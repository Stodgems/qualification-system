-- Server-side loadout selection system

-- Helper function for colored chat messages
local function QualChatPrint(ply, message)
    if not IsValid(ply) then return end
    
    net.Start("QualSystem_ColoredChat")
    net.WriteString(message)
    net.Send(ply)
end

util.AddNetworkString("QualSystem_OpenLoadoutMenu")
util.AddNetworkString("QualSystem_EquipLoadout")
util.AddNetworkString("QualSystem_SetDefaultLoadout")
util.AddNetworkString("QualSystem_SendLoadoutData")

-- Store active loadouts and preferences
QualSystem.ActiveLoadouts = QualSystem.ActiveLoadouts or {}
QualSystem.LoadoutPreferences = QualSystem.LoadoutPreferences or {}
QualSystem.LoadoutSwitchCooldowns = QualSystem.LoadoutSwitchCooldowns or {}
QualSystem.GrantedWeapons = QualSystem.GrantedWeapons or {} -- Track weapons granted by qualifications

-- Initialize loadout database table
function QualSystem:InitializeLoadoutDatabase()
    local loadoutTable = "qualification_system_loadouts"
    
    sql.Query(string.format([[
        CREATE TABLE IF NOT EXISTS %s (
            steamid TEXT PRIMARY KEY,
            default_loadout TEXT,
            auto_equip INTEGER DEFAULT 1
        )
    ]], loadoutTable))
    
    print("[Qualification System] Loadout database initialized")
end

-- Load player loadout preference
function QualSystem:LoadPlayerLoadoutPreference(steamid)
    local loadoutTable = "qualification_system_loadouts"
    local query = string.format("SELECT * FROM %s WHERE steamid = %s", loadoutTable, sql.SQLStr(steamid))
    local result = sql.Query(query)
    
    if result then
        local defaultLoadout = result[1].default_loadout
        local autoEquip = tonumber(result[1].auto_equip) == 1
        
        -- Validate that the qualification still exists
        if defaultLoadout ~= "none" and not self.Qualifications[defaultLoadout] then
            -- Qualification was deleted, reset to none
            self:SavePlayerLoadoutPreference(steamid, "none", false)
            return {
                default_loadout = "none",
                auto_equip = false
            }
        end
        
        return {
            default_loadout = defaultLoadout,
            auto_equip = autoEquip
        }
    end
    
    return {
        default_loadout = "none",
        auto_equip = false
    }
end

-- Save player loadout preference
function QualSystem:SavePlayerLoadoutPreference(steamid, defaultLoadout, autoEquip)
    local loadoutTable = "qualification_system_loadouts"
    
    -- Validate qualification exists before saving
    if defaultLoadout ~= "none" and not self.Qualifications[defaultLoadout] then
        defaultLoadout = "none"
        autoEquip = false
    end
    
    local query = string.format([[
        INSERT OR REPLACE INTO %s (steamid, default_loadout, auto_equip)
        VALUES (%s, %s, %d)
    ]], loadoutTable,
        sql.SQLStr(steamid),
        sql.SQLStr(defaultLoadout or "none"),
        autoEquip and 1 or 0
    )
    
    sql.Query(query)
    self.LoadoutPreferences[steamid] = {
        default_loadout = defaultLoadout,
        auto_equip = autoEquip
    }
end

-- Equip a specific qualification loadout
function QualSystem:EquipQualificationLoadout(ply, qualName)
    if not IsValid(ply) then return false end

    local steamid = ply:SteamID()

    -- Check cooldown to prevent rapid switching
    local now = CurTime()
    local lastSwitch = self.LoadoutSwitchCooldowns[steamid] or 0
    if now - lastSwitch < 0.5 then
        QualChatPrint(ply, "Please wait before switching loadouts again.")
        return false
    end

    -- Update cooldown timestamp
    self.LoadoutSwitchCooldowns[steamid] = now

    -- "none" means use default loadout (no qualification equipped)
    if qualName == "none" then
        self.ActiveLoadouts[steamid] = "none"
        -- Automatically save "none" as the default loadout
        self:SavePlayerLoadoutPreference(steamid, "none", true)
        -- Actively remove qualification effects and restore job defaults
        self:RemoveQualificationEffects(ply)
        QualChatPrint(ply, "Using default loadout")
        return true
    end

    -- Check if qualification exists
    if not self.Qualifications[qualName] then
        QualChatPrint(ply, "This qualification no longer exists!")
        -- Reset to default loadout
        self.ActiveLoadouts[steamid] = "none"
        return false
    end

    -- Check if player has this qualification
    if not self:PlayerHasQualification(ply, qualName) then
        QualChatPrint(ply, "You don't have access to this qualification!")
        -- Reset to default loadout
        self.ActiveLoadouts[steamid] = "none"
        return false
    end

    -- Store active loadout
    self.ActiveLoadouts[steamid] = qualName

    -- Automatically save this as the default loadout (auto-equip enabled by default)
    self:SavePlayerLoadoutPreference(steamid, qualName, true)

    -- Apply qualification effects (which now includes removal)
    self:ApplyQualificationEffects(ply, qualName)

    local qualData = self.Qualifications[qualName]
    QualChatPrint(ply, string.format("Equipped loadout: %s", qualData.display_name))

    return true
end

-- Get player's active loadout
function QualSystem:GetActiveLoadout(ply)
    if not IsValid(ply) then return nil end
    return self.ActiveLoadouts[ply:SteamID()]
end

-- Send loadout data to client
function QualSystem:SendLoadoutData(ply)
    if not IsValid(ply) then return end
    
    local steamid = ply:SteamID()
    
    -- Load from cache first, then database if not cached
    if not self.LoadoutPreferences[steamid] then
        self.LoadoutPreferences[steamid] = self:LoadPlayerLoadoutPreference(steamid)
    end
    
    local preference = self.LoadoutPreferences[steamid]
    local activeLoadout = self.ActiveLoadouts[steamid] or "none"
    
    local defaultLoadout = preference.default_loadout or "none"
    local autoEquip = preference.auto_equip or false
    
    -- Validate default loadout still exists
    if defaultLoadout ~= "none" and not self.Qualifications[defaultLoadout] then
        defaultLoadout = "none"
        autoEquip = false
        -- Update the preference
        self:SavePlayerLoadoutPreference(steamid, "none", false)
    end
    
    -- Validate active loadout still exists
    if activeLoadout ~= "none" and not self.Qualifications[activeLoadout] then
        activeLoadout = "none"
        self.ActiveLoadouts[steamid] = "none"
    end
    
    net.Start("QualSystem_SendLoadoutData")
    net.WriteString(activeLoadout)
    net.WriteString(defaultLoadout)
    net.WriteBool(autoEquip)
    net.Send(ply)
end

-- Network receivers
net.Receive("QualSystem_EquipLoadout", function(len, ply)
    local qualName = net.ReadString()
    QualSystem:EquipQualificationLoadout(ply, qualName)
    
    -- Send updated data back
    timer.Simple(0.1, function()
        if IsValid(ply) then
            QualSystem:SendLoadoutData(ply)
        end
    end)
end)

net.Receive("QualSystem_SetDefaultLoadout", function(len, ply)
    local defaultLoadout = net.ReadString()
    local autoEquip = net.ReadBool()
    
    local steamid = ply:SteamID()
    
    -- Validate qualification exists
    if defaultLoadout ~= "none" and not QualSystem.Qualifications[defaultLoadout] then
        QualChatPrint(ply, "That qualification no longer exists!")
        return
    end
    
    -- Save to database and cache
    QualSystem:SavePlayerLoadoutPreference(steamid, defaultLoadout, autoEquip)
    
    -- Update cache immediately
    QualSystem.LoadoutPreferences[steamid] = {
        default_loadout = defaultLoadout,
        auto_equip = autoEquip
    }
    
    QualChatPrint(ply, "Loadout preferences saved!")
    
    -- Send updated data back
    timer.Simple(0.1, function()
        if IsValid(ply) then
            QualSystem:SendLoadoutData(ply)
        end
    end)
end)

-- Initialize on server start
hook.Add("Initialize", "QualSystem_InitializeLoadout", function()
    QualSystem:InitializeLoadoutDatabase()
end)

-- Apply default loadout on spawn
hook.Add("PlayerSpawn", "QualSystem_ApplyLoadout", function(ply)
    timer.Simple(0.5, function()
        if not IsValid(ply) then return end

        local steamid = ply:SteamID()

        -- Load preference if not cached
        if not QualSystem.LoadoutPreferences[steamid] then
            QualSystem.LoadoutPreferences[steamid] = QualSystem:LoadPlayerLoadoutPreference(steamid)
        end

        local preference = QualSystem.LoadoutPreferences[steamid]
        local savedLoadout = preference.default_loadout or "none"

        -- Validate the saved loadout still exists
        if savedLoadout ~= "none" and not QualSystem.Qualifications[savedLoadout] then
            -- Qualification was deleted, reset to none
            QualSystem:SavePlayerLoadoutPreference(steamid, "none", true)
            savedLoadout = "none"
        end

        -- Always auto-equip the last selected loadout
        if savedLoadout ~= "none" then
            -- Check if player still has access to this qualification
            if QualSystem.Qualifications[savedLoadout] and
               QualSystem:PlayerHasQualification(ply, savedLoadout) then
                QualSystem:EquipQualificationLoadout(ply, savedLoadout)
            else
                -- Player no longer has access, reset to default
                QualSystem.ActiveLoadouts[steamid] = "none"
                QualSystem:SavePlayerLoadoutPreference(steamid, "none", true)
            end
        else
            -- Using default loadout (none)
            QualSystem.ActiveLoadouts[steamid] = "none"
        end
    end)
end)

-- Chat command to open loadout menu
hook.Add("PlayerSay", "QualSystem_LoadoutCommand", function(ply, text)
    if text == "!loadout" or text == "/loadout" or text == "!loadouts" or text == "/loadouts" then
        -- Send player's qualifications first
        local steamid = ply:SteamID()
        net.Start("QualSystem_SendPlayerQuals")
        net.WriteString(steamid)
        net.WriteTable(QualSystem:GetPlayerQualifications(ply))
        net.Send(ply)

        -- Send current loadout data
        QualSystem:SendLoadoutData(ply)

        -- Open menu after a small delay to ensure data arrives first
        timer.Simple(0.05, function()
            if IsValid(ply) then
                net.Start("QualSystem_OpenLoadoutMenu")
                net.Send(ply)
            end
        end)

        return ""
    end
end)

-- Override ApplyQualificationEffects to check active loadout
local oldApplyEffects = QualSystem.ApplyQualificationEffects
function QualSystem:ApplyQualificationEffects(ply, qualName)
    if not IsValid(ply) then return end
    
    -- Check if qualification still exists
    if not self.Qualifications[qualName] then
        return
    end
    
    local steamid = ply:SteamID()
    local activeLoadout = self.ActiveLoadouts[steamid]
    
    -- Only apply effects if this is the active loadout or no loadout preference is set
    if activeLoadout == nil or activeLoadout == qualName then
        oldApplyEffects(self, ply, qualName)
    end
end

print("[Qualification System] Loadout system loaded!")

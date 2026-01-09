-- Server-side qualification effects application

-- Helper function for colored chat messages
local function QualChatPrint(ply, message)
    if not IsValid(ply) then return end

    net.Start("QualSystem_ColoredChat")
    net.WriteString(message)
    net.Send(ply)
end

-- Remove current qualification effects and restore DarkRP job defaults
function QualSystem:RemoveQualificationEffects(ply)
    if not IsValid(ply) then return end

    local steamid = ply:SteamID()

    -- Step 1: Remove only weapons that were granted by the qualification
    if self.GrantedWeapons[steamid] then
        for _, weaponClass in ipairs(self.GrantedWeapons[steamid]) do
            if ply:HasWeapon(weaponClass) then
                ply:StripWeapon(weaponClass)
            end
        end
        -- Clear the tracked weapons list
        self.GrantedWeapons[steamid] = nil
    end

    -- Step 2: Check if DarkRP is available
    local hasDarkRP = DarkRP ~= nil

    if hasDarkRP then
        -- Step 3a: Restore DarkRP job defaults

        -- Get job table - this contains all default job properties
        local jobTable = ply:getJobTable()

        if jobTable then
            -- Restore health from job or DarkRP default
            local defaultHealth = jobTable.health or GAMEMODE.Config.startinghealth or 100
            ply:SetHealth(defaultHealth)
            ply:SetMaxHealth(defaultHealth)

            -- Restore armor from job
            local defaultArmor = jobTable.armor or 0
            ply:SetArmor(defaultArmor)

            -- Restore model from job
            if jobTable.model then
                -- DarkRP jobs can have single model or table of models
                local modelToUse = jobTable.model
                if istable(jobTable.model) then
                    -- If multiple models, use the first one
                    modelToUse = jobTable.model[1]
                end
                ply:SetModel(modelToUse)

                -- Reset skin and bodygroups to defaults after model is set
                timer.Simple(0.1, function()
                    if IsValid(ply) then
                        ply:SetSkin(0)
                        -- Reset all bodygroups to 0
                        for i = 0, ply:GetNumBodyGroups() - 1 do
                            ply:SetBodygroup(i, 0)
                        end
                    end
                end)
            end
        end
    else
        -- Step 3b: Fallback for non-DarkRP servers (base Garry's Mod)

        -- Set to default GMod health
        ply:SetHealth(100)
        ply:SetMaxHealth(100)

        -- Remove all armor
        ply:SetArmor(0)

        -- Restore default player model
        ply:SetModel("models/player/group01/male_02.mdl")

        -- Reset skin and bodygroups
        timer.Simple(0.1, function()
            if IsValid(ply) then
                ply:SetSkin(0)
                for i = 0, ply:GetNumBodyGroups() - 1 do
                    ply:SetBodygroup(i, 0)
                end
            end
        end)
    end
end

-- Apply qualification effects to a player
function QualSystem:ApplyQualificationEffects(ply, qualName)
    if not IsValid(ply) then return end

    -- Check if qualification still exists
    if not self.Qualifications[qualName] then
        print(string.format("[Qualification System] Attempted to apply non-existent qualification '%s' to %s", qualName, ply:Nick()))
        return
    end

    local qualData = self.Qualifications[qualName]

    -- Check if player's job is allowed for this qualification
    if not self:IsPlayerJobAllowed(ply, qualData) then
        return -- Don't apply effects if job isn't allowed
    end

    -- Remove old qualification effects before applying new ones
    self:RemoveQualificationEffects(ply)

    -- Add delay to ensure removal completes before applying new effects
    timer.Simple(0.1, function()
        if not IsValid(ply) then return end

        -- Revalidate qualification still exists after delay
        if not self.Qualifications[qualName] then return end
        local qualData = self.Qualifications[qualName]

        -- Apply health
        if qualData.health and qualData.health > 0 then
            ply:SetHealth(qualData.health)
            ply:SetMaxHealth(qualData.health)
        end

        -- Apply armor
        if qualData.armor and qualData.armor > 0 then
            ply:SetArmor(qualData.armor)
        end

        -- Apply model
        if qualData.model and qualData.model ~= "" then
            ply:SetModel(qualData.model)

            -- Apply skin and bodygroups after a small delay to ensure model is loaded
            timer.Simple(0.1, function()
                if not IsValid(ply) then return end

                -- Apply skin
                if qualData.skin and qualData.skin > 0 then
                    ply:SetSkin(qualData.skin)
                end

                -- Apply bodygroups
                if qualData.bodygroups and table.Count(qualData.bodygroups) > 0 then
                    for bgName, bgValue in pairs(qualData.bodygroups) do
                        local bgIndex = ply:FindBodygroupByName(bgName)
                        if bgIndex ~= -1 then
                            ply:SetBodygroup(bgIndex, bgValue)
                        end
                    end
                end
            end)
        end

        -- Give weapons and track them
        if qualData.weapons and #qualData.weapons > 0 then
            local steamid = ply:SteamID()
            QualSystem.GrantedWeapons[steamid] = QualSystem.GrantedWeapons[steamid] or {}

            for _, weapon in ipairs(qualData.weapons) do
                if weapon ~= "" then
                    ply:Give(weapon)
                    -- Track this weapon as granted by qualification
                    table.insert(QualSystem.GrantedWeapons[steamid], weapon)
                end
            end
        end

        -- Execute custom function
        if qualData.custom_function and qualData.custom_function ~= "" then
            local func, err = CompileString(qualData.custom_function, "QualificationCustomFunction_" .. qualName)
            if func then
                local success, error = pcall(func, ply, qualData)
                if not success then
                    print("[Qualification System] Error executing custom function for " .. qualName .. ": " .. tostring(error))
                end
            else
                print("[Qualification System] Error compiling custom function for " .. qualName .. ": " .. tostring(err))
            end
        end
    end)
end

-- Chat command handler
hook.Add("PlayerSay", "QualSystem_ChatCommands", function(ply, text)
    if text == QualSystem.Config.AdminCommand then
        if QualSystem:IsAdmin(ply) then
            net.Start("QualSystem_OpenAdminMenu")
            net.Send(ply)
        else
            QualChatPrint(ply, "You don't have permission to use this command!")
        end
        return ""
    end
    
    if text == "!quals" then
        net.Start("QualSystem_OpenContextMenu")
        net.WriteEntity(ply)
        net.Send(ply)
        return ""
    end
end)

-- Network receivers
net.Receive("QualSystem_CreateQualification", function(len, ply)
    if not QualSystem:IsAdmin(ply) then return end
    
    local data = net.ReadTable()
    if QualSystem:CreateQualification(data) then
        QualChatPrint(ply, "Qualification created successfully!")
    else
        QualChatPrint(ply, "Failed to create qualification!")
    end
end)

net.Receive("QualSystem_UpdateQualification", function(len, ply)
    if not QualSystem:IsAdmin(ply) then return end
    
    local data = net.ReadTable()
    if QualSystem:UpdateQualification(data) then
        QualChatPrint(ply, "Qualification updated successfully!")
    else
        QualChatPrint(ply, "Failed to update qualification!")
    end
end)

net.Receive("QualSystem_DeleteQualification", function(len, ply)
    if not QualSystem:IsAdmin(ply) then return end
    
    local qualName = net.ReadString()
    QualSystem:DeleteQualification(qualName)
    QualChatPrint(ply, "Qualification deleted successfully!")
end)

net.Receive("QualSystem_AddPlayerQual", function(len, ply)
    local targetSteamID = net.ReadString()
    local qualName = net.ReadString()
    
    local target = player.GetBySteamID(targetSteamID)
    if not IsValid(target) then 
        QualChatPrint(ply, "Target player not found!")
        return 
    end
    
    local qualData = QualSystem.Qualifications[qualName]
    if not qualData then
        QualChatPrint(ply, "Invalid qualification!")
        return
    end
    
    -- Check permissions
    if not QualSystem:CanManageQualification(ply, qualData) then
        QualChatPrint(ply, "You don't have permission to assign this qualification!")
        return
    end
    
    -- Check job restrictions
    if not QualSystem:IsPlayerJobAllowed(target, qualData) then
        local jobsList = table.concat(qualData.allowed_jobs, ", ")
        QualChatPrint(ply, string.format("%s's job is not allowed for this qualification! Allowed jobs: %s", target:Nick(), jobsList))
        return
    end
    
    if QualSystem:AddPlayerQualification(target, qualName, ply:Nick()) then
        QualChatPrint(ply, string.format("Added '%s' to %s", qualData.display_name, target:Nick()))
        QualChatPrint(target, string.format("You have been granted the '%s' qualification!", qualData.display_name))
    else
        QualChatPrint(ply, "Failed to add qualification!")
    end
end)

net.Receive("QualSystem_RemovePlayerQual", function(len, ply)
    local targetSteamID = net.ReadString()
    local qualName = net.ReadString()
    
    local target = player.GetBySteamID(targetSteamID)
    if not IsValid(target) then 
        QualChatPrint(ply, "Target player not found!")
        return 
    end
    
    local qualData = QualSystem.Qualifications[qualName]
    if not qualData then
        QualChatPrint(ply, "Invalid qualification!")
        return
    end
    
    -- Check permissions
    if not QualSystem:CanManageQualification(ply, qualData) then
        QualChatPrint(ply, "You don't have permission to remove this qualification!")
        return
    end
    
    if QualSystem:RemovePlayerQualification(target, qualName) then
        QualChatPrint(ply, string.format("Removed '%s' from %s", qualData.display_name, target:Nick()))
        QualChatPrint(target, string.format("Your '%s' qualification has been removed.", qualData.display_name))
    else
        QualChatPrint(ply, "Failed to remove qualification!")
    end
end)

net.Receive("QualSystem_RequestPlayerQuals", function(len, ply)
    local targetSteamID = net.ReadString()
    local target = player.GetBySteamID(targetSteamID)
    
    if not IsValid(target) then return end
    
    local quals = QualSystem:GetPlayerQualifications(target)
    
    net.Start("QualSystem_SendPlayerQuals")
    net.WriteString(targetSteamID)
    net.WriteTable(quals)
    net.Send(ply)
end)

-- Reapply qualifications when player changes job
hook.Add("OnPlayerChangedTeam", "QualSystem_JobChange", function(ply, oldTeam, newTeam)
    if not IsValid(ply) then return end

    -- Small delay to ensure job change is complete
    timer.Simple(0.1, function()
        if not IsValid(ply) then return end

        local steamid = ply:SteamID()
        local activeLoadout = QualSystem.ActiveLoadouts[steamid]

        -- If player has an active loadout, reapply it
        if activeLoadout and activeLoadout ~= "none" then
            -- Check if the qualification still exists and player still has access
            if QualSystem.Qualifications[activeLoadout] and
               QualSystem:PlayerHasQualification(ply, activeLoadout) then
                -- Check if the new job is allowed for this qualification
                local qualData = QualSystem.Qualifications[activeLoadout]
                if QualSystem:IsPlayerJobAllowed(ply, qualData) then
                    -- Job is allowed, reapply the qualification
                    QualSystem:ApplyQualificationEffects(ply, activeLoadout)
                else
                    -- Job is not allowed, reset to default
                    QualSystem.ActiveLoadouts[steamid] = "none"
                    QualSystem:RemoveQualificationEffects(ply)
                    QualChatPrint(ply, "Your active loadout is not allowed for your new job. Switched to default.")
                end
            else
                -- Qualification no longer exists or player lost access
                QualSystem.ActiveLoadouts[steamid] = "none"
                QualSystem:RemoveQualificationEffects(ply)
            end
        else
            -- No active loadout, ensure job defaults are applied
            QualSystem:RemoveQualificationEffects(ply)
        end
    end)
end)

print("[Qualification System] Server-side effects loaded!")

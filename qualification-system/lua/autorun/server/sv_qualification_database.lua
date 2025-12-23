-- Server-side database and qualification management
util.AddNetworkString("QualSystem_OpenAdminMenu")
util.AddNetworkString("QualSystem_SendQualifications")
util.AddNetworkString("QualSystem_CreateQualification")
util.AddNetworkString("QualSystem_UpdateQualification")
util.AddNetworkString("QualSystem_DeleteQualification")
util.AddNetworkString("QualSystem_AddPlayerQual")
util.AddNetworkString("QualSystem_RemovePlayerQual")
util.AddNetworkString("QualSystem_RequestPlayerQuals")
util.AddNetworkString("QualSystem_SendPlayerQuals")
util.AddNetworkString("QualSystem_OpenContextMenu")

QualSystem.Qualifications = QualSystem.Qualifications or {}
QualSystem.PlayerQualifications = QualSystem.PlayerQualifications or {}

-- Initialize database
function QualSystem:InitializeDatabase()
    local qualsTable = self.Config.Tables.qualifications
    local playerQualsTable = self.Config.Tables.player_quals
    
    -- Create qualifications table
    sql.Query(string.format([[
        CREATE TABLE IF NOT EXISTS %s (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            display_name TEXT NOT NULL,
            description TEXT,
            model TEXT,
            health INTEGER DEFAULT 100,
            armor INTEGER DEFAULT 0,
            weapons TEXT,
            staff_only INTEGER DEFAULT 1,
            allow_teachers INTEGER DEFAULT 0,
            teacher_qual TEXT,
            custom_function TEXT,
            allowed_jobs TEXT,
            created_at INTEGER
        )
    ]], qualsTable))
    
    -- Add allowed_jobs column if it doesn't exist (for existing databases)
    sql.Query(string.format("ALTER TABLE %s ADD COLUMN allowed_jobs TEXT", qualsTable))
    
    -- Create player qualifications table
    sql.Query(string.format([[
        CREATE TABLE IF NOT EXISTS %s (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            steamid TEXT NOT NULL,
            qualification_name TEXT NOT NULL,
            granted_by TEXT,
            granted_at INTEGER,
            UNIQUE(steamid, qualification_name)
        )
    ]], playerQualsTable))
    
    print("[Qualification System] Database initialized")
end

-- Load all qualifications from database
function QualSystem:LoadQualifications()
    local qualsTable = self.Config.Tables.qualifications
    local query = string.format("SELECT * FROM %s", qualsTable)
    local results = sql.Query(query)
    
    self.Qualifications = {}
    
    if results then
        for _, row in ipairs(results) do
            local qualData = {
                id = tonumber(row.id),
                name = row.name,
                display_name = row.display_name,
                description = row.description or "",
                model = row.model or "",
                health = tonumber(row.health) or 100,
                armor = tonumber(row.armor) or 0,
                weapons = util.JSONToTable(row.weapons or "[]") or {},
                staff_only = tonumber(row.staff_only) == 1,
                allow_teachers = tonumber(row.allow_teachers) == 1,
                teacher_qual = row.teacher_qual or "",
                custom_function = row.custom_function or "",
                allowed_jobs = util.JSONToTable(row.allowed_jobs or "[]") or {},
                created_at = tonumber(row.created_at)
            }
            self.Qualifications[row.name] = qualData
        end
        print(string.format("[Qualification System] Loaded %d qualifications", table.Count(self.Qualifications)))
    end
end

-- Load player qualifications from database
function QualSystem:LoadPlayerQualifications()
    local playerQualsTable = self.Config.Tables.player_quals
    local query = string.format("SELECT * FROM %s", playerQualsTable)
    local results = sql.Query(query)
    
    self.PlayerQualifications = {}
    
    if results then
        for _, row in ipairs(results) do
            local steamid = row.steamid
            if not self.PlayerQualifications[steamid] then
                self.PlayerQualifications[steamid] = {}
            end
            table.insert(self.PlayerQualifications[steamid], {
                qualification_name = row.qualification_name,
                granted_by = row.granted_by,
                granted_at = tonumber(row.granted_at)
            })
        end
        print(string.format("[Qualification System] Loaded player qualifications"))
    end
end

-- Helper function to create or ensure teacher qualification exists
function QualSystem:EnsureTeacherQualification(teacherQualName)
    if teacherQualName == "" then return end
    
    -- Check if teacher qualification already exists
    if self.Qualifications[teacherQualName] then return end
    
    local qualsTable = self.Config.Tables.qualifications
    
    -- Create the teacher qualification
    local query = string.format([[
        INSERT INTO %s (name, display_name, description, model, health, armor, weapons, staff_only, allow_teachers, teacher_qual, custom_function, created_at)
        VALUES (%s, %s, %s, %s, %d, %d, %s, %d, %d, %s, %s, %d)
    ]], qualsTable,
        sql.SQLStr(teacherQualName),
        sql.SQLStr(teacherQualName .. " (Teacher)"),
        sql.SQLStr("Teacher qualification - allows assigning specific qualifications"),
        sql.SQLStr(""),
        100,
        0,
        sql.SQLStr("[]"),
        1, -- staff_only
        0, -- allow_teachers
        sql.SQLStr(""),
        sql.SQLStr(""),
        os.time()
    )
    
    local result = sql.Query(query)
    if result == false then
        print("[Qualification System] Error creating teacher qualification: " .. sql.LastError())
    else
        print(string.format("[Qualification System] Auto-created teacher qualification: %s", teacherQualName))
    end
end

-- Create a new qualification
function QualSystem:CreateQualification(data)
    local qualsTable = self.Config.Tables.qualifications
    
    -- If allow_teachers is enabled and teacher_qual is set, ensure the teacher qualification exists
    if data.allow_teachers and data.teacher_qual and data.teacher_qual ~= "" then
        self:EnsureTeacherQualification(data.teacher_qual)
    end
    
    local query = string.format([[
        INSERT INTO %s (name, display_name, description, model, health, armor, weapons, staff_only, allow_teachers, teacher_qual, custom_function, allowed_jobs, created_at)
        VALUES (%s, %s, %s, %s, %d, %d, %s, %d, %d, %s, %s, %s, %d)
    ]], qualsTable,
        sql.SQLStr(data.name),
        sql.SQLStr(data.display_name),
        sql.SQLStr(data.description or ""),
        sql.SQLStr(data.model or ""),
        data.health or 100,
        data.armor or 0,
        sql.SQLStr(util.TableToJSON(data.weapons or {})),
        data.staff_only and 1 or 0,
        data.allow_teachers and 1 or 0,
        sql.SQLStr(data.teacher_qual or ""),
        sql.SQLStr(data.custom_function or ""),
        sql.SQLStr(util.TableToJSON(data.allowed_jobs or {})),
        os.time()
    )
    
    local result = sql.Query(query)
    if result == false then
        print("[Qualification System] Error creating qualification: " .. sql.LastError())
        return false
    end
    
    self:LoadQualifications()
    self:SyncQualificationsToClients()
    return true
end

-- Update an existing qualification
function QualSystem:UpdateQualification(data)
    local qualsTable = self.Config.Tables.qualifications
    
    -- If allow_teachers is enabled and teacher_qual is set, ensure the teacher qualification exists
    if data.allow_teachers and data.teacher_qual and data.teacher_qual ~= "" then
        self:EnsureTeacherQualification(data.teacher_qual)
    end
    
    local query = string.format([[
        UPDATE %s SET 
            display_name = %s,
            description = %s,
            model = %s,
            health = %d,
            armor = %d,
            weapons = %s,
            staff_only = %d,
            allow_teachers = %d,
            teacher_qual = %s,
            custom_function = %s,
            allowed_jobs = %s
        WHERE name = %s
    ]], qualsTable,
        sql.SQLStr(data.display_name),
        sql.SQLStr(data.description or ""),
        sql.SQLStr(data.model or ""),
        data.health or 100,
        data.armor or 0,
        sql.SQLStr(util.TableToJSON(data.weapons or {})),
        data.staff_only and 1 or 0,
        data.allow_teachers and 1 or 0,
        sql.SQLStr(data.teacher_qual or ""),
        sql.SQLStr(data.custom_function or ""),
        sql.SQLStr(util.TableToJSON(data.allowed_jobs or {})),
        sql.SQLStr(data.name)
    )
    
    local result = sql.Query(query)
    if result == false then
        print("[Qualification System] Error updating qualification: " .. sql.LastError())
        return false
    end
    
    self:LoadQualifications()
    self:SyncQualificationsToClients()
    return true
end

-- Delete a qualification
function QualSystem:DeleteQualification(name)
    local qualsTable = self.Config.Tables.qualifications
    local query = string.format("DELETE FROM %s WHERE name = %s", qualsTable, sql.SQLStr(name))
    sql.Query(query)
    
    self:LoadQualifications()
    self:SyncQualificationsToClients()
end

-- Add qualification to player
function QualSystem:AddPlayerQualification(ply, qualName, grantedBy)
    if not IsValid(ply) then return false end
    if not self.Qualifications[qualName] then return false end
    
    local steamid = ply:SteamID()
    local playerQualsTable = self.Config.Tables.player_quals
    
    local query = string.format([[
        INSERT OR REPLACE INTO %s (steamid, qualification_name, granted_by, granted_at)
        VALUES (%s, %s, %s, %d)
    ]], playerQualsTable,
        sql.SQLStr(steamid),
        sql.SQLStr(qualName),
        sql.SQLStr(grantedBy or "Unknown"),
        os.time()
    )
    
    sql.Query(query)
    
    if not self.PlayerQualifications[steamid] then
        self.PlayerQualifications[steamid] = {}
    end
    
    -- Check if already exists
    local exists = false
    for _, qual in ipairs(self.PlayerQualifications[steamid]) do
        if qual.qualification_name == qualName then
            exists = true
            break
        end
    end
    
    if not exists then
        table.insert(self.PlayerQualifications[steamid], {
            qualification_name = qualName,
            granted_by = grantedBy or "Unknown",
            granted_at = os.time()
        })
    end
    
    -- Apply qualification effects
    self:ApplyQualificationEffects(ply, qualName)
    
    return true
end

-- Remove qualification from player
function QualSystem:RemovePlayerQualification(ply, qualName)
    if not IsValid(ply) then return false end
    
    local steamid = ply:SteamID()
    local playerQualsTable = self.Config.Tables.player_quals
    
    local query = string.format([[
        DELETE FROM %s WHERE steamid = %s AND qualification_name = %s
    ]], playerQualsTable, sql.SQLStr(steamid), sql.SQLStr(qualName))
    
    sql.Query(query)
    
    if self.PlayerQualifications[steamid] then
        for i, qual in ipairs(self.PlayerQualifications[steamid]) do
            if qual.qualification_name == qualName then
                table.remove(self.PlayerQualifications[steamid], i)
                break
            end
        end
    end
    
    return true
end

-- Check if player has qualification
function QualSystem:PlayerHasQualification(ply, qualName)
    if not IsValid(ply) then return false end
    
    local steamid = ply:SteamID()
    if not self.PlayerQualifications[steamid] then return false end
    
    for _, qual in ipairs(self.PlayerQualifications[steamid]) do
        if qual.qualification_name == qualName then
            return true
        end
    end
    
    return false
end

-- Get all player qualifications
function QualSystem:GetPlayerQualifications(ply)
    if not IsValid(ply) then return {} end
    return self.PlayerQualifications[ply:SteamID()] or {}
end

-- Sync qualifications to all clients
function QualSystem:SyncQualificationsToClients()
    net.Start("QualSystem_SendQualifications")
    net.WriteTable(self.Qualifications)
    net.Broadcast()
end

-- Initialize on server start
hook.Add("Initialize", "QualSystem_Initialize", function()
    QualSystem:InitializeDatabase()
    QualSystem:LoadQualifications()
    QualSystem:LoadPlayerQualifications()
end)

-- Send qualifications to player on spawn
hook.Add("PlayerInitialSpawn", "QualSystem_PlayerSpawn", function(ply)
    timer.Simple(1, function()
        if not IsValid(ply) then return end
        
        net.Start("QualSystem_SendQualifications")
        net.WriteTable(QualSystem.Qualifications)
        net.Send(ply)
        
        -- Apply existing qualifications
        local quals = QualSystem:GetPlayerQualifications(ply)
        for _, qual in ipairs(quals) do
            QualSystem:ApplyQualificationEffects(ply, qual.qualification_name)
        end
    end)
end)

print("[Qualification System] Server-side database loaded!")

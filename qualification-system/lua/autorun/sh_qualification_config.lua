-- Qualification System Configuration
-- This file is shared between server and client

QualSystem = QualSystem or {}
QualSystem.Config = {}

-- Admin ranks that can access !qualadmin and manage qualifications
-- Add your admin ranks here (case sensitive)
QualSystem.Config.AdminRanks = {
    ["superadmin"] = true,
    ["admin"] = true,
    -- Add more admin ranks as needed
    -- ["moderator"] = true,
}

-- Chat command to open the admin menu
QualSystem.Config.AdminCommand = "!qualadmin"

-- Database table names
QualSystem.Config.Tables = {
    qualifications = "qualification_system_quals",
    player_quals = "qualification_system_player_quals"
}

-- Default qualification settings
QualSystem.Config.Defaults = {
    health = 100,
    armor = 0,
    model = "",
    weapons = {},
    staff_only = true, -- By default, only staff can assign qualifications
    allow_teachers = false, -- By default, teachers cannot assign
}

-- Function to check if a player is an admin
function QualSystem:IsAdmin(ply)
    if not IsValid(ply) then return false end
    local usergroup = ply:GetUserGroup()
    return self.Config.AdminRanks[usergroup] == true
end

-- Function to check if a player can manage a specific qualification
function QualSystem:CanManageQualification(ply, qualData)
    if not IsValid(ply) then return false end
    
    -- Admins can always manage
    if self:IsAdmin(ply) then return true end
    
    -- If qualification allows teachers, check if player has the teacher qualification
    if qualData.allow_teachers and qualData.teacher_qual and qualData.teacher_qual ~= "" then
        if SERVER then
            return self:PlayerHasQualification(ply, qualData.teacher_qual)
        else
            -- Client-side check using cached player qualifications
            local steamid = ply:SteamID()
            local playerQuals = self.PlayerQuals[steamid] or {}
            
            for _, qual in ipairs(playerQuals) do
                if qual.qualification_name == qualData.teacher_qual then
                    return true
                end
            end
        end
    end
    
    return false
end

print("[Qualification System] Config loaded successfully!")

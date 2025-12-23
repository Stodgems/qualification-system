-- SAM Integration for Qualification System

-- Wait for SAM to load
hook.Add("Initialize", "QualSystem_SAM_Integration", function()
    -- Check if SAM is installed
    if not sam then return end
    
    -- Register permissions with SAM
    sam.permissions.add("qualification_admin", "Qualification System", "superadmin")
    
    print("[Qualification System] SAM permissions registered!")
    
    -- Override the IsAdmin function to use SAM permissions
    function QualSystem:IsAdmin(ply)
        if not IsValid(ply) then return false end
        
        -- Check SAM permission for full admin access
        if ply:HasPermission("qualification_admin") then
            return true
        end
        
        -- Fallback to original usergroup check
        local usergroup = ply:GetUserGroup()
        return self.Config.AdminRanks[usergroup] == true
    end
end)

print("[Qualification System] SAM integration loaded!")

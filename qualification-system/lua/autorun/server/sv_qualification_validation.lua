-- Qualification validation and restrictions

-- Check if player's job is allowed for a qualification
function QualSystem:IsPlayerJobAllowed(ply, qualData)
    if not IsValid(ply) then return false end
    if not qualData then return false end
    
    -- If no job restrictions, allow all jobs
    if not qualData.allowed_jobs or #qualData.allowed_jobs == 0 then
        return true
    end
    
    -- Get player's team (job)
    local playerTeam = ply:Team()
    local teamName = team.GetName(playerTeam)
    
    -- Check if player's team is in the allowed list
    -- Support both team number and team name
    for _, allowedJob in ipairs(qualData.allowed_jobs) do
        -- Check by team constant name (e.g., "TEAM_MEDIC")
        if _G[allowedJob] and _G[allowedJob] == playerTeam then
            return true
        end
        
        -- Check by team name (e.g., "Medic")
        if string.lower(allowedJob) == string.lower(teamName) then
            return true
        end
        
        -- Check by team number as string
        if tonumber(allowedJob) == playerTeam then
            return true
        end
    end
    
    return false
end

print("[Qualification System] Validation loaded!")

-- Client-side networking and data synchronization

QualSystem.Qualifications = QualSystem.Qualifications or {}
QualSystem.PlayerQuals = QualSystem.PlayerQuals or {}

-- Receive qualifications from server
net.Receive("QualSystem_SendQualifications", function()
    QualSystem.Qualifications = net.ReadTable()
    print("[Qualification System] Received qualifications from server")
end)

-- Receive player qualifications
net.Receive("QualSystem_SendPlayerQuals", function()
    local steamid = net.ReadString()
    local quals = net.ReadTable()
    QualSystem.PlayerQuals[steamid] = quals
end)

-- Request to open admin menu
net.Receive("QualSystem_OpenAdminMenu", function()
    QualSystem:OpenAdminMenu()
end)

print("[Qualification System] Client-side networking loaded!")

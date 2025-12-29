-- Server-side qualification effects application

-- Helper function for colored chat messages
local function QualChatPrint(ply, message)
    if not IsValid(ply) then return end
    
    net.Start("QualSystem_ColoredChat")
    net.WriteString(message)
    net.Send(ply)
end

-- Apply qualification effects to a player
function QualSystem:ApplyQualificationEffects(ply, qualName)
    if not IsValid(ply) then return end
    if not self.Qualifications[qualName] then return end
    
    local qualData = self.Qualifications[qualName]
    
    -- Check if player's job is allowed for this qualification
    if not self:IsPlayerJobAllowed(ply, qualData) then
        return -- Don't apply effects if job isn't allowed
    end
    
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
    
    -- Give weapons
    if qualData.weapons and #qualData.weapons > 0 then
        for _, weapon in ipairs(qualData.weapons) do
            if weapon ~= "" then
                ply:Give(weapon)
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
        
        -- Reapply all player's qualifications
        local quals = QualSystem:GetPlayerQualifications(ply)
        for _, qual in ipairs(quals) do
            QualSystem:ApplyQualificationEffects(ply, qual.qualification_name)
        end
    end)
end)

print("[Qualification System] Server-side effects loaded!")

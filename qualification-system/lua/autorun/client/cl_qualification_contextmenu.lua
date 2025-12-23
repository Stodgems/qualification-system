-- Context menu integration for assigning qualifications

-- Add context menu option when right-clicking a player
hook.Add("OnPlayerChat", "QualSystem_ContextMenuOpener", function(ply)
    -- This hook exists to ensure the client files are loaded
    -- The actual context menu is added via properties
end)

-- Add property for qualification management
properties.Add("qualification_manage", {
    MenuLabel = "Manage Qualifications",
    Order = 1000,
    MenuIcon = "icon16/user_edit.png",
    
    Filter = function(self, target, ply)
        if not IsValid(target) then return false end
        if not target:IsPlayer() then return false end
        if target == ply then return false end
        
        -- Check if player has any qualifications they can manage
        -- Staff can always manage
        if QualSystem:IsAdmin(LocalPlayer()) then return true end
        
        -- Check if player is a teacher for any qualification
        for name, qualData in pairs(QualSystem.Qualifications) do
            if qualData.allow_teachers and QualSystem:CanManageQualification(LocalPlayer(), qualData) then
                return true
            end
        end
        
        return false
    end,
    
    Action = function(self, target)
        QualSystem:OpenQualificationContextMenu(target)
    end
})

-- Open qualification assignment menu
function QualSystem:OpenQualificationContextMenu(target)
    if not IsValid(target) or not target:IsPlayer() then return end
    
    -- Request current qualifications for the target
    net.Start("QualSystem_RequestPlayerQuals")
    net.WriteString(target:SteamID())
    net.SendToServer()
    
    -- Also request local player's qualifications if not the same player
    if target ~= LocalPlayer() then
        net.Start("QualSystem_RequestPlayerQuals")
        net.WriteString(LocalPlayer():SteamID())
        net.SendToServer()
    end
    
    -- Wait a moment for the response
    timer.Simple(0.1, function()
        if not IsValid(target) then return end
        
        -- Create menu frame
        local frame = vgui.Create("DFrame")
        frame:SetSize(500, 450)
        frame:Center()
        frame:SetTitle("")
        frame:SetVisible(true)
        frame:SetDraggable(true)
        frame:ShowCloseButton(false)
        frame:MakePopup()
        
        frame.Paint = function(self, w, h)
            -- Main background
            draw.RoundedBox(8, 0, 0, w, h, Color(25, 25, 30, 250))
            
            -- Header bar with gradient
            draw.RoundedBoxEx(8, 0, 0, w, 45, Color(35, 100, 180, 255), true, true, false, false)
            draw.RoundedBox(0, 0, 40, w, 5, Color(45, 120, 200, 255))
            
            -- Title text
            draw.SimpleText("Manage Qualifications", "DermaLarge", 15, 12, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
        
        -- Custom close button
        local closeBtn = vgui.Create("DButton", frame)
        closeBtn:SetSize(30, 30)
        closeBtn:SetPos(frame:GetWide() - 35, 7)
        closeBtn:SetText("")
        closeBtn.Paint = function(self, w, h)
            local col = Color(180, 50, 50, 200)
            if self:IsHovered() then
                col = Color(220, 60, 60, 255)
            end
            draw.RoundedBox(4, 0, 0, w, h, col)
            draw.SimpleText("✕", "DermaLarge", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        closeBtn.DoClick = function()
            frame:Close()
        end
        
        -- Split into two sections
        local topPanel = vgui.Create("DPanel", frame)
        topPanel:Dock(TOP)
        topPanel:SetTall(180)
        topPanel:DockMargin(10, 60, 10, 5)
        topPanel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(35, 35, 40, 220))
            surface.SetDrawColor(50, 50, 60, 100)
            surface.DrawOutlinedRect(0, 0, w, h)
        end
        
        local topLabel = vgui.Create("DLabel", topPanel)
        topLabel:Dock(TOP)
        topLabel:SetText("Current Qualifications:")
        topLabel:SetFont("DermaDefaultBold")
        topLabel:SetTextColor(Color(200, 220, 255, 255))
        topLabel:DockMargin(5, 5, 5, 5)
        
        -- Custom scroll panel for current qualifications
        local currentScroll = vgui.Create("DScrollPanel", topPanel)
        currentScroll:Dock(FILL)
        currentScroll:DockMargin(5, 0, 5, 5)
        
        local currentList = vgui.Create("DPanel", currentScroll)
        currentList:Dock(TOP)
        currentList:SetTall(0)
        currentList.Paint = function(self, w, h) end
        
        -- Bottom panel for available qualifications
        local bottomPanel = vgui.Create("DPanel", frame)
        bottomPanel:Dock(FILL)
        bottomPanel:DockMargin(10, 0, 10, 10)
        bottomPanel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(35, 35, 40, 220))
            surface.SetDrawColor(50, 50, 60, 100)
            surface.DrawOutlinedRect(0, 0, w, h)
        end
        
        local bottomLabel = vgui.Create("DLabel", bottomPanel)
        bottomLabel:Dock(TOP)
        bottomLabel:SetText("Add Qualification:")
        bottomLabel:SetFont("DermaDefaultBold")
        bottomLabel:SetTextColor(Color(200, 220, 255, 255))
        bottomLabel:DockMargin(5, 5, 5, 5)
        
        -- Custom scroll panel for available qualifications
        local availableScroll = vgui.Create("DScrollPanel", bottomPanel)
        availableScroll:Dock(FILL)
        availableScroll:DockMargin(5, 0, 5, 5)
        
        local availableList = vgui.Create("DPanel", availableScroll)
        availableList:Dock(TOP)
        availableList:SetTall(0)
        availableList.Paint = function(self, w, h) end
        
        -- Populate current qualifications
        local playerQuals = self.PlayerQuals[target:SteamID()] or {}
        local currentQualNames = {}
        local currentY = 0
        
        for _, qual in ipairs(playerQuals) do
            currentQualNames[qual.qualification_name] = true
            local qualData = self.Qualifications[qual.qualification_name]
            if qualData then
                local qualPanel = vgui.Create("DButton", currentList)
                qualPanel:SetPos(0, currentY)
                qualPanel:SetSize(460, 70) -- Fixed size that fits content
                qualPanel:SetText("")
                qualPanel.qualName = qual.qualification_name
                qualPanel.displayName = qualData.display_name
                qualPanel.grantedBy = qual.granted_by or "Unknown"
                
                qualPanel.Paint = function(self, w, h)
                    local col = Color(45, 45, 50, 200)
                    if self:IsHovered() then
                        col = Color(180, 60, 60, 220)
                    end
                    draw.RoundedBox(4, 0, 0, w, h, col)
                    
                    -- Left accent bar
                    if self:IsHovered() then
                        draw.RoundedBox(0, 0, 0, 4, h, Color(220, 80, 80, 255))
                    else
                        draw.RoundedBox(0, 0, 0, 4, h, Color(50, 150, 220, 255))
                    end
                    
                    -- Qualification name
                    draw.SimpleText(self.displayName, "DermaDefaultBold", 15, 8, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    
                    -- Granted by
                    draw.SimpleText("Granted by: " .. self.grantedBy, "DermaDefault", 15, 26, Color(180, 180, 200, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    
                    -- Hint text
                    if self:IsHovered() then
                        draw.SimpleText("Double-click to remove", "DermaDefault", 15, 44, Color(255, 220, 220, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    end
                end
                
                qualPanel.DoDoubleClick = function(self)
                    Derma_Query(
                        "Remove '" .. self.displayName .. "' from " .. target:Nick() .. "?",
                        "Confirm Removal",
                        "Yes",
                        function()
                            net.Start("QualSystem_RemovePlayerQual")
                            net.WriteString(target:SteamID())
                            net.WriteString(self.qualName)
                            net.SendToServer()
                            
                            timer.Simple(0.3, function()
                                if IsValid(frame) then
                                    frame:Close()
                                    QualSystem:OpenQualificationContextMenu(target)
                                end
                            end)
                        end,
                        "No"
                    )
                end
                
                currentY = currentY + 75
            end
        end
        
        currentList:SetTall(math.max(currentY, 10))
        
        -- Populate available qualifications (ones they don't have and can manage)
        local availableY = 0
        
        for name, qualData in pairs(self.Qualifications) do
            if not currentQualNames[name] then
                -- Check if player can manage this qualification
                if self:CanManageQualification(LocalPlayer(), qualData) then
                    local qualPanel = vgui.Create("DButton", availableList)
                    qualPanel:SetPos(0, availableY)
                    qualPanel:SetSize(460, 45)
                    qualPanel:SetText("")
                    qualPanel.qualName = name
                    qualPanel.displayName = qualData.display_name
                    qualPanel.description = qualData.description or ""
                    
                    qualPanel.Paint = function(self, w, h)
                        local col = Color(45, 45, 50, 200)
                        if self:IsHovered() then
                            col = Color(50, 140, 90, 220)
                        end
                        draw.RoundedBox(4, 0, 0, w, h, col)
                        
                        -- Left accent bar
                        if self:IsHovered() then
                            draw.RoundedBox(0, 0, 0, 4, h, Color(60, 200, 120, 255))
                        else
                            draw.RoundedBox(0, 0, 0, 4, h, Color(100, 100, 120, 255))
                        end
                        
                        -- Qualification name
                        draw.SimpleText(self.displayName, "DermaDefaultBold", 15, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        
                        -- Hint text
                        if self:IsHovered() then
                            draw.SimpleText("Double-click to add", "DermaDefault", w - 10, h/2, Color(255, 255, 255, 200), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                        end
                    end
                    
                    qualPanel.DoDoubleClick = function(self)
                        Derma_Query(
                            "Add '" .. self.displayName .. "' to " .. target:Nick() .. "?",
                            "Confirm Addition",
                            "Yes",
                            function()
                                net.Start("QualSystem_AddPlayerQual")
                                net.WriteString(target:SteamID())
                                net.WriteString(self.qualName)
                                net.SendToServer()
                                
                                timer.Simple(0.3, function()
                                    if IsValid(frame) then
                                        frame:Close()
                                        QualSystem:OpenQualificationContextMenu(target)
                                    end
                                end)
                            end,
                            "No"
                        )
                    end
                    
                    availableY = availableY + 50
                end
            end
        end
        
        availableList:SetTall(math.max(availableY, 10))
        
        
        -- Instructions label
        local instructions = vgui.Create("DLabel", frame)
        instructions:Dock(BOTTOM)
        instructions:SetText("Double-click to add/remove qualifications")
        instructions:SetContentAlignment(5)
        instructions:DockMargin(10, 5, 10, 10)
        instructions:SetTextColor(Color(150, 170, 200, 255))
        instructions:SetFont("DermaDefaultBold")
    end)
end

-- Network receiver for opening context menu via command
net.Receive("QualSystem_OpenContextMenu", function()
    local target = net.ReadEntity()
    if IsValid(target) then
        QualSystem:OpenQualificationContextMenu(target)
    end
end)

print("[Qualification System] Client-side context menu loaded!")

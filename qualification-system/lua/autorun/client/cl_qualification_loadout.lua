-- Client-side loadout selection UI

QualSystem.LoadoutData = QualSystem.LoadoutData or {
    active = "none",
    default = "none",
    auto_equip = false
}

-- Receive loadout data from server
net.Receive("QualSystem_SendLoadoutData", function()
    local active = net.ReadString()
    local default = net.ReadString()
    local autoEquip = net.ReadBool()
    
    QualSystem.LoadoutData.active = active
    QualSystem.LoadoutData.default = default
    QualSystem.LoadoutData.auto_equip = autoEquip
end)

-- Open loadout selection menu
net.Receive("QualSystem_OpenLoadoutMenu", function()
    QualSystem:OpenLoadoutMenu()
end)

function QualSystem:OpenLoadoutMenu()
    -- Create main frame
    local frame = vgui.Create("DFrame")
    frame:SetSize(500, 480)
    frame:Center()
    frame:SetTitle("")
    frame:SetVisible(true)
    frame:SetDraggable(true)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    
    frame.Paint = function(self, w, h)
        -- Main background
        draw.RoundedBox(8, 0, 0, w, h, Color(25, 25, 30, 250))
        
        -- Header bar
        draw.RoundedBoxEx(8, 0, 0, w, 45, Color(35, 100, 180, 255), true, true, false, false)
        draw.RoundedBox(0, 0, 40, w, 5, Color(45, 120, 200, 255))
        
        -- Title
        draw.SimpleText("Loadout Selection", "DermaLarge", 15, 12, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
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
    
    -- Main content panel
    local contentPanel = vgui.Create("DPanel", frame)
    contentPanel:Dock(FILL)
    contentPanel:DockMargin(10, 55, 10, 10)
    contentPanel.Paint = function(self, w, h) end
    
    -- Current loadout display
    local currentPanel = vgui.Create("DPanel", contentPanel)
    currentPanel:Dock(TOP)
    currentPanel:SetTall(60)
    currentPanel:DockMargin(0, 0, 0, 10)
    currentPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(35, 35, 40, 220))
        surface.SetDrawColor(50, 50, 60, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    local currentLabel = vgui.Create("DLabel", currentPanel)
    currentLabel:Dock(TOP)
    currentLabel:SetText("Currently Equipped:")
    currentLabel:SetFont("DermaDefaultBold")
    currentLabel:SetTextColor(Color(200, 220, 255, 255))
    currentLabel:DockMargin(10, 8, 10, 5)
    
    local currentValue = vgui.Create("DLabel", currentPanel)
    currentValue:Dock(TOP)
    local activeLoadout = self.LoadoutData.active or "none"
    if activeLoadout == "none" then
        currentValue:SetText("Default Loadout (no qualification)")
    else
        local qualData = self.Qualifications[activeLoadout]
        if qualData then
            currentValue:SetText(qualData.display_name)
        else
            currentValue:SetText("Unknown")
        end
    end
    currentValue:SetTextColor(Color(100, 255, 150, 255))
    currentValue:DockMargin(10, 0, 10, 5)
    
    -- Available loadouts label
    local availableLabel = vgui.Create("DLabel", contentPanel)
    availableLabel:Dock(TOP)
    availableLabel:SetText("Available Loadouts:")
    availableLabel:SetFont("DermaDefaultBold")
    availableLabel:SetTextColor(Color(200, 220, 255, 255))
    availableLabel:DockMargin(0, 5, 0, 5)
    
    -- Loadout list scroll panel
    local loadoutScroll = vgui.Create("DScrollPanel", contentPanel)
    loadoutScroll:Dock(TOP)
    loadoutScroll:SetTall(320)
    loadoutScroll:DockMargin(0, 0, 0, 10)
    
    local loadoutList = vgui.Create("DPanel", loadoutScroll)
    loadoutList:Dock(TOP)
    loadoutList:SetTall(0)
    loadoutList.Paint = function(self, w, h) end
    
    -- Get player qualifications
    local playerQuals = self.PlayerQuals[LocalPlayer():SteamID()] or {}
    
    local y = 0
    
    -- Add "Default Loadout" option
    local defaultOption = vgui.Create("DButton", loadoutList)
    defaultOption:SetPos(0, y)
    defaultOption:SetSize(460, 60)
    defaultOption:SetText("")
    defaultOption.qualName = "none"
    defaultOption.isActive = activeLoadout == "none"
    
    defaultOption.Paint = function(self, w, h)
        local col = Color(45, 45, 50, 200)
        if self.isActive then
            col = Color(50, 120, 180, 230)
        elseif self:IsHovered() then
            col = Color(55, 55, 65, 230)
        end
        draw.RoundedBox(4, 0, 0, w, h, col)
        
        -- Left accent bar
        if self.isActive then
            draw.RoundedBox(0, 0, 0, 4, h, Color(60, 150, 220, 255))
        end
        
        -- Title
        draw.SimpleText("Default Loadout", "DermaDefaultBold", 15, 12, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        
        -- Description
        draw.SimpleText("Use your job's default weapons and stats", "DermaDefault", 15, 32, Color(180, 180, 200, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    
    defaultOption.DoClick = function(self)
        net.Start("QualSystem_EquipLoadout")
        net.WriteString("none")
        net.SendToServer()
        
        timer.Simple(0.2, function()
            if IsValid(frame) then
                frame:Close()
            end
        end)
    end
    
    y = y + 65
    
    -- Add qualification loadouts
    for _, qual in ipairs(playerQuals) do
        local qualData = self.Qualifications[qual.qualification_name]
        if qualData then
            local loadoutOption = vgui.Create("DButton", loadoutList)
            loadoutOption:SetPos(0, y)
            loadoutOption:SetSize(460, 80)
            loadoutOption:SetText("")
            loadoutOption.qualName = qual.qualification_name
            loadoutOption.isActive = activeLoadout == qual.qualification_name
            
            loadoutOption.Paint = function(self, w, h)
                local col = Color(45, 45, 50, 200)
                if self.isActive then
                    col = Color(50, 120, 180, 230)
                elseif self:IsHovered() then
                    col = Color(55, 55, 65, 230)
                end
                draw.RoundedBox(4, 0, 0, w, h, col)
                
                -- Left accent bar
                if self.isActive then
                    draw.RoundedBox(0, 0, 0, 4, h, Color(60, 150, 220, 255))
                end
                
                -- Qualification name
                draw.SimpleText(qualData.display_name, "DermaDefaultBold", 15, 8, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                
                -- Stats
                local statsText = string.format("HP: %d | Armor: %d | Weapons: %d", 
                    qualData.health or 100,
                    qualData.armor or 0,
                    #(qualData.weapons or {})
                )
                draw.SimpleText(statsText, "DermaDefault", 15, 28, Color(180, 180, 200, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                
                -- Description
                if qualData.description and qualData.description ~= "" then
                    local desc = qualData.description
                    if #desc > 50 then
                        desc = string.sub(desc, 1, 47) .. "..."
                    end
                    draw.SimpleText(desc, "DermaDefault", 15, 46, Color(150, 150, 170, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end
            end
            
            loadoutOption.DoClick = function(self)
                net.Start("QualSystem_EquipLoadout")
                net.WriteString(self.qualName)
                net.SendToServer()
                
                timer.Simple(0.2, function()
                    if IsValid(frame) then
                        frame:Close()
                    end
                end)
            end
            
            y = y + 85
        end
    end
    
    loadoutList:SetTall(math.max(y, 10))
end

print("[Qualification System] Client-side loadout UI loaded!")

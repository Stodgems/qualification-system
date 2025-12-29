-- Admin menu for managing qualifications

function QualSystem:OpenAdminMenu()
    -- Create main frame
    local frame = vgui.Create("DFrame")
    frame:SetSize(800, 600)
    frame:Center()
    frame:SetTitle("")
    frame:SetVisible(true)
    frame:SetDraggable(true)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    
    frame.Paint = function(self, w, h)
        -- Main background with gradient
        surface.SetDrawColor(25, 25, 30, 250)
        draw.RoundedBox(8, 0, 0, w, h, Color(25, 25, 30, 250))
        
        -- Header bar with gradient
        surface.SetDrawColor(35, 100, 180, 255)
        draw.RoundedBoxEx(8, 0, 0, w, 40, Color(35, 100, 180, 255), true, true, false, false)
        draw.RoundedBox(0, 0, 35, w, 5, Color(45, 120, 200, 255))
        
        -- Title text
        draw.SimpleText("Qualification System", "DermaLarge", 15, 12, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        
        -- Outer glow
        surface.SetDrawColor(0, 0, 0, 100)
        draw.RoundedBox(8, -2, -2, w + 4, h + 4, Color(0, 0, 0, 0))
    end
    
    -- Custom close button
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(frame:GetWide() - 35, 5)
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
    
    -- Left panel - Qualification list
    local leftPanel = vgui.Create("DPanel", frame)
    leftPanel:Dock(LEFT)
    leftPanel:SetWide(250)
    leftPanel:DockMargin(10, 50, 5, 10)
    leftPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(35, 35, 40, 220))
        surface.SetDrawColor(50, 50, 60, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    -- Custom scroll panel for qualifications
    local qualScroll = vgui.Create("DScrollPanel", leftPanel)
    qualScroll:Dock(FILL)
    qualScroll:DockMargin(5, 5, 5, 5)
    
    local qualList = vgui.Create("DPanel", qualScroll)
    qualList:Dock(TOP)
    qualList:SetTall(0)
    qualList.Paint = function(self, w, h) end
    
    -- Add create button
    local createBtn = vgui.Create("DButton", leftPanel)
    createBtn:Dock(BOTTOM)
    createBtn:SetText("")
    createBtn:SetHeight(35)
    createBtn:DockMargin(5, 5, 5, 5)
    createBtn.Paint = function(self, w, h)
        local col = Color(40, 120, 200, 220)
        if self:IsHovered() then
            col = Color(50, 140, 220, 255)
        end
        draw.RoundedBox(4, 0, 0, w, h, col)
        draw.SimpleText("+ Create New Qualification", "DermaDefaultBold", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    createBtn.DoClick = function()
        self:OpenQualificationEditor(frame)
    end
    
    -- Right panel - Qualification details
    local rightPanel = vgui.Create("DPanel", frame)
    rightPanel:Dock(FILL)
    rightPanel:DockMargin(5, 50, 10, 10)
    rightPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(35, 35, 40, 220))
        surface.SetDrawColor(50, 50, 60, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    -- Scroll panel for details
    local scroll = vgui.Create("DScrollPanel", rightPanel)
    scroll:Dock(FILL)
    
    local detailsPanel = vgui.Create("DPanel", scroll)
    detailsPanel:Dock(TOP)
    detailsPanel:SetTall(550)
    detailsPanel.Paint = function(self, w, h)
        -- Transparent background
    end
    
    -- Function to display qualification details
    local function DisplayQualificationDetails(qualName)
        detailsPanel:Clear()
        
        local qualData = self.Qualifications[qualName]
        if not qualData then return end
        
        local y = 10
        
        -- Title
        local title = vgui.Create("DLabel", detailsPanel)
        title:SetPos(10, y)
        title:SetText(qualData.display_name)
        title:SetFont("DermaLarge")
        title:SizeToContents()
        y = y + 30
        
        -- Description
        if qualData.description ~= "" then
            local desc = vgui.Create("DLabel", detailsPanel)
            desc:SetPos(10, y)
            desc:SetText("Description: " .. qualData.description)
            desc:SizeToContents()
            y = y + 25
        end
        
        -- Model
        local modelLabel = vgui.Create("DLabel", detailsPanel)
        modelLabel:SetPos(10, y)
        modelLabel:SetText("Model: " .. (qualData.model ~= "" and qualData.model or "None"))
        modelLabel:SizeToContents()
        y = y + 25
        
        -- Skin
        if qualData.skin and qualData.skin > 0 then
            local skinLabel = vgui.Create("DLabel", detailsPanel)
            skinLabel:SetPos(10, y)
            skinLabel:SetText("Skin: " .. qualData.skin)
            skinLabel:SizeToContents()
            y = y + 25
        end
        
        -- Bodygroups
        if qualData.bodygroups and table.Count(qualData.bodygroups) > 0 then
            local bodygroupsLabel = vgui.Create("DLabel", detailsPanel)
            bodygroupsLabel:SetPos(10, y)
            local bgText = "Bodygroups: "
            for bgName, bgValue in pairs(qualData.bodygroups) do
                bgText = bgText .. bgName .. "=" .. bgValue .. " "
            end
            bodygroupsLabel:SetText(bgText)
            bodygroupsLabel:SizeToContents()
            y = y + 25
        end
        
        -- Health
        local healthLabel = vgui.Create("DLabel", detailsPanel)
        healthLabel:SetPos(10, y)
        healthLabel:SetText("Health: " .. qualData.health)
        healthLabel:SizeToContents()
        y = y + 25
        
        -- Armor
        local armorLabel = vgui.Create("DLabel", detailsPanel)
        armorLabel:SetPos(10, y)
        armorLabel:SetText("Armor: " .. qualData.armor)
        armorLabel:SizeToContents()
        y = y + 25
        
        -- Weapons
        local weaponsLabel = vgui.Create("DLabel", detailsPanel)
        weaponsLabel:SetPos(10, y)
        weaponsLabel:SetText("Weapons: " .. (#qualData.weapons > 0 and table.concat(qualData.weapons, ", ") or "None"))
        weaponsLabel:SizeToContents()
        y = y + 25
        
        -- Staff only
        local staffLabel = vgui.Create("DLabel", detailsPanel)
        staffLabel:SetPos(10, y)
        staffLabel:SetText("Staff Only: " .. (qualData.staff_only and "Yes" or "No"))
        staffLabel:SizeToContents()
        y = y + 25
        
        -- Allow teachers
        local teacherLabel = vgui.Create("DLabel", detailsPanel)
        teacherLabel:SetPos(10, y)
        teacherLabel:SetText("Allow Teachers: " .. (qualData.allow_teachers and "Yes" or "No"))
        teacherLabel:SizeToContents()
        y = y + 25
        
        if qualData.allow_teachers and qualData.teacher_qual ~= "" then
            local teacherQualLabel = vgui.Create("DLabel", detailsPanel)
            teacherQualLabel:SetPos(10, y)
            teacherQualLabel:SetText("Teacher Qualification: " .. qualData.teacher_qual)
            teacherQualLabel:SizeToContents()
            y = y + 25
        end
        
        -- Allowed Jobs
        local jobsLabel = vgui.Create("DLabel", detailsPanel)
        jobsLabel:SetPos(10, y)
        if qualData.allowed_jobs and #qualData.allowed_jobs > 0 then
            jobsLabel:SetText("Allowed Jobs: " .. table.concat(qualData.allowed_jobs, ", "))
        else
            jobsLabel:SetText("Allowed Jobs: All Jobs")
        end
        jobsLabel:SizeToContents()
        y = y + 25
        
        -- Custom function
        if qualData.custom_function ~= "" then
            local funcLabel = vgui.Create("DLabel", detailsPanel)
            funcLabel:SetPos(10, y)
            funcLabel:SetText("Custom Function:")
            funcLabel:SizeToContents()
            y = y + 25
            
            local funcBox = vgui.Create("DTextEntry", detailsPanel)
            funcBox:SetPos(10, y)
            funcBox:SetSize(500, 100)
            funcBox:SetMultiline(true)
            funcBox:SetEditable(false)
            funcBox:SetValue(qualData.custom_function)
            y = y + 110
        end
        
        -- Edit button
        local editBtn = vgui.Create("DButton", detailsPanel)
        editBtn:SetPos(10, y)
        editBtn:SetSize(100, 35)
        editBtn:SetText("")
        editBtn.Paint = function(self, w, h)
            local col = Color(40, 120, 200, 220)
            if self:IsHovered() then
                col = Color(50, 140, 220, 255)
            end
            draw.RoundedBox(4, 0, 0, w, h, col)
            draw.SimpleText("Edit", "DermaDefaultBold", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        editBtn.DoClick = function()
            self:OpenQualificationEditor(frame, qualName)
        end
        
        -- Manage Players button
        local playersBtn = vgui.Create("DButton", detailsPanel)
        playersBtn:SetPos(120, y)
        playersBtn:SetSize(140, 35)
        playersBtn:SetText("")
        playersBtn.Paint = function(self, w, h)
            local col = Color(60, 160, 80, 220)
            if self:IsHovered() then
                col = Color(70, 180, 90, 255)
            end
            draw.RoundedBox(4, 0, 0, w, h, col)
            draw.SimpleText("Manage Players", "DermaDefaultBold", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        playersBtn.DoClick = function()
            self:OpenPlayerManagement(qualName)
        end
        
        -- Delete button
        local deleteBtn = vgui.Create("DButton", detailsPanel)
        deleteBtn:SetPos(270, y)
        deleteBtn:SetSize(100, 35)
        deleteBtn:SetText("")
        deleteBtn.Paint = function(self, w, h)
            local col = Color(180, 50, 50, 200)
            if self:IsHovered() then
                col = Color(220, 60, 60, 255)
            end
            draw.RoundedBox(4, 0, 0, w, h, col)
            draw.SimpleText("Delete", "DermaDefaultBold", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        deleteBtn.DoClick = function()
            Derma_Query(
                "Are you sure you want to delete this qualification?",
                "Confirm Delete",
                "Yes",
                function()
                    net.Start("QualSystem_DeleteQualification")
                    net.WriteString(qualName)
                    net.SendToServer()
                    timer.Simple(0.5, function()
                        if IsValid(frame) then
                            frame:Close()
                            self:OpenAdminMenu()
                        end
                    end)
                end,
                "No"
            )
        end
    end
    
    -- Populate qualification list
    local qualY = 0
    for name, data in pairs(self.Qualifications) do
        -- Calculate text dimensions for dynamic height
        surface.SetFont("DermaDefaultBold")
        local textW, textH = surface.GetTextSize(data.display_name)
        
        -- Calculate card height based on text (min 40px)
        local cardHeight = math.max(40, textH + 20)
        
        local qualPanel = vgui.Create("DButton", qualList)
        qualPanel:SetPos(0, qualY)
        qualPanel:SetSize(230, cardHeight)
        qualPanel:SetText("")
        qualPanel.qualName = name
        qualPanel.displayName = data.display_name
        qualPanel.isSelected = false
        
        qualPanel.Paint = function(self, w, h)
            local col = Color(45, 45, 50, 200)
            if self.isSelected then
                col = Color(50, 120, 180, 230)
            elseif self:IsHovered() then
                col = Color(55, 55, 65, 230)
            end
            draw.RoundedBox(4, 0, 0, w, h, col)
            
            -- Left accent bar
            if self.isSelected then
                draw.RoundedBox(0, 0, 0, 4, h, Color(60, 150, 220, 255))
            end
            
            -- Qualification name (with text wrapping support)
            draw.DrawText(self.displayName, "DermaDefaultBold", 15, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
        end
        
        qualPanel.DoClick = function(self)
            -- Deselect all other panels
            for _, child in ipairs(qualList:GetChildren()) do
                if child.isSelected ~= nil then
                    child.isSelected = false
                end
            end
            
            -- Select this panel
            self.isSelected = true
            DisplayQualificationDetails(self.qualName)
        end
        
        qualY = qualY + cardHeight + 5
    end
    
    qualList:SetTall(math.max(qualY, 10))
end

function QualSystem:OpenQualificationEditor(parent, editQualName)
    local isEdit = editQualName ~= nil
    local qualData = isEdit and self.Qualifications[editQualName] or {}
    
    -- Create editor frame
    local frame = vgui.Create("DFrame")
    frame:SetSize(900, 700)
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
        draw.RoundedBoxEx(8, 0, 0, w, 40, Color(35, 100, 180, 255), true, true, false, false)
        draw.RoundedBox(0, 0, 35, w, 5, Color(45, 120, 200, 255))
        
        -- Title
        local title = isEdit and "Edit Qualification" or "Create New Qualification"
        draw.SimpleText(title, "DermaLarge", 15, 10, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    
    -- Custom close button
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(frame:GetWide() - 35, 5)
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
    
    -- Create left and right panels
    local leftPanel = vgui.Create("DPanel", frame)
    leftPanel:Dock(LEFT)
    leftPanel:SetWide(550)
    leftPanel:DockMargin(10, 50, 5, 10)
    leftPanel.Paint = function(self, w, h) end
    
    local scroll = vgui.Create("DScrollPanel", leftPanel)
    scroll:Dock(FILL)
    
    -- Create right panel for model preview
    local rightPanel = vgui.Create("DPanel", frame)
    rightPanel:Dock(FILL)
    rightPanel:DockMargin(5, 50, 10, 10)
    rightPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(35, 35, 40, 220))
        surface.SetDrawColor(50, 50, 60, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    -- Model preview header panel
    local previewHeader = vgui.Create("DPanel", rightPanel)
    previewHeader:Dock(TOP)
    previewHeader:SetTall(30)
    previewHeader:DockMargin(5, 5, 5, 0)
    previewHeader.Paint = function(self, w, h) end
    
    -- Model preview label
    local previewLabel = vgui.Create("DLabel", previewHeader)
    previewLabel:Dock(LEFT)
    previewLabel:SetText("Model Preview (drag to rotate)")
    previewLabel:SetFont("DermaDefaultBold")
    previewLabel:SetTextColor(Color(200, 220, 255, 255))
    previewLabel:SetContentAlignment(4)
    previewLabel:DockMargin(0, 0, 5, 0)
    previewLabel:SizeToContents()
    
    -- Reset rotation button
    local resetBtn = vgui.Create("DButton", previewHeader)
    resetBtn:Dock(RIGHT)
    resetBtn:SetWide(80)
    resetBtn:SetText("")
    resetBtn.Paint = function(self, w, h)
        local col = Color(50, 100, 150, 200)
        if self:IsHovered() then
            col = Color(60, 120, 170, 255)
        end
        draw.RoundedBox(4, 0, 0, w, h, col)
        draw.SimpleText("Reset View", "DermaDefault", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Model viewer
    local modelViewer = vgui.Create("DModelPanel", rightPanel)
    modelViewer:Dock(FILL)
    modelViewer:DockMargin(5, 0, 5, 5)
    
    -- Enable mouse rotation
    local rotationYaw = 180  -- Start at 180 so model faces forward
    local rotationPitch = 0
    local isDragging = false
    local lastMouseX = 0
    local lastMouseY = 0
    
    function modelViewer:DragMousePress()
        isDragging = true
        lastMouseX, lastMouseY = input.GetCursorPos()
        self:MouseCapture(true)
    end
    
    function modelViewer:DragMouseRelease()
        isDragging = false
        self:MouseCapture(false)
    end
    
    modelViewer.OnMousePressed = function(self, keyCode)
        if keyCode == MOUSE_LEFT then
            self:DragMousePress()
        end
    end
    
    modelViewer.OnMouseReleased = function(self, keyCode)
        if keyCode == MOUSE_LEFT then
            self:DragMouseRelease()
        end
    end
    
    modelViewer.Think = function(self)
        if isDragging then
            local mx, my = input.GetCursorPos()
            local deltaX = mx - lastMouseX
            local deltaY = my - lastMouseY
            
            rotationYaw = rotationYaw + deltaX * 0.5
            rotationPitch = math.Clamp(rotationPitch + deltaY * 0.5, -89, 89)
            
            lastMouseX = mx
            lastMouseY = my
        end
    end
    
    modelViewer.LayoutEntity = function(self, ent)
        if IsValid(ent) then
            ent:SetAngles(Angle(rotationPitch, rotationYaw, 0))
        end
    end
    
    -- Change cursor to hand when hovering
    modelViewer.OnCursorEntered = function(self)
        self:SetCursor("hand")
    end
    
    modelViewer.OnCursorExited = function(self)
        self:SetCursor("arrow")
    end
    
    -- Reset rotation function
    local function ResetRotation()
        rotationYaw = 180  -- Reset to face forward
        rotationPitch = 0
        isDragging = false
    end
    
    -- Reset button click
    resetBtn.DoClick = function()
        ResetRotation()
    end
    
    -- Store preview model entity
    local previewEntity = nil
    
    -- Function to update model preview
    local function UpdateModelPreview(modelPath, skinValue, bodygroupValues, resetRot)
        if not modelPath or modelPath == "" then
            modelViewer:SetModel("models/error.mdl")
            if resetRot then ResetRotation() end
            return
        end
        
        if resetRot then ResetRotation() end
        
        modelViewer:SetModel(modelPath)
        previewEntity = modelViewer:GetEntity()
        
        if IsValid(previewEntity) then
            -- Apply skin
            if skinValue then
                previewEntity:SetSkin(skinValue)
            end
            
            -- Apply bodygroups
            if bodygroupValues then
                for bgName, bgValue in pairs(bodygroupValues) do
                    local bgIndex = previewEntity:FindBodygroupByName(bgName)
                    if bgIndex ~= -1 then
                        previewEntity:SetBodygroup(bgIndex, bgValue)
                    end
                end
            end
            
            -- Center the model nicely
            local mn, mx = previewEntity:GetRenderBounds()
            local size = 0
            size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
            size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
            size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
            
            modelViewer:SetFOV(45)
            modelViewer:SetCamPos(Vector(size, size, size * 0.5))
            modelViewer:SetLookAt((mn + mx) * 0.5)
        end
    end
    
    -- Initialize with default error model
    if isEdit and qualData.model and qualData.model ~= "" then
        UpdateModelPreview(qualData.model, qualData.skin or 0, qualData.bodygroups or {}, true)
    else
        modelViewer:SetModel("models/error.mdl")
    end
    
    local y = 0
    
    -- Internal name (only for creation)
    local nameEntry
    if not isEdit then
        local nameLabel = vgui.Create("DLabel", scroll)
        nameLabel:SetPos(0, y)
        nameLabel:SetText("Internal Name (unique, no spaces):")
        nameLabel:SizeToContents()
        y = y + 20
        
        nameEntry = vgui.Create("DTextEntry", scroll)
        nameEntry:SetPos(0, y)
        nameEntry:SetSize(530, 25)
        nameEntry:SetPlaceholderText("e.g., medic_basic")
        y = y + 35
    end
    
    -- Display name
    local displayLabel = vgui.Create("DLabel", scroll)
    displayLabel:SetPos(0, y)
    displayLabel:SetText("Display Name:")
    displayLabel:SizeToContents()
    y = y + 20
    
    local displayEntry = vgui.Create("DTextEntry", scroll)
    displayEntry:SetPos(0, y)
    displayEntry:SetSize(530, 25)
    displayEntry:SetValue(qualData.display_name or "")
    y = y + 35
    
    -- Description
    local descLabel = vgui.Create("DLabel", scroll)
    descLabel:SetPos(0, y)
    descLabel:SetText("Description:")
    descLabel:SizeToContents()
    y = y + 20
    
    local descEntry = vgui.Create("DTextEntry", scroll)
    descEntry:SetPos(0, y)
    descEntry:SetSize(530, 25)
    descEntry:SetValue(qualData.description or "")
    y = y + 35
    
    -- Model
    local modelLabel = vgui.Create("DLabel", scroll)
    modelLabel:SetPos(0, y)
    modelLabel:SetText("Custom Model (optional):")
    modelLabel:SizeToContents()
    y = y + 20
    
    local modelEntry = vgui.Create("DTextEntry", scroll)
    modelEntry:SetPos(0, y)
    modelEntry:SetSize(530, 25)
    modelEntry:SetValue(qualData.model or "")
    modelEntry:SetPlaceholderText("e.g., models/player/group01/male_01.mdl")
    y = y + 35
    
    -- Skin section
    local skinLabel = vgui.Create("DLabel", scroll)
    skinLabel:SetPos(0, y)
    skinLabel:SetText("Model Skin:")
    skinLabel:SizeToContents()
    y = y + 20
    
    local skinSlider = vgui.Create("DNumSlider", scroll)
    skinSlider:SetPos(0, y)
    skinSlider:SetSize(530, 25)
    skinSlider:SetMin(0)
    skinSlider:SetMax(20)
    skinSlider:SetDecimals(0)
    skinSlider:SetValue(qualData.skin or 0)
    skinSlider.OnValueChanged = function(self, value)
        UpdateModelPreview(modelEntry:GetValue(), math.floor(value), bodygroups, false)
    end
    y = y + 35
    
    -- Add a refresh button before bodygroups
    local refreshBtn = vgui.Create("DButton", scroll)
    refreshBtn:SetPos(0, y)
    refreshBtn:SetSize(530, 30)
    refreshBtn:SetText("")
    refreshBtn.Paint = function(self, w, h)
        local col = Color(50, 100, 150, 220)
        if self:IsHovered() then
            col = Color(60, 120, 170, 255)
        end
        draw.RoundedBox(4, 0, 0, w, h, col)
        draw.SimpleText("🔄 Refresh Skin & Bodygroups", "DermaDefaultBold", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    y = y + 35
    
    -- Bodygroups section
    local bodygroupsLabel = vgui.Create("DLabel", scroll)
    bodygroupsLabel:SetPos(0, y)
    bodygroupsLabel:SetText("Bodygroups:")
    bodygroupsLabel:SizeToContents()
    y = y + 20
    
    -- Container for bodygroups
    local bodygroupContainer = vgui.Create("DPanel", scroll)
    bodygroupContainer:SetPos(0, y)
    bodygroupContainer:SetSize(530, 150)
    bodygroupContainer.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 40, 220))
        surface.SetDrawColor(50, 50, 60, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    local bodygroupScroll = vgui.Create("DScrollPanel", bodygroupContainer)
    bodygroupScroll:Dock(FILL)
    bodygroupScroll:DockMargin(5, 5, 5, 5)
    
    local bodygroupList = vgui.Create("DPanel", bodygroupScroll)
    bodygroupList:Dock(TOP)
    bodygroupList:SetTall(0)
    bodygroupList.Paint = function(self, w, h) end
    
    -- Store bodygroup selections
    local bodygroups = qualData.bodygroups or {}
    local bodygroupSelectors = {}
    
    -- Function to update skin slider max based on model
    local function UpdateSkinRange(modelPath)
        if not modelPath or modelPath == "" then
            skinSlider:SetMax(20)
            return
        end
        
        local modelEntity = ClientsideModel(modelPath, RENDERGROUP_OTHER)
        if IsValid(modelEntity) then
            local numSkins = modelEntity:SkinCount()
            skinSlider:SetMax(math.max(numSkins - 1, 0))
            modelEntity:Remove()
        else
            skinSlider:SetMax(20)
        end
    end
    
    -- Function to refresh bodygroup list
    local function RefreshBodygroups(modelPath)
        bodygroupList:Clear()
        bodygroupSelectors = {}
        
        if not modelPath or modelPath == "" then
            local noModel = vgui.Create("DLabel", bodygroupList)
            noModel:Dock(TOP)
            noModel:SetText("No model selected")
            noModel:SetTextColor(Color(150, 150, 150, 255))
            noModel:DockMargin(5, 5, 5, 5)
            bodygroupList:SetTall(25)
            return
        end
        
        -- Try to get bodygroups from the model
        local modelEntity = ClientsideModel(modelPath, RENDERGROUP_OTHER)
        if not IsValid(modelEntity) then
            local invalidModel = vgui.Create("DLabel", bodygroupList)
            invalidModel:Dock(TOP)
            invalidModel:SetText("Invalid model or model not found")
            invalidModel:SetTextColor(Color(200, 100, 100, 255))
            invalidModel:DockMargin(5, 5, 5, 5)
            bodygroupList:SetTall(25)
            return
        end
        
        local bgCount = modelEntity:GetNumBodyGroups()
        
        if bgCount <= 1 then
            local noBodygroups = vgui.Create("DLabel", bodygroupList)
            noBodygroups:Dock(TOP)
            noBodygroups:SetText("This model has no bodygroups")
            noBodygroups:SetTextColor(Color(150, 150, 150, 255))
            noBodygroups:DockMargin(5, 5, 5, 5)
            bodygroupList:SetTall(25)
            modelEntity:Remove()
            return
        end
        
        local bgY = 0
        for i = 0, bgCount - 1 do
            local bgName = modelEntity:GetBodygroupName(i)
            local bgSubCount = modelEntity:GetBodygroupCount(i)
            
            if bgSubCount > 1 then
                local bgLabel = vgui.Create("DLabel", bodygroupList)
                bgLabel:Dock(TOP)
                bgLabel:SetText(bgName .. ":")
                bgLabel:SetFont("DermaDefaultBold")
                bgLabel:SetTextColor(Color(200, 220, 255, 255))
                bgLabel:DockMargin(5, 5, 5, 2)
                bgY = bgY + 20
                
                local bgCombo = vgui.Create("DComboBox", bodygroupList)
                bgCombo:Dock(TOP)
                bgCombo:DockMargin(10, 0, 5, 5)
                bgCombo:SetTall(25)
                
                for j = 0, bgSubCount - 1 do
                    bgCombo:AddChoice("Option " .. j, j)
                end
                
                -- Set current value if it exists
                if bodygroups[bgName] then
                    bgCombo:ChooseOptionID(bodygroups[bgName] + 1)
                else
                    bgCombo:ChooseOptionID(1)
                end
                
                bgCombo.OnSelect = function(self, index, value, data)
                    bodygroups[bgName] = data
                    UpdateModelPreview(modelEntry:GetValue(), math.floor(skinSlider:GetValue()), bodygroups, false)
                end
                
                bodygroupSelectors[bgName] = bgCombo
                bgY = bgY + 30
            end
        end
        
        bodygroupList:SetTall(math.max(bgY, 25))
        modelEntity:Remove()
    end
    
    -- Connect refresh button (already created above)
    refreshBtn.DoClick = function()
        local modelPath = modelEntry:GetValue()
        UpdateSkinRange(modelPath)
        RefreshBodygroups(modelPath)
        UpdateModelPreview(modelPath, math.floor(skinSlider:GetValue()), bodygroups, true)
    end
    
    -- Refresh bodygroups and skin when model changes
    modelEntry.OnEnter = function(self)
        local modelPath = self:GetValue()
        UpdateSkinRange(modelPath)
        RefreshBodygroups(modelPath)
        UpdateModelPreview(modelPath, math.floor(skinSlider:GetValue()), bodygroups, true)
    end
    
    y = y + 160
    
    -- Initial load of bodygroups and skin if editing
    if isEdit and qualData.model and qualData.model ~= "" then
        timer.Simple(0.1, function()
            UpdateSkinRange(qualData.model)
            RefreshBodygroups(qualData.model)
        end)
    end
    
    -- Health
    local healthLabel = vgui.Create("DLabel", scroll)
    healthLabel:SetPos(0, y)
    healthLabel:SetText("Health:")
    healthLabel:SizeToContents()
    y = y + 20
    
    local healthSlider = vgui.Create("DNumSlider", scroll)
    healthSlider:SetPos(0, y)
    healthSlider:SetSize(530, 25)
    healthSlider:SetMin(1)
    healthSlider:SetMax(500)
    healthSlider:SetDecimals(0)
    healthSlider:SetValue(qualData.health or 100)
    y = y + 35
    
    -- Armor
    local armorLabel = vgui.Create("DLabel", scroll)
    armorLabel:SetPos(0, y)
    armorLabel:SetText("Armor:")
    armorLabel:SizeToContents()
    y = y + 20
    
    local armorSlider = vgui.Create("DNumSlider", scroll)
    armorSlider:SetPos(0, y)
    armorSlider:SetSize(530, 25)
    armorSlider:SetMin(0)
    armorSlider:SetMax(255)
    armorSlider:SetDecimals(0)
    armorSlider:SetValue(qualData.armor or 0)
    y = y + 35
    
    -- Weapons
    local weaponsLabel = vgui.Create("DLabel", scroll)
    weaponsLabel:SetPos(0, y)
    weaponsLabel:SetText("Weapons (comma-separated):")
    weaponsLabel:SizeToContents()
    y = y + 20
    
    local weaponsEntry = vgui.Create("DTextEntry", scroll)
    weaponsEntry:SetPos(0, y)
    weaponsEntry:SetSize(530, 25)
    weaponsEntry:SetValue(qualData.weapons and table.concat(qualData.weapons, ", ") or "")
    weaponsEntry:SetPlaceholderText("e.g., weapon_pistol, weapon_smg1")
    y = y + 35
    
    -- Staff only checkbox
    local staffCheck = vgui.Create("DCheckBoxLabel", scroll)
    staffCheck:SetPos(0, y)
    staffCheck:SetText("Staff Only (only staff can assign)")
    staffCheck:SetValue(qualData.staff_only == nil and true or qualData.staff_only)
    staffCheck:SizeToContents()
    y = y + 25
    
    -- Allow teachers checkbox
    local teacherCheck = vgui.Create("DCheckBoxLabel", scroll)
    teacherCheck:SetPos(0, y)
    teacherCheck:SetText("Allow Teachers (users with a specific qualification can assign)")
    teacherCheck:SetValue(qualData.allow_teachers or false)
    teacherCheck:SizeToContents()
    y = y + 25
    
    -- Teacher qualification
    local teacherQualLabel = vgui.Create("DLabel", scroll)
    teacherQualLabel:SetPos(0, y)
    teacherQualLabel:SetText("Teacher Qualification Name:")
    teacherQualLabel:SizeToContents()
    y = y + 20
    
    local teacherQualEntry = vgui.Create("DTextEntry", scroll)
    teacherQualEntry:SetPos(0, y)
    teacherQualEntry:SetSize(530, 25)
    teacherQualEntry:SetValue(qualData.teacher_qual or "")
    teacherQualEntry:SetPlaceholderText("e.g., medic_instructor")
    y = y + 35
    
    -- Allowed Jobs
    local jobsLabel = vgui.Create("DLabel", scroll)
    jobsLabel:SetPos(0, y)
    jobsLabel:SetText("Allowed Jobs/Categories (leave empty for all jobs):")
    jobsLabel:SizeToContents()
    y = y + 20
    
    -- Create scrollable panel for job list
    local jobPanel = vgui.Create("DPanel", scroll)
    jobPanel:SetPos(0, y)
    jobPanel:SetSize(530, 150)
    jobPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 40, 220))
        surface.SetDrawColor(50, 50, 60, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    local jobScroll = vgui.Create("DScrollPanel", jobPanel)
    jobScroll:Dock(FILL)
    jobScroll:DockMargin(5, 5, 5, 5)
    
    -- Store selected jobs
    local selectedJobs = {}
    if qualData.allowed_jobs then
        for _, job in ipairs(qualData.allowed_jobs) do
            selectedJobs[job] = true
        end
    end
    
    -- Get all teams/jobs
    local teams = {}
    for i = 0, 255 do
        if team.Valid(i) then
            local teamName = team.GetName(i)
            if teamName and teamName ~= "" then
                table.insert(teams, {
                    id = i,
                    name = teamName,
                    color = team.GetColor(i)
                })
            end
        end
    end
    
    -- Add "All Jobs" option
    local allJobsCheck = vgui.Create("DCheckBoxLabel", jobScroll)
    allJobsCheck:Dock(TOP)
    allJobsCheck:SetText("All Jobs (no restrictions)")
    allJobsCheck:SetValue(not qualData.allowed_jobs or #qualData.allowed_jobs == 0)
    allJobsCheck:DockMargin(2, 2, 2, 2)
    allJobsCheck:SetTextColor(Color(100, 200, 255, 255))
    allJobsCheck.OnChange = function(self, val)
        if val then
            -- Uncheck all job checkboxes
            selectedJobs = {}
            for _, child in ipairs(jobScroll:GetChildren()) do
                if child.jobCheck then
                    child:SetValue(false)
                end
            end
        end
    end
    
    -- Add separator
    local separator = vgui.Create("DPanel", jobScroll)
    separator:Dock(TOP)
    separator:SetTall(2)
    separator:DockMargin(0, 5, 0, 5)
    separator.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 70, 255))
    end
    
    -- Create checkbox for each job
    for _, teamData in ipairs(teams) do
        local jobCheck = vgui.Create("DCheckBoxLabel", jobScroll)
        jobCheck:Dock(TOP)
        jobCheck:SetText(teamData.name)
        jobCheck:SetValue(selectedJobs[teamData.name] or false)
        jobCheck:DockMargin(2, 2, 2, 2)
        jobCheck:SetTextColor(teamData.color)
        jobCheck.jobCheck = true
        jobCheck.jobName = teamData.name
        
        jobCheck.OnChange = function(self, val)
            if val then
                selectedJobs[teamData.name] = true
                allJobsCheck:SetValue(false)
            else
                selectedJobs[teamData.name] = nil
            end
        end
    end
    
    y = y + 160
    
    -- Custom function
    local funcLabel = vgui.Create("DLabel", scroll)
    funcLabel:SetPos(0, y)
    funcLabel:SetText("Custom Function (Lua code, parameters: ply, qualData):")
    funcLabel:SizeToContents()
    y = y + 20
    
    local funcEntry = vgui.Create("DTextEntry", scroll)
    funcEntry:SetPos(0, y)
    funcEntry:SetSize(530, 100)
    funcEntry:SetMultiline(true)
    funcEntry:SetValue(qualData.custom_function or "")
    funcEntry:SetPlaceholderText("-- Optional Lua code\n-- Example:\n-- ply:SetRunSpeed(400)")
    y = y + 110
    
    -- Save button
    local saveBtn = vgui.Create("DButton", scroll)
    saveBtn:SetPos(0, y)
    saveBtn:SetSize(530, 40)
    saveBtn:SetText("")
    saveBtn.Paint = function(self, w, h)
        local col = Color(50, 180, 100, 220)
        if self:IsHovered() then
            col = Color(60, 200, 120, 255)
        end
        draw.RoundedBox(6, 0, 0, w, h, col)
        local text = isEdit and "Update Qualification" or "Create Qualification"
        draw.SimpleText(text, "DermaLarge", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    saveBtn.DoClick = function()
        local data = {
            name = isEdit and editQualName or nameEntry:GetValue(),
            display_name = displayEntry:GetValue(),
            description = descEntry:GetValue(),
            model = modelEntry:GetValue(),
            health = math.floor(healthSlider:GetValue()),
            armor = math.floor(armorSlider:GetValue()),
            weapons = {},
            staff_only = staffCheck:GetChecked(),
            allow_teachers = teacherCheck:GetChecked(),
            teacher_qual = teacherQualEntry:GetValue(),
            custom_function = funcEntry:GetValue(),
            allowed_jobs = {},
            bodygroups = bodygroups,
            skin = math.floor(skinSlider:GetValue())
        }
        
        -- Parse weapons
        if weaponsEntry:GetValue() ~= "" then
            for weapon in string.gmatch(weaponsEntry:GetValue(), "[^,]+") do
                table.insert(data.weapons, string.Trim(weapon))
            end
        end
        
        -- Parse allowed jobs from checkboxes
        for jobName, _ in pairs(selectedJobs) do
            table.insert(data.allowed_jobs, jobName)
        end
        
        -- Validation
        if data.name == "" or data.display_name == "" then
            Derma_Message("Please fill in all required fields!", "Error", "OK")
            return
        end
        
        -- Send to server
        if isEdit then
            net.Start("QualSystem_UpdateQualification")
        else
            net.Start("QualSystem_CreateQualification")
        end
        net.WriteTable(data)
        net.SendToServer()
        
        frame:Close()
        timer.Simple(0.5, function()
            if IsValid(parent) then
                parent:Close()
                QualSystem:OpenAdminMenu()
            end
        end)
    end
end

function QualSystem:OpenPlayerManagement(qualName)
    local qualData = self.Qualifications[qualName]
    if not qualData then return end
    
    -- Create frame
    local frame = vgui.Create("DFrame")
    frame:SetSize(700, 600)
    frame:Center()
    frame:SetTitle("")
    frame:SetVisible(true)
    frame:SetDraggable(true)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(25, 25, 30, 250))
        draw.RoundedBoxEx(8, 0, 0, w, 40, Color(35, 100, 180, 255), true, true, false, false)
        draw.RoundedBox(0, 0, 35, w, 5, Color(45, 120, 200, 255))
        draw.SimpleText("Players: " .. qualData.display_name, "DermaLarge", 15, 10, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    
    -- Close button
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(frame:GetWide() - 35, 5)
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
    
    -- Content panel
    local contentPanel = vgui.Create("DPanel", frame)
    contentPanel:Dock(FILL)
    contentPanel:DockMargin(10, 50, 10, 10)
    contentPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(35, 35, 40, 220))
    end
    
    -- Add player section
    local addPanel = vgui.Create("DPanel", contentPanel)
    addPanel:Dock(TOP)
    addPanel:SetTall(100)
    addPanel:DockMargin(5, 5, 5, 5)
    addPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(45, 45, 50, 200))
        draw.SimpleText("Add Player:", "DermaDefaultBold", 10, 10, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    
    -- Player selector dropdown
    local playerDropdown = vgui.Create("DComboBox", addPanel)
    playerDropdown:SetPos(10, 30)
    playerDropdown:SetSize(440, 25)
    playerDropdown:SetValue("Select online player...")
    
    -- Populate with online players
    for _, ply in ipairs(player.GetAll()) do
        playerDropdown:AddChoice(ply:Nick(), ply:SteamID())
    end
    
    -- Add by dropdown button
    local addByDropdownBtn = vgui.Create("DButton", addPanel)
    addByDropdownBtn:SetPos(460, 30)
    addByDropdownBtn:SetSize(210, 25)
    addByDropdownBtn:SetText("")
    addByDropdownBtn.Paint = function(self, w, h)
        local col = Color(60, 160, 80, 220)
        if self:IsHovered() then
            col = Color(70, 180, 90, 255)
        end
        draw.RoundedBox(4, 0, 0, w, h, col)
        draw.SimpleText("Add Selected Player", "DermaDefaultBold", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    addByDropdownBtn.DoClick = function()
        local _, steamid = playerDropdown:GetSelected()
        if not steamid then
            Derma_Message("Please select a player!", "Error", "OK")
            return
        end
        
        net.Start("QualSystem_AddPlayerToQual")
        net.WriteString(steamid)
        net.WriteString(qualName)
        net.SendToServer()
        
        timer.Simple(0.3, function()
            if IsValid(frame) then
                frame:Close()
                QualSystem:OpenPlayerManagement(qualName)
            end
        end)
    end
    
    -- SteamID entry
    local steamidLabel = vgui.Create("DLabel", addPanel)
    steamidLabel:SetPos(10, 60)
    steamidLabel:SetText("Or add by SteamID:")
    steamidLabel:SetTextColor(Color(200, 200, 200, 255))
    steamidLabel:SizeToContents()
    
    local steamidEntry = vgui.Create("DTextEntry", addPanel)
    steamidEntry:SetPos(10, 75)
    steamidEntry:SetSize(440, 20)
    steamidEntry:SetPlaceholderText("STEAM_0:X:XXXXXXXX")
    
    -- Add by SteamID button
    local addBySteamidBtn = vgui.Create("DButton", addPanel)
    addBySteamidBtn:SetPos(460, 70)
    addBySteamidBtn:SetSize(210, 25)
    addBySteamidBtn:SetText("")
    addBySteamidBtn.Paint = function(self, w, h)
        local col = Color(60, 160, 80, 220)
        if self:IsHovered() then
            col = Color(70, 180, 90, 255)
        end
        draw.RoundedBox(4, 0, 0, w, h, col)
        draw.SimpleText("Add by SteamID", "DermaDefaultBold", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    addBySteamidBtn.DoClick = function()
        local steamid = steamidEntry:GetValue()
        if steamid == "" then
            Derma_Message("Please enter a SteamID!", "Error", "OK")
            return
        end
        
        -- Basic validation
        if not string.match(steamid, "STEAM_%d:%d:%d+") then
            Derma_Message("Invalid SteamID format! Use: STEAM_0:X:XXXXXXXX", "Error", "OK")
            return
        end
        
        net.Start("QualSystem_AddPlayerToQual")
        net.WriteString(steamid)
        net.WriteString(qualName)
        net.SendToServer()
        
        timer.Simple(0.3, function()
            if IsValid(frame) then
                frame:Close()
                QualSystem:OpenPlayerManagement(qualName)
            end
        end)
    end
    
    -- Players list
    local listLabel = vgui.Create("DLabel", contentPanel)
    listLabel:Dock(TOP)
    listLabel:SetText("Current Players:")
    listLabel:SetFont("DermaDefaultBold")
    listLabel:SetTextColor(Color(255, 255, 255))
    listLabel:DockMargin(10, 10, 10, 5)
    
    local playersList = vgui.Create("DScrollPanel", contentPanel)
    playersList:Dock(FILL)
    playersList:DockMargin(5, 0, 5, 5)
    
    -- Request player data from server
    net.Start("QualSystem_RequestQualificationPlayers")
    net.WriteString(qualName)
    net.SendToServer()
    
    -- Network receiver for player data
    net.Receive("QualSystem_SendQualificationPlayers", function()
        local receivedQualName = net.ReadString()
        if receivedQualName ~= qualName then return end
        if not IsValid(frame) then return end
        
        local players = net.ReadTable()
        playersList:Clear()
        
        if #players == 0 then
            local noPlayers = vgui.Create("DLabel", playersList)
            noPlayers:Dock(TOP)
            noPlayers:SetText("No players have this qualification")
            noPlayers:SetTextColor(Color(150, 150, 150))
            noPlayers:DockMargin(10, 10, 10, 10)
            return
        end
        
        for _, playerData in ipairs(players) do
            local playerPanel = vgui.Create("DPanel", playersList)
            playerPanel:Dock(TOP)
            playerPanel:SetTall(60)
            playerPanel:DockMargin(5, 5, 5, 0)
            playerPanel.Paint = function(self, w, h)
                local col = Color(50, 50, 55, 200)
                if self:IsHovered() then
                    col = Color(60, 60, 70, 230)
                end
                draw.RoundedBox(4, 0, 0, w, h, col)
                
                -- Player name
                local nameText = playerData.name
                if not playerData.is_online then
                    nameText = nameText .. " (Offline)"
                end
                draw.SimpleText(nameText, "DermaDefaultBold", 10, 8, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                
                -- SteamID
                draw.SimpleText("SteamID: " .. playerData.steamid, "DermaDefault", 10, 25, Color(150, 180, 220, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                
                -- Granted info
                local grantedText = "Granted by: " .. playerData.granted_by
                draw.SimpleText(grantedText, "DermaDefault", 10, 42, Color(180, 180, 180, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end
            
            -- Copy SteamID button
            local copyBtn = vgui.Create("DButton", playerPanel)
            copyBtn:Dock(RIGHT)
            copyBtn:SetWide(80)
            copyBtn:DockMargin(5, 10, 5, 10)
            copyBtn:SetText("")
            copyBtn.Paint = function(self, w, h)
                local col = Color(60, 120, 180, 220)
                if self:IsHovered() then
                    col = Color(70, 140, 200, 255)
                end
                draw.RoundedBox(4, 0, 0, w, h, col)
                draw.SimpleText("Copy ID", "DermaDefaultBold", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            copyBtn.DoClick = function()
                SetClipboardText(playerData.steamid)
                chat.AddText(Color(100, 255, 150), "[Qualification System] ", Color(255, 255, 255), "SteamID copied to clipboard!")
            end
            
            -- Remove button (only for online players)
            if playerData.is_online then
                local removeBtn = vgui.Create("DButton", playerPanel)
                removeBtn:Dock(RIGHT)
                removeBtn:SetWide(80)
                removeBtn:DockMargin(0, 10, 5, 10)
                removeBtn:SetText("")
                removeBtn.Paint = function(self, w, h)
                    local col = Color(180, 50, 50, 200)
                    if self:IsHovered() then
                        col = Color(220, 60, 60, 255)
                    end
                    draw.RoundedBox(4, 0, 0, w, h, col)
                    draw.SimpleText("Remove", "DermaDefaultBold", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                removeBtn.DoClick = function()
                    Derma_Query(
                        "Remove " .. playerData.name .. " from this qualification?",
                        "Confirm Remove",
                        "Yes",
                        function()
                            net.Start("QualSystem_RemovePlayerFromQual")
                            net.WriteString(playerData.steamid)
                            net.WriteString(qualName)
                            net.SendToServer()
                            
                            timer.Simple(0.3, function()
                                if IsValid(frame) then
                                    frame:Close()
                                    QualSystem:OpenPlayerManagement(qualName)
                                end
                            end)
                        end,
                        "No"
                    )
                end
            end
        end
    end)
end

print("[Qualification System] Client-side admin menu loaded!")

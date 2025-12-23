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
        
        -- Delete button
        local deleteBtn = vgui.Create("DButton", detailsPanel)
        deleteBtn:SetPos(120, y)
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
    frame:SetSize(600, 700)
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
    
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 50, 10, 10)
    
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
        nameEntry:SetSize(560, 25)
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
    displayEntry:SetSize(560, 25)
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
    descEntry:SetSize(560, 25)
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
    modelEntry:SetSize(560, 25)
    modelEntry:SetValue(qualData.model or "")
    modelEntry:SetPlaceholderText("e.g., models/player/group01/male_01.mdl")
    y = y + 35
    
    -- Health
    local healthLabel = vgui.Create("DLabel", scroll)
    healthLabel:SetPos(0, y)
    healthLabel:SetText("Health:")
    healthLabel:SizeToContents()
    y = y + 20
    
    local healthSlider = vgui.Create("DNumSlider", scroll)
    healthSlider:SetPos(0, y)
    healthSlider:SetSize(560, 25)
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
    armorSlider:SetSize(560, 25)
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
    weaponsEntry:SetSize(560, 25)
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
    teacherQualEntry:SetSize(560, 25)
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
    jobPanel:SetSize(560, 150)
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
    funcEntry:SetSize(560, 100)
    funcEntry:SetMultiline(true)
    funcEntry:SetValue(qualData.custom_function or "")
    funcEntry:SetPlaceholderText("-- Optional Lua code\n-- Example:\n-- ply:SetRunSpeed(400)")
    y = y + 110
    
    -- Save button
    local saveBtn = vgui.Create("DButton", scroll)
    saveBtn:SetPos(0, y)
    saveBtn:SetSize(560, 40)
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
            allowed_jobs = {}
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

print("[Qualification System] Client-side admin menu loaded!")

local AceGUI = LibStub("AceGUI-3.0")
local columnWidth = 375
local minWidth, minHeight = columnWidth, 710

-- Function to display Notification Settings (Loot and Money Notifications)
local function NotificationSettingsSection(container, tempSettingsData)
    container:ReleaseChildren()  -- Clears the tab content before adding new widgets

    local displaySettingsGroup = AceGUI:Create("InlineGroup")
    displaySettingsGroup:SetLayout("Flow")  
    displaySettingsGroup:SetTitle("Notification Toggles")
    container:AddChild(displaySettingsGroup) 

    local enableLootCheckbox = AceGUI:Create("CheckBox")
    enableLootCheckbox:SetLabel("Enable Loot Notifications")
    enableLootCheckbox:SetValue(tempSettingsData.showLootNotifications)  
    enableLootCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleLootNotifications(value)
    end)
    displaySettingsGroup:AddChild(enableLootCheckbox)

    local enableMoneyCheckbox = AceGUI:Create("CheckBox")
    enableMoneyCheckbox:SetLabel("Enable Money Notifications")
    enableMoneyCheckbox:SetValue(tempSettingsData.showMoneyNotifications) 
    enableMoneyCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleMoneyNotifications(value)
    end)
    displaySettingsGroup:AddChild(enableMoneyCheckbox)

    -- Rarity Threshold Slider
    local thresholdSlider = AceGUI:Create("Slider")
    thresholdSlider:SetLabel("Notification Threshold (Rarity)")
    thresholdSlider:SetWidth(columnWidth)
    thresholdSlider:SetSliderValues(0, 5, 1) 
    thresholdSlider:SetValue(tempSettingsData.notificationThreshold)

    -- Create a text box below the slider to display the rarity name with color
    local initialRarity = rarityData[math.floor(tempSettingsData.notificationThreshold)]
    local rarityDisplayBox = AceGUI:Create("Label")
    rarityDisplayBox:SetText(initialRarity.name)  
    rarityDisplayBox:SetColor(initialRarity.color[1], initialRarity.color[2], initialRarity.color[3]) 
    rarityDisplayBox:SetWidth(columnWidth)
    rarityDisplayBox:SetFullWidth(true)
    rarityDisplayBox:SetJustifyH("CENTER")  

    -- Update the rarity name and color whenever the slider value changes
    thresholdSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleThresholdChange(value)
        local rarity = rarityData[math.floor(value)]
        rarityDisplayBox:SetText(rarity.name)  
        rarityDisplayBox:SetColor(rarity.color[1], rarity.color[2], rarity.color[3])  
    end)

    container:AddChild(thresholdSlider)
    container:AddChild(rarityDisplayBox)
end

-- Function to display Notification Display Settings (Loot Scroll Direction and Background)
local function DisplaySettingsSection(container, tempSettingsData)
    container:ReleaseChildren()  -- Clears the tab content before adding new widgets

    -- Display Duration Slider
    local durationSlider = AceGUI:Create("Slider")
    durationSlider:SetLabel("Display Duration (Seconds)")
    durationSlider:SetWidth(columnWidth)
    durationSlider:SetSliderValues(0.5, 5, 0.5)  
    durationSlider:SetValue(tempSettingsData.displayDuration)  
    durationSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleDisplayDurationChange(value)
    end)
    container:AddChild(durationSlider)  

    -- Notification Delay Slider 
    local notificationDelaySlider = AceGUI:Create("Slider")
    notificationDelaySlider:SetLabel("Delay Between Notifications (Seconds)")
    notificationDelaySlider:SetWidth(columnWidth)
    notificationDelaySlider:SetSliderValues(0, 1, 0.1)  
    notificationDelaySlider:SetValue(tempSettingsData.notificationDelay)  
    notificationDelaySlider:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleNotificationDelayChange(value)
    end)
    container:AddChild(notificationDelaySlider)  

    -- Max Notifications Slider
    local maximumNotificationsSlider = AceGUI:Create("Slider")
    maximumNotificationsSlider:SetLabel("Max Notifications (0 = No Limit)")
    maximumNotificationsSlider:SetWidth(columnWidth)
    maximumNotificationsSlider:SetSliderValues(0, 10, 1)  
    maximumNotificationsSlider:SetValue(tempSettingsData.maximumNotifications)  
    maximumNotificationsSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleMaximumNotificationsChange(value)
    end)
    container:AddChild(maximumNotificationsSlider)  

    -- Notifications Alpha
    local notificiationAlphaSlider = AceGUI:Create("Slider")
    notificiationAlphaSlider:SetLabel("Notification Alpha")
    notificiationAlphaSlider:SetWidth(columnWidth)
    notificiationAlphaSlider:SetSliderValues(0, 1, 0.1)  
    notificiationAlphaSlider:SetValue(tempSettingsData.notificationAlpha)  
    notificiationAlphaSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleNotificationAlphaChange(value)
    end)
    container:AddChild(notificiationAlphaSlider)  

    -- Notifications SCale
    local notificiationScaleSlider = AceGUI:Create("Slider")
    notificiationScaleSlider:SetLabel("Notification Scale")
    notificiationScaleSlider:SetWidth(columnWidth)
    notificiationScaleSlider:SetSliderValues(0, 2, 0.1)  
    notificiationScaleSlider:SetValue(tempSettingsData.notificationScale)  
    notificiationScaleSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleNotificationScaleChange(value)
    end)
    container:AddChild(notificiationScaleSlider) 

    -- Loot Scroll Direction Dropdown
    local scrollDirectionDropdown = AceGUI:Create("Dropdown")
    scrollDirectionDropdown:SetLabel("Loot Scroll Direction")
    scrollDirectionDropdown:SetWidth(columnWidth)
    scrollDirectionDropdown:SetList({
        ["up"] = "Scroll Up",
        ["down"] = "Scroll Down"
    })
    scrollDirectionDropdown:SetValue(tempSettingsData.scrollDirection) 
    scrollDirectionDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleScrollDirectionChange(value)
    end)
    container:AddChild(scrollDirectionDropdown)

    -- Loot Scroll Direction Dropdown
    local textDisplayDropdown = AceGUI:Create("Dropdown")
    textDisplayDropdown:SetLabel("Text Display")
    textDisplayDropdown:SetWidth(columnWidth)
    textDisplayDropdown:SetList({
        ["LEFT"] = "Left",
        ["CENTER"] = "Center",
        ["RIGHT"] = "Right",
    })
    textDisplayDropdown:SetValue(tempSettingsData.textDisplay) 
    textDisplayDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleTextDisplayChange(value)
    end)
    container:AddChild(textDisplayDropdown)

    -- Loot Scroll Direction Dropdown
    local iconDisplayDropdown = AceGUI:Create("Dropdown")
    iconDisplayDropdown:SetLabel("Icon Display")
    iconDisplayDropdown:SetWidth(columnWidth)
    iconDisplayDropdown:SetList({
        ["LEFT"] = "Left",
        ["RIGHT"] = "Right",
    })
    iconDisplayDropdown:SetValue(tempSettingsData.iconDisplay) 
    iconDisplayDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleIconDisplayChange(value)
    end)
    container:AddChild(iconDisplayDropdown)

    -- Display Notification Background Checkbox
    local displayBackgroundCheckbox = AceGUI:Create("CheckBox")
    displayBackgroundCheckbox:SetLabel("Display Notification Background")
    displayBackgroundCheckbox:SetValue(tempSettingsData.displayBackground)  
    displayBackgroundCheckbox:SetWidth(250)
    displayBackgroundCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleBackgroundDisplayChange(value)
    end)
    container:AddChild(displayBackgroundCheckbox)

    -- Background Alpha
    local notificiationBackgroundSlider = AceGUI:Create("Slider")
    notificiationBackgroundSlider:SetLabel("Notification Background Alpha")
    notificiationBackgroundSlider:SetWidth(columnWidth)
    notificiationBackgroundSlider:SetSliderValues(0, 1, 0.1)  
    notificiationBackgroundSlider:SetValue(tempSettingsData.backgroundAlpha)  
    notificiationBackgroundSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleBackgroundAlphaChange(value)
    end)
    container:AddChild(notificiationBackgroundSlider)  

    -- Display Notification Background Checkbox
    local showQuantityCheckbox = AceGUI:Create("CheckBox")
    showQuantityCheckbox:SetLabel("Display Quantities (x2, x3, ...)")
    showQuantityCheckbox:SetValue(tempSettingsData.showQuantity)  
    showQuantityCheckbox:SetWidth(250)
    showQuantityCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleShowQuantityChange(value)
    end)
    container:AddChild(showQuantityCheckbox)

    -- Display Notification Background Checkbox
    local showIconCheckbox = AceGUI:Create("CheckBox")
    showIconCheckbox:SetLabel("Show Icon")
    showIconCheckbox:SetValue(tempSettingsData.showIcon)  
    showIconCheckbox:SetWidth(250)
    showIconCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleShowIconChange(value)
    end)
    container:AddChild(showIconCheckbox)
end

-- Function to create a TabGroup
local function CreateTabGroup(tempSettingsData)
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Looti Settings")
    frame:SetWidth(columnWidth + 35)
    frame:SetHeight(minHeight)

    -- Button to display Loot Notification Frame
    local displayButton = AceGUI:Create("Button")
    displayButton:SetText("Show Notification Frame")
    displayButton:SetWidth(columnWidth)  
    displayButton:SetCallback("OnClick", function()
        NotificationManager:SetShowNotificationFrame(true)
    end)
    frame:AddChild(displayButton)  

    -- Create a TabGroup
    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Flow")  
    tabGroup:SetWidth(columnWidth)
    tabGroup:SetHeight(500)

    local tabFunctions = {
        ["tab1"] = function(container) NotificationSettingsSection(container, tempSettingsData) end,
        ["tab2"] = function(container) DisplaySettingsSection(container, tempSettingsData) end
    }

    --[[
    General Settings:   
                        [Checkbox] Enable Loot Notifications
                        [Checkbox] Enable Money Notifications
                        [Checkbox] Show Item Quantities (x2, x3, etc.)
                        [Checkbox] Show Loot Icon
                        [Slider] Notification Threshold (Rarity)
                        
    Display Settings:   
                        [Slider] Notification Alpha (Transparency)
                        [Slider] Notification Scale (Size)

                        [Checkbox] Display Notification Background
                        [Slider] Notification Background Alpha

                        [Dropdown] Loot Scroll Direction (Up / Down)
                        [Dropdown] Icon Display (Left / Right)
                        [Dropdown] Text Display (Left / Center / Right)

    Notification Behavior:   
                        [Slider] Display Duration (Seconds)
                        [Slider] Delay Between Notifications (Seconds)
                        [Slider] Max Notifications Displayed (0 = No Limit)

    Advanced Settings:   
                        [Future Debugging Features] Placeholder for logs/debug mode if needed
                        [Reset Button] Restore Defaults
]]--

    -- Set tabs
    local tabs = {
        {value = "tab1", text = "General Settings"},
        {value = "tab2", text = "Display Settings"},
        {value = "tab3", text = "Notification Behavior"},
        {value = "tab4", text = "Advanced Settings"},
    }
    tabGroup:SetTabs(tabs)

    -- Set callback for tab selection
    tabGroup:SetCallback("OnGroupSelected", function(widget, event, group)
        if tabFunctions[group] then
            tabFunctions[group](tabGroup)
        end
    end)

    -- Add the TabGroup to the frame
    frame:AddChild(tabGroup)

    -- Group for Test and Save Buttons 
    local butonGroup = AceGUI:Create("InlineGroup")
    butonGroup:SetFullWidth(true)
    butonGroup:SetTitle("") 
    butonGroup:SetLayout("Flow")  

    local testButton = AceGUI:Create("Button")
    testButton:SetText("Test Looti")
    testButton:SetWidth(columnWidth/2.2)
    testButton:SetCallback("OnClick", function()
        Looti_Test()
    end)
    butonGroup:AddChild(testButton)
    
    local saveButton = AceGUI:Create("Button")
    saveButton:SetText("Save Settings")
    saveButton:SetWidth(columnWidth/2.2)
    saveButton:SetCallback("OnClick", function()
        settingsPanel.HandleSaveSettings() 
    end)
    butonGroup:AddChild(saveButton)

    frame:AddChild(butonGroup)

    tabGroup:SelectTab("tab1")
end

-- Function to open the Looti Settings window
local function OpenLootiSettings()
    tempSettingsData = {
        showLootNotifications = LootiConfig.showLootNotifications,
        showMoneyNotifications = LootiConfig.showMoneyNotifications,
        notificationThreshold = LootiConfig.notificationThreshold,
        scrollDirection = LootiConfig.scrollDirection,
        displayBackground = LootiConfig.displayBackground,
        displayDuration = LootiConfig.displayDuration,
        notificationDelay = LootiConfig.notificationDelay,
        maximumNotifications = LootiConfig.maximumNotifications,
        showQuantity = LootiConfig.showQuantity,
        showIcon = LootiConfig.showIcon,
        textDisplay = LootiConfig.textDisplay,
        iconDisplay = LootiConfig.iconDisplay,
        notificationAlpha = LootiConfig.notificationAlpha,
        notificationScale = LootiConfig.notificationScale,
        backgroundAlpha = LootiConfig.backgroundAlpha
    }
    CreateTabGroup(tempSettingsData)
end

-- Register the slash command to open the settings window
SLASH_LOOTI1 = "/looti"
SlashCmdList["LOOTI"] = OpenLootiSettings

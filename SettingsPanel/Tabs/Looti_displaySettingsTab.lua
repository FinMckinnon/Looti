--[[
    [Slider] Notification Alpha (Transparency) 
    [Slider] Notification Scale (Size) 

    [Checkbox] Display Notification Background 
    [Slider] Notification Background Alpha 

    [Dropdown] Loot Scroll Direction (Up / Down) 
    [Dropdown] Icon Display (Left / Right) 
    [Dropdown] Text Display (Left / Center / Right) 
]]--

local function CreateNotificationOptions(container, tempSettingsData, columnWidth)
    -- Group for notification settings
    local notificationsSettingsGroup = AceGUI:Create("InlineGroup")
    notificationsSettingsGroup:SetLayout("Flow")  
    notificationsSettingsGroup:SetWidth(columnWidth)  
    notificationsSettingsGroup:SetTitle("Notification Settings")
    container:AddChild(notificationsSettingsGroup) 

    -- Notifications Alpha
    local notificiationAlphaSlider = AceGUI:Create("Slider")
    notificiationAlphaSlider:SetLabel("Notification Alpha")
    notificiationAlphaSlider:SetFullWidth(true)
    notificiationAlphaSlider:SetSliderValues(0, 1, 0.1)  
    notificiationAlphaSlider:SetValue(tempSettingsData.notificationAlpha)  
    notificiationAlphaSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleNotificationAlphaChange(value)
    end)
    notificationsSettingsGroup:AddChild(notificiationAlphaSlider)  

    -- Notifications SCale
    local notificiationScaleSlider = AceGUI:Create("Slider")
    notificiationScaleSlider:SetLabel("Notification Scale")
    notificiationScaleSlider:SetFullWidth(true)
    notificiationScaleSlider:SetSliderValues(0, 2, 0.1)  
    notificiationScaleSlider:SetValue(tempSettingsData.notificationScale)  
    notificiationScaleSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleNotificationScaleChange(value)
    end)
    notificationsSettingsGroup:AddChild(notificiationScaleSlider) 
end

local function CreateBackgroundOptions(container, tempSettingsData, columnWidth)
    -- Group for background settings
    local backgroundSettingsGroup = AceGUI:Create("InlineGroup")
    backgroundSettingsGroup:SetLayout("Flow")  
    backgroundSettingsGroup:SetWidth(columnWidth)  
    backgroundSettingsGroup:SetTitle("Background Settings")
    container:AddChild(backgroundSettingsGroup) 

    -- Display Notification Background Checkbox
    local displayBackgroundCheckbox = AceGUI:Create("CheckBox")
    displayBackgroundCheckbox:SetLabel("Display Notification Background")
    displayBackgroundCheckbox:SetValue(tempSettingsData.displayBackground)  
    displayBackgroundCheckbox:SetFullWidth(true)
    displayBackgroundCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleBackgroundDisplayChange(value)
    end)
    backgroundSettingsGroup:AddChild(displayBackgroundCheckbox)

    -- Background Alpha
    local notificiationBackgroundSlider = AceGUI:Create("Slider")
    notificiationBackgroundSlider:SetLabel("Notification Background Alpha")
    notificiationBackgroundSlider:SetFullWidth(true)
    notificiationBackgroundSlider:SetSliderValues(0, 1, 0.1)  
    notificiationBackgroundSlider:SetValue(tempSettingsData.backgroundAlpha)  
    notificiationBackgroundSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleBackgroundAlphaChange(value)
    end)
    backgroundSettingsGroup:AddChild(notificiationBackgroundSlider)  
    
end

local function CreateOrientationOptions(container, tempSettingsData, columnWidth)

    -- Group for oritentation settings
    local orientationSettingsGroup = AceGUI:Create("InlineGroup")
    orientationSettingsGroup:SetLayout("Flow")  
    orientationSettingsGroup:SetWidth(columnWidth)  
    orientationSettingsGroup:SetTitle("Oritentation Settings")
    container:AddChild(orientationSettingsGroup) 

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
    orientationSettingsGroup:AddChild(scrollDirectionDropdown)

    -- Text Orientation Dropdown
    local textDisplayDropdown = AceGUI:Create("Dropdown")
    textDisplayDropdown:SetLabel("Text Display")
    textDisplayDropdown:SetFullWidth(true)
    textDisplayDropdown:SetList({
        ["LEFT"] = "Left",
        ["CENTER"] = "Center",
        ["RIGHT"] = "Right",
    })
    textDisplayDropdown:SetValue(tempSettingsData.textDisplay) 
    textDisplayDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleTextDisplayChange(value)
    end)
    orientationSettingsGroup:AddChild(textDisplayDropdown)

    -- Icon Orientation Dropdown
    local iconDisplayDropdown = AceGUI:Create("Dropdown")
    iconDisplayDropdown:SetLabel("Icon Display")
    iconDisplayDropdown:SetFullWidth(true)
    iconDisplayDropdown:SetList({
        ["LEFT"] = "Left",
        ["RIGHT"] = "Right",
    })
    iconDisplayDropdown:SetValue(tempSettingsData.iconDisplay) 
    iconDisplayDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleIconDisplayChange(value)
    end)
    orientationSettingsGroup:AddChild(iconDisplayDropdown)
end

local function CreateDisplaySettingsTab(container, tempSettingsData, columnWidth)
    container:ReleaseChildren()  -- Clears the tab content before adding new widgets

    CreateBackgroundOptions(container, tempSettingsData, columnWidth)

    CreateNotificationOptions(container, tempSettingsData, columnWidth)

    CreateOrientationOptions(container, tempSettingsData, columnWidth)

end

_G["CreateDisplaySettingsTab"] = CreateDisplaySettingsTab

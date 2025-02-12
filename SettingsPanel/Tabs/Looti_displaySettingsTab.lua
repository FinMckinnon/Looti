--[[
    [Slider] Notification Alpha (Transparency) 
    [Slider] Notification Scale (Size) 

    [Checkbox] Display Notification Background 
    [Slider] Notification Background Alpha 

    [Dropdown] Loot Scroll Direction (Up / Down) 
    [Dropdown] Icon Display (Left / Right) 
    [Dropdown] Text Display (Left / Center / Right) 
]]--

local function createBackgroundOptions(container, tempSettingsData, columnWidth)
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
    
end

local function createOrientationOptions(container, tempSettingsData, columnWidth)
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

    -- Text Orientation Dropdown
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

    -- Icon Orientation Dropdown
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
end

local function createDisplaySettingsTab(container, tempSettingsData, columnWidth)
    container:ReleaseChildren()  -- Clears the tab content before adding new widgets

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

   createBackgroundOptions(container, tempSettingsData, columnWidth)

   createOrientationOptions(container, tempSettingsData, columnWidth)

end

_G["createDisplaySettingsTab"] = createDisplaySettingsTab

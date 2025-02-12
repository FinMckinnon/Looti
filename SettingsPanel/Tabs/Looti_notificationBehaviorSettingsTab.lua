--[[
    [Slider] Display Duration (Seconds)
    [Slider] Delay Between Notifications (Seconds)
    
    [Slider] Max Notifications Displayed (0 = No Limit)
]]--

local function CreateNotificationBehaviorSettingsTab(container, tempSettingsData, columnWidth)
    container:ReleaseChildren()  -- Clears the tab content before adding new widgets

    -- Group for Timing settings
    local notificationTimingSettingsGroup = AceGUI:Create("InlineGroup")
    notificationTimingSettingsGroup:SetLayout("Flow")  
    notificationTimingSettingsGroup:SetWidth(columnWidth)  
    notificationTimingSettingsGroup:SetTitle("Notification Timing Settings")
    container:AddChild(notificationTimingSettingsGroup) 

    -- Display Duration Slider
    local durationSlider = AceGUI:Create("Slider")
    durationSlider:SetLabel("Display Duration (Seconds)")
    durationSlider:SetFullWidth(true)
    durationSlider:SetSliderValues(0.5, 5, 0.5)  
    durationSlider:SetValue(tempSettingsData.displayDuration)  
    durationSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleDisplayDurationChange(value)
    end)
    notificationTimingSettingsGroup:AddChild(durationSlider)  

    -- Notification Delay Slider 
    local notificationDelaySlider = AceGUI:Create("Slider")
    notificationDelaySlider:SetLabel("Delay Between Notifications (Seconds)")
    notificationDelaySlider:SetFullWidth(true)
    notificationDelaySlider:SetSliderValues(0, 1, 0.1)  
    notificationDelaySlider:SetValue(tempSettingsData.notificationDelay)  
    notificationDelaySlider:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleNotificationDelayChange(value)
    end)
    notificationTimingSettingsGroup:AddChild(notificationDelaySlider)  

    -- Group for Management settings
    local notificationManagementSettingsGroup = AceGUI:Create("InlineGroup")
    notificationManagementSettingsGroup:SetLayout("Flow")  
    notificationManagementSettingsGroup:SetWidth(columnWidth)  
    notificationManagementSettingsGroup:SetTitle("Notification Management Settings")
    container:AddChild(notificationManagementSettingsGroup) 

    -- Max Notifications Slider
    local maximumNotificationsSlider = AceGUI:Create("Slider")
    maximumNotificationsSlider:SetLabel("Max Notifications (0 = No Limit)")
    maximumNotificationsSlider:SetFullWidth(true)
    maximumNotificationsSlider:SetSliderValues(0, 10, 1)  
    maximumNotificationsSlider:SetValue(tempSettingsData.maximumNotifications)  
    maximumNotificationsSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleMaximumNotificationsChange(value)
    end)
    notificationManagementSettingsGroup:AddChild(maximumNotificationsSlider)

end

_G["CreateNotificationBehaviorSettingsTab"] = CreateNotificationBehaviorSettingsTab

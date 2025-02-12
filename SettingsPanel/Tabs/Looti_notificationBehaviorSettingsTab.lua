--[[
    [Slider] Display Duration (Seconds)
    [Slider] Delay Between Notifications (Seconds)
    [Slider] Max Notifications Displayed (0 = No Limit)
]]--

local function createNotificationBehaviorSettingsTab(container, tempSettingsData, columnWidth)
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

end

_G["createNotificationBehaviorSettingsTab"] = createNotificationBehaviorSettingsTab

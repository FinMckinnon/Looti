AceGUI = LibStub("AceGUI-3.0")
local columnWidth = 375
local minWidth, minHeight = columnWidth, 600

-- Button group displayed at the top of the settings page
local function CreateHeaderButtonGroup(frame)
    -- Button to display Loot Notification Frame
    local displayButton = AceGUI:Create("Button")
    displayButton:SetText("Show Notification Frame")
    displayButton:SetWidth(columnWidth)  
    displayButton:SetCallback("OnClick", function()
        NotificationManager:SetShowNotificationFrame(true)
    end)
    frame:AddChild(displayButton)  
end

-- Button group displayed at bottom of settings tabs
local function createFooterButtonGroup(frame)
    -- Group for Test and Save Buttons 
    local butonGroup = AceGUI:Create("InlineGroup")
    butonGroup:SetFullWidth(true)
    butonGroup:SetWidth(columnWidth)
    butonGroup:SetTitle("") 
    butonGroup:SetLayout("Flow")  

    -- Test Looti Button
    local testButton = AceGUI:Create("Button")
    testButton:SetText("Test Looti")
    testButton:SetWidth(columnWidth/2.2)
    testButton:SetCallback("OnClick", function()
        Looti_Test()
    end)
    butonGroup:AddChild(testButton)
    
    -- Save Looti Button
    local saveButton = AceGUI:Create("Button")
    saveButton:SetText("Save Settings")
    saveButton:SetWidth(columnWidth/2.2)
    saveButton:SetCallback("OnClick", function()
        settingsPanel.HandleSaveSettings() 
    end)
    butonGroup:AddChild(saveButton)
    
    frame:AddChild(butonGroup)
end

-- Create a TabGroup for navigation
local function CreateTabGroup(frame, tempSettingsData)
    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Flow")  
    tabGroup:SetWidth(columnWidth)
    tabGroup:SetHeight(500)

    local tabs = {
        {value = "general_settings", text = "General Settings"},
        {value = "display_settings", text = "Display Settings"},
        {value = "notification_behavior_settings", text = "Notification Behavior"},
        {value = "advanced_settings", text = "Advanced Settings"},
    }

    local tabFunctions = {
        ["general_settings"] = function(container) createGeneralSettingsTab(container, tempSettingsData, columnWidth) end,
        ["display_settings"] = function(container) createDisplaySettingsTab(container, tempSettingsData, columnWidth) end,
        ["notification_behavior_settings"] = function(container) createNotificationBehaviorSettingsTab(container, tempSettingsData, columnWidth) end,
        ["advanced_settings"] = function(container) createAdvancedSettingsTab(container, tempSettingsData, columnWidth) end
    }

    tabGroup:SetTabs(tabs)

    -- Set callback for tab selection
    tabGroup:SetCallback("OnGroupSelected", function(widget, event, group)
        if tabFunctions[group] then
            tabFunctions[group](tabGroup)
        end
    end)
    frame:AddChild(tabGroup)
    tabGroup:SelectTab("general_settings")
end

-- Function to create a TabGroup
local function CreateSettingsWindow(tempSettingsData)
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Looti Settings")
    frame:SetWidth(columnWidth + 35)
    frame:SetHeight(minHeight)

    CreateHeaderButtonGroup(frame)

    CreateTabGroup(frame, tempSettingsData)

    createFooterButtonGroup(frame)

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
    CreateSettingsWindow(tempSettingsData)
end

-- Register the slash command to open the settings window
SLASH_LOOTI1 = "/looti"
SlashCmdList["LOOTI"] = OpenLootiSettings

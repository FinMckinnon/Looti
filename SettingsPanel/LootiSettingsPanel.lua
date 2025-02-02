local AceGUI = LibStub("AceGUI-3.0")
local columnWidth = 300
local minWidth, minHeight = columnWidth, 600

-- Function to open the settings window
local function OpenLootiSettings()
    tempSettingsData = {
        showLootNotifications = LootiConfig.showLootNotifications,
        showMoneyNotifications = LootiConfig.showMoneyNotifications,
        notificationThreshold = LootiConfig.notificationThreshold,
        scrollDirection = LootiConfig.scrollDirection,
        displayBackground = LootiConfig.displayBackground,
        displayDuration = LootiConfig.displayDuration,
        notificationDelay = LootiConfig.notificationDelay,
        maximumNotifications = LootiConfig.maximumNotifications
    }

    -- Create the main settings frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Looti Settings")
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    
    -- Set the initial size of the frame
    frame:SetWidth(columnWidth + 50)
    frame:SetHeight(600)  
    frame.frame:SetScript("OnSizeChanged", function(self, width, height)
        if width < minWidth then
            self:SetWidth(minWidth)
        end
        if height < minHeight then
            self:SetHeight(minHeight)
        end
    end)
    
    frame:SetLayout("Table")
    frame:SetUserData("table", {columns = {columnWidth}, spaceH = 10, spaceV = 10})  
    frame:SetUserData("align", "CENTER")

    -- Button to display Loot Notification Frame
    local displayButton = AceGUI:Create("Button")
    displayButton:SetText("Show Notification Frame")
    displayButton:SetWidth(columnWidth)  
    displayButton:SetCallback("OnClick", function()
        NotificationManager:SetShowNotificationFrame(true)
    end)
    frame:AddChild(displayButton)  

    -- Group for Notification Settings (Loot and Money Notifications checkboxes)
    local displaySettingsGroup = AceGUI:Create("InlineGroup")
    displaySettingsGroup:SetLayout("Flow")  
    displaySettingsGroup:SetTitle("Notification Settings")
    frame:AddChild(displaySettingsGroup) 

    -- Loot Notifications Checkbox
    local enableLootCheckbox = AceGUI:Create("CheckBox")
    enableLootCheckbox:SetLabel("Enable Loot Notifications")
    enableLootCheckbox:SetValue(tempSettingsData.showLootNotifications)  
    enableLootCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleLootNotifications(value)
    end)
    displaySettingsGroup:AddChild(enableLootCheckbox)

    -- Money Notifications Checkbox
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
    local rarityDisplayBox = AceGUI:Create("Label")
    local initialRarity = rarityData[math.floor(tempSettingsData.notificationThreshold)]
    rarityDisplayBox:SetText(initialRarity.name)  
    rarityDisplayBox:SetColor(initialRarity.color[1], initialRarity.color[2], initialRarity.color[3])  
    rarityDisplayBox:SetJustifyH("CENTER")  
    rarityDisplayBox:SetWidth(columnWidth)

    -- Update the rarity name and color whenever the slider value changes
    thresholdSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleThresholdChange(value)
        local rarity = rarityData[math.floor(value)]
        rarityDisplayBox:SetText(rarity.name)  
        rarityDisplayBox:SetColor(rarity.color[1], rarity.color[2], rarity.color[3])  
    end)

    frame:AddChild(thresholdSlider)
    frame:AddChild(rarityDisplayBox)

    -- Display Duration Slider (this will go on a new row)
    local durationSlider = AceGUI:Create("Slider")
    durationSlider:SetLabel("Display Duration (Seconds)")
    durationSlider:SetWidth(columnWidth)
    durationSlider:SetSliderValues(0.5, 5, 0.5)  
    durationSlider:SetValue(tempSettingsData.displayDuration)  
    durationSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleDisplayDurationChange(value)
    end)
    frame:AddChild(durationSlider)  

    -- Display Duration Slider 
    local notificationDelaySlider = AceGUI:Create("Slider")
    notificationDelaySlider:SetLabel("Delay Between Notifications (Seconds)")
    notificationDelaySlider:SetWidth(columnWidth)
    notificationDelaySlider:SetSliderValues(0, 1, 0.1)  
    notificationDelaySlider:SetValue(tempSettingsData.notificationDelay)  
    notificationDelaySlider:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleNotificationDelayChange(value)
    end)
    frame:AddChild(notificationDelaySlider)  

    -- Display Duration Slider (this will go on a new row)
    local maximumNotificationsSlider = AceGUI:Create("Slider")
    maximumNotificationsSlider:SetLabel("Max Notifications (0 = No Limit)")
    maximumNotificationsSlider:SetWidth(columnWidth)
    maximumNotificationsSlider:SetSliderValues(0, 10, 1)  
    maximumNotificationsSlider:SetValue(tempSettingsData.maximumNotifications)  
    maximumNotificationsSlider:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleMaximumNotificationsChange(value)
    end)
    frame:AddChild(maximumNotificationsSlider)  

    -- Group for Notification Settings (Loot Scroll Direction and Display Background checkboxes)
    local notificationSettingsGroup = AceGUI:Create("InlineGroup")
    notificationSettingsGroup:SetLayout("Flow") 
    notificationSettingsGroup:SetTitle("Notification Display Settings")
    frame:AddChild(notificationSettingsGroup)  

    -- Loot Scroll Direction Dropdown
    local scrollDirectionDropdown = AceGUI:Create("Dropdown")
    scrollDirectionDropdown:SetLabel("Loot Scroll Direction")
    scrollDirectionDropdown:SetList({
        ["up"] = "Scroll Up",
        ["down"] = "Scroll Down"
    })
    scrollDirectionDropdown:SetValue(tempSettingsData.scrollDirection) 
    scrollDirectionDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleScrollDirectionChange(value)
    end)
    notificationSettingsGroup:AddChild(scrollDirectionDropdown)

    -- Display Notification Background Checkbox
    local displayBackgroundCheckbox = AceGUI:Create("CheckBox")
    displayBackgroundCheckbox:SetLabel("Display Notification Background")
    displayBackgroundCheckbox:SetValue(tempSettingsData.displayBackground)  
    displayBackgroundCheckbox:SetWidth(250)
    displayBackgroundCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleBackgroundDisplayChange(value)
    end)
    notificationSettingsGroup:AddChild(displayBackgroundCheckbox)

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
end

local function CreateTabGroup()
    -- Create the main frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Looti Settings")
    frame:SetWidth(300)
    frame:SetHeight(200)

    -- Create a TabGroup
    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")  -- Set layout to fill to occupy the entire space of the frame
    tabGroup:SetWidth(300)
    tabGroup:SetHeight(150)

    -- Set the titles and content of the tabs
    local tabs = {
        {value = "tab1", text = "Tab 1", contents = "Content of Tab 1"},
        {value = "tab2", text = "Tab 2", contents = "Content of Tab 2"},
        {value = "tab3", text = "Tab 3", contents = "Content of Tab 3"}
    }

    -- Function to display the content of the selected tab
    local function DisplayTabContent(tabKey)
        -- Find the selected tab and display its content
        for _, tab in ipairs(tabs) do
            if tab.value == tabKey then
                print(tab.contents)  -- Here you can replace this with any action to show the tab's content
            end
        end
    end

    -- Set the tabs in the TabGroup
    tabGroup:SetTabs(tabs)

    -- Set the callback for when a tab is selected
    tabGroup:SetCallback("OnGroupSelected", function(widget, event, group)
        DisplayTabContent(group)  -- Display content for the selected tab
    end)

    -- Add the TabGroup to the frame
    frame:AddChild(tabGroup)

    -- Select the first tab by default
    tabGroup:SelectTab("tab1")
end

-- Register the slash command to open the settings window
SLASH_LOOTI1 = "/looti"
SlashCmdList["LOOTI"] = OpenLootiSettings

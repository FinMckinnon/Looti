local AceGUI = LibStub("AceGUI-3.0")
local columnWidth = 300

-- Empty handler functions (placeholders)
local function HandleLootNotifications(value)
    tempSettingsData.showLootNotifications = value
end

local function HandleMoneyNotifications(value)
    tempSettingsData.showMoneyNotifications = value
end

local function HandleThresholdChange(value)
    tempSettingsData.notificationThreshold = value
end

local function HandleScrollDirectionChange(value)
    tempSettingsData.scrollDirection = value
end

local function HandleBackgroundDisplayChange(value)
    tempSettingsData.displayBackground = value
end

local function HandleDisplayDurationChange(value)
    tempSettingsData.displayDuration = value
end

local function HandleSaveSettings()
    -- Save the settings to the saved config from tempSettingsData
    LootiConfig.showLootNotifications = tempSettingsData.showLootNotifications
    LootiConfig.showMoneyNotifications = tempSettingsData.showMoneyNotifications
    LootiConfig.notificationThreshold = tempSettingsData.notificationThreshold
    LootiConfig.scrollDirection = tempSettingsData.scrollDirection
    LootiConfig.displayBackground = tempSettingsData.displayBackground
    LootiConfig.displayDuration = tempSettingsData.displayDuration
    print("Settings saved!")
end

local function getStatusString()
    return "Looti is " .. (tempSettingsData.showLootNotifications and tempSettingsData.showMoneyNotifications and "enabled" or "disabled")
end

-- Function to open the settings window
local function OpenLootiSettings()
    -- Create tempSettingsData to hold the temporary settings
    tempSettingsData = {
        showLootNotifications = LootiConfig.showLootNotifications,
        showMoneyNotifications = LootiConfig.showMoneyNotifications,
        notificationThreshold = LootiConfig.notificationThreshold,
        scrollDirection = LootiConfig.scrollDirection,
        displayBackground = LootiConfig.displayBackground,
        displayDuration = LootiConfig.displayDuration
    }

    -- Create the main settings frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Loot Notifications Settings")
    frame:SetStatusText(getStatusString())
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    
    -- Set the initial size of the frame
    frame:SetWidth(columnWidth + 50)
    frame:SetHeight(600)  -- Increased height to accommodate the new slider
    
    -- Apply the 'Table' layout for grid structure with 2 columns (Display Settings + Slider side by side)
    frame:SetLayout("Table")
    frame:SetUserData("table", {columns = {columnWidth}, spaceH = 10, spaceV = 10})  -- Set 1 column for each row
    
    -- Center alignment for all child elements
    frame:SetUserData("align", "CENTER")

    -- Button to display Loot Notification Frame
    local displayButton = AceGUI:Create("Button")
    displayButton:SetText("Display Loot Notification Frame")
    displayButton:SetWidth(columnWidth)  -- Increase the width to make the text fully visible
    displayButton:SetCallback("OnClick", function()
        NotificationManager:SetShowNotificationFrame(true)
    end)
    frame:AddChild(displayButton)  -- Automatically placed in the first row

    -- Group for Display Settings (Loot and Money Notifications checkboxes)
    local displaySettingsGroup = AceGUI:Create("InlineGroup")
    displaySettingsGroup:SetLayout("Flow")  -- Use Flow inside the section
    displaySettingsGroup:SetTitle("Display Settings")
    frame:AddChild(displaySettingsGroup)  -- Automatically placed in the next row

    -- Loot Notifications Checkbox
    local enableLootCheckbox = AceGUI:Create("CheckBox")
    enableLootCheckbox:SetLabel("Enable Loot Notifications")
    enableLootCheckbox:SetValue(tempSettingsData.showLootNotifications)  -- Default to tempSettingsData value
    enableLootCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        HandleLootNotifications(value)
    end)
    displaySettingsGroup:AddChild(enableLootCheckbox)

    -- Money Notifications Checkbox
    local enableMoneyCheckbox = AceGUI:Create("CheckBox")
    enableMoneyCheckbox:SetLabel("Enable Money Notifications")
    enableMoneyCheckbox:SetValue(tempSettingsData.showMoneyNotifications)  -- Default to tempSettingsData value
    enableMoneyCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        HandleMoneyNotifications(value)
    end)
    displaySettingsGroup:AddChild(enableMoneyCheckbox)

    -- Rarity Threshold Slider (this will be placed next to Display Settings)
    local thresholdSlider = AceGUI:Create("Slider")
    thresholdSlider:SetLabel("Notification Threshold (Rarity)")
    thresholdSlider:SetSliderValues(0, 7, 1)  -- Min 0, Max 7, Step 1
    thresholdSlider:SetValue(tempSettingsData.notificationThreshold)  -- Default to tempSettingsData value
    thresholdSlider:SetCallback("OnValueChanged", function(widget, event, value)
        HandleThresholdChange(value)
    end)
    frame:AddChild(thresholdSlider)  -- This will go in the second column next to Display Settings

    -- Display Duration Slider (this will go on a new row)
    local durationSlider = AceGUI:Create("Slider")
    durationSlider:SetLabel("Display Duration (Seconds)")
    durationSlider:SetSliderValues(0.5, 5, 0.5)  -- Min 1, Max 10, Step 1
    durationSlider:SetValue(tempSettingsData.displayDuration)  -- Default to tempSettingsData value
    durationSlider:SetCallback("OnValueChanged", function(widget, event, value)
        HandleDisplayDurationChange(value)
    end)
    frame:AddChild(durationSlider)  -- This will go into its own row below the threshold slider

    -- Group for Notification Settings (Loot Scroll Direction and Display Background checkboxes)
    local notificationSettingsGroup = AceGUI:Create("InlineGroup")
    notificationSettingsGroup:SetLayout("Flow")  -- Use Flow inside the section
    notificationSettingsGroup:SetTitle("Notification Settings")
    frame:AddChild(notificationSettingsGroup)  -- Automatically placed in the next row

    -- Loot Scroll Direction Dropdown
    local scrollDirectionDropdown = AceGUI:Create("Dropdown")
    scrollDirectionDropdown:SetLabel("Loot Scroll Direction")
    scrollDirectionDropdown:SetList({
        ["up"] = "Scroll Up",
        ["down"] = "Scroll Down"
    })
    scrollDirectionDropdown:SetValue(tempSettingsData.scrollDirection)  -- Default to tempSettingsData value
    scrollDirectionDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        HandleScrollDirectionChange(value)
    end)
    notificationSettingsGroup:AddChild(scrollDirectionDropdown)

    -- Display Notification Background Checkbox
    local displayBackgroundCheckbox = AceGUI:Create("CheckBox")
    displayBackgroundCheckbox:SetLabel("Display Notification Background")
    displayBackgroundCheckbox:SetValue(tempSettingsData.displayBackground)  -- Default to tempSettingsData value
    displayBackgroundCheckbox:SetWidth(250)
    displayBackgroundCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        HandleBackgroundDisplayChange(value)
    end)
    notificationSettingsGroup:AddChild(displayBackgroundCheckbox)

    -- Save Button at the bottom (on the next row)
    local saveButton = AceGUI:Create("Button")
    saveButton:SetText("Save Settings")
    saveButton:SetWidth(columnWidth)
    saveButton:SetCallback("OnClick", function()
        HandleSaveSettings() 
        frame:Hide()  -- Optionally close the settings frame after saving
    end)

    -- Add the save button, it will go to the next available grid slot
    frame:AddChild(saveButton)
end

-- Register the slash command to open the settings window
SLASH_LOOTI1 = "/looti"
SlashCmdList["LOOTI"] = OpenLootiSettings

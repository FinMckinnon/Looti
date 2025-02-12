--[[
    [Checkbox] Enable Loot Notifications
    [Checkbox] Enable Money Notifications
    [Checkbox] Show Item Quantities (x2, x3, etc.)
    [Checkbox] Show Loot Icon
    [Slider] Notification Threshold (Rarity)
]]--

local function createGeneralNotificationToggles(container, tempSettingsData, columnWidth)
    -- Grouped frame for the checkboxes
    local notificationTogglesGroup = AceGUI:Create("InlineGroup")
    notificationTogglesGroup:SetLayout("Flow")  
    notificationTogglesGroup:SetTitle("Notification Toggles")
    container:AddChild(notificationTogglesGroup) 

    -- Enable loot notifications checkbox
    local enableLootCheckbox = AceGUI:Create("CheckBox")
    enableLootCheckbox:SetLabel("Enable Loot Notifications")
    enableLootCheckbox:SetValue(tempSettingsData.showLootNotifications)  
    enableLootCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleLootNotifications(value)
    end)
    notificationTogglesGroup:AddChild(enableLootCheckbox)

    -- Enable money notifications checkbox
    local enableMoneyCheckbox = AceGUI:Create("CheckBox")
    enableMoneyCheckbox:SetLabel("Enable Money Notifications")
    enableMoneyCheckbox:SetValue(tempSettingsData.showMoneyNotifications) 
    enableMoneyCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleMoneyNotifications(value)
    end)
    notificationTogglesGroup:AddChild(enableMoneyCheckbox)

    -- Display Quantities Checkbox
    local showQuantityCheckbox = AceGUI:Create("CheckBox")
    showQuantityCheckbox:SetLabel("Display Quantities (x2, x3, ...)")
    showQuantityCheckbox:SetValue(tempSettingsData.showQuantity)  
    showQuantityCheckbox:SetWidth(250)
    showQuantityCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleShowQuantityChange(value)
    end)
    container:AddChild(showQuantityCheckbox)

    -- Display Icons Checkbox
    local showIconCheckbox = AceGUI:Create("CheckBox")
    showIconCheckbox:SetLabel("Show Icon")
    showIconCheckbox:SetValue(tempSettingsData.showIcon)  
    showIconCheckbox:SetWidth(250)
    showIconCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        settingsPanel.HandleShowIconChange(value)
    end)
    container:AddChild(showIconCheckbox)
end

local function createRaritySlider(container, tempSettingsData, columnWidth)
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

local function createGeneralSettingsTab(container, tempSettingsData, columnWidth)
    container:ReleaseChildren()  -- Clears the tab content before adding new widgets

    createGeneralNotificationToggles(container, tempSettingsData, columnWidth)

    createRaritySlider(container, tempSettingsData, columnWidth)
end

_G["createGeneralSettingsTab"] = createGeneralSettingsTab

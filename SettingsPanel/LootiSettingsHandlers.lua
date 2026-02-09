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

local function HandleNotificationDelayChange(value)
    tempSettingsData.notificationDelay = value
end

local function HandleMaximumNotificationsChange(value)
    tempSettingsData.maximumNotifications = value
end

local function HandleShowQuantityChange(value)
    tempSettingsData.showQuantity = value
end

local function HandleShowItemLevelChange(value)
    tempSettingsData.showItemLevel = value
end

local function HandleShowItemLevelUpgradeIconChange(value)
    tempSettingsData.showItemLevelUpgradeIcon = value
end

local function HandleShowIconChange(value)
    tempSettingsData.showIcon = value
end

local function HandleIconDisplayChange(value)
    tempSettingsData.iconDisplay = value
end

local function HandleTextDisplayChange(value)
    tempSettingsData.textDisplay = value
end

local function HandleNotificationAlphaChange(value)
    tempSettingsData.notificationAlpha = value
end

local function HandleNotificationScaleChange(value)
    tempSettingsData.notificationScale = value
end

local function HandleBackgroundAlphaChange(value)
    tempSettingsData.backgroundAlpha = value
end


local function HandleReset(tempSettingsData)
    copyTable(LootiConfig, LootiConfigDefault)
    copyTable(tempSettingsData, LootiConfig)
    LOOTI_CHAT_LOG("Looti has been reset.", "update")
end

local function HandleResetButtonClick(tempSettingsData)
    CreateConfirmationPopup("RESET_LOOTI_POP_UP", "Confirm Action", "Are you sure you want to reset Looti?", function()
        HandleReset(tempSettingsData)
    end)
    
end

-- Function to save settings from tempSettingsData to LootiConfig
local function HandleSaveSettings()
    for setting, value in pairs(tempSettingsData) do
        LootiConfig[setting] = value
    end
    LOOTI_CHAT_LOG("Looti Settings saved!")
end

_G["settingsPanel"] = {
    HandleLootNotifications = HandleLootNotifications,
    HandleMoneyNotifications = HandleMoneyNotifications,
    HandleThresholdChange = HandleThresholdChange,
    HandleScrollDirectionChange = HandleScrollDirectionChange,
    HandleBackgroundDisplayChange = HandleBackgroundDisplayChange,
    HandleDisplayDurationChange = HandleDisplayDurationChange,
    HandleNotificationDelayChange = HandleNotificationDelayChange,
    HandleMaximumNotificationsChange = HandleMaximumNotificationsChange,
    HandleSaveSettings = HandleSaveSettings,
    HandleShowQuantityChange = HandleShowQuantityChange,
    HandleShowItemLevelChange = HandleShowItemLevelChange,
    HandleShowItemLevelUpgradeIconChange = HandleShowItemLevelUpgradeIconChange,
    HandleShowIconChange = HandleShowIconChange,
    HandleIconDisplayChange = HandleIconDisplayChange,
    HandleTextDisplayChange = HandleTextDisplayChange,
    HandleNotificationAlphaChange = HandleNotificationAlphaChange,
    HandleNotificationScaleChange = HandleNotificationScaleChange,
    HandleBackgroundAlphaChange = HandleBackgroundAlphaChange,
    HandleResetButtonClick = HandleResetButtonClick
}
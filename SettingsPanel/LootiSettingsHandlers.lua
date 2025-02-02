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

local function HandleShowIconChange(value)
    tempSettingsData.showIcon = value
end

-- Save the settings to the saved config from tempSettingsData
local function HandleSaveSettings()
    LootiConfig.showLootNotifications = tempSettingsData.showLootNotifications
    LootiConfig.showMoneyNotifications = tempSettingsData.showMoneyNotifications
    LootiConfig.notificationThreshold = tempSettingsData.notificationThreshold
    LootiConfig.scrollDirection = tempSettingsData.scrollDirection
    LootiConfig.displayBackground = tempSettingsData.displayBackground
    LootiConfig.displayDuration = tempSettingsData.displayDuration
    LootiConfig.notificationDelay = tempSettingsData.notificationDelay
    LootiConfig.maximumNotifications = tempSettingsData.maximumNotifications
    LootiConfig.showQuantity = tempSettingsData.showQuantity
    LootiConfig.showIcon = tempSettingsData.showIcon
    print("Looti Settings saved!")
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
    HandleShowIconChange = HandleShowIconChange
}
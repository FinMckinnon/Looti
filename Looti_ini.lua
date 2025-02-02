local defaultConfig = {
    showLootNotifications = true,
    showMoneyNotifications = true,
    notificationThreshold = 3,
    scrollDirection = "up",
    displayBackground = true,
    displayDuration = 1,
    notificationFrameX = 0,
    notificationFrameY = 0,
    notificationDelay = 0.4,
    maximumNotifications = 0
}

LootiNotificationSettings = LootiNotificationSettings or {
    BASE_Y = 0,
    SPACING = -35,
    NOTIFICATION_WIDTH = 300,
    NOTIFICATION_HEIGHT =35,
}

currencyIcons = {
    copper = "Interface\\Icons\\INV_misc_coin_05",  -- Copper
    silver = "Interface\\Icons\\INV_Misc_Coin_03",  -- Silver
    gold = "Interface\\Icons\\INV_Misc_Coin_01"    -- Gold
}

rarityData = {
    [0] = {name = "Poor", color = {GetItemQualityColor(0)}},   
    [1] = {name = "Common", color = {GetItemQualityColor(1)}},  
    [2] = {name = "Uncommon", color = {GetItemQualityColor(2)}},
    [3] = {name = "Rare", color = {GetItemQualityColor(3)}},    
    [4] = {name = "Epic", color = {GetItemQualityColor(4)}},    
    [5] = {name = "Legendary", color = {GetItemQualityColor(5)}}, 
}

local function EnsureDefaults(targetTable, defaultTable)
    if not targetTable then
        targetTable = {}
    end

    for key, value in pairs(defaultTable) do
        if targetTable[key] == nil then
            targetTable[key] = value
        end
    end
    return targetTable
end

local function EnsureLootiSettings()
    LootiConfig = EnsureDefaults(LootiConfig, defaultConfig)
    LootiNotificationSettings = EnsureDefaults(LootiNotificationSettings, defaultConfig)
end

function LootiNotificationSettings:UpdateFrameDimensions()
    self.NOTI_FRAME_WIDTH = self.NOTIFICATION_WIDTH + 20
    self.NOTI_FRAME_HEIGHT = self.NOTIFICATION_HEIGHT * 5
end

LootiNotificationSettings:UpdateFrameDimensions()

_G["EnsureLootiSettings"] = EnsureLootiSettings

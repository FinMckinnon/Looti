LootiConfig = LootiConfig or {
    showLootNotifications = true,  -- Default to true
    showMoneyNotifications = true,  -- Default to true
    notificationThreshold = 3,  -- Default threshold set to 3
    scrollDirection = "up",  -- Default to "up"
    displayBackground = true,  -- Default to true
    displayDuration = 1
}

LootiNotificationSettings = LootiNotificationSettings or {
    BASE_Y = 0,
    SPACING = -35,
    NOTIFICATION_WIDTH = 300,
    NOTIFICATION_HEIGHT = 50,
}

function LootiNotificationSettings:UpdateFrameDimensions()
    self.NOTI_FRAME_WIDTH = self.NOTIFICATION_WIDTH + 20
    self.NOTI_FRAME_HEIGHT = self.NOTIFICATION_HEIGHT * 5
end

LootiNotificationSettings:UpdateFrameDimensions()

lootFlags = {
    [-1] = true,  -- Show currency (for all currencies)
    [0] = true, -- Poor 
    [1] = true,  -- Common 
    [2] = true, -- Uncommon 
    [3] = true, -- Rare 
    [4] = false, -- Epic 
    [5] = false, -- Legendary 
    [6] = false, -- Artifact 
    [7] = false -- Heirloom 
}

currencyIcons = {
    copper = "Interface\\Icons\\INV_Misc_Coin_01",  -- Copper
    silver = "Interface\\Icons\\INV_Misc_Coin_02",  -- Silver
    gold = "Interface\\Icons\\INV_Misc_Coin_03"    -- Gold
}


LootiConfig = LootiConfig or {
    showLootNotifications = true,  -- Default to true
    showMoneyNotifications = true,  -- Default to true
    notificationThreshold = 3,  -- Default threshold set to 3
    scrollDirection = "up",  -- Default to "up"
    displayBackground = true,  -- Default to true
    displayDuration = 1,
    notificationFrameX = 0, 
    notificationFrameY = 0,
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



currencyIcons = {
    copper = "Interface\\Icons\\INV_misc_coin_05",  -- Copper
    silver = "Interface\\Icons\\INV_Misc_Coin_03",  -- Silver
    gold = "Interface\\Icons\\INV_Misc_Coin_01"    -- Gold
}


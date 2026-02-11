AceGUI = LibStub("AceGUI-3.0")
local ADDON_NAME, Looti = ...
_G[ADDON_NAME] = Looti or {}

LootiConfigDefault = {
    showLootNotifications = true,
    showMoneyNotifications = true,
    notificationThreshold = 0,
    scrollDirection = "up",
    displayBackground = true,
    displayDuration = 1,
    notificationFrameX = 0,
    notificationFrameY = 0,
    notificationDelay = 0.4,
    maximumNotifications = 0,
    showQuantity = true,
    showItemLevel = true,
    showItemLevelUpgradeIcon = true,
    showIcon = true,
    showText = true,
    iconSize = 32,
    textDisplay = "CENTER",
    iconDisplay = "LEFT",
    notificationAlpha = 1,
    notificationScale = 1,
    backgroundAlpha = 0.6
}

LootiFiltersDefault = {
    blacklist = {
        items = {
        },
        categories = {
            BoE = false,
            BoP = false,
            QuestItems = false,
            Consumables = false,
            Gear = false,
            CraftingMats = false,
            Miscellaneous = false
        }
    },
    whitelist = {
        items = {
        },
        categories = {
            BoE = false,
            BoP = false,
            QuestItems = false,
            Consumables = false,
            Gear = false,
            CraftingMats = false,
            Miscellaneous = false
        }
    }
}

LootiNotificationSettingsDefault = {
    SPACING = -35,
    NOTIFICATION_FRAME_WIDTH = 300,
    NOTIFICATION_FRAME_HEIGHT = 35,
}

LootiConfig = LootiConfig or LootiConfigDefault
LootiFilters = LootiFilters or LootiFiltersDefault
LootiNotificationSettings = LootiNotificationSettings or LootiNotificationSettingsDefault

currencyIcons = {
    copper = "Interface\\Icons\\INV_misc_coin_05", -- Copper
    silver = "Interface\\Icons\\INV_Misc_Coin_03", -- Silver
    gold = "Interface\\Icons\\INV_Misc_Coin_01"    -- Gold
}

rarityData = {
    [0] = { name = "Poor", color = { GetItemQualityColor(0) } },
    [1] = { name = "Common", color = { GetItemQualityColor(1) } },
    [2] = { name = "Uncommon", color = { GetItemQualityColor(2) } },
    [3] = { name = "Rare", color = { GetItemQualityColor(3) } },
    [4] = { name = "Epic", color = { GetItemQualityColor(4) } },
    [5] = { name = "Legendary", color = { GetItemQualityColor(5) } },
}

local function EnsureDefaults(target, defaults)
    if target == nil then
        target = {}
    end

    for key, defaultValue in pairs(defaults) do
        local targetValue = target[key]

        if type(defaultValue) == "table" then
            if type(targetValue) ~= "table" then
                target[key] = {}
            end
            EnsureDefaults(target[key], defaultValue)
        elseif targetValue == nil then
            target[key] = defaultValue
        end
    end

    return target
end

local function EnsureLootiSettings()
    LootiConfig = EnsureDefaults(LootiConfig, LootiConfigDefault)
    LootiFilters = EnsureDefaults(LootiFilters, LootiFiltersDefault)
    LootiNotificationSettings = EnsureDefaults(LootiNotificationSettings, LootiNotificationSettingsDefault)
end

_G["EnsureLootiSettings"] = EnsureLootiSettings

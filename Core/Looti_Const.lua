-- Fixed tables: frame sizes, equipment slots, item categories and rarity names.
local ADDON, L = ...

L.Const = {}

L.Const.FRAME = {
    NOTIFICATION_WIDTH = 300,
    NOTIFICATION_HEIGHT = 35,
    SPACING = -35,
    PANEL_WIDTH = 480,
    PANEL_HEIGHT = 675,
    EDITOR_WIDTH = 600,
    EDITOR_HEIGHT = 675,
    MARGIN = 5,
}

L.Const.UPGRADE_ICON = "Interface\\AddOns\\Looti\\Media\\green_up_arrow_icon.tga"

L.Const.RARITY_NAMES = {
    [0] = "Poor",
    [1] = "Common",
    [2] = "Uncommon",
    [3] = "Rare",
    [4] = "Epic",
    [5] = "Legendary",
}

-- Equipment slots an item type can occupy. Rings and trinkets have two.
L.Const.EQUIP_SLOTS = {
    INVTYPE_HEAD = { 1 },
    INVTYPE_NECK = { 2 },
    INVTYPE_SHOULDER = { 3 },
    INVTYPE_BODY = { 4 },
    INVTYPE_CHEST = { 5 },
    INVTYPE_ROBE = { 5 },
    INVTYPE_WAIST = { 6 },
    INVTYPE_LEGS = { 7 },
    INVTYPE_FEET = { 8 },
    INVTYPE_WRIST = { 9 },
    INVTYPE_HAND = { 10 },
    INVTYPE_FINGER = { 11, 12 },
    INVTYPE_TRINKET = { 13, 14 },
    INVTYPE_CLOAK = { 15 },
    INVTYPE_WEAPON = { 16 },
    INVTYPE_SHIELD = { 17 },
    INVTYPE_2HWEAPON = { 16 },
    INVTYPE_WEAPONMAINHAND = { 16 },
    INVTYPE_WEAPONOFFHAND = { 17 },
    INVTYPE_HOLDABLE = { 17 },
    INVTYPE_RANGED = { 16 },
    INVTYPE_THROWN = { 16 },
    INVTYPE_RANGEDRIGHT = { 16 },
    INVTYPE_RELIC = { 16 },
}

-- classID values the filter categories match on.
L.Const.CLASS_CONSUMABLE = 0
L.Const.CLASS_GEM = 3
L.Const.CLASS_TRADE_GOODS = 7
L.Const.CLASS_RECIPE = 9
L.Const.CLASS_KEY = 13
L.Const.CLASS_MISC = 15
L.Const.CLASS_GLYPH = 16
L.Const.CLASS_TOKEN = 18
L.Const.CLASS_PROFESSION = 19

-- bindType values the filter categories match on.
L.Const.BIND_ON_EQUIP = 1
L.Const.BIND_ON_PICKUP = 2
L.Const.BIND_QUEST = 4

L.Const.CATEGORY_LABELS = {
    BoE = "Bind on Equip",
    BoP = "Bind on Pickup",
    QuestItems = "Quest items",
    Consumables = "Consumables",
    Gear = "Gear",
    CraftingMats = "Crafting materials",
    Miscellaneous = "Miscellaneous",
}

-- Order the categories are listed in, so the filter editor is stable.
L.Const.CATEGORY_ORDER = {
    "BoE", "BoP", "QuestItems", "Consumables", "CraftingMats", "Gear", "Miscellaneous",
}

L.Const.FILTER_LISTS = { "whitelist", "blacklist", "watchlist" }

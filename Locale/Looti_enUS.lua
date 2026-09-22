-- Every piece of text Looti shows the player.
local ADDON, L = ...

-- To translate, copy this file to Looti_<locale>.lua, list it after this one in
-- the .toc, and open it with a guard so it only overwrites the keys it changes:
--     if GetLocale() ~= "deDE" then return end
--     local ADDON, L = ...
--     L.Text.BUTTON_SAVE = "Speichern"
-- Anything a translation omits falls back to the English below.
L.Text = {
    -- Windows
    ADDON_NAME = "Looti",
    SETTINGS_SUBTITLE = "Loot notification settings",
    ANCHOR_TITLE = "Loot Notifications",

    -- Buttons
    BUTTON_SAVE = "Save",
    BUTTON_CANCEL = "Cancel",
    BUTTON_YES = "Yes",
    BUTTON_TEST = "Test Looti",
    BUTTON_EDIT = "Edit...",
    BUTTON_ADD = "Add",
    BUTTON_REMOVE = "Remove",
    BUTTON_MOVE_ANCHOR = "Move notification area",
    BUTTON_RESET = "Reset all settings...",

    -- Chat messages
    MSG_SAVED = "Looti settings saved.",
    MSG_RESET = "Looti has been reset.",
    MSG_LIST_SAVED = "%s saved.",
    MSG_BAD_ITEM = "That is not an item id or an item link.",
    MSG_UPGRADED = "Looti has changed how it stores settings, so yours are back at "
        .. "their defaults. Your filter lists have been kept. Type /looti to set "
        .. "things up again.",

    -- Notification contents
    ITEM_LEVEL = "(Lvl %d)",

    -- Tabs
    TAB_GENERAL = "General",
    TAB_CONTENT = "Content",
    TAB_LAYOUT = "Layout",
    TAB_TIMING = "Timing",
    TAB_FILTERS = "Filters",

    -- Setting groups and the line under each heading
    GROUP_NOTIFICATIONS = "Notifications",
    HINT_NOTIFICATIONS = "Which alerts Looti shows.",
    GROUP_MINIMUM_RARITY = "Minimum rarity",
    HINT_MINIMUM_RARITY = "Hide loot below this quality. Whitelisted items always show.",
    GROUP_RESET = "Reset",
    HINT_RESET = "Every setting and filter list back to default. Asks first.",
    GROUP_EACH_SHOWS = "Each notification shows",
    HINT_EACH_SHOWS = "Turn off anything you do not want in the line.",
    GROUP_ICON_SIZE = "Icon size",
    HINT_ICON_SIZE = "Notification height follows it.",
    GROUP_POSITION = "Position",
    HINT_POSITION = "Where notifications appear on screen.",
    GROUP_ALIGNMENT = "Alignment",
    HINT_ALIGNMENT = "Inside each notification.",
    GROUP_BACKGROUND = "Background",
    HINT_BACKGROUND = "A dark panel behind each notification.",
    GROUP_APPEARANCE = "Size and transparency",
    HINT_APPEARANCE = "Of the whole notification.",
    GROUP_ON_SCREEN = "On screen",
    HINT_ON_SCREEN = "How long each notification stays before it fades.",
    GROUP_QUEUE = "Queue",
    HINT_QUEUE = "When several items arrive at once.",

    -- Setting labels
    LABEL_LOOT_NOTIFICATIONS = "Loot notifications",
    LABEL_MONEY_NOTIFICATIONS = "Money notifications",
    LABEL_MINIMUM_RARITY = "Minimum rarity",
    LABEL_ITEM_ICON = "Item icon",
    LABEL_ITEM_NAME = "Item name",
    LABEL_QUANTITY = "Quantity (x2, x3, ...)",
    LABEL_ITEM_LEVEL = "Item level",
    LABEL_UPGRADE_ARROW = "Upgrade arrow when better than equipped",
    LABEL_ICON_SIZE = "Icon size",
    LABEL_NEW_ALERTS = "New alerts appear",
    LABEL_ICON = "Icon",
    LABEL_TEXT = "Text",
    LABEL_SHOW_BACKGROUND = "Show background",
    LABEL_BACKGROUND_OPACITY = "Background opacity",
    LABEL_SCALE = "Scale",
    LABEL_OPACITY = "Opacity",
    LABEL_DURATION = "Duration",
    LABEL_DELAY = "Delay between notifications",
    LABEL_MOST_ON_SCREEN = "Most on screen at once",

    -- Dropdown options and special slider values
    OPTION_ABOVE_LAST = "Above the last one",
    OPTION_BELOW_LAST = "Below the last one",
    OPTION_LEFT = "Left",
    OPTION_CENTER = "Center",
    OPTION_RIGHT = "Right",
    VALUE_NO_LIMIT = "No limit",
    UNIT_PIXELS = " px",
    UNIT_SECONDS = " s",

    -- Filter lists
    LIST_WHITELIST = "Whitelist",
    LIST_BLACKLIST = "Blacklist",
    LIST_WATCHLIST = "Watchlist",
    HINT_WHITELIST = "Always notify, even below the minimum rarity.",
    HINT_BLACKLIST = "Never notify.",
    HINT_WATCHLIST = "An extra alert for items you are waiting on.",
    HINT_WATCHLIST_SOON = "An extra alert for items you are waiting on. Coming later.",
    FILTER_SUMMARY = "%d items \194\183 %d categories",

    -- Filter editor
    GROUP_ADD_ITEM = "Add an item",
    HINT_ADD_ITEM = "Paste an item link or type its id.",
    GROUP_CATEGORIES = "Categories",
    HINT_CATEGORIES = "Whole groups of items, in one go.",
    GROUP_ITEMS = "Items",
    HINT_ITEMS = "Individual items, by id.",
    ITEMS_EMPTY = "No items in this list yet.",

    -- Reset confirmation
    RESET_TITLE = "Reset Looti",
    RESET_MESSAGE = "Every setting and filter list goes back to its default.",

    -- Item rarities
    RARITY_POOR = "Poor",
    RARITY_COMMON = "Common",
    RARITY_UNCOMMON = "Uncommon",
    RARITY_RARE = "Rare",
    RARITY_EPIC = "Epic",
    RARITY_LEGENDARY = "Legendary",

    -- Filter categories
    CATEGORY_BOE = "Bind on Equip",
    CATEGORY_BOP = "Bind on Pickup",
    CATEGORY_QUEST = "Quest items",
    CATEGORY_CONSUMABLES = "Consumables",
    CATEGORY_GEAR = "Gear",
    CATEGORY_CRAFTING = "Crafting materials",
    CATEGORY_MISC = "Miscellaneous",
}

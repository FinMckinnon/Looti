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
    ANCHOR_TITLE = "Loot Notifications",

    -- Buttons
    BUTTON_SAVE = "Save",
    BUTTON_CANCEL = "Cancel",
    BUTTON_CLOSE = "Close",
    BUTTON_YES = "Yes",
    BUTTON_TEST = "Test Looti",
    BUTTON_EDIT = "Edit...",
    BUTTON_ADD = "Add",
    BUTTON_REMOVE = "Remove",
    BUTTON_MOVE_ANCHOR = "Move notification area",
    BUTTON_RESET = "Reset all settings...",
    BUTTON_RESET_POSITION = "Reset position",

    -- Chat messages
    MSG_SAVED = "Looti settings saved.",
    MSG_RESET = "Looti has been reset.",
    MSG_POSITION_RESET = "Notifications are back in their default position.",
    MSG_LIST_SAVED = "%s saved.",
    MSG_BAD_ITEM = "Could not find that item. Names only work for items your client has seen, "
        .. "such as ones in your bags. Otherwise shift-click the item or use its id.",
    MSG_UPGRADED = "Looti has changed how it stores settings, so yours are back at "
        .. "their defaults. Your filter lists have been kept. Type /looti to set "
        .. "things up again.",

    -- Notification contents
    ITEM_LEVEL = "(Lvl %d)",
    BAG_COUNT = "(%d)",

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
    HINT_MINIMUM_RARITY = "Hide loot below this quality. Whitelisted and watched items "
        .. "always show.",
    GROUP_RESET = "Reset",
    HINT_RESET = "Reset all settings or notification position.",
    GROUP_EACH_SHOWS = "Each notification shows",
    HINT_EACH_SHOWS = "Turn off anything you do not want in the line.",
    GROUP_ICON = "Icon",
    GROUP_TEXT = "Text",
    GROUP_POSITION = "Position",
    HINT_POSITION = "Where notifications appear on screen.",
    GROUP_ALIGNMENT = "Alignment",
    HINT_ALIGNMENT = "Inside each notification.",
    GROUP_BACKGROUND = "Background",
    HINT_BACKGROUND = "A dark panel behind each notification.",
    GROUP_APPEARANCE = "Size and transparency",
    GROUP_ON_SCREEN = "On screen",
    HINT_ON_SCREEN = "How long each notification stays before it fades.",
    GROUP_MOUSEOVER = "Mouseover",
    HINT_MOUSEOVER = "When the mouse is over a notification.",
    GROUP_QUEUE = "Queue",
    HINT_QUEUE = "When several items arrive at once.",

    -- Setting labels
    LABEL_LOOT_NOTIFICATIONS = "Loot notifications",
    LABEL_MONEY_NOTIFICATIONS = "Money notifications",
    LABEL_CURRENCY_NOTIFICATIONS = "Currency notifications",
    LABEL_PUSHED_ITEMS = "Bought and rewarded items (\"You receive item\")",
    LABEL_CRAFTED_ITEMS = "Crafted items (\"You create\")",
    LABEL_MINIMUM_RARITY = "Minimum rarity",
    LABEL_ITEM_ICON = "Item icon",
    LABEL_ITEM_NAME = "Item name",
    LABEL_RARITY_COLOUR = "Item name in its rarity colour (off: white)",
    LABEL_QUANTITY = "Quantity (x2, x3, ...)",
    LABEL_ITEM_LEVEL = "Item level",
    LABEL_UPGRADE_ARROW = "Upgrade arrow when better than equipped",
    LABEL_BAG_COUNT = "Amount in your bags (Copper Ore (12))",
    LABEL_CRAFTING_QUALITY = "Crafting quality icon (Retail)",
    LABEL_ICON_SIZE = "Icon size",
    LABEL_ICON_ZOOM = "Hide Blizzard icon borders",
    LABEL_TEXT_OUTLINE = "Text outline",
    LABEL_SHOW_TOOLTIP = "Show the item tooltip on mouseover",
    LABEL_PAUSE_ON_HOVER = "Freeze all notifications and hold new ones back",
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
    LABEL_WATCH_SOUND = "Play a sound",
    LABEL_WATCH_STAR = "Star beside the item",
    LABEL_WATCH_HIGHLIGHT = "Highlight the notification",

    -- Dropdown options and special slider values
    OPTION_ABOVE_LAST = "Above the last one",
    OPTION_BELOW_LAST = "Below the last one",
    OPTION_LEFT = "Left",
    OPTION_CENTER = "Centre",
    OPTION_RIGHT = "Right",
    OPTION_NONE = "None",
    OPTION_OUTLINE = "Outline",
    OPTION_THICK_OUTLINE = "Thick outline",
    VALUE_NO_LIMIT = "No limit",
    UNIT_PIXELS = " px",
    UNIT_SECONDS = " s",

    -- Filter lists
    LIST_WHITELIST = "Whitelist",
    LIST_BLACKLIST = "Blacklist",
    LIST_WATCHLIST = "Watchlist",
    HINT_WHITELIST = "Always notify, even below the minimum rarity.",
    HINT_BLACKLIST = "Never notify.",
    HINT_WATCHLIST = "Always shows with extra alerts.",
    FILTER_SUMMARY = "%d items \194\183 %d categories",

    -- Filter editor
    GROUP_ADD_ITEM = "Add an item",
    HINT_ADD_ITEM = "Click in the box and shift-click one or more items from your bags or chat, "
        .. "or type one id or exact name, then press Add.",
    GROUP_CATEGORIES = "Categories",
    HINT_CATEGORIES = "Whole groups of items, in one go.",
    GROUP_ITEMS = "Items",
    HINT_ITEMS = "Individual items, by id.",
    ITEMS_EMPTY = "No items in this list yet.",

    -- Reset confirmation
    RESET_TITLE = "Reset Looti",
    RESET_MESSAGE = "Every setting and filter list goes back to its default.",

    -- Filter categories
    CATEGORY_BOE = "Bind on Equip",
    CATEGORY_BOP = "Bind on Pickup",
    CATEGORY_QUEST = "Quest items",
    CATEGORY_CONSUMABLES = "Consumables",
    CATEGORY_GEAR = "Gear",
    CATEGORY_CRAFTING = "Crafting materials",
    CATEGORY_MISC = "Miscellaneous",
}

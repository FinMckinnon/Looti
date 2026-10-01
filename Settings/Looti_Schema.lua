-- Every configurable setting, described as data.
local ADDON, L = ...

-- key       matches a LootiConfig key exactly
-- type      "toggle", "range", "select", "action" or "filterlist"
-- tab       which tab the entry appears on
-- group     section heading; a change of value opens a new section
-- hint      muted line under the section heading, on the first entry of a group
-- label     text shown beside the widget
-- min/max/step   range only
-- unit      range only, appended to the value in the label
-- zeroLabel range only, shown in place of a value of zero
-- rarity    range only, the value is an item rarity; its coloured name shows under the slider
-- options/order  select only
-- enabledBy the key of a toggle that must be on for this to be usable
-- action    action only, the name of a handler in L.Actions
-- width     action only, the button's share of the row from 0 to 1; full row if unset
-- list      filterlist only, which filter list the entry summarises and edits
L.Schema = {
    { key = "showLootNotifications", type = "toggle", tab = "general",
      group = L.Text.GROUP_NOTIFICATIONS, hint = L.Text.HINT_NOTIFICATIONS,
      label = L.Text.LABEL_LOOT_NOTIFICATIONS },
    { key = "showMoneyNotifications", type = "toggle", tab = "general",
      group = L.Text.GROUP_NOTIFICATIONS, label = L.Text.LABEL_MONEY_NOTIFICATIONS },
    { key = "showCurrencyNotifications", type = "toggle", tab = "general",
      group = L.Text.GROUP_NOTIFICATIONS, label = L.Text.LABEL_CURRENCY_NOTIFICATIONS },
    { key = "showPushedItems", type = "toggle", tab = "general",
      group = L.Text.GROUP_NOTIFICATIONS, label = L.Text.LABEL_PUSHED_ITEMS },
    { key = "showCraftedItems", type = "toggle", tab = "general",
      group = L.Text.GROUP_NOTIFICATIONS, label = L.Text.LABEL_CRAFTED_ITEMS },

    { key = "notificationThreshold", type = "range", tab = "general",
      group = L.Text.GROUP_MINIMUM_RARITY,
      hint = L.Text.HINT_MINIMUM_RARITY,
      label = L.Text.LABEL_MINIMUM_RARITY, min = 0, max = 5, step = 1, rarity = true },

    { type = "action", tab = "general",
      group = L.Text.GROUP_RESET,
      hint = L.Text.HINT_RESET,
      label = L.Text.BUTTON_RESET, action = "resetAll", width = 0.5 },
    { type = "action", tab = "general",
      group = L.Text.GROUP_RESET,
      label = L.Text.BUTTON_RESET_POSITION, action = "resetPosition", width = 0.5 },

    { key = "showIcon", type = "toggle", tab = "content",
      group = L.Text.GROUP_EACH_SHOWS,
      hint = L.Text.HINT_EACH_SHOWS,
      label = L.Text.LABEL_ITEM_ICON },
    { key = "showText", type = "toggle", tab = "content",
      group = L.Text.GROUP_EACH_SHOWS, label = L.Text.LABEL_ITEM_NAME },
    { key = "colourByRarity", type = "toggle", tab = "content",
      group = L.Text.GROUP_EACH_SHOWS, label = L.Text.LABEL_RARITY_COLOUR, enabledBy = "showText" },
    { key = "showQuantity", type = "toggle", tab = "content",
      group = L.Text.GROUP_EACH_SHOWS, label = L.Text.LABEL_QUANTITY },
    { key = "showItemLevel", type = "toggle", tab = "content",
      group = L.Text.GROUP_EACH_SHOWS, label = L.Text.LABEL_ITEM_LEVEL },
    { key = "showItemLevelUpgradeIcon", type = "toggle", tab = "content",
      group = L.Text.GROUP_EACH_SHOWS, label = L.Text.LABEL_UPGRADE_ARROW },

    { key = "iconSize", type = "range", tab = "content",
      group = L.Text.GROUP_ICON_SIZE,
      label = L.Text.LABEL_ICON_SIZE, min = 12, max = 64, step = 2, unit = L.Text.UNIT_PIXELS },

    { type = "action", tab = "layout",
      group = L.Text.GROUP_POSITION, hint = L.Text.HINT_POSITION,
      label = L.Text.BUTTON_MOVE_ANCHOR, action = "moveAnchor" },
    { key = "scrollDirection", type = "select", tab = "layout",
      group = L.Text.GROUP_POSITION, label = L.Text.LABEL_NEW_ALERTS,
      options = { up = L.Text.OPTION_ABOVE_LAST, down = L.Text.OPTION_BELOW_LAST },
      order = { "up", "down" } },

    { key = "iconDisplay", type = "select", tab = "layout",
      group = L.Text.GROUP_ALIGNMENT, hint = L.Text.HINT_ALIGNMENT,
      label = L.Text.LABEL_ICON, options = { LEFT = L.Text.OPTION_LEFT, RIGHT = L.Text.OPTION_RIGHT },
      order = { "LEFT", "RIGHT" } },
    { key = "textDisplay", type = "select", tab = "layout",
      group = L.Text.GROUP_ALIGNMENT, label = L.Text.LABEL_TEXT,
      options = { LEFT = L.Text.OPTION_LEFT, CENTER = L.Text.OPTION_CENTER, RIGHT = L.Text.OPTION_RIGHT },
      order = { "LEFT", "CENTER", "RIGHT" } },

    { key = "displayBackground", type = "toggle", tab = "layout",
      group = L.Text.GROUP_BACKGROUND, hint = L.Text.HINT_BACKGROUND,
      label = L.Text.LABEL_SHOW_BACKGROUND },
    { key = "backgroundAlpha", type = "range", tab = "layout",
      group = L.Text.GROUP_BACKGROUND, label = L.Text.LABEL_BACKGROUND_OPACITY,
      min = 0, max = 1, step = 0.1, enabledBy = "displayBackground" },

    { key = "notificationScale", type = "range", tab = "layout",
      group = L.Text.GROUP_APPEARANCE,
      label = L.Text.LABEL_SCALE, min = 0.5, max = 2, step = 0.1 },
    { key = "notificationAlpha", type = "range", tab = "layout",
      group = L.Text.GROUP_APPEARANCE, label = L.Text.LABEL_OPACITY,
      min = 0, max = 1, step = 0.1 },

    { key = "displayDuration", type = "range", tab = "timing",
      group = L.Text.GROUP_ON_SCREEN, hint = L.Text.HINT_ON_SCREEN,
      label = L.Text.LABEL_DURATION, min = 0.5, max = 5, step = 0.5, unit = L.Text.UNIT_SECONDS },

    { key = "notificationDelay", type = "range", tab = "timing",
      group = L.Text.GROUP_QUEUE, hint = L.Text.HINT_QUEUE,
      label = L.Text.LABEL_DELAY, min = 0, max = 1, step = 0.1, unit = L.Text.UNIT_SECONDS },
    { key = "maximumNotifications", type = "range", tab = "timing",
      group = L.Text.GROUP_QUEUE, label = L.Text.LABEL_MOST_ON_SCREEN,
      min = 0, max = 10, step = 1, zeroLabel = L.Text.VALUE_NO_LIMIT },

    { type = "filterlist", tab = "filters", list = "whitelist",
      group = L.Text.LIST_WHITELIST, hint = L.Text.HINT_WHITELIST },

    { type = "filterlist", tab = "filters", list = "blacklist",
      group = L.Text.LIST_BLACKLIST, hint = L.Text.HINT_BLACKLIST },

    { type = "filterlist", tab = "filters", list = "watchlist",
      group = L.Text.LIST_WATCHLIST, hint = L.Text.HINT_WATCHLIST },
    { key = "watchlistSound", type = "toggle", tab = "filters",
      group = L.Text.LIST_WATCHLIST, label = L.Text.LABEL_WATCH_SOUND },
    { key = "watchlistStar", type = "toggle", tab = "filters",
      group = L.Text.LIST_WATCHLIST, label = L.Text.LABEL_WATCH_STAR },
    { key = "watchlistHighlight", type = "toggle", tab = "filters",
      group = L.Text.LIST_WATCHLIST, label = L.Text.LABEL_WATCH_HIGHLIGHT },
}

-- Tabs in the order they appear.
L.SchemaTabs = {
    { value = "general", text = L.Text.TAB_GENERAL },
    { value = "content", text = L.Text.TAB_CONTENT },
    { value = "layout", text = L.Text.TAB_LAYOUT },
    { value = "timing", text = L.Text.TAB_TIMING },
    { value = "filters", text = L.Text.TAB_FILTERS },
}

-- input: nothing
-- output: a list of every settings key the panel can edit
-- Lists the config keys the schema covers.
function L.SchemaKeys()
    local keys = {}

    for _, entry in ipairs(L.Schema) do
        if entry.key then
            keys[#keys + 1] = entry.key
        end
    end

    return keys
end

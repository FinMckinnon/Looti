-- Every configurable setting, described as data.
local ADDON, L = ...

-- key       matches a LootiConfig key exactly
-- type      "toggle", "range", "select" or "action"
-- tab       which tab the entry appears on
-- group     section heading; a change of value opens a new section
-- hint      muted line under the section heading, on the first entry of a group
-- label     text shown beside the widget
-- min/max/step   range only
-- unit      range only, appended to the value in the label
-- zeroLabel range only, shown in place of a value of zero
-- names     range only, value to name mapping shown beside the number
-- options/order  select only
-- enabledBy the key of a toggle that must be on for this to be usable
-- action    action only, the name of a handler in L.Actions
L.Schema = {
    { key = "showLootNotifications", type = "toggle", tab = "general",
      group = L.Text.GROUP_NOTIFICATIONS, hint = L.Text.HINT_NOTIFICATIONS,
      label = L.Text.LABEL_LOOT_NOTIFICATIONS },
    { key = "showMoneyNotifications", type = "toggle", tab = "general",
      group = L.Text.GROUP_NOTIFICATIONS, label = L.Text.LABEL_MONEY_NOTIFICATIONS },

    { key = "notificationThreshold", type = "range", tab = "general",
      group = L.Text.GROUP_MINIMUM_RARITY,
      hint = L.Text.HINT_MINIMUM_RARITY,
      label = L.Text.LABEL_MINIMUM_RARITY, min = 0, max = 5, step = 1,
      names = L.Const.RARITY_NAMES },

    { type = "action", tab = "general",
      group = L.Text.GROUP_RESET,
      hint = L.Text.HINT_RESET,
      label = L.Text.BUTTON_RESET, action = "resetAll" },

    { key = "showIcon", type = "toggle", tab = "content",
      group = L.Text.GROUP_EACH_SHOWS,
      hint = L.Text.HINT_EACH_SHOWS,
      label = L.Text.LABEL_ITEM_ICON },
    { key = "showText", type = "toggle", tab = "content",
      group = L.Text.GROUP_EACH_SHOWS, label = L.Text.LABEL_ITEM_NAME },
    { key = "showQuantity", type = "toggle", tab = "content",
      group = L.Text.GROUP_EACH_SHOWS, label = L.Text.LABEL_QUANTITY },
    { key = "showItemLevel", type = "toggle", tab = "content",
      group = L.Text.GROUP_EACH_SHOWS, label = L.Text.LABEL_ITEM_LEVEL },
    { key = "showItemLevelUpgradeIcon", type = "toggle", tab = "content",
      group = L.Text.GROUP_EACH_SHOWS, label = L.Text.LABEL_UPGRADE_ARROW },

    { key = "iconSize", type = "range", tab = "content",
      group = L.Text.GROUP_ICON_SIZE, hint = L.Text.HINT_ICON_SIZE,
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
      group = L.Text.GROUP_APPEARANCE, hint = L.Text.HINT_APPEARANCE,
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
}

-- Tabs in the order they appear. The filters tab is built by hand rather than
-- from the schema, because it lists filter lists instead of settings.
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

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
      group = "Notifications", hint = "Which alerts Looti shows.",
      label = "Loot notifications" },
    { key = "showMoneyNotifications", type = "toggle", tab = "general",
      group = "Notifications", label = "Money notifications" },

    { key = "notificationThreshold", type = "range", tab = "general",
      group = "Minimum rarity",
      hint = "Hide loot below this quality. Whitelisted items always show.",
      label = "Minimum rarity", min = 0, max = 5, step = 1,
      names = L.Const.RARITY_NAMES },

    { type = "action", tab = "general",
      group = "Reset",
      hint = "Every setting and filter list back to default. Asks first.",
      label = "Reset all settings...", action = "resetAll" },

    { key = "showIcon", type = "toggle", tab = "content",
      group = "Each notification shows",
      hint = "Turn off anything you do not want in the line.",
      label = "Item icon" },
    { key = "showText", type = "toggle", tab = "content",
      group = "Each notification shows", label = "Item name" },
    { key = "showQuantity", type = "toggle", tab = "content",
      group = "Each notification shows", label = "Quantity (x2, x3, ...)" },
    { key = "showItemLevel", type = "toggle", tab = "content",
      group = "Each notification shows", label = "Item level" },
    { key = "showItemLevelUpgradeIcon", type = "toggle", tab = "content",
      group = "Each notification shows", label = "Upgrade arrow when better than equipped" },

    { key = "iconSize", type = "range", tab = "content",
      group = "Icon size", hint = "Notification height follows it.",
      label = "Icon size", min = 12, max = 64, step = 2, unit = " px" },

    { type = "action", tab = "layout",
      group = "Position", hint = "Where notifications appear on screen.",
      label = "Move notification area", action = "moveAnchor" },
    { key = "scrollDirection", type = "select", tab = "layout",
      group = "Position", label = "New alerts appear",
      options = { up = "Above the last one", down = "Below the last one" },
      order = { "up", "down" } },

    { key = "iconDisplay", type = "select", tab = "layout",
      group = "Alignment", hint = "Inside each notification.",
      label = "Icon", options = { LEFT = "Left", RIGHT = "Right" },
      order = { "LEFT", "RIGHT" } },
    { key = "textDisplay", type = "select", tab = "layout",
      group = "Alignment", label = "Text",
      options = { LEFT = "Left", CENTER = "Center", RIGHT = "Right" },
      order = { "LEFT", "CENTER", "RIGHT" } },

    { key = "displayBackground", type = "toggle", tab = "layout",
      group = "Background", hint = "A dark panel behind each notification.",
      label = "Show background" },
    { key = "backgroundAlpha", type = "range", tab = "layout",
      group = "Background", label = "Background opacity",
      min = 0, max = 1, step = 0.1, enabledBy = "displayBackground" },

    { key = "notificationScale", type = "range", tab = "layout",
      group = "Size and transparency", hint = "Of the whole notification.",
      label = "Scale", min = 0.5, max = 2, step = 0.1 },
    { key = "notificationAlpha", type = "range", tab = "layout",
      group = "Size and transparency", label = "Opacity",
      min = 0, max = 1, step = 0.1 },

    { key = "displayDuration", type = "range", tab = "timing",
      group = "On screen", hint = "How long each notification stays before it fades.",
      label = "Duration", min = 0.5, max = 5, step = 0.5, unit = " s" },

    { key = "notificationDelay", type = "range", tab = "timing",
      group = "Queue", hint = "When several items arrive at once.",
      label = "Delay between notifications", min = 0, max = 1, step = 0.1, unit = " s" },
    { key = "maximumNotifications", type = "range", tab = "timing",
      group = "Queue", label = "Most on screen at once",
      min = 0, max = 10, step = 1, zeroLabel = "No limit" },
}

-- Tabs in the order they appear. The filters tab is built by hand rather than
-- from the schema, because it lists filter lists instead of settings.
L.SchemaTabs = {
    { value = "general", text = "General" },
    { value = "content", text = "Content" },
    { value = "layout", text = "Layout" },
    { value = "timing", text = "Timing" },
    { value = "filters", text = "Filters" },
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

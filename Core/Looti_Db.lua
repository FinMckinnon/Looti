-- Saved variable defaults, first-run seeding and reset.
local ADDON, L = ...

L.Db = {}

L.Db.ConfigDefault = {
    showLootNotifications = true,
    showMoneyNotifications = true,
    notificationThreshold = 0,
    showText = true,
    showIcon = true,
    showQuantity = true,
    showItemLevel = true,
    showItemLevelUpgradeIcon = true,
    iconSize = 32,
    textDisplay = "CENTER",
    iconDisplay = "LEFT",
    scrollDirection = "up",
    displayBackground = true,
    backgroundAlpha = 0.6,
    notificationAlpha = 1,
    notificationScale = 1,
    displayDuration = 1,
    notificationDelay = 0.4,
    maximumNotifications = 0,
    notificationFrameX = 0,
    notificationFrameY = 0,
    -- Reserved for features that are not built yet, see Features/Looti_Stubs.lua.
    watchlistEnabled = false,
    sessionTrackerEnabled = false,
}

-- Position is state the mover owns, not a setting the panel edits.
L.Db.POSITION_KEYS = {
    notificationFrameX = true,
    notificationFrameY = true,
}

-- input: nothing
-- output: an empty filter list table
-- Builds one filter list with every category switched off.
local function NewFilterList()
    return {
        items = {},
        categories = {
            BoE = false,
            BoP = false,
            QuestItems = false,
            Consumables = false,
            Gear = false,
            CraftingMats = false,
            Miscellaneous = false,
        },
    }
end

-- input: nothing
-- output: a table holding every filter list
-- Builds the whitelist, blacklist and watchlist from one shape.
function L.Db.NewFilters()
    local filters = {}

    for _, listType in ipairs(L.Const.FILTER_LISTS) do
        filters[listType] = NewFilterList()
    end

    return filters
end

-- input: nothing
-- output: nothing
-- Gives the saved variables their own tables and fills in missing keys.
function L.Db.Load()
    LootiConfig = L.Util.ApplyDefaults(LootiConfig, L.Db.ConfigDefault)
    LootiFilters = L.Util.ApplyDefaults(LootiFilters, L.Db.NewFilters())
end

-- input: nothing
-- output: nothing
-- Restores every setting and filter list to its default.
function L.Db.Reset()
    L.Util.ReplaceContents(LootiConfig, L.Db.ConfigDefault)
    L.Util.ReplaceContents(LootiFilters, L.Db.NewFilters())
end

-- input: a filter list name and an item id
-- output: nothing
-- Adds an item to one filter list.
function L.Db.AddFilterItem(listType, itemID)
    local list = LootiFilters[listType]
    if list then
        list.items[itemID] = true
    end
end

-- input: a filter list name and an item id
-- output: nothing
-- Removes an item from one filter list.
function L.Db.RemoveFilterItem(listType, itemID)
    local list = LootiFilters[listType]
    if list then
        list.items[itemID] = nil
    end
end

-- input: a filter list name
-- output: the number of items and the number of enabled categories
-- Counts what one filter list currently holds.
function L.Db.CountFilter(listType)
    local list = LootiFilters[listType]
    if not list then
        return 0, 0
    end

    local items = 0
    for _ in pairs(list.items) do
        items = items + 1
    end

    local categories = 0
    for _, enabled in pairs(list.categories) do
        if enabled then
            categories = categories + 1
        end
    end

    return items, categories
end

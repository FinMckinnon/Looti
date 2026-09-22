-- Saved variable defaults, first-run seeding and reset.
local ADDON, L = ...

L.Db = {}

-- Raised only when a release changes the saved variables in a way that older
-- data cannot satisfy. RESET_BELOW is the version under which stored data is
-- discarded; raising SCHEMA_VERSION alone just re-stamps and keeps settings.
L.Db.SCHEMA_VERSION = 2
L.Db.RESET_BELOW = 2

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
    schemaVersion = 0,
    -- Reserved for features that are not built yet, see Features/Looti_Stubs.lua.
    watchlistEnabled = false,
    sessionTrackerEnabled = false,
}

-- Saved values the settings panel does not own: position belongs to the mover,
-- and the schema version belongs to the upgrade check.
L.Db.INTERNAL_KEYS = {
    notificationFrameX = true,
    notificationFrameY = true,
    schemaVersion = true,
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
-- output: true when stored data was discarded as too old
-- Gives the saved variables their own tables, upgrading them when needed.
function L.Db.Load()
    local freshInstall = LootiConfig == nil
    local stored = (not freshInstall) and LootiConfig.schemaVersion or nil
    local tooOld = (not freshInstall) and (not stored or stored < L.Db.RESET_BELOW)

    LootiConfig = L.Util.ApplyDefaults(LootiConfig, L.Db.ConfigDefault)
    LootiFilters = L.Util.ApplyDefaults(LootiFilters, L.Db.NewFilters())

    if tooOld then
        -- Settings only. Filter lists are hand-curated and survive the upgrade.
        L.Db.ResetSettings()
    end

    LootiConfig.schemaVersion = L.Db.SCHEMA_VERSION

    return tooOld and true or false
end

-- input: nothing
-- output: nothing
-- Restores every setting to its default, leaving the filter lists alone.
function L.Db.ResetSettings()
    local x, y = LootiConfig.notificationFrameX, LootiConfig.notificationFrameY

    L.Util.ReplaceContents(LootiConfig, L.Db.ConfigDefault)

    LootiConfig.notificationFrameX = x
    LootiConfig.notificationFrameY = y
    LootiConfig.schemaVersion = L.Db.SCHEMA_VERSION
end

-- input: nothing
-- output: nothing
-- Restores every setting and every filter list to its default.
function L.Db.Reset()
    L.Util.ReplaceContents(LootiConfig, L.Db.ConfigDefault)
    L.Util.ReplaceContents(LootiFilters, L.Db.NewFilters())

    LootiConfig.schemaVersion = L.Db.SCHEMA_VERSION
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

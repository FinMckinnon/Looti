-- Decides whether an item passes the rarity threshold and the filter lists.
local ADDON, L = ...

L.Filter = {}

-- input: a category table, a class id, a bind type and an equip location
-- output: true when the item falls into an enabled category
-- Tests one item against the enabled categories of a filter list.
local function MatchesCategory(categories, classID, bindType, equipLoc)
    local const = L.Const

    if categories.QuestItems and (bindType == const.BIND_QUEST or classID == const.CLASS_KEY) then
        return true
    end

    if categories.Consumables and classID == const.CLASS_CONSUMABLE then
        return true
    end

    if categories.Gear and equipLoc and equipLoc ~= "" and not equipLoc:match("^INVTYPE_NON_EQUIP") then
        return true
    end

    if categories.CraftingMats then
        local crafting = classID == const.CLASS_TRADE_GOODS
            or classID == const.CLASS_GEM
            or classID == const.CLASS_RECIPE
            or classID == const.CLASS_GLYPH
            or classID == const.CLASS_PROFESSION
        if crafting then
            return true
        end
    end

    if categories.Miscellaneous and (classID == const.CLASS_MISC or classID == const.CLASS_TOKEN) then
        return true
    end

    if categories.BoE and bindType == const.BIND_ON_EQUIP then
        return true
    end

    if categories.BoP and bindType == const.BIND_ON_PICKUP then
        return true
    end

    return false
end

-- input: a filter list name and an item's id, class id, bind type and equip location
-- output: true when the item is in that list
-- Tests one item against a named filter list.
function L.Filter.InList(listType, itemID, classID, bindType, equipLoc)
    local list = LootiFilters[listType]
    if not list then
        return false
    end

    if list.items[itemID] then
        return true
    end

    return MatchesCategory(list.categories, classID, bindType, equipLoc)
end

-- input: an item's rarity, and whether it is whitelisted or blacklisted
-- output: true when the item should produce a notification
-- Applies the whitelist, then the blacklist, then the rarity threshold.
function L.Filter.ShouldShow(rarity, isWhitelisted, isBlacklisted)
    if isWhitelisted then
        return true
    end

    if isBlacklisted then
        return false
    end

    return rarity >= LootiConfig.notificationThreshold
end

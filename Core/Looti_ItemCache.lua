-- Resolves item data the client has not cached yet.
local ADDON, L = ...

L.ItemCache = {}

local PENDING_TIMEOUT = 30

local pending = {}
local frame = CreateFrame("Frame")

-- input: an item link or item id
-- output: the numeric item id, or nil
-- Reads the item id out of a link.
function L.ItemCache.ItemID(item)
    if type(item) == "number" then
        return item
    end

    if type(item) ~= "string" then
        return nil
    end

    return tonumber(item:match("item:(%d+)"))
end

-- input: text the player typed or pasted
-- output: the item id, or nil when the text is not a known item
-- Reads an item link, an item id, or an exact item name. Names resolve only
-- for items the client has cached.
function L.ItemCache.ItemIDFromText(text)
    text = strtrim(text or "")
    if text == "" then
        return nil
    end

    local itemID = L.ItemCache.ItemID(text)
    if itemID then
        return itemID
    end

    if text:match("^%d+$") then
        return tonumber(text)
    end

    local name = text:match("^%[(.+)%]$") or text

    itemID = C_Item.GetItemInfoInstant(name)
    if itemID then
        return itemID
    end

    local _, link = L.Compat.GetItemInfo(name)
    return L.ItemCache.ItemID(link)
end

-- input: text the player typed or pasted
-- output: a list of item ids, empty when nothing in the text is a known item
-- Reads every item link in the text, or a single id or name when there are none.
function L.ItemCache.ItemIDsFromText(text)
    local itemIDs = {}

    for itemID in (text or ""):gmatch("|Hitem:(%d+)") do
        itemIDs[#itemIDs + 1] = tonumber(itemID)
    end

    if #itemIDs == 0 then
        itemIDs[1] = L.ItemCache.ItemIDFromText(text)
    end

    return itemIDs
end

-- input: an item id
-- output: nothing
-- Runs and clears every callback waiting on one item.
local function Deliver(itemID)
    local waiting = pending[itemID]
    if not waiting then
        return
    end

    pending[itemID] = nil

    for _, entry in ipairs(waiting) do
        entry.callback(entry.item)
    end
end

-- input: nothing
-- output: nothing
-- Drops callbacks for items the client never sent.
local function DropStale()
    local now = GetTime()

    for itemID, waiting in pairs(pending) do
        if now - waiting.queuedAt > PENDING_TIMEOUT then
            pending[itemID] = nil
        end
    end
end

-- input: an item link or id, and a callback taking that item
-- output: nothing
-- Runs the callback now if the item is cached, otherwise when the client sends it.
function L.ItemCache.Resolve(item, callback)
    local itemID = L.ItemCache.ItemID(item)
    if not itemID then
        return
    end

    -- Pruning rides on the next loot rather than a timer, so nothing of ours
    -- runs while the player is not looting.
    DropStale()

    if L.Compat.GetItemInfo(item) then
        callback(item)
        return
    end

    local waiting = pending[itemID]
    if not waiting then
        waiting = { queuedAt = GetTime() }
        pending[itemID] = waiting
    end

    waiting[#waiting + 1] = { item = item, callback = callback }
end

frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
frame:SetScript("OnEvent", function(_, _, itemID)
    if itemID then
        Deliver(itemID)
    end
end)

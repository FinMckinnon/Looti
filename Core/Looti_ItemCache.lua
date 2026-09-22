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

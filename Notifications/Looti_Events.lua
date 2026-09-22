-- Loot event handling, loot window capture and duplicate suppression.
local ADDON, L = ...

L.Events = {}

local DEDUP_WINDOW = 5

local COIN_ICONS = {
    gold = "Interface\\Icons\\INV_Misc_Coin_01",
    silver = "Interface\\Icons\\INV_Misc_Coin_03",
    copper = "Interface\\Icons\\INV_misc_coin_05",
}

-- Our own copy of the loot window. Other addons empty the live window from
-- their own LOOT_READY handler, so a slot read back later returns nothing.
local lootCapture = {}
local lootSessionOpen = false

-- The slot path and the chat backstop cover each other. Each loot raises a
-- balance from one side and lowers it from the other; a notification is sent
-- whenever the balance moves away from zero and withheld when it returns. That
-- gives one notification per pickup whichever event arrives first, and still
-- one per pickup when another addon loots the item and only chat reaches us.
local dedupTokens = {}

-- input: an item link and a quantity
-- output: a key identifying that exact loot
-- Builds the dedup key for one item and count.
local function DedupKey(link, quantity)
    return (link or "?") .. "\1" .. tostring(quantity or 1)
end

-- input: an item link, a quantity, and whether the chat backstop saw it
-- output: true when this loot should be reported
-- Moves the balance for this loot and reports only when it leaves zero.
local function ClaimLoot(link, quantity, fromChat)
    local key = DedupKey(link, quantity)
    local token = dedupTokens[key]
    local now = GetTime()

    if not token or token.expires <= now then
        token = { balance = 0 }
        dedupTokens[key] = token
    end
    token.expires = now + DEDUP_WINDOW

    local before = token.balance
    token.balance = before + (fromChat and -1 or 1)

    return math.abs(token.balance) > math.abs(before)
end

-- input: an item link and a quantity
-- output: a notification data table, or nil when the item is filtered out
-- Reads an item's details and tests it against the filters.
local function BuildItemData(link, quantity)
    local name, _, rarity, level, _, _, _, _, equipLoc, icon, _, classID, _, bindType =
        L.Compat.GetItemInfo(link)

    if not rarity then
        return nil
    end

    local itemID = L.ItemCache.ItemID(link)
    local isWhitelisted = L.Filter.InList("whitelist", itemID, classID, bindType, equipLoc)
    local isBlacklisted = L.Filter.InList("blacklist", itemID, classID, bindType, equipLoc)

    if not L.Filter.ShouldShow(rarity, isWhitelisted, isBlacklisted) then
        return nil
    end

    return {
        itemName = name,
        itemIcon = icon,
        itemRarity = rarity,
        itemQuantity = quantity,
        itemLevel = level,
        itemEquipLoc = equipLoc,
        itemLink = link,
    }
end

-- input: an item link and a quantity
-- output: nothing
-- Queues a notification for one item once its details are known.
function L.Events.Present(link, quantity)
    local itemData = BuildItemData(link, quantity)
    if not itemData then
        return
    end

    L.Queue.Add(itemData, nil)
    L.Features.OnRecord(itemData, nil)
end

-- input: an item link, a quantity, and whether the chat backstop saw it
-- output: nothing
-- Reports one looted item, unless the other path already reported it.
function L.Events.NotifyLoot(link, quantity, fromChat)
    if not link or not ClaimLoot(link, quantity, fromChat) then
        return
    end

    L.ItemCache.Resolve(link, function(resolved)
        L.Events.Present(resolved, quantity)
    end)
end

-- input: nothing
-- output: nothing
-- Copies every slot in the loot window into our own array.
local function CaptureLootWindow()
    if not lootSessionOpen then
        wipe(lootCapture)
        lootSessionOpen = true
    end

    for slot = 1, GetNumLootItems() do
        if not lootCapture[slot] then
            local link = GetLootSlotLink(slot)
            if link then
                local _, _, quantity = GetLootSlotInfo(slot)
                lootCapture[slot] = { link = link, quantity = quantity or 1 }
            end
        end
    end
end

-- input: a loot slot index
-- output: nothing
-- Reports the item taken from one slot.
local function HandleSlotCleared(slot)
    local data = lootCapture[slot]

    if not data then
        -- Something emptied this slot before we saw the window; salvage what is
        -- still there so the remaining slots survive.
        CaptureLootWindow()
        data = lootCapture[slot]
    end

    if data then
        lootCapture[slot] = nil
        L.Events.NotifyLoot(data.link, data.quantity)
    end
end

-- input: nothing
-- output: nothing
-- Clears the captured window and drops spent dedup tokens.
local function HandleLootClosed()
    lootSessionOpen = false
    wipe(lootCapture)

    local now = GetTime()
    for key, token in pairs(dedupTokens) do
        if token.expires <= now then
            dedupTokens[key] = nil
        end
    end
end

-- input: a chat message
-- output: nothing
-- Reports loot announced in chat, covering anything the slot path missed.
local function HandleChatLoot(message)
    local link, quantity = L.Chat.ParseLoot(message)
    if link then
        L.Events.NotifyLoot(link, quantity, true)
    end
end

-- input: a chat message
-- output: nothing
-- Queues a notification for money the player received.
local function HandleMoney(message)
    local copper = L.Chat.ParseMoney(message)
    if copper <= 0 then
        return
    end

    local icon = COIN_ICONS.copper
    if copper >= 10000 then
        icon = COIN_ICONS.gold
    elseif copper >= 100 then
        icon = COIN_ICONS.silver
    end

    local currencyData = { totalCopper = copper, text = GetCoinTextureString(copper), icon = icon }

    L.Queue.Add(nil, currencyData)
    L.Features.OnRecord(nil, copper)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("LOOT_READY")
frame:RegisterEvent("LOOT_OPENED")
frame:RegisterEvent("LOOT_SLOT_CLEARED")
frame:RegisterEvent("LOOT_CLOSED")
frame:RegisterEvent("CHAT_MSG_LOOT")
frame:RegisterEvent("CHAT_MSG_MONEY")
frame:RegisterEvent("LOOT_ITEM_ROLL_WON")

frame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local loaded = ...
        if loaded == ADDON then
            L.Db.Load()
            L.Anchor.LoadPosition()
            L.Anchor.SetMoveMode(false)
        end
    elseif event == "LOOT_READY" or event == "LOOT_OPENED" then
        CaptureLootWindow()
    elseif event == "LOOT_SLOT_CLEARED" then
        local slot = ...
        HandleSlotCleared(slot)
    elseif event == "LOOT_CLOSED" then
        HandleLootClosed()
    elseif event == "CHAT_MSG_LOOT" then
        local message = ...
        HandleChatLoot(message)
    elseif event == "CHAT_MSG_MONEY" then
        local message = ...
        HandleMoney(message)
    elseif event == "LOOT_ITEM_ROLL_WON" then
        -- The payload is itemLink, quantity, rollType, roll, isUpgraded, and it
        -- fires only for the player's own win.
        local itemLink, rollQuantity = ...
        L.Events.NotifyLoot(itemLink, rollQuantity or 1)
    end
end)

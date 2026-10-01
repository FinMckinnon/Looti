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

-- Chat output at ADDON_LOADED is not reliably visible, so an upgrade notice
-- waits for the player to be in the world.
local pendingUpgradeNotice = false

-- The slot path and the chat backstop cover each other. Each loot raises a
-- balance from one side and lowers it from the other; a notification is sent
-- whenever the balance moves away from zero and withheld when it returns. That
-- gives one notification per pickup whichever event arrives first, and still
-- one per pickup when another addon loots the item and only chat reaches us.
local dedupTokens = {}

-- input: an item link and a quantity
-- output: a key identifying that loot
-- Builds the dedup key from the item id and count.
local function DedupKey(link, quantity)
    return tostring(L.ItemCache.ItemID(link) or link or "?") .. "\1" .. tostring(quantity or 1)
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

-- input: an item link, a quantity, and true to treat the item as watched
-- output: a notification data table, or nil when the item is filtered out
-- Reads an item's details and tests it against the filters.
local function BuildItemData(link, quantity, forceWatched)
    local name, _, rarity, baseLevel, _, _, _, _, equipLoc, icon, _, classID, _, bindType =
        L.Compat.GetItemInfo(link)

    if not rarity then
        return nil
    end

    local itemID = L.ItemCache.ItemID(link)
    local isWhitelisted = L.Filter.InList("whitelist", itemID, classID, bindType, equipLoc)
    local isBlacklisted = L.Filter.InList("blacklist", itemID, classID, bindType, equipLoc)
    local isWatched = forceWatched
        or L.Filter.InList("watchlist", itemID, classID, bindType, equipLoc)

    if not L.Filter.ShouldShow(rarity, isWhitelisted or isWatched, isBlacklisted) then
        return nil
    end

    local itemLevel
    if L.Const.EQUIP_SLOTS[equipLoc] then
        itemLevel = C_Item.GetDetailedItemLevelInfo(link) or baseLevel
    end

    return {
        itemName = name,
        itemIcon = icon,
        itemRarity = rarity,
        itemQuantity = quantity,
        itemLevel = itemLevel,
        itemEquipLoc = equipLoc,
        itemLink = link,
        itemWatched = isWatched and true or false,
    }
end

-- input: an item link, a quantity, and true to treat the item as watched
-- output: nothing
-- Queues a notification for one item once its details are known.
function L.Events.Present(link, quantity, forceWatched)
    local itemData = BuildItemData(link, quantity, forceWatched)
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
    local link, quantity, setting = L.Chat.ParseLoot(message)
    if link and (not setting or LootiConfig[setting]) then
        L.Events.NotifyLoot(link, quantity, true)
    end
end

-- input: an amount in copper
-- output: a notification data table for that amount
-- Builds the text and coin icon for a money notification.
function L.Events.MoneyData(copper)
    local icon = COIN_ICONS.copper
    if copper >= 10000 then
        icon = COIN_ICONS.gold
    elseif copper >= 100 then
        icon = COIN_ICONS.silver
    end

    return { totalCopper = copper, text = C_CurrencyInfo.GetCoinTextureString(copper), icon = icon }
end

-- input: a chat message
-- output: nothing
-- Queues a notification for money the player received.
local function HandleMoney(message)
    local copper = L.Chat.ParseMoney(message)
    if copper <= 0 then
        return
    end

    L.Queue.Add(nil, L.Events.MoneyData(copper))
    L.Features.OnRecord(nil, copper)
end

-- input: a chat message
-- output: nothing
-- Queues a notification for a currency the player received.
local function HandleCurrency(message)
    local link, quantity = L.Chat.ParseCurrency(message)
    local currencyID = link and tonumber(link:match("|Hcurrency:(%d+)"))
    local info = currencyID and C_CurrencyInfo.GetCurrencyInfo(currencyID)
    if not info then
        return
    end

    L.Queue.Add(nil, {
        text = info.name,
        icon = info.iconFileID,
        quality = info.quality,
        quantity = quantity,
        isCurrency = true,
    })
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("LOOT_READY")
frame:RegisterEvent("LOOT_OPENED")
frame:RegisterEvent("LOOT_SLOT_CLEARED")
frame:RegisterEvent("LOOT_CLOSED")
frame:RegisterEvent("CHAT_MSG_LOOT")
frame:RegisterEvent("CHAT_MSG_MONEY")
frame:RegisterEvent("CHAT_MSG_CURRENCY")
frame:RegisterEvent("LOOT_ITEM_ROLL_WON")

frame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local loaded = ...
        if loaded == ADDON then
            pendingUpgradeNotice = L.Db.Load()
            L.Anchor.LoadPosition()
            L.Anchor.SetMoveMode(false)
        end
    elseif event == "PLAYER_LOGIN" then
        if pendingUpgradeNotice then
            pendingUpgradeNotice = false
            L.Util.Print(L.Text.MSG_UPGRADED, "update")
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
    elseif event == "CHAT_MSG_CURRENCY" then
        local message = ...
        HandleCurrency(message)
    elseif event == "LOOT_ITEM_ROLL_WON" then
        -- The payload is itemLink, quantity, rollType, roll, isUpgraded, and it
        -- fires only for the player's own win.
        local itemLink, rollQuantity = ...
        L.Events.NotifyLoot(itemLink, rollQuantity or 1)
    end
end)

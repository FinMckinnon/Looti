-- Loot scenarios: when Looti must notify, when it must stay quiet, and how
-- many times. Every message is rendered from the client's own strings, for
-- every locale Blizzard ships, so the run covers other players' loot, master
-- loot, trades, crafting, refunds, secret text and duplicate suppression.
-- Run from the addon folder: node tests/run.js tests/loot.lua .
local M = dofile("tests/mocks.lua")
local STRINGS = dofile("tests/strings.lua")
local LinkFor = M.LinkFor

local now = 0
GetTime = function() return now end

-- The loot window the mock client reports. Filled by OpenLootWindow.
local lootSlots = {}
GetNumLootItems = function() return #lootSlots end
GetLootSlotLink = function(slot) return lootSlots[slot] and lootSlots[slot].link end
GetLootSlotInfo = function(slot) return nil, nil, lootSlots[slot] and lootSlots[slot].quantity end

-- input: a client format string and its arguments
-- output: the text the client would show
-- Resolves |4 and |1 grammar to its first form, then fills %s, %d, %1$s and %2$d.
local function Render(fmt, ...)
    local args = { ... }
    local text = fmt:gsub("|4([^:;]*):[^;]*;", "%1"):gsub("|1([^;]*);[^;]*;", "%1")
    local index = 0

    return (text:gsub("%%(%d*)%$?([sd])", function(position, kind)
        index = index + 1
        local value = args[tonumber(position) or index]
        return tostring(value)
    end))
end

-- input: an item id and a quantity
-- output: the item link with the 11.1.5 colour format
local function ChatLink(itemID)
    return "|cnIQ2|" .. LinkFor(itemID):match("|Hitem.*$")
end

local L, fire, captured

-- input: nothing
-- output: nothing
-- Drops the loot window, expires dedup tokens and clears captured notifications.
local function Reset()
    lootSlots = {}
    now = now + 60
    fire("LOOT_CLOSED")
    captured = {}
end

-- input: a list of { link, quantity }
-- output: nothing
-- Opens the mock loot window, as LOOT_READY and LOOT_OPENED would.
local function OpenLootWindow(slots)
    lootSlots = slots
    fire("LOOT_READY")
    fire("LOOT_OPENED")
end

-- input: a loot slot index
-- output: nothing
-- Takes one slot out of the loot window.
local function TakeSlot(slot)
    fire("LOOT_SLOT_CLEARED", slot)
    lootSlots[slot] = nil
end

-- input: the locale's strings and a message
-- output: nothing
-- Delivers one CHAT_MSG_LOOT line.
local function Loot(message) fire("CHAT_MSG_LOOT", message) end

-- Each scenario runs against one locale's strings and returns the expected
-- notification count. S is that locale's string table.
local SCENARIOS = {
    -- Happy paths: one notification each.
    { name = "loot window, then the chat line", expect = 1, run = function(S)
        OpenLootWindow({ { link = LinkFor(1003), quantity = 1 } })
        TakeSlot(1)
        Loot(Render(S.LOOT_ITEM_SELF, ChatLink(1003)))
    end },
    { name = "chat line before the loot window empties", expect = 1, run = function(S)
        OpenLootWindow({ { link = LinkFor(1003), quantity = 1 } })
        Loot(Render(S.LOOT_ITEM_SELF, ChatLink(1003)))
        TakeSlot(1)
    end },
    { name = "stack of 12 via the loot window and chat", expect = 1, run = function(S)
        OpenLootWindow({ { link = LinkFor(1001), quantity = 12 } })
        TakeSlot(1)
        Loot(Render(S.LOOT_ITEM_SELF_MULTIPLE, ChatLink(1001), 12))
    end, quantity = 12 },
    { name = "master looter hands you an item (chat only)", expect = 1, run = function(S)
        Loot(Render(S.LOOT_ITEM_SELF, ChatLink(1003)))
    end },
    { name = "vendor, quest reward or trade (You receive item)", expect = 1, run = function(S)
        Loot(Render(S.LOOT_ITEM_PUSHED_SELF, ChatLink(1002)))
    end },
    { name = "gathering a stack (You receive item x4)", expect = 1, run = function(S)
        Loot(Render(S.LOOT_ITEM_PUSHED_SELF_MULTIPLE, ChatLink(1002), 4))
    end, quantity = 4 },
    { name = "crafting (You create x5)", expect = 1, run = function(S)
        Loot(Render(S.LOOT_ITEM_CREATED_SELF_MULTIPLE, ChatLink(1002), 5))
    end, quantity = 5 },
    { name = "bonus roll", expect = 1, run = function(S)
        Loot(Render(S.LOOT_ITEM_BONUS_ROLL_SELF, ChatLink(1003)))
    end },
    { name = "won a roll, then the chat line", expect = 1, run = function(S)
        fire("LOOT_ITEM_ROLL_WON", LinkFor(1003), 1)
        Loot(Render(S.LOOT_ITEM_SELF, ChatLink(1003)))
    end },
    { name = "same item looted from two corpses", expect = 2, run = function(S)
        OpenLootWindow({ { link = LinkFor(1001), quantity = 1 } })
        TakeSlot(1)
        Loot(Render(S.LOOT_ITEM_SELF, ChatLink(1001)))
        fire("LOOT_CLOSED")
        OpenLootWindow({ { link = LinkFor(1001), quantity = 1 } })
        TakeSlot(1)
        Loot(Render(S.LOOT_ITEM_SELF, ChatLink(1001)))
    end },
    { name = "two different items in one window", expect = 2, run = function(S)
        OpenLootWindow({ { link = LinkFor(1001), quantity = 1 }, { link = LinkFor(1003), quantity = 1 } })
        TakeSlot(1)
        TakeSlot(2)
        Loot(Render(S.LOOT_ITEM_SELF, ChatLink(1001)))
        Loot(Render(S.LOOT_ITEM_SELF, ChatLink(1003)))
    end },
    { name = "another addon looted first: only chat reaches us", expect = 1, run = function(S)
        OpenLootWindow({})
        Loot(Render(S.LOOT_ITEM_SELF, ChatLink(1003)))
        fire("LOOT_SLOT_CLEARED", 1)
    end },
    { name = "watched grey item below the rarity threshold", expect = 1, run = function(S)
        LootiConfig.notificationThreshold = 3
        LootiFilters.watchlist.items[1004] = true
        Loot(Render(S.LOOT_ITEM_SELF, ChatLink(1004)))
        LootiConfig.notificationThreshold = 0
        LootiFilters.watchlist.items[1004] = nil
    end, watched = true },
    { name = "looted gold, silver and copper", expect = 1, run = function(S)
        local amount = Render(S.GOLD_AMOUNT, 5) .. " " .. Render(S.SILVER_AMOUNT, 3) .. " " .. Render(S.COPPER_AMOUNT, 7)
        fire("CHAT_MSG_MONEY", Render(S.YOU_LOOT_MONEY, amount))
    end, copper = 50307 },
    { name = "share of party loot", expect = 1, run = function(S)
        fire("CHAT_MSG_MONEY", Render(S.LOOT_MONEY_SPLIT, Render(S.SILVER_AMOUNT, 42)))
    end, copper = 4200 },
    { name = "currency x25", expect = 1, run = function(S)
        fire("CHAT_MSG_CURRENCY", Render(S.CURRENCY_GAINED_MULTIPLE, "|cnIQ3|Hcurrency:3008:0|h[Valorstones]|h|r", 25))
    end, quantity = 25 },
    { name = "currency at the cap", expect = function(S) return S.CURRENCY_GAINED_MULTIPLE_OVERFLOW and 1 or 0 end, run = function(S)
        if not S.CURRENCY_GAINED_MULTIPLE_OVERFLOW then return end
        fire("CHAT_MSG_CURRENCY", Render(S.CURRENCY_GAINED_MULTIPLE_OVERFLOW, "|cnIQ3|Hcurrency:3008:0|h[Valorstones]|h|r", 10, "Valorstones"))
    end, quantity = 10 },

    -- Unhappy paths: no notification.
    { name = "party member loots", expect = 0, run = function(S)
        Loot(Render(S.LOOT_ITEM, "Bob", ChatLink(1003)))
    end },
    { name = "party member loots a stack", expect = 0, run = function(S)
        Loot(Render(S.LOOT_ITEM_MULTIPLE, "Bob", ChatLink(1001), 12))
    end },
    { name = "party member receives an item", expect = 0, run = function(S)
        Loot(Render(S.LOOT_ITEM_PUSHED, "Bob", ChatLink(1002)))
    end },
    { name = "party member crafts", expect = 0, run = function(S)
        Loot(Render(S.CREATED_ITEM, "Bob", ChatLink(1002)))
    end },
    { name = "party member bonus roll", expect = 0, run = function(S)
        Loot(Render(S.LOOT_ITEM_BONUS_ROLL, "Bob", ChatLink(1003)))
    end },
    { name = "loot you were ineligible for", expect = 0, run = function(S)
        Loot(Render(S.LOOT_ITEM_WHILE_PLAYER_INELIGIBLE, "Bob", ChatLink(1003)))
    end },
    { name = "a player called You loots", expect = 0, run = function(S)
        Loot(Render(S.LOOT_ITEM, "You", ChatLink(1003)))
    end },
    { name = "party member loots money", expect = 0, run = function(S)
        fire("CHAT_MSG_MONEY", Render(S.LOOT_MONEY, "Bob", Render(S.GOLD_AMOUNT, 5)))
    end },
    { name = "item refund", expect = 0, run = function(S)
        Loot(Render(S.LOOT_ITEM_REFUND, ChatLink(1003)))
    end },
    { name = "money refund", expect = 0, run = function(S)
        fire("CHAT_MSG_MONEY", Render(S.LOOT_MONEY_REFUND, Render(S.GOLD_AMOUNT, 5)))
    end },
    { name = "disenchant credit", expect = 0, run = function(S)
        Loot(Render(S.LOOT_DISENCHANT_CREDIT, ChatLink(1003), "Bob"))
    end },
    { name = "blacklisted item", expect = 0, run = function(S)
        LootiFilters.blacklist.items[1003] = true
        Loot(Render(S.LOOT_ITEM_SELF, ChatLink(1003)))
        LootiFilters.blacklist.items[1003] = nil
    end },
    { name = "grey item below the rarity threshold", expect = 0, run = function(S)
        LootiConfig.notificationThreshold = 2
        Loot(Render(S.LOOT_ITEM_SELF, ChatLink(1004)))
        LootiConfig.notificationThreshold = 0
    end },
    { name = "loot notifications switched off", expect = 0, run = function(S)
        LootiConfig.showLootNotifications = false
        OpenLootWindow({ { link = LinkFor(1003), quantity = 1 } })
        TakeSlot(1)
        Loot(Render(S.LOOT_ITEM_SELF, ChatLink(1003)))
        LootiConfig.showLootNotifications = true
    end },
    { name = "money notifications switched off", expect = 0, run = function(S)
        LootiConfig.showMoneyNotifications = false
        fire("CHAT_MSG_MONEY", Render(S.YOU_LOOT_MONEY, Render(S.GOLD_AMOUNT, 5)))
        LootiConfig.showMoneyNotifications = true
    end },
    -- Italian and Korean use the same words for loot and received items, so the toggle cannot apply there.
    { name = "bought items switched off", expect = function(S) return S.LOOT_ITEM_PUSHED_SELF == S.LOOT_ITEM_SELF and 1 or 0 end, run = function(S)
        LootiConfig.showPushedItems = false
        Loot(Render(S.LOOT_ITEM_PUSHED_SELF, ChatLink(1002)))
        LootiConfig.showPushedItems = true
    end },
    { name = "crafted items switched off", expect = 0, run = function(S)
        LootiConfig.showCraftedItems = false
        Loot(Render(S.LOOT_ITEM_CREATED_SELF, ChatLink(1002)))
        LootiConfig.showCraftedItems = true
    end },
    { name = "secret chat text (12.0 instanced content)", expect = 0, run = function(S)
        local secret = Render(S.LOOT_ITEM_SELF, ChatLink(1003))
        issecretvalue = function(value) return value == secret end
        Loot(secret)
        fire("CHAT_MSG_MONEY", secret)
        issecretvalue = nil
    end },
    { name = "empty and nil messages", expect = 0, run = function(S)
        Loot("")
        Loot(nil)
        fire("CHAT_MSG_MONEY", nil)
        fire("CHAT_MSG_CURRENCY", "")
    end },
}

local total, failed = 0, 0

-- enUS_classic drops the strings Classic clients lack, so those groups still build.
STRINGS.enUS_forever = dofile("tests/strings_forever.lua")

STRINGS.enUS_classic = {}
for key, value in pairs(STRINGS.enUS) do STRINGS.enUS_classic[key] = value end
STRINGS.enUS_classic.CURRENCY_GAINED_MULTIPLE_OVERFLOW = nil

for _, locale in ipairs({ "enUS", "enUS_forever", "enUS_classic", "deDE", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW" }) do
    local S = STRINGS[locale]
    CURRENCY_GAINED_MULTIPLE_OVERFLOW = nil
    L = M.LoadAddon(S)

    local eventFrame
    for _, frame in ipairs(M.allFrames) do
        if frame.events and frame.events.CHAT_MSG_LOOT then eventFrame = frame end
    end
    fire = function(event, ...) eventFrame.scripts.OnEvent(eventFrame, event, ...) end
    L.Rows.Fill = function(_, itemData, currencyData) captured[#captured + 1] = itemData or currencyData end
    C_Timer.After = function(_, callback) callback() end

    local localeFailed = 0
    for _, scenario in ipairs(SCENARIOS) do
        Reset()
        local ok, err = pcall(scenario.run, S)
        local got = #captured
        local first = captured[1] or {}
        local expect = type(scenario.expect) == "function" and scenario.expect(S) or scenario.expect
        local pass = ok and got == expect
        if pass and expect > 0 then
            pass = (not scenario.quantity or (first.itemQuantity or first.quantity) == scenario.quantity)
                and (not scenario.copper or first.totalCopper == scenario.copper)
                and (not scenario.watched or first.itemWatched == true)
        end

        total = total + 1
        if not pass then
            failed = failed + 1
            localeFailed = localeFailed + 1
            print(string.format("  FAIL [%s] %s: expected %d, got %d%s", locale, scenario.name,
                expect, got, ok and "" or (" (error: " .. tostring(err) .. ")")))
        end
    end

    print(string.format("%s: %d scenarios, %d failed", locale, #SCENARIOS, localeFailed))
end

print(string.format("%d checks, %d failed", total, failed))
print(failed == 0 and "ALL PASSED" or "FAILED")

-- Ordering, pacing and on-screen placement of notifications.
local ADDON, L = ...

L.Queue = {}

local FADE_IN_TIME = 0.5
local FADE_OUT_TIME = 0.5

local active = {}
local waiting = {}
local ticker

-- input: nothing
-- output: nothing
-- Stacks every visible notification against the anchor.
function L.Queue.UpdatePositions()
    local scrollUp = LootiConfig.scrollDirection == "up"
    local point = scrollUp and "BOTTOM" or "TOP"
    local spacing = -L.Rows.Height()

    for index, row in ipairs(active) do
        local offset = (index - 1) * spacing

        row:ClearAllPoints()
        row:SetPoint(point, L.Anchor.frame, point, 0, scrollUp and -offset or offset)
    end
end

-- input: a row and the generation it was acquired with
-- output: nothing
-- Drops a row from the visible list and returns it to the pool.
local function Retire(row, atGeneration)
    for index, candidate in ipairs(active) do
        if candidate == row then
            table.remove(active, index)
            break
        end
    end

    L.Rows.Release(row, atGeneration)
    L.Queue.UpdatePositions()
end

-- input: item data and currency data, one of which is nil
-- output: nothing
-- Puts one notification on screen and schedules its removal.
local function Show(itemData, currencyData)
    local row, atGeneration = L.Rows.Acquire()
    L.Rows.Fill(row, itemData, currencyData)

    table.insert(active, 1, row)

    UIFrameFadeIn(row, FADE_IN_TIME, 0, LootiConfig.notificationAlpha)
    L.Queue.UpdatePositions()

    C_Timer.After(LootiConfig.displayDuration, function()
        UIFrameFadeOut(row, FADE_OUT_TIME, LootiConfig.notificationAlpha, 0)
        C_Timer.After(FADE_OUT_TIME, function()
            Retire(row, atGeneration)
        end)
    end)

    L.Features.OnNotify(itemData)
end

-- input: nothing
-- output: nothing
-- Releases one waiting notification per tick.
local function Drain()
    if #waiting == 0 then
        if ticker then
            ticker:Cancel()
            ticker = nil
        end
        return
    end

    -- The screen is full; the ticker calls back, so no extra polling here.
    local limit = LootiConfig.maximumNotifications
    if limit > 0 and #active >= limit then
        return
    end

    local queued = table.remove(waiting, 1)
    Show(queued.itemData, queued.currencyData)
end

-- input: item data and currency data, one of which is nil
-- output: nothing
-- Shows a notification straight away, or queues it behind the ones on screen.
function L.Queue.Add(itemData, currencyData)
    if itemData and not LootiConfig.showLootNotifications then
        return
    end

    if currencyData then
        local enabled = LootiConfig.showMoneyNotifications
        if currencyData.isCurrency then
            enabled = LootiConfig.showCurrencyNotifications
        end

        if not enabled then
            return
        end
    end

    if #active == 0 then
        Show(itemData, currencyData)
        return
    end

    waiting[#waiting + 1] = { itemData = itemData, currencyData = currencyData }

    if not ticker then
        ticker = C_Timer.NewTicker(LootiConfig.notificationDelay, Drain)
    end
end

-- Ordering, pacing and on-screen placement of notifications.
local ADDON, L = ...

L.Queue = {}

-- The backlog is released over at most this many ticks, so a large loot cannot
-- leave its last notification many seconds behind the pickup.
local MAX_DRAIN_TICKS = 5
local FADE_IN_TIME = 0.5
local FADE_OUT_TIME = 0.5

local active = {}
local waiting = {}
local ticker
local drainBatch = 1

-- input: nothing
-- output: nothing
-- Stacks every visible notification against the anchor.
function L.Queue.UpdatePositions()
    local scrollUp = LootiConfig.scrollDirection == "up"
    local point = scrollUp and "BOTTOM" or "TOP"
    local spacing = L.Const.FRAME.SPACING * LootiConfig.notificationScale

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
-- Releases part of the backlog, holding the rate for the whole drain.
local function Drain()
    if #waiting == 0 then
        if ticker then
            ticker:Cancel()
            ticker = nil
        end
        drainBatch = 1
        return
    end

    -- The screen is full; the ticker calls back, so no extra polling here.
    local limit = LootiConfig.maximumNotifications
    if limit > 0 and #active >= limit then
        return
    end

    drainBatch = math.max(drainBatch, math.ceil(#waiting / MAX_DRAIN_TICKS))

    for _ = 1, drainBatch do
        local queued = table.remove(waiting, 1)
        if not queued then
            break
        end
        Show(queued.itemData, queued.currencyData)
    end
end

-- input: item data and currency data, one of which is nil
-- output: nothing
-- Shows a notification straight away, or queues it behind the ones on screen.
function L.Queue.Add(itemData, currencyData)
    if itemData and not LootiConfig.showLootNotifications then
        return
    end

    if currencyData and not LootiConfig.showMoneyNotifications then
        return
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

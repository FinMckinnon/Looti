-- Ordering, pacing and on-screen placement of notifications.
local ADDON, L = ...

L.Queue = {}

local FADE_IN_TIME = 0.5
local FADE_OUT_TIME = 0.5

local active = {}
local waiting = {}
local ticker
local paused = false

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

    if GameTooltip:IsOwned(row) then
        GameTooltip:Hide()
    end

    L.Rows.Release(row, atGeneration)
    L.Queue.UpdatePositions()
end

-- input: a row
-- output: nothing
-- Fades a row out and retires it, unless a hover cancels the fade first.
local function FadeOut(row)
    local atGeneration = row.generation
    row.fading = true

    UIFrameFadeOut(row, FADE_OUT_TIME, LootiConfig.notificationAlpha, 0)
    C_Timer.After(FADE_OUT_TIME, function()
        if row.fading and row.generation == atGeneration then
            Retire(row, atGeneration)
        end
    end)
end

-- input: a row
-- output: nothing
-- Runs a row's remaining display time, then fades it.
local function StartClock(row)
    row.clock = (row.clock or 0) + 1
    row.startedAt = GetTime()

    local clock, atGeneration = row.clock, row.generation
    C_Timer.After(row.remaining, function()
        if row.clock == clock and row.generation == atGeneration then
            row.expired = true
            FadeOut(row)
        end
    end)
end

-- input: a row
-- output: nothing
-- Stops a row's clock and keeps the time it had left.
local function StopClock(row)
    row.clock = (row.clock or 0) + 1
    row.remaining = math.max(0, row.remaining - (GetTime() - row.startedAt))
end

-- input: a row
-- output: nothing
-- Shows the tooltip and, while the mouse is over any notification, freezes
-- every notification's clock and stops new ones arriving.
local function OnEnter(row)
    if LootiConfig.showTooltip then
        L.Rows.ShowTooltip(row)
    end

    if not (LootiConfig.showTooltip and LootiConfig.pauseOnHover) or paused then
        return
    end

    paused = true

    for _, visible in ipairs(active) do
        if visible.fading then
            UIFrameFadeRemoveFrame(visible)
            visible:SetAlpha(LootiConfig.notificationAlpha)
            visible.fading = false
        elseif not visible.expired then
            StopClock(visible)
        end
    end
end

-- input: a row
-- output: nothing
-- Hides the tooltip and restarts every clock from where it stopped.
local function OnLeave()
    GameTooltip:Hide()

    if not paused then
        return
    end

    paused = false

    for _, visible in ipairs(active) do
        if visible.expired then
            FadeOut(visible)
        else
            StartClock(visible)
        end
    end
end

L.Rows.OnEnter, L.Rows.OnLeave = OnEnter, OnLeave

-- input: item data and currency data, one of which is nil
-- output: nothing
-- Puts one notification on screen and starts its clock.
local function Show(itemData, currencyData)
    local row = L.Rows.Acquire()
    L.Rows.Fill(row, itemData, currencyData)

    row.fading, row.expired = false, false
    row.remaining = LootiConfig.displayDuration

    table.insert(active, 1, row)

    UIFrameFadeIn(row, FADE_IN_TIME, 0, LootiConfig.notificationAlpha)
    L.Queue.UpdatePositions()

    if not paused then
        StartClock(row)
    end

    L.Features.OnNotify(itemData)
end

-- input: nothing
-- output: nothing
-- Rewrites every visible notification, so bag counts catch up with the bags.
function L.Queue.RefreshAll()
    for _, row in ipairs(active) do
        L.Rows.Fill(row, row.itemData, row.currencyData)
    end
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

    if paused then
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

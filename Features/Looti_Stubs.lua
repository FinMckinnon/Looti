-- The watchlist sound, and the disabled entry point for the session tracker.
local ADDON, L = ...

L.Features = {}

-- Hardcoded rather than read from the saved variables, so editing the saved
-- variables file cannot switch on code that is not written yet.
L.Features.sessionTracker = false

-- input: item data for a notification that is being shown, or nil for money
-- output: nothing
-- Plays the watchlist sound when a watched item appears.
function L.Features.OnNotify(itemData)
    if itemData and itemData.itemWatched and LootiConfig.watchlistSound then
        PlaySound(L.Const.WATCH_SOUND, "Master")
    end
end

-- input: item data, or nil and a copper amount for money
-- output: nothing
-- Reserved for running session totals.
function L.Features.OnRecord(itemData, copper)
    if not L.Features.sessionTracker then
        return
    end
end

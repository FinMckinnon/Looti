-- Disabled entry points for the watchlist and session tracker.
local ADDON, L = ...

L.Features = {}

-- Hardcoded rather than read from the saved variables, so editing the saved
-- variables file cannot switch on code that is not written yet.
L.Features.watchlist = false
L.Features.sessionTracker = false

-- input: item data for a notification that is about to be shown
-- output: nothing
-- Reserved for the extra watchlist alert.
function L.Features.OnNotify(itemData)
    if not L.Features.watchlist then
        return
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

-- Settings panel, notification rows and watchlist checks against the mock client.
-- Run from the addon folder: node tests/run.js tests/ui.lua .
local M = dofile("tests/mocks.lua")
local check, allFrames, played = M.check, M.allFrames, M.played
local layouts, released, AceGUI = M.layouts, M.released, M.AceGUI
local LinkFor = M.LinkFor
local strings = dofile("tests/strings.lua").enUS
local L = M.LoadAddon(strings)

local function Find(w, pred, out)
    out = out or {}
    if pred(w) then out[#out + 1] = w end
    for _, c in ipairs(w.children or {}) do Find(c, pred, out) end
    return out
end

print("Settings panel")
LootiConfig.notificationFrameX, LootiConfig.notificationFrameY = 120, -40
L.Panel.Open()
local window
check(L.Panel.IsOpen(), "panel opens")

L.Panel.Close()
local created = {}
local realCreate = AceGUI.Create
AceGUI.Create = function(self, kind) local w = realCreate(self, kind); created[#created + 1] = w; return w end
L.Panel.Open()
window = created[1]
check(window.type == "Frame", "window is an AceGUI Frame")
check(window.statusBar.shown == false and window.closeButton.shown == false, "status bar and Close button hidden")
local bottom = window.content.points[#window.content.points]
check(bottom[1] == "BOTTOMRIGHT" and bottom[3] == 16, "content bottom moved down to 16px")
check(window.content.height == 675 - 27 - 16, "content height recorded as " .. tostring(window.content.height))
local tabGroup = window.children[1]
local footer = window.children[2]
check(tabGroup.height == 632 - 32, "tab group height " .. tostring(tabGroup.height))
check(footer.layout == "LootiCentredRow" and #footer.children == 3, "footer uses centred row with 3 buttons")

-- run the centred layout on the footer
for _, b in ipairs(footer.children) do b.frame.w, b.frame.h = b.width, 24 end
footer.content.width = 446
local finishedHeight
footer.LayoutFinished = function(_, _, h) finishedHeight = h end
layouts["LootiCentredRow"](footer.content, footer.children)
local xs = {}
for _, b in ipairs(footer.children) do xs[#xs + 1] = b.frame.points[1][4] end
check(xs[1] == 35 and xs[2] == 163 and xs[3] == 291, "buttons centred at x = " .. table.concat(xs, ", "))
check(finishedHeight == 24, "footer reports its height")

-- General tab: reset buttons side by side
tabGroup:SelectTab("general")
local scroll = tabGroup.children[1]
local resetButtons = Find(scroll, function(w) return w.type == "Button" and (w.text == L.Text.BUTTON_RESET or w.text == L.Text.BUTTON_RESET_POSITION) end)
check(#resetButtons == 2 and resetButtons[1].relWidth == 0.5 and resetButtons[2].relWidth == 0.5, "Reset all and Reset position share a row")
resetButtons[2]:Fire("OnClick")
check(LootiConfig.notificationFrameX == 0 and LootiConfig.notificationFrameY == 0, "Reset position saves the default position")
local anchorPoint = L.Anchor.frame.points[1]
check(anchorPoint and anchorPoint[4] == 0 and anchorPoint[5] == 0, "anchor frame moved to the centre")


-- Rarity slider: plain label, coloured name underneath that follows the slider
tabGroup:SelectTab("general")
scroll = tabGroup.children[1]
local slider = Find(scroll, function(w) return w.type == "Slider" end)[1]
local raritySection = Find(scroll, function(w) return w.title == L.Text.GROUP_MINIMUM_RARITY end)[1]
local nameLabel = raritySection.children[#raritySection.children]
check(slider.label == L.Text.LABEL_MINIMUM_RARITY, "rarity slider label is plain: " .. tostring(slider.label))
check(nameLabel.type == "Label" and nameLabel.justify == "CENTER", "coloured name label sits centred under the slider")
check(nameLabel.text == L.Const.RARITY_NAMES[LootiConfig.notificationThreshold], "name matches the current rarity: " .. tostring(nameLabel.text))
slider:Fire("OnValueChanged", 3)
check(nameLabel.text == ITEM_QUALITY3_DESC and nameLabel.color[1] == 0.3, "moving the slider to 3 shows Rare in its colour")

-- Every tab builds without errors
for _, tab in ipairs(L.SchemaTabs) do
    local ok, err = pcall(tabGroup.SelectTab, tabGroup, tab.value)
    check(ok, "tab '" .. tab.value .. "' builds" .. (ok and "" or (": " .. tostring(err))))
end

-- Filters tab: three list sections, watchlist toggles inside the watchlist section
tabGroup:SelectTab("filters")
scroll = tabGroup.children[1]
check(#scroll.children == 3, "filters tab has 3 sections")
local watchSection = scroll.children[3]
check(watchSection.title == L.Text.LIST_WATCHLIST, "third section is the watchlist")
local edit = Find(watchSection, function(w) return w.type == "Button" end)[1]
check(edit and not edit.disabled, "watchlist Edit button present")
local toggles = Find(watchSection, function(w) return w.type == "CheckBox" end)
check(#toggles == 3, "watchlist section has sound, star and highlight toggles")
check(toggles[1].label == L.Text.LABEL_WATCH_SOUND and toggles[1].value == true, "sound toggle defaults on")
toggles[1]:Fire("OnValueChanged", false)
L.Panel.Save()
check(L.Panel.IsOpen(), "Save leaves the window open")
check(LootiConfig.watchlistSound == false, "Save writes the watchlist toggle")
LootiConfig.watchlistSound = true

L.Panel.Close()
check(window.statusBar.shown and window.closeButton.shown, "bottom bar restored before release")
check(window.content.points[#window.content.points][3] == 40, "content bottom restored to 40px")
check(released[#released] == window, "window released after close")


print("Move notification area")
check(L.Anchor.frame.mouse == false, "notification area ignores the mouse outside move mode")
created = {}
L.Panel.Open()
local moveWindow = created[1]
local moveTabs = moveWindow.children[1]
moveTabs:SelectTab("layout")
local moveButton = Find(moveTabs.children[1], function(w) return w.type == "Button" and w.text == L.Text.BUTTON_MOVE_ANCHOR end)[1]
local ok, err = pcall(moveButton.Fire, moveButton, "OnClick")
check(ok, "clicking Move runs without error " .. tostring(err or ""))
check(L.Panel.IsOpen(), "settings window stays open")
check(L.Anchor.IsMoveMode(), "anchor in move mode")
L.Anchor.SetMoveMode(false)

print("Item data")
local captured = {}
local realAdd = L.Queue.Add
L.Queue.Add = function(item, money) captured[#captured + 1] = item or money end
local function present(id, forced)
    captured = {}
    L.Events.Present(LinkFor(id), 1, forced)
    return captured[1]
end
LootiConfig.notificationThreshold = 0
check(present(1001).itemLevel == nil, "junk has no item level")
check(present(1002).itemLevel == nil, "Tigerseye (gem) has no item level")
check(present(1003).itemLevel == 639, "gear uses its real level (639, base 580)")
LootiConfig.notificationThreshold = 2
check(present(1004) == nil, "grey item below threshold hidden")
LootiFilters.watchlist.items[1004] = true
local watchedGrey = present(1004)
check(watchedGrey and watchedGrey.itemWatched, "watched grey item shows and is flagged")
LootiFilters.blacklist.items[1005] = true
check(present(1005) == nil, "blacklisted item hidden")
LootiFilters.watchlist.items[1005] = true
check(present(1005) ~= nil, "watched item shows even when blacklisted")
check(present(1002, true).itemWatched, "preview can force the watched state")
check(present(1002).itemWatched == false, "unwatched item not flagged")
LootiConfig.notificationThreshold = 0

print("Rows")
local gear = present(1003, true)
local row = L.Rows.Acquire()
L.Rows.Fill(row, gear, nil)
check(row.text.text == "Sword |cFFFFFFFF(Lvl 639)|r", "text has no stray spaces: " .. row.text.text)
check(row.star.shown and row.upgrade.shown and row.highlight.shown, "star, upgrade arrow and highlight shown")
check(row.star.points[1][2] == row.text and row.star.points[1][3] == "RIGHT", "star sits after the text")
check(row.upgrade.points[1][2] == row.star, "upgrade arrow sits after the star")
check(row.highlight.color and row.highlight.color[1] == 1, "highlight tinted gold")

local junk = present(1001)
L.Rows.Fill(L.Rows.Acquire(), junk, nil)
local row2 = L.Rows.Acquire()
L.Rows.Fill(row2, junk, nil)
check(row2.text.text == "Broken Fang", "junk text is just the name: '" .. row2.text.text .. "'")
check(not row2.star.shown and not row2.highlight.shown, "unwatched row has no star or highlight")

LootiConfig.watchlistStar, LootiConfig.watchlistHighlight = false, false
local row3 = L.Rows.Acquire(); L.Rows.Fill(row3, gear, nil)
check(not row3.star.shown and not row3.highlight.shown and row3.upgrade.points[1][2] == row3.text, "star and highlight off; arrow moves up to the text")
LootiConfig.watchlistStar, LootiConfig.watchlistHighlight = true, true

LootiConfig.showText, LootiConfig.iconDisplay = false, "RIGHT"
local row4 = L.Rows.Acquire(); L.Rows.Fill(row4, gear, nil)
check(row4.star.points[1][2] == row4.icon and row4.star.points[1][3] == "LEFT", "no text, icon right: star sits left of the icon")
check(row4.upgrade.points[1][2] == row4.star and row4.upgrade.points[1][3] == "LEFT", "then the arrow left of the star")
LootiConfig.showText, LootiConfig.iconDisplay = true, "LEFT"

local row5 = L.Rows.Acquire(); L.Rows.Fill(row5, nil, L.Events.MoneyData(1030))
check(not row5.star.shown and not row5.highlight.shown and row5.icon.texture ~= nil, "money row: coin icon, no watch extras")


check(LootiConfig.colourByRarity == true, "rarity colour on by default")
local coloured = L.Rows.Acquire(); L.Rows.Fill(coloured, gear, nil)
check(coloured.text.textColor[1] == 0.3, "name in rarity colour when on")
LootiConfig.colourByRarity = false
local plain = L.Rows.Acquire(); L.Rows.Fill(plain, gear, nil)
check(plain.text.textColor[1] == 1 and plain.text.textColor[2] == 1 and plain.text.textColor[3] == 1, "name white when off")
LootiConfig.colourByRarity = true

M.bagCounts[1003] = 4
local counted = L.Rows.Acquire(); L.Rows.Fill(counted, gear, nil)
check(counted.text.text:find("|cFFAAAAAA(4)|r", 1, true), "bag count after the name: " .. counted.text.text)
LootiConfig.showBagCount = false
local uncounted = L.Rows.Acquire(); L.Rows.Fill(uncounted, gear, nil)
check(not uncounted.text.text:find("(4)", 1, true), "bag count hidden when off")
LootiConfig.showBagCount = true
M.bagCounts[1003] = nil

check(counted.text.font[3] == "", "no outline by default")
LootiConfig.textOutline = "THICKOUTLINE"
local outlined = L.Rows.Acquire()
check(outlined.text.font[3] == "THICKOUTLINE", "thick outline applied")
LootiConfig.textOutline = "NONE"

check(counted.icon.texCoord[1] == 0 and not counted.iconBorder.shown, "icon not zoomed and no border by default")
LootiConfig.iconZoom = true
local framed = L.Rows.Acquire()
check(framed.icon.texCoord[1] == 0.08 and framed.icon.texCoord[2] == 0.92, "icon zoomed in")
check(framed.iconBorder.shown and framed.iconBorder.points[1][2] == framed.icon, "border shown around the icon")
LootiConfig.iconZoom = false

local reagent = present(1005)
local tiered = L.Rows.Acquire(); L.Rows.Fill(tiered, reagent, nil)
check(tiered.text.text:find("Hated But Wanted|A:Tier2|a", 1, true), "crafting quality icon after the name: " .. tiered.text.text)
LootiConfig.showCraftingQuality = false
L.Rows.Fill(tiered, reagent, nil)
check(not tiered.text.text:find("|A:", 1, true), "crafting quality hidden when off")
LootiConfig.showCraftingQuality = true
local realTrade = C_TradeSkillUI
C_TradeSkillUI = nil
L.Rows.Fill(tiered, reagent, nil)
check(tiered.text.text == "Hated But Wanted", "no crafting quality API: plain name")
C_TradeSkillUI = { GetItemReagentQualityInfo = function() error("rejected") end, GetItemCraftedQualityInfo = function() error("rejected") end }
local ok = pcall(L.Rows.Fill, tiered, reagent, nil)
check(ok and tiered.text.text == "Hated But Wanted", "crafting quality call that errors: notification still shows")
C_TradeSkillUI = realTrade

local previewed = present(1003)
previewed.previewBagCount = 47
L.Rows.Fill(tiered, previewed, nil)
check(tiered.text.text:find("(47)", 1, true), "preview bag count shown")

print("Item names in the add box")
check(L.ItemCache.ItemIDFromText("Sword") == 1003 and L.ItemCache.ItemIDFromText("[Sword]") == 1003, "name and bracketed name resolve")
check(#L.ItemCache.ItemIDsFromText(link and "" or "") == 0, "empty text gives no ids")

print("Chat parsing (12.1 strings)")
local function link(id, name, colour) return (colour or "|cnIQ2|") .. "Hitem:" .. id .. "::::::::80:::::|h[" .. name .. "]|h|r" end
local cases = {
    { "You receive loot: " .. link(1003, "Sword") .. "x3", 1003, 3, "loot, |cnIQ link, x3" },
    { "You receive loot: " .. link(1003, "Sword", "|cnIQ2:|"), 1003, 1, "loot, |cnIQ2: link" },
    { "You receive loot: " .. link(1003, "Sword", "|cffffffff|") .. "x2.", 1003, 2, "loot, old |cff link with full stop" },
    { "You receive item: " .. link(1001, "Broken Fang"), 1001, 1, "pushed item (gathering, quest reward)" },
    { "You receive item: " .. link(1002, "Tigerseye") .. "x4", 1002, 4, "pushed item x4" },
    { "You receive bonus loot: " .. link(1003, "Sword"), 1003, 1, "bonus roll" },
    { "You create: " .. link(1002, "Tigerseye") .. "x5.", 1002, 5, "crafted x5" },
    { "You create: " .. link(1002, "Tigerseye") .. ".", 1002, 1, "crafted single" },
    { "You receive loot: |cnIQ3|Hitem:1003::::|h[Sword |A:Professions-ChatIcon-Quality-Tier3:17:15::1|a]|h|rx2", 1003, 2, "link text with a quality atlas" },
}
for _, c in ipairs(cases) do
    local l, q = L.Chat.ParseLoot(c[1])
    check(l and L.ItemCache.ItemID(l) == c[2] and q == c[3], c[4] .. " -> " .. tostring(l and L.ItemCache.ItemID(l)) .. " x" .. tostring(q))
end
check(L.Chat.ParseLoot("Bob receives loot: " .. link(1003, "Sword")) == nil, "another player's loot ignored")
check(L.Chat.ParseLoot("Bob receives item: " .. link(1003, "Sword") .. "x2") == nil, "another player's pushed item ignored")
local cl, cq = L.Chat.ParseCurrency("You receive currency: |cnIQ3|Hcurrency:3008:0|h[Valorstones]|h|rx25")
check(cl and cl:match("currency:3008") and cq == 25, "currency x25")
cl, cq = L.Chat.ParseCurrency("You receive currency: |cnIQ3|Hcurrency:3008:0|h[Valorstones]|h|rx10 (Bonus Objective)")
check(cq == 10, "currency bonus objective x10")
cl, cq = L.Chat.ParseCurrency("You receive currency: |cnIQ3|Hcurrency:3008:0|h[Valorstones]|h|r")
check(cl and cq == 1, "currency single")
local SECRET = "You receive loot: " .. link(1003, "Sword")
issecretvalue = function(v) return v == SECRET end
check(L.Chat.ParseLoot(SECRET) == nil, "secret message skipped without error")
issecretvalue = nil

print("Loot window and chat together")
local eventFrame
for _, f in ipairs(allFrames) do if f.events and f.events.CHAT_MSG_CURRENCY then eventFrame = f end end
check(eventFrame ~= nil, "CHAT_MSG_CURRENCY registered")
local fire = function(event, ...) eventFrame.scripts.OnEvent(eventFrame, event, ...) end
captured = {}
L.Queue.Add = function(item, money) captured[#captured + 1] = item or money end
L.Events.NotifyLoot("|cnIQ3|Hitem:1003::::::::80:257::::::|h[Sword]|h|r", 1)
fire("CHAT_MSG_LOOT", "You receive loot: |cnIQ3:|Hitem:1003::::::::80:::::::|h[Sword]|h|r")
check(#captured == 1, "same item from loot window and chat notifies once (" .. #captured .. ")")
captured = {}
fire("CHAT_MSG_LOOT", "You receive item: " .. link(1002, "Tigerseye") .. "x3")
check(#captured == 1 and captured[1].itemQuantity == 3, "pushed item with no loot window notifies")
captured = {}
fire("CHAT_MSG_CURRENCY", "You receive currency: |cnIQ3|Hcurrency:3008:0|h[Valorstones]|h|rx25")
check(#captured == 1 and captured[1].text == "Valorstones" and captured[1].quantity == 25 and captured[1].isCurrency, "currency event queues a notification")

check(LootiConfig.showPushedItems and LootiConfig.showCraftedItems, "bought and crafted toggles on by default")
LootiConfig.showPushedItems, LootiConfig.showCraftedItems = false, false
captured = {}
fire("CHAT_MSG_LOOT", "You receive item: " .. link(1002, "Tigerseye") .. "x2")
fire("CHAT_MSG_LOOT", "You create: " .. link(1002, "Tigerseye") .. "x3.")
check(#captured == 0, "bought and crafted lines skipped when their toggles are off")
fire("CHAT_MSG_LOOT", "You receive loot: " .. link(1001, "Broken Fang") .. "x4")
check(#captured == 1 and captured[1].itemQuantity == 4, "looted items still notify")
LootiConfig.showPushedItems, LootiConfig.showCraftedItems = true, true
L.Queue.Add = realAdd

local cur = { text = "Valorstones", icon = 1, quality = 3, quantity = 25, isCurrency = true }
local crow = L.Rows.Acquire(); L.Rows.Fill(crow, nil, cur)
check(crow.text.text == "Valorstones |cFFFFFFFFx25|r" and crow.text.textColor[1] == 0.3, "currency row: name, quantity, quality colour")
local shown = 0
local realAcquire = L.Rows.Acquire
L.Rows.Acquire = function(...) shown = shown + 1; return realAcquire(...) end
LootiConfig.showCurrencyNotifications = false
L.Queue.Add(nil, cur)
check(shown == 0, "currency toggle off hides currency")
LootiConfig.showCurrencyNotifications = true
L.Rows.Acquire = realAcquire


print("Row height follows the icon")
local tick
local realTicker = C_Timer.NewTicker
C_Timer.NewTicker = function(_, fn) tick = fn; return { Cancel = function() end } end
LootiConfig.iconSize, LootiConfig.notificationScale, LootiConfig.scrollDirection = 64, 1, "up"
check(L.Rows.Height() == 74, "64px icon gives a 74px row: " .. L.Rows.Height())
L.Queue.Add(gear, nil)
L.Queue.Add(junk, nil)
tick()
local rowsOnScreen = {}
for _, f in ipairs(allFrames) do if f.shown and f.generation and f.points[1] and f.points[1][2] == L.Anchor.frame then rowsOnScreen[#rowsOnScreen + 1] = f end end
table.sort(rowsOnScreen, function(a, b) return a.points[1][5] < b.points[1][5] end)
local gap = rowsOnScreen[2] and (rowsOnScreen[2].points[1][5] - rowsOnScreen[1].points[1][5])
check(#rowsOnScreen >= 2 and gap == 74 and rowsOnScreen[1].h == 74, "rows are 74px tall and stacked 74px apart: gap " .. tostring(gap))
LootiConfig.iconSize, LootiConfig.notificationScale = 16, 2
check(L.Rows.Height() == 70, "small icon keeps the 35px default, scaled x2: " .. L.Rows.Height())
LootiConfig.iconSize, LootiConfig.notificationScale = 32, 1

print("Hover")
local timers = {}
local function RunTimers() local due = timers; timers = {}; for _, fn in ipairs(due) do fn() end end
local realAfter, realGetTime = C_Timer.After, GetTime
local now = 0
C_Timer.After = function(_, fn) timers[#timers + 1] = fn end
GetTime = function() return now end
local hoverRow
local realAcq = L.Rows.Acquire
L.Rows.Acquire = function(...) local r, g = realAcq(...); hoverRow = r; return r, g end
check(not LootiConfig.showTooltip and not LootiConfig.pauseOnHover, "mouseover off by default")
local idle = L.Rows.Acquire()
check(idle.mouse == false, "row ignores the mouse when the tooltip is off")
hoverRow = nil
LootiConfig.showTooltip, LootiConfig.pauseOnHover = true, true
L.Queue.Add(gear, nil)
for _ = 1, 50 do if hoverRow then break end tick() end
L.Rows.Acquire = realAcq
check(hoverRow and hoverRow.mouse == true, "row reads the mouse")
hoverRow.scripts.OnEnter(hoverRow)
check(GameTooltip.owner == hoverRow and GameTooltip.link == gear.itemLink, "tooltip shows the item")
now = 3
RunTimers()
check(not hoverRow.expired and not hoverRow.fading, "clock frozen while hovered")
local arrived = 0
L.Rows.Acquire = function(...) arrived = arrived + 1; return realAcq(...) end
L.Queue.Add(junk, nil)
tick(); tick()
L.Rows.Acquire = realAcq
check(arrived == 0, "queue paused while hovered")
hoverRow.scripts.OnLeave(hoverRow)
check(not hoverRow.fading and hoverRow.remaining == LootiConfig.displayDuration, "full time left after a 3s hover: " .. tostring(hoverRow.remaining))
RunTimers()
check(hoverRow.expired and hoverRow.fading, "fades once its time runs out")
hoverRow.scripts.OnEnter(hoverRow)
check(not hoverRow.fading, "hovering mid-fade brings it back")
hoverRow.scripts.OnLeave(hoverRow)
for _ = 1, 5 do RunTimers() end
check(hoverRow.shown == false, "retired after the fade")
LootiConfig.showTooltip, LootiConfig.pauseOnHover = false, false
C_Timer.After, GetTime = realAfter, realGetTime
C_Timer.NewTicker = realTicker

print("Sound")
for k in pairs(played) do played[k] = nil end
L.Features.OnNotify(gear)
check(#played == 1 and played[1][1] == 8959 and played[1][2] == "Master", "watched item plays the raid warning sound")
for k in pairs(played) do played[k] = nil end
L.Features.OnNotify(junk); L.Features.OnNotify(nil)
check(#played == 0, "unwatched item and money are silent")
LootiConfig.watchlistSound = false
L.Features.OnNotify(gear)
check(#played == 0, "sound toggle off silences it")

print(M.failures == 0 and "ALL PASSED" or (M.failures .. " FAILED"))

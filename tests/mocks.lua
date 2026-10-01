-- Mock WoW client and AceGUI, enough to load Looti outside the game.
-- Returns the addon table, the frames created, the sounds played, and a check helper.
local M = { failures = 0, allFrames = {}, played = {} }

function M.check(cond, msg)
    if cond then print("  ok   " .. msg) else M.failures = M.failures + 1; print("  FAIL " .. msg) end
end
local allFrames, played = M.allFrames, M.played

-- Mock regions and frames ---------------------------------------------------
local function noop() end
-- Unknown methods (capitalised) are no-ops; unknown fields stay nil.
local FALLBACK = { __index = function(_, k) if type(k) == "string" and k:match("^%u") then return noop end end }
local function Region(kind, parent)
    local r = { kind = kind or "Texture", shown = true, points = {}, parent = parent }
    function r:SetPoint(...) self.points[#self.points + 1] = { ... } end
    function r:ClearAllPoints() self.points = {} end
    function r:Show() self.shown = true end
    function r:Hide() self.shown = false end
    function r:SetShown(v) self.shown = v and true or false end
    function r:IsShown() return self.shown end
    function r:GetObjectType() return self.kind end
    function r:GetParent() return self.parent end
    function r:SetTexture(t) self.texture = t end
    function r:SetColorTexture(...) self.color = { ... } end
    function r:SetText(t) self.text = t end
    function r:SetTextColor(...) self.textColor = { ... } end
    function r:SetHeight(h) self.h = h end
    function r:SetWidth(w) self.w = w end
    function r:GetHeight() return self.h or 0 end
    function r:GetWidth() return self.w or 0 end
    function r:SetSize(w, h) self.w, self.h = w, h end
    function r:CreateTexture(...) local t = Region("Texture", self); t.args = { ... }; return t end
    function r:CreateFontString() return Region("FontString", self) end
    function r:RegisterEvent(e) self.events = self.events or {}; self.events[e] = true end
    function r:SetScript(name, fn) self.scripts = self.scripts or {}; self.scripts[name] = fn end
    function r:GetChildren() return table.unpack(self.children or {}) end
    return setmetatable(r, FALLBACK)
end

CreateFrame = function(kind, name, parent) local f = Region(kind or "Frame", parent); allFrames[#allFrames + 1] = f; return f end
UIParent = Region("Frame")
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) print("  chat: " .. m) end }
SlashCmdList = {}
C_Timer = { After = noop, NewTicker = function() return { Cancel = noop } end }
UIFrameFadeIn, UIFrameFadeOut = noop, noop
GetTime = function() return 0 end
wipe = function(t) for k in pairs(t) do t[k] = nil end return t end
strtrim = function(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
StaticPopupDialogs = {}
StaticPopup_Show = noop
PlaySound = function(id, channel) played[#played + 1] = { id, channel } end

-- Items: name, link, rarity, base level, equipLoc, icon, classID, bindType, detailed level
M.ITEMS = {
    [1001] = { "Broken Fang", 0, 1, "", "fang", 15, 0 },
    [1002] = { "Tigerseye", 2, 10, "", "gem", 3, 0 },
    [1003] = { "Sword", 3, 580, "INVTYPE_WEAPON", "sword", 2, 1, 639 },
    [1004] = { "Grey Trinket Thing", 0, 1, "", "thing", 15, 0 },
    [1005] = { "Hated But Wanted", 2, 5, "", "hbw", 15, 0 },
    [2000] = { "Equipped Sword", 3, 600, "INVTYPE_WEAPON", "esword", 2, 1, 600 },
}
local ITEMS = M.ITEMS
local function LinkFor(id) return M.LinkFor(id) end
function M.LinkFor(id) return "|cffffffff|Hitem:" .. id .. "::::|h[" .. ITEMS[id][1] .. "]|h|r" end
local function IdOf(item) return type(item) == "number" and item or tonumber(tostring(item):match("item:(%d+)")) end
C_CurrencyInfo = { GetCoinTextureString = function(c) return tostring(c) .. "c" end, GetCurrencyInfo = function(id) if id == 3008 then return { name = "Valorstones", iconFileID = 5868902, quality = 3 } end end }
C_Item = {
    GetItemInfo = function(item)
        local d = ITEMS[IdOf(item)]
        if not d then return nil end
        return d[1], LinkFor(IdOf(item)), d[2], d[3], 0, "", "", 1, d[4], d[5], 0, d[6], 0, d[7]
    end,
    GetItemQualityColor = function(q) return q / 10, 0.5, 1 - q / 10 end,
    IsEquippableItem = function(item) return ITEMS[IdOf(item)][4] ~= "" end,
    GetDetailedItemLevelInfo = function(item) local d = ITEMS[IdOf(item)]; return d and d[8] end,
    GetItemInfoInstant = function(item) return type(item) == "string" and item == "Sword" and 1003 or nil end,
}
GetInventoryItemLink = function(_, slot) if slot == 16 then return LinkFor(2000) end end

-- Fake AceGUI ---------------------------------------------------------------
M.layouts, M.released = {}, {}
local layouts, released = M.layouts, M.released
local function FakeWidget(kind)
    local w = { type = kind, children = {}, callbacks = {} }
    w.frame = Region("Frame")
    w.frame.obj = w
    w.content = Region("Frame")
    w.content.obj = w
    function w:AddChild(c) self.children[#self.children + 1] = c end
    function w:ReleaseChildren() self.children = {} end
    function w:SetCallback(n, fn) self.callbacks[n] = fn end
    function w:Fire(n, ...) if self.callbacks[n] then return self.callbacks[n](self, n, ...) end end
    function w:SelectTab(id) self:Fire("OnGroupSelected", id) end
    function w:SetLayout(name) self.layout = name end
    function w:SetHeight(h) self.height = h; self.frame.h = h end
    function w:SetWidth(v) self.width = v; self.frame.w = v end
    function w:SetRelativeWidth(r) assert(r > 0 and r <= 1, "bad relative width"); self.relWidth = r end
    function w:SetFullWidth() self.fullWidth = true end
    function w:SetText(t) self.text = t end
    function w:SetLabel(t) self.label = t end
    function w:SetValue(v) self.value = v end
    function w:SetColor(r, g, b) self.color = { r, g, b } end
    function w:SetJustifyH(j) self.justify = j end
    function w:SetTitle(t) self.title = t end
    function w:SetStatusText(t) self.statustext:SetText(t) end
    function w:Hide() self:Fire("OnClose") end
    if kind == "Frame" then
        local statusBar = Region("Button"); statusBar.obj = w
        local closeButton = Region("Button"); closeButton.obj = w
        local title = Region("Frame")
        w.statustext = Region("FontString", statusBar)
        w.frame.children = { closeButton, statusBar, title, w.content }
        w.statusBar, w.closeButton = statusBar, closeButton
        w.SetHeight = function(self, h) self.frame.h = h; self.content.height = h - 57 end
    end
    return setmetatable(w, FALLBACK)
end
M.AceGUI = {
    RegisterLayout = function(_, name, fn) layouts[name] = fn end,
    Create = function(_, kind) return FakeWidget(kind) end,
    Release = function(_, w) released[#released + 1] = w end,
}
local AceGUI = M.AceGUI
LibStub = function() return AceGUI end


-- input: the locale's client strings
-- output: the addon's private table
-- Loads every file the .toc lists, except the libraries, with the given strings
-- as globals. ADDON_DIR and TOC come from run.js.
function M.LoadAddon(strings)
    for key, value in pairs(strings) do _G[key] = value end
    local L = {}
    local toc = TOC
    for line in toc:gmatch("[^\r\n]+") do
        if line:match("%.lua$") and not line:match("^Libs") then
            local chunk = assert(loadfile(ADDON_DIR .. "/" .. line:gsub("\\", "/")))
            chunk("Looti", L)
        end
    end
    L.Db.Load()
    L.Anchor.LoadPosition()
    return L
end

return M

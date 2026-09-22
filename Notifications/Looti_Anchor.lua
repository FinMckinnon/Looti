-- The draggable frame that notifications are positioned against.
local ADDON, L = ...

L.Anchor = {}

local BACKDROP = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    tile = true,
    tileSize = 32,
    edgeSize = 0,
    insets = { left = 10, right = 10, top = 10, bottom = 10 },
}

local frame = CreateFrame("Frame", "notificationFrame", UIParent, L.Compat.BACKDROP_TEMPLATE)
frame:SetSize(L.Const.FRAME.NOTIFICATION_WIDTH, L.Const.FRAME.NOTIFICATION_HEIGHT + 2)
frame:SetClampedToScreen(true)
frame:SetFrameStrata("BACKGROUND")
frame:SetMovable(true)
frame:EnableMouse(true)
L.Compat.SetBackdrop(frame, BACKDROP, 0, 0, 0, 0)

local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
title:SetPoint("TOP", frame, "TOP", 0, -12)
title:SetText(L.Text.ANCHOR_TITLE)
title:Hide()

local doneButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
doneButton:SetSize(25, 25)
doneButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
doneButton.icon = doneButton:CreateTexture(nil, "ARTWORK")
doneButton.icon:SetAllPoints()
doneButton.icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
doneButton:Hide()

local moveMode = false

L.Anchor.frame = frame

-- input: nothing
-- output: nothing
-- Writes the frame's centre offset to the saved variables.
function L.Anchor.SavePosition()
    local parentX, parentY = UIParent:GetCenter()
    local frameX, frameY = frame:GetCenter()
    if not (parentX and parentY and frameX and frameY) then
        return
    end

    local x, y = frameX - parentX, frameY - parentY

    -- Re-anchor to the same reference the load path uses, so a drag that left
    -- the frame anchored elsewhere still round-trips.
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", x, y)

    LootiConfig.notificationFrameX = x
    LootiConfig.notificationFrameY = y
end

-- input: nothing
-- output: nothing
-- Places the frame at its saved position.
function L.Anchor.LoadPosition()
    local x = LootiConfig.notificationFrameX or 0
    local y = LootiConfig.notificationFrameY or 0

    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
end

-- input: nothing
-- output: true while the frame is being positioned
-- Reports whether move mode is on.
function L.Anchor.IsMoveMode()
    return moveMode
end

-- input: true to show the mover, false to hide it
-- output: nothing
-- Switches the frame between move mode and normal play.
function L.Anchor.SetMoveMode(enabled)
    enabled = enabled and true or false
    if moveMode == enabled then
        return
    end

    moveMode = enabled

    title:SetShown(enabled)
    doneButton:SetShown(enabled)
    L.Compat.SetBackdrop(frame, BACKDROP, 0, 0, 0, enabled and 0.5 or 0)
    frame:EnableMouse(enabled)
    frame:SetMovable(enabled)
    frame:SetFrameStrata(enabled and "HIGH" or "BACKGROUND")
end

frame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and moveMode then
        self:StartMoving()
    end
end)

frame:SetScript("OnMouseUp", function(self)
    self:StopMovingOrSizing()
    L.Anchor.SavePosition()

    if L.Queue then
        L.Queue.UpdatePositions()
    end
end)

doneButton:SetScript("OnClick", function()
    L.Anchor.SavePosition()
    L.Anchor.SetMoveMode(false)
end)

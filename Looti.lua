-- Create a draggable frame for moving loot notification area
notificationFrame = CreateFrame("Frame", "notificationFrame", UIParent, "BackdropTemplate")
notificationFrame:SetSize(LootiNotificationSettings.NOTIFICATION_FRAME_WIDTH,
    LootiNotificationSettings.NOTIFICATION_FRAME_HEIGHT + 2)
notificationFrame:SetClampedToScreen(true)
notificationFrame:SetFrameStrata("BACKGROUND")
notificationFrame:SetMovable(true)
notificationFrame:EnableMouse(true)
notificationFrame:SetBackdropColor(0, 0, 0, 0)

-- Set background for the move frame (optional)
notificationFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    tile = true,
    tileSize = 32,
    edgeSize = 0,
    insets = { left = 10, right = 10, top = 10, bottom = 10 }
})
notificationFrame:SetBackdropColor(0, 0, 0, 0)

-- Create a title text for the movable frame
local title = notificationFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
title:SetPoint("TOP", notificationFrame, "TOP", 0, -12)
title:SetText("Loot Notifications")
title:Hide()

local function SaveFramePosition()
    local point, _, _, x, y = notificationFrame:GetPoint()
    LootiConfig.notificationFrameX = x
    LootiConfig.notificationFrameY = y
end

local function LoadFramePosition()
    if LootiConfig.notificationFrameX and LootiConfig.notificationFrameY then
        notificationFrame:SetPoint("CENTER", UIParent, "CENTER", LootiConfig.notificationFrameX,
            LootiConfig.notificationFrameY)
    else
        notificationFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

-- Make the notificationFrame draggable by clicking the title
notificationFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        self:StartMoving()
    end
end)
notificationFrame:SetScript("OnMouseUp", function(self)
    self:StopMovingOrSizing()
    UpdateNotificationPositions()
end)

-- Create a toggle button to disable notificationFrame (tick mark)
local toggleButton = CreateFrame("Button", nil, notificationFrame, "UIPanelButtonTemplate")
toggleButton:SetSize(25, 25)
toggleButton:SetPoint("TOPRIGHT", notificationFrame, "TOPRIGHT", -5, -5)
toggleButton.icon = toggleButton:CreateTexture(nil, "ARTWORK")
toggleButton.icon:SetAllPoints()
toggleButton.icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
toggleButton:SetScript("OnClick", function(self)
    SaveFramePosition()
    NotificationManager:SetShowNotificationFrame(false)
end)
toggleButton:Hide()

-- Set notification frame visibility
NotificationManager:AddListener(function(isVisible)
    if isVisible then
        title:Show()
        toggleButton:Show()
        notificationFrame:SetBackdropColor(0, 0, 0, 0.5)
        notificationFrame:EnableMouse(true)
        notificationFrame:SetMovable(true)
        notificationFrame:SetFrameStrata("HIGH")
    else
        title:Hide()
        toggleButton:Hide()
        notificationFrame:SetBackdropColor(0, 0, 0, 0)
        notificationFrame:EnableMouse(false)
        notificationFrame:SetMovable(false)
        notificationFrame:SetFrameStrata("BACKGROUND")
    end
end)

-- var for tracking loot slots when loot window is opened
local lootSlots = {}

local function handleLootReady()
    wipe(lootSlots)
    local numSlots = GetNumLootItems()
    for slot = 1, numSlots do
        local link = GetLootSlotLink(slot)
        if link then
            local _, _, quantity = GetLootSlotInfo(slot)

            lootSlots[slot] = {
                link = link,
                quantity = quantity or 1,
            }
        end
    end
end

local function handleLootSlotCleared(slot)
    local data = lootSlots[slot]
    if data then
        HandleLootMessage(notificationFrame, data.link, data.quantity)
        lootSlots[slot] = nil
    end
end

-- Listener for loot/money events
local frame = CreateFrame("Frame")
frame:RegisterEvent("LOOT_READY")
frame:RegisterEvent("LOOT_SLOT_CLEARED")
frame:RegisterEvent("CHAT_MSG_MONEY")
frame:RegisterEvent("LOOT_ITEM_ROLL_WON")
frame:RegisterEvent("ADDON_LOADED")

-- Required
-- Master Looter assigning an item.
--      Currently no way to implement this with out checking chat event.

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "Looti" then
            NotificationManager:SetShowNotificationFrame(false)
            EnsureLootiSettings()
            LoadFramePosition()
        end
    elseif event == "CHAT_MSG_MONEY" then
        local message = ...
        HandleMoneyMessage(notificationFrame, message)
    elseif event == "LOOT_READY" then
        handleLootReady()
    elseif event == "LOOT_SLOT_CLEARED" then
        local slot = ...
        handleLootSlotCleared(slot)
    elseif event == "LOOT_ITEM_ROLL_WON" then
        local itemLink, rollQuantity, _, _, _, rollerId = ...
        if itemLink and rollerId == UnitGUID("player") then
            HandleLootMessage(notificationFrame, itemLink, rollQuantity or 1)
        end
    end
end)

-- Create a draggable frame for moving loot notification area
notificationFrame = CreateFrame("Frame", "notificationFrame", UIParent, "BackdropTemplate")
notificationFrame:SetSize(LootiNotificationSettings.NOTIFICATION_FRAME_WIDTH, LootiNotificationSettings.NOTIFICATION_FRAME_HEIGHT + 2)
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
        notificationFrame:SetPoint("CENTER", UIParent, "CENTER", LootiConfig.notificationFrameX, LootiConfig.notificationFrameY)
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

-- Listener for loot/money events
local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_LOOT")
frame:RegisterEvent("CHAT_MSG_MONEY")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "Looti" then
            NotificationManager:SetShowNotificationFrame(false)
            EnsureLootiSettings()
            LoadFramePosition()
        end
    elseif event == "CHAT_MSG_LOOT" then
        local message = ...
        handleLootMessage(notificationFrame, message)
    elseif event == "CHAT_MSG_MONEY" then
        local message = ...
        handleMoneyMessage(notificationFrame, message)
    end
end)

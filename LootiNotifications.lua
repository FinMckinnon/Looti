local activeNotifications = {}
local notificationStack = {}
local ticker
local fadeoutTime = 0.5
local frameMargin = 5

local function setNotificationData(itemData, currencyData, rarity, text, icon)
    local contentText, contentIcon, r, g, b

    if itemData then
        r, g, b = GetRarityColor(rarity)
        contentText, contentIcon = itemData.itemName, itemData.itemIcon
    else
        r, g, b = 1, 1, 1
        contentText, contentIcon = currencyData.text, currencyData.icon
    end

    text:SetTextColor(r, g, b)
    text:SetText(contentText)
    if icon and contentIcon then
        icon:SetTexture(contentIcon)
    end
end

local function getNotificationData(notification)
    local text, icon
    local iconMarginX, textMarginX
    local initialMarginX = LootiConfig.iconSize + (frameMargin * 2)
    local iconMarginModifier = 0

    -- Calculate icon margin modifier
    if LootiConfig.iconDisplay == "LEFT" then
        iconMarginModifier = -1
    elseif LootiConfig.iconDisplay == "RIGHT" then
        iconMarginModifier = 1
    end

    -- Create text if enabled
    if LootiConfig.showText then
        text = notification:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        
        -- Determine the position of the text based on the icon display and text display settings
        if LootiConfig.textDisplay == "LEFT" and LootiConfig.iconDisplay == "LEFT" then
            textMarginX = initialMarginX
        elseif LootiConfig.textDisplay == "RIGHT" and LootiConfig.iconDisplay == "RIGHT" then
            textMarginX = -initialMarginX
        else
            textMarginX = 0
        end
        
        text:SetPoint(LootiConfig.textDisplay, notification, LootiConfig.textDisplay, textMarginX, 0)
    end

    -- Create icon if enabled
    if LootiConfig.showIcon then
        icon = notification:CreateTexture(nil, "ARTWORK")
        icon:SetSize(LootiConfig.iconSize, LootiConfig.iconSize)

        -- If text exists, adjust icon positioning relative to the text
        if text then
            iconMarginX = (LootiConfig.iconSize + frameMargin) * iconMarginModifier
            icon:SetPoint(LootiConfig.iconDisplay, text, LootiConfig.iconDisplay, iconMarginX, 0)
        else
            -- If no text, position the icon in its own place
            icon:SetPoint(LootiConfig.iconDisplay, notification, LootiConfig.iconDisplay, iconMarginX, 0)
        end
    end

    return text, icon
end

local function ProcessNotifications()
    if #notificationStack == 0 then
        if ticker then
            ticker:Cancel()
            ticker = nil
        end
        return
    end

    local data = table.remove(notificationStack, 1)
    Looti_ShowNotification(data.parent, data.itemData, data.currencyData, data.rarity)
end

local function TryProcessNotifications()
    if #activeNotifications < LootiConfig.maximumNotifications or LootiConfig.maximumNotifications == 0 then
        ProcessNotifications()
    else
        C_Timer.After(0.05, TryProcessNotifications) 
    end
end

local function AddNotification(parent, itemData, currencyData, rarity)
    if #activeNotifications == 0 then
        Looti_ShowNotification(parent, itemData, currencyData, rarity)
    else
        table.insert(notificationStack, { parent = parent, itemData = itemData, currencyData = currencyData, rarity = rarity })
        if not ticker then
            ticker = C_Timer.NewTicker(LootiConfig.notificationDelay, TryProcessNotifications)
        end
    end
end

function Looti_ShowNotification(parent, itemData, currencyData, rarity)
    if itemData and not LootiConfig.showLootNotifications then return end
    if currencyData and not LootiConfig.showMoneyNotifications then return end
    if itemData and rarity < LootiConfig.notificationThreshold then return end

    local notification = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    notification:SetSize(LootiNotificationSettings.NOTIFICATION_FRAME_WIDTH, LootiNotificationSettings.NOTIFICATION_FRAME_HEIGHT)

    if LootiConfig.displayBackground then
        notification:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 32 })
        notification:SetBackdropColor(0, 0, 0, 0.8)
    end

    local text, icon = getNotificationData(notification)
    if not text and not icon then 
        return 
    end

    setNotificationData(itemData, currencyData, rarity, text, icon)
    table.insert(activeNotifications, 1, notification)

    UIFrameFadeIn(notification, 0.5, 0, 1)
    C_Timer.After(0.05, UpdateNotificationPositions)

    C_Timer.After(LootiConfig.displayDuration, function()
        UIFrameFadeOut(notification, fadeoutTime, 1, 0)
        C_Timer.After(fadeoutTime, function()
            for i, frame in ipairs(activeNotifications) do
                if frame == notification then
                    table.remove(activeNotifications, i)
                    break
                end
            end
            notification:Hide()
            UpdateNotificationPositions()
        end)
    end)
end

function UpdateNotificationPositions()
    for i, frame in ipairs(activeNotifications) do
        local yOffset = (i - 1) * LootiNotificationSettings.SPACING
        frame:ClearAllPoints()
        frame:SetPoint(LootiConfig.scrollDirection == "up" and "BOTTOM" or "TOP", notificationFrame, LootiConfig.scrollDirection == "up" and "BOTTOM" or "TOP", 0, LootiConfig.scrollDirection == "up" and -yOffset or yOffset)
    end
end

local function getQuantityText(quantity)
    return (quantity > 1) and "x" .. quantity or ""  
end

local function handleLootMessage(frame, message)
    if message:find("You loot") or message:find("You receive") then
        local itemLink = message:match("|c%x+|Hitem:.-|h|r")
        local quantity = tonumber(message:match("x(%d+)")) or 1  
        
        if itemLink then
            local itemName, _, itemRarity, _, _, _, _, _, _, itemIcon = GetItemInfo(itemLink)
            if itemName and itemIcon and itemRarity then
                if itemRarity >= LootiConfig.notificationThreshold then
                    local quantityText = LootiConfig.showQuantity and getQuantityText(quantity) or ""
                    local displayText = itemName .. " " .. quantityText
                    AddNotification(frame, { itemName = displayText, itemIcon = itemIcon }, nil, itemRarity)
                end
            end
        end
    end
end

local function handleMoneyMessage(frame, message)
    local gold = tonumber(message:match("(%d+) Gold") or 0) * 10000
    local silver = tonumber(message:match("(%d+) Silver") or 0) * 100
    local copper = tonumber(message:match("(%d+) Copper") or 0)
    local totalCopper = gold + silver + (copper or 0)
    
    if totalCopper > 0 then
        AddNotification(frame, nil, { totalCopper = totalCopper, text = GetCoinTextureString(totalCopper), icon = gold > 0 and currencyIcons.gold or silver > 0 and currencyIcons.silver or currencyIcons.copper }, nil)
    end
end

_G["handleLootMessage"] = handleLootMessage
_G["handleMoneyMessage"] = handleMoneyMessage
_G["AddNotification"] = AddNotification
_G["UpdateNotificationPositions"] = UpdateNotificationPositions
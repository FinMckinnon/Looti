local activeNotifications = {}
local notificationStack = {}
local ticker
local fadeoutTime = 0.5

local function setNotificationData(itemData, currencyData, rarity, text, icon)
    if itemData then
        local r, g, b = GetRarityColor(rarity)
        text:SetTextColor(r, g, b)
        text:SetText(itemData.itemName)
        icon:SetTexture(itemData.itemIcon)
    elseif currencyData then
        text:SetTextColor(1, 1, 1)
        text:SetText(currencyData.text)
        icon:SetTexture(currencyData.icon)
    end
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

    local icon = notification:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("LEFT", notification, "LEFT", 5, 0)

    local text = notification:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    text:SetPoint("LEFT", icon, "RIGHT", 10, 0)

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
        local yOffset = LootiNotificationSettings.BASE_Y + (i - 1) * LootiNotificationSettings.SPACING
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
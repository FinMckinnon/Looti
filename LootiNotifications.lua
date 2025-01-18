local activeNotifications = {}

-- Function to set notification data
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

-- Show notification
function Looti_ShowNotification(parent, itemData, currencyData, rarity)
    if not lootFlags[rarity] then
        return
    end

    local notification = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    notification:SetSize(LootiNotificationSettings.NOTIFICATION_WIDTH, LootiNotificationSettings.NOTIFICATION_HEIGHT)

    if LootiConfig.displayBackground then
        notification:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            tile = true,
            tileSize = 32,
            edgeSize = 0,
            insets = { left = 10, right = 10, top = 10, bottom = 10 }
        })
        notification:SetBackdropColor(0, 0, 0, 0.8)
    else
        notification:SetBackdrop(nil)
    end

    local icon = notification:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("LEFT", notification, "LEFT", 5, 0)

    local text = notification:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    text:SetPoint("LEFT", icon, "RIGHT", 10, 0)

    setNotificationData(itemData, currencyData, rarity, text, icon)
    table.insert(activeNotifications, 1, notification)

    local delay = 0.15
    C_Timer.After(delay, function()
        UIFrameFadeIn(notification, 0.5, 0, 1)
        C_Timer.After(0.05, UpdateNotificationPositions)
    end)

    C_Timer.After(LootiConfig.displayDuration + delay, function()
        UIFrameFadeOut(notification, 0.5, 1, 0)
        C_Timer.After(0.5, function()
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

-- Update notification positions
function UpdateNotificationPositions()
    for i, frame in ipairs(activeNotifications) do
        local yOffset = LootiNotificationSettings.BASE_Y + (i - 1) * LootiNotificationSettings.SPACING
        frame:ClearAllPoints()
        local startPoint = "TOP"
        if LootiConfig.scrollDirection == "up" then
            yOffset = -yOffset
            startPoint = "BOTTOM"
        end
        frame:SetPoint(startPoint, notificationFrame, startPoint, 0, yOffset)
    end
end


local function handleLootMessage(frame, message)
    if LootiConfig.showLootNotifications then
        if message:find("You receive loot") or message:find("You have looted") then
            local itemLink = message:match("|c%x+|Hitem:.-|h|r")
            if itemLink then
                local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(itemLink)
                if itemName and itemIcon and itemRarity then
                    if itemRarity >= LootiConfig.notificationThreshold then
                        local itemData = {itemName = itemName, itemIcon = itemIcon}
                        Looti_ShowNotification(frame, itemData, nil, itemRarity)
                    end
                end
            end
        end
    end
end

local function handleMoneyMessage(frame, message)
    if LootiConfig.showMoneyNotifications then
        -- Process money loot with support for multiple denominations
        local gold, silver, copper = 0, 0, 0
        
        -- Check for gold, silver, and copper in the loot message
        gold = tonumber((message:match("(%d+) Gold")) or 0)
        silver = tonumber((message:match("(%d+) Silver")) or 0)
        copper = tonumber((message:match("(%d+) Copper")) or 0)

        -- If any money is looted, display the notification
        if gold > 0 or silver > 0 or copper > 0 then
            local totalCopper = (gold * 10000) + (silver * 100) + copper
            local moneyData = {
                totalCopper = totalCopper,
                text = GetCoinTextureString(totalCopper),
                icon = gold > 0 and currencyIcons.gold or silver > 0 and currencyIcons.silver or currencyIcons.copper,
            }

            -- Show notification for looted money
            Looti_ShowNotification(frame, nil, moneyData, -1)  -- -1 can be used for money items or a custom rarity
        end
    end
end

_G["handleLootMessage"] = handleLootMessage
_G["handleMoneyMessage"] = handleMoneyMessage
_G["Looti_ShowNotification"] = Looti_ShowNotification
_G["UpdateNotificationPositions"] = UpdateNotificationPositions

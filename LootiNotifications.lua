local activeNotifications = {}
local notificationStack = {}
local ticker
local fadeoutTime = 0.5
local frameMargin = 5

local function getQuantityText(quantity)
    return (quantity and quantity > 1) and "x" .. quantity or ""
end

local function isEquippableUpgrade(equipSlot, itemLevel)
    -- If item is not equippable, return false
    if not equipSlot or equipSlot == "" or equipSlot == "INVTYPE_NON_EQUIP" then
        return false
    end

    -- Map equipment slots to inventory slot IDs
    local slotMap = {
        INVTYPE_HEAD = 1,
        INVTYPE_NECK = 2,
        INVTYPE_SHOULDER = 3,
        INVTYPE_BODY = 4,
        INVTYPE_CHEST = 5,
        INVTYPE_ROBE = 5,
        INVTYPE_WAIST = 6,
        INVTYPE_LEGS = 7,
        INVTYPE_FEET = 8,
        INVTYPE_WRIST = 9,
        INVTYPE_HAND = 10,
        INVTYPE_FINGER = { 11, 12 }, -- Two ring slots
        INVTYPE_TRINKET = { 13, 14 }, -- Two trinket slots
        INVTYPE_CLOAK = 15,
        INVTYPE_WEAPON = 16,
        INVTYPE_SHIELD = 17,
        INVTYPE_2HWEAPON = 16,
        INVTYPE_WEAPONMAINHAND = 16,
        INVTYPE_WEAPONOFFHAND = 17,
        INVTYPE_HOLDABLE = 17,
        INVTYPE_RANGED = 16,
        INVTYPE_THROWN = 16,
        INVTYPE_RANGEDRIGHT = 16,
        INVTYPE_RELIC = 16,
    }

    local slots = slotMap[equipSlot]
    if not slots then
        return false
    end


    -- Handle slots that can have multiple positions (rings, trinkets)
    if type(slots) == "table" then
        for _, slotID in ipairs(slots) do
            local equippedLink = GetInventoryItemLink("player", slotID)
            if equippedLink then
                local equippedItemLevel = C_Item.GetCurrentItemLevel(ItemLocation:CreateFromEquipmentSlot(slotID))
                if itemLevel > equippedItemLevel then
                    return true
                end
            else
                -- Nothing equipped, so it's an upgrade
                return true
            end
        end

        return false
    else
        -- Single slot
        local equippedLink = GetInventoryItemLink("player", slots)
        if not equippedLink then
            -- Nothing equipped, so it's an upgrade
            return true
        end

        local equippedItemLevel = C_Item.GetCurrentItemLevel(ItemLocation:CreateFromEquipmentSlot(slots))
        return itemLevel > equippedItemLevel
    end
end


local function setNotificationData(itemData, currencyData, text, icon, upgradeIcon)
    local contentText, contentIcon, r, g, b, isUpgrade

    if itemData then
        local itemLevel = itemData.itemLevel
        local itemEquipLoc = itemData.itemEquipLoc

        r, g, b = GetRarityColor(itemData.itemRarity)
        local quantityText = LootiConfig.showQuantity and getQuantityText(itemData.itemQuantity) or ""
        local gearItemText = LootiConfig.showItemLevel and "(Lvl " .. itemData.itemLevel .. ")" or ""
        isUpgrade = isEquippableUpgrade(itemEquipLoc, itemLevel)
        contentText = itemData.itemName .. " |cFFFFFFFF" .. quantityText .. " |cFFFFFFFF" .. gearItemText .. "|r"
        contentIcon = itemData.itemIcon
    else
        r, g, b = 1, 1, 1
        contentText, contentIcon = currencyData.text, currencyData.icon
    end

    text:SetTextColor(r, g, b, LootiConfig.notificationAlpha)
    text:SetText(contentText)
    text:SetScale(LootiConfig.notificationScale)
    if icon and contentIcon then
        icon:SetTexture(contentIcon)
        icon:SetAlpha(LootiConfig.notificationAlpha)
        icon:SetScale(LootiConfig.notificationScale)
    end
    if upgradeIcon and isUpgrade then
        upgradeIcon:SetTexture("Interface\\AddOns\\Looti\\Media\\green_up_arrow_icon.tga")
        upgradeIcon:SetAlpha(LootiConfig.notificationAlpha * 0.75)
        upgradeIcon:SetScale(LootiConfig.notificationScale)
    end
end

local function getNotificationData(notification)
    local text, icon, upgradeIcon
    local iconMarginX, textMarginX, upgradeIconMarginX
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

    -- Create upgrade if enabled
    if LootiConfig.showItemLevelUpgradeIcon then
        upgradeIcon = notification:CreateTexture(nil, "ARTWORK")
        upgradeIcon:SetSize(LootiConfig.iconSize / 2, LootiConfig.iconSize / 2)

        -- Always position upgrade icon to the right  of the text
        if text then
            upgradeIconMarginX = frameMargin
            upgradeIcon:SetPoint("LEFT", text, "RIGHT", upgradeIconMarginX, 0)
        else
            -- If no text, position the icon on the right edge of the frame
            upgradeIcon:SetPoint("RIGHT", notification, "RIGHT", -frameMargin, 0)
        end
    end


    return text, icon, upgradeIcon
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
    Looti_ShowNotification(data.parent, data.itemData, data.currencyData)
end

local function TryProcessNotifications()
    if #activeNotifications < LootiConfig.maximumNotifications or LootiConfig.maximumNotifications == 0 then
        ProcessNotifications()
    else
        C_Timer.After(0.05, TryProcessNotifications)
    end
end

local function AddNotification(parent, itemData, currencyData)
    if #activeNotifications == 0 then
        Looti_ShowNotification(parent, itemData, currencyData)
    else
        table.insert(notificationStack, { parent = parent, itemData = itemData, currencyData = currencyData })
        if not ticker then
            ticker = C_Timer.NewTicker(LootiConfig.notificationDelay, TryProcessNotifications)
        end
    end
end

function Looti_ShowNotification(parent, itemData, currencyData)
    if itemData and not LootiConfig.showLootNotifications then return end
    if currencyData and not LootiConfig.showMoneyNotifications then return end
    if itemData and itemData.itemRarity < LootiConfig.notificationThreshold then return end

    local notification = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    notification:SetSize(LootiNotificationSettings.NOTIFICATION_FRAME_WIDTH * LootiConfig.notificationScale,
        LootiNotificationSettings.NOTIFICATION_FRAME_HEIGHT * LootiConfig.notificationScale)

    if LootiConfig.displayBackground then
        notification:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 32 })
        notification:SetBackdropColor(0, 0, 0, LootiConfig.backgroundAlpha)
    end

    local text, icon, upgradeIcon = getNotificationData(notification)
    if not text and not icon and not upgradeIcon then
        return
    end

    setNotificationData(itemData, currencyData, text, icon, upgradeIcon)
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
        local yOffset = (i - 1) * (LootiNotificationSettings.SPACING * LootiConfig.notificationScale)
        frame:ClearAllPoints()
        frame:SetPoint(LootiConfig.scrollDirection == "up" and "BOTTOM" or "TOP", notificationFrame,
            LootiConfig.scrollDirection == "up" and "BOTTOM" or "TOP", 0,
            LootiConfig.scrollDirection == "up" and -yOffset or yOffset)
    end
end

local function handleLootMessage(frame, itemLink, itemQuantity)
    if itemLink then
        local itemName, _, itemRarity, itemLevel, _, _, _, _, itemEquipLoc, itemIcon = GetItemInfo(itemLink)
        if itemName and itemIcon and itemRarity then
            if itemRarity >= LootiConfig.notificationThreshold then
                AddNotification(frame,
                    { itemName = itemName, itemIcon = itemIcon, itemRarity = itemRarity, itemQuantity = itemQuantity, itemLevel =
                    itemLevel, itemEquipLoc = itemEquipLoc }, nil)
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
        AddNotification(frame, nil,
            {
                totalCopper = totalCopper,
                text = GetCoinTextureString(totalCopper),
                icon = gold > 0 and currencyIcons
                    .gold or silver > 0 and currencyIcons.silver or currencyIcons.copper
            }, nil)
    end
end

_G["handleLootMessage"] = handleLootMessage
_G["handleMoneyMessage"] = handleMoneyMessage
_G["AddNotification"] = AddNotification
_G["UpdateNotificationPositions"] = UpdateNotificationPositions

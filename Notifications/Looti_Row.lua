-- Pooled notification frames and the contents of one notification.
local ADDON, L = ...

L.Rows = {}

local BACKDROP = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    tile = true,
    tileSize = 32,
}

local free = {}
local generation = 0

-- input: an item link, its equip location and its item level
-- output: true when the item beats what is equipped
-- Compares an item against the slots it could occupy.
local function IsUpgrade(itemLink, equipLoc, itemLevel)
    if not itemLevel or not equipLoc or equipLoc == "" then
        return false
    end

    local slots = L.Const.EQUIP_SLOTS[equipLoc]
    if not slots or not L.Compat.IsEquippableItem(itemLink) then
        return false
    end

    for _, slotID in ipairs(slots) do
        local equippedLevel = L.Compat.EquippedItemLevel(slotID)
        if not equippedLevel or itemLevel > equippedLevel then
            return true
        end
    end

    return false
end

-- input: an item quantity
-- output: the quantity suffix, empty for a single item
-- Formats a stack count for display.
local function QuantityText(quantity)
    if quantity and quantity > 1 then
        return "x" .. quantity
    end

    return ""
end

-- input: nothing
-- output: a notification frame with its text, icon and upgrade regions attached
-- Builds one frame and its regions, which are then reused for every notification.
local function BuildRow()
    local row = CreateFrame("Frame", nil, L.Anchor.frame, L.Compat.BACKDROP_TEMPLATE)

    row.text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    row.icon = row:CreateTexture(nil, "ARTWORK")

    row.upgrade = row:CreateTexture(nil, "ARTWORK")
    row.upgrade:SetTexture(L.Const.UPGRADE_ICON)

    return row
end

-- input: a row
-- output: nothing
-- Sizes and anchors a row's regions from the current display settings.
local function ApplyLayout(row)
    local config = LootiConfig
    local margin = L.Const.FRAME.MARGIN
    local scale = config.notificationScale

    row:SetSize(L.Const.FRAME.NOTIFICATION_WIDTH * scale, L.Const.FRAME.NOTIFICATION_HEIGHT * scale)

    if config.displayBackground then
        L.Compat.SetBackdrop(row, BACKDROP, 0, 0, 0, config.backgroundAlpha)
    else
        L.Compat.SetBackdrop(row, nil)
    end

    row.text:ClearAllPoints()
    row.icon:ClearAllPoints()
    row.upgrade:ClearAllPoints()

    row.text:SetShown(config.showText)
    row.icon:SetShown(config.showIcon)
    row.upgrade:Hide()

    local iconSize = config.iconSize
    local initialMargin = iconSize + (margin * 2)

    if config.showText then
        local textMargin = 0
        if config.textDisplay == config.iconDisplay and config.showIcon then
            textMargin = config.iconDisplay == "LEFT" and initialMargin or -initialMargin
        end
        row.text:SetPoint(config.textDisplay, row, config.textDisplay, textMargin, 0)
        row.text:SetScale(scale)
    end

    if config.showIcon then
        row.icon:SetSize(iconSize, iconSize)
        row.icon:SetAlpha(config.notificationAlpha)
        row.icon:SetScale(scale)

        if config.showText then
            local modifier = config.iconDisplay == "LEFT" and -1 or 1
            local iconMargin = (iconSize + margin) * modifier
            row.icon:SetPoint(config.iconDisplay, row.text, config.iconDisplay, iconMargin, 0)
        else
            row.icon:SetPoint(config.iconDisplay, row, config.iconDisplay, 0, 0)
        end
    end

    row.upgrade:SetSize(iconSize / 2, iconSize / 2)
    row.upgrade:SetAlpha(config.notificationAlpha * 0.75)
    row.upgrade:SetScale(scale)

    if config.showText then
        row.upgrade:SetPoint("LEFT", row.text, "RIGHT", margin, 0)
    else
        row.upgrade:SetPoint("RIGHT", row, "RIGHT", -margin, 0)
    end
end

-- input: nothing
-- output: a row ready to be filled, and the generation it was acquired with
-- Takes a row from the pool or builds one, then stamps it.
function L.Rows.Acquire()
    local row = table.remove(free) or BuildRow()

    generation = generation + 1
    row.generation = generation

    ApplyLayout(row)
    row:Show()

    return row, generation
end

-- input: a row and the generation it was acquired with
-- output: nothing
-- Hides a row and returns it to the pool, ignoring an expiry from an earlier use.
function L.Rows.Release(row, atGeneration)
    if row.generation ~= atGeneration then
        return
    end

    row:Hide()
    row:ClearAllPoints()
    free[#free + 1] = row
end

-- input: a row, item data, and currency data
-- output: nothing
-- Writes one notification's text, icon and upgrade arrow into a row.
function L.Rows.Fill(row, itemData, currencyData)
    local config = LootiConfig
    local text, icon, red, green, blue
    local showUpgrade = false

    if itemData then
        red, green, blue = L.Compat.QualityColor(itemData.itemRarity)

        local quantity = config.showQuantity and QuantityText(itemData.itemQuantity) or ""
        local level = ""
        if config.showItemLevel and itemData.itemLevel then
            level = "(Lvl " .. itemData.itemLevel .. ")"
        end

        text = itemData.itemName .. " |cFFFFFFFF" .. quantity .. " |cFFFFFFFF" .. level .. "|r"
        icon = itemData.itemIcon

        showUpgrade = config.showItemLevelUpgradeIcon
            and IsUpgrade(itemData.itemLink, itemData.itemEquipLoc, itemData.itemLevel)
    else
        red, green, blue = 1, 1, 1
        text, icon = currencyData.text, currencyData.icon
    end

    if config.showText then
        row.text:SetTextColor(red, green, blue, config.notificationAlpha)
        row.text:SetText(text)
    end

    if config.showIcon and icon then
        row.icon:SetTexture(icon)
    end

    row.upgrade:SetShown(showUpgrade)
end

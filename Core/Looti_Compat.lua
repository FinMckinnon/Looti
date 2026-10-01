-- Wrappers for client API, feature-detected where a flavour may lack it.
local ADDON, L = ...

L.Compat = {}

local itemLocation = ItemLocation

L.Compat.BACKDROP_TEMPLATE = "BackdropTemplate"

-- input: an item link or item id
-- output: every GetItemInfo return, or nil when the client has not cached it
-- Calls C_Item.GetItemInfo.
function L.Compat.GetItemInfo(item)
    return C_Item.GetItemInfo(item)
end

-- input: an item rarity number
-- output: red, green and blue components
-- Returns the colour for a rarity, white for an unknown one.
function L.Compat.QualityColor(rarity)
    if not rarity then
        return 1, 1, 1
    end

    local r, g, b = C_Item.GetItemQualityColor(rarity)
    return r or 1, g or 1, b or 1
end

-- input: an item link
-- output: true when the item can be equipped
-- Reports whether the player could equip the item.
function L.Compat.IsEquippableItem(link)
    if not link then
        return false
    end

    return C_Item.IsEquippableItem(link) and true or false
end

-- input: an inventory slot id
-- output: the equipped item's level, or nil when the slot is empty
-- Reads the live item level where the client has it, otherwise the static one.
function L.Compat.EquippedItemLevel(slotID)
    local link = GetInventoryItemLink("player", slotID)
    if not link then
        return nil
    end

    if itemLocation then
        local location = itemLocation:CreateFromEquipmentSlot(slotID)
        local level = C_Item.GetCurrentItemLevel(location)
        if level and level > 0 then
            return level
        end
    end

    return select(4, C_Item.GetItemInfo(link))
end

-- input: a frame, a backdrop table, and optional colour components
-- output: nothing
-- Applies a backdrop, and its colour when one is given.
function L.Compat.SetBackdrop(frame, backdrop, red, green, blue, alpha)
    frame:SetBackdrop(backdrop)

    if backdrop and red then
        frame:SetBackdropColor(red, green, blue, alpha)
    end
end

-- input: a frame, a minimum width, a minimum height
-- output: nothing
-- Clamps a frame's minimum size.
function L.Compat.SetMinSize(frame, width, height)
    frame:SetResizeBounds(width, height)
end

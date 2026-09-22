-- Feature-detected wrappers for client API that is absent on some flavours.
local ADDON, L = ...

L.Compat = {}

local getItemInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
local getQualityColor = (C_Item and C_Item.GetItemQualityColor) or GetItemQualityColor
local isEquippable = (C_Item and C_Item.IsEquippableItem) or IsEquippableItem
local getCurrentItemLevel = C_Item and C_Item.GetCurrentItemLevel
local itemLocation = ItemLocation

-- Backdrops arrived as a template in 9.0 and were backported; older clients have none.
L.Compat.BACKDROP_TEMPLATE = BackdropTemplateMixin and "BackdropTemplate" or nil

-- input: an item link or item id
-- output: every GetItemInfo return, or nil when the client has not cached it
-- Calls whichever GetItemInfo this client exposes.
function L.Compat.GetItemInfo(item)
    return getItemInfo(item)
end

-- input: an item rarity number
-- output: red, green and blue components
-- Returns the colour for a rarity, white for an unknown one.
function L.Compat.QualityColor(rarity)
    if not rarity then
        return 1, 1, 1
    end

    local r, g, b = getQualityColor(rarity)
    return r or 1, g or 1, b or 1
end

-- input: an item link
-- output: true when the item can be equipped
-- Reports whether the player could equip the item.
function L.Compat.IsEquippableItem(link)
    if not link then
        return false
    end

    return isEquippable(link) and true or false
end

-- input: an inventory slot id
-- output: the equipped item's level, or nil when the slot is empty
-- Reads the live item level where the client has it, otherwise the static one.
function L.Compat.EquippedItemLevel(slotID)
    local link = GetInventoryItemLink("player", slotID)
    if not link then
        return nil
    end

    if getCurrentItemLevel and itemLocation then
        local location = itemLocation:CreateFromEquipmentSlot(slotID)
        local level = getCurrentItemLevel(location)
        if level and level > 0 then
            return level
        end
    end

    return select(4, getItemInfo(link))
end

-- input: a frame, a backdrop table, and optional colour components
-- output: nothing
-- Applies a backdrop where the client supports one, otherwise does nothing.
function L.Compat.SetBackdrop(frame, backdrop, red, green, blue, alpha)
    if not frame.SetBackdrop then
        return
    end

    frame:SetBackdrop(backdrop)

    if backdrop and frame.SetBackdropColor and red then
        frame:SetBackdropColor(red, green, blue, alpha)
    end
end

-- input: a frame, a minimum width, a minimum height
-- output: nothing
-- Clamps a frame's minimum size using whichever method this client exposes.
function L.Compat.SetMinSize(frame, width, height)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(width, height)
    elseif frame.SetMinResize then
        frame:SetMinResize(width, height)
    end
end

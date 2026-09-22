-- The scrolling list of items inside the filter editor.
local ADDON, L = ...

L.FilterGrid = {}

local ICON_SIZE = 24
local ROW_HEIGHT = 32

-- input: a table of item ids
-- output: a sorted array of those ids
-- Puts the item ids into a stable order.
local function SortedIDs(items)
    local ids = {}

    for itemID in pairs(items) do
        ids[#ids + 1] = itemID
    end

    table.sort(ids)
    return ids
end

-- input: a parent container, an item id, and a remove callback
-- output: nothing
-- Adds one row showing an item's icon, name and id.
local function AddRow(parent, itemID, onRemove)
    local AceGUI = L.AceGUI

    local row = AceGUI:Create("SimpleGroup")
    row:SetLayout("Flow")
    row:SetFullWidth(true)
    row:SetHeight(ROW_HEIGHT)
    parent:AddChild(row)

    local icon = AceGUI:Create("Icon")
    icon:SetImageSize(ICON_SIZE, ICON_SIZE)
    icon:SetWidth(ICON_SIZE + 8)
    row:AddChild(icon)

    local label = AceGUI:Create("Label")
    label:SetRelativeWidth(0.6)
    label:SetText(tostring(itemID))
    row:AddChild(label)

    L.UI.Button(row, "Remove", 80, function()
        onRemove(itemID)
    end)

    L.ItemCache.Resolve(itemID, function()
        local name, _, _, _, _, _, _, _, _, texture = L.Compat.GetItemInfo(itemID)
        if name then
            label:SetText(name .. " |cff888888" .. itemID .. "|r")
        end
        if texture then
            icon:SetImage(texture)
        end
    end)
end

-- input: a scroll container, a staged filter list, and a remove callback
-- output: nothing
-- Rebuilds the item rows from a staged filter list.
function L.FilterGrid.Build(container, staged, onRemove)
    container:ReleaseChildren()

    local ids = SortedIDs(staged.items)

    if #ids == 0 then
        local empty = L.AceGUI:Create("Label")
        empty:SetText("No items in this list yet.")
        empty:SetFullWidth(true)
        container:AddChild(empty)
        return
    end

    for _, itemID in ipairs(ids) do
        AddRow(container, itemID, onRemove)
    end
end

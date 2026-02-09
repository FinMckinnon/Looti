local columnWidth = 375
-- Make the editor wider so 3-column cells have room for icon+name inline
local minWidth, minHeight = 600, 675

local function UpdateSelectedItemDisplay(itemID, itemIcon, itemNameLabel)
    local item = Item:CreateFromItemID(itemID)
    item:ContinueOnItemLoad(function()
        local itemName = item:GetItemName()
        local itemIconTexture = item:GetItemIcon()
        if itemName and itemIconTexture then
            itemIcon:SetImage(itemIconTexture)
            itemNameLabel:SetText(itemName)
        else
            itemIcon:SetImage("Interface\\AddOns\\Looti\\Media\\green_up_arrow_icon.tga")
            itemNameLabel:SetText("Invalid ID")
        end
    end)
end

local function UpdateFilterList(scrollList, itemIDInput, listType, itemIcon, itemNameLabel)
    scrollList:ReleaseChildren()

    -- Render as a 3-column grid (cells expand right then wrap downward).
    if LootiFilters[listType] then
        local cols = 3
        local grid = AceGUI:Create("SimpleGroup")
        grid:SetLayout("Flow")
        grid:SetFullWidth(true)
        scrollList:AddChild(grid)

        for id in pairs(LootiFilters[listType]) do
            local item = Item:CreateFromItemID(id)
            item:ContinueOnItemLoad(function()
                local itemName = item:GetItemName()
                local itemIconTexture = item:GetItemIcon()

                if itemName then
                    local cell = AceGUI:Create("SimpleGroup")
                    cell:SetLayout("Flow")
                    cell:SetRelativeWidth(1 / cols)
                    cell:SetHeight(40)
                    cell:SetUserData("itemID", id)

                    -- Icon
                    local dispIcon = AceGUI:Create("Icon")
                    dispIcon:SetImage(itemIconTexture)
                    dispIcon:SetImageSize(28, 28)
                    dispIcon:SetWidth(36)
                    cell:AddChild(dispIcon)

                    -- Name (narrower so it sits inline with the icon)
                    local nameLabel = AceGUI:Create("Label")
                    nameLabel:SetText(itemName)
                    nameLabel:SetRelativeWidth(0.7)
                    cell:AddChild(nameLabel)

                    -- Click handling on the cell frame
                    local frame = cell.frame
                    frame:EnableMouse(true)
                    frame:SetScript("OnMouseUp", function()
                        itemIDInput:SetText(tostring(id))
                        UpdateSelectedItemDisplay(id, itemIcon, itemNameLabel)
                    end)

                    grid:AddChild(cell)
                end
            end)
        end
    end
end


local function CreateFilterEditor(listType, filterList)
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Filter Editor")
    frame:SetWidth(minWidth)
    frame:SetHeight(minHeight)
    frame:SetLayout("Flow")

    local bg = frame.frame

    -- Required in Classic / Wrath
    if not bg.SetBackdrop then
        Mixin(bg, BackdropTemplateMixin)
    end

    bg:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })

    bg:SetBackdropColor(0.08, 0.08, 0.08, 0.95) -- dark background
    bg:SetBackdropBorderColor(0, 0, 0, 1)

    -- Declare scrollList early to avoid nil reference in button callbacks
    local scrollList

    -- Controls container (input + buttons)
    local controlContainer = AceGUI:Create("InlineGroup")
    controlContainer:SetLayout("List")
    controlContainer:SetFullWidth(true)
    frame:AddChild(controlContainer)

    local selectedItemContainer = AceGUI:Create("SimpleGroup")
    selectedItemContainer:SetLayout("Flow")
    selectedItemContainer:SetFullWidth(true)
    controlContainer:AddChild(selectedItemContainer)

    -- Use Icon widget
    local itemIcon = AceGUI:Create("Icon")
    itemIcon:SetImageSize(32, 32)
    itemIcon:SetWidth(70)
    selectedItemContainer:AddChild(itemIcon)

    -- Use Label widget
    local itemNameLabel = AceGUI:Create("Label")
    itemNameLabel:SetText("No Item Selected")
    itemNameLabel:SetFontObject(GameFontNormalLarge)
    itemNameLabel:SetRelativeWidth(0.7)
    selectedItemContainer:AddChild(itemNameLabel)

    -- Input and Buttons Container
    local inputButtonContainer = AceGUI:Create("SimpleGroup")
    inputButtonContainer:SetLayout("Flow")
    inputButtonContainer:SetFullWidth(true)
    controlContainer:AddChild(inputButtonContainer)

    -- Item ID Input
    local itemIDInput = AceGUI:Create("EditBox")
    itemIDInput:SetLabel("Item ID")
    itemIDInput:SetWidth(200)
    itemIDInput:SetCallback("OnEnterPressed", function(widget, event, value)
        if value and value ~= "" then
            UpdateSelectedItemDisplay(tonumber(value), itemIcon, itemNameLabel)
        end
    end)
    inputButtonContainer:AddChild(itemIDInput)

    -- Buttons Container
    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetHeight(40)
    inputButtonContainer:AddChild(buttonGroup)

    local addBtn = AceGUI:Create("Button")
    addBtn:SetText("Add")
    addBtn:SetWidth(80)
    addBtn:SetCallback("OnClick", function()
        local id = itemIDInput:GetText()
        if id and id ~= "" then
            if not LootiFilters[listType] then
                LootiFilters[listType] = {}
            end
            LootiFilters[listType][tonumber(id)] = true
            itemIDInput:SetText("")
            UpdateFilterList(scrollList, itemIDInput, listType, itemIcon, itemNameLabel)
        end
    end)
    buttonGroup:AddChild(addBtn)

    local removeBtn = AceGUI:Create("Button")
    removeBtn:SetText("Remove")
    removeBtn:SetWidth(80)
    removeBtn:SetCallback("OnClick", function()
        local id = itemIDInput:GetText()
        if id and id ~= "" and LootiFilters[listType] then
            LootiFilters[listType][tonumber(id)] = nil
            itemIDInput:SetText("")
            UpdateFilterList(scrollList, itemIDInput, listType, itemIcon, itemNameLabel)
        end
    end)
    buttonGroup:AddChild(removeBtn)

    -- Scrollable List (fill remaining height)
    scrollList = AceGUI:Create("ScrollFrame")
    scrollList:SetFullWidth(true)
    scrollList:SetFullHeight(true)
    frame:AddChild(scrollList)

    UpdateFilterList(scrollList, itemIDInput, listType, itemIcon, itemNameLabel)

    return frame
end

_G["CreateFilterEditor"] = CreateFilterEditor

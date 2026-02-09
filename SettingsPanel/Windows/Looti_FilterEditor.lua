local columnWidth = 375
local minWidth, minHeight = columnWidth, 675

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
    if LootiFilters[listType] then
        for id in pairs(LootiFilters[listType]) do
            local item = Item:CreateFromItemID(id)
            item:ContinueOnItemLoad(function()
                local itemName = item:GetItemName()
                local itemIconTexture = item:GetItemIcon()
                if itemName then
                    -- Create container for icon and name with background
                    local itemRow = AceGUI:Create("InlineGroup")
                    itemRow:SetLayout("Flow")
                    itemRow:SetFullWidth(true)
                    itemRow:SetHeight(35)
                    itemRow:SetUserData("itemID", id)

                    -- Make background darker
                    local bg = itemRow.frame:GetRegions()
                    if bg and bg:GetObjectType() == "Texture" then
                        bg:SetColorTexture(0, 0, 0, 0.6)
                    end

                    scrollList:AddChild(itemRow)

                    -- Add icon to container
                    local dispIcon = AceGUI:Create("Icon")
                    dispIcon:SetImage(itemIconTexture)
                    dispIcon:SetImageSize(28, 28)
                    dispIcon:SetWidth(40)
                    itemRow:AddChild(dispIcon)

                    -- Add name label to container
                    local nameLabel = AceGUI:Create("Label")
                    nameLabel:SetText(itemName)
                    nameLabel:SetRelativeWidth(0.7)
                    itemRow:AddChild(nameLabel)

                    -- Make the row frame clickable
                    itemRow.frame:EnableMouse(true)
                    itemRow.frame:SetScript("OnMouseUp", function()
                        itemIDInput:SetText(tostring(id))
                        UpdateSelectedItemDisplay(id, itemIcon, itemNameLabel)
                    end)
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

local _, Looti = ...

local frameWidth = 600
local frameHeight = 675
local minWidth, minHeight = frameWidth, frameHeight

-- Set true for nil default text input
local invalidItemID = true

local function UpdateSelectedItemDisplay(itemID, itemIcon, itemNameLabel)
    local function setSelectedItemInfo(iconImage, labelText, isInvalid)
        itemIcon:SetImage(iconImage)
        itemNameLabel:SetText(labelText)
        invalidItemID = isInvalid or false
    end

    local function setInvalidItemInfo()
        local QUESTIONMARK_INV_ICON = 134400
        setSelectedItemInfo(QUESTIONMARK_INV_ICON, "Invalid ID", true)
    end

    itemID = tonumber(itemID)
    if not itemID then
        setInvalidItemInfo()
        return
    end

    -- Safety check for item info availability
    local _, _, _, _, icon = C_Item.GetItemInfoInstant(itemID)
    if not icon then
        setInvalidItemInfo()
        return
    end

    -- Safe to proceed
    local item = Item:CreateFromItemID(itemID)
    item:ContinueOnItemLoad(function()
        local itemName = item:GetItemName()
        local itemIconTexture = item:GetItemIcon()

        if itemName and itemIconTexture then
            setSelectedItemInfo(itemIconTexture, itemName, false)
        else
            setInvalidItemInfo()
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

        if not LootiFilters[listType].items then
            LootiFilters[listType].items = {}
        end

        for id in pairs(LootiFilters[listType].items) do
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
                    dispIcon.frame:EnableMouse(false)
                    cell:AddChild(dispIcon)

                    local nameLabel = AceGUI:Create("Label")
                    nameLabel:SetText(itemName)
                    nameLabel:SetRelativeWidth(0.7)
                    nameLabel.frame:EnableMouse(false)
                    cell:AddChild(nameLabel)

                    -- Click handling on the cell frame
                    local frame = cell.frame
                    frame:EnableMouse(true)
                    frame:SetScript("OnMouseUp", function()
                        itemIDInput:SetText(tostring(id))
                        UpdateSelectedItemDisplay(id, itemIcon, itemNameLabel)
                    end)

                    grid:AddChild(cell)
                    -- Force layout update so the scroll bar recalculates
                    scrollList:DoLayout()
                end
            end)
        end
    end
end


-- Configuration
local WINDOW_CONFIG = {
    blacklist = {
        title = "Blacklist Editor",
        isOpenFlag = "BlacklistWindowIsOpen"
    },
    whitelist = {
        title = "Whitelist Editor",
        isOpenFlag = "WhitelistWindowsIsOpen"
    }
}

-- State management
local function isWindowOpen(listType)
    local flagName = WINDOW_CONFIG[listType].isOpenFlag
    return _G[flagName]
end

local function setWindowOpen(listType, isOpen)
    local flagName = WINDOW_CONFIG[listType].isOpenFlag
    _G[flagName] = isOpen
end

-- UI Component Creators
local function CreateFrameBase(listType)
    local frame = AceGUI:Create("Frame")
    frame:SetWidth(minWidth)
    frame:SetHeight(minHeight)
    frame:SetLayout("Flow")
    frame:SetTitle(WINDOW_CONFIG[listType].title)

    -- Handle window state change on close
    frame:SetCallback("OnClose", function()
        setWindowOpen(listType, false)
    end)

    -- Backdrop setup
    local bg = frame.frame
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
    bg:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
    bg:SetBackdropBorderColor(0, 0, 0, 1)

    return frame
end

local function CreateSelectedItemDisplay(parent)
    local container = AceGUI:Create("SimpleGroup")
    container:SetLayout("Flow")
    container:SetFullWidth(true)
    parent:AddChild(container)

    local icon = AceGUI:Create("Icon")
    icon:SetImageSize(32, 32)
    icon:SetWidth(70)
    container:AddChild(icon)

    local nameLabel = AceGUI:Create("Label")
    nameLabel:SetText("Select or Add an Item")
    nameLabel:SetFontObject(GameFontNormalLarge)
    nameLabel:SetRelativeWidth(0.7)
    container:AddChild(nameLabel)

    return icon, nameLabel
end

local function CreateItemInput(parent, onEnterCallback)
    local input = AceGUI:Create("EditBox")
    input:SetLabel("Item ID")
    input:SetWidth(200)
    input:SetCallback("OnEnterPressed", onEnterCallback)
    parent:AddChild(input)
    return input
end

local function CreateActionButtons(parent, listType, itemIDInput, scrollList, itemIcon, itemNameLabel)
    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetHeight(40)
    parent:AddChild(buttonGroup)

    -- Add Button
    local addBtn = AceGUI:Create("Button")
    addBtn:SetText("Add")
    addBtn:SetWidth(80)
    addBtn:SetCallback("OnClick", function()
        if invalidItemID then return end

        local id = tonumber(itemIDInput:GetText())
        if id then
            LootiFilters[listType].items[id] = true
            itemIDInput:SetText("")
            UpdateFilterList(scrollList, itemIDInput, listType, itemIcon, itemNameLabel)
        end
    end)
    buttonGroup:AddChild(addBtn)

    -- Remove Button
    local removeBtn = AceGUI:Create("Button")
    removeBtn:SetText("Remove")
    removeBtn:SetWidth(80)
    removeBtn:SetCallback("OnClick", function()
        if invalidItemID then return end

        local id = tonumber(itemIDInput:GetText())
        if id then
            LootiFilters[listType].items[id] = nil
            itemIDInput:SetText("")
            UpdateFilterList(scrollList, itemIDInput, listType, itemIcon, itemNameLabel)
        end
    end)
    buttonGroup:AddChild(removeBtn)
end

local function CreateCategoryToggles(parent, listType)
    if not LootiFilters[listType].categories then
        LootiFilters[listType].categories = {
            BoE = false,
            BoP = false,
            QuestItems = false,
            Consumables = false,
            Gear = false,
            CraftingMats = false,
        }
    end

    for categoryKey, isEnabled in pairs(LootiFilters[listType].categories) do
        local categoryCheckbox = AceGUI:Create("CheckBox")
        categoryCheckbox:SetLabel(Looti.CATEGORY_LABELS[categoryKey])
        categoryCheckbox:SetValue(isEnabled)

        categoryCheckbox:SetRelativeWidth(0.5)
        categoryCheckbox:SetHeight(24)

        categoryCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
            LootiFilters[listType].categories[categoryKey] = value
        end)

        parent:AddChild(categoryCheckbox)
    end
end

-- Main function
local function CreateFilterEditor(listType)
    -- Prevent duplicate windows
    if isWindowOpen(listType) then
        return
    end
    setWindowOpen(listType, true)

    -- Create main frame
    local frame = CreateFrameBase(listType)

    -- Controls container
    local controlContainer = AceGUI:Create("InlineGroup")
    controlContainer:SetLayout("List")
    controlContainer:SetFullWidth(true)
    frame:AddChild(controlContainer)

    -- Selected item display
    local selectedItemContainer = AceGUI:Create("SimpleGroup")
    selectedItemContainer:SetLayout("Flow")
    selectedItemContainer:SetFullWidth(true)
    controlContainer:AddChild(selectedItemContainer)

    local itemIcon, itemNameLabel = CreateSelectedItemDisplay(selectedItemContainer)

    -- Input and buttons container
    local inputButtonContainer = AceGUI:Create("SimpleGroup")
    inputButtonContainer:SetLayout("Flow")
    inputButtonContainer:SetFullWidth(true)
    controlContainer:AddChild(inputButtonContainer)

    -- Category checkbox container
    local checkboxGroup = AceGUI:Create("InlineGroup")
    checkboxGroup:SetLayout("Flow")
    checkboxGroup:SetFullWidth(true)
    controlContainer:AddChild(checkboxGroup)

    -- Category toggles
    CreateCategoryToggles(checkboxGroup, listType)

    -- Item input
    local itemIDInput = CreateItemInput(inputButtonContainer, function(widget, event, value)
        local id = tonumber(value)
        if id then
            UpdateSelectedItemDisplay(id, itemIcon, itemNameLabel)
        end
    end)

    -- Scrollable list
    local scrollList = AceGUI:Create("ScrollFrame")
    scrollList:SetFullWidth(true)
    scrollList:SetFullHeight(true)
    frame:AddChild(scrollList)

    -- Action buttons (needs scrollList reference, so created after)
    CreateActionButtons(inputButtonContainer, listType, itemIDInput, scrollList, itemIcon, itemNameLabel)

    -- Populate list
    UpdateFilterList(scrollList, itemIDInput, listType, itemIcon, itemNameLabel)

    return frame
end

_G["CreateFilterEditor"] = CreateFilterEditor

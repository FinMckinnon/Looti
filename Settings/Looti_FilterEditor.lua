-- The whitelist, blacklist and watchlist editor window.
local ADDON, L = ...

L.FilterEditor = {}

local LIST_TITLES = {
    whitelist = "Whitelist",
    blacklist = "Blacklist",
    watchlist = "Watchlist",
}

local LIST_HINTS = {
    whitelist = "Always notify, even below the minimum rarity.",
    blacklist = "Never notify.",
    watchlist = "An extra alert for items you are waiting on.",
}

local open = {}

-- input: a filter list name
-- output: the staged copy and the window, or nil when it is not open
-- Reads the editor state for one list.
local function State(listType)
    return open[listType]
end

-- input: a filter list name
-- output: nothing
-- Writes the staged copy back over the saved filter list.
local function Apply(listType)
    local state = State(listType)
    if not state then
        return
    end

    L.Util.ReplaceContents(LootiFilters[listType], state.staged)
    L.Util.Print(LIST_TITLES[listType] .. " saved.", "update")
end

-- input: a filter list name
-- output: nothing
-- Forgets the editor state for one list.
local function Forget(listType)
    open[listType] = nil
end

-- input: a filter list name
-- output: nothing
-- Rebuilds the item rows from the staged copy.
local function RefreshItems(listType)
    local state = State(listType)
    if not state then
        return
    end

    L.FilterGrid.Build(state.scroll, state.staged, function(itemID)
        state.staged.items[itemID] = nil
        RefreshItems(listType)
    end)
end

-- input: a filter list name and the text typed into the add field
-- output: nothing
-- Adds an item id or link to the staged copy.
local function AddEntry(listType, text)
    local state = State(listType)
    if not state then
        return
    end

    local itemID = L.ItemCache.ItemID(text) or tonumber(text)
    if not itemID then
        L.Util.Print("That is not an item id or an item link.", "error")
        return
    end

    state.staged.items[itemID] = true
    RefreshItems(listType)
end

-- input: a filter list name
-- output: nothing
-- Opens the editor for one filter list, or brings it to the front.
function L.FilterEditor.Open(listType)
    if State(listType) then
        return
    end

    local AceGUI = L.AceGUI
    local staged = L.Util.DeepCopy(LootiFilters[listType])

    local window = L.UI.Window(
        LIST_TITLES[listType],
        LIST_HINTS[listType],
        L.Const.FRAME.EDITOR_WIDTH,
        L.Const.FRAME.EDITOR_HEIGHT,
        function(self)
            Forget(listType)
            AceGUI:Release(self)
        end
    )

    open[listType] = { window = window, staged = staged }

    local addSection = L.UI.Section(window, "Add an item", "Paste an item link or type its id.")
    local input = AceGUI:Create("EditBox")
    input:SetLabel("")
    input:SetRelativeWidth(0.7)
    input:SetCallback("OnEnterPressed", function(self, _, text)
        AddEntry(listType, text)
        self:SetText("")
    end)
    addSection:AddChild(input)

    L.UI.Button(addSection, "Add", 80, function()
        AddEntry(listType, input:GetText())
        input:SetText("")
    end)

    local categorySection = L.UI.Section(window, "Categories", "Whole groups of items, in one go.")
    for _, key in ipairs(L.Const.CATEGORY_ORDER) do
        local toggle = L.UI.Toggle(categorySection, L.Const.CATEGORY_LABELS[key],
            staged.categories[key], function(value)
                staged.categories[key] = value
            end)
        toggle:SetRelativeWidth(0.5)
    end

    local itemSection = L.UI.Section(window, "Items", "Individual items, by id.")
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    itemSection:AddChild(scroll)

    open[listType].scroll = scroll
    RefreshItems(listType)

    local footer = L.UI.Section(window, "", nil)
    L.UI.Button(footer, "Cancel", 120, function()
        Forget(listType)
        window:Hide()
    end)
    L.UI.Button(footer, "Save", 120, function()
        Apply(listType)
        Forget(listType)
        window:Hide()
    end)
end

-- input: a filter list name
-- output: the staged copy, or nil when the editor is closed
-- Exposes the staged copy so it can be checked without a window.
function L.FilterEditor.Staged(listType)
    local state = State(listType)
    return state and state.staged or nil
end

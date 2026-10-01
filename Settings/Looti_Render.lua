-- Builds settings widgets from the schema.
local ADDON, L = ...

L.Render = {}

-- Widgets currently on screen, keyed by the setting they edit.
L.Render.live = {}

-- Handlers a schema entry of type "action" can name.
L.Actions = {}

-- input: nothing
-- output: nothing
-- Closes the settings window and puts the anchor into move mode.
function L.Actions.moveAnchor()
    if L.Panel then
        L.Panel.Close()
    end

    L.Anchor.SetMoveMode(true)
end

-- input: nothing
-- output: nothing
-- Puts the notifications back at their default position.
function L.Actions.resetPosition()
    L.Anchor.ResetPosition()
    L.Util.Print(L.Text.MSG_POSITION_RESET, "update")
end

-- input: the staging table
-- output: nothing
-- Greys any widget whose gating toggle is currently off.
function L.Render.RefreshEnabled(staging)
    for _, entry in ipairs(L.Schema) do
        local widget = entry.key and L.Render.live[entry.key]
        if widget and entry.enabledBy then
            widget:SetDisabled(not staging[entry.enabledBy])
        end
    end
end

-- input: a section container and a schema entry of type "filterlist"
-- output: nothing
-- Shows how much one filter list holds, beside a button that opens its editor.
local function RenderFilterList(section, entry)
    local items, categories = L.Db.CountFilter(entry.list)

    local summary = L.AceGUI:Create("Label")
    summary:SetText(L.Text.FILTER_SUMMARY:format(items, categories))
    summary:SetRelativeWidth(0.55)
    section:AddChild(summary)

    L.UI.Button(section, L.Text.BUTTON_EDIT, 100, function()
        L.FilterEditor.Open(entry.list)
    end)
end

-- input: a section container, a schema entry, and the staging table
-- output: the created widget, or nil for an action or a filter list
-- Creates one widget and wires its change callback into the staging table.
local function RenderEntry(section, entry, staging)
    if entry.type == "action" then
        L.UI.Button(section, entry.label, entry.width, function()
            local handler = L.Actions[entry.action]
            if handler then
                handler()
            end
        end)
        return nil
    end

    if entry.type == "filterlist" then
        RenderFilterList(section, entry)
        return nil
    end

    local function onChange(value)
        staging[entry.key] = value
        L.Render.RefreshEnabled(staging)
    end

    local widget
    local value = staging[entry.key]

    if entry.type == "toggle" then
        widget = L.UI.Toggle(section, entry.label, value, onChange)
    elseif entry.type == "range" then
        widget = L.UI.Range(section, entry, value, onChange)
    elseif entry.type == "select" then
        widget = L.UI.Select(section, entry.label, value, entry.options, entry.order, onChange)
    end

    L.Render.live[entry.key] = widget
    return widget
end

-- input: an AceGUI container, the staging table, a tab id, and a column width
-- output: nothing
-- Builds every entry for one tab, opening a section whenever the group changes.
function L.Render.Tab(container, staging, tabId, width)
    container:ReleaseChildren()
    wipe(L.Render.live)

    local section, currentGroup

    for _, entry in ipairs(L.Schema) do
        if entry.tab == tabId then
            if entry.group ~= currentGroup then
                currentGroup = entry.group
                section = L.UI.Section(container, entry.group, entry.hint, width)
            end
            RenderEntry(section, entry, staging)
        end
    end

    L.Render.RefreshEnabled(staging)
end

-- input: the staging table
-- output: nothing
-- Pushes staged values back into every widget currently on screen.
function L.Render.Refresh(staging)
    for key, widget in pairs(L.Render.live) do
        widget:SetValue(staging[key])

        -- A slider's label carries its value, so it has to be rebuilt too.
        for _, entry in ipairs(L.Schema) do
            if entry.key == key and entry.type == "range" then
                widget:SetLabel(L.UI.RangeLabel(entry, staging[key]))
            end
        end
    end

    L.Render.RefreshEnabled(staging)
end

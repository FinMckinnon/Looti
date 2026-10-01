---@diagnostic disable: undefined-field, invisible
-- AceGUI ships without type annotations, and widget.frame is its documented
-- route to the underlying frame.
--
-- AceGUI widget factories used by the settings panel and the filter editor.
local ADDON, L = ...

L.UI = {}

local AceGUI = LibStub("AceGUI-3.0")
L.AceGUI = AceGUI

-- AceGUI Frame content offsets, and the bottom offset without the status bar.
local FRAME_CONTENT_TOP = 27
local FRAME_CONTENT_SIDE = 17
local FRAME_CONTENT_BOTTOM = 40
local BARE_CONTENT_BOTTOM = 16

-- Gap between the controls in a centred row.
local CENTRED_ROW_SPACING = 8

-- input: an AceGUI content frame and its children
-- output: nothing
-- Layout "LootiCentredRow": one row, centred horizontally.
AceGUI:RegisterLayout("LootiCentredRow", function(content, children)
    local rowWidth, rowHeight = 0, 0

    for index, child in ipairs(children) do
        rowWidth = rowWidth + child.frame:GetWidth()
        if index > 1 then
            rowWidth = rowWidth + CENTRED_ROW_SPACING
        end
        rowHeight = math.max(rowHeight, child.frame:GetHeight())
    end

    local available = content.width or content:GetWidth() or 0
    local x = math.max(0, (available - rowWidth) / 2)

    for _, child in ipairs(children) do
        child.frame:ClearAllPoints()
        child.frame:SetPoint("TOPLEFT", content, "TOPLEFT", x, 0)
        child.frame:Show()
        x = x + child.frame:GetWidth() + CENTRED_ROW_SPACING
    end

    if content.obj.LayoutFinished then
        content.obj:LayoutFinished(nil, rowHeight)
    end
end)

-- input: a schema entry and a value
-- output: the label text for that value
-- Builds a slider label that reads as words where a bare number would not.
function L.UI.RangeLabel(entry, value)
    if entry.zeroLabel and value == 0 then
        return entry.label .. ": " .. entry.zeroLabel
    end

    if entry.rarity then
        return entry.label
    end

    return entry.label .. ": " .. value .. (entry.unit or "")
end

-- input: a label widget and an item rarity
-- output: nothing
-- Shows the rarity's name in that rarity's own colour.
local function ShowRarity(label, rarity)
    label:SetText(L.Const.RARITY_NAMES[rarity] or "")
    label:SetColor(L.Compat.QualityColor(rarity))
end

-- input: a parent container, a title, an optional hint, and a width
-- output: the AceGUI InlineGroup
-- Adds a titled section, with the hint as muted text under the title.
function L.UI.Section(parent, title, hint, width)
    local group = AceGUI:Create("InlineGroup")
    group:SetLayout("Flow")
    group:SetTitle(title)

    if width then
        group:SetWidth(width)
    else
        group:SetFullWidth(true)
    end

    parent:AddChild(group)

    if hint then
        local label = AceGUI:Create("Label")
        label:SetText(hint)
        label:SetFullWidth(true)
        group:AddChild(label)
    end

    return group
end

-- input: a parent container, a label, a starting value, and a change callback
-- output: the AceGUI CheckBox
-- Adds a labelled checkbox that reports its new value on change.
function L.UI.Toggle(parent, label, value, onChange)
    local widget = AceGUI:Create("CheckBox")
    widget:SetLabel(label)
    widget:SetValue(value and true or false)
    widget:SetFullWidth(true)
    widget:SetCallback("OnValueChanged", function(_, _, newValue)
        onChange(newValue and true or false)
    end)

    parent:AddChild(widget)
    return widget
end

-- input: a parent container, a schema entry, a starting value, and a change callback
-- output: the AceGUI Slider
-- Adds a slider bounded by the entry, relabelling itself as the value changes.
-- A rarity slider also gets the rarity's coloured name centred underneath.
function L.UI.Range(parent, entry, value, onChange)
    local widget = AceGUI:Create("Slider")
    widget:SetLabel(L.UI.RangeLabel(entry, value))
    widget:SetSliderValues(entry.min, entry.max, entry.step)
    widget:SetValue(value)
    widget:SetFullWidth(true)

    local rarityName
    if entry.rarity then
        rarityName = AceGUI:Create("Label")
        rarityName:SetFullWidth(true)
        rarityName:SetJustifyH("CENTER")
        ShowRarity(rarityName, value)
    end

    widget:SetCallback("OnValueChanged", function(self, _, newValue)
        self:SetLabel(L.UI.RangeLabel(entry, newValue))
        if rarityName then
            ShowRarity(rarityName, newValue)
        end
        onChange(newValue)
    end)

    parent:AddChild(widget)
    if rarityName then
        parent:AddChild(rarityName)
    end

    return widget
end

-- input: a parent container, a label, a starting value, an options table, an order, and a change callback
-- output: the AceGUI Dropdown
-- Adds a labelled dropdown listing the options in the given order.
function L.UI.Select(parent, label, value, options, order, onChange)
    local widget = AceGUI:Create("Dropdown")
    widget:SetLabel(label)
    widget:SetList(options, order)
    widget:SetValue(value)
    widget:SetFullWidth(true)
    widget:SetCallback("OnValueChanged", function(_, _, newValue)
        onChange(newValue)
    end)

    parent:AddChild(widget)
    return widget
end

-- input: a parent container, the button text, a width, and a click callback
-- output: the AceGUI Button
-- Adds a button that runs the callback when clicked. The width is in pixels,
-- or a share of the row when it is 1 or less, or the full row when nil.
function L.UI.Button(parent, text, width, onClick)
    local widget = AceGUI:Create("Button")
    widget:SetText(text)

    if not width then
        widget:SetFullWidth(true)
    elseif width <= 1 then
        widget:SetRelativeWidth(width)
    else
        widget:SetWidth(width)
    end

    widget:SetCallback("OnClick", onClick)
    parent:AddChild(widget)

    return widget
end

-- input: an AceGUI Frame
-- output: its status bar and its Close button
-- Finds the status bar and Close button of an AceGUI Frame.
local function BottomBar(window)
    local statusBar = window.statustext:GetParent()
    local closeButton

    for _, child in ipairs({ window.frame:GetChildren() }) do
        if child.obj == window and child ~= statusBar and child:GetObjectType() == "Button" then
            closeButton = child
        end
    end

    return statusBar, closeButton
end

-- input: an AceGUI Frame and whether its bottom bar should show
-- output: nothing
-- Shows or hides the status bar and Close button, and moves the content's
-- bottom edge to match.
local function SetBottomBarShown(window, shown)
    local statusBar, closeButton = BottomBar(window)
    statusBar:SetShown(shown)
    if closeButton then
        closeButton:SetShown(shown)
    end

    local bottom = shown and FRAME_CONTENT_BOTTOM or BARE_CONTENT_BOTTOM
    window.content:SetPoint("BOTTOMRIGHT", -FRAME_CONTENT_SIDE, bottom)

    window.content.height = window.frame:GetHeight() - FRAME_CONTENT_TOP - bottom
end

-- input: a title, a subtitle or nil, a width, a height, and a close callback
-- output: the AceGUI Frame
-- Creates a window whose minimum size is clamped to the size given. Without a
-- subtitle the window has no status bar or Close button.
function L.UI.Window(title, subtitle, width, height, onClose)
    local window = AceGUI:Create("Frame")
    window:SetTitle(title)
    window:SetStatusText(subtitle or "")
    window:SetLayout("Flow")
    window:SetWidth(width)
    window:SetHeight(height)

    local raw = window.frame or window
    L.Compat.SetMinSize(raw, width, height)

    local bare = subtitle == nil
    if bare then
        SetBottomBarShown(window, false)
    end

    window:SetCallback("OnClose", function(widget, ...)
        if bare then
            SetBottomBarShown(widget, true)
        end
        onClose(widget, ...)
    end)

    return window
end

-- input: an AceGUI container
-- output: the height of its content area in pixels
-- Reads how much vertical room a container gives its children.
function L.UI.ContentHeight(container)
    local content = container.content
    return content.height or content:GetHeight() or 0
end

-- input: a parent container using the "Fill" layout
-- output: the AceGUI ScrollFrame
-- Adds a scrolling area that fills the parent.
function L.UI.Scroll(parent)
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)

    parent:AddChild(scroll)
    return scroll
end

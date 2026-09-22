---@diagnostic disable: undefined-field, invisible
-- AceGUI ships without type annotations, and widget.frame is its documented
-- route to the underlying frame.
--
-- AceGUI widget factories used by the settings panel and the filter editor.
local ADDON, L = ...

L.UI = {}

local AceGUI = LibStub("AceGUI-3.0")
L.AceGUI = AceGUI

-- input: a schema entry and a value
-- output: the label text for that value
-- Builds a slider label that reads as words where a bare number would not.
function L.UI.RangeLabel(entry, value)
    if entry.zeroLabel and value == 0 then
        return entry.label .. ": " .. entry.zeroLabel
    end

    if entry.names then
        local name = entry.names[value]
        if name then
            return entry.label .. ": " .. value .. " \194\183 " .. name
        end
    end

    return entry.label .. ": " .. value .. (entry.unit or "")
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
function L.UI.Range(parent, entry, value, onChange)
    local widget = AceGUI:Create("Slider")
    widget:SetLabel(L.UI.RangeLabel(entry, value))
    widget:SetSliderValues(entry.min, entry.max, entry.step)
    widget:SetValue(value)
    widget:SetFullWidth(true)
    widget:SetCallback("OnValueChanged", function(self, _, newValue)
        self:SetLabel(L.UI.RangeLabel(entry, newValue))
        onChange(newValue)
    end)

    parent:AddChild(widget)
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
-- Adds a button that runs the callback when clicked.
function L.UI.Button(parent, text, width, onClick)
    local widget = AceGUI:Create("Button")
    widget:SetText(text)

    if width then
        widget:SetWidth(width)
    else
        widget:SetFullWidth(true)
    end

    widget:SetCallback("OnClick", onClick)
    parent:AddChild(widget)

    return widget
end

-- input: a title, a subtitle, a width, a height, and a close callback
-- output: the AceGUI Frame
-- Creates a window whose minimum size is clamped to the size given.
function L.UI.Window(title, subtitle, width, height, onClose)
    local window = AceGUI:Create("Frame")
    window:SetTitle(title)
    window:SetStatusText(subtitle or "")
    window:SetLayout("Flow")
    window:SetWidth(width)
    window:SetHeight(height)
    window:SetCallback("OnClose", onClose)

    local raw = window.frame or window
    L.Compat.SetMinSize(raw, width, height)

    return window
end

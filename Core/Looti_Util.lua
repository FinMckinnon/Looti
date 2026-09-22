-- Table copying and coloured chat output.
local ADDON, L = ...

L.Util = {}

local COLOUR_INFO = "1E90FF"
local COLOUR_UPDATE = "FF6347"
local COLOUR_ERROR = "DC143C"

-- input: any value
-- output: an independent copy of it, or the value itself when not a table
-- Copies a table and every table inside it.
function L.Util.DeepCopy(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, inner in pairs(value) do
        copy[key] = L.Util.DeepCopy(inner)
    end

    return copy
end

-- input: a destination table and a table of defaults
-- output: the destination table
-- Fills in any key the destination is missing, descending into nested tables.
function L.Util.ApplyDefaults(target, defaults)
    if type(target) ~= "table" then
        target = {}
    end

    for key, defaultValue in pairs(defaults) do
        if type(defaultValue) == "table" then
            if type(target[key]) ~= "table" then
                target[key] = {}
            end
            L.Util.ApplyDefaults(target[key], defaultValue)
        elseif target[key] == nil then
            target[key] = L.Util.DeepCopy(defaultValue)
        end
    end

    return target
end

-- input: a table to empty and a table to copy from
-- output: the destination table
-- Replaces the destination's contents with an independent copy of the source.
function L.Util.ReplaceContents(target, source)
    wipe(target)

    for key, value in pairs(source) do
        target[key] = L.Util.DeepCopy(value)
    end

    return target
end

-- input: a message string and an optional tone of "update" or "error"
-- output: nothing
-- Prints a coloured Looti message to the default chat frame.
function L.Util.Print(message, tone)
    local colour = COLOUR_INFO
    if tone == "update" then
        colour = COLOUR_UPDATE
    elseif tone == "error" then
        colour = COLOUR_ERROR
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cff" .. colour .. message .. "|r")
end

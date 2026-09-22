-- Turns the client's own loot and money strings into patterns and reads messages with them.
local ADDON, L = ...

L.Chat = {}

local COPPER_PER_SILVER = 100
local COPPER_PER_GOLD = 10000
local MAX_EXPANSIONS = 4

-- input: a client format string
-- output: a list of format strings, one per grammar alternative
-- Expands |4one:few:many; and |1a;b; selectors into separate literal forms.
local function ExpandForms(fmt)
    local forms = { fmt }

    for _ = 1, MAX_EXPANSIONS do
        local expanded = {}
        local changed = false

        for _, candidate in ipairs(forms) do
            local prefix, body, suffix = candidate:match("^(.-)|4([^;]*);(.*)$")
            if body then
                changed = true
                for option in (body .. ":"):gmatch("([^:]*):") do
                    expanded[#expanded + 1] = prefix .. option .. suffix
                end
            else
                local head, first, second, tail = candidate:match("^(.-)|1([^;]*);([^;]*);(.*)$")
                if first then
                    changed = true
                    expanded[#expanded + 1] = head .. first .. tail
                    expanded[#expanded + 1] = head .. second .. tail
                else
                    expanded[#expanded + 1] = candidate
                end
            end
        end

        forms = expanded
        if not changed then
            break
        end
    end

    return forms
end

-- input: a client format string, and whether to anchor at the start
-- output: a Lua pattern with captures, or nil for an unusable string
-- Converts one format string into a pattern that matches the client's own text.
function L.Chat.FormatToPattern(fmt, anchored)
    if type(fmt) ~= "string" or fmt == "" then
        return nil
    end

    local pattern = fmt:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")

    pattern = pattern:gsub("%%%%%d%$s", "(.+)")
    pattern = pattern:gsub("%%%%%d%$d", "(%%d+)")
    pattern = pattern:gsub("%%%%d", "(%%d+)")
    pattern = pattern:gsub("%%%%s", "(.+)")

    if anchored then
        return "^" .. pattern
    end

    return pattern
end

-- input: a client format string
-- output: the literal text before its first placeholder, or nil
-- Reads the fixed opening a message must have to be about the player.
local function LiteralPrefix(fmt)
    if type(fmt) ~= "string" then
        return nil
    end

    local prefix = fmt:match("^(.-)%%")
    if not prefix or prefix == "" then
        return nil
    end

    return prefix
end

-- input: a list of client format strings
-- output: a list of the literal openings they have
-- Collects the openings that mark a message as the player's own.
local function SelfPrefixes(formats)
    local prefixes = {}

    for _, fmt in ipairs(formats) do
        local prefix = LiteralPrefix(fmt)
        if prefix then
            prefixes[#prefixes + 1] = prefix
        end
    end

    return prefixes
end

-- input: a message and a list of literal openings
-- output: true when the message starts with one of them
-- Rejects other players' messages with one plain compare, before any matching.
local function IsAboutPlayer(message, prefixes)
    if #prefixes == 0 then
        return true
    end

    for _, prefix in ipairs(prefixes) do
        if message:find(prefix, 1, true) == 1 then
            return true
        end
    end

    return false
end

-- input: a client format string and whether to anchor it
-- output: a list of patterns
-- Builds one pattern per grammar alternative of a format string.
local function PatternsFor(fmt, anchored)
    local patterns = {}

    for _, form in ipairs(ExpandForms(fmt)) do
        local pattern = L.Chat.FormatToPattern(form, anchored)
        if pattern then
            patterns[#patterns + 1] = pattern
        end
    end

    return patterns
end

-- Loot lines are anchored so another player's loot cannot match. The multiple
-- form is tried first because the single form is a prefix of it.
local lootForms = {
    { patterns = PatternsFor(LOOT_ITEM_SELF_MULTIPLE, true), hasQuantity = true },
    { patterns = PatternsFor(LOOT_ITEM_SELF, true), hasQuantity = false },
}

-- Only the player's own loot and money lines are read. Everyone else's arrive
-- on the same events, and in a raid that is most of them.
local lootSelfPrefixes = SelfPrefixes({ LOOT_ITEM_SELF_MULTIPLE, LOOT_ITEM_SELF })
local moneySelfPrefixes = SelfPrefixes({
    YOU_LOOT_MONEY, YOU_LOOT_MONEY_GUILD, LOOT_MONEY_SPLIT, LOOT_MONEY_SPLIT_GUILD,
})

-- Amounts appear in the middle of a money message, so these are unanchored.
local moneyUnits = {
    { patterns = PatternsFor(GOLD_AMOUNT, false), value = COPPER_PER_GOLD },
    { patterns = PatternsFor(SILVER_AMOUNT, false), value = COPPER_PER_SILVER },
    { patterns = PatternsFor(COPPER_AMOUNT, false), value = 1 },
}

-- input: captured text from a loot message
-- output: the item link, or nil
-- Reads a leading item link, rejecting a capture that is anything else.
local function LeadingItemLink(text)
    if type(text) ~= "string" then
        return nil
    end

    return text:match("^(|c%x+|H.-|h%[.-%]|h|r)") or text:match("^(|H.-|h%[.-%]|h|r)")
end

-- input: a chat message
-- output: the item link and quantity, or nil
-- Reads a link and count out of a message announcing the player's own loot.
function L.Chat.ParseLoot(message)
    if type(message) ~= "string" or not IsAboutPlayer(message, lootSelfPrefixes) then
        return nil
    end

    for _, form in ipairs(lootForms) do
        for _, pattern in ipairs(form.patterns) do
            local captured, count = message:match(pattern)
            local link = LeadingItemLink(captured)
            if link then
                return link, form.hasQuantity and (tonumber(count) or 1) or 1
            end
        end
    end

    return nil
end

-- input: a chat message
-- output: the total in copper, zero when the message holds no amount
-- Adds up every gold, silver and copper amount in a money message.
function L.Chat.ParseMoney(message)
    if type(message) ~= "string" or not IsAboutPlayer(message, moneySelfPrefixes) then
        return 0
    end

    local total = 0

    for _, unit in ipairs(moneyUnits) do
        for _, pattern in ipairs(unit.patterns) do
            local amount = tonumber(message:match(pattern))
            if amount then
                total = total + (amount * unit.value)
                break
            end
        end
    end

    return total
end

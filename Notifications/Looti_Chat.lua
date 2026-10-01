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

    pattern = pattern:gsub("%%%%%d+%%%$s", "(.+)")
    pattern = pattern:gsub("%%%%%d+%%%$d", "(%%d+)")
    pattern = pattern:gsub("%%%%d", "(%%d+)")
    pattern = pattern:gsub("%%%%s", "(.+)")

    if anchored then
        return "^" .. pattern
    end

    return pattern
end

-- input: a client format string
-- output: a list of patterns
-- Builds one anchored pattern per grammar alternative of a format string.
local function PatternsFor(fmt)
    local patterns = {}

    for _, form in ipairs(ExpandForms(fmt)) do
        local pattern = L.Chat.FormatToPattern(form, true)
        if pattern then
            patterns[#patterns + 1] = pattern
        end
    end

    return patterns
end

-- Each entry names a message's format strings, the ones carrying a quantity
-- first and the plain form last. Only the player's own lines are listed.
-- setting names the LootiConfig key that gates the line.
local LOOT_FORMATS = {
    { "LOOT_ITEM_SELF_MULTIPLE", "LOOT_ITEM_SELF" },
    { "LOOT_ITEM_PUSHED_SELF_MULTIPLE", "LOOT_ITEM_PUSHED_SELF", setting = "showPushedItems" },
    { "LOOT_ITEM_BONUS_ROLL_SELF_MULTIPLE", "LOOT_ITEM_BONUS_ROLL_SELF" },
    { "LOOT_ITEM_CREATED_SELF_MULTIPLE", "LOOT_ITEM_CREATED_SELF", setting = "showCraftedItems" },
}

local CURRENCY_FORMATS = {
    { "CURRENCY_GAINED_MULTIPLE_OVERFLOW", "CURRENCY_GAINED_MULTIPLE_BONUS",
      "CURRENCY_GAINED_MULTIPLE", "CURRENCY_GAINED" },
}

local MONEY_FORMATS = {
    { "YOU_LOOT_MONEY_GUILD", "YOU_LOOT_MONEY" },
    { "LOOT_MONEY_SPLIT_GUILD", "LOOT_MONEY_SPLIT_MOD", "LOOT_MONEY_SPLIT" },
}

-- input: a list of format groups, as above
-- output: the forms to try in order
-- Builds each format's patterns and its fixed opening, which is compared
-- before any pattern is tried. Strings a client flavour lacks are skipped.
local function BuildForms(groups)
    local forms = {}

    for _, group in ipairs(groups) do
        for index, name in ipairs(group) do
            local fmt = _G[name]
            if type(fmt) == "string" then
                local prefix = fmt:match("^(.-)%%")
                forms[#forms + 1] = {
                    patterns = PatternsFor(fmt),
                    prefix = prefix ~= "" and prefix or nil,
                    hasQuantity = index < #group,
                    setting = group.setting,
                }
            end
        end
    end

    return forms
end

local lootForms = BuildForms(LOOT_FORMATS)
local currencyForms = BuildForms(CURRENCY_FORMATS)
local moneyForms = BuildForms(MONEY_FORMATS)

-- Amounts appear in the middle of a money message, so these are unanchored.
local moneyUnits = {
    { patterns = {}, value = COPPER_PER_GOLD },
    { patterns = {}, value = COPPER_PER_SILVER },
    { patterns = {}, value = 1 },
}

for index, fmt in ipairs({ GOLD_AMOUNT, SILVER_AMOUNT, COPPER_AMOUNT }) do
    for _, form in ipairs(ExpandForms(fmt)) do
        local patterns = moneyUnits[index].patterns
        patterns[#patterns + 1] = L.Chat.FormatToPattern(form, false)
    end
end

-- input: a chat message
-- output: true when the message is text the addon may read
-- Rejects anything that is not a string, and secret values on 12.0 and later.
local function IsReadable(message)
    return type(message) == "string" and not (issecretvalue and issecretvalue(message))
end

-- input: a chat message and the forms to try
-- output: the matching form and its captures, or nil
-- Tries each form whose fixed opening the message has.
local function MatchForm(message, forms)
    for _, form in ipairs(forms) do
        if not form.prefix or message:find(form.prefix, 1, true) == 1 then
            for _, pattern in ipairs(form.patterns) do
                local first, second = message:match(pattern)
                if first then
                    return form, first, second
                end
            end
        end
    end

    return nil
end

-- input: captured text from a message
-- output: the link, or nil
-- Reads a leading item or currency link, in the |cff or |cnIQ colour format.
local function LeadingLink(text)
    return text:match("^(|c.-|H.-|h%[.-%]|h|r)") or text:match("^(|H.-|h%[.-%]|h|r)")
end

-- input: a chat message and the forms to try
-- output: the link, the quantity, and the LootiConfig key that gates the line, or nil
-- Reads a link and count out of one of the player's own messages.
local function ParseLink(message, forms)
    if not IsReadable(message) then
        return nil
    end

    local form, captured, count = MatchForm(message, forms)
    local link = form and LeadingLink(captured)
    if not link then
        return nil
    end

    return link, form.hasQuantity and (tonumber(count) or 1) or 1, form.setting
end

-- input: a chat message
-- output: the item link, the quantity, and the LootiConfig key that gates the line, or nil
-- Reads the player's own loot, pushed item, bonus roll or crafted item line.
function L.Chat.ParseLoot(message)
    return ParseLink(message, lootForms)
end

-- input: a chat message
-- output: the currency link and quantity, or nil
-- Reads the player's own currency line.
function L.Chat.ParseCurrency(message)
    return ParseLink(message, currencyForms)
end

-- input: a chat message
-- output: the total in copper, zero when the message holds no amount
-- Adds up the gold, silver and copper in the player's own money message.
function L.Chat.ParseMoney(message)
    if not IsReadable(message) then
        return 0
    end

    local form, amount = MatchForm(message, moneyForms)
    if not form or not amount:match("^%d") then
        return 0
    end

    local total = 0

    for _, unit in ipairs(moneyUnits) do
        for _, pattern in ipairs(unit.patterns) do
            local value = tonumber(amount:match(pattern))
            if value then
                total = total + (value * unit.value)
                break
            end
        end
    end

    return total
end

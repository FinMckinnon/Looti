-- The settings window, its tabs and its save and cancel buffer.
local ADDON, L = ...

L.Panel = {}

local RESET_DIALOG = "LOOTI_RESET_CONFIRM"

local window
local tabGroup
local staging = {}
local currentTab

-- input: nothing
-- output: nothing
-- Copies the settings the schema covers into the staging table.
local function Stage()
    wipe(staging)

    for _, key in ipairs(L.SchemaKeys()) do
        staging[key] = LootiConfig[key]
    end
end

-- input: nothing
-- output: nothing
-- Writes the staging table back over the saved settings.
local function Commit()
    for key, value in pairs(staging) do
        if not L.Db.INTERNAL_KEYS[key] then
            LootiConfig[key] = value
        end
    end
end

-- input: a container for the filters tab and a column width
-- output: nothing
-- Lists each filter list with its contents and an edit button.
local function BuildFiltersTab(container, width)
    container:ReleaseChildren()

    local titles = {
        whitelist = { L.Text.LIST_WHITELIST, L.Text.HINT_WHITELIST },
        blacklist = { L.Text.LIST_BLACKLIST, L.Text.HINT_BLACKLIST },
        watchlist = { L.Text.LIST_WATCHLIST, L.Text.HINT_WATCHLIST_SOON },
    }

    for _, listType in ipairs(L.Const.FILTER_LISTS) do
        local title, hint = titles[listType][1], titles[listType][2]
        local section = L.UI.Section(container, title, hint, width)

        local items, categories = L.Db.CountFilter(listType)
        local summary = L.AceGUI:Create("Label")
        summary:SetText(L.Text.FILTER_SUMMARY:format(items, categories))
        summary:SetRelativeWidth(0.55)
        section:AddChild(summary)

        local button = L.UI.Button(section, L.Text.BUTTON_EDIT, 100, function()
            L.FilterEditor.Open(listType)
        end)

        if listType == "watchlist" and not L.Features.watchlist then
            button:SetDisabled(true)
        end
    end
end

-- input: a container and a tab id
-- output: nothing
-- Fills one tab with its contents.
local function BuildTab(container, tabId)
    currentTab = tabId

    local width = L.Const.FRAME.PANEL_WIDTH - 60

    if tabId == "filters" then
        BuildFiltersTab(container, width)
    else
        L.Render.Tab(container, staging, tabId, width)
    end
end

-- input: nothing
-- output: nothing
-- Restores the defaults and redraws the tab on screen.
function L.Actions.resetAll()
    L.Popup.Confirm(RESET_DIALOG, L.Text.RESET_TITLE, L.Text.RESET_MESSAGE, function()
            L.Db.Reset()
            Stage()

            if tabGroup and currentTab then
                tabGroup:SelectTab(currentTab)
            end

            L.Util.Print(L.Text.MSG_RESET, "update")
        end)
end

-- input: nothing
-- output: nothing
-- Closes the settings window without saving.
function L.Panel.Close()
    if window then
        window:Hide()
    end
end

-- input: nothing
-- output: true while the settings window is open
-- Reports whether the panel is on screen.
function L.Panel.IsOpen()
    return window ~= nil
end

-- input: nothing
-- output: nothing
-- Writes the staged settings back and closes the window.
function L.Panel.Save()
    Commit()
    L.Util.Print(L.Text.MSG_SAVED, "update")
    L.Panel.Close()
end

-- input: a tab id
-- output: nothing
-- Switches the panel to one tab.
function L.Panel.SelectTab(tabId)
    if tabGroup then
        tabGroup:SelectTab(tabId)
    end
end

-- input: nothing
-- output: the staging table
-- Exposes the staged settings so they can be checked without a window.
function L.Panel.Staged()
    return staging
end

-- input: nothing
-- output: nothing
-- Opens the settings window, staging the current settings first.
function L.Panel.Open()
    if window then
        return
    end

    local AceGUI = L.AceGUI
    Stage()

    window = L.UI.Window(L.Text.ADDON_NAME, L.Text.SETTINGS_SUBTITLE,
        L.Const.FRAME.PANEL_WIDTH, L.Const.FRAME.PANEL_HEIGHT, function(self)
            window, tabGroup = nil, nil
            AceGUI:Release(self)
        end)

    tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Flow")
    tabGroup:SetFullWidth(true)
    tabGroup:SetFullHeight(true)
    tabGroup:SetTabs(L.SchemaTabs)
    tabGroup:SetCallback("OnGroupSelected", function(container, _, tabId)
        BuildTab(container, tabId)
    end)
    window:AddChild(tabGroup)

    tabGroup:SelectTab(L.SchemaTabs[1].value)

    local footer = AceGUI:Create("SimpleGroup")
    footer:SetLayout("Flow")
    footer:SetFullWidth(true)
    window:AddChild(footer)

    L.UI.Button(footer, L.Text.BUTTON_CANCEL, 140, function()
        L.Panel.Close()
    end)

    L.UI.Button(footer, L.Text.BUTTON_SAVE, 140, function()
        L.Panel.Save()
    end)

    L.UI.Button(footer, L.Text.BUTTON_TEST, 140, function()
        L.RunPreview()
    end)
end

SLASH_LOOTI1 = "/looti"
SlashCmdList["LOOTI"] = function()
    L.Panel.Open()
end

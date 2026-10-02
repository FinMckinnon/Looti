-- The settings window, its tabs and its save and cancel buffer.
local ADDON, L = ...

L.Panel = {}

local RESET_DIALOG = "LOOTI_RESET_CONFIRM"

-- Height kept under the tabs for the footer row, and the width of its buttons.
local FOOTER_HEIGHT = 32
local FOOTER_BUTTON_WIDTH = 120

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

-- input: a container and a tab id
-- output: nothing
-- Fills one tab with its contents.
local function BuildTab(container, tabId)
    currentTab = tabId

    L.Render.Tab(container, staging, tabId)
end

-- input: nothing
-- output: nothing
-- Restores the defaults and redraws the tab on screen.
function L.Actions.resetAll()
    L.Popup.Confirm(RESET_DIALOG, L.Text.RESET_TITLE, L.Text.RESET_MESSAGE, function()
            L.Db.Reset()
            Stage()

            L.Anchor.LoadPosition()

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
-- Writes the staged settings back, leaving the window open.
function L.Panel.Save()
    Commit()
    L.Util.Print(L.Text.MSG_SAVED, "update")
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

    window = L.UI.Window(L.Text.ADDON_NAME, nil,
        L.Const.FRAME.PANEL_WIDTH, L.Const.FRAME.PANEL_HEIGHT, function(self)
            window, tabGroup = nil, nil
            AceGUI:Release(self)
        end)

    window:EnableResize(false)

    tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Fill")
    tabGroup:SetFullWidth(true)

    tabGroup:SetAutoAdjustHeight(false)
    tabGroup:SetHeight(L.UI.ContentHeight(window) - FOOTER_HEIGHT)

    tabGroup:SetTabs(L.SchemaTabs)
    tabGroup:SetCallback("OnGroupSelected", function(container, _, tabId)
        container:ReleaseChildren()
        local scroll = L.UI.Scroll(container)

        scroll:PauseLayout()
        BuildTab(scroll, tabId)
        scroll:ResumeLayout()
        scroll:DoLayout()
    end)
    window:AddChild(tabGroup)

    tabGroup:SelectTab(L.SchemaTabs[1].value)

    local footer = AceGUI:Create("SimpleGroup")
    footer:SetLayout("LootiCentredRow")
    footer:SetFullWidth(true)
    window:AddChild(footer)

    L.UI.Button(footer, L.Text.BUTTON_CLOSE, FOOTER_BUTTON_WIDTH, function()
        L.Panel.Close()
    end)

    L.UI.Button(footer, L.Text.BUTTON_SAVE, FOOTER_BUTTON_WIDTH, function()
        L.Panel.Save()
    end)

    L.UI.Button(footer, L.Text.BUTTON_TEST, FOOTER_BUTTON_WIDTH, function()
        L.RunPreview()
    end)
end

SLASH_LOOTI1 = "/looti"
SlashCmdList["LOOTI"] = function()
    L.Panel.Open()
end

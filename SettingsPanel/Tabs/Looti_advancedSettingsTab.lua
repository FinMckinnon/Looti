--[[
    [Future - Debugging Features] Placeholder for logs/debug mode if needed
    [Reset Button] Restore Defaults
]] --

-- Reset Looti button with confirmation pop up
local function CreateButtonWithConfirmation(parent, buttonText, confirmTitle, confirmMessage, onConfirm, width,
                                            tempSettingsData)
    local button = AceGUI:Create("Button")
    button:SetText(buttonText)
    button:SetWidth(width)
    button:SetCallback("OnClick", function()
        settingsPanel.HandleResetButtonClick(tempSettingsData)
    end)
    parent:AddChild(button)
end

local function CreateFilterManagementSection(parent, width, LootiFilters)
    -- Group for Filter management
    local filtersManagementSettingsGroup = AceGUI:Create("InlineGroup")
    filtersManagementSettingsGroup:SetLayout("Flow")
    filtersManagementSettingsGroup:SetWidth(width)
    filtersManagementSettingsGroup:SetTitle("Filter Management")
    parent:AddChild(filtersManagementSettingsGroup)

    -- Open Blacklist Button
    local button = AceGUI:Create("Button")
    button:SetText("Blacklist")
    button:SetWidth(width)
    button:SetCallback("OnClick", function()
        settingsPanel.HandleOpenFilterListEditor("blacklist")
    end)
    filtersManagementSettingsGroup:AddChild(button)

    -- Open Blacklist Button
    local button = AceGUI:Create("Button")
    button:SetText("Whitelist")
    button:SetWidth(width)
    button:SetCallback("OnClick", function()
        settingsPanel.HandleOpenFilterListEditor("whitelist")
    end)
    filtersManagementSettingsGroup:AddChild(button)
end

-- Advanced Settings Tab
local function CreateAdvancedSettingsTab(container, tempSettingsData, columnWidth)
    container:ReleaseChildren() -- Clears the tab content before adding new widgets

    CreateFilterManagementSection(container, columnWidth, tempSettingsData)

    CreateButtonWithConfirmation(
        container,
        "Reset Looti",
        "Reset Looti",
        "Are you sure you want to reset Looti?",
        HandleReset,
        columnWidth,
        tempSettingsData
    )
end

_G["CreateAdvancedSettingsTab"] = CreateAdvancedSettingsTab

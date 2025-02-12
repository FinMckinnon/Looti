--[[
    [Future - Debugging Features] Placeholder for logs/debug mode if needed
    [Reset Button] Restore Defaults
]]--

-- Reset Looti button with confirmation pop up
local function CreateButtonWithConfirmation(parent, buttonText, confirmTitle, confirmMessage, onConfirm, width, tempSettingsData)
    local button = AceGUI:Create("Button")
    button:SetText(buttonText)
    button:SetWidth(width)
    button:SetCallback("OnClick", function()
        settingsPanel.HandleResetButtonClick(tempSettingsData)
    end)
    parent:AddChild(button)
end

-- Advanced Settings Tab
local function CreateAdvancedSettingsTab(container, tempSettingsData, columnWidth)
    container:ReleaseChildren()  -- Clears the tab content before adding new widgets

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

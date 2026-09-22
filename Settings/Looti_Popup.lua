-- Confirmation dialogue built on StaticPopupDialogs.
local ADDON, L = ...

L.Popup = {}

-- input: a dialog id, a title, a message and a callback for the accept button
-- output: nothing
-- Registers a yes or cancel dialog and shows it.
function L.Popup.Confirm(dialogID, title, message, onAccept)
    StaticPopupDialogs[dialogID] = {
        text = title .. "\n\n" .. message,
        button1 = "Yes",
        button2 = "Cancel",
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnAccept = onAccept,
    }

    StaticPopup_Show(dialogID)
end

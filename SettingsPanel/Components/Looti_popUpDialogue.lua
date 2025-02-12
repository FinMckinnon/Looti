-- Function to create a confirmation popup
local function CreateConfirmationPopup(popup_id, title, message, onConfirm)
    StaticPopupDialogs[popup_id] = {
        text = message,
        button1 = "Yes",  
        button2 = "Cancel",  
        OnAccept = function()
            onConfirm()  
        end,
        timeout = 0,  
        whileDead = true,  
        hideOnEscape = true,  
        textAlign = "CENTER",  
        title = title,  
    }
    StaticPopup_Show(popup_id)
end

_G["CreateConfirmationPopup"] = CreateConfirmationPopup

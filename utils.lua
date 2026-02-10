-- Function to get color for rarity
local function GetRarityColor(rarity)
    if rarity then
        local r, g, b = GetItemQualityColor(rarity)
        return r, g, b
    else
        return 1, 1, 1 -- Default white color
    end
end

local function PrintColoredMessage(message, color)
    local coloredMessage = "|cff" .. color .. message .. "|r"
    DEFAULT_CHAT_FRAME:AddMessage(coloredMessage)
end

local function LOOTI_CHAT_LOG(msg, event)
    local color = "1E90FF"  -- Default
    if event == "update" then
        color = "FF6347"  
    elseif event == "error" then
        color = "DC143C"  
    end
    PrintColoredMessage(msg, color)
end

local function LOOTI_DEBUG_MSG(msg)
    LOOTI_CHAT_LOG(msg)
end

local function copyTable(dest, src)
    for key, value in pairs(src) do
        dest[key] = value
    end
end

_G["GetRarityColor"] = GetRarityColor
_G["copyTable"] = copyTable
_G["LOOTI_CHAT_LOG"] = LOOTI_CHAT_LOG
_G["LOOTI_DEBUG_MSG"] = LOOTI_DEBUG_MSG

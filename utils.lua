-- Function to get color for rarity
local function GetRarityColor(rarity)
    if rarity then
        local r, g, b = GetItemQualityColor(rarity)
        return r, g, b
    else
        return 1, 1, 1 -- Default white color
    end
end

local function log(str)
    print(str)
end

_G["GetRarityColor"] = GetRarityColor
_G["log"] = log

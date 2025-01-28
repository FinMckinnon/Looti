-- Test function for multiple loot and money notifications with a 0.25s wait between each item
function Looti_Test()
    -- List of test loot items (with varying rarities)
    local lootItems = {
        "|cff9d9d9d|Hitem:6196::::::::60:::::|h[Noboru's Cudgel]|h|r",  -- Poor
        "|cffffffff|Hitem:2770:0:0:0:0:0:0:0|h[Copper Ore]|h|r",   -- Common
        "|cff1eff00|Hitem:11382::::::::80:::::|h[Blood of the Mountain]|h|r", -- Uncommon
        "|cff0070dd|Hitem:7713::::::::80:::::|h[Illusionary Rod]|h|r", -- Rare
        "|cffa335ee|Hitem:873::::::::80:::::|h[Staff of Jordan]|h|r", -- Epic
        "|cffff8000|Hitem:17182::::::::80:::::|h[Sulfuras, Hand of Ragnaros]|h|r", -- Legendary
        "|cffe5cc80|Hitem:128910::::::::80::::1:750:|h[Strom'kar, the Warbreaker]|h|r", -- Artifact
        "|cff00ccff|Hitem:48689::::::::80:::::|h[Stained Shadowcraft Tunic]|h|r", -- Heirloom
    }

    -- Test money loot (with different amounts)
    local moneyMessages = {
        "You receive loot: 50 Copper",                   
        "You receive loot: 10 Silver 30 Copper",         
        "You receive loot: 25 Silver",                   
        "You receive loot: 3 Gold 15 Silver",            
        "You receive loot: 10 Gold 50 Silver 25 Copper" 
    }

    -- Simulate loot item notifications with delay
    for _, itemLink in ipairs(lootItems) do
        local message = "You receive loot: " .. itemLink  
        handleLootMessage(notificationFrame, message)
    end

    -- Simulate money loot notifications with delay
    for _, message in ipairs(moneyMessages) do
        handleMoneyMessage(notificationFrame, message)
    end
end

-- Register a slash command for testing
SLASH_TESTLOOTI1 = "/lootitest"
SlashCmdList["TESTLOOTI"] = function()
    Looti_Test()
end

_G["Looti_Test"] = Looti_Test
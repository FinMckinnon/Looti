-- Test function for multiple loot and money notifications with a 0.25s wait between each item
function Looti_Test()
    -- List of test loot items (with varying rarities)
    local lootItems = {
        { link = "|cff9d9d9d|Hitem:6196::::::::60:::::|h[Noboru's Cudgel]|h|r",                  quantity = 1 }, -- Poor
        { link = "|cffffffff|Hitem:2770:0:0:0:0:0:0:0|h[Copper Ore]|h|r",                        quantity = 2 }, -- Common
        { link = "|cff1eff00|Hitem:11382::::::::80:::::|h[Blood of the Mountain]|h|r",           quantity = 3 }, -- Uncommon
        { link = "|cff0070dd|Hitem:7713::::::::80:::::|h[Illusionary Rod]|h|r",                  quantity = 4 }, -- Rare
        { link = "|cffa335ee|Hitem:873::::::::80:::::|h[Staff of Jordan]|h|r",                   quantity = 5 }, -- Epic
        { link = "|cffff8000|Hitem:17182::::::::80:::::|h[Sulfuras, Hand of Ragnaros]|h|r",      quantity = 6 }, -- Legendary
        { link = "|cffe5cc80|Hitem:128910::::::::80::::1:750:|h[Strom'kar, the Warbreaker]|h|r", quantity = 7 }, -- Artifact
        { link = "|cff00ccff|Hitem:48689::::::::80:::::|h[Stained Shadowcraft Tunic]|h|r",       quantity = 8 }  -- Rare
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
    for _, item in ipairs(lootItems) do
        HandleLootMessage(notificationFrame, item.link, item.quantity)
    end

    -- Simulate money loot notifications with delay
    for _, message in ipairs(moneyMessages) do
        HandleMoneyMessage(notificationFrame, message)
    end
end

-- Register a slash command for testing
SLASH_TESTLOOTI1 = "/lootitest"
SlashCmdList["TESTLOOTI"] = function()
    Looti_Test()
end

_G["Looti_Test"] = Looti_Test

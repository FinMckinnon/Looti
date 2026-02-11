-- Test function for multiple loot and money notifications with a 0.25s wait between each item
function Looti_Test()
    -- List of test loot items (with varying rarities and item types)
    local lootItems = {
        { link = "|cff9d9d9d|Hitem:6196::::::::60:::::|h[Noboru's Cudgel]|h|r",                  quantity = 1 }, -- Poor (Gear)
        { link = "|cffffffff|Hitem:2770:0:0:0:0:0:0:0|h[Copper Ore]|h|r",                        quantity = 2 }, -- Common (Trade Goods - classID 7)
        { link = "|cff1eff00|Hitem:11382::::::::80:::::|h[Blood of the Mountain]|h|r",           quantity = 3 }, -- Uncommon (Trade Goods - classID 7)
        { link = "|cff0070dd|Hitem:7713::::::::80:::::|h[Illusionary Rod]|h|r",                  quantity = 4 }, -- Rare (Gear)
        { link = "|cffa335ee|Hitem:873::::::::80:::::|h[Staff of Jordan]|h|r",                   quantity = 5 }, -- Epic (Gear)
        { link = "|cffff8000|Hitem:17182::::::::80:::::|h[Sulfuras, Hand of Ragnaros]|h|r",      quantity = 6 }, -- Legendary (Gear)
        { link = "|cffe5cc80|Hitem:128910::::::::80::::1:750:|h[Strom'kar, the Warbreaker]|h|r", quantity = 7 }, -- Artifact (Gear)
        { link = "|cff00ccff|Hitem:48689::::::::80:::::|h[Stained Shadowcraft Tunic]|h|r",       quantity = 8 }, -- Rare (Gear)
        { link = "|cffffffff|Hitem:5184::::::::20:::::|h[Filled Crystal Phial]|h|r",             quantity = 1 }, -- Quest Item (classID 12/bindType 4)
        { link = "|cffffffff|Hitem:774:0:0:0:0:0:0:0|h[Malachite]|h|r",                          quantity = 3 }, -- Common (Gem - classID 3)
        { link = "|cff1eff00|Hitem:6265::::::::80:::::|h[Recipe: Brilliant Smallfish]|h|r",      quantity = 1 }, -- Uncommon (Recipe - classID 9)
        { link = "|cff1eff00|Hitem:32622::::::::80:::::|h[Elekk Training Collar]|h|r",           quantity = 1 }, -- Rare (Pet - classID 17)
        { link = "|cffffffff|Hitem:858:0:0:0:0:0:0:0|h[Lesser Healing Potion]|h|r",              quantity = 5 }, -- Common (Consumable - classID 0)
        { link = "|cff1eff00|Hitem:6218::::::::80:::::|h[Runed Copper Rod]|h|r",                 quantity = 1 }, -- Uncommon (Profession Tool - classID 19)
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

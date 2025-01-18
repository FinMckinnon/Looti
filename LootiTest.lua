-- Test function for multiple loot and money notifications with a 0.25s wait between each item
function Looti_Test()
    -- List of test loot items (with varying rarities)
    local lootItems = {
        { name = "Epic Sword", rarity = 4, icon = "Interface\\Icons\\INV_Sword_05", quantity = 1 },
        { name = "Rare Shield", rarity = 3, icon = "Interface\\Icons\\INV_Shield_05", quantity = 1 },
        { name = "Common Helmet", rarity = 2, icon = "Interface\\Icons\\INV_Helmet_01", quantity = 1 },
        { name = "Poor Boots", rarity = 1, icon = "Interface\\Icons\\INV_Boots_01", quantity = 3 },
    }

    -- Test money loot (with different amounts)
    local moneyItems = {
        { gold = 5000, silver = 0, copper = 0 },   -- 5000 gold
        { gold = 0, silver = 250, copper = 0 },    -- 250 silver
        { gold = 0, silver = 0, copper = 1200 },   -- 1200 copper
        { gold = 1, silver = 50, copper = 500 },   -- 1 gold, 50 silver, 500 copper
    }

    -- Helper function to show loot item notification
    local function ShowLootNotification(item, delay)
        C_Timer.After(delay, function()
            local lootData = {
                itemName = item.name,
                itemLink = string.format("|c%x+|Hitem:12345::::::::60:::::::|h[%s]|h|r", 12345, item.name),  -- 12345 is a dummy item ID
                itemIcon = item.icon,  -- Item icon path
            }
            local currencyData = nil  -- No currency for loot notification
            Looti_ShowNotification(notificationFrame, lootData, currencyData, item.rarity)
        end)
    end

    -- Helper function to show money loot notification
    local function ShowMoneyNotification(currency, delay)
        C_Timer.After(delay, function()
            -- Calculate totalCopper from gold, silver, and copper
            local totalCopper = (currency.gold * 10000) + (currency.silver * 100) + currency.copper
            
            if totalCopper > 0 then
                local moneyData = {
                    totalCopper = totalCopper,
                    text = GetCoinTextureString(totalCopper),
                    icon = currency.gold > 0 and currencyIcons.gold or currency.silver > 0 and currencyIcons.silver or currencyIcons.copper,
                }
        
                -- Show notification for looted money
                Looti_ShowNotification(notificationFrame, nil, moneyData, -1)  -- -1 for money items (custom rarity)
            end
        end)
    end

    -- Simulate loot item notifications with delay
    local delay = 0
    for _, item in ipairs(lootItems) do
        delay = delay + 0.25  -- Increase delay for each item
        ShowLootNotification(item, delay)
    end

    -- Simulate money loot notifications with delay
    for _, currency in ipairs(moneyItems) do
        delay = delay + 0.25  -- Increase delay for each money item
        ShowMoneyNotification(currency, delay)
    end
end

-- Register a slash command for testing
SLASH_TESTLOOTI1 = "/lootitest"
SlashCmdList["TESTLOOTI"] = function()
    Looti_Test()
end

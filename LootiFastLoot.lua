local function IsInventoryFull()
    for bag = 0, 4 do
        local freeSlots = C_Container.GetContainerNumFreeSlots(bag)
        if freeSlots > 0 then
            return false
        end
    end
    return true
end

local function handleFastLoot()
    -- Check if inventory is full first
    if IsInventoryFull() then
        print("|cffff0000[Looti]|r Inventory is full!")
        PlaySound(SOUNDKIT.RAID_WARNING)
        return  -- Don't try to loot anything
    end
    
    local originalAutoLoot = GetCVar("autoLootDefault")
    SetCVar("autoLootDefault", "1")
    
    local hasBoP = false
    
    -- Loot everything except BoP items
    for i = GetNumLootItems(), 1, -1 do
        local slotType = GetLootSlotType(i)
        local isBoP = false
        
        if slotType == LOOT_SLOT_ITEM then
            local itemLink = GetLootSlotLink(i)
            if itemLink then
                local tooltip = CreateFrame("GameTooltip", "LootiScanTooltip"..i, nil, "GameTooltipTemplate")
                tooltip:SetOwner(UIParent, "ANCHOR_NONE")
                tooltip:SetLootItem(i)
                
                for j = 1, tooltip:NumLines() do
                    local text = _G["LootiScanTooltip"..i.."TextLeft"..j]:GetText()
                    if text and (text:find("Binds when picked up") or text:find("Soulbound")) then
                        isBoP = true
                        hasBoP = true
                        break
                    end
                end
            end
        end
        
        -- Only loot if it's not BoP
        if not isBoP then
            LootSlot(i)
        end
    end
    
    SetCVar("autoLootDefault", originalAutoLoot)
    
    -- Only close if there's no BoP left
    if not hasBoP then
        CloseLoot()
    else
        print("|cffff0000[Looti]|r Bind on Pickup item detected! Review remaining loot.")
        PlaySound(SOUNDKIT.RAID_WARNING)
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("LOOT_READY")
frame:SetScript("OnEvent", function(self, event)
    if event == "LOOT_READY" then
        handleFastLoot()
    end
end)
_G["handleFastLoot"] = handleFastLoot
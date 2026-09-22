-- Fires sample notifications from a slash command.
local ADDON, L = ...

local SAMPLE_ITEMS = {
    { link = "|cff9d9d9d|Hitem:6196::::::::60:::::|h[Noboru's Cudgel]|h|r", quantity = 1 },
    { link = "|cffffffff|Hitem:2770:0:0:0:0:0:0:0|h[Copper Ore]|h|r", quantity = 12 },
    { link = "|cff1eff00|Hitem:11382::::::::80:::::|h[Blood of the Mountain]|h|r", quantity = 3 },
    { link = "|cff0070dd|Hitem:7713::::::::80:::::|h[Illusionary Rod]|h|r", quantity = 1 },
    { link = "|cffa335ee|Hitem:873::::::::80:::::|h[Staff of Jordan]|h|r", quantity = 1 },
    { link = "|cffff8000|Hitem:17182::::::::80:::::|h[Sulfuras, Hand of Ragnaros]|h|r", quantity = 1 },
    { link = "|cffffffff|Hitem:858:0:0:0:0:0:0:0|h[Lesser Healing Potion]|h|r", quantity = 5 },
}

-- Copper amounts rather than chat text, so the preview does not depend on the
-- wording of a money message.
local SAMPLE_MONEY = { 50, 1030, 31500 }

-- input: nothing
-- output: nothing
-- Shows one notification per sample item and money amount.
local function RunPreview()
    for _, sample in ipairs(SAMPLE_ITEMS) do
        L.Events.Present(sample.link, sample.quantity)
    end

    for _, copper in ipairs(SAMPLE_MONEY) do
        L.Queue.Add(nil, { totalCopper = copper, text = GetCoinTextureString(copper) })
    end
end

L.RunPreview = RunPreview

SLASH_LOOTITEST1 = "/lootitest"
SlashCmdList["LOOTITEST"] = RunPreview

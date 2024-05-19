local Module = {}

Module.InventoryTierPrices = {
	nil,
	1400,  -- Tier2
	2000,
	3000,
	4000,
	5000,
	6000,
	7000,
	8000,
	9000,
	10000,
	10000,
	10000,
	10000,
	10000,
	10000, -- Tier16
}

Module.MaxPageForTier = {
	1, -- Tier 1 (Default)
	2,
	2,
	3,
	3,
	4,
	4,
	5,
	5,
	6,
	6,
	7,
	7,
	8,
	8,
	8, -- Tier 16
}

Module.InventorySlotsPerTier = {
	21, -- Page1 (Default, 1)
	28, -- Page1
	42, -- Page2
	56, -- Page2
	70, -- Page3
	84, -- Page3
	98, -- Page4
	112, -- Page4
	126, -- Page5
	140, -- Page5
	154, -- Page6
	168, -- Page6
	182, -- Page7
	196, -- Page7
	210, -- Page8
	224, -- Page8 (Max, 16)
}

Module.SlotStartNumberPerPage = {
	1, -- Page1
	29, -- Page2
	57,  -- Page3
	85,  -- Page4
	113, -- Page5
	141, -- Page6
	169, -- Page7
	197, -- Page8
}

Module.SlotEndNumberPerPage = {
	28, -- Page1
	56, -- Page2
	84, -- Page3
	112, -- Page4
	140, -- Page5
	168, -- Page6
	196, -- Page7
	224, -- Page8
}

-- Format: [pageNumber, slotNumber]
Module.PositionsForExpandInvButton = {
	{nil},
	{1, 22}, -- Tier2
	{2, 1},
	{2, 15},
	{3, 1},
	{3, 15},
	{4, 1},
	{4, 15},
	{5, 1},
	{5, 15},
	{6, 1},
	{6, 15},
	{7, 1},
	{7, 15},
	{8, 1},
	{8, 15}, -- Tier16
}

function Module.GetTierPrice(tier)
	return Module.InventoryTierPrices[tier]
end

function Module.GetSlotsPerTier(tier)
	return Module.InventorySlotsPerTier[tier]
end

function Module.GetSlotStartNumber(page)
	return Module.SlotStartNumberPerPage[page]
end

function Module.GetSlotEndNumber(page, currentTier)
	return math.min(Module.SlotEndNumberPerPage[page], Module.InventorySlotsPerTier[currentTier])
end

function Module.GetPositionForExpandGuiBtn(tier)
	return Module.PositionsForExpandInvButton[tier]
end

function Module.GetMaxPageForTier(tier)
	return Module.MaxPageForTier[tier]
end



return Module
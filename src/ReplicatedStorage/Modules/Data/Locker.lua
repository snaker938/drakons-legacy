local Module = {}


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

Module.LockerTierPrices = {
	nil,
	1400, -- Tier 2
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
	10000, -- Tier 16
}

Module.LockerSlotsPerTier = {
	10, -- Page1 (Default, 1)
	20, -- Page1
	30, -- Page2
	40, -- Page2
	50, -- Page3
	60, -- Page3
	70, -- Page4
	80, -- Page4
	90, -- Page5
	100, -- Page5
	110, -- Page6
	120, -- Page6
	130, -- Page7
	140, -- Page7
	150, -- Page8
	160, -- Page8 (Max, 16)
}


Module.SlotStartNumberPerPage = {
	1, -- Page1
	21,
	41,
	61,
	81,
	101,
	121,
	141,
	161, -- Page8
}


Module.SlotEndNumberPerPage = {
	20, -- Page1
	40,
	60,
	80,
	100,
	120,
	140,
	160,
	180, -- Page8
}


-- Format: [pageNumber, slotNumber]
Module.PositionsForExpandLockerButton = {
	{nil},
	{1, 11}, -- Tier 2
	{2, 1},
	{2, 11},
	{3, 1},
	{3, 11},
	{4, 1},
	{4, 11},
	{5, 1},
	{5, 11},
	{6, 1},
	{6, 11},
	{7, 1},
	{7, 11},
	{8, 1},
	{8, 11}, -- Tier 16
}

function Module.GetTierPrice(tier)
	return Module.LockerTierPrices[tier]
end

function Module.GetSlotsPerTier(tier)
	return Module.LockerSlotsPerTier[tier]
end

function Module.GetSlotStartNumber(page)
	return Module.SlotStartNumberPerPage[page]
end

function Module.GetSlotEndNumber(page, currentTier)
	return math.min(Module.SlotEndNumberPerPage[page], Module.LockerSlotsPerTier[currentTier])
end

function Module.GetPositionForExpandGuiBtn(tier)
	return Module.PositionsForExpandLockerButton[tier]
end

function Module.GetMaxPageForTier(tier)
	return Module.MaxPageForTier[tier]
end

return Module
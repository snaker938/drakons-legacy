local Module = {}

Module.LockerTierPrices = {
	nil,
	1400, -- Tier 2
	2000,
	3000,
	4000,
	5000,
	6000,
	7000,
	8500,
	8600,
	8700,
	8800,
	8900,
	9000, -- Tier 14
}

Module.LockerSlotsPerTier = {
	10, -- Page1
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
}

Module.SlotStartNumberPerPage = {
	1, -- Page1
	21,
	41,
	61,
	81,
	101,
	121, -- Page7
}

Module.SlotEndNumberPerPage = {
	20, -- Page1
	40,
	60,
	80,
	100,
	120,
	140, -- Page7
}

-- Format: [pageNumber, slotNumber]
Module.PositionsForExpandLockerButton = {
	nil,
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
	{7, 11} -- Tier 14
}

function Module.GetLockerTierPrice(tier)
	return Module.LockerTierPrices[tier]
end

function Module.GetLockerSlotsPerTier(tier)
	return Module.LockerSlotsPerTier[tier]
end

function Module.GetSlotStartNumber(page)
	return Module.SlotStartNumberPerPage[page]
end

function Module.GetSlotEndNumber(page, currentTier)
	return math.min(Module.SlotEndNumberPerPage[page], Module.LockerSlotsPerTier[currentTier])
end

function Module.GetPositionForExpandLockerButton(tier)
	return Module.PositionsForExpandLockerButton[tier]
end

return Module
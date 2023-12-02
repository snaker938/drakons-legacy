local Module = {}

Module.LockerTierPrices = {
	Tier1 = 1400,
	Tier2 = 2000,
	Tier3 = 3000,
	Tier4 = 4000,
	Tier5 = 5000,
	Tier6 = 6000,
	Tier7 = 7000,
	Tier8 = 8500,
	Tier9 = 8600,
	Tier10 = 8700,
	Tier11 = 8800,
	Tier12 = 8900,
	Tier13 = 9000,
}

Module.LockerSlotsPerTier = {
	Tier0 = 10, -- Page1
	Tier1 = 20, -- Page1
	Tier2 = 30, -- Page2
	Tier3 = 40, -- Page2
	Tier4 = 50, -- Page3
	Tier5 = 60, -- Page3
	Tier6 = 70, -- Page4
	Tier7 = 80, -- Page4
	Tier8 = 90, -- Page5
	Tier9 = 100, -- Page5
	Tier10 = 110, -- Page6
	Tier11 = 120, -- Page6
	Tier12 = 130, -- Page7
	Tier13 = 140, -- Page7
}

Module.SlotStartNumberPerPage = {
	Page1 = 1,
	Page2 = 21,
	Page3 = 41,
	Page4 = 61,
	Page5 = 81,
	Page6 = 101,
	Page7 = 121,
}

Module.SlotEndNumberPerPage = {
	Page1 = 20,
	Page2 = 40,
	Page3 = 60,
	Page4 = 80,
	Page5 = 100,
	Page6 = 120,
	Page7 = 140,
}

-- Format: [pageNumber, slotNumber]
Module.PositionsForExpandLockerButton = {
	Tier1 = {1, 11},
	Tier2 = {2, 1},
	Tier3 = {2, 11},
	Tier4 = {3, 1},
	Tier5 = {3, 11},
	Tier6 = {4, 1},
	Tier7 = {4, 11},
	Tier8 = {5, 1},
	Tier9 = {5, 11},
	Tier10 = {6, 1},
	Tier11 = {6, 11},
	Tier12 = {7, 1},
	Tier13 = {7, 11}
}

return Module
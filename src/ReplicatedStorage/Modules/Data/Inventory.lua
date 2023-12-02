local Module = {}

Module.InventoryTierPrices = {
	Tier1 = 1400,
	Tier2 = 2000,
	Tier3 = 3000,
	Tier4 = 4000,
	Tier5 = 5000,
	Tier6 = 6000,
	Tier7 = 7000,
	Tier8 = 8000,
	Tier9 = 9000,
	Tier10= 10000,
	Tier11 = 10000,
	Tier12 = 10000,
	Tier13 = 10000,
	Tier14 = 10000,
	Tier15 = 10000,
}

Module.InventorySlotsPerTier = {
	Tier0 = 21, -- Page1
	Tier1 = 28, -- Page1
	Tier2 = 42, -- Page2
	Tier3 = 56, -- Page2
	Tier4 = 70, -- Page3
	Tier5 = 84, -- Page3
	Tier6 = 98, -- Page4
	Tier7 = 112, -- Page4
	Tier8 = 126, -- Page5
	Tier9 = 140, -- Page5
	Tier10 = 154, -- Page6
	Tier11 = 168, -- Page6
	Tier12 = 182, -- Page7
	Tier13 = 196, -- Page7
	Tier14 = 210, -- Page8
	Tier15 = 224, -- Page8
}

Module.SlotStartNumberPerPage = {
	Page1 = 1,
	Page2 = 29,
	Page3 = 57,
	Page4 = 85,
	Page5 = 113,
	Page6 = 141,
	Page7 = 169,
	Page8 = 197,
}

Module.SlotEndNumberPerPage = {
	Page1 = 28,
	Page2 = 56,
	Page3 = 84,
	Page4 = 112,
	Page5 = 140,
	Page6 = 168,
	Page7 = 196,
	Page8 = 224,
}

-- Format: [pageNumber, slotNumber]
Module.PositionsForExpandInvButton = {
	Tier1 = {1, 22},
	Tier2 = {2, 1},
	Tier3 = {2, 15},
	Tier4 = {3, 1},
	Tier5 = {3, 15},
	Tier6 = {4, 1},
	Tier7 = {4, 15},
	Tier8 = {5, 1},
	Tier9 = {5, 15},
	Tier10 = {6, 1},
	Tier11 = {6, 15},
	Tier12 = {7, 1},
	Tier13 = {7, 15},
	Tier14 = {8, 1},
	Tier15 = {8, 15},
}

return Module
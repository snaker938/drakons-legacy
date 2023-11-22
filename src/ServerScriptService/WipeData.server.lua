local WipeDataEvent = game:GetService("ReplicatedStorage"):WaitForChild("WipeDataEvent")
local DataStoreModule = require(game.ServerStorage.DataStore)


WipeDataEvent.OnServerEvent:Connect(function(player)
	
	local GlobalData = DataStoreModule.find("Player", player.UserId, "GlobalData")
	if GlobalData == nil then return false end
	if GlobalData.State ~= true then return false end
	GlobalData.Value = {
		CurrentlyPlayingProfile = 0,
		Draken = 0,
	}
	
	GlobalData:Save()
	
	for i = 1, 4 do
		local profileData = DataStoreModule.find("Player", player.UserId, "Profile_" .. i)
		if profileData == nil then return false end
		if profileData.State ~= true then return false end
		
		profileData.Value = {
			CurrentlyPlaying = false,
			HasPlayed = false,
			CharacterName = "",
			ClassType = "",
			CharacterLevel = 1,
			CharacterXP = 0,
			LastUrbanArea = "",
			LastArea = "Starfall Bastion",
			QuestData = {},
			Inventory = {},
			InventoryTier = 0,
			EquippedItems = {},
			CurrencyBag = {},
			MapStatus = {},
			SkillTree = {},
			SkillHotbar = {},
			EquippedPotions = {},
			EquippedEssence = {},
			EquippedMount = {},
			Buffs = {},
			WisdomTree = {},
			Locker = {},
			LockerTier = 0,
			Gamepasses = {},
			OtherStats = {},}
		
		profileData:Save()
	end
end)
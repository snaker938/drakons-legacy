local DataStoreModule = require(game.ServerStorage.DataStore)

local ProfileDataTemplate = {
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
	OtherStats = {},
}

local GlobalDataTemplate = {
	CurrentlyPlayingProfile = 0,
	Draken = 0,
}


local function setCurrentlyPlayingToFalse(player)
	for i = 1, 4 do
		local profileData = DataStoreModule.find("Player", player.UserId, "Profile_" .. i)
		if profileData == nil then continue end
		if profileData.State ~= true then continue end

		profileData.Value.CurrentlyPlaying = false

	end
	local GlobalData = DataStoreModule.find("Player", player.UserId, "GlobalData")
	GlobalData.Value.CurrentlyPlayingProfile = 0
	return
end


local function ProfileStateChanged(state, dataStore)
	while dataStore.State == false do
		if dataStore:Open(ProfileDataTemplate) ~= "Success" then task.wait(6) end
	end
end

local function GlobalDataStateChanged(state, dataStore)
	while dataStore.State == false do
		if dataStore:Open(GlobalDataTemplate) ~= "Success" then task.wait(6) end
	end
end

game.Players.PlayerAdded:Connect(function(player)
	local Profile_1_Data = DataStoreModule.new("Player", player.UserId, "Profile_1")
	local Profile_2_Data = DataStoreModule.new("Player", player.UserId, "Profile_2")
	local Profile_3_Data = DataStoreModule.new("Player", player.UserId, "Profile_3")
	local Profile_4_Data = DataStoreModule.new("Player", player.UserId, "Profile_4")
	
	local PlayerGlobalData = DataStoreModule.new("Player", player.UserId, "GlobalData")
	--local Profile_5_Data = DataStoreModule.new("Player", player.UserId, "Profile_5")
	
	Profile_1_Data.StateChanged:Connect(ProfileStateChanged)
	ProfileStateChanged(Profile_1_Data.State, Profile_1_Data)
		
	Profile_2_Data.StateChanged:Connect(ProfileStateChanged)
	ProfileStateChanged(Profile_2_Data.State, Profile_2_Data)
	
	Profile_3_Data.StateChanged:Connect(ProfileStateChanged)
	ProfileStateChanged(Profile_3_Data.State, Profile_3_Data)
	
	Profile_4_Data.StateChanged:Connect(ProfileStateChanged)
	ProfileStateChanged(Profile_4_Data.State, Profile_4_Data)
	
	PlayerGlobalData.StateChanged:Connect(GlobalDataStateChanged)
	GlobalDataStateChanged(PlayerGlobalData.State, PlayerGlobalData)
	
	setCurrentlyPlayingToFalse(player)
	
end)

game.Players.PlayerRemoving:Connect(function(player)
	local Profile_1_Data = DataStoreModule.find("Player", player.UserId, "Profile_1")
	local Profile_2_Data = DataStoreModule.find("Player", player.UserId, "Profile_2")
	local Profile_3_Data = DataStoreModule.find("Player", player.UserId, "Profile_3")
	local Profile_4_Data = DataStoreModule.find("Player", player.UserId, "Profile_4")
	--local Profile_5_Data = DataStoreModule.find("Player", player.UserId, "Profile_5")
	
	local GlobalPlayerData = DataStoreModule.find("Player", player.UserId, "GlobalData")
	
	
	if Profile_1_Data ~= nil then Profile_1_Data:Destroy() end
	if Profile_2_Data ~= nil then Profile_2_Data:Destroy() end
	if Profile_3_Data ~= nil then Profile_3_Data:Destroy() end
	if Profile_4_Data ~= nil then Profile_4_Data:Destroy() end
	--if Profile_5_Data ~= nil then Profile_5_Data:Destroy() end
	
	if GlobalPlayerData ~= nil then GlobalPlayerData:Destroy() end
end)
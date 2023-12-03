local ServerStorage = game:GetService('ServerStorage')
local ServerModules = require(ServerStorage:WaitForChild("Modules"))

local Players = game:GetService("Players")

local DataStoreModule = ServerModules.Services.DataStore
local ReplicaService = require(game:GetService("ServerScriptService").ReplicaService)

local SystemsContainer = {}

-- // Data Templates -- //
local ProfileDataTemplate = {
	CharacterName = "",
	ClassType = "",
	CharacterLevel = 1,
	CharacterXP = 0,
	LastUrbanArea = "",
	LastArea = "Starfall Bastion",
	-- QuestData = {},
	Inventory = {},
	InventoryTier = 0,
	-- EquippedItems = {},
	-- CurrencyBag = {},
	-- MapStatus = {},
	-- SkillTree = {},
	-- SkillHotbar = {},
	-- EquippedPotions = {},
	-- EquippedEssence = {},
	-- EquippedMount = {},
	-- Buffs = {},
	-- WisdomTree = {},
	Locker = {},
	LockerTier = 0,
	-- Gamepasses = {},
	-- OtherStats = {},
}

local GlobalDataTemplate = {
	NumSlotsUsed = 0,
	CurrentlyPlayingProfile = -1,
	Draken = 0,
	Banned = false,
	Version = 1,
}

local PlayerProfile -- PlayerProfile object
local PlayerProfiles = {} -- [player] = {Profile = profile, Replica = replica}

local GlobalProfile -- GlobalProfile object
local GlobalProfiles = {} -- [player] = {Global = global, Replica = replica}

--------

-- // Module // --
local Module = {ProfileDataTemplate = ProfileDataTemplate, GlobalDataTemplate = GlobalDataTemplate}

function Module.GetDataTemplate(type)
	if type == "player" then
		return ProfileDataTemplate
	elseif type == "global" then
		return GlobalDataTemplate
	end
end

function Module.ProfileStateChanged(state, dataStore)
	while dataStore.State == false do
		if dataStore:Open(ProfileDataTemplate) ~= "Success" then task.wait(6) end
	end
end

function Module.GlobalDataStateChanged(state, dataStore)
	while dataStore.State == false do
		if dataStore:Open(GlobalDataTemplate) ~= "Success" then task.wait(6) end
	end
end

function Module.CloseDataStoresNotInUse(localPlayer : Player)
	local globalData = SystemsContainer.ProfileHandling.GetCurrentUserData(localPlayer, "global")
	local CurrentlyPlayingProfile = globalData.Value.CurrentlyPlayingProfile

    for profileNum = 1, 4 do
		local profileData = SystemsContainer.ProfileHandling.GetSpecificProfileData(localPlayer, profileNum)

		if profileNum == tonumber(CurrentlyPlayingProfile) then
			continue
		else
			profileData:Destroy()
		end
	end

	Module.ReplicateDataToClient(localPlayer, CurrentlyPlayingProfile)
end

function Module.SetCurrentlyPlayingToFalse(localPlayer : Player)
 	local GlobalData = SystemsContainer.ProfileHandling.GetCurrentUserData(localPlayer, "global")
	GlobalData.Value.CurrentlyPlayingProfile = -1
end

function Module.OnPlayerAdded(localPlayer : Player)
	if localPlayer:IsDescendantOf(Players) == false then
		localPlayer:Kick("Critical Error Getting Player Data")
	end

	local Profile_1_Data = DataStoreModule.new("Player", localPlayer.UserId, "Profile_1")
	local Profile_2_Data = DataStoreModule.new("Player", localPlayer.UserId, "Profile_2")
	local Profile_3_Data = DataStoreModule.new("Player", localPlayer.UserId, "Profile_3")
	local Profile_4_Data = DataStoreModule.new("Player", localPlayer.UserId, "Profile_4")

	local PlayerGlobalData = DataStoreModule.new("Player", localPlayer.UserId, "GlobalData")
	--local Profile_5_Data = DataStoreModule.new("Player", player.UserId, "Profile_5")

	Profile_1_Data.StateChanged:Connect(function(...)
		Module.ProfileStateChanged(...)
	end)
	Module.ProfileStateChanged(Profile_1_Data.State, Profile_1_Data)

	Profile_2_Data.StateChanged:Connect(function(...)
		Module.ProfileStateChanged(...)
	end)
	Module.ProfileStateChanged(Profile_2_Data.State, Profile_2_Data)

	Profile_3_Data.StateChanged:Connect(function(...)
		Module.ProfileStateChanged(...)
	end)
	Module.ProfileStateChanged(Profile_3_Data.State, Profile_3_Data)

	Profile_4_Data.StateChanged:Connect(function(...)
		Module.ProfileStateChanged(...)
	end)
	Module.ProfileStateChanged(Profile_4_Data.State, Profile_4_Data)

	PlayerGlobalData.StateChanged:Connect(function(...)
		Module.GlobalDataStateChanged(...)
	end)
	Module.GlobalDataStateChanged(PlayerGlobalData.State, PlayerGlobalData)

	-- SystemsContainer.WipeData:WipePlayerData(localPlayer, nil, true)

	-- for i = 1, 4 do
	-- 	local profileData = DataStoreModule.find("Player", localPlayer.UserId, "Profile_" .. i)
	-- 	print(profileData.Value)
	-- 	if profileData == nil then continue end
	-- 	if profileData.State ~= true then continue end
	-- end

	SystemsContainer.ProfileHandling.SendLoadProfileDataToClient(localPlayer)


	-- profileData = DataStoreModule.find("Player", localPlayer.UserId, "GlobalData")
	-- print(profileData.Value)
end

function Module.OnPlayerRemoving(localPlayer)
	local Profile_1_Data = DataStoreModule.find("Player", localPlayer.UserId, "Profile_1")
	local Profile_2_Data = DataStoreModule.find("Player", localPlayer.UserId, "Profile_2")
	local Profile_3_Data = DataStoreModule.find("Player", localPlayer.UserId, "Profile_3")
	local Profile_4_Data = DataStoreModule.find("Player", localPlayer.UserId, "Profile_4")
	--local Profile_5_Data = DataStoreModule.find("Player", player.UserId, "Profile_5")

	Module.SetCurrentlyPlayingToFalse(localPlayer)


	if Profile_1_Data ~= nil then Profile_1_Data:Destroy() end
	if Profile_2_Data ~= nil then Profile_2_Data:Destroy() end
	if Profile_3_Data ~= nil then Profile_3_Data:Destroy() end
	if Profile_4_Data ~= nil then Profile_4_Data:Destroy() end
	--if Profile_5_Data ~= nil then Profile_5_Data:Destroy() end

	local GlobalPlayerData = DataStoreModule.find("Player", localPlayer.UserId, "GlobalData")

	if GlobalPlayerData ~= nil then GlobalPlayerData:Destroy() end

	local player_profile = PlayerProfiles[localPlayer]
    if player_profile ~= nil then
        PlayerProfiles[localPlayer].Replica:Destroy()
        PlayerProfiles[localPlayer] = nil
    end

	local global_profile = GlobalProfiles[localPlayer]
    if global_profile ~= nil then
        GlobalProfiles[localPlayer].Replica:Destroy()
        GlobalProfiles[localPlayer] = nil
    end
end


function Module.Start()
	for _, localPlayer in ipairs(Players:GetPlayers()) do
		task.defer(function()
			Module.OnPlayerAdded(localPlayer)
		end)
	end

	Players.PlayerAdded:Connect(function(localPlayer)
		Module.OnPlayerAdded(localPlayer)
	end)
	
	Players.PlayerRemoving:Connect(function(localPlayer)
		Module.OnPlayerRemoving(localPlayer)
	end)

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end


-- Replica Handling

function Module.ReplicateDataToClient(localPlayer : Player, playSlot : number)
	warn("TO FINISH: Replicating data to client")
	if true then return end
	warn("THIS SHOULD NOT BE PRINTING!!")
	-- Profile Replica
    local PlayerProfileClassToken = ReplicaService.NewClassToken("PlayerProfile_" .. localPlayer.UserId)

    local profile = SystemsContainer.ProfileHandling.GetSpecificProfileData(localPlayer, playSlot)

    local player_profile = {
		Profile = profile,
		Replica = ReplicaService.NewReplica({
			ClassToken = PlayerProfileClassToken,
			Tags = {Player = localPlayer},
			Data = profile,
			Replication = localPlayer,
		}),
		_player = localPlayer,
	}
	setmetatable(player_profile, PlayerProfile)
	PlayerProfiles[localPlayer] = player_profile


	-- Global Replica
	local GlobalProfileClassToken = ReplicaService.NewClassToken("GlobalProfile_" .. localPlayer.UserId)

	local globalProfile = SystemsContainer.ProfileHandling.GetCurrentUserData(localPlayer, "global")

	local global_profile = {
		Global = globalProfile,
		Replica = ReplicaService.NewReplica({
			ClassToken = GlobalProfileClassToken,
			Tags = {Player = localPlayer},
			Data = globalProfile,
			Replication = localPlayer,
		}),
		_player = localPlayer
	}

	setmetatable(global_profile, GlobalProfile)
	GlobalProfiles[localPlayer] = global_profile
end

----- Public functions -----

-- PlayerProfile object:
PlayerProfile = {
	--[[
		_player = player,
	--]]
}

-- GlobalProfile object:
GlobalProfile = {
	--[[
		_player = player,
	--]]
}

PlayerProfile.__index = PlayerProfile

GlobalProfile.__index = GlobalProfile

function GlobalProfile.IsActive(self)
	return PlayerProfiles[self._player] ~= nil
end

function PlayerProfile.IsActive(self) --> is_active
	return GlobalProfiles[self._player] ~= nil
end

return Module


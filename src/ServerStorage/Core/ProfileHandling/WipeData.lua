local ServerStorage = game:GetService('ServerStorage')
local ServerModules = require(ServerStorage:WaitForChild("Modules"))

local Packages = game:GetService("ReplicatedStorage").Packages
local Red = require(Packages.Red)

-- local Net = Red.Server("RemoteSpace")

local Players = game:GetService("Players")

local DataStoreModule = ServerModules.Services.DataStore

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module:WipePlayerData(localPlayer)
	local GlobalData = DataStoreModule.find("Player", localPlayer.UserId, "GlobalData")
	if GlobalData == nil then return false end
	if GlobalData.State ~= true then return false end
	GlobalData.Value = {
		CurrentlyPlayingProfile = 0,
		Draken = 0,
	}

	GlobalData:Save()

	for i = 1, 4 do
		local profileData = DataStoreModule.find("Player", localPlayer.UserId, "Profile_" .. i)
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
end

function Module:Start()
	-- Net:On("WipePlayerData", function(localPlayer)
	-- 	Module:WipePlayerData(localPlayer)
	-- end)
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
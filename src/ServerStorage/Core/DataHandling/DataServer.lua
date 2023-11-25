local ServerStorage = game:GetService('ServerStorage')
local ServerModules = require(ServerStorage:WaitForChild("Modules"))

local Players = game:GetService("Players")

local DataStoreModule = ServerModules.Services.DataStore

local SystemsContainer = {}

-- // Data Templates -- //
local ProfileDataTemplate = {
	CharacterName = "",
	ClassType = "",
	CharacterLevel = 1,
	CharacterXP = 0,
	-- LastUrbanArea = "",
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
	NumSlotsUsed = -1,
	CurrentlyPlayingProfile = -1,
	Draken = 0,
	Banned = false,
	Version = 1,
}

--------

-- // Module // --
local Module = {ProfileDataTemplate = ProfileDataTemplate, GlobalDataTemplate = GlobalDataTemplate}

function Module:GetDataTemplate(type)
	if type == "player" then
		return ProfileDataTemplate
	elseif type == "global" then
		return GlobalDataTemplate
	end
end

function Module:ProfileStateChanged(state, dataStore)
	while dataStore.State == false do
		if dataStore:Open(ProfileDataTemplate) ~= "Success" then task.wait(6) end
	end
end

function Module:GlobalDataStateChanged(state, dataStore)
	while dataStore.State == false do
		if dataStore:Open(GlobalDataTemplate) ~= "Success" then task.wait(6) end
	end
end

function Module:OnPlayerAdded(localPlayer)
	local Profile_1_Data = DataStoreModule.new("Player", localPlayer.UserId, "Profile_1")
	local Profile_2_Data = DataStoreModule.new("Player", localPlayer.UserId, "Profile_2")
	local Profile_3_Data = DataStoreModule.new("Player", localPlayer.UserId, "Profile_3")
	local Profile_4_Data = DataStoreModule.new("Player", localPlayer.UserId, "Profile_4")

	local PlayerGlobalData = DataStoreModule.new("Player", localPlayer.UserId, "GlobalData")
	--local Profile_5_Data = DataStoreModule.new("Player", player.UserId, "Profile_5")

	Profile_1_Data.StateChanged:Connect(function(...)
		Module:ProfileStateChanged(...)
	end)
	Module:ProfileStateChanged(Profile_1_Data.State, Profile_1_Data)

	Profile_2_Data.StateChanged:Connect(function(...)
		Module:ProfileStateChanged(...)
	end)
	Module:ProfileStateChanged(Profile_2_Data.State, Profile_2_Data)

	Profile_3_Data.StateChanged:Connect(function(...)
		Module:ProfileStateChanged(...)
	end)
	Module:ProfileStateChanged(Profile_3_Data.State, Profile_3_Data)

	Profile_4_Data.StateChanged:Connect(function(...)
		Module:ProfileStateChanged(...)
	end)
	Module:ProfileStateChanged(Profile_4_Data.State, Profile_4_Data)

	PlayerGlobalData.StateChanged:Connect(function(...)
		Module:GlobalDataStateChanged(...)
	end)
	Module:GlobalDataStateChanged(PlayerGlobalData.State, PlayerGlobalData)

	-- SystemsContainer.WipeData:WipePlayerData(localPlayer)
	-- for i = 1, 4 do
	-- 	local profileData = DataStoreModule.find("Player", localPlayer.UserId, "Profile_" .. i)
	-- 	if profileData == nil then continue end
	-- 	if profileData.State ~= true then continue end

	-- 	print(profileData.Value)
	-- end
	-- profileData = DataStoreModule.find("Player", localPlayer.UserId, "GlobalData")
	-- print(profileData.Value)
end

function Module:OnPlayerRemoving(localPlayer)
	local Profile_1_Data = DataStoreModule.find("Player", localPlayer.UserId, "Profile_1")
	local Profile_2_Data = DataStoreModule.find("Player", localPlayer.UserId, "Profile_2")
	local Profile_3_Data = DataStoreModule.find("Player", localPlayer.UserId, "Profile_3")
	local Profile_4_Data = DataStoreModule.find("Player", localPlayer.UserId, "Profile_4")
	--local Profile_5_Data = DataStoreModule.find("Player", player.UserId, "Profile_5")

	SystemsContainer.ProfileHandling:SetCurrentlyPlayingToFalse(localPlayer)

	if Profile_1_Data ~= nil then Profile_1_Data:Destroy() end
	if Profile_2_Data ~= nil then Profile_2_Data:Destroy() end
	if Profile_3_Data ~= nil then Profile_3_Data:Destroy() end
	if Profile_4_Data ~= nil then Profile_4_Data:Destroy() end
	--if Profile_5_Data ~= nil then Profile_5_Data:Destroy() end

	local GlobalPlayerData = DataStoreModule.find("Player", localPlayer.UserId, "GlobalData")

	if GlobalPlayerData ~= nil then GlobalPlayerData:Destroy() end
end


function Module:Start()
	Players.PlayerAdded:Connect(function(localPlayer)
		Module:OnPlayerAdded(localPlayer)
	end)
	
	Players.PlayerRemoving:Connect(function(localPlayer)
		Module:OnPlayerRemoving(localPlayer)
	end)

end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
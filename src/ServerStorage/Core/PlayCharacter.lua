local ServerStorage = game:GetService('ServerStorage')
local ServerModules = require(ServerStorage:WaitForChild("Modules"))
local DataStoreModule = ServerModules.Services.DataStore

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))
local Red = ReplicatedModules.Services.Red

local Net = Red.Server("RemoteSpace")

local Players = game:GetService("Players")


local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module:PlaySelectedCharacter(localPlayer, playSlot)
	if not localPlayer or not playSlot then return end
	if not localPlayer:IsA("Player") then return end
	
	playSlot = tonumber(playSlot)
	
	if not playSlot then return end
	if playSlot > 4 or playSlot < 1 then return end
	if playSlot % 1 ~= 0 then return end
	
	
	playSlot = tostring(playSlot)
	
	local profileName = "Profile_" .. playSlot
	local dataStore = DataStoreModule.find("Player", localPlayer.UserId, profileName)

	if dataStore == nil then
		return
	end

	if dataStore.Value.HasPlayed == false then return end
	if dataStore.State ~= true then
		return 
	end
	
	dataStore.Value.CurrentlyPlaying = true
	
	local GlobalPlayerDataStore = DataStoreModule.find("Player", localPlayer.UserId, "GlobalData")
	GlobalPlayerDataStore.Value.CurrentlyPlayingProfile = tonumber(playSlot)
	
	
	if dataStore:Save() == "Saved" and GlobalPlayerDataStore:Save() == "Saved" then
		print("Teleporting player to Starfall Bastion")
	else
		return
	end
end

function Module:Start()
	Net:On("PlaySelectedCharacter", function(localPlayer, playSlot)
		Module:PlaySelectedCharacter(localPlayer, playSlot)
	end)
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
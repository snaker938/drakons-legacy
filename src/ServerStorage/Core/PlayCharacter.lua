local ServerStorage = game:GetService('ServerStorage')
local ServerModules = require(ServerStorage:WaitForChild("Modules"))
local DataStoreModule = ServerModules.Services.DataStore

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)
local playCharacter = BridgeNet2.ServerBridge("playCharacter")


local Players = game:GetService("Players")


local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module:PlaySelectedCharacter(localPlayer : Player, playSlot)
	if not playSlot then return end
	
	playSlot = tonumber(playSlot)
	
	if not playSlot then localPlayer:Kick("A Critical Error Occured") end
	if playSlot > 4 or playSlot < 1 then localPlayer:Kick("A Critical Error Occured") end
	if playSlot % 1 ~= 0 then localPlayer:Kick("A Critical Error Occured") end
	
	local GlobalData = SystemsContainer.DataHandling.ProfileHandling:GetCurrentUserData(localPlayer, "global")

	if playSlot > GlobalData.Value.NumSlotsUsed then localPlayer:Kick("Critical Error Occured") end
	
	GlobalData.Value.CurrentlyPlayingProfile = playSlot
	
	if GlobalData:Save() == "Saved" then
		print("User is now playing profile " .. playSlot)
	else
		local errorCount = 0
		repeat
			errorCount = errorCount + 1
			GlobalData:Save()
			task.wait(0.25)

			if errorCount == 12 then
				print("Error saving data!")
				localPlayer:Kick("Critical Error Creating Character")
				return
			end
		until GlobalData:Save() == "Saved"

		print("Teleporting player to Starfall Bastion (but errored)")
	end
end

function Module:Start()
	playCharacter:Connect(function(player, playSlot)
		Module:PlaySelectedCharacter(player, playSlot)
	end)
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
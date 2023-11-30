local ServerStorage = game:GetService('ServerStorage')
local ServerModules = require(ServerStorage:WaitForChild("Modules"))
local DataStoreModule = ServerModules.Services.DataStore
local VerifyText = ServerModules.Utility.VerifyText

local Packages = game:GetService("ReplicatedStorage").Packages

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)
local createCharacter = BridgeNet2.ServerBridge("createCharacter")

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module:FindProfileToCreate(localPlayer : Player)
	local GlobalPlayerData = SystemsContainer.DataHandling.ProfileHandling:GetCurrentUserData(localPlayer, "global")


	if GlobalPlayerData.Value.NumSlotsUsed == 4 then
		print("Critical Error Creating Character")
		localPlayer:Kick("Critical Error Creating Character")
	end

	return GlobalPlayerData.Value.NumSlotsUsed + 1
end

function Module:CheckIfAllProfilesAreUsed(localPlayer : Player)
	if SystemsContainer.DataHandling.ProfileHandling:GetCurrentUserData(localPlayer, "global").Value.NumSlotsUsed == 4 then
		return true
	else
		return false
	end
end


function Module:CreateCharacter(localPlayer, characterName : string, characterType : string)
	-- if not localPlayer or not characterName or not characterType then return false end
	if not localPlayer then return {false, "Critical Error Occured"} end
	if not characterType then localPlayer:Kick("Critical Error Creating Character") end
	if not characterName then return {false, "Invalid Character Name"} end

	if characterName == "" then return {false, "Invalid Character Name"} end
	
	if typeof(characterType) ~= "string" then localPlayer:Kick("Critical Error Occured") end
	
	if typeof(characterName) ~= "string" then localPlayer:Kick("Critical Error Occured") end
	
	if characterType ~= "Battlelord" and characterType ~= "Spellweaver" and characterType ~= "Ranger" and characterType ~= "Tinkerer" then
		-- displayErrorMessageEvent:FireClient(player, "Something went wrong... Try again later! random")
		print("Character type not allowed!")
		localPlayer:Kick("Critical Error Creating Character")
	end
	
	
	if Module:CheckIfAllProfilesAreUsed(localPlayer) then
		-- displayErrorMessageEvent:FireClient(player, "All profile slots used!")
		print("All profile slots used!")
		return {false, "All profile slots used!"}
	end

	
	-- local isUsernameAlright = verifyUsernameInputEvent:Invoke(player, characterName)
	local isUsernameAlright = VerifyText:VerifyText(localPlayer, characterName, "username")
	
	if isUsernameAlright then
		local GlobalData = SystemsContainer.DataHandling.ProfileHandling:GetCurrentUserData(localPlayer, "global")

		local PlayerData = SystemsContainer.DataHandling.ProfileHandling:GetSpecificProfileData(localPlayer, Module:FindProfileToCreate(localPlayer) + 1)

		PlayerData.Value.CharacterName = characterName
		PlayerData.Value.ClassType = characterType

		local CurrentlyPlayingProfile = Module:FindProfileToCreate(localPlayer)
		
		GlobalData.Value.CurrentlyPlayingProfile = CurrentlyPlayingProfile
		GlobalData.Value.NumSlotsUsed = CurrentlyPlayingProfile
		
		if PlayerData:Save() == "Saved" and GlobalData:Save() == "Saved" then
			print("Character created!")
			return {true, ""}
			-- local TARGET_PLACE_ID = 14169281935 -- Starfall Bastion

			-- local success, result = SafeTeleport(TARGET_PLACE_ID, {player})
			-- if success then
			-- 	game.ReplicatedStorage.TeleportEvent:FireClient(player)
			-- end
		else
			local errorCount = 0
			repeat
				errorCount = errorCount + 1
				PlayerData:Save()
				GlobalData:Save()
				task.wait(0.25)

				if errorCount == 12 then
					print("Error saving data!")
					localPlayer:Kick("Critical Error Creating Character")
					return
				end
			until PlayerData:Save() == "Saved" and GlobalData:Save() == "Saved"

			print("Character created! (but errored before)")
			return {true, ""}
		end
	else
		-- displayErrorMessageEvent:FireClient(player, "Username not allowed!")
		return {false, "Username not allowed!"}
	end
end


function Module:Start()
	createCharacter.OnServerInvoke = function(player : Player, characterInfo : table)
		-- characterInfo = {characterName, characterType}
		return Module:CreateCharacter(player, characterInfo[1], characterInfo[2])
	end
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
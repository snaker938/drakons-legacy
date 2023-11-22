local ServerStorage = game:GetService('ServerStorage')
local ServerModules = require(ServerStorage:WaitForChild("Modules"))
local DataStoreModule = ServerModules.Services.DataStore
local VerifyText = ServerModules.Utility.VerifyText

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))
local Red = ReplicatedModules.Services.Red

local Net = Red.Server("RemoteSpace")

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module:findProfileToCreate(localPlayer)
	for i = 1, 4 do
		local profileData = DataStoreModule.find("Player", localPlayer.UserId, "Profile_" .. i)
		if profileData == nil then return false end
		if profileData.State ~= true then return false end
		
		if not profileData.Value.HasPlayed then 
			return i
		end
	end
	return false
end

-- Check if the local player has used all their character slots
function Module:checkIfAllProfilesUsed(localPlayer)
	for i = 1, 4 do
		local profileData = DataStoreModule.find("Player", localPlayer.UserId, "Profile_" .. i)
		if profileData == nil then return true end
		if profileData.State ~= true then return true end

		if not profileData.Value.HasPlayed then 
			return false
		end
	end
	return true
end

function Module:createCharacter(localPlayer, characterName : string, characterType : string)
	if not player or not characterName or not characterType then return end
	
	if typeof(characterType) ~= "string" then return end
	
	if typeof(characterName) ~= "string" then return end
	
	if characterType ~= "Battlelord" and characterType ~= "Spellweaver" and characterType ~= "Ranger" and characterType ~= "Tinkerer" then
		-- displayErrorMessageEvent:FireClient(player, "Something went wrong... Try again later! random")
		print("Something went wrong... Try again later!)")
		return
	end
	
	
	if Module:checkIfAllProfilesUsed(player) then
		-- displayErrorMessageEvent:FireClient(player, "All profile slots used!")
		print("All profile slots used!")
		return
	end
	
	-- local isUsernameAlright = verifyUsernameInputEvent:Invoke(player, characterName)
	local isUsernameAlright = VerifyText:verifyText(localPlayer, characterName, "username")
	
	if isUsernameAlright then
		if not Module:findProfileToCreate(player) then
			-- displayErrorMessageEvent:FireClient(player, "Something went wrong... Try again later! 1")
			print("Something went wrong... Try again later!")
			return
		else
			local profileName = "Profile_" .. Module:findProfileToCreate(player)

			local dataStore = DataStoreModule.find("Player", player.UserId, profileName)
			if dataStore == nil or dataStore.State ~= true then
				-- displayErrorMessageEvent:FireClient(player, "Something went wrong... Try again later!")
				print("Something went wrong... Try again later!")
				return
			end
			
			local GlobalPlayerDataStore = DataStoreModule.find("Player", player.UserId, "GlobalData")
			if GlobalPlayerDataStore == nil or GlobalPlayerDataStore ~= true then
				-- displayErrorMessageEvent:FireClient(player, "Something went wrong... Try again later!")
				print("Something went wrong... Try again later!")
				return
			end

			dataStore.Value.HasPlayed = true
			dataStore.Value.CharacterName = characterName
			dataStore.Value.ClassType = characterType
			dataStore.Value.CurrentlyPlaying = true

			GlobalPlayerDataStore.Value.CurrentlyPlayingProfile = Module:findProfileToCreate(player) - 1
			

			if dataStore:Save() == "Saved" and GlobalPlayerDataStore:Save() == "Saved" then
				print("Character created!")
				-- local TARGET_PLACE_ID = 14169281935 -- Starfall Bastion

				-- local success, result = SafeTeleport(TARGET_PLACE_ID, {player})
				-- if success then
				-- 	game.ReplicatedStorage.TeleportEvent:FireClient(player)
				-- end
			else
				return
			end
		end
	else
		-- displayErrorMessageEvent:FireClient(player, "Username not allowed!")
		print("Username not allowed!")
		return
	end
end

function Module:Start()
	Net:On("CreateCharacter", function(localPlayer, characterName, characterType)
		Module:createCharacter(localPlayer, characterName, characterType)
	end)
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
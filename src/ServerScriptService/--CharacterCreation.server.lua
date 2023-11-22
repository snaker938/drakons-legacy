-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local createCharacterEvent = ReplicatedStorage:WaitForChild("createCharacter")
-- local DataStoreModule = require(game.ServerStorage.DataStore)
-- local verifyUsernameInputEvent = game:GetService("ServerScriptService"):WaitForChild("verifyUsernameInputEvent")
-- local displayErrorMessageEvent = ReplicatedStorage:WaitForChild("displayErrorMessage")

-- local ServerScriptService = game:GetService("ServerScriptService")
-- local SafeTeleport = require(ServerScriptService.SafeTeleport)

-- local function findProfileToCreate(player)
-- 	for i = 1, 4 do
-- 		local profileData = DataStoreModule.find("Player", player.UserId, "Profile_" .. i)
-- 		if profileData == nil then return false end
-- 		if profileData.State ~= true then return false end
		
-- 		if not profileData.Value.HasPlayed then 
-- 			return i
-- 		end
		
-- 	end
	
-- 	return false
-- end


-- local function allProfilesUsed(player)
-- 	for i = 1, 4 do
-- 		local profileData = DataStoreModule.find("Player", player.UserId, "Profile_" .. i)
-- 		if profileData == nil then return true end
-- 		if profileData.State ~= true then return true end

-- 		if not profileData.Value.HasPlayed then 
-- 			return false
-- 		end
-- 	end
-- 	return true
-- end

-- createCharacterEvent.OnServerEvent:Connect(function(player, characterName, characterType)
	
-- 	if not player or not characterName or not characterType then return end
	
-- 	if typeof(characterType) ~= "string" then return end
	
-- 	if typeof(characterName) ~= "string" then return end
	
-- 	if characterType ~= "Battlelord" and characterType ~= "Spellweaver" and characterType ~= "Ranger" and characterType ~= "Tinkerer" then
-- 		displayErrorMessageEvent:FireClient(player, "Something went wrong... Try again later! random")
-- 		return
-- 	end
	
	
-- 	if allProfilesUsed(player) then
-- 		displayErrorMessageEvent:FireClient(player, "All profile slots used!")
-- 		return
-- 	end
	
-- 	local isUsernameAlright = verifyUsernameInputEvent:Invoke(player, characterName)
	
-- 	if isUsernameAlright then
		
-- 		if not findProfileToCreate(player) then
-- 			displayErrorMessageEvent:FireClient(player, "Something went wrong... Try again later! 1")
-- 			return
-- 		else
-- 			local profileName = "Profile_" .. findProfileToCreate(player)

-- 			local dataStore = DataStoreModule.find("Player", player.UserId, profileName)
-- 			if dataStore == nil then
-- 				displayErrorMessageEvent:FireClient(player, "Something went wrong... Try again later! 2")
-- 				return
-- 			end
-- 			if dataStore.State ~= true then
-- 				displayErrorMessageEvent:FireClient(player, "Something went wrong... Try again later! 3")
-- 				return 
-- 			end -- make sure the session is open or the value will never get saved
			
			
-- 			dataStore.Value.HasPlayed = true
-- 			dataStore.Value.CharacterName = characterName
-- 			dataStore.Value.ClassType = characterType
-- 			dataStore.Value.CurrentlyPlaying = true
			
-- 			local GlobalPlayerDataStore = DataStoreModule.find("Player", player.UserId, "GlobalData")
-- 			GlobalPlayerDataStore.Value.CurrentlyPlayingProfile = findProfileToCreate(player) - 1
			

-- 			if dataStore:Save() == "Saved" and GlobalPlayerDataStore:Save() == "Saved" then
-- 				local TARGET_PLACE_ID = 14169281935 -- Starfall Bastion

-- 				local success, result = SafeTeleport(TARGET_PLACE_ID, {player})
-- 				if success then
-- 					game.ReplicatedStorage.TeleportEvent:FireClient(player)
-- 				end
-- 			else
-- 				return
-- 			end
-- 		end
-- 	else
-- 		displayErrorMessageEvent:FireClient(player, "Username not allowed!")
-- 		return
-- 	end
-- end)

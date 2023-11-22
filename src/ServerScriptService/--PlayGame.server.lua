-- local PlayGameEvent = game:GetService("ReplicatedStorage"):WaitForChild("PlayGameEvent")
-- local DataStoreModule = require(game.ServerStorage.DataStore)
-- local ServerScriptService = game:GetService("ServerScriptService")
-- local SafeTeleport = require(ServerScriptService.SafeTeleport)

-- PlayGameEvent.OnServerEvent:Connect(function(player, PlaySlot)
	
-- 	if not player or not PlaySlot then return end
	
	
-- 	PlaySlot = tonumber(PlaySlot)
	
-- 	if not PlaySlot then return end
-- 	if PlaySlot > 4 or PlaySlot < 1 then return end
-- 	if PlaySlot % 1 ~= 0 then return end
	
	
-- 	PlaySlot = tostring(PlaySlot)
	
-- 	local profileName = "Profile_" .. PlaySlot
-- 	local dataStore = DataStoreModule.find("Player", player.UserId, profileName)
-- 	if dataStore.Value.HasPlayed == false then return end
-- 	if dataStore == nil then
-- 		return
-- 	end
-- 	if dataStore.State ~= true then
-- 		return 
-- 	end -- make sure the session is open or the value will never get saved
	
-- 	dataStore.Value.CurrentlyPlaying = true
	
-- 	local GlobalPlayerDataStore = DataStoreModule.find("Player", player.UserId, "GlobalData")
-- 	GlobalPlayerDataStore.Value.CurrentlyPlayingProfile = tonumber(PlaySlot)
	
	
-- 	if dataStore:Save() == "Saved" and GlobalPlayerDataStore:Save() == "Saved" then
-- 		local TARGET_PLACE_ID = 14169281935 -- Starfall Bastion
-- 		local success, result = SafeTeleport(TARGET_PLACE_ID, {player})
-- 		if success then
-- 			game.ReplicatedStorage.TeleportEvent:FireClient(player)
-- 		end
-- 	else
-- 		return
-- 	end
-- end)
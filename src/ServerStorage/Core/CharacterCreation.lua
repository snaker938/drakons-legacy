local ServerStorage = game:GetService('ServerStorage')
local ServerModules = require(ServerStorage:WaitForChild("Modules"))
local DataStoreModule = ServerModules.Services.DataStore
local VerifyText = ServerModules.Utility.VerifyText

local Packages = game:GetService("ReplicatedStorage").Packages
local Red = require(Packages.Red)

-- local Net = Red.Server("RemoteSpace")

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module:FindProfileToCreate(localPlayer : Player)
	local GlobalPlayerData = SystemsContainer.ProfileHandling:GetCurrentUserData(localPlayer, "global")

	if GlobalPlayerData.Value.NumSlotsUsed == 4 then
		error("Critical Error Creating Character")
		localPlayer:Kick("Critical Error Creating Character")
	end

	return GlobalPlayerData.Value.NumSlotsUsed + 1
end

function Module:CheckIfAllProfilesAreUsed(localPlayer : Player)
	if SystemsContainer.ProfileHandling:GetCurrentUserData(localPlayer, "global").Value.NumSlotsUsed == 4 then
		return true
	else
		return false
	end
end


function Module:CreateCharacter(localPlayer, characterName : string, characterType : string)
	if not localPlayer or not characterName or not characterType then return end
	
	if typeof(characterType) ~= "string" then return end
	
	if typeof(characterName) ~= "string" then return end
	
	if characterType ~= "Battlelord" and characterType ~= "Spellweaver" and characterType ~= "Ranger" and characterType ~= "Tinkerer" then
		-- displayErrorMessageEvent:FireClient(player, "Something went wrong... Try again later! random")
		error("Character type not allowed!")
		localPlayer:Kick("Critical Error Creating Character")
		return
	end
	
	
	if Module:CheckIfAllProfilesAreUsed(localPlayer) then
		-- displayErrorMessageEvent:FireClient(player, "All profile slots used!")
		warn("All profile slots used!")
		return
	end
	
	-- local isUsernameAlright = verifyUsernameInputEvent:Invoke(player, characterName)
	local isUsernameAlright = VerifyText:VerifyText(localPlayer, characterName, "username")
	
	if isUsernameAlright then
		local PlayerData, GlobalData = SystemsContainer.ProfileHandling:GetCurrentUserData(localPlayer)

		PlayerData.Value.CharacterName = characterName
		PlayerData.Value.ClassType = characterType

		local CurrentlyPlayingProfile = Module:FindProfileToCreate(localPlayer) - 1
		
		GlobalData.Value.CurrentlyPlayingProfile = CurrentlyPlayingProfile
		GlobalData.Value.NumSlotsUsed = CurrentlyPlayingProfile
		
		if PlayerData:Save() == "Saved" and GlobalData:Save() == "Saved" then
			print("Character created!")
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
					error("Error saving data!")
					localPlayer:Kick("Critical Error Creating Character")
					return
				end
			until PlayerData:Save() == "Saved" and GlobalData:Save() == "Saved"

			print("Character created! (but errored before)")
		end
	else
		-- displayErrorMessageEvent:FireClient(player, "Username not allowed!")
		warn("Username not allowed!")
		return
	end
end

function Module:Start()
	-- Net:On("CreateCharacter", function(localPlayer, characterName, characterType)
	-- 	Module:createCharacter(localPlayer, characterName, characterType)
	-- end)
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
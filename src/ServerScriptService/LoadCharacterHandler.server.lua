-- DataStore Module --

local DataStoreModule = require(game.ServerStorage.DataStore)

-- Events --
local RS = game:GetService("ReplicatedStorage")
local LoadCharacterEvent = RS:WaitForChild("LoadCharacters")

-- Display Appropiate Character Slots


local function allProfilesUsed(player)
	for i = 1, 4 do
		local profileData = DataStoreModule.find("Player", player.UserId, "Profile_" .. i)
		if profileData == nil then return true end
		if profileData.State ~= true then return true end

		if not profileData.Value.HasPlayed then 
			return false
		end
	end
	return true
end



local function displayCharSlot(charData, charSlot)
	local charName = charData.Value.CharacterName
	local classType = charData.Value.ClassType
	local charLevel = charData.Value.CharacterLevel
	local lastUrban = charData.Value.LastUrbanArea
	local hasPlayed = charData.Value.HasPlayed
	
	if not hasPlayed then
		return false 
	end
	
	if lastUrban == "" then lastUrban = "Starfall Bastion" end
	
	charSlot.Visible = true
	charSlot.CharacterInfo.charSlotName.Text  = charName
	charSlot.CharacterInfo.LastUrbanArea.Text = lastUrban
	charSlot.CharacterInfo.Level.Text = "Level ".. charLevel
	charSlot.CharacterInfo.ClassType.Text = classType
	
	return true
end



local function loadCharacterSlots(player)
	local currentChars = player.PlayerGui:WaitForChild("LoadCharacter"):WaitForChild("CurrentCharacters")
	local LoadCharacter = player.PlayerGui:WaitForChild("LoadCharacter")
	LoadCharacter.Enabled = false

	local lastProfile = nil
	for i = 1, 4 do
		local profileData = DataStoreModule.find("Player", player.UserId, "Profile_" .. i)
		local charSlot = currentChars:WaitForChild("charSlot" .. i)

		if not displayCharSlot(profileData, charSlot) then
			break
		end
		lastProfile = i
	end

	if lastProfile == nil then
		local CharacterCreationScreen = player.PlayerGui:WaitForChild("CharacterCreation")
		local backButton = CharacterCreationScreen:WaitForChild("BackButton")
		backButton.Visible = false
		CharacterCreationScreen.Enabled = true
		LoadCharacter.Enabled = false
		print("No Char Slots")
		return
	else
		LoadCharacter.Enabled = true
	end
end


-- Connecting Functions --

game.Players.PlayerAdded:Connect(function(player)
	task.wait(4)
	loadCharacterSlots(player)
	
	if allProfilesUsed(player) then
		player.PlayerGui.LoadCharacter.CreateCharButton.Visible = false
	end
end)

LoadCharacterEvent.OnServerEvent:Connect(function(player)
	loadCharacterSlots(player)
end)
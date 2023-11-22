local textLabel = script.Parent

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local characterClickedEvent = ReplicatedStorage.characterSlotClicked

local characterName = nil

local function getClickedCharName() 
	for _,element in ipairs(player.PlayerGui.LoadCharacter.CurrentCharacters:GetDescendants()) do
		if element:IsA("LocalScript") then continue end
		if element:GetAttribute("isClicked") == true then
			characterName = element:WaitForChild("CharacterInfo"):WaitForChild("charSlotName").Text
		end
	end
	if characterName and characterName ~= "" then
		return characterName
	end
	return false
end

local function setTextToDisplay(clickedCharName)
	if not clickedCharName then
		player.PlayerGui.LoadCharacter.CharacterNameHolder.Visible = false
		return
	end
	player.PlayerGui.LoadCharacter.CharacterNameHolder.Visible = true
	player.PlayerGui.LoadCharacter.CharacterNameHolder.CharacterName.Text = clickedCharName
end


characterClickedEvent.Event:Connect(function ()
	setTextToDisplay(getClickedCharName())
end)
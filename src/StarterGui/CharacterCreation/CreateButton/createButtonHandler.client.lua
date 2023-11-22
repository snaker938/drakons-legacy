local Players = game:GetService("Players")
local player = Players.LocalPlayer
local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CreateButton = script.Parent


local createCharacterEvent = ReplicatedStorage:WaitForChild("createCharacter")

local NameInputBox = Players.LocalPlayer.PlayerGui:WaitForChild("CharacterCreation"):WaitForChild("EnterNameInputBox")



local function hasSpecialCharacters(username)
	-- Define the pattern to match allowed characters (letters, numbers, and underscores)
	local allowedPattern = "[A-Za-z0-9_]+"

	-- Use string.match to check if the username matches the allowed pattern
	-- If it doesn't match, it means it contains special characters
	return not string.match(username, "^" .. allowedPattern .. "$")
end

local function isValidLength(username)
	return string.len(username) >= 3 and string.len(username) <= 20
end

local function isValidUnderscorePlacement(username)
	return string.sub(username, 1, 1) ~= "_" and string.sub(username, -1) ~= "_"
end

local function isValidUnderscoreCount(username)
	local underscoreCount = select(2, string.gsub(username, "_", "_"))
	return underscoreCount <= 1
end

local function whichClassClicked()
	local otherClasses = player.PlayerGui.CharacterCreation.ClassTypes:GetDescendants()
	for _,element in ipairs(otherClasses) do
		if element:isA("LocalScript") then continue end
		if element:GetAttribute("isClicked") then return element.Name end
	end
end


local function createCharacter()
	local username = NameInputBox.Text
	local errorText = NameInputBox:WaitForChild("ErrorMessage")
	
	
	if username == "" then
		errorText.Text = "Username cannot be empty"
	elseif not isValidLength(username) then
		errorText.Text = "Username must be between 3 and 20 characters"
	elseif hasSpecialCharacters(username) or not isValidUnderscoreCount(username) then
		errorText.Text = "Username can only contain one underscore _ character"
	elseif string.find(username, "%s") then
		errorText.Text = "Username cannot contain spaces"
	elseif not isValidUnderscorePlacement(username) then
		errorText.Text = "Username cannot start or end with an underscore"
	else
		--print("Valid username local side!")
		createCharacterEvent:FireServer(username, whichClassClicked())
	end

end



CreateButton.MouseButton1Click:Connect(createCharacter)
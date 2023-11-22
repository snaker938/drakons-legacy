local Module = {}

local TextService = game:GetService("TextService")
--local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local displayErrorMessageEvent = ReplicatedStorage:WaitForChild("displayErrorMessage")


function Module:getTextObject(message, fromPlayerId)
	local textObject
	local success, errorMessage = pcall(function()
		textObject = TextService:FilterStringAsync(message, fromPlayerId)
	end)
	if success then
		return textObject
	elseif errorMessage then
		print("Error generating TextFilterResult:", errorMessage)
	end
	return false
end


function Module:getFilteredMessage(textObject)
	local filteredMessage
	local success, errorMessage = pcall(function()
		filteredMessage = textObject:GetNonChatStringForBroadcastAsync()
	end)
	if success then
		return filteredMessage
	elseif errorMessage then
		print("Error filtering message:", errorMessage)
	end
	return false
end


function Module:hasSpecialCharacters(username)
	-- Define the pattern to match allowed characters (letters, numbers, and underscores)
	local allowedPattern = "[A-Za-z0-9_]+"

	-- Use string.match to check if the username matches the allowed pattern
	-- If it doesn't match, it means it contains special characters
	return not string.match(username, "^" .. allowedPattern .. "$")
end

function Module:isValidLength(username)
	return string.len(username) >= 3 and string.len(username) <= 20
end

function Module:isValidUnderscorePlacement(username)
	return string.sub(username, 1, 1) ~= "_" and string.sub(username, -1) ~= "_"
end

function Module:isValidUnderscoreCount(username)
	local underscoreCount = select(2, string.gsub(username, "_", "_"))
	return underscoreCount <= 1
end

function Module:verifyText(player : Player, text : string, usage : string)
	if usage == "username" then
		local username = text
		if username == "" then
			--displayErrorMessageEvent:FireClient("Username cannot be empty")
			return false
		elseif not Module:isValidLength(username) then
			--displayErrorMessageEvent:FireClient("Username must be between 3 and 20 characters")
			return false
		elseif Module:hasSpecialCharacters(username) or not Module:isValidUnderscoreCount(username) then
			--displayErrorMessageEvent:FireClient("Username can only contain one underscore _ character")
			return false
		elseif string.find(username, "%s") then
			--displayErrorMessageEvent:FireClient("Username cannot contain spaces")
			return false
		elseif not Module:isValidUnderscorePlacement(username) then
			--displayErrorMessageEvent:FireClient("Username cannot start or end with an underscore")
			return false
		else
			--Filter the incoming message and check it against the original to make sure they match
			local filteredText = Module:getFilteredMessage(Module:getTextObject(username, player.UserId)) 

			if not filteredText then
				return false
			end

			if type(filteredText) ~= "string" then
				return false
			end

			if filteredText ~= username then
				return false
			end

			if filteredText == "" then
				return false
			end


			return true
		end
	end
end

return Module

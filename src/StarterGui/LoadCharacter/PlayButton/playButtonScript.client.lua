-- local PlayGameEvent = game:GetService("ReplicatedStorage"):WaitForChild("PlayGameEvent")
-- local Players = game:GetService("Players")
-- local PlayButton = script.Parent

-- local function getClickedSlot()
-- 	local player = Players.LocalPlayer
-- 	local otherSlots = player.PlayerGui.LoadCharacter.CurrentCharacters:GetDescendants()
-- 	for _,element in ipairs(otherSlots) do
-- 		if element:isA("LocalScript") then continue end
-- 		if element:GetAttribute("isClicked") == true then
-- 			local fullName = element.Name
-- 			return string.sub(fullName, -1)
-- 		end
-- 	end
-- end


-- PlayButton.MouseButton1Click:Connect(function(player)
-- 	local id = getClickedSlot()
-- 	PlayGameEvent:FireServer(id)
-- end)
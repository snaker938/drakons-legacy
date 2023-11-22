local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local characterClickedEvent = ReplicatedStorage.characterSlotClicked

local charButton = script.Parent



local function mouseHoverStart()
	if not charButton:GetAttribute("isClicked") then
		charButton.BackgroundTransparency = 0.6
	end
end

local function mouseHoverEnd()
	charButton.BackgroundTransparency = 0
end

local function unClickOtherSlots()
	local otherSlots = player.PlayerGui.LoadCharacter.CurrentCharacters:GetDescendants()
	for _,element in ipairs(otherSlots) do
		if element:isA("LocalScript") then continue end
		element.BorderColor3 = Color3.fromRGB(255, 0, 4)
		element:SetAttribute("isClicked", false)
		--element.BackgroundColor3 = Color3.fromRGB(37, 190, 255)
	end
end

local function charSlotClicked()
	if charButton:GetAttribute("isClicked") then return end
	unClickOtherSlots()
	--charButton.BackgroundColor3 = Color3.fromRGB(255, 0, 4)
	charButton.BackgroundTransparency = 0
	charButton:SetAttribute("isClicked", true)
	charButton.BorderColor3 = Color3.fromRGB(12, 89, 255)
	characterClickedEvent:Fire()
end




charButton.MouseEnter:Connect(mouseHoverStart)
charButton.MouseLeave:Connect(mouseHoverEnd)

charButton.MouseButton1Click:Connect(charSlotClicked)
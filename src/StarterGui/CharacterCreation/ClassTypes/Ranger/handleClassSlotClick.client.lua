local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local classClickedEvent = ReplicatedStorage.classTypeClicked

local classButton = script.Parent


local function mouseHoverStart()
	if not classButton:GetAttribute("isClicked") then
		classButton.BackgroundTransparency = 0.6
	end
end

local function mouseHoverEnd()
	classButton.BackgroundTransparency = 0
end

local function unClickOtherClasses()
	local otherClasses = player.PlayerGui.CharacterCreation.ClassTypes:GetDescendants()
	for _,element in ipairs(otherClasses) do
		if element:isA("LocalScript") then continue end
		element:SetAttribute("isClicked", false)
		element.BackgroundColor3 = Color3.fromRGB(35, 226, 255)
	end
end

local function charSlotClicked()
	unClickOtherClasses()
	classButton.BackgroundColor3 = Color3.fromRGB(20, 132, 144)
	classButton.BackgroundTransparency = 0
	classButton:SetAttribute("isClicked", true)
	classClickedEvent:Fire() -- used to communicate with other Frames to contain class info, stats etc.
end




classButton.MouseEnter:Connect(mouseHoverStart)
classButton.MouseLeave:Connect(mouseHoverEnd)


if script.Parent.Name == "Battlelord" then charSlotClicked() end

classButton.MouseButton1Click:Connect(charSlotClicked)
-- local BackButton = script.Parent
-- local LoadCharacterGUI = BackButton.Parent.Parent:WaitForChild("LoadCharacter")
-- local BlackScreenHolder = BackButton.Parent.Parent:WaitForChild("BlackScreenHolder")
-- local FadeService = require(game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("FadeService"))
-- local currentGUI = script.Parent.Parent
-- local RS = game:GetService("ReplicatedStorage")
-- local LoadCharacterEvent = RS:WaitForChild("LoadCharacters")



-- BackButton.MouseButton1Click:Connect(function()
-- 	FadeService.Fade(BlackScreenHolder, currentGUI, LoadCharacterGUI, 1.5)
-- 	LoadCharacterEvent:FireServer()
-- end)
local WipeDataButton = script.Parent

local WipeDataEvent = game:GetService("ReplicatedStorage"):WaitForChild("WipeDataEvent")

WipeDataButton.MouseButton1Click:Connect(function()
	WipeDataEvent:FireServer()
end)
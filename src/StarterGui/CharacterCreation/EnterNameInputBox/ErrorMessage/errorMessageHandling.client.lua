local ErrorMessage = script.Parent
local InputBox = script.Parent.Parent
local displayErrorMessageEvent = game:GetService("ReplicatedStorage"):WaitForChild("displayErrorMessage")


InputBox.Focused:Connect(function()
	ErrorMessage.Text = ""
end)

displayErrorMessageEvent.OnClientEvent:Connect(function(errorMessage)
	ErrorMessage.Text = errorMessage
end)


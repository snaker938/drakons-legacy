local Players = game:GetService("Players")


Players.PlayerAdded:Connect(function(player)	
	local character = player.Character
	if character then
		local forceField = Instance.new("ForceField")
		forceField.Visible = true
		forceField.Parent = character
	end
end)
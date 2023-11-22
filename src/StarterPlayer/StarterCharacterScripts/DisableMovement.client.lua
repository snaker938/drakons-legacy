local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerScripts = player:WaitForChild("PlayerScripts")

local PlayerModule = require(playerScripts:WaitForChild("PlayerModule"))
local controls = PlayerModule:GetControls()

controls:Disable()
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local Trove = ReplicatedModules.Classes.Trove

local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)
local addDraken = BridgeNet2.ClientBridge("addDraken")

local SystemsContainer = {}
local WidgetControllerModule = {}

-- // Module // --
local Module = {}

Module.WidgetTrove = Trove.new()
Module.Open = false

function Module.UpdateWidget()

end

function Module.OpenWidget()
	if Module.Open then
		return
	end
	
	Module.Open = true
end

function Module.CloseWidget()
	if not Module.Open then
		return
	end

	Module.Open = false
	Module.WidgetTrove:Destroy()
end

function Module.Start()
	local AlwaysActiveBtn = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("AlwaysActive").TestBtn
	AlwaysActiveBtn.Activated:Connect(function()
		addDraken:InvokeServerAsync(10000)
	end)
end

function Module.Init(ParentController, otherSystems)
	WidgetControllerModule = ParentController
	SystemsContainer = otherSystems
end

return Module

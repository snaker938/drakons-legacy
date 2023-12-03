local ServerStorage = game:GetService('ServerStorage')
local ServerModules = require(ServerStorage:WaitForChild("Modules"))

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)
local wipeAllData = BridgeNet2.ServerBridge("wipeAllData")

local Packages = game:GetService("ReplicatedStorage").Packages

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.WipePlayerData(localPlayer : Player, profileToWipe : number, globalWipe : boolean)
	if profileToWipe then
		local PlayerData = SystemsContainer.ProfileHandling.GetSpecificProfileData(localPlayer, profileToWipe)
		PlayerData.Value = SystemsContainer.DataServer.GetDataTemplate("player")
	else
		for i = 1, 4 do
			local PlayerData = SystemsContainer.ProfileHandling.GetSpecificProfileData(localPlayer, i)
			PlayerData.Value = SystemsContainer.DataServer.GetDataTemplate("player")
		end
	end

	if globalWipe then
		local GlobalData = SystemsContainer.ProfileHandling.GetCurrentUserData(localPlayer, "global")
		GlobalData.Value = SystemsContainer.DataServer.GetDataTemplate("global")
	end
end


function Module.Start()
	wipeAllData:Connect(function(player)
		Module.WipePlayerData(player, nil, true)
	end)
end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
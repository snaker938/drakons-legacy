local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)

local addDraken = BridgeNet2.ServerBridge("addDraken")
local getDrakenAmount = BridgeNet2.ServerBridge("getDrakenAmount")
local DrakenAmountChanged = BridgeNet2.ServerBridge("DrakenAmountChanged")

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.DrakenAmountChanged(localPlayer : Player)
	DrakenAmountChanged:Fire(localPlayer)
end

function Module.AddDraken(localPlayer : Player, amountToAdd : number)
	local GlobalData = SystemsContainer.ParentSystems.DataHandling.ProfileHandling.GetCurrentUserData(localPlayer, "global")
	GlobalData.Value.Draken += amountToAdd
	GlobalData:Save()

	Module.DrakenAmountChanged(localPlayer)
end

function Module.DeductDraken(localPlayer : Player, amountToRemove : number)
	local GlobalData = SystemsContainer.ParentSystems.DataHandling.ProfileHandling.GetCurrentUserData(localPlayer, "global")
	
	if GlobalData.Value.Draken < amountToRemove then
		-- Open Shop To Draken Page
		print("Opening shop!")
		return false
	else
		GlobalData.Value.Draken -= amountToRemove
		GlobalData:Save()

		Module.DrakenAmountChanged(localPlayer)
		return true
	end
end

function Module.Start()
	addDraken.OnServerInvoke = function(localPlayer : Player, amountToAdd : number)
		Module.AddDraken(localPlayer, amountToAdd)
	end

	getDrakenAmount.OnServerInvoke = function(localPlayer : Player)
		local GlobalData = SystemsContainer.ParentSystems.DataHandling.ProfileHandling.GetCurrentUserData(localPlayer, "global")
		return GlobalData.Value.Draken
	end
end

function Module.Init(otherSystems)
    SystemsContainer = otherSystems
end

return Module
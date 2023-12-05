local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)

local addDraken = BridgeNet2.ServerBridge("addDraken")

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.AddDraken(localPlayer : Player, amountToAdd : number)
	print("Adding Draken!")
	local GlobalData = SystemsContainer.ParentSystems.DataHandling.ProfileHandling.GetCurrentUserData(localPlayer, "global")
	GlobalData.Value.Draken += amountToAdd
	GlobalData:Save()
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
		return true
	end

	GlobalData:Save()
end

function Module.Start()
	addDraken:Connect(function(localPlayer : Player, amountToAdd : number)
		Module.AddDraken(localPlayer, amountToAdd)

		local playerInventory = SystemsContainer.ParentSystems.DataHandling.ProfileHandling.GetCurrentUserData(localPlayer, "player").Value.Inventory

		playerInventory[4] = {
		["ID"] =  139656808,
		}

		playerInventory[13] = {
			["ID"] =  5921693348,
		}
	end)
end

function Module.Init(otherSystems)
    SystemsContainer = otherSystems
end

return Module
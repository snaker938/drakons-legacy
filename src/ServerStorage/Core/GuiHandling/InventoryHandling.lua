local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)
local getInventoryData = BridgeNet2.ServerBridge("getInventoryData")

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.GetInventoryData(localPlayer : Player)
    local PlayerData = SystemsContainer.ParentSystems.DataHandling.ProfileHandling.GetCurrentUserData(localPlayer, "player")
    local InventoryData = PlayerData.Value.InventoryData
    return {InventoryData, PlayerData.Value.CharacterName}
end

function Module.Start()
    getInventoryData.OnServerInvoke = function(localPlayer : Player)
		return Module.GetInventoryData(localPlayer)
    end
end

function Module.Init(otherSystems)
    SystemsContainer = otherSystems
end

return Module
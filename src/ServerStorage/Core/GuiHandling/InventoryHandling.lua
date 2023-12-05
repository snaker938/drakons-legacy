local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)

local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local InventoryData = ReplicatedModules.Data.Inventory

local getInventoryData = BridgeNet2.ServerBridge("getInventoryData")
local expandInventory = BridgeNet2.ServerBridge("expandInventory")

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.GetInventoryData(localPlayer : Player)
    local PlayerData = SystemsContainer.ParentSystems.DataHandling.ProfileHandling.GetCurrentUserData(localPlayer, "player")
    return {PlayerData.Value.Inventory, PlayerData.Value.CharacterName, PlayerData.Value.InventoryTier}
end

function Module.ExpandInventory(localPlayer : Player)
    local PlayerData = SystemsContainer.ParentSystems.DataHandling.ProfileHandling.GetCurrentUserData(localPlayer, "player")

    local CurrentInventoryTier = PlayerData.Value.InventoryTier

    if CurrentInventoryTier == 16 then return false end

    local nextInventoryTier = CurrentInventoryTier + 1
    local nextInventoryTierPrice = InventoryData.GetInventoryTierPrice(nextInventoryTier)
    if not nextInventoryTierPrice then return false end

    local transactionComplete = SystemsContainer.ParentSystems.CurrencyHandling.DrakenHandling.DeductDraken(localPlayer, nextInventoryTierPrice)

    if not transactionComplete then return false end

    PlayerData.Value.InventoryTier += 1
    PlayerData:Save()
    
    return true

end

function Module.Start()
    getInventoryData.OnServerInvoke = function(localPlayer : Player)
		return Module.GetInventoryData(localPlayer)
    end

    expandInventory.OnServerInvoke = function(localPlayer : Player)
        return Module.ExpandInventory(localPlayer)
    end
end

function Module.Init(otherSystems)
    SystemsContainer = otherSystems
end

return Module
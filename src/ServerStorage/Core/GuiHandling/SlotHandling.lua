local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local InventoryData = ReplicatedModules.Data.Inventory
local LockerData = ReplicatedModules.Data.Locker

local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)

local swapItemSlotsEvent = BridgeNet2.ServerBridge("swapItemSlotsEvent")


local getInventoryData = BridgeNet2.ServerBridge("getInventoryData")
local expandInventory = BridgeNet2.ServerBridge("expandInventory")

local getLockerData = BridgeNet2.ServerBridge("getLockerData")
local expandLocker = BridgeNet2.ServerBridge("expandLocker")

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.SwapItemSlots(player : Player, startSlotType, startSlotNumber, endSlotType, endSlotNumber)
    if startSlotType == "L" then startSlotType = "locker" end
    if startSlotType == "I" then startSlotType = "inventory" end
    if endSlotType == "L" then endSlotType = "locker" end
    if endSlotType == "I" then endSlotType = "inventory" end


    startSlotNumber = tonumber(startSlotNumber)
    endSlotNumber = tonumber(endSlotNumber)

    if not startSlotType or not endSlotType then return false end
    if not typeof(startSlotType) == "string" or not typeof(endSlotType) == "string" then return false end
    if startSlotType ~= "locker" and startSlotType ~= "inventory" then return false end
    if endSlotType ~= "locker" and endSlotType ~= "inventory" then return false end

    if not endSlotNumber or not startSlotNumber then return false end
    if not typeof(endSlotNumber) == "number" or not typeof(startSlotNumber) == "number" then return false end

    if not (endSlotNumber % 1 == 0) or not (startSlotNumber % 1 == 0) then return false end
    if endSlotNumber < 1 or startSlotNumber < 1 then return false end

    if (endSlotNumber == startSlotNumber) and (endSlotType == startSlotType) then return false end

    local PlayerData = SystemsContainer.ParentSystems.DataHandling.ProfileHandling.GetCurrentUserData(player, "player")

    -- If the old slot type is a locker slot, then we need to check if the new slot number is within the locker tier's slot range. Do the same for if the old slot type is an inventory slot. Do the same for the new slot type.

    local specificData
    local slotsPerTier

    if startSlotType == "locker" then
        specificData = LockerData
        slotsPerTier = specificData.GetSlotsPerTier(PlayerData.Value.LockerTier)
        if not PlayerData.Value.Locker[tostring(startSlotNumber)] then return false end
    else
        specificData = InventoryData
        slotsPerTier = specificData.GetSlotsPerTier(PlayerData.Value.InventoryTier)
        if not PlayerData.Value.Inventory[tostring(startSlotNumber)] then return false end
    end


    if startSlotNumber > slotsPerTier then return false end

    if endSlotType == "locker" then
        specificData = LockerData
        slotsPerTier = specificData.GetSlotsPerTier(PlayerData.Value.LockerTier)
    else
        specificData = InventoryData
        slotsPerTier = specificData.GetSlotsPerTier(PlayerData.Value.InventoryTier)
    end


    if endSlotNumber > slotsPerTier then return false end


    startSlotNumber = tostring(startSlotNumber)
    endSlotNumber = tostring(endSlotNumber)


    if startSlotType == "locker" and endSlotType == "locker" then
        PlayerData.Value.Locker[startSlotNumber], PlayerData.Value.Locker[endSlotNumber] = PlayerData.Value.Locker[endSlotNumber], PlayerData.Value.Locker[startSlotNumber]
    elseif startSlotType == "locker" and endSlotType == "inventory" then
        PlayerData.Value.Locker[startSlotNumber], PlayerData.Value.Inventory[endSlotNumber] = PlayerData.Value.Inventory[endSlotNumber], PlayerData.Value.Locker[startSlotNumber]
    elseif startSlotType == "inventory" and endSlotType == "locker" then
        PlayerData.Value.Inventory[startSlotNumber], PlayerData.Value.Locker[endSlotNumber] = PlayerData.Value.Locker[endSlotNumber], PlayerData.Value.Inventory[startSlotNumber]
    elseif startSlotType == "inventory" and endSlotType == "inventory" then
        PlayerData.Value.Inventory[startSlotNumber], PlayerData.Value.Inventory[endSlotNumber] = PlayerData.Value.Inventory[endSlotNumber], PlayerData.Value.Inventory[startSlotNumber]
    end

    return true
end

function Module.GetSpecificData(localPlayer : Player, location)
    local PlayerData = SystemsContainer.ParentSystems.DataHandling.ProfileHandling.GetCurrentUserData(localPlayer, "player")
    
    if location == "inventory" then
        return {PlayerData.Value.Inventory, PlayerData.Value.InventoryTier, PlayerData.Value.CharacterName}
    elseif location== "locker" then
        return {PlayerData.Value.Locker, PlayerData.Value.LockerTier}
    end
end

function Module.ExpandGui(localPlayer : Player, location)
    local PlayerData = SystemsContainer.ParentSystems.DataHandling.ProfileHandling.GetCurrentUserData(localPlayer, "player")

    local CurrentTier
    local NextTier
    local NextTierPrice
    local specificData

    if location == "inventory" then
        specificData = InventoryData
        CurrentTier = PlayerData.Value.InventoryTier
    else
        specificData = LockerData
        CurrentTier = PlayerData.Value.LockerTier
    end

    if CurrentTier == 16 then return false end

    NextTier = CurrentTier + 1
    NextTierPrice = specificData.GetTierPrice(NextTier)

    if not NextTierPrice then return false end

    local transactionComplete = SystemsContainer.ParentSystems.CurrencyHandling.DrakenHandling.DeductDraken(localPlayer, NextTierPrice)

    if not transactionComplete then return false end

    if location == "inventory" then
        PlayerData.Value.InventoryTier += 1
    else
        PlayerData.Value.LockerTier += 1
    end

    PlayerData:Save()

    return true
end

function Module.Start()
    swapItemSlotsEvent.OnServerInvoke = function(player : Player, args)
        local startSlotType = args[1]
        local startSlotNum = args[2]
        local endSlotType = args[3]
        local endSlotNum = args[4]

        return Module.SwapItemSlots(player, startSlotType, startSlotNum, endSlotType, endSlotNum)
    end

    getInventoryData.OnServerInvoke = function(localPlayer : Player)
		return Module.GetSpecificData(localPlayer, "inventory")
    end

    expandInventory.OnServerInvoke = function(localPlayer : Player)
        return Module.ExpandGui(localPlayer, "inventory")
    end

    getLockerData.OnServerInvoke = function(localPlayer : Player)
		return Module.GetSpecificData(localPlayer, "locker")
    end

    expandLocker.OnServerInvoke = function(localPlayer : Player)
        return Module.ExpandGui(localPlayer, "locker")
    end
end

function Module.Init(otherSystems)
    SystemsContainer = otherSystems
end

return Module
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local Trove = ReplicatedModules.Classes.Trove

local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)
local getInventoryData = BridgeNet2.ClientBridge("getInventoryData")

local Interface = LocalPlayer:WaitForChild('PlayerGui')

local InventoryWidget = Interface:WaitForChild('Inventory') :: ScreenGui
local InventoryBase = InventoryWidget.InventoryBase :: ImageLabel

local SystemsContainer = {}
local HandlerControllerModule = {}


-- // Module // --
local Module = {}

Module.Handling = false

Module.HandlerTrove = Trove.new()

------------------------- Configs -------------------------
Module.InventoryCache = {}
-----------------------------------------------------------


function Module.StartHandling(...)
    Module.Handling = true

    local args = {...}

    local pageNum = args[1] or 1

    HandlerControllerModule.StartHandler("InvLockerHandling", "inventory")

    -- Load the inventory data
    Module.InventoryCache = getInventoryData:InvokeServerAsync()

    local PlayerNameContainer = InventoryBase.PlayerName
    PlayerNameContainer.Text = Module.InventoryCache[3]

    -- Load the item slots
    HandlerControllerModule.GetHandler("InvLockerHandling").DisplayItemSlots("inventory", pageNum)
end

function Module.EndHandling(...)
    Module.Handling = false
    Module.HandlerTrove:Destroy()

    local args = {...}

    local doNotDestroyImageCache = args[2] or false

    HandlerControllerModule.EndHandler("InvLockerHandling", "inventory", doNotDestroyImageCache)
end


function Module.Init(ParentController, otherSystems)
    HandlerControllerModule = ParentController
    SystemsContainer = otherSystems
end

return Module
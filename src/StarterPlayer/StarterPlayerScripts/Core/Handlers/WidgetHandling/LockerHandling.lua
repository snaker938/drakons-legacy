local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local Trove = ReplicatedModules.Classes.Trove

local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)
local getLockerData = BridgeNet2.ClientBridge("getLockerData")

local Interface = LocalPlayer:WaitForChild('PlayerGui')

local LockerWidget = Interface:WaitForChild('Locker') :: ScreenGui
local LockerBase = LockerWidget.LockerBase :: ImageLabel

local SystemsContainer = {}
local HandlerControllerModule = {}


-- // Module // --
local Module = {}

Module.Handling = false

Module.HandlerTrove = Trove.new()

------------------------- Configs -------------------------
Module.LockerCache = {}
-----------------------------------------------------------


function Module.StartHandling(...)
    Module.Handling = true

    local args = {...}

    local pageNum = args[1] or 1

    HandlerControllerModule.StartHandler("InvLockerHandling", "locker")

    -- Load the locker data
    Module.LockerCache = getLockerData:InvokeServerAsync()

    -- Load the item slots
    HandlerControllerModule.GetHandler("InvLockerHandling").DisplayItemSlots("locker", pageNum)
end

function Module.EndHandling(...)
    Module.Handling = false
    Module.HandlerTrove:Destroy()

    local args = {...}

    local doNotDestroyImageCache = args[2] or false

    HandlerControllerModule.EndHandler("InvLockerHandling", "locker", doNotDestroyImageCache)
end


function Module.Init(ParentController, otherSystems)
    HandlerControllerModule = ParentController
    SystemsContainer = otherSystems
end

return Module
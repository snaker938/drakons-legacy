local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UserInputService = game:GetService("UserInputService")

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local Trove = ReplicatedModules.Classes.Trove
local FunctionUtility = ReplicatedModules.Utility.FunctionUtility

local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)

local Interface = LocalPlayer:WaitForChild('PlayerGui')

local LockerWidget = Interface:WaitForChild('Locker') :: ScreenGui
local LockerBase = LockerWidget.LockerBase :: ImageLabel


local SystemsContainer = {}
local WidgetControllerModule = {}

-- // Module // --
local Module = {}

Module.WidgetTrove = Trove.new()
Module.Open = false

function Module.UpdateWidget()
    
end

function Module.LoadWidget()
    SystemsContainer.Overlays.ToggleAllOverlays(false)

    Module.WidgetTrove:Add(LockerBase.CloseButton.Activated:Connect(function()
        Module.CloseWidget()
    end))

    WidgetControllerModule.ToggleWidget("InventoryWidget", true)

    SystemsContainer.Handlers.StartHandler("LockerHandling")
end

function Module.OpenWidget()
    if Module.Open then
        return
    end
    
    Module.Open = true

    Module.LoadWidget()
    LockerWidget.Enabled = true
end

function Module.CloseWidget()
    if not Module.Open then
        return
    end


    SystemsContainer.Handlers.EndHandler("LockerHandling")

    SystemsContainer.Overlays.ToggleAllOverlays(false)

    LockerWidget.Enabled = false
    
    Module.Open = false
    Module.WidgetTrove:Destroy()
end

function Module.Start()
end

function Module.Init(ParentController, otherSystems)
    WidgetControllerModule = ParentController
    SystemsContainer = otherSystems
end

return Module
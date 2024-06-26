local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local Trove = ReplicatedModules.Classes.Trove
local FunctionUtility = ReplicatedModules.Utility.FunctionUtility

local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)

local Interface = LocalPlayer:WaitForChild('PlayerGui')

local InventoryWidget = Interface:WaitForChild('Inventory') :: ScreenGui
local InventoryBase = InventoryWidget.InventoryBase :: ImageLabel

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

    Module.WidgetTrove:Add(InventoryBase.CloseButton.Activated:Connect(function()
        Module.CloseWidget()
    end))

    SystemsContainer.Handlers.StartHandler("InventoryHandling")
end

function Module.OpenWidget()
    if Module.Open then
        return
    end
    
    Module.Open = true

    Module.LoadWidget()
    InventoryWidget.Enabled = true
end

function Module.CloseWidget()
    if not Module.Open then
        return
    end


    SystemsContainer.Handlers.EndHandler("InventoryHandling")
    WidgetControllerModule.ToggleWidget("LockerWidget", false)
    SystemsContainer.Overlays.ToggleAllOverlays(false)

    InventoryWidget.Enabled = false
    
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
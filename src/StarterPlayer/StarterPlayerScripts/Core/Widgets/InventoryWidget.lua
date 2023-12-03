local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local Trove = ReplicatedModules.Classes.Trove

local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)
local getInventoryData = BridgeNet2.ClientBridge("getInventoryData")

local Interface = LocalPlayer:WaitForChild('PlayerGui')
local LoadCharacterWidget = Interface:WaitForChild('Inventory') :: ScreenGui
local InventoryBase = LoadCharacterWidget.InventoryBase :: ImageLabel
local Templates = LoadCharacterWidget.Templates :: Folder

local SystemsContainer = {}
local WidgetControllerModule = {}

local firstLoad = false

-- // Module // --
local Module = {}

Module.InventoryCache = {}

Module.WidgetTrove = Trove.new()
Module.Open = false

function Module.UpdateWidget()
    Module.LoadWidget()
end

function Module.LoadWidget()
    local PlayerNameContainer = InventoryBase.PlayerName
    PlayerNameContainer.Text = Module.InventoryCache[LocalPlayer.UserId][2]
end

function Module.OpenWidget()
    if Module.Open then
        return
    end


    Module.WidgetTrove:Add(InventoryBase.CloseButton.Activated:Connect(function()
        Module.CloseWidget()
    end))

    if not firstLoad then
        local InventoryData = getInventoryData:InvokeServerAsync()
        Module.InventoryCache[LocalPlayer.UserId] = InventoryData
        firstLoad = true
    end

    Module.Open = true
    Module.UpdateWidget()

    LoadCharacterWidget.Enabled = true
end

function Module.CloseWidget()
    if not Module.Open then
        return
    end

    LoadCharacterWidget.Enabled = false
    
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
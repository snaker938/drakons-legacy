local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UserInputService = game:GetService("UserInputService")

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local Trove = ReplicatedModules.Classes.Trove

local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)

local getDrakenAmount = BridgeNet2.ClientBridge("getDrakenAmount")
local getAllCurrencyData = BridgeNet2.ClientBridge("getAllCurrencyData")

local DrakenAmountChanged = BridgeNet2.ClientBridge("DrakenAmountChanged")

local FunctionUtility = ReplicatedModules.Utility.FunctionUtility

local Interface = LocalPlayer:WaitForChild('PlayerGui')
local CurrencyWidget = Interface:WaitForChild('Currency') :: ScreenGui

local DrakenAmountText = CurrencyWidget.DrakenAmount :: TextLabel
local DrakenImage = DrakenAmountText.DrakenImage :: ImageLabel

local SystemsContainer = {}
local WidgetControllerModule = {}


-- // Module // --
local Module = {}

-- Dictionary of all currencies, named by their ID
Module.CurrencyCache = {
        ["Draken"] = 0,
        ["Gold"] = 0,
        ["Silver"] = 0,
        ["Copper"] = 0,
}


Module.WidgetTrove = Trove.new()
Module.Open = false

function Module.UpdateWidget()
    -- Get the current amount of Draken
    Module.CurrencyCache["Draken"] = getDrakenAmount:InvokeServerAsync()

    DrakenAmountText.Text = Module.CurrencyCache["Draken"]
    DrakenImage.Position = UDim2.new(0, DrakenAmountText.TextBounds.X + 5, 0, 0)
end

function Module.OpenWidget()
    if Module.Open then
        return
    end

    CurrencyWidget.Enabled = true

    Module.UpdateWidget()
    
    Module.Open = true
end

function Module.CloseWidget()
    if not Module.Open then
        return
    end
    
    Module.Open = false

    CurrencyWidget.Enabled = false

    Module.WidgetTrove:Destroy()
end

function Module.Start()
    Module.WidgetTrove:Add(getAllCurrencyData:Connect(function(playerData)
        Module.CurrencyCache["Draken"] = playerData
        Module.OpenWidget()
    end))

    DrakenAmountChanged:Connect(function()
        Module.UpdateWidget()
    end)
end

function Module.Init(ParentController, otherSystems)
    WidgetControllerModule = ParentController
    SystemsContainer = otherSystems
end

return Module
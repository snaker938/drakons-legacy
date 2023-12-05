local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local InventoryData = ReplicatedModules.Data.Inventory
local Trove = ReplicatedModules.Classes.Trove
local FunctionUtility = ReplicatedModules.Utility.FunctionUtility

local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)

local Interface = LocalPlayer:WaitForChild('PlayerGui')
local InventoryWidget = Interface:WaitForChild('Inventory') :: ScreenGui
local Templates = InventoryWidget.Templates :: Folder
local InventoryBase = InventoryWidget.InventoryBase :: ImageLabel

local getInventoryData = BridgeNet2.ClientBridge("getInventoryData")
local expandInventory = BridgeNet2.ClientBridge("expandInventory")


local SystemsContainer = {}
local WidgetControllerModule = {}

local loadInitialInventoryData


-- // Module // --
local Module = {}

Module.InventoryCache = {}
Module.CurrentPage = 1

Module.WidgetTrove = Trove.new()
Module.Open = false

function Module.UpdateWidget()
    Module.WidgetTrove:Destroy()
    Module.LoadWidget()
end

function Module.SetupPageButtons()
    local PageButtons = InventoryBase.InventoryPageHolder:GetChildren()
    for _, pageButton in pairs(PageButtons) do
        if pageButton:IsA("ImageButton") then
            Module.WidgetTrove:Add(pageButton.Activated:Connect(function()
                Module.CurrentPage = tonumber(pageButton.Name)
                Module.UpdateWidget()
            end))
        end
    end
end

function Module.ExpandInventory()
    local expandComplete = expandInventory:InvokeServerAsync()

    if not expandComplete then print("Expansion Failed!") return end

    print("Inventory Expanded!")
end

function Module.DisplayInventorySlots()
    local slotStartNumber = InventoryData.GetSlotStartNumber(Module.CurrentPage)

    local slotEndNumber = InventoryData.GetSlotEndNumber(Module.CurrentPage, Module.InventoryCache[LocalPlayer.UserId][3])

    for i = slotStartNumber, slotEndNumber do
        local SlotClone =Templates. SlotTemplate:Clone() :: ImageLabel
        Module.WidgetTrove:Add(SlotClone)
        SlotClone.Name = "I_Slot" .. i
        SlotClone.Parent = InventoryBase.InventorySlots
        SlotClone.Visible = true
    end

    -- Display expand inventory button

    local nextExpandInvTier = Module.InventoryCache[LocalPlayer.UserId][3] + 1

    local expandInvButtonPosition = InventoryData.GetPositionForExpandInvButton(nextExpandInvTier)

    if not expandInvButtonPosition then return end

    local expandBtnPageNum = expandInvButtonPosition[1]
    -- local expandBtnSlotNum = expandInvButtonPosition[2]

    if expandBtnPageNum == Module.CurrentPage then
        local ExpandInvButtonClone = Templates.ExpandInvBtnTemplate:Clone() :: ImageButton
        Module.WidgetTrove:Add(ExpandInvButtonClone)
        ExpandInvButtonClone.Name = "ExpandInvButton"

        local originalPosition = ExpandInvButtonClone.Position
        local newPosition = UDim2.new(originalPosition.X.Scale - 0.45, originalPosition.X.Offset, originalPosition.Y.Scale - 0.2, originalPosition.Y.Offset)

        Module.WidgetTrove:Add(ExpandInvButtonClone.MouseEnter:Connect(function()
            ExpandInvButtonClone.ImageTransparency = 0.5

            SystemsContainer.Overlays.ToggleOverlay("ExpandGuiOverlay", true, "inventory", tonumber(nextExpandInvTier - 1), newPosition)
        end))

        Module.WidgetTrove:Add(ExpandInvButtonClone.MouseLeave:Connect(function()
            ExpandInvButtonClone.ImageTransparency = 0

            SystemsContainer.Overlays.ToggleOverlay("ExpandGuiOverlay", false)
        end))

        Module.WidgetTrove:Add(ExpandInvButtonClone.Activated:Connect(function()
            Module.ExpandInventory()
        end))

        ExpandInvButtonClone.Parent = InventoryBase.InventorySlots
        ExpandInvButtonClone.Visible = true
    end
end

function Module.LoadWidget()
    local PlayerNameContainer = InventoryBase.PlayerName
    PlayerNameContainer.Text = Module.InventoryCache[LocalPlayer.UserId][2]

    Module.DisplayInventorySlots()
    Module.SetupPageButtons()
end

function Module.OpenWidget()
    if Module.Open then
        return
    end

    Module.WidgetTrove:Add(InventoryBase.CloseButton.Activated:Connect(function()
        Module.CloseWidget()
    end))

    loadInitialInventoryData()

    local InitialInventoryData = getInventoryData:InvokeServerAsync()

    Module.InventoryCache[LocalPlayer.UserId] = InitialInventoryData

    Module.Open = true
    Module.UpdateWidget()

    InventoryWidget.Enabled = true
end

function Module.CloseWidget()
    if not Module.Open then
        return
    end

    InventoryWidget.Enabled = false
    
    Module.CurrentPage = 1
    Module.Open = false
    Module.WidgetTrove:Destroy()
end

function Module.Start()
    loadInitialInventoryData = FunctionUtility.RunFunctionOnce(function()
        local InitialInventoryData = getInventoryData:InvokeServerAsync()

        Module.InventoryCache[LocalPlayer.UserId] = InitialInventoryData
    end)
end

function Module.Init(ParentController, otherSystems)
    WidgetControllerModule = ParentController
    SystemsContainer = otherSystems
end

return Module
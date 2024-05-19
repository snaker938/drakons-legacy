local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local Trove = ReplicatedModules.Classes.Trove

local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)


local deleteItemEvent = BridgeNet2.ClientBridge("expandInventory")

local Interface = LocalPlayer:WaitForChild('PlayerGui')
local DeleteItemWidget = Interface:WaitForChild('DestroyItemGui') :: ScreenGui
local DeleteItemBase = DeleteItemWidget.DestroyItemGuiBase :: ImageLabel

local SystemsContainer = {}
local WidgetControllerModule = {}

-- // Module // --
local Module = {}

Module.IsLockerOpen = false

Module.WidgetTrove = Trove.new()
Module.Open = false

function Module.UpdateWidget()
    
end

function Module.OpenWidget(...)
    if Module.Open then
        return
    end

    Module.IsLockerOpen = WidgetControllerModule.IsWidgetOpen("LockerWidget")

    WidgetControllerModule.ToggleWidget("LockerWidget", false)

    local args = {...}

    local slotObject = args[3] :: ImageLabel
    
    Module.Open = true

    Module.WidgetTrove:Add(DeleteItemBase.NoBtn.Activated:Connect(function()
        Module.CloseWidget()
    end))

    DeleteItemBase.ItemThumbnail.Image = slotObject.Image

    local itemSlotName = slotObject:GetAttribute("ItemSlotName")

    DeleteItemBase.DeleteItemPrompt.Text = 'Are you sure you want to destroy this item: <font color="#FFFFFF">' .. itemSlotName .. '</font>?'

    DeleteItemWidget.Enabled = true

end

function Module.CloseWidget()
    if not Module.Open then
        return
    end

    if Module.IsLockerOpen then
        WidgetControllerModule.ToggleWidget("LockerWidget", true)
    end

    Module.IsLockerOpen = false
    
    Module.Open = false
    Module.WidgetTrove:Destroy()

    DeleteItemWidget.Enabled = false
end

function Module.Start()
    
end

function Module.Init(ParentController, otherSystems)
    WidgetControllerModule = ParentController
    SystemsContainer = otherSystems
end

return Module
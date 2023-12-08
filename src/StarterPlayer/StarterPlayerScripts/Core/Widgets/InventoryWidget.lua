local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UserInputService = game:GetService("UserInputService")

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

-- Page Buttons Config --
Module.hoverDuration = 0.4
Module.hoverDisrupted = false
Module.hovering = false
-------------------------

-- Dragging Config --
Module.DraggingItemSlot = false
Module.DisplayingDraggingItemSlot = false
Module.DraggingImageSlotObject = nil
Module.DraggingSlotName = nil
--------------------

Module.InventoryCache = {}
Module.CurrentPage = 1

Module.WidgetTrove = Trove.new()
Module.Open = false

function Module.UpdateWidget()
    local InitialInventoryData = getInventoryData:InvokeServerAsync()
    Module.InventoryCache[LocalPlayer.UserId] = InitialInventoryData

    SystemsContainer.Overlays.ToggleOverlay("ExpandGuiOverlay", false)
    Module.WidgetTrove:Destroy()
    Module.LoadWidget()
end

function Module.StartPageBtnHoverDetection(pageNum, cancel)
    if cancel then
        print("Hovering Cancelled!")
        Module.hovering = false
        Module.hoverDisrupted = false
        Module.UpdateWidget()
    return end

    if Module.hovering then return end

    Module.hovering = true

    local startTime = os.clock() -- record the starting time

    while os.clock() - startTime < Module.hoverDuration do
        task.wait(0.1) -- check every 0.1 seconds
        print("Hovering Time: ", os.clock() - startTime, Module.hoverDisrupted)
        if Module.hoverDisrupted then
            Module.hovering = false
            Module.hoverDisrupted = false
            Module.UpdateWidget()
            return
        end
    end

    Module.CurrentPage = pageNum
    Module.hovering = false
    Module.hoverDisrupted = false
    Module.UpdateWidget()
end


function Module.SetupPageButtons()
    local PageButtons = InventoryBase.InventoryPageHolder.PositionFrame:GetChildren()
    for _, pageButton in pairs(PageButtons) do
        if pageButton:IsA("TextButton") then
            if pageButton.Name == tostring(Module.CurrentPage) then
                pageButton.TextTransparency = 0.5
            else
                pageButton.TextTransparency = 0
            end

            if InventoryData.GetMaxPageForTier(Module.InventoryCache[LocalPlayer.UserId][3]) < tonumber(pageButton.Name) then
                pageButton.Visible = false
                continue
            else
                pageButton.Visible = true
            end
            Module.WidgetTrove:Add(pageButton.Activated:Connect(function()
                if tonumber(pageButton.Name) == Module.CurrentPage then return end
                Module.CurrentPage = tonumber(pageButton.Name)
                Module.UpdateWidget()
            end))

            Module.WidgetTrove:Add(pageButton.InputBegan:Connect(function(inputObject)
                if inputObject.UserInputType == Enum.UserInputType.MouseMovement and not Module.hovering then
                    Module.StartPageBtnHoverDetection(tonumber(pageButton.Name), false)
                end
            end))

            Module.WidgetTrove:Add(pageButton.InputEnded:Connect(function(inputObject)
                if inputObject.UserInputType == Enum.UserInputType.MouseMovement and Module.hovering and not Module.hoverDisrupted then
                    Module.StartPageBtnHoverDetection(tonumber(pageButton.Name), true)
                end
            end))
        end
    end
end

function Module.ExpandInventory(ExpandInvButtonClone)
    local expandComplete = expandInventory:InvokeServerAsync()

    if not expandComplete then print("Expansion Failed!") return end

    Module.UpdateWidget()
end

function Module.DisplayExpandInvButton()
    local nextExpandInvTier = Module.InventoryCache[LocalPlayer.UserId][3] + 1

    local expandInvButtonPosition = InventoryData.GetPositionForExpandInvButton(nextExpandInvTier)

    if not expandInvButtonPosition then return end

    local expandBtnPageNum = expandInvButtonPosition[1]

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
            Module.ExpandInventory(ExpandInvButtonClone)
        end))

        ExpandInvButtonClone.Parent = InventoryBase.InventorySlots
        ExpandInvButtonClone.Visible = true
    end
end

function Module.DragItemSlot(imageSlot, action, mouseLocation, slotName)
    if action == "dragStart" then
        -- print("Dragging Started: ", slotName)
        Module.DraggingItemSlot = true
        Module.DraggingImageSlotObject = imageSlot:Clone()
        Module.DraggingImageSlotObject.Visible = false
        Module.DraggingSlotName = slotName
    elseif action == "tryToDisplaySlot" then
        local GuiObjects = Players.LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(mouseLocation.X, mouseLocation.Y)
        if not GuiObjects then return end
        if #GuiObjects == 0 then return end
        local hoveringOverDifferentSlot = false

        local FoundOwnSlot = false

        for _, GuiObject in pairs(GuiObjects) do
            -- Check if the user is hovering over a different slot
            if GuiObject.Name:match("Slot(%d+)") then
                if GuiObject.Name ~= Module.DraggingSlotName then
                    -- print(GuiObject.Name, Module.DraggingSlotName)
                    hoveringOverDifferentSlot = true
                    break
                else
                    FoundOwnSlot = true
                end
            end
            if GuiObject.Name:match("InventoryPageHolder") then
                hoveringOverDifferentSlot = true
                break
            end

            if GuiObject.Name:match("InventoryBase") and not FoundOwnSlot then
                hoveringOverDifferentSlot = true
                break
            end
        end
        if not hoveringOverDifferentSlot then return end

        Module.DisplayingDraggingItemSlot = true

        -- print("Displaying Slot: ", Module.DraggingSlotName)

        Module.DraggingImageSlotObject.Name = "ImageThumbnailCloned"

        Module.DraggingImageSlotObject.Position = UDim2.new(0, mouseLocation.X, 0, mouseLocation.Y + 36)

        Module.DraggingImageSlotObject.Size = UDim2.new(0, InventoryBase.InventorySlots.InvLayout.AbsoluteCellSize.X, 0, InventoryBase.InventorySlots.InvLayout.AbsoluteCellSize.Y)

        Module.DraggingImageSlotObject.AnchorPoint = Vector2.new(0.5, 0.5)
        Module.DraggingImageSlotObject.ImageTransparency = 0.4


        Module.DraggingImageSlotObject.Parent = InventoryWidget

        Module.DraggingImageSlotObject.Visible = true

        Module.WidgetTrove:Add(Module.DraggingImageSlotObject)
    elseif action == "drag" then
        -- print("Dragging the slot!")
        Module.DraggingImageSlotObject.Position = UDim2.new(0, mouseLocation.X, 0, mouseLocation.Y + 36)
    else
        -- print("Dragging Ended: ", Module.DraggingSlotName)

        Module.WidgetTrove:Remove(Module.DraggingImageSlotObject)


        Module.DraggingItemSlot = false
        Module.DisplayingDraggingItemSlot = false
        Module.DraggingImageSlotObject = nil
        Module.DraggingSlotName = nil
    end
end

function Module.DisplayInventorySlots()
    local slotStartNumber = InventoryData.GetSlotStartNumber(Module.CurrentPage)

    local slotEndNumber = InventoryData.GetSlotEndNumber(Module.CurrentPage, Module.InventoryCache[LocalPlayer.UserId][3])

    for i = slotStartNumber, slotEndNumber do
        local SlotClone = Templates.SlotTemplate:Clone() :: ImageLabel
        Module.WidgetTrove:Add(SlotClone)
        SlotClone.Name = "I_Slot" .. i
        SlotClone.Parent = InventoryBase.InventorySlots

        local playerInv = Module.InventoryCache[LocalPlayer.UserId][1]
        
        if playerInv[tostring(i)] then
            local ItemThumbnailTemplateClone = Templates.ItemThumbnailTemplate:Clone() :: ImageLabel
            ItemThumbnailTemplateClone.Name = "ItemThumbnail"
            ItemThumbnailTemplateClone.Image = "rbxassetid://" .. tostring(playerInv[tostring(i)]["ID"])
            ItemThumbnailTemplateClone.Parent = SlotClone
            ItemThumbnailTemplateClone.Visible = true

            Module.WidgetTrove:Add(ItemThumbnailTemplateClone.InputBegan:Connect(function(inputObject)
                if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mouseLocation = inputObject.Position

                    Module.DragItemSlot(ItemThumbnailTemplateClone, "dragStart", mouseLocation, SlotClone.Name)
                end
            end))

            Module.WidgetTrove:Add(ItemThumbnailTemplateClone)
        end
        SlotClone.Visible = true
    end

    Module.WidgetTrove:Add(UserInputService.InputEnded:Connect(function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouseLocation = inputObject.Position

            Module.DragItemSlot(nil, "dragEnd", nil, nil)
        end
    end))

    Module.WidgetTrove:Add(UserInputService.InputChanged:Connect(function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseLocation = inputObject.Position

            if Module.DraggingItemSlot then
                if Module.DisplayingDraggingItemSlot then
                    Module.DragItemSlot(nil, "drag", mouseLocation, nil)
                else
                    Module.DragItemSlot(nil, "tryToDisplaySlot", mouseLocation)
                end
            end
        end
    end))
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
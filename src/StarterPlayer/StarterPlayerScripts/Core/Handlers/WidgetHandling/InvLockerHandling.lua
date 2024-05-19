local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UserInputService = game:GetService("UserInputService")

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)

local expandLocker = BridgeNet2.ClientBridge("expandLocker")
local expandInventory = BridgeNet2.ClientBridge("expandInventory")
local swapItemSlotsEvent = BridgeNet2.ClientBridge("swapItemSlotsEvent")

local Interface = LocalPlayer:WaitForChild('PlayerGui')
local Templates = Interface.Templates.SlotTemplates :: Folder

local InventoryWidget = Interface:WaitForChild('Inventory') :: ScreenGui
local InventoryBase = InventoryWidget.InventoryBase :: ImageLabel

local LockerWidget = Interface:WaitForChild('Locker') :: ScreenGui
local LockerBase = LockerWidget.LockerBase :: ImageLabel

-- --- Data --
local inventoryConfigData = ReplicatedModules.Data.Inventory
local lockerConfigData = ReplicatedModules.Data.Locker

local DraggingImageSlotCache = nil


local SystemsContainer = {}
local HandlerControllerModule = {}

-- // Module // --
local Module = {}

Module.Handling = false

------------------------- Configs -------------------------
Module.CurrentInventoryPage = 1
Module.CurrentLockerPage = 1

-- Dragging
Module.DraggingSlotName = nil
Module.DraggingImageSlotObject = nil
Module.DraggingItemSlot = false
Module.DisplayingDraggingItemSlot = false


-- Hovering
Module.hoveringAndDraggingOverPageNum = -1
Module.hoveringAndDraggingDuration = 0.4
-----------------------------------------------------------

function Module.ExpandGui(type)
    if not Module.Handling then
        error("ExpandGui() called when handling is not active")
        return
    end

    local expandComplete

    if type == "inventory" then
        expandComplete = expandInventory:InvokeServerAsync()
    else
        expandComplete = expandLocker:InvokeServerAsync()
    end

    if not expandComplete then print("Expansion Failed!") return end

    SystemsContainer.Overlays.ToggleOverlay("ExpandGuiOverlay", false)

    if type == "inventory" then
        HandlerControllerModule.ResetHandler("InventoryHandling", Module.CurrentInventoryPage)
    else
        HandlerControllerModule.ResetHandler("LockerHandling", Module.CurrentLockerPage)
    end
end

function Module.StartPageBtnHoverDetection(pageNum, cancel, location)
    if not Module.Handling then
        error("StartPageBtnHoverDetection() called when handling is not active")
        return
    end

    if cancel or (Module.hoveringAndDraggingOverPageNum ~= pageNum and not Module.hoveringAndDraggingOverPageNum == 0) or not Module.DisplayingDraggingItemSlot then
        Module.hoveringAndDraggingOverPageNum = -1
        return
    end

    Module.hoveringAndDraggingOverPageNum = pageNum

    local startTime = os.clock() -- record the starting time

    while ((os.clock() - startTime) < Module.hoveringAndDraggingDuration) and (not (Module.hoveringAndDraggingOverPageNum == -1)) and (Module.DisplayingDraggingItemSlot) do
        if (Module.hoveringAndDraggingOverPageNum == -1) or (Module.hoveringAndDraggingOverPageNum ~= pageNum) or (not Module.DisplayingDraggingItemSlot) then
            Module.hoveringAndDraggingOverPageNum = -1
            return
        end
        task.wait(0.1)
    end


    if (Module.hoveringAndDraggingOverPageNum == -1) or (not Module.DisplayingDraggingItemSlot) then
        return
    end

    Module.hoveringAndDraggingOverPageNum = -1

    DraggingImageSlotCache = Module.DraggingImageSlotObject:Clone()


    if location == "inventory" then
        Module.CurrentInventoryPage = pageNum
        HandlerControllerModule.ResetHandler("InventoryHandling", Module.CurrentInventoryPage, true)
    else
        Module.CurrentLockerPage = pageNum
        HandlerControllerModule.ResetHandler("LockerHandling", Module.CurrentLockerPage, true)
    end
end

function Module.SetupPageButtons(location)
    if not Module.Handling then
        error("SetupPageButtons() called when handling is not active")
        return
    end

    local PageButtons
    local currentPage
    local specificData
    local dataCache
    local trove

    if location == "inventory" then
        PageButtons = InventoryBase.InventoryPageHolder.PositionFrame:GetChildren()
        currentPage = Module.CurrentInventoryPage
        specificData = inventoryConfigData
        dataCache = HandlerControllerModule.GetHandler("InventoryHandling").InventoryCache
        trove = HandlerControllerModule.GetHandler("InventoryHandling").HandlerTrove
    else
        PageButtons = LockerBase.LockerPageHolder.PositionFrame:GetChildren()
        currentPage = Module.CurrentLockerPage
        specificData = lockerConfigData
        dataCache = HandlerControllerModule.GetHandler("LockerHandling").LockerCache
        trove = HandlerControllerModule.GetHandler("LockerHandling").HandlerTrove
    end

    for _, pageButton in pairs(PageButtons) do
        if pageButton:IsA("TextButton") then
            if pageButton.Name == tostring(currentPage) then
                pageButton.TextTransparency = 0.5
            else
                pageButton.TextTransparency = 0
            end

            if specificData.GetMaxPageForTier(dataCache[2]) < tonumber(pageButton.Name) then
                pageButton.Visible = false
                continue
            else
                pageButton.Visible = true
            end

            trove:Add(pageButton.Activated:Connect(function()
                if tonumber(pageButton.Name) == currentPage then return end
                local currentPageNum = tonumber(pageButton.Name)

                if location == "inventory" then
                    HandlerControllerModule.ResetHandler("InventoryHandling", currentPageNum)
                else
                    HandlerControllerModule.ResetHandler("LockerHandling", currentPageNum)
                end
            end))

            trove:Add(pageButton.InputBegan:Connect(function(inputObject)
                if not Module.DisplayingDraggingItemSlot or tonumber(pageButton.Name) == tonumber(currentPage) then return end

                if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
                    Module.StartPageBtnHoverDetection(tonumber(pageButton.Name), false, location)
                end
            end))

            trove:Add(pageButton.InputEnded:Connect(function(inputObject)
                if not Module.DisplayingDraggingItemSlot or tonumber(pageButton.Name) == tonumber(currentPage) then return end

                if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
                    Module.StartPageBtnHoverDetection(tonumber(pageButton.Name), true, location)
                end
            end))
        end
    end
end

function Module.SwitchItemSlots(startSlotType, startSlotNum, endSlotType, endSlotNum)
    if not Module.Handling then
        error("SwitchItemSlots() called when handling is not active")
        return
    end

    local didItemsSwap = swapItemSlotsEvent:InvokeServerAsync({startSlotType, startSlotNum, endSlotType, endSlotNum})

    -- If the items did not swap, then return
    if not didItemsSwap then return end

    local startSlotGuiObject
    local endSlotGuiObject
   

    if startSlotType == "I" then
        startSlotGuiObject = InventoryBase.InventorySlots:FindFirstChild("I_Slot" .. startSlotNum)
    else
        startSlotGuiObject = LockerBase.LockerSlots:FindFirstChild("L_Slot" .. startSlotNum)
    end

    if endSlotType == "I" then
        endSlotGuiObject = InventoryBase.InventorySlots:FindFirstChild("I_Slot" .. endSlotNum)
    else
        endSlotGuiObject = LockerBase.LockerSlots:FindFirstChild("L_Slot" .. endSlotNum)
    end

    if not endSlotGuiObject then return end

    -- Get the item thumbnail gui objects, for the start slot. If the end slot is not empty, get the item thumbnail gui object for the end slot

    local endSlotItemThumbnail = endSlotGuiObject:FindFirstChild("ItemThumbnail")

    -- If there is a startSlotGuiObject, then the user is swapping items on the same page
    if startSlotGuiObject then
        local startSlotItemThumbnail = startSlotGuiObject:FindFirstChild("ItemThumbnail")

        startSlotItemThumbnail.Parent = endSlotGuiObject

        if endSlotItemThumbnail then
            endSlotItemThumbnail.Parent = startSlotGuiObject
        end
    else
        local endSlotTypeString

        if endSlotType == "I" then
            endSlotTypeString = "inventory"
        else
            endSlotTypeString = "locker"
        end

        if not endSlotItemThumbnail then
            Module.DisplayItemThumbnail(endSlotGuiObject, startSlotNum, endSlotTypeString)
        else
            endSlotItemThumbnail:Destroy()
            Module.DisplayItemThumbnail(endSlotGuiObject, startSlotNum, endSlotTypeString)
        end
    end

    -- Update the specific caches --TODO--
    local startSlotData
    local endSlotData

    -- local startSlotData = Module.InventoryCache[1][tostring(startSlotNum)]
    -- local endSlotData = Module.InventoryCache[1][tostring(endSlotNum)]

    -- Module.InventoryCache[1][tostring(startSlotNum)] = endSlotData
    -- Module.InventoryCache[1][tostring(endSlotNum)] = startSlotData
end

function Module.DisplayExpandGuiBtn(location)
    if not Module.Handling then
        error("DisplayExpandGuiBtn() called when handling is not active")
        return
    end

    local nextExpandGuiTier
    local expandGuiBtnPosition

    local dataCache
    local trove

    if location == "inventory" then
        dataCache = HandlerControllerModule.GetHandler("InventoryHandling").InventoryCache
        trove = HandlerControllerModule.GetHandler("InventoryHandling").HandlerTrove
    else
        dataCache = HandlerControllerModule.GetHandler("LockerHandling").LockerCache
        trove = HandlerControllerModule.GetHandler("LockerHandling").HandlerTrove
    end

    if location == "inventory" then
        nextExpandGuiTier = dataCache[2] + 1
        expandGuiBtnPosition = inventoryConfigData.GetPositionForExpandGuiBtn(nextExpandGuiTier)
    else
        nextExpandGuiTier = dataCache[2] + 1
        expandGuiBtnPosition = lockerConfigData.GetPositionForExpandGuiBtn(nextExpandGuiTier)
    end

    if not expandGuiBtnPosition then return end

    local expandBtnPageNum = expandGuiBtnPosition[1]

    local pageToCheck

    if location == "inventory" then
        pageToCheck = Module.CurrentInventoryPage
    else
        pageToCheck = Module.CurrentLockerPage
    end

    if expandBtnPageNum == pageToCheck then
        local ExpandGuiBtnClone = Templates.ExpandSlotsBtnTemplate:Clone() :: ImageButton

        trove:Add(ExpandGuiBtnClone)

        ExpandGuiBtnClone.Name = "ExpandGuiButton"


        trove:Add(ExpandGuiBtnClone.MouseEnter:Connect(function()
            ExpandGuiBtnClone.ImageTransparency = 0.5

            -- Get the absolute X and Y position of the expand gui button
            local absolutePosition = ExpandGuiBtnClone.AbsolutePosition

            if location == "inventory" then
                SystemsContainer.Overlays.ToggleOverlay("ExpandGuiOverlay", true, "inventory", tonumber(nextExpandGuiTier), inventoryConfigData, {absolutePosition.X, absolutePosition.Y})
            else
                SystemsContainer.Overlays.ToggleOverlay("ExpandGuiOverlay", true, "locker", tonumber(nextExpandGuiTier), lockerConfigData, {absolutePosition.X, absolutePosition.Y})
            end
        end))

        trove:Add(ExpandGuiBtnClone.MouseLeave:Connect(function()
            ExpandGuiBtnClone.ImageTransparency = 0

            SystemsContainer.Overlays.ToggleOverlay("ExpandGuiOverlay", false)
        end))

        trove:Add(ExpandGuiBtnClone.Activated:Connect(function()
            Module.ExpandGui(location)
        end))

        if location == "inventory" then
            ExpandGuiBtnClone.Parent = InventoryBase.InventorySlots
        else
            ExpandGuiBtnClone.Parent = LockerBase.LockerSlots
        end
       
        ExpandGuiBtnClone.Visible = true
    end
end

function Module.DragItemSlot(imageSlot, action, mouseLocation, slotName, location)
    if not Module.Handling then
        error("DragItemSlot() called when handling is not active")
        return
    end

    if action == "dragStart" then
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
                    hoveringOverDifferentSlot = true
                    break
                else
                    FoundOwnSlot = true
                end
            end
            
            if location == "inventory" then
                if GuiObject.Name:match("InventoryPageHolder") or (GuiObject.Name:match("InventoryBase") and not FoundOwnSlot) then
                    hoveringOverDifferentSlot = true
                    break
                end
            else
                if GuiObject.Name:match("LockerPageHolder") or (GuiObject.Name:match("LockerBase") and not FoundOwnSlot) then
                    hoveringOverDifferentSlot = true
                    break
                end
            end
        end

        if not hoveringOverDifferentSlot then return end

        Module.DisplayingDraggingItemSlot = true
        Module.DraggingImageSlotObject.Name = "ImageThumbnailCloned"
        Module.DraggingImageSlotObject.Position = UDim2.new(0, mouseLocation.X, 0, mouseLocation.Y)
        Module.DraggingImageSlotObject.AnchorPoint = Vector2.new(0.5, 0.5)
        Module.DraggingImageSlotObject.ImageTransparency = 0.4

    
        -- Get the slot number from Module.DraggingSlotName
        local slotNum = string.match(Module.DraggingSlotName, "Slot(%d+)")

        local slotSize
        local trove

        if location == "inventory" then
            slotSize = InventoryBase.InventorySlots["I_Slot" .. slotNum].AbsoluteSize
            trove = HandlerControllerModule.GetHandler("InventoryHandling").HandlerTrove
        else
            slotSize = LockerBase.LockerSlots["L_Slot" .. slotNum].AbsoluteSize
            trove = HandlerControllerModule.GetHandler("LockerHandling").HandlerTrove
        end


        -- Set the size of the dragging image slot object to the size of the slot
        Module.DraggingImageSlotObject.Size = UDim2.new(0, slotSize.X, 0, slotSize.Y)
       

        Module.DraggingImageSlotObject.Parent = Interface.DraggingImageSlotHolder

        Module.DraggingImageSlotObject.Visible = true

        trove:Add(Module.DraggingImageSlotObject)
    elseif action == "drag" then
        if DraggingImageSlotCache then
            DraggingImageSlotCache.Position = UDim2.new(0, mouseLocation.X, 0, mouseLocation.Y)
        elseif Module.DraggingImageSlotObject then
            Module.DraggingImageSlotObject.Position = UDim2.new(0, mouseLocation.X, 0, mouseLocation.Y)
        end
    else
        -- action == "dragEnd"
        if Module.DisplayingDraggingItemSlot then
            local GuiObjects = Players.LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(mouseLocation.X, mouseLocation.Y)

            local startSlotType, startSlotNum = string.match(Module.DraggingSlotName, "(%a)_Slot(%d+)")

            if (#GuiObjects == 1 and GuiObjects[1].Name == "ImageThumbnailCloned") or (#GuiObjects == 0) then
                -- Open the delete item widget
                SystemsContainer.Widgets.ToggleWidget("DeleteItemWidget", true, startSlotType, startSlotNum, Module.DraggingImageSlotObject)
            else
                -- Loop through all the GUI objects that the user is hovering over. Get the first slot that the user is hovering over, and extract the slot type and slot number from the name
                for _, GuiObject in pairs(GuiObjects) do
                    if GuiObject.Name:match("Slot(%d+)") then
                        local endSlotType, endSlotNum = string.match(GuiObject.Name, "(%a)_Slot(%d+)")

                        if endSlotType and endSlotNum then
                            -- If the user is hovering over a different slot, then swap the items
                            if startSlotType ~= endSlotType or startSlotNum ~= endSlotNum then
                                Module.SwitchItemSlots(startSlotType, startSlotNum, endSlotType, endSlotNum)
                                break
                            end
                        end
                    end
                end
            end
        end
        -- Reset all variables
        if DraggingImageSlotCache then
            DraggingImageSlotCache:Destroy()
        end

        if Module.DraggingImageSlotObject then
            Module.DraggingImageSlotObject:Destroy()
        end

        Module.DraggingSlotName = nil
        Module.DraggingImageSlotObject = nil

        Module.DraggingItemSlot = false
        Module.DisplayingDraggingItemSlot = false
        DraggingImageSlotCache = nil
    end
end

function Module.DisplayItemThumbnail(SlotClone, i, location)
    if not Module.Handling then
        error("DisplayItemThumbnail() called when handling is not active")
        return
    end
    local ItemThumbnailTemplateClone = Templates.ItemThumbnailTemplate:Clone() :: ImageLabel
    ItemThumbnailTemplateClone.Name = "ItemThumbnail"

    local dataCache
    local trove

    if location == "inventory" then
        dataCache = HandlerControllerModule.GetHandler("InventoryHandling").InventoryCache
        trove = HandlerControllerModule.GetHandler("InventoryHandling").HandlerTrove
    else
        dataCache = HandlerControllerModule.GetHandler("LockerHandling").LockerCache
        trove = HandlerControllerModule.GetHandler("LockerHandling").HandlerTrove
    end

    if location == "inventory" then
        ItemThumbnailTemplateClone.Image = "rbxassetid://" .. tostring(dataCache[1][tostring(i)]["ID"])
    else
        ItemThumbnailTemplateClone.Image = "rbxassetid://" .. tostring(dataCache[1][tostring(i)]["ID"])
    end

    ItemThumbnailTemplateClone.Parent = SlotClone
    ItemThumbnailTemplateClone.Visible = true

    ----------------------- TO REMOVE -----------------------
    -- Create new attribute "ItemSlotName" for the item thumbnail
    if location == "inventory" then
        if tonumber(dataCache[1][tostring(i)]["ID"]) == 139656808 then
            ItemThumbnailTemplateClone:SetAttribute("ItemSlotName", "The Epic Bow")
        else
            ItemThumbnailTemplateClone:SetAttribute("ItemSlotName", "Sword of the Gods")
        end
    else
        if tonumber(dataCache[1][tostring(i)]["ID"]) == 139656808 then
            ItemThumbnailTemplateClone:SetAttribute("ItemSlotName", "The Epic Bow")
        else
            ItemThumbnailTemplateClone:SetAttribute("ItemSlotName", "Sword of the Gods")
        end
    end
    ----------------------------------------------------------

    trove:Add(ItemThumbnailTemplateClone.InputBegan:Connect(function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
            Module.DragItemSlot(ItemThumbnailTemplateClone, "dragStart", inputObject.Position, ItemThumbnailTemplateClone.Parent.Name, location)
        end
    end))

    trove:Add(ItemThumbnailTemplateClone)
end

function Module.DisplayItemSlots(location, pageNum)
    if not Module.Handling then
        error("DisplayItemSlots() called when handling is not active")
        return
    end

    local slotStartNumber
    local slotEndNumber

    local dataCache
    local trove

    if location == "inventory" then
        dataCache = HandlerControllerModule.GetHandler("InventoryHandling").InventoryCache
        trove = HandlerControllerModule.GetHandler("InventoryHandling").HandlerTrove
        Module.CurrentInventoryPage = pageNum
    else
        dataCache = HandlerControllerModule.GetHandler("LockerHandling").LockerCache
        trove = HandlerControllerModule.GetHandler("LockerHandling").HandlerTrove
        Module.CurrentLockerPage = pageNum
    end

    if location == "inventory" then
        slotStartNumber = inventoryConfigData.GetSlotStartNumber(Module.CurrentInventoryPage)
        slotEndNumber = inventoryConfigData.GetSlotEndNumber(Module.CurrentInventoryPage, dataCache[2])
    else
        slotStartNumber = lockerConfigData.GetSlotStartNumber(Module.CurrentLockerPage)
        slotEndNumber = lockerConfigData.GetSlotEndNumber(Module.CurrentLockerPage, dataCache[2])
    end

    local letter
    if location == "inventory" then
        letter = "I"
    else
        letter = "L"
    end

    for i = slotStartNumber, slotEndNumber do
        local SlotClone = Templates.SlotTemplate:Clone() :: ImageLabel
        trove:Add(SlotClone)

        SlotClone.Name = letter .. "_Slot" .. i

        if location == "inventory" then
            SlotClone.Parent = InventoryBase.InventorySlots

            if dataCache[1][tostring(i)] then
                Module.DisplayItemThumbnail(SlotClone, i, location)
            end
        else
            SlotClone.Parent = LockerBase.LockerSlots

            if dataCache[1][tostring(i)] then
                Module.DisplayItemThumbnail(SlotClone, i, location)
            end
        end

        SlotClone.Visible = true
    end

    Module.DisplayExpandGuiBtn(location)
    Module.SetupPageButtons(location)
end

function Module.CreateDraggingImageSlotHolder(trove)
    -- Create a new ScreenGUI object to hold the dragging image slot object
    local DraggingImageSlotHolder = Instance.new("ScreenGui")
    DraggingImageSlotHolder.Name = "DraggingImageSlotHolder"
    DraggingImageSlotHolder.DisplayOrder = 1
    DraggingImageSlotHolder.Parent = Interface

    trove:Add(DraggingImageSlotHolder)
end

function Module.StartHandling(location)
    Module.Handling = true

    local trove

    if location == "inventory" then
        trove = HandlerControllerModule.GetHandler("InventoryHandling").HandlerTrove
    else
        trove = HandlerControllerModule.GetHandler("LockerHandling").HandlerTrove
    end

    Module.CreateDraggingImageSlotHolder(trove)

    trove:Add(UserInputService.InputChanged:Connect(function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseLocation = inputObject.Position

            if Module.DraggingItemSlot then
                if Module.DisplayingDraggingItemSlot then
                    Module.DragItemSlot(nil, "drag", mouseLocation, nil, location)
                else
                    Module.DragItemSlot(nil, "tryToDisplaySlot", mouseLocation, nil, location)
                end
            end
        end
    end))

    -- User has stopped dragging the item thumbnail
    trove:Add(UserInputService.InputEnded:Connect(function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 and Module.DraggingItemSlot then
            local mouseLocation = inputObject.Position
            Module.hoveringAndDraggingOverPageNum = -1
            Module.DragItemSlot(nil, "dragEnd", mouseLocation, nil, location)
        end
    end))
end

function Module.EndHandling(...)
    Module.Handling = false

    Module.CurrentInventoryPage = 1
    Module.CurrentLockerPage = 1

    local args = {...}
    local doNotDestroyImageCache = args[2] or false
    local location = args[1]

    local trove

    if location == "inventory" then
        trove = HandlerControllerModule.GetHandler("InventoryHandling").HandlerTrove
    elseif location == "locker" then
        trove = HandlerControllerModule.GetHandler("LockerHandling").HandlerTrove
    end

    if doNotDestroyImageCache then
        if DraggingImageSlotCache then
            HandlerControllerModule.GetHandler("InvLockerHandling").CreateDraggingImageSlotHolder(trove)

            DraggingImageSlotCache.Parent = Interface.DraggingImageSlotHolder

            local mouse = LocalPlayer:GetMouse()
            local position = Vector2.new(mouse.X, mouse.Y)
	    
            DraggingImageSlotCache.Position = UDim2.new(0, position.X, 0, position.Y)

            trove:Add(DraggingImageSlotCache)
        end
    else
        if DraggingImageSlotCache then
            DraggingImageSlotCache:Destroy()
            DraggingImageSlotCache = nil
        end

        Module.DraggingSlotName = nil
        Module.DraggingImageSlotObject = nil
        Module.DraggingItemSlot = false
        Module.DisplayingDraggingItemSlot = false
    end

    if Module.DraggingImageSlotObject then
        Module.DraggingImageSlotObject:Destroy()
    end

    ---
    Module.hoveringAndDraggingOverPageNum = -1
end

function Module.Init(ParentController, otherSystems)
    HandlerControllerModule = ParentController
    SystemsContainer = otherSystems
end

return Module
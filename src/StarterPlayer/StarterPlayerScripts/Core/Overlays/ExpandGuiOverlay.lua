local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local InventoryData = ReplicatedModules.Data.Inventory
local LockerData = ReplicatedModules.Data.Locker
local Trove = ReplicatedModules.Classes.Trove

local Interface = LocalPlayer:WaitForChild('PlayerGui')
local DrakenImage = Interface:WaitForChild('Templates').DrakenImage :: ImageLabel
local InventoryWidget = Interface:WaitForChild('Inventory') :: ScreenGui
local LockerWidget = Interface:WaitForChild('Locker') :: ScreenGui
local Templates = InventoryWidget.Templates :: Folder

local SystemsContainer = {}
local OverlayControllerModule = {}

-- // Module // --
local Module = {}

Module.OverlayTrove = Trove.new()
Module.Open = false

function Module.UpdateOverlay()

end

function Module.GenerateTitleText(expandType : string, nextGuiTier : number)
    local firstLetter = string.sub(expandType, 1, 1):upper()
    local restOfWord = string.sub(expandType, 2)

    return firstLetter .. restOfWord .. " Tier " .. nextGuiTier - 1
end

function Module.GenerateBodyText(expandType : string, slotNumIncrease : number)
    return "Increases your " .. expandType .. " by " .. slotNumIncrease .. " spaces."
end

function Module.GenerateValueText(priceToDisplay : number)
    return "Price: " .. priceToDisplay
end

function Module.DisplayExpandGuiOverlay(expandType : string, priceToDisplay : number, slotNumIncrease : number, nextGuiTier : number, position : UDim2)
    local ExpandGuiFrameClone = Templates.ExpandGuiToolTipTemplateHolder:Clone() :: Frame
    ExpandGuiFrameClone.Name = "ExpandGuiToolTip"
    ExpandGuiFrameClone.Position = position

    local titleText = Module.GenerateTitleText(expandType, nextGuiTier)
    local bodyText = Module.GenerateBodyText(expandType, slotNumIncrease)
    local valueText = Module.GenerateValueText(priceToDisplay)

    ExpandGuiFrameClone.TitleText.Text = titleText
    ExpandGuiFrameClone.BodyText.Text = bodyText
    ExpandGuiFrameClone.ValueText.Text = valueText


    if expandType == "inventory" then
        local OverlaysFolder = Instance.new("Folder")
        Module.OverlayTrove:Add(OverlaysFolder)
        OverlaysFolder.Name = "Overlays"
        OverlaysFolder.Parent = InventoryWidget.InventoryBase.InventorySlots
        ExpandGuiFrameClone.Parent = InventoryWidget.InventoryBase.InventorySlots.Overlays
    else
        ExpandGuiFrameClone.Parent = LockerWidget
    end

    ExpandGuiFrameClone.Visible = true
    Module.OverlayTrove:Add(ExpandGuiFrameClone)
end

function Module.OpenOverlay(...)
    if Module.Open then
        return
    end

    local args = {...}

    local nextGuiTier = args[2] + 1
    local position = args[3]
    local priceToDisplay
    local slotNumIncrease

    if args[1] == "inventory" then
        priceToDisplay = tonumber(InventoryData.GetInventoryTierPrice(nextGuiTier))
        slotNumIncrease = tonumber(InventoryData.GetInventorySlotsPerTier(nextGuiTier) - InventoryData.GetInventorySlotsPerTier(args[2]))

        Module.DisplayExpandGuiOverlay("inventory", priceToDisplay, slotNumIncrease, nextGuiTier, position)
    else
        priceToDisplay = tonumber(LockerData.GetPriceToExpandLocker(nextGuiTier))
        slotNumIncrease = tonumber(LockerData.GetLockerSlotsPerTier(nextGuiTier) - LockerData.GetLockerSlotsPerTier(args[2]))

        Module.DisplayExpandGuiOverlay("locker", priceToDisplay, slotNumIncrease, nextGuiTier, position)
    end
    
    Module.Open = true
end

function Module.CloseOverlay()
    if not Module.Open then
        return
    end
    
    Module.Open = false
    Module.OverlayTrove:Destroy()
end

function Module.Start()
end

function Module.Init(ParentController, otherSystems)
    OverlayControllerModule = ParentController
    SystemsContainer = otherSystems
end

return Module
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


local Overlays = Interface:WaitForChild('Overlays') :: ScreenGui
local Templates = Overlays:WaitForChild('Templates') :: Folder

local ExpandGuiToolTipTemplate = Templates.ExpandGuiToolTipTemplate :: Frame

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

function Module.DisplayExpandGuiOverlay(location, priceToDisplay, slotNumIncrease, nextGuiTier, absolutePosition)

    local absolutePositionX = absolutePosition[1]
    local absolutePositionY = absolutePosition[2]

    local ExpandGuiFrameClone = ExpandGuiToolTipTemplate:Clone() :: Frame

    ExpandGuiFrameClone.Name = "ExpandGuiToolTip"
    ExpandGuiFrameClone.Parent = Overlays
    ExpandGuiFrameClone.Position = UDim2.new(0, absolutePositionX, 0, absolutePositionY)


    local titleText = Module.GenerateTitleText(location, nextGuiTier)
    local bodyText = Module.GenerateBodyText(location, slotNumIncrease)
    local valueText = Module.GenerateValueText(priceToDisplay)

    ExpandGuiFrameClone.TitleText.Text = titleText
    ExpandGuiFrameClone.BodyText.Text = bodyText
    ExpandGuiFrameClone.ValueText.Text = valueText

    -- Display the draken image next to the value text
    local DrakenImageClone = DrakenImage:Clone() :: ImageLabel
    DrakenImageClone.Position = UDim2.new(0, ExpandGuiFrameClone.ValueText.TextBounds.X + 5, 0, 0)
    DrakenImageClone.Visible = true
    DrakenImageClone.Parent = ExpandGuiFrameClone.ValueText

    ExpandGuiFrameClone.Visible = true
    Module.OverlayTrove:Add(ExpandGuiFrameClone)
end

function Module.OpenOverlay(...)
    if Module.Open then
        return
    end

    local args = {...}

    local location = args[1]
    local nextGuiTier = args[2]
    local specificData = args[3]
    local absolutePosition = args[4]

    local priceToDisplay
    local slotNumIncrease


    priceToDisplay = tonumber(specificData.GetTierPrice(nextGuiTier))
    slotNumIncrease = tonumber(specificData.GetSlotsPerTier(nextGuiTier) - specificData.GetSlotsPerTier(nextGuiTier - 1))

    Module.DisplayExpandGuiOverlay(location, priceToDisplay, slotNumIncrease, nextGuiTier, absolutePosition)

    Module.Open = true

    Overlays.Enabled = true
end

function Module.CloseOverlay()
    if not Module.Open then
        return
    end

    Module.Open = false
    Overlays.Enabled = false
    Module.OverlayTrove:Destroy()
end

function Module.Start()
end

function Module.Init(ParentController, otherSystems)
    OverlayControllerModule = ParentController
    SystemsContainer = otherSystems
end

return Module
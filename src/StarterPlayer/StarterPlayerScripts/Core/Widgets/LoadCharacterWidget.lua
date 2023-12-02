local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local Trove = ReplicatedModules.Classes.Trove

local Interface = LocalPlayer:WaitForChild('PlayerGui')
local LoadCharacterWidget = Interface:WaitForChild('SelectProfile') :: ScreenGui

local SystemsContainer = {}
local WidgetControllerModule = {}

local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)
local getAllProfileData = BridgeNet2.ClientBridge("getAllProfileData")
local wipeAllData = BridgeNet2.ClientBridge("wipeAllData")
local playCharacter = BridgeNet2.ClientBridge("playCharacter")

local ProfileCache = {}

local ProfileNumClicked = 1
local ProfileNameClicked = ""


----- Replica Data -----

-- local ReplicaTestClient = {

-- }

-- local ReplicaController = require(game:GetService("ReplicatedStorage"):WaitForChild("Core"):WaitForChild("ReplicaController"):WaitForChild("ReplicaController"))


-------------------------

-- // Module // --
local Module = {}

Module.WidgetTrove = Trove.new()
Module.Open = false

function Module:UpdateWidget()
    if #ProfileCache[LocalPlayer.UserId] == 0 then
        Module:CloseWidget()
        WidgetControllerModule:ToggleWidget("CharacterCreationWidget", true, true)
        return false
    else
        Module:LoadWidget()
        return true
    end
end

function Module:LoadWidget()
    Module:DisplayCharacterSlots()

    Module.WidgetTrove:Add(LoadCharacterWidget.PlayButton.Activated:Connect(function()
        Module:PlayProfile()
    end))

    Module.WidgetTrove:Add(LoadCharacterWidget.CreateButton.Activated:Connect(function()
        Module:CreateProfile()
    end))

    Module.WidgetTrove:Add(LoadCharacterWidget.WipeDataBtn.Activated:Connect(function()
        Module:WipeData()
    end))

    if #ProfileCache[LocalPlayer.UserId] == 4 then
        LoadCharacterWidget.CreateButton.Visible = false
    end

    -- Click the first profile
    Module:ProfileClicked(LoadCharacterWidget.CurrentCharacters.CharacterContainer:FindFirstChild("CharSlot_1"), true)

    LoadCharacterWidget.CharacterNameHolder.CharacterName.Text = ProfileNameClicked
end

function Module:PlayProfile()
    if ProfileNameClicked == "" then
        return
    end

    playCharacter:Fire(ProfileNumClicked)
    Module:CloseWidget()
end

function Module:CreateProfile()
    Module:CloseWidget()
    WidgetControllerModule:ToggleWidget("CharacterCreationWidget", true, false)
end

function Module:WipeData()
    wipeAllData:Fire()
end

function Module:ProfileClicked(profileButton : TextButton, firstTime : boolean)

    -- If the profile is already clicked, don't do anything, unless it's the first time
    if tonumber(profileButton.Name:match("%d+")) == ProfileNumClicked and not firstTime then
        return
    end

    local function unClickOtherClasses()
        local otherClasses = LoadCharacterWidget.CurrentCharacters.CharacterContainer:GetChildren()
        for _,element in ipairs(otherClasses) do
            if element:IsA("TextButton") then
                element.BackgroundTransparency = 0
                element.BorderSizePixel = 0
            end
        end
    end

    unClickOtherClasses()

	profileButton.BackgroundTransparency = 0.3
    profileButton.BorderSizePixel = 3

    ProfileNumClicked = tonumber(profileButton.Name:match("%d+"))
    ProfileNameClicked = profileButton.CharName.Text

    LoadCharacterWidget.CharacterNameHolder.CharacterName.Text = ProfileNameClicked
end

function Module:HoveringOverProfile(profileButton : TextButton, entering : boolean)
    if tonumber(profileButton.Name:match("%d+")) == ProfileNumClicked then
        return
    elseif entering then
        profileButton.BackgroundTransparency = 0.6
    else
        profileButton.BackgroundTransparency = 0
    end
end

function Module:DisplayCharacterSlots()
    for profileNum, profileData in ipairs(ProfileCache[LocalPlayer.UserId]) do
        local CharSlotClone = LoadCharacterWidget.CurrentCharacters.CharacterContainer.CharSlotTemplate:Clone()
       
        CharSlotClone.Name = "CharSlot_" .. profileNum
        CharSlotClone.Visible = true

        -- Add the data to the character slot

        CharSlotClone.CharName.Text = profileData.CharacterName
        CharSlotClone.CharClass.Text = profileData.ClassType
        CharSlotClone.CharLevel.Text = profileData.CharacterLevel
        if profileData.LastUrbanArea == "" then
            CharSlotClone.CharArea.Text = "Starfall Bastion"
        else
            CharSlotClone.CharArea.Text = profileData.LastUrbanArea
        end

        -- Add the connections to check hovering and clicked
        Module.WidgetTrove:Add(CharSlotClone.Activated:Connect(function()
            Module:ProfileClicked(CharSlotClone, false)
        end))

        Module.WidgetTrove:Add(CharSlotClone.MouseEnter:Connect(function()
            Module:HoveringOverProfile(CharSlotClone, true)
        end))

        Module.WidgetTrove:Add(CharSlotClone.MouseLeave:Connect(function()
            Module:HoveringOverProfile(CharSlotClone, false)
        end))

        CharSlotClone.Parent = LoadCharacterWidget.CurrentCharacters.CharacterContainer
    end


end

function Module:OpenWidget()
    if Module.Open then
        return
    end
    
    Module.Open = true

    ProfileNumClicked = 1
    ProfileNameClicked = ""

    if Module:UpdateWidget() then
        LoadCharacterWidget.Enabled = true
        return
    end
end


function Module:CloseWidget()
    if not Module.Open then
        return
    end
    
    Module.Open = false

    -- Clear the character slots
    for _, CharSlot in ipairs(LoadCharacterWidget.CurrentCharacters.CharacterContainer:GetChildren()) do
        if CharSlot:IsA("TextButton") and not (CharSlot.Name == "CharSlotTemplate") then
            CharSlot:Destroy()
        end
    end

    LoadCharacterWidget.Enabled = false
    Module.WidgetTrove:Destroy()
end


function Module:Start()

    Module.WidgetTrove:Add(getAllProfileData:Connect(function(playerData)
        ProfileCache[LocalPlayer.UserId] = playerData
        -- print(ProfileCache[LocalPlayer.UserId], #ProfileCache[LocalPlayer.UserId])
        Module:OpenWidget()
    end))





    -- ReplicaController.ReplicaOfClassCreated("PlayerProfile_" .. LocalPlayer.UserId, function(replica)
    --     local is_local = replica.Tags.Player == LocalPlayer

    --     if not is_local then return end
        
    --     local replica_data = replica.Data
    
    --     print(replica_data)
    -- end)
end

function Module:Init(ParentController, otherSystems)
    WidgetControllerModule = ParentController
    SystemsContainer = otherSystems
end

return Module
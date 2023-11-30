local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local Trove = ReplicatedModules.Classes.Trove

local Interface = LocalPlayer:WaitForChild('PlayerGui')
local LoadCharacterWidget = Interface:WaitForChild('LoadCharacter') :: ScreenGui

local SystemsContainer = {}
local WidgetControllerModule = {}

local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)
local getAllProfileData = BridgeNet2.ClientBridge("getAllProfileData")

local ProfileCache = {}

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
        Module:DisplayCharacterSlots()
        return true
    end
end

function Module:DisplayCharacterSlots()
    -- Print the player data of all the profiles
    for _, profileData in ipairs(ProfileCache[LocalPlayer.UserId]) do
        print("Profile Num " .. _ .. " ", profileData)
    end
end

function Module:OpenWidget()
    if Module.Open then
        return
    end
    
    Module.Open = true

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
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local Trove = ReplicatedModules.Classes.Trove

local Interface = LocalPlayer:WaitForChild('PlayerGui')
local LoadCharacterWidget = Interface:WaitForChild('LoadCharacter')

local SystemsContainer = {}
local WidgetControllerModule = {}

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
    
end

function Module:LoadCharacterSlots()
end

function Module:OpenWidget()
    if Module.Open then
        return
    end
    
    Module.Open = true
    LoadCharacterWidget.Enabled = true
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
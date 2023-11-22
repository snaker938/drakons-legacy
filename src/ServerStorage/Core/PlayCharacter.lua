local ServerStorage = game:GetService('ServerStorage')
local ServerModules = require(ServerStorage:WaitForChild("Modules"))

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))
local Red = ReplicatedModules.Services.Red

local Net = Red.Server("RemoteSpace")

local Players = game:GetService("Players")

local DataStoreModule = ServerModules.Services.DataStore

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module:Start()

end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
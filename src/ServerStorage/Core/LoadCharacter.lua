local ServerStorage = game:GetService('ServerStorage')
local ServerModules = require(ServerStorage:WaitForChild("Modules"))
local DataStoreModule = ServerModules.Services.DataStore

local Packages = game:GetService("ReplicatedStorage").Packages
local Red = require(Packages.Red)

-- local Net = Red.Server("RemoteSpace")


local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module:Start()

end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
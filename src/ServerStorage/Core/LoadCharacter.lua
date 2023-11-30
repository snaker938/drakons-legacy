local ServerStorage = game:GetService('ServerStorage')
local ServerModules = require(ServerStorage:WaitForChild("Modules"))
local DataStoreModule = ServerModules.Services.DataStore

local Packages = game:GetService("ReplicatedStorage").Packages



local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module:Start()
	-- print(SystemsContainer)
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
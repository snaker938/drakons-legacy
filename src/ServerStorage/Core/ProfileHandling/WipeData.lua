local ServerStorage = game:GetService('ServerStorage')
local ServerModules = require(ServerStorage:WaitForChild("Modules"))

local Packages = game:GetService("ReplicatedStorage").Packages
local Red = require(Packages.Red)

-- local Net = Red.Server("RemoteSpace")

local Players = game:GetService("Players")

local DataStoreModule = ServerModules.Services.DataStore

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module:WipePlayerData(localPlayer)
	local GlobalData = DataStoreModule.find("Player", localPlayer.UserId, "GlobalData")
	if GlobalData == nil then return false end
	if GlobalData.State ~= true then return false end
	GlobalData.Value = SystemsContainer.ProfileHandling:_GetDataTemplate("Global")

	GlobalData:Save()

	for i = 1, 4 do
		local profileData = DataStoreModule.find("Player", localPlayer.UserId, "Profile_" .. i)
		if profileData == nil then return false end
		if profileData.State ~= true then return false end

		profileData.Value = SystemsContainer.ProfileHandling:_GetDataTemplate("Profile")

		profileData:Save()
	end
end

function Module:Start()
	-- Net:On("WipePlayerData", function(localPlayer)
	-- 	Module:WipePlayerData(localPlayer)
	-- end)
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
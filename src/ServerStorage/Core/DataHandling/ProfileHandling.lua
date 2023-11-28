local ServerStorage = game:GetService('ServerStorage')
local ServerModules = require(ServerStorage:WaitForChild("Modules"))
local DataStoreModule = ServerModules.Services.DataStore

local SystemsContainer = {}

-- // Module // --
local Module = {}


function Module:GetCurrentUserData(localPlayer : Player, type : string)
    type = type or "both"

    local GlobalData = DataStoreModule.find("Player", localPlayer.UserId, "GlobalData")
    local ProfileData = DataStoreModule.find("Player", localPlayer.UserId, "Profile_" .. GlobalData.Value.CurrentlyPlayingProfile)

    if GlobalData == nil or ProfileData == nil or GlobalData.State ~= true or ProfileData.State ~= true or not ProfileData.Value.CurrentlyPlaying then
        localPlayer:Kick("Error Getting User Data")
    end
    
    if type == "global" then
        return GlobalData
    elseif type == "player" then
        return ProfileData
    else
        return ProfileData, GlobalData
    end
end

function Module:GetSpecificProfileData(localPlayer : Player, profileNum)
    if tonumber(profileNum) == nil then localPlayer:Kick("Critical Error Getting Player Data") end
    profileNum = tonumber(profileNum)
    if profileNum < 1 or profileNum > 4 then
        error("Trying to get invalid profile")
        localPlayer:Kick("Critical Error Getting Player Data")
        return
    end

    local ProfileData = DataStoreModule.find("Player", localPlayer.UserId, "Profile_" .. profileNum)
    if ProfileData == nil or ProfileData.State ~= true then
        localPlayer:Kick("Error Getting User Data")
    end
    return ProfileData
end


function Module:Start()
    
end

function Module:Init(otherSystems)
    SystemsContainer = otherSystems
end

return Module
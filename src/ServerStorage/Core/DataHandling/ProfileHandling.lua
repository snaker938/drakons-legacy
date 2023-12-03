local ServerStorage = game:GetService('ServerStorage')
local ServerModules = require(ServerStorage:WaitForChild("Modules"))
local DataStoreModule = ServerModules.Services.DataStore
local TableModule = ServerModules.Utility.Table
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SystemsContainer = {}

local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)
local getAllProfileData = BridgeNet2.ServerBridge("getAllProfileData")

-- // Module // --
local Module = {}


function Module.GetCurrentUserData(localPlayer : Player, type : string)
    type = type or "both"

    local GlobalData = DataStoreModule.find("Player", localPlayer.UserId, "GlobalData")

    if GlobalData == nil or GlobalData.State ~= true then
        localPlayer:Kick("Error Getting User Data")
    end

    if type == "global" then
        return GlobalData
    end

    if GlobalData.Value.CurrentlyPlayingProfile == -1 then
        localPlayer:Kick("Critical Error Getting Player Data (GetCurrentData)")
    end

    local ProfileData = DataStoreModule.find("Player", localPlayer.UserId, "Profile_" .. GlobalData.Value.CurrentlyPlayingProfile)

    if ProfileData == nil or ProfileData.State ~= true then
        localPlayer:Kick("Error Getting User Data (GetCurrentData)")
    end
    
    
    if type == "player" then
        return ProfileData
    else
        return ProfileData, GlobalData
    end
end


function Module.GetSpecificProfileData(localPlayer : Player, profileNum)
    if tonumber(profileNum) == nil then localPlayer:Kick("Critical Error Getting Player Data") end
    profileNum = tonumber(profileNum)

    if profileNum < 1 or profileNum > 4 then
        print("Trying to get invalid profile")
        localPlayer:Kick("Critical Error Getting Player Data")
        return
    end

    local ProfileData = DataStoreModule.find("Player", localPlayer.UserId, "Profile_" .. profileNum)
    if ProfileData == nil or ProfileData.State ~= true then
        localPlayer:Kick("Error Getting User Data")
    end
    return ProfileData
end

function Module.SendLoadProfileDataToClient(localPlayer)
    -- Only things needed currently: CharacterName, ClassType, LastUrbanArea, CharacterLevel
    local allProfileData = {}

    local profileIndex = 0

    for i = 1, 4 do
        -- Retrieve the specific profile data and store it in the table
        local profileData = Module.GetSpecificProfileData(localPlayer, i).Value

        if profileData.CharacterName == "" then
            continue
        else
            profileIndex = profileIndex + 1
        end

        local usefulData = {}
        usefulData.CharacterName = profileData.CharacterName
        usefulData.ClassType = profileData.ClassType
        usefulData.LastUrbanArea = profileData.LastUrbanArea
        usefulData.CharacterLevel = profileData.CharacterLevel
        
        allProfileData[profileIndex] = TableModule.DeepCopy(usefulData)
    end

    getAllProfileData:Fire(localPlayer, allProfileData)
end



function Module.Start()

end

function Module.Init(otherSystems)
    SystemsContainer = otherSystems
end

return Module
local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.AddDraken(localPlayer : Player, amountToAdd : number)

end

function Module.RemoveDraken(localPlayer : Player, amountToRemove : number)
    -- Get the player's current draken amount
    -- local DrakenAmount = getDraken(localPlayer)
    --
    if amountToRemove > 10 then
		-- Open Shop To Draken Page

        --
		return false
	else
		-- DataStore.Value.Draken -= amountToDeduct
		-- if DataStore:Save() == "Saved" then
		-- 	return true
		-- end
	end
	return false
end

function Module.Start()
    
end

function Module.Init(otherSystems)
    SystemsContainer = otherSystems
end

return Module
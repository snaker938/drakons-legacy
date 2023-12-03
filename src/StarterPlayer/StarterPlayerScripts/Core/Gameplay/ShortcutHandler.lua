local UserInputService = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local CAS = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer


local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.DisableDefaultKeybinds()
    CAS:BindActionAtPriority("DisableI", function()
        return Enum.ContextActionResult.Sink
    end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.I)

    CAS:BindActionAtPriority("DisableL", function()
        return Enum.ContextActionResult.Sink
    end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.L)
end

function Module.InputBegan(input, _gameProcessed)

    -- Nothing should happen if the LoadCharacterWidget or CharacterCreationWidget is open
    if SystemsContainer.ParentSystems.Widgets.IsWidgetOpen("LoadCharacterWidget") or SystemsContainer.ParentSystems.Widgets.IsWidgetOpen("CharacterCreationWidget") then
        return
    end

    if input.KeyCode == Enum.KeyCode.I then
		print("Open Inventory!")
	
		-- Fire Server
	
	elseif input.KeyCode == Enum.KeyCode.L then
        print("Open Locker!")
        
		-- Fire Server
	end
end

function Module.Start()
    Module.DisableDefaultKeybinds()

    UserInputService.InputBegan:Connect(function(input, _gameProcessed)
        Module.InputBegan(input, _gameProcessed)
    end)
end

function Module.Init(otherSystems)
    SystemsContainer = otherSystems
end

return Module
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local Trove = ReplicatedModules.Classes.Trove


local Interface = LocalPlayer:WaitForChild('PlayerGui')
local CreateCharacterWidget = Interface:WaitForChild('CharacterCreation') :: ScreenGui

local BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)
local createCharacter = BridgeNet2.ClientBridge("createCharacter")

local classTypeClicked = "Battlelord"

local isErrored = false

local SystemsContainer = {}
local WidgetControllerModule = {}

-- // Module // --
local Module = {}

Module.WidgetTrove = Trove.new()
Module.Open = false

function Module:UpdateWidget(noCharacters)
    if noCharacters then
        CreateCharacterWidget.BackButton.Visible = false
    end

    Module:ClassTypeButtonClicked(CreateCharacterWidget.ClassTypes:FindFirstChild(classTypeClicked))
end

function Module:OpenWidget(...)
    if Module.Open then
        return
    end

    classTypeClicked = "Battlelord"
    isErrored = false

    local ClassTypesFrame = CreateCharacterWidget.ClassTypes :: Frame
    local ClassTypeButtons = ClassTypesFrame:GetChildren()

    for _, ClassTypeButton in ipairs(ClassTypeButtons) do
        if ClassTypeButton:IsA("ImageButton") then
            Module.WidgetTrove:Add(ClassTypeButton.Activated:Connect(function()
                Module:ClassTypeButtonClicked(ClassTypeButton)
            end))

            Module.WidgetTrove:Add(ClassTypeButton.MouseEnter:Connect(function()
                Module:HoveringOverClassTypeButton(ClassTypeButton, true)
            end))

            Module.WidgetTrove:Add(ClassTypeButton.MouseLeave:Connect(function()
                Module:HoveringOverClassTypeButton(ClassTypeButton, false)
            end))
        end
    end

    local CreateButton = CreateCharacterWidget.Description.CreateButton :: ImageButton
    Module.WidgetTrove:Add(CreateButton.Activated:Connect(function()
        if isErrored then
            return
        end
        Module:CreateCharacter()
    end))

    -- On focus, if the text is red, change it back to white and clear the text
    local EnterNameInputBox = CreateCharacterWidget.UsernameInputImage.UsernameInputBox :: TextBox
    Module.WidgetTrove:Add(EnterNameInputBox.Focused:Connect(function()
        if EnterNameInputBox.TextColor3 == Color3.fromRGB(255, 0, 0) then
            EnterNameInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            EnterNameInputBox.Text = ""
            isErrored = false
        end
    end))

    local args = {...}
    local noCharacters = args[1]

    Module.Open = true

    Module:UpdateWidget(noCharacters)

    CreateCharacterWidget.Enabled = true
end

function Module:CloseWidget()
    if not Module.Open then
        return
    end

    Module.Open = false
    CreateCharacterWidget.Enabled = false
    Module.WidgetTrove:Destroy()
end

function Module:CreateCharacter()
    local characterName = CreateCharacterWidget.UsernameInputImage.UsernameInputBox.Text
    local result = createCharacter:InvokeServerAsync({characterName, classTypeClicked})
    local success, errorText = result[1] :: boolean, result[2] :: string

    if not success then
        -- Change the colour of the text of the input box to red and display the error text
        CreateCharacterWidget.UsernameInputImage.UsernameInputBox.TextColor3 = Color3.fromRGB(255, 0, 0)
        CreateCharacterWidget.UsernameInputImage.UsernameInputBox.Text = errorText
        isErrored = true
    else
        print("Closig widget")
        Module:CloseWidget()
    end
end

function Module:ClassTypeButtonClicked(classTypeButton : ImageButton)
    local function unClickOtherClasses()
        local otherClasses = CreateCharacterWidget.ClassTypes:GetChildren()
        for _,element in ipairs(otherClasses) do
            if element:IsA("ImageButton") then
                element.ImageTransparency = 0
            end
        end
    end

    unClickOtherClasses()

	classTypeButton.ImageTransparency = 0.3

    classTypeClicked = classTypeButton.Name
end

function Module:HoveringOverClassTypeButton(classTypeButton : ImageButton, entering : boolean)
    if classTypeClicked == classTypeButton.Name then
        return
    elseif entering then
        classTypeButton.ImageTransparency = 0.2
    else
        classTypeButton.ImageTransparency = 0
    end
end

function Module:Start()
    
end

function Module:Init(ParentController, otherSystems)
    WidgetControllerModule = ParentController
    SystemsContainer = otherSystems
end

return Module
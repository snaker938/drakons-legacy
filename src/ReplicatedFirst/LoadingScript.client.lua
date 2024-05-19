--------------------------------------------- Require Modules --------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService('ReplicatedStorage')
require(ReplicatedStorage:WaitForChild('Modules'))
require(ReplicatedStorage:WaitForChild('Core'))
local LocalPlayer = game:GetService('Players').LocalPlayer
require(LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Modules'))
require(LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Core'))

local Data = require(ReplicatedStorage:WaitForChild('Framework'))
Data.Start()

---------------------------------------------- Loading Bar ---------------------------------------------------------------------
-- SERVICES --
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- VARIABLES --
local assets = game:GetDescendants()

-- local cloneGui = script:WaitForChild("LoadingGUI"):Clone()
-- cloneGui.Parent = Players.LocalPlayer.PlayerGui

local camera = workspace.CurrentCamera
local cameraPart = workspace:WaitForChild("CameraPart")
camera.CameraType = Enum.CameraType.Scriptable
camera.CFrame = cameraPart.CFrame


-- CONSTANTS --
local LOADING_STRING = "Loading: "

-- MAIN --

local function resizeCustomLoadingBar(sizeRatio, clipping, top)
	clipping.Size = UDim2.new(sizeRatio, clipping.Size.X.Offset, clipping.Size.Y.Scale, clipping.Size.Y.Offset)
	top.Size = UDim2.new((sizeRatio > 0 and 1 / sizeRatio) or 0, top.Size.X.Offset, top.Size.Y.Scale, top.Size.Y.Offset) -- Extra check in place just to avoid doing 1 / 0 (which is undefined)
end



-- for i,asset in ipairs(assets) do
-- 	ContentProvider:PreloadAsync({asset})
-- 	local xScale = i/#assets
	-- resizeCustomLoadingBar(xScale, cloneGui.Frame.ImageBase.Clipping, cloneGui.Frame.ImageBase.Clipping.Top)
	-- --cloneGui.Frame.LoadingBarOutline.LoadingBar.Size = UDim2.new(xScale,0,cloneGui.Frame.LoadingBarOutline.LoadingBar.Size.Y.Scale,0)
-- 	cloneGui.Frame.AssetNameLabel.Text = LOADING_STRING..asset.Name
-- 	if i == #assets then
-- 		local camera = workspace.CurrentCamera
-- 		local cameraPart = workspace:WaitForChild("CameraPart")
-- 		camera.CameraType = Enum.CameraType.Scriptable

-- 		camera.CFrame = cameraPart.CFrame

-- 		task.wait(1.3)
		
-- 		cloneGui.Frame.ImageBase:Destroy()
		
-- 		for _,element in ipairs(cloneGui:GetDescendants()) do
-- 			if element:IsA("Frame") then
-- 				TweenService:Create(element, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
-- 			elseif element:IsA("TextLabel") then
-- 				TweenService:Create(element, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
-- 			elseif element:IsA("UIStroke") then
-- 				TweenService:Create(element, TweenInfo.new(0.5), {Transparency = 1}):Play()
-- 			end
-- 		end
-- 		task.wait(0.5)


-- 		cloneGui:Destroy()


-- 		script:Destroy()
-- 	-- elseif i % 250 == 0 then
-- 	-- 	task.wait()
-- 	-- end
-- 	end
-- end



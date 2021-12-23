--[[
Version: 1.1.9
Changelog:

-- Internal code rewrite
-- Added module.move for 1.2.0 update

Credits:

-- GGshor


TweenModel.new(): Tween
------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------

The simple way of using this TweenModel.
Only needs a primarypart and everything needs to be anchored

Example:

local TweenModel = require(6019253834) -- Get the module. Use id to get most updated version!

local Tween = TweenModel.new( -- Creates a new tween
	script.Parent.Door, -- Which model should be moved. (SET THE PRIMARYPART, to something in the middle or something)
	TweenInfo.new(
		5, -- Amount of seconds it take. (Default = 1)
		Enum.EasingStyle.Linear, -- Style of tween. (Default = TweenModel.TypeStyles.Quad)
		Enum.EasingDirection.Out, -- Type of direction. (Default = TweenModel.TypeDirections.Out)
		0, -- How many times should it repeat. (Default = 0)
		false, -- -- Should it go back. (Default = false)
		0 -- Amount of seconds it will wait before playing the tween again. (Default = 0)
	),
	script.Parent.Goal.CFrame -- Where should the model move to. (Should be a dupe of the PrimaryPart and out of the model you are moving, so it doesn't move incorrect)
)

Tween:Play() -- Plays the tween.

------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------


TweenModel:PlayInstant(): Tween
------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------

If you need to play the tween immediatly use TweenModel:PlayInstant()

Example:

local TweenModel = require(6019253834) -- Get the module. Use id to get most updated version!

TweenModel:PlayInstant( -- Creates a new tween
	script.Parent.Door, -- Which model should be moved. (SET THE PRIMARYPART, to something in the middle or something)
	TweenInfo.new(
		5, -- Amount of seconds it take. (Default = 1)
		Enum.EasingStyle.Linear, -- Style of tween. (Default = TweenModel.TypeStyles.Quad)
		Enum.EasingDirection.Out, -- Type of direction. (Default = TweenModel.TypeDirections.Out)
		0, -- How many times should it repeat. (Default = 0)
		false, -- -- Should it go back. (Default = false)
		0 -- Amount of seconds it will wait before playing the tween again. (Default = 0)
	),
	script.Parent.Goal.CFrame -- Where should the model move to. (Should be a dupe of the PrimaryPart and out of the model you are moving, so it doesn't move incorrect)
)

You don't have to call Tween:Play() anymore.

Will still return the tween object if needed

------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------


TweenModel.move(): boolean
------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------

Moves a model in a instant to given target.

Example:

local TweenModel = require(6019253834) -- Get the module. Use id to get most updated version!

local moved = TweenModel.move(
	Model, -- Which model should be moved (SET THE PRIMARYPART TO A PART IN THE MIDDLE)
	Goal -- Where model should move to (Should be a duplicate of your PRIMARYPART)
)

Returns boolean if the model moved with no problems

------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------
--]]


--// Services
local TweenService = game:GetService("TweenService")
local MarketPlaceService = game:GetService("MarketplaceService")


--// Constants
local TweenModel = {}
local ModuleVersion = "1.1.9"
local ExpectGot = "%s expected, got %s"
local Outdated = "Module outdated, newest version is %s! Please import the new version from the Toolbox!"
local OutputPrefix = " { Tween-Model } --"


--// Custom types
export type Target = CFrame | Instance


--// Local functions
local function CustomWarn(...: string)
	warn(OutputPrefix, ...)
end

local function CustomPrint(...: string)
	print(OutputPrefix, ...)
end

local function CheckVersion()
	local info = MarketPlaceService:GetProductInfo(6019253834, Enum.InfoType.Asset)
	local description: string = info.Description

	local latest = description:split(" ")[3]:gsub("%s", ""):gsub("Tweens", "")
	if latest ~= ModuleVersion then
		warn(Outdated:format(latest))
	end
end


--// Public Functions
function TweenModel.move(model: Model, target: CFrame | Instance): boolean
	local isModel, _  = pcall(function()
		if model.PrimaryPart then
			return true

		else
			return false
		end
	end)

	local hasCFrame, goal = pcall(function()
		if typeof(target) == "CFrame" then
			return target

		elseif target.CFrame then
			return target.CFrame

		else
			return false
		end
	end)

	if isModel == false then
		warn(ExpectGot:format("Model", typeof(model)))
		return false
	end

	if hasCFrame == false then
		warn(ExpectGot:format("CFrame/Instance", typeof(target)))
		return false
	end
	
	model:SetPrimaryPartCFrame(goal)
	
	return true
end


function TweenModel.new(Model: Model, Info: TweenInfo, Goal: Instance|CFrame): Tween
	local IsModel, _  = pcall(function()
		if Model.PrimaryPart then
			return true
			
		else
			return false
		end
	end)

	local IsCFrame, CheckedCFrame = pcall(function()
		if typeof(Goal) == "CFrame" then
			return Goal

		elseif Goal.CFrame then
			return Goal.CFrame
			
		else
			return false
		end
	end)

	if IsModel == false then
		warn(ExpectGot:format("Model",typeof(Model)))
		return
	end

	if IsCFrame == false then
		warn(ExpectGot:format("CFrame/Instance",typeof(Goal)))
		return
	end

	if typeof(Info) ~= "TweenInfo" then
		warn(ExpectGot:format("TweenInfo",typeof(Info)))
		return
	end

	local CF = Instance.new("CFrameValue")
	CF.Value = Model:GetPrimaryPartCFrame()
	CF.Changed:Connect(function()
		Model:SetPrimaryPartCFrame(CF.Value)
	end)

	local CreatedTween = TweenService:Create(CF,Info,{Value = CheckedCFrame})

	return CreatedTween
end

function TweenModel:Play()
	error(" { Tween-Model Module } -- Deprecated method of using TweenModel module detected, please update your code!",0)
end

function TweenModel:PlayInstant(Model,Goal,Duration,Style,Direction,Repeat,Reverses,Delay): Tween
	if typeof(Goal) ~= "TweenInfo" then -- If goal isn't using the new way then use deprecated method
		if Duration == nil then
			Duration = 1
		end
		if Style == nil then
			Style = Enum.EasingStyle.Quad
		end
		if Direction == nil then
			Direction = Enum.EasingDirection.Out
		end
		if Repeat == nil then
			Repeat = 0
		end
		if Reverses == nil then
			Reverses = false
		end
		if Delay == nil then
			Delay = 0
		end

		local info = TweenInfo.new(Duration,Style,Direction,Repeat,Reverses,Delay)
		
		
		local createdTween: Tween = TweenModel.new(Model, info, Goal.CFrame)
		
		createdTween:Play()
		
		return createdTween

	else -- Is using the new way
		local IsCFrame, CheckedCFrame = pcall(function()
			if typeof(Duration) == "CFrame" then
				return Duration
			else
				if Duration.CFrame then
					return Duration.CFrame
				end
			end
		end)
		
		local createdTween: Tween = TweenModel.new(Model,Goal,CheckedCFrame)

		createdTween:Play()

		return createdTween
	end
end


warn("Module loaded! Current version:", ModuleVersion)

task.spawn(CheckVersion)


return TweenModel

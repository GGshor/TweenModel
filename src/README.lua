--[[
Version: 2.0.0
Changelog:

-- All CFrame calculations are now done on client.

Credits:

-- GGshor


NOTE: This module tweens models on client instead of server! When testing in studio make sure to use Play!


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

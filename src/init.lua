--[[
	Main module for tweening models on client.

	@GGshor
]]

--// Services
local TweenService = game:GetService("TweenService")
local MarketPlaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

--// Constants
local TweenModel = {}
local ModuleVersion = "2.0.2"
local OutputPrefix = "[TweenModel]:"
local TweenModelSetup = script:WaitForChild("TweenModelSetup")
local ClientReference = TweenModelSetup:WaitForChild("MainModuleReference") :: ObjectValue
local TweenEvent = script:WaitForChild("TweenEvent") :: RemoteEvent

--// Custom types
export type Target = CFrame | BasePart
export type TweenTable = {
	EasingDirection: Enum.EasingDirection,
	Time: number,
	DelayTime: number,
	RepeatCount: number,
	EasingStyle: Enum.EasingStyle,
	Reverses: boolean,
}
export type TweenData = {
	Id: string,
	State: Enum.PlaybackState,
	OriginalCFrame: CFrame,
	TargetCFrame: CFrame,
	Info: TweenTable,
	Model: Model,
	Tween: Tween?,
	Destroying: boolean,
	CFrameInstance: CFrameValue,
}

--// Variables
local activeTweens = {} :: { [Instance]: TweenData }

--// Local functions

--[=[
	Checks the version
]=]
local function CheckVersion(): ()
	local info = MarketPlaceService:GetProductInfo(6019253834, Enum.InfoType.Asset)
	local description: string = info.Description

	local latest = description:split(" ")[3]:gsub("%s", ""):gsub("Tweens", "")
	if latest and latest ~= ModuleVersion then
		warn(
			`{OutputPrefix} Module is outdated, newest version available is: {latest}. Current module version is: {ModuleVersion}.`
		)
	end
end

--[=[
	Transforms `TweenInfo` into `TweenTable`

	@param info TweenInfo -- The TweenInfo you want to transform

	@return TweenTable -- The transformed TweenInfo
]=]
local function TweenInfoToTweenTable(info: TweenInfo): TweenTable
	return {
		EasingDirection = info.EasingDirection,
		Time = info.Time,
		DelayTime = info.DelayTime,
		RepeatCount = info.RepeatCount,
		EasingStyle = info.EasingStyle,
		Reverses = info.Reverses,
	}
end

--[=[
	Transforms `TweenTable` into `TweenInfo`

	@param info TweenTable -- The TweenInfo you want to transform

	@return TweenInfo -- The transformed TweenInfo
]=]
local function TweenTableToTweenInfo(info: TweenTable): TweenInfo
	return TweenInfo.new(
		info.Time or 0,
		info.EasingStyle,
		info.EasingDirection,
		info.RepeatCount or 0,
		info.Reverses or false,
		info.DelayTime or 0
	)
end

--[=[
	Setups the client side of the module on client

	@param player Player -- The player where client is setup
]=]
local function SetupClient(player: Player): ()
	local clone = TweenModelSetup:Clone()
	local playerscripts = player:WaitForChild("PlayerGui", 15)

	-- Retry if player still exists
	if not playerscripts and player.Parent == Players then
		SetupClient(player)
	-- Give up when client doesn't exist anymore
	elseif not playerscripts then
		return
	end

	clone.Parent = playerscripts
end

--[=[
	Registers the tween in active tweens and connects events
]=]
local function RegisterTween(tweendata: TweenData): TweenData
	activeTweens[tweendata.Model] = tweendata

	local CFrameValue = Instance.new("CFrameValue")
	CFrameValue.Value = tweendata.Model:GetPivot()

	local createdTween = TweenService:Create(CFrameValue, TweenTableToTweenInfo(tweendata.Info), {
		Value = tweendata.TargetCFrame,
	})

	CFrameValue.Changed:Connect(function()
		tweendata.Model:PivotTo(CFrameValue.Value)
	end)

	activeTweens[tweendata.Model].Tween = createdTween
	activeTweens[tweendata.Model].CFrameInstance = CFrameValue

	createdTween.Completed:Connect(function(state)
		if state == Enum.PlaybackState.Completed or activeTweens[tweendata.Model].Destroying == true then
			-- Disconnect everything
			createdTween:Destroy()

			-- Remove unused CFrameValue
			CFrameValue:Destroy()

			-- Remove from active tweens list
			activeTweens[tweendata.Model] = nil
		end
	end)

	return activeTweens[tweendata.Model]
end

--// Public Functions

--[=[
    Creates a new tween.

    @param model Model -- The model you want to tween
    @param info TweenInfo -- The tweeninfo you want to use
    @param target Target -- the goal

	@return Tween -- The tween instance you can use
]=]
function TweenModel.new(model: Model, info: TweenInfo, target: Target): Tween
	local isModel, hasPrimary = pcall(function()
		if model.PrimaryPart then
			return true
		else
			return false
		end
	end)

	local isTarget, isValidTarget = pcall(function()
		if typeof(target) == "CFrame" then
			return true
		elseif target.CFrame then
			target = target.CFrame
			return true
		else
			return false
		end
	end)

	if isModel == false or hasPrimary == false then
		error(
			`{OutputPrefix} Model does not have a primary part, please set the primary part before tweening! Model: {model and model:GetFullName()}`
		)
	end

	if isTarget == false or isValidTarget == false then
		error(`target is invalid, please use a BasePart or CFrame. ({typeof(target)})`)
	end

	if typeof(info) ~= "TweenInfo" then
		error(`TweenInformation is invalid, please use TweenInfo.`)
	end

	-- Cancel any active tweens on model, this will automatically destroy it
	if activeTweens[model] then
		activeTweens[model].Destroying = true

		activeTweens[model].Tween:Cancel()

		-- Wait for entry to be removed
		while activeTweens[model] ~= nil do
			task.wait()
		end
	end

	local CFrameValue = Instance.new("CFrameValue")
	CFrameValue.Value = model:GetPivot()

	local createdTween = TweenService:Create(CFrameValue, info, {
		Value = target,
	})

	-- Add entry to active tweens
	local currentId = HttpService:GenerateGUID(false)
	activeTweens[model] = {
		Id = currentId,
		State = createdTween.PlaybackState,
		OriginalCFrame = model:GetPivot(),
		CurrentCFrame = CFrameValue.Value,
		TargetCFrame = target,
		Info = TweenInfoToTweenTable(info),
		Model = model,
		Tween = createdTween,
		Destroying = false,
		CFrameInstance = CFrameValue,
	}

	createdTween:GetPropertyChangedSignal("PlaybackState"):Connect(function()
		activeTweens[model].State = createdTween.PlaybackState
		model:PivotTo(CFrameValue.Value)
		TweenEvent:FireAllClients(activeTweens[model])
	end)

	-- Handle cleaning up on completion
	createdTween.Completed:Connect(function(state)
		if state == Enum.PlaybackState.Completed or activeTweens[model].Destroying == true then
			-- Update model position on server side
			model:PivotTo(CFrameValue.Value)

			-- Disconnect everything
			createdTween:Destroy()

			-- Remove used CFrameValue
			CFrameValue:Destroy()

			-- Remove from active tweens list
			activeTweens[model] = nil
		end
	end)

	-- Send new created tween to client
	TweenEvent:FireAllClients(activeTweens[model])

	return createdTween
end

function TweenModel:PlayInstant(model: Model, info: TweenInfo, target: Target): Tween
	-- Create the new tween
	local tween = TweenModel.new(model, info, target)

	-- Play the tween
	tween:Play()

	-- Return tween if server needs it
	return tween
end

-- Setup server side
if RunService:IsServer() then
	-- Setup client reference
	if script.Parent == ReplicatedStorage then
		ClientReference.Value = script
	elseif ReplicatedStorage:FindFirstChild("TweenModel") then
		ClientReference.Value = ReplicatedStorage:WaitForChild("TweenModel")
		return require(ClientReference.Value)
	else
		script:Clone().Parent = ReplicatedStorage
		ClientReference.Value = ReplicatedStorage:WaitForChild("TweenModel")
		return require(ClientReference.Value)
	end

	-- Insert setup script to players
	Players.PlayerAdded:Connect(function(player: Player)
		SetupClient(player)
	end)
	for _, player: Player in Players:GetPlayers() do
		task.spawn(SetupClient, player)
	end

-- Setup client side
elseif RunService:IsClient() then
	TweenEvent.OnClientEvent:Connect(function(tweendata: TweenData)
		local clientData = activeTweens[tweendata.Model] or RegisterTween(tweendata)

		if tweendata.State == Enum.PlaybackState.Playing then
			clientData.Tween:Play()
		elseif tweendata.State == Enum.PlaybackState.Paused then
			clientData.Tween:Pause()
		elseif tweendata.State == Enum.PlaybackState.Cancelled and tweendata.Destroying == true then
			clientData.Tween:Cancel()
			clientData.Destroying = true
		elseif tweendata.State == Enum.PlaybackState.Cancelled then
			clientData.Tween:Cancel()
		end
	end)
end

-- Notify logs about version
print(`{OutputPrefix} Module loaded! Current version: {ModuleVersion}`)

-- Run version check in the background
task.spawn(CheckVersion)

return TweenModel

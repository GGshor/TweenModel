--[[
	Main module for tweening models on client.

	@GGshor
]]

--// Configuration
local DebugEnabled = false

--// Services
local TweenService = game:GetService("TweenService")
local MarketPlaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

--// Constants
local ModuleVersion = "2.2.1"
local OutputPrefix = "[TweenModel]:"
local TweenModelSetup = script:WaitForChild("TweenModelSetup")
local ClientReference = TweenModelSetup:WaitForChild("MainModuleReference") :: ObjectValue
local TweenEvent = script:WaitForChild("TweenEvent") :: RemoteEvent
local Types = require(script:WaitForChild("Types"))

local TweenModel = {} :: Types.TweenModelAPI

--// Variables
local activeTweens = {} :: { [Instance]: Types.TweenData }

--// Local functions

--[=[
	Prints debug messages
]=]
local function PrintDebug(...)
	-- Prevent debug messages when debug is not enabled
	if DebugEnabled ~= true then
		return
	end
	
	if RunService:IsServer() then
		print(`{OutputPrefix} (Server):`, ...)
	elseif RunService:IsClient() then
		print(`{OutputPrefix} (Client):`, ...)
	end
end

--[=[
	Checks the version
]=]
local function CheckVersion(): ()
	local info = MarketPlaceService:GetProductInfo(6019253834, Enum.InfoType.Asset)
	local description: string = info.Description

	local latest = description:match("%d+.%d+.%d+")
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
local function TweenInfoToTweenTable(info: TweenInfo): Types.TweenTable
	PrintDebug("Transforming TweenInfo instance to TweenTable, TweenInfo:", info)
	
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
local function TweenTableToTweenInfo(info: Types.TweenTable): TweenInfo
	PrintDebug("Transforming TweenTable instance to TweenInfo, TweenTable:", info)
	
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
	local playerGui = player:WaitForChild("PlayerGui", 15)

	-- Retry if player still exists
	if not playerGui and player.Parent == Players then
		SetupClient(player)
	-- Give up when client doesn't exist anymore
	elseif not playerGui then
		return
	end

	clone.Parent = playerGui
	
	PrintDebug(`Running setup script on player: {player}`)
end

--[=[
	Registers the tween in active tweens and connects events
]=]
local function RegisterTween(tweendata: Types.TweenData): Types.TweenData
	activeTweens[tweendata.Model] = tweendata

	local CFrameValue = Instance.new("CFrameValue")
	CFrameValue.Value = tweendata.CurrentCFrame

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
			PrintDebug("Destroying TweenData:", activeTweens[tweendata.Model])
			
			-- Disconnect everything
			createdTween:Destroy()

			-- Remove unused CFrameValue
			CFrameValue:Destroy()

			-- Remove from active tweens list
			activeTweens[tweendata.Model] = nil
		end
	end)
	
	PrintDebug("Registered new tween, current data:", activeTweens[tweendata.Model])

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
function TweenModel.new(model: Model, info: TweenInfo, target: Types.Target): Tween
	PrintDebug(`Creating new tween with arguments, model: {model}, info: {info}, target: {target}`)
	
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
		
		PrintDebug(`Cancelled current tween from model: {model:GetFullName()}`)
	end

	local CFrameValue = Instance.new("CFrameValue")
	CFrameValue.Value = model:GetPivot()
	CFrameValue.Changed:Connect(function(newValue: CFrame)
		activeTweens[model].CurrentCFrame = newValue
	end)

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
		PrintDebug(`Tween state changed! Old state: {activeTweens[model].State}, new state: {createdTween.PlaybackState}`)
		activeTweens[model].State = createdTween.PlaybackState
		model:PivotTo(CFrameValue.Value)
		TweenEvent:FireAllClients(activeTweens[model])
	end)

	-- Handle cleaning up on completion
	createdTween.Completed:Connect(function(state)
		if state == Enum.PlaybackState.Completed or activeTweens[model].Destroying == true then
			PrintDebug("Destroying TweenData:", activeTweens[model])
			
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
	
	PrintDebug("Created new tween, current data:", activeTweens[model])

	return createdTween
end

function TweenModel.PlayInstant(self: {}? | Model, model: Model | TweenInfo, info: TweenInfo | Types.Target, target: Types.Target): Tween
	if typeof(self) == "Instance" and self:IsA("Model") then
		-- Using the new way

		-- Create the new tween
		local tween = TweenModel.new(self, model, info)

		-- Play the tween
		tween:Play()

		-- Return tween if server needs it
		return tween
	else
		-- Using the old way
		
		-- Create the new tween
		local tween = TweenModel.new(model, info, target)

		-- Play the tween
		tween:Play()

		-- Return tween if server needs it
		return tween
	end
end

-- Setup server side
if RunService:IsServer() then
	-- Setup client reference
	if script.Parent == ReplicatedStorage then
		ClientReference.Value = ReplicatedStorage:WaitForChild("TweenModel")
	elseif ReplicatedStorage:FindFirstChild("TweenModel") then
		ClientReference.Value = ReplicatedStorage:WaitForChild("TweenModel")
		return require(ClientReference.Value) :: Types.TweenModelAPI
	else
		local clone = script:Clone()
		clone.Name = "TweenModel"
		clone.Parent = ReplicatedStorage
		ClientReference.Value = ReplicatedStorage:WaitForChild("TweenModel")
		return require(ClientReference.Value) :: Types.TweenModelAPI
	end

	-- Insert setup script to players
	Players.PlayerAdded:Connect(SetupClient)
	for _, player: Player in Players:GetPlayers() do
		task.spawn(SetupClient, player)
	end
	
	-- Client requests current tweens
	TweenEvent.OnServerEvent:Connect(function(player: Player)
		for _, tweenData in activeTweens do
			TweenEvent:FireClient(player, tweenData)
		end
	end)

-- Setup client side
elseif RunService:IsClient() then
	-- Request active tweens
	TweenEvent:FireServer()
	
	-- Listen to active tweens changes
	TweenEvent.OnClientEvent:Connect(function(tweendata: Types.TweenData)
		local clientData = activeTweens[tweendata.Model] or RegisterTween(tweendata)
		
		PrintDebug("Received tween event! New data:", tweendata)

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
PrintDebug(`Module loaded! Current version: {ModuleVersion}`)

-- Run version check in the background
task.spawn(CheckVersion)

return TweenModel :: Types.TweenModelAPI
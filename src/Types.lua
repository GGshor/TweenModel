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
	CurrentCFrame: CFrame,
	TargetCFrame: CFrame,
	Info: TweenTable,
	Model: Model,
	Tween: Tween?,
	Destroying: boolean,
	CFrameInstance: CFrameValue,
}

export type TweenModelAPI = {
	new: (model: Model, info: TweenInfo, target: Target) -> Tween,
	PlayInstant: (model: Model, info: TweenInfo, target: Target) -> Tween
}

return {}
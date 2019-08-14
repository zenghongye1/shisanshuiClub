--[[--
 * @Description:	ui_base自动添加动画
 * @Author:			shine
 * @Path:			logic/common_ui/ui_base_tween
 * @DateTime:		2016-08-31 16:17:06
]]

ui_base_tween = ui_base.New()
ui_base_tween.__index = ui_base_tween

function ui_base_tween.New()
	local result = {}
	setmetatable(result, ui_base_tween)
	return result
end

--[[--
 * @Description: 开始动画
]]
function ui_base_tween:StartTween(isShow,cellback)
	local tweenScaleMain = componentGet(self.transform,typeof(TweenScale))
	local tweenAlphaMain = componentGet(self.transform,typeof(TweenAlpha))

	if tweenScaleMain == nil then
		tweenScaleMain = self.gameObject:AddComponent("TweenScale")
	end

	if tweenAlphaMain == nil then
		tweenAlphaMain = self.gameObject:AddComponent("TweenAlpha")
	end

	if tweenScaleMain ~= nil and tweenAlphaMain ~= nil then
		local form = Vector3.New(0.8,0.8,1)
		local to = Vector3.New(1,1,1)
		local formAlpha = 0.2
		local toAlpha = 1
		local durTime = 0.15

		if isShow then
			tweenScaleMain.from = form
			tweenScaleMain.to = to

			tweenAlphaMain.from = formAlpha
			tweenAlphaMain.to = toAlpha
		else
			tweenScaleMain.from = to
			tweenScaleMain.to = form

			tweenAlphaMain.from = toAlpha
			tweenAlphaMain.to = formAlpha
		end

		tweenScaleMain.duration = durTime
		tweenScaleMain:SetOnFinished(EventDelegate.Callback(cellback))
		tweenScaleMain.enabled = true

		tweenAlphaMain.duration = durTime
		tweenAlphaMain.enabled = true

		tweenAlphaMain:ResetToBeginning()
		tweenScaleMain:ResetToBeginning()
	end
end

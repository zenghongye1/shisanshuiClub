--[[--
 * @Description: 通用倒计时
 * @Author:      ShushingWong
 * @FileName:    game_common_countDown_view.lua
 * @DateTime:    2018-04-12 14:15:56
 ]]
local base = require "logic/framework/ui/uibase/ui_load_view_base"
local baseClass = class("game_common_countDown_view", base)

function baseClass:InitPrefabPath()
	self.prefabPath = data_center.GetAppPath().."/ui/game_common_ui/gameCommonCountDown"
end

function baseClass:Init(parentTr)
	self.parentTr = parentTr
end

function baseClass:OnLoaded()
	self:SetParent(self.parentTr)
end

function baseClass:InitView()
	self.countDownSlider = self
	self.countDownSliderSprite = self:GetComponent("foreground", "UISprite")
	self.countDownTimeLabel = self:GetComponent("timeLbl", "UILabel")
end

function baseClass:Refresh()
end

local _xiaopaoTime = 0
local xiaopaoTimer_Elapse = nil
local xiaopaoCallBack = nil
local isDone = false

--通用倒计时接口
function  baseClass:SetCountDown(time,shakeTime,callback)
	self:StopCountDownTimer()
	isDone = false
	if time == nil or time <= 0 then
		self:Hide()
	elseif xiaopaoTimer_Elapse == nil then
		xiaopaoCallBack = callback
		self:Show()
		_xiaopaoTime =math.floor(time)
		self:SetLabel(_xiaopaoTime,shakeTime)
		xiaopaoTimer_Elapse = Timer.New(function()
			_xiaopaoTime = _xiaopaoTime -1;
			self:SetLabel(_xiaopaoTime,shakeTime)
			if _xiaopaoTime <= 0 then
				self:StopCountDownTimer()
				self:Hide()
				if xiaopaoCallBack ~= nil then
					xiaopaoCallBack()
				end
			end
		end,1,time)
		xiaopaoTimer_Elapse:Start()
	end
end

function baseClass:SetLabel(time,shakeTime)
	if self.countDownTimeLabel ~= nil then 
		self.countDownTimeLabel.text = tostring(time)
	end
	if shakeTime and time == shakeTime and not isDone then
		Notifier.dispatchCmd(cmdName.MSG_SHAKE,{})
	end
end

function baseClass:StopCountDownTimer()
	if xiaopaoTimer_Elapse ~= nil then
		xiaopaoTimer_Elapse:Stop()
		xiaopaoTimer_Elapse = nil
	end
end

---设置自己已经操作,用于倒计时标志
function baseClass:SetSelfDone(state)
	isDone = state
end

return baseClass
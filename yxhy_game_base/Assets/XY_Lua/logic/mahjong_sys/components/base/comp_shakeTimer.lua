local mode_comp_base = require "logic/mahjong_sys/components/base/mode_comp_base"
local comp_shakeTimer = class("comp_shakeTimer", mode_comp_base)

function comp_shakeTimer:ctor()
	self.timer = nil
	self.maxTime = 10
end

function comp_shakeTimer:StartTimer(time,loopTime)
	self:StopTimer()
	self.maxTime = 5
	if self.timer == nil then	
		self.timer = Timer.New(slot(self.OnTimer_Proc,self),self.time or 30,loopTime or -1)
		self.timer:Start()
	end
end

function comp_shakeTimer:OnTimer_Proc()
	self.maxTime = self.maxTime - 1
	Notifier.dispatchCmd(cmdName.MSG_SHAKE,{})
	if self.maxTime <= 0 then
		self:StopTimer()
	end
end

function comp_shakeTimer:StopTimer()
	if self.timer then
		self.timer:Stop()
		self.timer = nil
	end
end

function comp_shakeTimer:Uninitialize()
	self:StopTimer()
end

return comp_shakeTimer
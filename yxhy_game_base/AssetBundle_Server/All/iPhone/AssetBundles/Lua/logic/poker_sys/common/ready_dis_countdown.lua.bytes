local base = require "logic/framework/ui/uibase/ui_view_base"
local ready_dis_countdown = class("ready_dis_countdown", base)

local count = 0		-- 倒计时走的次数

function ready_dis_countdown:InitView()
	self.timeLbl = self:GetComponent("timeLbl","UILabel")
	self.proStr = ""
	self.afterStr = ""
	self.isSign = 30
end

function ready_dis_countdown:SetCallback(fun)
	self.callback = fun
end

function ready_dis_countdown:ShowCountDownView(time)	
	self.timeEnd = time	
	self:SetActive(true)
	self.timeLbl.text = self.proStr..tostring(math.floor(self.timeEnd))..self.afterStr
	self:StartReadyDisTimer()
end

function ready_dis_countdown:StartReadyDisTimer()
	if not self.readyDisTimer then
		self.readyDisTimer = Timer.New(slot(self.OnTimer_Proc,self),1,self.timeEnd)
		self.readyDisTimer:Start()
	end
end

function ready_dis_countdown:OnTimer_Proc()
	self.timeEnd = self.timeEnd - 1
	self.timeLbl.text = self.proStr..tostring(math.floor(self.timeEnd))..self.afterStr
	
	count = count + 1
	
	if self.callback then
		if count == self.isSign then
			self.callback(self.timeEnd,true)
			count = 0
		else
			self.callback(self.timeEnd,false)
		end
	end
	
	if self.timeEnd <= 0 then
		self:StopReadyDisTimer()
	end
end

function ready_dis_countdown:StopReadyDisTimer()
	if self.readyDisTimer then
		self.readyDisTimer:Stop()
		self.readyDisTimer = nil
		count = 0
	end
end

function ready_dis_countdown:HideCountDownView()
	self:SetActive(false)
	self:StopReadyDisTimer()
end

return ready_dis_countdown
local base = require "logic/framework/ui/uibase/ui_view_base"
local ColorCountDown = class("ColorCountDown", base)

function ColorCountDown:InitView()
	self.objSp = componentGet(self.gameObject,"UISprite")
	self.speed = 1
	self.callback = nil
end

function ColorCountDown:SetProcCallback(callback)
	self.callback = callback
end

--timeEnd:剩余时间	time:总时间
function ColorCountDown:StartTimer(timeEnd,time)
	self.timeEnd = timeEnd or 30	
	self.time = time or 30
	self.timeMid = self.time / 4
	self.objSp.color = self:GetColor()
	if self.timer == nil then	
		self.timer = Timer.New(slot(self.OnTimer_Proc,self),self.speed,self.timeEnd/self.speed)
		self.timer:Start()
	end
end

function ColorCountDown:OnTimer_Proc()
	self.timeEnd = self.timeEnd - self.speed
	self.objSp.color = self:GetColor()
	if self.callback then
		self.callback(self.timeEnd/self.time,math.floor(self.timeEnd))
	end
	if self.timeEnd <= 0 then
		self:StopTimer()
	end
end

function ColorCountDown:StopTimer()
	if self.timer then
		self.timer:Stop()
		self.timer = nil
	end
end

function ColorCountDown:GetColor()
	local color
	if self.timeEnd > self.timeMid then
		color = Color(
						((215-11)/(self.time-self.timeMid)*(self.time-self.timeEnd)+11)/255,
						(218 - (218-129)/(self.time-self.timeMid)*(self.time-self.timeEnd))/255,
						17/255
					)
	else
		color = Color(
						215/255,
						(129 - (129-12)/(self.timeMid)*(self.timeMid-self.timeEnd))/255,
						12/255
					)
	end
	
	return color
end

return ColorCountDown
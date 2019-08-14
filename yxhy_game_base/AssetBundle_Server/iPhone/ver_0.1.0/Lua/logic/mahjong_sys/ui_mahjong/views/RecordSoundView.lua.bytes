local base = require "logic/framework/ui/uibase/ui_view_base"
local RecordSoundView = class("RecordSoundView", base)

local RecordEnum = 
{
	Send = 1,
	Cancel = 2,
}

local RefreshInterval = 0.3


function RecordSoundView:InitView()
	self.sendViewGo = self:GetGameObject("send")
	self.canelViewGo = self:GetGameObject("cancelSend")

	self.recordPercentSp = self:GetComponent("send/quan", typeof(UISprite))
	self.recordPercentSp.gameObject:SetActive(true)

	self.state = RecordEnum.Send

	self.beginRecord = false

	self.recordTimer = nil

	-- 录音最长时间  动态获取
	self.maxRecordTime = nil

	self.time = 0

end

function RecordSoundView:UpdateState()
	self.sendViewGo:SetActive(self.state == RecordEnum.Send)
	self.canelViewGo:SetActive(self.state == RecordEnum.Cancel)
end

function RecordSoundView:SetState(enum)
	self.state = enum
	self:UpdateState()
end

function RecordSoundView:Hide()
	self.beginRecord = false
	self:StopTimer()
	self:SetState(RecordEnum.Send)
	self.time = 0
	self:SetActive(false)
end

function RecordSoundView:StopGvoice(needUpLoad)
	gvoice_sys.StopRecording()   -- 结束录音
	if needUpLoad then
    	gvoice_sys.AddRecordedFileLst()   -- 上传文件
    end
end


function RecordSoundView:StartRecord()
	Trace("录音开始,执行开始录音逻辑-------------------------------")
    local ret = gvoice_sys.StartRecording()   --开始录音

    self:SetActive(true)
    self:SetState(RecordEnum.Send)
    self.recordPercentSp.fillAmount = 0

    self:StartTimer()
end

function RecordSoundView:CancelRecord()
	self:StopGvoice(false)
	self:Hide()
end


function RecordSoundView:EndRecord()
	self:StopGvoice(true)
	self:Hide()
end



-------------拖拽事件 ---------------------

function RecordSoundView:Drag(go, delta)
	if self.state == RecordEnum.Send then
		if delta.y > 3 then
			self:SetState(RecordEnum.Cancel)
		end
	end
end


function RecordSoundView:DragEnd()
end


function RecordSoundView:Press(go, isPress)
	if isPress and not self.beginRecord then
		self.beginRecord = true
		self:SetState(RecordEnum.Send)
		self:StartRecord()
	else
		if not self.beginRecord then
			return
		end
		if self.state == RecordEnum.Send  then
			if self.time < gvoice_sys.GetMinRecordTime() then
				UI_Manager:Instance():FastTip("说话时间过短，请重新说话")
        		self:CancelRecord()
			else
				self:EndRecord()
			end
		else
			self:CancelRecord()
		end
	
	end
end


----------------------timer 相关 ----------------------

function RecordSoundView:StartTimer()
	self:StopTimer()
	self.recordTimer = Timer.New(slot(self.OnTimer, self), RefreshInterval, -1)
	self.recordTimer:Start()
end

function RecordSoundView:StopTimer()
	if self.recordTimer ~= nil then
		self.recordTimer:Stop()
		self.recordTimer = nil
	end
end

function RecordSoundView:OnTimer()
	self.time = self.time + RefreshInterval
	if self.time < self:GetMaxTime() then
		self.recordPercentSp.fillAmount = self.time / self:GetMaxTime()
	else
		self:EndRecord()
	end
end

function RecordSoundView:GetMaxTime()
	if self.maxRecordTime == nil then
		self.maxRecordTime = gvoice_sys.GetMaxRecordTime()
	end
	return self.maxRecordTime
end


return RecordSoundView

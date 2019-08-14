--[[--
 * @Description: 弹出框，持续一段时间后自动关闭
 * @Author:      xuemin.lin
 * @FileName:    fast_tip.lua
 * @DateTime:    2017-12-4
 ]]
local base = require("logic.framework.ui.uibase.ui_window")
fast_tip = class("fast_tip",base)

function fast_tip:ctor()
	base.ctor(self)
	self.timer_Elapse = nil -- timer
	self.nLeftTime = nil -- 持续时间
	self.lb_text = nil
	self.lb_nobbcode_text = nil
	self.msg = nil
	self.outlineColor = nil
	self.dotCount = 0
	self.Init = nil
	self.StartTimer = nil
	self.StopTimer = nil
	self.OnTimer_Proc = nil
	self.supportEncoding = true
end

function fast_tip:OnInit()
	self.m_UiLayer = UILayerEnum.UILayerEnum_Top
	self:InitItem()
end

function fast_tip:OnOpen()
	InputManager.AddLock()
	Notifier.regist(cmdName.MSG_MOUSE_BTN_DOWN, slot(self.OnMouseBtnDown, self))
end

function fast_tip:StopTimer()
	if self.timer_Elapse ~= nil then
		self.timer_Elapse:Stop()
		self.timer_Elapse = nil
	end
end

function fast_tip:OnClose()
	InputManager.ReleaseLock()
	Notifier.remove(cmdName.MSG_MOUSE_BTN_DOWN, slot(self.OnMouseBtnDown, self))
	self:StopTimer()
end

function fast_tip:OnMouseBtnDown(pos)
	self:StopTimer()
	self:Hide()
end

function fast_tip:OnTimer_Proc()
	self:Hide()
end

function fast_tip:OnTimer_ContentRefresh()
	self.dotCount = self.dotCount + 1
	if self.dotCount > 6 then
		self.dotCount = 1
	end
	local dotMsg = {}
	for i=1,self.dotCount do
		dotMsg[i] = "."		
	end
	self.lb_text.text = self.msg..table.concat(dotMsg, "")
end

function fast_tip:StartTimer()
	if self.nLeftTime == -1 then
		self:StopTimer()
		self.timer_Elapse = Timer.New( slot(self.OnTimer_ContentRefresh,self), 1, -1)
		self.timer_Elapse:Start()
	else
		self:StopTimer()
		self.timer_Elapse = Timer.New( slot(self.OnTimer_Proc,self), self.nLeftTime, 1)
		self.timer_Elapse:Start()
	end
end

--[[--
 * @Description: 逻辑入口  
 参数：encoding -是否支持bbcode默认支持
 ]]
function fast_tip:Show(text, time, pos, encoding, outlineColorValue)
	if pos == nil then
		pos = Vector3.New(0, 0, 0) 
	end
	self.supportEncoding = encoding
	self.outlineColor = outlineColorValue
	if time == nil then
		time = 2
	end
	self:ShowByTime(text, pos, time)
end

--[[--
 * @Description: 逻辑入口  
 ]]
function fast_tip:ShowByTime(text, pos, last_time)
	self.msg = text
	if last_time == 0.0 then
		self.nLeftTime = 3
	else
		self.nLeftTime = last_time
	end
	if not IsNil(self.gameObject) then
		if self.nLeftTime ~= -1 then
			--快速显示
			self.transform.localPosition = pos
		end
	else
	self.transform.localPosition = pos
	end
	local bEncode = not(self.supportEncoding == false)
	
	self.lb_text.transform.gameObject:SetActive(bEncode)
	self.lb_nobbcode_text.transform.gameObject:SetActive(not bEncode)
	self.lb_text.text = self.msg
	self.lb_nobbcode_text.text = self.msg
	if (self.outlineColor ~= nil) then
		self.lb_text.effectStyle = UILabel.Effect.Outline
		self.lb_text.effectColor = self.outlineColor
	end
	
	self:StartTimer()
end

function fast_tip:ResetFastTip()
	self.outlineColor = nil 
end

function fast_tip:FakeDestroy()
	UI_Manager:Instance():CloseUiForms("fast_tip")
end

function fast_tip:PlayOpenAmination()
end

--[[--
 * @Description: 逻辑入口  
 ]]
function fast_tip:Hide()
	UI_Manager:Instance():CloseUiForms("fast_tip")
end

function fast_tip:InitItem()	
	self.lb_text = subComponentGet(self.transform, "Label", "UILabel")
	self.lb_nobbcode_text = subComponentGet(self.transform, "Label_noBBcode","UILabel")
end

return fast_tip
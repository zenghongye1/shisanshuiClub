local base = require "logic/framework/ui/uibase/ui_view_base"
local tips_view = class("tips_view", base)

function tips_view:InitView()
	self.maxLblWidth = 385
	self.tipsView = self:GetGameObject("tipsView")
	self.tipsView:SetActive(false)
	self.tipsBg = self:GetComponent("tipsView/bg","UISprite")
	self.tipsLbl = self:GetComponent("tipsView/Label","UILabel")
	self.checkList = {self.tipsBg,self:GetComponent("","UISprite")}	
	self.showTime = 2
end

function tips_view:SetTipsEnable(toggleData)
	self.tipsData = toggleData
	if self.tipsData then
		self:SetActive(true)
		UIEventListener.Get(self.gameObject).onPress = function(obj,state)
			self:TipsObjOnPress(state)
		end
		addClickCallbackSelf(self.gameObject,self.TipsObjOnClick,self)
	else
		self:SetActive(false)
	end
end

function tips_view:TipsObjOnPress(state)	
	if state then
		self:StopHideTimer()
		self:ShowTips(true,self.tipsData)
	else
		self:ShowTips(false)
	end
end

function tips_view:TipsObjOnClick()
	self:ShowTips(true,self.tipsData)
	self:StartHideTimer()
end

function tips_view:StartHideTimer()
	if not self.autoHideTimer then
		self.autoHideTimer = Timer.New(function()
			self:ShowTips(false)
		end,self.showTime,1)
		self.autoHideTimer:Start()
	else
		self.autoHideTimer:Stop()
		self.autoHideTimer:Reset(function()
			self:ShowTips(false)
		end,self.showTime,1)
		self.autoHideTimer:Start()
	end
end

function tips_view:StopHideTimer()
	if self.autoHideTimer then
		self.autoHideTimer:Stop()
		self.autoHideTimer = nil
	end
end

function tips_view:ShowTips(state,content)
	if state then
		self.tipsView:SetActive(true)
		self.tipsLbl.text = content	
		self.tipsLbl.overflowMethod = UILabel.Overflow.ResizeFreely
		self.tipsLbl:ProcessText()							---适配文本和背景
		if self.tipsLbl.width < self.maxLblWidth then
			self.tipsBg.width = self.tipsLbl.width + 20
		else
			self.tipsLbl.width = self.maxLblWidth
			self.tipsLbl.overflowMethod = UILabel.Overflow.ResizeHeight
			self.tipsLbl:ProcessText()
			self.tipsBg.width = self.tipsLbl.width + 20
			self.tipsBg.height = self.tipsLbl.printedSize.y + 18
		end
	else
		self.tipsView:SetActive(false)
		self:StopHideTimer()
	end
end

function tips_view:OnShow()
	Notifier.regist(cmdName.MSG_MOUSE_BTN_DOWN, slot(self.OnMouseBtnDown, self))
end

function tips_view:OnHide()
	Notifier.remove(cmdName.MSG_MOUSE_BTN_DOWN, slot(self.OnMouseBtnDown, self))
end

function tips_view:OnMouseBtnDown(pos)
	if not Utils.CheckPointInUIs(self.checkList, pos) then
		self.tipsView:SetActive(false)
	end
end

return tips_view
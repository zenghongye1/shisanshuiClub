local base = require "logic/framework/ui/uibase/ui_view_base"
local HelpView = class("HelpView", base)

function HelpView:ctor(go)
	self.btnGo = nil
	self.callback = nil
	self.target = nil
	self.btnLabel = nil
	base.ctor(self, go)
end

function HelpView:InitView()
	self.btnGo = self:GetGameObject("middle/btn")
	self.contentLabel = self:GetComponent("middle/content", typeof(UILabel))
	self.btnLabel = self:GetComponent("middle/btn/Label", typeof(UILabel))
	addClickCallbackSelf(self.btnGo, self.OnBtnClick, self)

	self.btn2Go = self:GetGameObject("middle2/btn")
	self.content2Label = self:GetComponent("middle2/content", typeof(UILabel))
	self.btn2Label = self:GetComponent("middle2/btn/Label", typeof(UILabel))
	if self.btn2Go ~= nil then
		addClickCallbackSelf(self.btn2Go, self.OnBtn2Click, self)
	end
end

function HelpView:SetInfo(content, label, callback, target)
	self.contentLabel.text = content
	self.btnLabel.text = label
	self.callback = callback
	self.target = target
end

function HelpView:SetInfo2(content, label, callback)
	self.content2Label.text = content
	self.btn2Label.text = label
	self.callback2 = callback
end

function HelpView:OnBtnClick()
	ui_sound_mgr.PlayButtonClick()
	if self.callback ~= nil then
		self.callback(self.target)
	end
end

function HelpView:OnBtn2Click()
	ui_sound_mgr.PlayButtonClick()
	if self.callback2 ~= nil then
		self.callback2(self.target)
	end
end

return HelpView

local base = require "logic/framework/ui/uibase/ui_view_base"
local BtnView = class("BtnView", base)

function BtnView:ctor( go, bgPath, labelPath)
	self.bgPath = bgPath or ""
	self.labelPath = labelPath or "Label"
	base.ctor(self, go)
end

function BtnView:InitView()
	self.bgSp = self:GetComponent(self.bgPath, typeof(UISprite))
	self.label = self:GetComponent(self.labelPath, typeof(UILabel))
	addClickCallbackSelf(self.gameObject, self.OnClick, self)
end

function BtnView:SetInfo(info, callback, target)
	self.label:resetMyFormatData(true)
	self.info = info
	self.label.text = info.text
	self.callback = callback
	self.target = target
	local bgSp = info.bgSp or "button_03"
	self.bgSp.spriteName = bgSp
	if self.bgSp.spriteName == "button_03" then
		self.label:SetLabelFormat(UILabelFormat.F53)
	else
		self.label:SetLabelFormat(UILabelFormat.F37)
	end
end

function BtnView:OnClick()
	if self.callback ~= nil then
		self.callback(self.target, self)
	end
end

return BtnView
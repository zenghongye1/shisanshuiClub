local base = require "logic/framework/ui/uibase/ui_view_base"
local SelectView = class("SelectView", base)

function SelectView:InitView()
	self.isShow = false
	self.contentLabel = self:GetComponent("Label", typeof(UILabel))
	self.selectBtnSp = self:GetComponent("btnSelect", typeof(UISprite))
	self.selectIconSp = self:GetComponent("btnSelect/Sprite", typeof(UISprite))

	addClickCallbackSelf(self.selectBtnSp.gameObject, self.OnSelfClick, self)
	addClickCallbackSelf(self.contentLabel.gameObject, self.OnSelfClick, self)
	self:UpdateView()
end

function SelectView:OnSelfClick()
	self.isShow = not self.isShow
	self:UpdateView()
	-- show tableView
end

function SelectView:UpdateView()
	if not self.isShow then
		self.selectBtnSp.spriteName = "button_15"
		self.selectIconSp.spriteName = "common_47"
	else
		self.selectBtnSp.spriteName = "button_16"
		self.selectIconSp.spriteName = "common_41"
	end
end

function SelectView:Reset()
	self.isShow = false
	self:UpdateView()
end


return SelectView
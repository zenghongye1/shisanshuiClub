local base = require "logic/framework/ui/uibase/ui_view_base"
local mail_item = class("mail_item", base)

function mail_item:InitView()
	addClickCallbackSelf(self.gameObject,self.OnClick,self)
	self.lbl_checkName = self:GetComponent("lbl_checkName","UILabel")
	self.lbl_name = self:GetComponent("lbl_name","UILabel")
	self.redPointGo = self:GetGameObject("sp_red")
end

function mail_item:SetInfo(itemInfo)
	self.itemInfo = itemInfo
	self:UpdateView()
end

function mail_item:UpdateView()
	self.lbl_checkName.text = self.itemInfo["title"]
	self.lbl_name.text = self.itemInfo["title"]
	self:SetRedPointShow(self.itemInfo["status"]~=1)
end

function mail_item:SetRedPointShow(status)
	self.redPointGo:SetActive(status)
end

function mail_item:SetCallback(callback,target)
	self.callback = callback
	self.target = target
end

function mail_item:OnClick()
	if self.callback ~= nil then
		self.callback(self.target, self)
	end
end

return mail_item
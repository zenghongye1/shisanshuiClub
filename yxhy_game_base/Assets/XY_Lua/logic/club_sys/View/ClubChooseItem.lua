local base = require "logic/framework/ui/uibase/ui_view_base"
local ClubChooseItem = class("ClubChooseItem", base)

function ClubChooseItem:InitView()
	self.nameLabel = self:GetComponent("name", typeof(UILabel))
	self.selectIconGo = self:GetGameObject("selectIcon")
	self.desLabel = self:GetComponent("des", typeof(UILabel))
	self.tipsGo = self:GetGameObject("tipsGo")
	self.tipsLable = self:GetComponent("tipsGo/Label", typeof(UILabel))
	self.isSelected = false
	addClickCallbackSelf(self.gameObject, self.OnClick, self)
end

function ClubChooseItem:SetCallback(callback, target)
	self.callback = callback 
	self.target = target
end

function ClubChooseItem:SetInfo(gid)
	self.gid = gid
	local cfg = config_mgr.getConfig("cfg_game", gid)
	if cfg == nil then
		return
	end
	self.nameLabel.text = model_manager:GetModel("GameModel"):GetGameName(gid)
	self.desLabel.text = cfg.des
end

function ClubChooseItem:SetState(value)
	self.tipsGo:SetActive(value)
end

function ClubChooseItem:SetSelected(value)
	self.isSelected = value
	self.selectIconGo:SetActive(value)
end

function ClubChooseItem:OnClick()
	if self.callback ~= nil then
		self.callback(self.target, self)
	end
end


return ClubChooseItem
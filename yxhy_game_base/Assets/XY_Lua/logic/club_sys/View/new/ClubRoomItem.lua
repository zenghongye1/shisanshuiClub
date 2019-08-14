local base = require "logic/framework/ui/uibase/ui_view_base"
local ClubRoomItem = class("ClubRoomItem", base)

function ClubRoomItem:InitView()
	self.model = model_manager:GetModel("ClubModel")
	self.nameLabel = self:GetComponent("room", typeof(UILabel))
	self.roundLabel = self:GetComponent("round", typeof(UILabel))
	self.numLabel = self:GetComponent("num", typeof(UILabel))
	self.icon = self:GetComponent("icon", typeof(UISprite))
	self.leaderNameLabel = self:GetComponent("name", typeof(UILabel))
	self.selfIconGo = self:GetGameObject("selfIcon")
	self.selfIconGo:SetActive(false)
	addClickCallbackSelf(self.gameObject, self.OnClick, self)
end

function ClubRoomItem:SetCallback(callback, target)
	self.callback = callback
	self.target = target
end

function ClubRoomItem:SetInfo(info)
	self.info = info
	self:UpdateView()
end

function ClubRoomItem:UpdateView()
	local name = GameUtil.GetGameName(self.info.gid)
	self.nameLabel.text = name .. "【" .. self.info.rno .. "】"
	self.leaderNameLabel.text = self.info.homenickname or ""

	if self.info.cfg == nil then
		return
	end

	if self.info.cfg.rounds == 0 then
		self.roundLabel.text = "打课"
	else
		self.roundLabel.text = (self.info.cfg.rounds or 0) .. "局"
	end
	self.numLabel.text = (self.info.cur_pnum or 0) .. "/" .. (self.info.cfg.pnum or 0) .. "人"

	self.selfIconGo:SetActive(self.info.uid == self.model.selfPlayerId)
	self.icon.spriteName = GameUtil.GetGameIcon(self.info.gid)
end

function ClubRoomItem:OnClick()
	if self.callback ~= nil then
		self.callback(self.target, self)
	end
end


return ClubRoomItem
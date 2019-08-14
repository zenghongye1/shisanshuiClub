local base = require "logic/framework/ui/uibase/ui_view_base"
local ClubEnterRoomItem = class("ClubEnterRoomItem", base)

function ClubEnterRoomItem:InitView()
	self.model = model_manager:GetModel("ClubModel")
	self.nameLabel = self:GetComponent("name", typeof(UILabel))
	self.ruleLabel = self:GetComponent("rule", typeof(UILabel))
	self.roundLabel = self:GetComponent("round", typeof(UILabel))
	self.numLabel = self:GetComponent("num", typeof(UILabel))
	self.icon = self:GetComponent("icon", typeof(UISprite))
	self.roomCreaterLabel = self:GetComponent("roomCreater", typeof(UILabel))
	self.ownerIconGo = self:GetGameObject("ownerIcon")
	self.ownerIconGo:SetActive(false)
	addClickCallbackSelf(self.gameObject, self.OnClick, self)
end

function ClubEnterRoomItem:SetCallback(callback, target)
	self.callback = callback
	self.target = target
end

function ClubEnterRoomItem:SetInfo(info , callback, target)
	self.info = info
	self:UpdateView()
end

function ClubEnterRoomItem:UpdateView()
	local name = GameUtil.GetGameName(self.info.gid)
	self.nameLabel.text = name .. "【" .. self.info.rno .. "】"
	--self.roomCreaterLabel.text = "房主:" .. self.info.home_nickname or ""
	self.roomCreaterLabel.gameObject:SetActive(false)

	self.ruleLabel.text = self.info.homenickname or ""

	self.ownerIconGo:SetActive(self.info.uid == self.model.selfPlayerId)
	self.icon.spriteName = GameUtil.GetGameIcon(self.info.gid)

	if self.info.cfg == nil then
		return
	end

	if self.info.cfg.rounds == 0 then
		self.roundLabel.text = "打课"
	else
		self.roundLabel.text = (self.info.cfg.rounds or 0 ).. "局"
	end
	self.numLabel.text = (self.info.cur_pnum or 0).. "/" .. (self.info.cfg.pnum or 0) .. "人"
	-- self.ruleLabel.text = ShareStrUtil.GetRoomShareStr(self.info.gid, self.info, true)

end

function ClubEnterRoomItem:OnClick()
	if not TimeLimitHelper.CheckTimeLimit("ClubEnterRoomItem", 0.5) then
		return
	end
	if self.callback ~= nil then
		self.callback(self.target, self)
	end
end


return ClubEnterRoomItem
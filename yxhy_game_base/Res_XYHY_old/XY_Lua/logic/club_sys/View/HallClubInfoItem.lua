local base = require "logic/framework/ui/uibase/ui_view_base"
local HallClubInfoItem = class("HallClubInfoItem", base)

local curClubNameColor = Color.New(36/255, 134/255, 202/255)
local curClubIdColor = Color.New(51/255, 114/255, 158/255)
local otherClubNameColor = Color.New(194/255, 87/255, 8/255)
local otherClubIdColor = Color.New(137/255, 63/255, 3/255)

function HallClubInfoItem:InitView()
	self.nameLabel = self:GetComponent("name", typeof(UILabel))
	self.IdLabel = self:GetComponent("ID", typeof(UILabel))
	self.headIcon = self:GetComponent("headIcon", typeof(UISprite))
	self.newIconGo = self:GetGameObject("newIcon")
	self.bgSp = self:GetComponent("", typeof(UISprite))
	self.model = model_manager:GetModel("ClubModel")
	addClickCallbackSelf(self.gameObject, self.OnClick, self)
	self.newApplyBtnGo = self:GetGameObject("newApplyBtn")
	addClickCallbackSelf(self.newApplyBtnGo, self.OnApplyBtnClick, self)
	self.newApplyBtnGo:SetActive(false)
	self.applyNumLabel = self:GetComponent("newApplyBtn/num", typeof(UILabel))
	-- self.redIconGo = self:GetGameObject("redPoint")
	-- self.redIconGo:SetActive(false)
end

function HallClubInfoItem:SetCallback(callback, target)
	self.callback = callback
	self.target = target
end

function HallClubInfoItem:SetInfo(clubInfo)
	self.clubInfo = clubInfo
	self:UpdateView()
end

function HallClubInfoItem:UpdateView()
	if self.clubInfo.cid == self.model.currentClubInfo.cid then
		self.nameLabel.color = curClubNameColor
		self.IdLabel.color = curClubIdColor
		self.bgSp.spriteName = "common_04"
	else
		self.nameLabel.color = otherClubNameColor
		self.IdLabel.color = otherClubIdColor
		self.bgSp.spriteName = "common_13"
	end
	self.nameLabel.text = self.clubInfo.cname
	self.IdLabel.text = "ID:" .. self.clubInfo.shid
	self.headIcon.spriteName = ClubUtil.GetClubIconName(self.clubInfo.icon)
	self.newIconGo:SetActive(self.model:CheckClubIsNew(self.clubInfo.cid))

	if self.model:CheckCanSeeApplyList(self.clubInfo.cid) 
		and self.clubInfo.applyNum ~= nil 
		and self.clubInfo.applyNum > 0 then
		self.newApplyBtnGo:SetActive(true)
		self.applyNumLabel.text = self.clubInfo.applyNum .. ""
	else
		self.newApplyBtnGo:SetActive(false)
	end

	-- self.redIconGo:SetActive(self.model:CheckShowApplyHint(self.clubInfo.cid))
end

function HallClubInfoItem:OnClick()
	if self.callback ~= nil then
		self.callback(self.target, self)
	end
end

function HallClubInfoItem:OnApplyBtnClick()
	UI_Manager:Instance():ShowUiForms("ClubApplyUI", nil, nil, self.clubInfo.cid)
end

return HallClubInfoItem
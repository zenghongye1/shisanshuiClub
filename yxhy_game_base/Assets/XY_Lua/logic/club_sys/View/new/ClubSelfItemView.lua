local base = require "logic/framework/ui/uibase/ui_view_base"
local ClubSelfItemView = class("ClubSelfItemView", base)

local selectColor = Color.New(34/255, 46/255, 106/255)
local disselectColor = Color.New(163/255, 88/255, 27/255)

function ClubSelfItemView:InitView()
	self.model = model_manager:GetModel("ClubModel")
	self.nameLabel = self:GetComponent("name", typeof(UILabel))
	self.IdLabel = self:GetComponent("id", typeof(UILabel))
	self.icon = self:GetComponent("icon", typeof(UISprite))
	self.newIconGo = self:GetGameObject("newIcon")
	self.selfIconGo = self:GetGameObject("selfIcon")
	self.redIconGo = self:GetGameObject("redPoint")
	self.redIconGo:SetActive(false)

	self.selectIconGo = self:GetGameObject("selectIcon")

	self.bg = self:GetComponent("", typeof(UISprite))

	self:SetSelected(false)

	addClickCallbackSelf(self.gameObject, self.OnClick, self)
end

function ClubSelfItemView:SetCallback(callback, target)
	self.callback = callback
	self.target = target
end

function ClubSelfItemView:OnClick()
	if self.callback ~= nil then
		self.callback(self.target, self)
	end
end

function ClubSelfItemView:SetInfo(clubInfo)
	self.clubInfo = clubInfo
	self.IdLabel.text = "ID:" .. self.clubInfo.shid
	self.nameLabel.text = self.clubInfo.cname
	self.icon.spriteName = ClubUtil.GetClubIconName(self.clubInfo.icon)
	self.newIconGo:SetActive(self.model:CheckClubIsNew(self.clubInfo.cid))
	self.selfIconGo:SetActive(self.model:IsClubCreater(self.clubInfo.cid))
	self.redIconGo:SetActive(self.model:CheckCanSeeApplyList(self.clubInfo.cid) and self.clubInfo.applyNum ~= nil 
		and self.clubInfo.applyNum > 0 )
end

function ClubSelfItemView:SetSelected(value, force)
	if self.isSelect == value and not force then
		return 
	end
	self.isSelect = value
	self.selectIconGo:SetActive(value)
	if self.isSelect then
		self.nameLabel:SetLabelFormat( UILabelFormat.F10)
		self.IdLabel:SetLabelFormat(UILabelFormat.F10)
		self.bg.spriteName = "common_04"
	else
		self.nameLabel:SetLabelFormat( UILabelFormat.F12)
		self.IdLabel:SetLabelFormat(UILabelFormat.F12)
		self.bg.spriteName = "common_82"
	end
end


return ClubSelfItemView
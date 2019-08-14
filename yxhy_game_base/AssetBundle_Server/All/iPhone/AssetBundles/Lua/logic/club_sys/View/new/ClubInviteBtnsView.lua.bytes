local base = require "logic/framework/ui/uibase/ui_view_base"
local ClubInviteBtnsView = class("ClubInviteBtnsView", base)

function ClubInviteBtnsView:InitView()
	self.friendBtn = self:GetGameObject("btnsView/friendBtn")
	self.circleBtn = self:GetGameObject("btnsView/circleBtn")
	self.maskGo = self:GetGameObject("btnsView/mask")

	addClickCallbackSelf(self.maskGo, self.OnMaskClick, self)
	addClickCallbackSelf(self.friendBtn, self.OnFriendBtnClick, self)
	addClickCallbackSelf(self.circleBtn, self.OnCircleBtnClick, self)

	self.currentClubInfo = nil
end

function ClubInviteBtnsView:Show(currentClubInfo)
	self.currentClubInfo = currentClubInfo
	self:SetActive(true)
end

function ClubInviteBtnsView:OnMaskClick()
	self:Hide()
end

function ClubInviteBtnsView:OnFriendBtnClick()
	invite_sys.inviteToClub(self.currentClubInfo,0)
	self:Hide()
end

function ClubInviteBtnsView:OnCircleBtnClick()
	invite_sys.inviteToClub(self.currentClubInfo,1)
	self:Hide()
end

function ClubInviteBtnsView:Hide()
	self:SetActive(false)
end

return ClubInviteBtnsView
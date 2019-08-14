local base = require("logic.framework.ui.uibase.ui_window")
local InviteNoticeUI = class("InviteNoticeUI", base)
local UIManager = UI_Manager:Instance() 
local LanguageMgr = LanguageMgr

function InviteNoticeUI:OnInit()
	self.destroyType = UIDestroyType.Immediately
	self.desLabel = self:GetComponent("clubInvite/des", typeof(UILabel))
	self.contentLabel = self:GetComponent("clubInvite/content", typeof(UILabel))
	self.gameLabel = self:GetComponent("clubInvite/game", typeof(UILabel))

	self.closeBtn = self:GetGameObject("btn_close")
	addClickCallbackSelf(self.closeBtn, self.OnCloseClick, self)

	self.yesBtnGo = self:GetGameObject("btn_grid/btn_01")
	addClickCallbackSelf(self.yesBtnGo, self.OnYesBtnClick, self)
	
	self.noBtnGo = self:GetGameObject("btn_grid/btn_02")
	addClickCallbackSelf(self.noBtnGo, self.OnNoBtnClick, self)
end

function InviteNoticeUI:OnOpen(clubInfo, playerName)
	self.clubInfo = clubInfo
	self.desLabel.text = LanguageMgr.GetWord(9000, playerName)
	self.contentLabel.text = LanguageMgr.GetWord(9001, clubInfo.cname, clubInfo.nickname)
	self.gameLabel.text = LanguageMgr.GetWord(9002, ClubUtil.GetGameContent(clubInfo.gids, "、", 32))
end

function InviteNoticeUI:OnClose()
	self.clubInfo = nil
end

function InviteNoticeUI:OnYesBtnClick()
	ui_sound_mgr.PlayButtonClick()
	model_manager:GetModel("ClubModel"):ReqApplyClub(self.clubInfo["shid"])
	UIManager:CloseUiForms("InviteNoticeUI")
end

function InviteNoticeUI:OnNoBtnClick()
	ui_sound_mgr.PlayButtonClick()
	UIManager:CloseUiForms("InviteNoticeUI")
end

function InviteNoticeUI:OnCloseClick()
	ui_sound_mgr.PlayCloseClick()
	UIManager:CloseUiForms("InviteNoticeUI")
end


return InviteNoticeUI

local base = require("logic.framework.ui.uibase.ui_window")
local ClubAgentGetUI = class("ClubAgentGetUI",base)
local addClickCallbackSelf = addClickCallbackSelf
local UIManager = UI_Manager:Instance() 

function ClubAgentGetUI:OnInit()
	self.closeBtnGo = self:GetGameObject("panel/btn_close")
	self.copyWeixinBtnGo = self:GetGameObject("panel/copy1")
	self.copyQQBtnGo = self:GetGameObject("panel/copy2")
	self.weixinLabel = self:GetComponent("panel/weixin", typeof(UILabel))
	self.qqLabel = self:GetComponent("panel/qq", typeof(UILabel))
	self.weixinLabel.text = "微信客服号：" .. global_define.winXin
	self.qqLabel.text = "QQ客服号：" .. global_define.qq

	addClickCallbackSelf(self.closeBtnGo, self.OnCloseClick, self)
	addClickCallbackSelf(self.copyWeixinBtnGo, self.CopyWeiXin, self)
	addClickCallbackSelf(self.copyQQBtnGo, self.CopyQQ, self)
end

function ClubAgentGetUI:OnCloseClick()
	ui_sound_mgr.PlayCloseClick()
	UIManager:CloseUiForms("ClubAgentGetUI")
end

function ClubAgentGetUI:CopyWeiXin()
	local str = global_define.winXin
	YX_APIManage.Instance:onCopy(str,function() UIManager:FastTip(LanguageMgr.GetWord(6043))end)
end

function ClubAgentGetUI:CopyQQ()
	local str = tostring(global_define.qq)
	YX_APIManage.Instance:onCopy(str,function() UIManager:FastTip(LanguageMgr.GetWord(6043))end)
end

return ClubAgentGetUI
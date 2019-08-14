local base = require "logic/framework/ui/uibase/ui_view_base"
local ClubApplyItem = class("ClubApplyItem", base)
local ClubMemberEnum = ClubMemberEnum

function ClubApplyItem:InitView()
	self.headIcon = self:GetComponent("headIcon", typeof(UITexture))
	self.nameLabel = self:GetComponent("name", typeof(UILabel))
	self.IDLabel = self:GetComponent("Id", typeof(UILabel))
	self.timeLabel = self:GetComponent("time", typeof(UILabel))
	
	self.tipBtn = self:GetGameObject("tipBtn")

	self.bgSp = self:GetComponent("", typeof(UISprite))

	self.sureBtnGo = self:GetGameObject("sureBtn")
	self.refuseBtnGo = self:GetGameObject("refuseBtn")

	if self.sureBtnGo ~= nil then
		addClickCallbackSelf(self.sureBtnGo, self.OnSureClick, self)
		addClickCallbackSelf(self.refuseBtnGo, self.OnRefuseClick, self)
	end
	addClickCallbackSelf(self.gameObject, self.OnClick, self)

end

function ClubApplyItem:SetInfo(info, callback, target)
	self.info = info
	self.model = model_manager:GetModel("ClubModel")

	-- 刷数据
	self:UpdateView()
end

function ClubApplyItem:SetTipBtnCallback(isMisdeed,callback)
	local isMisdeed = isMisdeed or 0
	if self.tipBtn ~= nil then
		self.tipBtn:SetActive(isMisdeed ~= 0)
		if callback ~= nil then
			addClickCallbackSelf(self.tipBtn,callback,self)
		end
	end
end

function ClubApplyItem:SetCallback(callback, target)
	self.callback = callback
	self.target = target
end


function ClubApplyItem:UpdateView()
	self.nameLabel.text = self.info.nickname
	HeadImageHelper.SetImage(self.headIcon, 2, self.info.imageurl, self.info.uid)
	self.IDLabel.text = "ID:" .. self.info.uid

	self.timeLabel.text = os.date("%Y/%m/%d", self.info.atime)

	if self.info.uid == self.model.selfPlayerId then
		self.bgSp.spriteName = "common_54"
	else
		self.bgSp.spriteName = "common_11"
	end
end

function ClubApplyItem:OnClick()
	if self.callback ~= nil then
		self.callback(self.target, self)
	end
end

function ClubApplyItem:OnSureClick()
	ui_sound_mgr.PlayButtonClick()
	model_manager:GetModel("ClubModel"):ReqDealClubApply(self.info.cpid, 1)
end

function ClubApplyItem:OnRefuseClick()
	ui_sound_mgr.PlayButtonClick()
	model_manager:GetModel("ClubModel"):ReqDealClubApply(self.info.cpid, 0)
end

return ClubApplyItem
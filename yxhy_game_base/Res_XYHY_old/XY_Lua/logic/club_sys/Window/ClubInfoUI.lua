local base = require("logic.framework.ui.uibase.ui_window")
local ClubInfoUI = class("ClubInfoUI", base)
local UIManager = UI_Manager:Instance() 
local addClickCallbackSelf = addClickCallbackSelf
local ClubInfoView = require('logic/club_sys/View/ClubInfoView')
local ClubMemberView = require ("logic/club_sys/View/ClubMembersView")
local ClubAdView = require ("logic/club_sys/View/ClubAdView")

function ClubInfoUI:OnInit()
	self.model = model_manager:GetModel("ClubModel")
	self.closeBtnGo = self:GetGameObject("backBtn")
	addClickCallbackSelf(self.closeBtnGo, self.OnCloseClick, self)

	self.applyBtnGo = self:GetGameObject("applyBtn")
	self.effectGo = self:GetGameObject("applyBtn/Effect_shengqinliebiao")
	self.effectGo:SetActive(false)
	addClickCallbackSelf(self.applyBtnGo, self.OnApplyBtnClick, self)

	self.inviteBtnGo = self:GetGameObject("inviteBtn")
	addClickCallbackSelf(self.inviteBtnGo, self.OnInvite, self)

	self.infoView = ClubInfoView:create(self:GetGameObject("infoView"))
	self.infoView:SetActive(true)
	self.tipsGo = self:GetGameObject("tips")

	self.adView = ClubAdView:create(self:GetGameObject("adView"))
	self.adView:SetActive(false)

	self.memberView = ClubMemberView:create(self:GetGameObject("container"))
	self.memberView:SetActive(true)

end

-- 俱乐部信息，标签页
function ClubInfoUI:OnOpen(clubInfo, type)
	self.clubInfo = clubInfo
	self.infoView:SetInfo(clubInfo)
	self.memberView:SetInfo(clubInfo.cid)
	if self.model:IsClubMember(clubInfo.cid) and clubInfo.ctype ~= 1 then
		self.model:ReqGetClubUser(clubInfo.cid, false)
		self.tipsGo:SetActive(false)
	elseif clubInfo.ctype == 1 then
		self.tipsGo:SetActive(false)
	else
		self.tipsGo:SetActive(true)
	end
	self:UpdateView()
	self.effectGo:SetActive(self.model:CheckShowApplyHint())
	
	Notifier.regist(GameEvent.OnClubInfoUpdate, self.OnClubInfoUpdate, self)
	Notifier.regist(GameEvent.OnCurrentClubChange, self.OnClubInfoUpdate, self)
	Notifier.regist(GameEvent.OnSelfClubNumUpdate, self.OnClubInfoUpdate, self)
	Notifier.regist(GameEvent.OnClubMemberUpdate, self.OnClubMemberUpdate, self)
	Notifier.regist(GameEvent.OnPlayerApplyClubChange, self.OnPlayerApplyClubChange, self)
end

function ClubInfoUI:OnClose()
	self.model:ClearMemberData()
	Notifier.remove(GameEvent.OnClubInfoUpdate, self.OnClubInfoUpdate, self)
	Notifier.remove(GameEvent.OnCurrentClubChange, self.OnClubInfoUpdate, self)
	Notifier.remove(GameEvent.OnSelfClubNumUpdate, self.OnClubInfoUpdate, self)
	Notifier.remove(GameEvent.OnClubMemberUpdate, self.OnClubMemberUpdate, self)
	Notifier.remove(GameEvent.OnPlayerApplyClubChange, self.OnPlayerApplyClubChange, self)
	
	if self.scrollAdCom then
		self.scrollAdCom:Clear()
		self.scrollAdCom = nil
	end
end

function ClubInfoUI:OnPlayerApplyClubChange()
	self.effectGo:SetActive(self.model:CheckShowApplyHint())
end

function ClubInfoUI:OnInvite()
	invite_sys.inviteToClub(self.clubInfo)
end


function ClubInfoUI:UpdateView()
	if self.clubInfo.ctype == 1 then
		self.memberView:SetActive(false)
		self.applyBtnGo:SetActive(false)		
		self:InitAdScrollView()
		self.adView:SetActive(true)
	else
		self.memberView:SetActive(true)
		self.adView:SetActive(false)
		self.applyBtnGo:SetActive(self.model:CheckCanSeeApplyList(self.clubInfo.cid))
	end
end

function ClubInfoUI:InitAdScrollView()
	if G_isAppleVerifyInvite then
		return
	end
	
	if not self.scrollAdCom then
		local ScrollAdComponent = require "logic/common/ScrollAdComponent"
		local texTbl = {}
		local adUrlTbl = global_define.adUrlTbl
		if adUrlTbl and not isEmpty(adUrlTbl) then
			for k,v in ipairs(adUrlTbl) do
				DownloadCachesMgr.Instance:LoadImage(v["icon"],function(code,texture,url)
					table.insert(texTbl,texture)
				end)	
			end
		else
			for i=5,8 do
				local tex = newNormalObjSync(data_center.GetAppConfDataTble().appPath.."/uitextures/ui/clubcy_0"..i, typeof(UnityEngine.Texture2D))
				table.insert(texTbl,tex)
			end
		end
		if not isEmpty(texTbl) then
			self.scrollAdCom = ScrollAdComponent:create(self:GetGameObject("adView/ScrollAdComponent"),function(index)
				local adConfigData = adUrlTbl[tonumber(index)]
				if adConfigData and not isEmpty(adConfigData) then
					if adConfigData["jumptype"] == 1 then
						jumpHelper.JumpToUI(adConfigData["uitype"])
						UIManager:CloseUiForms("ClubInfoUI")
					elseif adConfigData["jumptype"] == 2 then
						jumpHelper.JumpToUrl(adConfigData["hrefurl"])
					end
				end
			end,778,texTbl,true)
		end
	end
end

function ClubInfoUI:OnApplyBtnClick()
	UIManager:ShowUiForms("ClubApplyUI", nil,nil, self.clubInfo.cid, true)
end

function ClubInfoUI:OnClubMemberUpdate()
	self.memberView:UpdateView()
end

function ClubInfoUI:OnClubInfoUpdate()
	if self.model.currentClubInfo ~= nil and self.clubInfo.cid == self.model.currentClubInfo.cid then
		self.infoView.clubInfo = self.model.currentClubInfo
	end
	self:UpdateView()
	self.memberView:UpdateView()
	self.infoView:SetInfo(self.infoView.clubInfo)
end

function ClubInfoUI:OnCloseClick()
	ui_sound_mgr.PlayCloseClick()
	UIManager:CloseUiForms("ClubInfoUI")
end

function ClubInfoUI:PlayOpenAmination()

end

function ClubInfoUI:OnRefreshDepth()

  local uiEffect = child(self.gameObject.transform, "bg/top/tittle/Effect_chengyuan")
  if uiEffect and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
    Utils.SetEffectSortLayer(self.effectGo, topLayerIndex)
  end
end


return ClubInfoUI
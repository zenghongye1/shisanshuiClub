local base = require "logic/framework/ui/uibase/ui_view_base"
local ClubInfoView = class("ClubInfoView", base)
local ClubMemberState = ClubMemberState
local UIManager = UI_Manager:Instance() 

-- local bgHeight1 = 386
-- local bgHeight2 = 460

-- local panelRange1 = Vector4(133, -39, 738, 378)
-- local panelRange2 = Vector4(133, -75, 738, 450)

function ClubInfoView:InitView()
	self.clubInfo = nil
	self.model = model_manager:GetModel("ClubModel")
	self.curGids = nil
	self.curIconId = nil
	self.curLocationId = nil

	self.nameBtnGo = self:GetGameObject("btns/nameBtn")
	addClickCallbackSelf(self.nameBtnGo, self.OnNameBtnClick, self)
	self.idBtnGo = self:GetGameObject("btns/IdBtn")
	-- id
	self.locationBtnGo = self:GetGameObject("btns/locationBtn")
	addClickCallbackSelf(self.locationBtnGo, self.OnLocationBtnClick, self)
	self.gameBtnGo = self:GetGameObject("btns/gameBtn")
	addClickCallbackSelf(self.gameBtnGo, self.OnGameBtnClick, self)

	self.applyBtnGo = self:GetGameObject("enterBtn")
	addClickCallbackSelf(self.applyBtnGo, self.OnApplyBtnClick, self)
	self.btnLabel = self:GetComponent("enterBtn/Label", typeof(UILabel))


	self.bg = self:GetComponent("bgs/bg2", typeof(UISprite))


	self.nameInputLabel = self:GetComponent("labels/clubName", typeof(UIInput))
	-- EventDelegate.Add(self.nameInputLabel.onSubmit, EventDelegate.Callback(function() self:OnNameLabelEdit() end))
	self.copyBtnGo = self:GetGameObject("btns/copyBtn")
	addClickCallbackSelf(self.copyBtnGo,self.OnCopyBtnClick,self)
	self.idLabel = self:GetComponent("labels/ID", typeof(UILabel))
	
	self.locationLabel = self:GetComponent("labels/location", typeof(UILabel))
	self.gameLabel = self:GetComponent("labels/game", typeof(UILabel))

	self.changeIconBtnGo = self:GetGameObject("btns/changeIconBtn")
	addClickCallbackSelf(self.changeIconBtnGo,self.OnIconClick,self)

	self.toggleGo = self:GetGameObject("btns/toggleView")
	self.toggleSelectedGo = self:GetGameObject("btns/toggleView/selectIcon")
	self.toggleSelectedGo:SetActive(false)
	self.toggleGo:SetActive(false)
	addClickCallbackSelf(self.toggleGo, self.OnToggleClick, self)


	self.levelLabel = self:GetComponent("labels/level", typeof(UILabel))
	self.leaderNameLabel = self:GetComponent("labels/leaderName", typeof(UILabel))
	self.roomCardLabel = self:GetComponent("labels/roomCard", typeof(UILabel))
	self.memberLabel = self:GetComponent("labels/member", typeof(UILabel))
	self.scroll = self:GetComponent("scroll", typeof(UIScrollView))

	self.headIcon = self:GetComponent("headIcon", typeof(UISprite))
	addClickCallbackSelf(self.headIcon.gameObject, self.OnIconClick, self)
	self.bgSp = self:GetComponent("bgs/bg4", typeof(UISprite))
	self.scrollPanel = self:GetComponent("scroll", typeof(UIPanel))

end

function ClubInfoView:SetInfo(clubInfo)
	if clubInfo == nil then
		return
	end
	self.clubInfo = clubInfo
	self.curGids = clubInfo.gids
	self.curLocationId = tostring(clubInfo.position)
	self.curIconId = clubInfo.icon
	self.clubState = self.model:GetClubState(clubInfo.cid)
	self:UpdateView()
end

function ClubInfoView:UpdateView()
	self.leaderNameLabel.text= self.clubInfo.nickname
	self.nameInputLabel.value = self.clubInfo.cname
	self.idLabel.text = "ID:" .. self.clubInfo.shid
	self.levelLabel.text = tostring(self.clubInfo.level)
	self.roomCardLabel.text = tostring(self.clubInfo.card)
	if self.clubInfo.clubusernum == nil then
		self.clubInfo.clubusernum = 1
	end

	local iconName = ClubUtil.GetClubIconName(self.curIconId)
	self.headIcon.spriteName = iconName

	if self.clubInfo.ctype == 1 then
		self.memberLabel.text = self.clubInfo.clubusernum
		self.gameLabel.text = self.clubInfo.content or ""
	else
		self.memberLabel.text = self.clubInfo.clubusernum .. "/" .. self.clubInfo.maxusernum
		self.gameLabel.text = ClubUtil.GetGameContent(self.clubInfo.gids)
	end

	self.locationLabel.text = ClubUtil.GetLocationNameById(self.curLocationId)

	self:RefreshBtns()
	-- self:AdjustDeclarationView()
end

function ClubInfoView:RefreshBtns()
	self.nameBtnGo:SetActive(self.clubState == ClubMemberState.agent)
	self.locationBtnGo:SetActive(self.clubState == ClubMemberState.agent)
	self.gameBtnGo:SetActive(self.clubState == ClubMemberState.agent)
	self.applyBtnGo:SetActive(self.clubState ~= ClubMemberState.agent)
	self.changeIconBtnGo:SetActive(self.clubState == ClubMemberState.agent)
	self.toggleGo:SetActive(self.clubState == ClubMemberState.agent)

	if self.clubState == ClubMemberState.agent then
		self.toggleSelectedGo:SetActive(self.clubInfo.is_push == 1)
	end

	if self.clubState == ClubMemberState.agent then
		self.gameLabel.width = 272
	else
		self.gameLabel.width = 300
	end

	if self.clubState == ClubMemberState.agent then
		self.bg.height = 574
	else
		self.bg.height = 470
	end

	if self.clubState == ClubMemberState.none then
		self.btnLabel.text = "申请加入"
	elseif self.clubState == ClubMemberState.member then
		self.btnLabel.text = "退出俱乐部"

		if G_isAppleVerifyInvite then
			if self.applyBtnGo then
				self.applyBtnGo:SetActive(false)
			end
		end
	end
end

-- function ClubInfoView:AdjustDeclarationView()
-- 	if self.clubState == ClubMemberState.agent then
-- 		self.bgSp.height = bgHeight2
-- 		self.scrollPanel.baseClipRegion = panelRange2
-- 	else
-- 		self.bgSp.height = bgHeight1
-- 		self.scrollPanel.baseClipRegion = panelRange1
-- 	end
-- end


function ClubInfoView:OnNameBtnClick()
	ui_sound_mgr.PlayButtonClick()
	--self.nameInputLabel.isSelected = true
	UIManager:ShowUiForms("ClubNameInputUI", nil, nil, 2, self.nameInputLabel.value, function (tab, value )
		self.nameInputLabel.value = value
		self:OnNameLabelEdit()
	end, self)
end

function ClubInfoView:OnToggleClick()
	if not TimeLimitHelper.CheckTimeLimit("clubPush", 2) then
		UIManager:FastTip(LanguageMgr.GetWord(10100))
		return
	end

	local isPush = 0
	if  self.clubInfo.is_push  ~= 1 then
		isPush = 1
	end
	self.model:ReqEditClub(self.clubInfo.cid, nil, nil, nil, nil,nil, isPush)
end


function ClubInfoView:OnLocationBtnClick()
	ui_sound_mgr.PlayButtonClick()
	--UIManager:ShowUiForms("ClubGameSelectUI", nil, nil, ClubGameSelectEnum.locations, self.curLocationId, self.OnPositionSelected, self)
	UIManager:ShowUiForms("ProvinceSelectUI", nil, nil, ClubUtil.SupportProvinceList, self.OnProvinceSelected, self)
end

function ClubInfoView:OnProvinceSelected(province)
	UIManager:ShowUiForms("ClubGameSelectUI", nil, nil, ClubGameSelectEnum.locations, self.curLocationId, self.OnPositionSelected, self, province)
end


function ClubInfoView:OnGameBtnClick()
	ui_sound_mgr.PlayButtonClick()
	--UIManager:ShowUiForms("ClubGameSelectUI", nil, nil, ClubGameSelectEnum.games, self.curGids, self.OnGameSelected, self)
	UIManager:ShowUiForms("ClubGameChooseUI", nil, nil, self.curGids, self.OnGameSelected, self)
end

function ClubInfoView:OnIconClick()
	ui_sound_mgr.PlayButtonClick()
	if self.clubState ~= ClubMemberState.agent then
		return
	end
	UIManager:ShowUiForms("ClubIconSelectUI", nil, nil, self.curIconId, self.OnSelectIcon, self)
end

function ClubInfoView:OnSelectIcon(id)
	if id == self.curIconId then
		return
	end
	self.curIconId = id
	local iconName = ClubUtil.iconIdToNameMap[id]
	self.headIcon.spriteName = iconName
	self.model:ReqEditClub(self.clubInfo.cid, nil, nil, nil, self.curIconId, nil)
end


function ClubInfoView:CheckListIsSame(list1, list2)
	if #list1 ~= #list2 then
		return false
	end
	for i = 1, #list1 do
		for j = 1, #list2 do
			if list1[i] ~= list2[j] then
				return false
			end
		end
	end
	return true
end


-- function ClubInfoView:OnDeclarationBtnClick()
-- 	self.declarationInputLabel.isSelected = true
-- end

function ClubInfoView:OnApplyBtnClick()
	ui_sound_mgr.PlayButtonClick()
	if self.clubState == ClubMemberState.none then
		MessageBox.ShowYesNoBox(LanguageMgr.GetWord(10044, self.clubInfo.nickname, self.clubInfo.cname), 
			function()
				self.model:ReqApplyClub(self.clubInfo.shid)
			end)
	elseif self.clubState == ClubMemberState.member then
		MessageBox.ShowYesNoBox(LanguageMgr.GetWord(10043), function () 
			self.model:ReqQuitClub(self.clubInfo.cid)
--			UIManager:CloseUiForms("ClubInfoUI")
		end)
	end
end


function ClubInfoView:OnNameLabelEdit()
	if self.nameInputLabel.value ~= self.clubInfo.cname then
		if self.nameInputLabel.value == nil or self.nameInputLabel.value == "" then
			self.nameInputLabel.value = self.clubInfo.cname
			UIManager:FastTip(LanguageMgr.GetWord(10011))
			return
		end
		self.model:ReqEditClub(self.clubInfo.cid, self.nameInputLabel.value, nil, nil, nil, nil)
	end
end

-- function ClubInfoView:OnDeclarationEdit()
-- 	if self.declarationInputLabel.value ~= self.clubInfo.content then
-- 		self.model:ReqEditClub(self.clubInfo.cid, nil, self.declarationInputLabel.value, nil, nil, nil)
-- 	end
-- end

function ClubInfoView:OnGameSelected(gids)
	if self:CheckListIsSame(self.clubInfo.gids ,gids) then
		return
	end
	if gids == nil or #gids == 0 then
		UIManager:FastTip(LanguageMgr.GetWord(10013))
		return
	end
	self.curGids = gids
	self.gameLabel.text = ClubUtil.GetGameContent(self.curGids)
	self.model:ReqEditClub(self.clubInfo.cid, nil, nil, gids, nil, nil)
end

function ClubInfoView:OnPositionSelected(id)
	if self.curLocationId == id then
		UIManager:CloseUiForms("ProvinceSelectUI")
		return
	end
	if id == nil or id == 0 then
		UIManager:CloseUiForms("ProvinceSelectUI")
		return
	end
	self.curLocationId = id
	self.model:ReqEditClub(self.clubInfo.cid, nil, nil, nil, nil, id)
	self.locationLabel.text = ClubUtil.GetLocationNameById(id)
	UIManager:CloseUiForms("ProvinceSelectUI")
end

function ClubInfoView:OnCopyBtnClick()
	local str = self.clubInfo.shid
	Trace("Id --- OnCopyBtnClick:"..tostring(str))
	YX_APIManage.Instance:onCopy(str,function()UI_Manager:Instance():FastTip(GetDictString(6043))end)
end

return ClubInfoView
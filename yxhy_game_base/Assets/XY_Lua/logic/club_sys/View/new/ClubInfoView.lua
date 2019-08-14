local base = require "logic/framework/ui/uibase/ui_view_base"
local ClubAgentEditView = class("ClubAgentEditView", base)
local addClickCallbackSelf = addClickCallbackSelf

function ClubAgentEditView:InitView()
	self.model = model_manager:GetModel("ClubModel")
	self.gameLabel = self:GetComponent("game",  typeof(UILabel))
	self.gameBtnGo = self:GetGameObject("editGameBtn")
	addClickCallbackSelf(self.gameBtnGo, self.OnGameBtnClick, self)
	self.bgSp = self:GetComponent("bg1", typeof(UISprite))
	self.bgTr = self:GetGameObject("bg4").transform
end

function ClubAgentEditView:SetInfo(clubInfo, state)
	self.clubInfo = clubInfo
	self.curGids = ClubUtil.GetOpenClubGids(clubInfo.gids)
	self.state = state
	self.gameLabel.text = ClubUtil.GetGameContent(self.curGids)
	self.gameBtnGo:SetActive(self.state == ClubMemberState.agent)

	self:UpdateBg()
end

function ClubAgentEditView:UpdateBg()
	if self.state == ClubMemberState.agent then
		self.bgSp.height = 335
		LuaHelper.SetTransformLocalY(self.bgTr, -167)
	else
		self.bgSp.height = 298
		LuaHelper.SetTransformLocalY(self.bgTr, -130)
	end
end

function ClubAgentEditView:OnGameBtnClick()
	ui_sound_mgr.PlayButtonClick()
	UIManager:ShowUiForms("ClubGameChooseUI", nil, nil, self.curGids, self.OnGameSelected, self)
end

function ClubAgentEditView:OnGameSelected(gids)
	if self:CheckListIsSame(self.clubInfo.gids ,gids) then
		return
	end
	if gids == nil or #gids == 0 then
		UIManager:FastTip(LanguageMgr.GetWord(10013))
		return
	end
	self.curGids = ClubUtil.GetOpenClubGids(gids)
	self.gameLabel.text = ClubUtil.GetGameContent(self.curGids)
	self.model:ReqEditClub(self.clubInfo.cid, nil, nil, gids, nil, nil)
end

function ClubAgentEditView:CheckListIsSame(list1, list2)
	if #list1 ~= #list2 then
		return false
	end
	for i = 1, #list1 do
		for j = 1, #list2 do
			if list1[i] ~= list2[i] then
				return false
			end
		end
	end
	return true
end


local ClubNormalEditView = class("ClubNormalEditView", ClubAgentEditView)

function ClubNormalEditView:InitView()
	ClubAgentEditView.InitView(self)
	self.contactLabel = self:GetComponent("contact", typeof(UILabel))
	self.contentLabel = self:GetComponent("content", typeof(UILabel))

	self.contentBtnGo = self:GetGameObject("editContentBtn")
	addClickCallbackSelf(self.contentBtnGo, self.OnContentBtnClick, self)
	self.contactBtnGo = self:GetGameObject("editContactBtn")
	addClickCallbackSelf(self.contactBtnGo, self.OnContactBtnClick, self)
	self.copyBtnGo = self:GetGameObject('copyBtn')
	addClickCallbackSelf(self.copyBtnGo, self.OnCopyBtnClick, self)
end

function ClubNormalEditView:SetInfo(clubInfo, state)
	ClubAgentEditView.SetInfo(self, clubInfo, state)
	self.contentLabel.text = self.clubInfo.content
	self.contactLabel.text = self.clubInfo.club_phone
	self.copyBtnGo:SetActive(self.state ~= ClubMemberState.agent and clubInfo.club_phone ~= nil and clubInfo.club_phone ~= "")
	self.contentBtnGo:SetActive(self.state == ClubMemberState.agent)
	self.contactBtnGo:SetActive(self.state == ClubMemberState.agent)
end

function ClubNormalEditView:UpdateBg()
end

function ClubNormalEditView:OnContactBtnClick()
	ui_sound_mgr.PlayButtonClick()
	UIManager:ShowUiForms("ClubNameInputUI", nil, nil, 4, self.contactLabel.text, function (tab, value )
		self.contactLabel.text = value
		if value ~= self.clubInfo.club_phone then
			self.model:ReqEditClub(self.clubInfo.cid, nil, nil, nil, nil, nil, nil, value)
		end
	end, self, 20)
end

function ClubNormalEditView:OnContentBtnClick()
	ui_sound_mgr.PlayButtonClick()
	UIManager:ShowUiForms("ClubNameInputUI", nil, nil, 3, self.contentLabel.text, function (tab, value )
		self.contentLabel.text = value
		if value ~= self.clubInfo.content then
			self.model:ReqEditClub(self.clubInfo.cid, nil, value, nil, nil, nil, nil, nil)
		end
	end, self, 30)
end

function ClubNormalEditView:OnCopyBtnClick()
	local str = self.clubInfo.club_phone
	Trace("Id --- OnCopyBtnClick:"..tostring(str))
	YX_APIManage.Instance:onCopy(str,function()UI_Manager:Instance():FastTip(LanguageMgr.GetWord(6043))end)
end





local ClubInfoView = class("ClubInfoView", base)


function ClubInfoView:InitView()
	self.clubInfo = nil
	self.model = model_manager:GetModel("ClubModel")
	self.curIconId = nil
	self.curLocationId = nil

	self.clubNameLabel = self:GetComponent("clubName", typeof(UILabel))
	self.locationLabel = self:GetComponent("location", typeof(UILabel))
	self.leaderNameLabel = self:GetComponent("leaderName", typeof(UILabel))
	self.memberLabel = self:GetComponent("memeber", typeof(UILabel))
	self.idLabel = self:GetComponent("Id", typeof(UILabel))

	self.icon = self:GetComponent("icon", typeof(UISprite))
	self.changeBtnGo = self:GetGameObject("changeBtn")
	addClickCallbackSelf(self.changeBtnGo, self.OnIconClick, self)
	self.nameBtnGo = self:GetGameObject("editNameBtn")
	addClickCallbackSelf(self.nameBtnGo, self.OnNameBtnClick, self)
	self.locationBtnGo = self:GetGameObject("editLocationBtn")
	addClickCallbackSelf(self.locationBtnGo, self.OnLocationBtnClick, self)
	self.copyBtnGo = self:GetGameObject("copyBtn")
	addClickCallbackSelf(self.copyBtnGo, self.OnCopyBtnClick, self)

	self.exitBtnGo = self:GetGameObject("exitBtn")
	addClickCallbackSelf(self.exitBtnGo, self.OnExitBtnClick, self)

	self.agentEditView = ClubAgentEditView:create(self:GetGameObject("agentEditView"))
	self.normalEditView = ClubNormalEditView:create(self:GetGameObject("normalEditView"))

	--解散俱乐部按钮
	self.dissolutionBtnGo = self:GetGameObject("dissolutionBtn")
	if self.dissolutionBtnGo ~= nil then
		addClickCallbackSelf(self.dissolutionBtnGo, self.OnDissolutionBtnClick, self)
	end
end

function ClubInfoView:RegistEvent()
	Notifier.regist(GameEvent.OnClubInfoUpdate, self.OnClubInfoUpdate, self)
end

function ClubInfoView:RemoveEvent()
	Notifier.remove(GameEvent.OnClubInfoUpdate, self.OnClubInfoUpdate, self)
end

function ClubInfoView:OnClose()
end

function ClubInfoView:OnClubInfoUpdate()
	if self.clubInfo == nil then
		return
	end
	self.clubInfo = self.model.clubMap[self.clubInfo.cid]
	if self.clubInfo == nil then
		return
	end
	self:SetInfo(self.clubInfo)
end

function ClubInfoView:UpdateView()
	self.locationLabel.text = ClubUtil.GetLocationNameById(self.curLocationId)
	self.clubNameLabel.text = self.clubInfo.cname
	self.leaderNameLabel.text =  (self.clubInfo.nickname or "")
	self.idLabel.text = "ID" .. self.clubInfo.shid
	if self.clubInfo.ctype == 1 then
		self.memberLabel.text = self.clubInfo.clubusernum or 0
	else
		self.memberLabel.text =  (self.clubInfo.clubusernum or 0 ).. "/" .. (self.clubInfo.maxusernum or 0)
	end

	local iconName = ClubUtil.GetClubIconName(self.curIconId)
	self.icon.spriteName = iconName

	self.exitBtnGo:SetActive(self.clubState ~= ClubMemberState.agent and self.clubInfo.ctype ~= 1)

	self.nameBtnGo:SetActive(self.clubState == ClubMemberState.agent)
	self.changeBtnGo:SetActive(self.clubState == ClubMemberState.agent)
	self.locationBtnGo:SetActive(self.clubState == ClubMemberState.agent)

	if self.dissolutionBtnGo ~= nil then
		self.dissolutionBtnGo:SetActive(self.clubState == ClubMemberState.agent)
	end
end

function ClubInfoView:SetInfo(clubInfo)
	if clubInfo == nil then
		return
	end
	self.clubInfo = clubInfo
	self.clubState = self.model:GetClubState(self.clubInfo.cid)
	self.curLocationId = tostring(self.clubInfo.position)
	self.curIconId = self.clubInfo.icon

	self.agentEditView:SetActive(self.clubInfo.ctype ~= 2)
	self.normalEditView:SetActive(self.clubInfo.ctype == 2)
	if self.clubInfo.ctype == 2 then  -- 散人俱乐部
		self.normalEditView:SetInfo(clubInfo, self.clubState)
	else
		self.agentEditView:SetInfo(clubInfo, self.clubState)
	end


	self:UpdateView()
end


function ClubInfoView:OnOpen()
	
end

function ClubInfoView:OnCopyBtnClick()
	local str = self.clubInfo.shid
	Trace("Id --- OnCopyBtnClick:"..tostring(str))
	YX_APIManage.Instance:onCopy(str,function()UI_Manager:Instance():FastTip(LanguageMgr.GetWord(6043))end)
end

function ClubInfoView:OnNameBtnClick()
	ui_sound_mgr.PlayButtonClick()
	--self.nameInputLabel.isSelected = true
	UIManager:ShowUiForms("ClubNameInputUI", nil, nil, 2, self.clubNameLabel.text, function (tab, value )
		self.clubNameLabel.text = value
		self:OnNameLabelEdit()
	end, self, 100)
end

function ClubInfoView:OnNameLabelEdit()
	if self.clubNameLabel.text ~= self.clubInfo.cname then
		if self.clubNameLabel.text == nil or self.clubNameLabel.text == "" then
			self.clubNameLabel.text = self.clubInfo.cname
			UIManager:FastTip(LanguageMgr.GetWord(10011))
			return
		end
		self.model:ReqEditClub(self.clubInfo.cid, self.clubNameLabel.text, nil, nil, nil, nil)
	end
end

function ClubInfoView:OnIconClick()
	ui_sound_mgr.PlayButtonClick()
	if self.clubState ~= ClubMemberState.agent then
		return
	end
	UIManager:ShowUiForms("ClubIconSelectUI", nil, nil, self.curIconId, self.OnSelectIcon, self)
end

function ClubInfoView:OnLocationBtnClick()
	ui_sound_mgr.PlayButtonClick()
	UIManager:ShowUiForms("ClubLocationChooseUI", nil, nil, self.curLocationId, self.OnPositionSelected, self)
end


function ClubInfoView:OnSelectIcon(id)
	if id == self.curIconId then
		return
	end
	self.curIconId = id
	local iconName = ClubUtil.GetClubIconName(id)
	self.icon.spriteName = iconName
	self.model:ReqEditClub(self.clubInfo.cid, nil, nil, nil, self.curIconId, nil)
end


function ClubInfoView:OnPositionSelected(id)
	if self.curLocationId == id then
		return
	end
	if id == nil or id == 0 then
		return
	end
	self.curLocationId = id
	self.model:ReqEditClub(self.clubInfo.cid, nil, nil, nil, nil, id)
	self.locationLabel.text = ClubUtil.GetLocationNameById(id)
end

function ClubInfoView:OnExitBtnClick()
	MessageBox.ShowYesNoBox(LanguageMgr.GetWord(10043), function () 
			self.model:ReqQuitClub(self.clubInfo.cid)
		end)
end


--解散俱乐部按钮点击响应
function ClubInfoView:OnDissolutionBtnClick()
	MessageBox.ShowYesNoBox(LanguageMgr.GetWord(10301), function()
				self.model:ReqDissolutionClub(self.clubInfo.cid, self.clubInfo.cname)
			end)
end

return ClubInfoView
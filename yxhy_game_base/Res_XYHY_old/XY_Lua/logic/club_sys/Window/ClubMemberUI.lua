local base = require("logic.framework.ui.uibase.ui_window")
local ClubMemberUI = class("ClubMemberUI", base)
local addClickCallbackSelf = addClickCallbackSelf
local UIManager = UI_Manager:Instance() 
local ClubMemberEnum = ClubMemberEnum
local ToggleClass = require ("logic/club_sys/View/ToggleView")
local ClubMemberItem = require("logic/club_sys/View/ClubMemberItem")
local ButtonInfo = require("logic/club_sys/Data/ButtonInfo")
local ui_wrap = require "logic/framework/ui/uibase/ui_wrap"


function ClubMemberUI:OnInit()
	self.type = ClubMemberEnum.member
	self.model = model_manager:GetModel("ClubModel")
	self.itemList = {}
	self.closeBtn = self:GetGameObject("backBtn")
	addClickCallbackSelf(self.closeBtn, self.OnCloseClick, self)

	self.onlineLabel = self:GetComponent("onlineMemeber", typeof(UILabel))
	self.onlineLabel.gameObject:SetActive(false)

	self.lastLabelGo = self:GetGameObject("titles/label4")
	self.timeLabel = self:GetComponent("titles/label3", typeof(UILabel))
	self.lastLineGo = self:GetGameObject("lines/line3")

	self.adsBtnGo = self:GetGameObject("Texture")
	addClickCallbackSelf(self.adsBtnGo, self.OnAdsClick, self)

	self.scroll = self:GetComponent("scroll", typeof(UIScrollView))
	
	self.btnsView = require ("logic/club_sys/View/ClubBtnsView"):create(self:GetGameObject("btnsPanel"))
	self.btnsView:SetLimit(-208, 600, 600, -334)
	self.btnsView:SetActive(false)

	self:InitToggles()
	self:InitItem()

	self.wrap = ui_wrap:create(self:GetGameObject("container"))
	self.wrap:InitUI(108)
	self.wrap.OnUpdateItemInfo = function(go, rindex, index)  self:OnItemUpdate(go, index, rindex)  end
	self.wrap:InitWrap(0)

	self:UpdateType()
	-- self:InitWebView()
end

function ClubMemberUI:InitWebView()
	  local WebComponent = require "logic/common/WebComponent"
	  self.webView = WebComponent:create(self:GetGameObject("WebComponent"), "https://www.apple.com")
end

function ClubMemberUI:OnOpen(cid, type)
	self.cid = cid
	self.type = type or ClubMemberEnum.member
	self.isManager = self.model:CheckCanSeeApplyList(cid)
	if not self.isManager then
		self.type = ClubMemberEnum.member
	end
	self:RegistEvent()
	self.model:ReqGetClubUser(cid)
	if self.isManager then
		self.model:ReqGetClubApplyList(cid)
	end
	self:UpdateType()
	self:UpdateView()
	-- self.webView:Show()
end

function ClubMemberUI:OnClose()
	self:UnregistEvent()
	self.model:ClearMemberData()
	self.btnsView:SetActive(false)
	-- self.webView:Hide()
end

function ClubMemberUI:RegistEvent()
	Notifier.regist(GameEvent.OnClubMemberUpdate, self.OnMemberUpdate, self)
	Notifier.regist(GameEvent.OnClubApplyMemberUpdate, self.OnApplyMemberUpdate, self)
	Notifier.regist(GameEvent.OnClubInfoUpdate, self.OnClubInfoUpdate, self)
end

function ClubMemberUI:UnregistEvent()
	Notifier.remove(GameEvent.OnClubMemberUpdate, self.OnMemberUpdate, self)
	Notifier.remove(GameEvent.OnClubApplyMemberUpdate, self.OnApplyMemberUpdate, self)
	Notifier.remove(GameEvent.OnClubInfoUpdate, self.OnClubInfoUpdate, self)
end

function ClubMemberUI:CallUpdateView()
	local time = FrameTimer.New(
		function() 
			self:UpdateView()
		end,1,1)
	time:Start()
end

function ClubMemberUI:OnClubInfoUpdate()
	self:CallUpdateView()
end

function ClubMemberUI:OnMemberUpdate()
	if self.type == ClubMemberEnum.apply then
		return
	end
	self:CallUpdateView()
end

function ClubMemberUI:OnApplyMemberUpdate()
	if self.type == ClubMemberEnum.member or not self.isManager then
		return
	end
	self:CallUpdateView()
end

function ClubMemberUI:InitToggles()
	self.applyToggle = ToggleClass:create(self:GetGameObject("applyToggle"))
	self.applyToggle:InitToggle(ClubMemberEnum.apply, "button_02", "button_01", Color(72/255, 30/255, 9/255) ,Color(143/255, 74/255, 18/255))
	self.applyToggle:SetCallback(self.OnToggleClick, self)

	self.memberToggle = ToggleClass:create(self:GetGameObject("memberListToggle"))
	self.memberToggle:InitToggle(ClubMemberEnum.member, "button_02", "button_01", Color(72/255, 30/255, 9/255) ,Color(143/255, 74/255, 18/255))
	self.memberToggle:SetCallback(self.OnToggleClick, self)
end

function ClubMemberUI:InitItem()
	for i = 1, 5 do
		local go = self:GetGameObject("container/scrollview/ui_wrapcontent/item" .. i)
		local item = ClubMemberItem:create(go)
		item:SetCallback(self.OnItemClick, self)
		item:SetActive(false)
		table.insert(self.itemList, item)
	end
end

function ClubMemberUI:UpdateType()
	if self.isManager then
		self.applyToggle:SetSelect(self.type == ClubMemberEnum.apply, true)
		self.applyToggle:SetActive(true)
	else
		self.applyToggle:SetActive(false)
	end
	self.memberToggle:SetSelect(self.type == ClubMemberEnum.member, true)
	self.lastLineGo:SetActive(self.type == ClubMemberEnum.member)
	self.lastLabelGo:SetActive(self.type == ClubMemberEnum.member)
	if self.type == ClubMemberEnum.apply then
		self.timeLabel.text = "申请时间"
	else
		self.timeLabel.text = "入会时间"
	end
end

function ClubMemberUI:UpdateView()
	self.memberList = self.model:GetMemberListByType(self.type)
	-- if self.memberList == nil or #self.memberList == 0 then
	-- 	self:HideAllItem()
	-- 	return
	-- end
	local count = 0
	if self.memberList ~= nil then
		count = #self.memberList 
	end
	self.wrap:InitWrap(count)
	-- local count = #self.memberList
	-- if count >= 5 then
	-- 	self.wrapContent.minIndex = -count+1
	-- 	self.wrapContent.maxIndex = 0  
	-- 	for i = 1, #self.itemList do
	-- 		self:OnItemUpdate(nil, i, -i)
	-- 	end
	-- 	self.wrapContent.enabled = true
	-- else
	-- 	self.wrapContent.enabled = false
	-- 	local offsetY = 0
	-- 	local pos = self.itemList[1].transform.localPosition
	-- 	for i = 0, count - 1 do
	-- 		self:OnItemUpdate(nil,i, -i)
	-- 		pos.y = offsetY 
	-- 		self.itemList[i + 1].transform.localPosition = pos
	-- 		offsetY = offsetY - self.itemHeight
	-- 	end
	-- 	for i = count + 1, #self.itemList do
	-- 		self.itemList[i]:SetActive(false)
	-- 	end
	-- end
	-- self.scroll:ResetPosition()
end



function ClubMemberUI:OnToggleClick(toggle)
	if toggle.data == self.type then
		return
	end
	self.type = toggle.data
	self:UpdateType()
	self:UpdateView()
end

function ClubMemberUI:OnAdsClick()
end


function ClubMemberUI:OnCloseClick()
	ui_sound_mgr.PlayCloseClick()
	UIManager:CloseUiForms("ClubMemberUI")
end

function ClubMemberUI:PlayOpenAmination()
end

function ClubMemberUI:OnRefreshDepth()

  local uiEffect = child(self.gameObject.transform, "bg/top/Title/tittle/Effect_chengyuan")
  if uiEffect and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
  end
end

function ClubMemberUI:OnItemUpdate(go, index, rindex)
	if self.itemList[index] ~= nil then
		self.itemList[index]:SetInfo(self.type, self.memberList[rindex])
	end
end

function ClubMemberUI:HideAllItem()
	for i = 1, #self.itemList do
		self.itemList[i]:SetActive(false)
	end
end

function ClubMemberUI:OnItemClick(item)
	if self.type == ClubMemberEnum.apply then
		return
	end
	local info = item.info
	-- 非管理员
	if not self.model:CheckCanSeeApplyList(self.cid) then
		self:PlayerInfoAction(info)
		return
	end
	local buttonInfoTab = {}

	if self.model:IsClubCreater(self.cid) then
		buttonInfoTab = self:GetCreaterBtnInfos(info)
	else
		buttonInfoTab = self:GetManagerBtnInfo(info)
	end
	self.btnsView:Show(buttonInfoTab)
end

-- 代理商按钮列表
function ClubMemberUI:GetCreaterBtnInfos(info)
	local tab = {}
	tab[1] = self:GetPlayerBtnInfo(info)
	if info.uid == self.model.selfPlayerId then
		return tab
	end
	local btnInfo = nil
	if self.model:CheckCanSeeApplyList(self.cid, info.uid) then
		btnInfo = self:GetRemoveManagerBtnInfo(info)
	else
		btnInfo = self:GetSetManagerBtnInfo(info)
	end
	table.insert(tab, 1, btnInfo)
	btnInfo = self:GetQuitClubBtnInfo(info)
	table.insert(tab, 1, btnInfo)
	return tab
end

function ClubMemberUI:GetManagerBtnInfo(info)
	local tab = {}
	tab[1] = self:GetPlayerBtnInfo(info)
	if not self.model:IsClubManager(self.cid, info.uid) then
		table.insert(tab, 1,self:GetQuitClubBtnInfo(info))
	end
	return tab
end

function ClubMemberUI:GetPlayerBtnInfo(info)
	if self.playerBtnInfo == nil then
		self.playerBtnInfo = ButtonInfo:create()
		self.playerBtnInfo.text = "查看"
		self.playerBtnInfo.bgSp = "button_03"
		self.playerBtnInfo.callback = self.PlayerInfoAction
		self.playerBtnInfo.target = self
	end
	self.playerBtnInfo.data = info
	return self.playerBtnInfo
end

function ClubMemberUI:GetSetManagerBtnInfo(info)
	if self.setManagerBtnInfo == nil then
		self.setManagerBtnInfo = ButtonInfo:create()
		self.setManagerBtnInfo.text = "设为管理员"
		self.setManagerBtnInfo.bgSp = "button_03"
		self.setManagerBtnInfo.callback = self.SetManagerAction
		self.setManagerBtnInfo.target = self
	end
	self.setManagerBtnInfo.data = info
	return self.setManagerBtnInfo
end

function ClubMemberUI:GetRemoveManagerBtnInfo(info)
	if self.removeManagerBtnInfo == nil then
		self.removeManagerBtnInfo = ButtonInfo:create()
		self.removeManagerBtnInfo.text = "取消管理员"
		self.removeManagerBtnInfo.bgSp = "button_05"
		self.removeManagerBtnInfo.callback = self.RemoveManagerAction
		self.removeManagerBtnInfo.target = self
	end
	self.removeManagerBtnInfo.data = info
	return self.removeManagerBtnInfo
end

function ClubMemberUI:GetQuitClubBtnInfo(info)
	if self.quitClubBtnInfo == nil then
		self.quitClubBtnInfo = ButtonInfo:create()
		self.quitClubBtnInfo.text = "踢出俱乐部"
		self.quitClubBtnInfo.bgSp = "button_05"
		self.quitClubBtnInfo.callback = self.QuitClubAction
		self.quitClubBtnInfo.target = self
	end
	self.quitClubBtnInfo.data = info
	return self.quitClubBtnInfo
end


function ClubMemberUI:PlayerInfoAction(info)
	UIManager:ShowUiForms("personInfo_ui", nil, nil, info.uid)
end

function ClubMemberUI:SetManagerAction(info)
	MessageBox.ShowYesNoBox(LanguageMgr.GetWord(10046, info.nickname),
	function()
		self.model:ReqSetManager(self.cid, info.uid, 0)
	end)
end

function ClubMemberUI:RemoveManagerAction(info)
	MessageBox.ShowYesNoBox(LanguageMgr.GetWord(10047, info.nickname),
	function()
		self.model:ReqSetManager(self.cid, info.uid, 1)
	end)
end

function ClubMemberUI:QuitClubAction(info)
	if info == nil then
		return
	end
	MessageBox.ShowYesNoBox(LanguageMgr.GetWord(10048, info.nickname),
	function()
		self.model:ReqKickClubUser(self.cid, info.uid)
	end)
end


return ClubMemberUI
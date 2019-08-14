local base = require("logic.framework.ui.uibase.ui_window")
local ClubSelectUI = class("ClubSelectUI", base)
local ui_wrap = require "logic/framework/ui/uibase/ui_wrap"
local addClickCallbackSelf = addClickCallbackSelf
local UIManager = UI_Manager:Instance() 

function ClubSelectUI:OnInit()
	self.model = model_manager:GetModel("ClubModel")
	self.itemList = {}

	self.selectedGid = nil
	self.selectedLocation = nil

	self.createBtnGo = self:GetGameObject("createClubBtn")
	self.createBtnGo:SetActive(false)
	addClickCallbackSelf(self.createBtnGo, self.OnCreateBtnClick, self)
	self.searchBtnGo = self:GetGameObject("searchBtn")
	self.searchBtnGo:SetActive(false)
	addClickCallbackSelf(self.searchBtnGo, self.OnSearchBtnClick, self)
	self.scroll = self:GetComponent("container/scrollview", typeof(UIScrollView))

	self.gameBtnGo = self:GetGameObject("selectGameView/btnSelect")
	self.gameLabel = self:GetComponent("selectGameView/Label", typeof(UILabel))
	self.locationBtnGo = self:GetGameObject("selectLocationView/btnSelect")
	self.locationBtnGo:SetActive(false)
	self.locationLabel = self:GetComponent("selectLocationView/Label", typeof(UILabel))

	addClickCallbackSelf(self.gameBtnGo, self.OnGameBtnClick, self)
	addClickCallbackSelf(self.locationBtnGo, self.OnLocationClick, self)


	-- self.adsBtnGo = self:GetGameObject("Texture")
	-- addClickCallbackSelf(self.adsBtnGo, self.OnAdsClick, self)
	-- self.selectLocationView = require("logic/club_sys/View/SelectView"):
	-- create(self:GetGameObject("selectLocationView"))
	-- self.selectGameView = require("logic/club_sys/View/SelectView"):
	-- create(self:GetGameObject("selectGameView"))

	self.tipsGo = self:GetGameObject("tips")
	self.tipsLabel = self:GetComponent("tips", typeof(UILabel))
	self.tipsLabel.text = LanguageMgr.GetWord(10082)

	self:InitItemList()

	self.closeBtn = self:GetGameObject("backBtn")
	addClickCallbackSelf(self.closeBtn, self.OnCloseClick, self)

	self.wrap = ui_wrap:create(self:GetGameObject("container"))
	self.wrap:InitUI(108)
	self.wrap.OnUpdateItemInfo = function(go, rindex, index)  self:OnItemUpdate(go, index, rindex)  end
	self.wrap:InitWrap(0)

	-- self:InitWebView()
end


function ClubSelectUI:InitWebView()
	  local WebComponent = require "logic/common/WebComponent"
	  self.webView = WebComponent:create(self:GetGameObject("WebComponent"), "https://www.apple.com")
end

function ClubSelectUI:OnClose()
	self:UnregistEvent()
	-- self.selectGameView:Reset()
	-- self.selectLocationView:Reset()
	self:HideAllItems()
	-- self.webView:Hide()

	if self.scrollAdCom then
		self.scrollAdCom:Clear()
		self.scrollAdCom = nil
	end
end

function ClubSelectUI:OnOpen()
	self.scroll:ResetPosition()
	self:RegistEvent()
	self.model:ReqSearchClubList(self.selectedGid, self.selectedLocation)
	-- self.webView:Show()

	if G_isAppleVerifyInvite then
		return
	end
	
	if not self.scrollAdCom then
		local ScrollAdComponent = require "logic/common/ScrollAdComponent"
		local texTbl = {}
		for i =1,4 do 
			local tex = newNormalObjSync(data_center.GetAppConfDataTble().appPath.."/uitextures/ui/clubcy_0"..i, typeof(UnityEngine.Texture2D))
			table.insert(texTbl,tex)
		end
		if not isEmpty(texTbl) then
			local scrollSizeX = 406
			self.scrollAdCom = ScrollAdComponent:create(self:GetGameObject("ScrollAdComponent"),function(msg)
				--logError(tostring(msg))
			end,scrollSizeX,texTbl,true)
		end
	end
end

function ClubSelectUI:RegistEvent()
	Notifier.regist(GameEvent.OnSearchClubListReturn, self.OnClubListReturn, self)
end

function ClubSelectUI:UnregistEvent()
	Notifier.remove(GameEvent.OnSearchClubListReturn, self.OnClubListReturn, self)
end


function ClubSelectUI:OnClubListReturn(clubList)
	self.clubList = self.model.searchClubList
	self:CallUpdateView()
end

function ClubSelectUI:UpdateView()
	local count = 0
	self.tipsGo:SetActive(self.clubList == nil or #self.clubList == 0)
	if self.clubList ~= nil then
		count = #self.clubList
	end
	self.wrap:InitWrap(count)
end


function ClubSelectUI:InitItemList()
	for i = 1, 7 do
		local go = self:GetGameObject("container/scrollview/ui_wrapcontent/item" .. i)
		self.itemList[i] = require("logic/club_sys/View/ClubInfoItem"):create(go)
		self.itemList[i]:SetActive(false)
	end
end

function ClubSelectUI:CallUpdateView()
	local time = FrameTimer.New(
		function() 
			self:UpdateView()
		end,1,1)
	time:Start()
end


function ClubSelectUI:PlayOpenAmination()
end



function ClubSelectUI:OnCloseClick()
	ui_sound_mgr.PlayCloseClick()
	UIManager:CloseUiForms("ClubSelectUI")
end

function ClubSelectUI:OnAdsClick()
end


function ClubSelectUI:OnCreateBtnClick()
	if self.model:CanCreateClub() then
		UIManager:ShowUiForms("ClubCreateUI")
	else
		UIManager:ShowUiForms("ClubInputUI", nil, nil, ClubInputUIEnum.InputCode)
	end
end

function ClubSelectUI:OnSearchBtnClick()
	self.model:ReqSearchClubList(self.selectedGid, self.selectedLocation)
end

function ClubSelectUI:OnGameBtnClick()
	ui_sound_mgr.PlayButtonClick()
	UIManager:ShowUiForms("ClubGameSelectUI", nil, nil, ClubGameSelectEnum.allGame, self.selectedGid, self.OnGameSelected, self)
end

function ClubSelectUI:OnGameSelected(gid)
	if gid == nil or gid == 0 then
		self.gameLabel.text = "游戏选择"
		self.selectedGid = nil
	else
		self.gameLabel.text = GameUtil.GetGameName(gid)
		self.selectedGid = gid
	end
end

function ClubSelectUI:OnLocationClick()
	ui_sound_mgr.PlayButtonClick()
	UIManager:ShowUiForms("ClubGameSelectUI", nil, nil, ClubGameSelectEnum.locations, self.selectedLocation, self.OnLocationSelected, self, 1)
end

function ClubSelectUI:OnLocationSelected(id)
	self.selectedLocation = id
	self.locationLabel.text = ClubUtil.GetLocationNameById(id, "地区选择")
	self.model:ReqSearchClubList(self.selectedGid, self.selectedLocation)
end

function ClubSelectUI:OnItemUpdate(go, index, rindex)
	if self.itemList[index] ~= nil then
		self.itemList[index]:SetActive(true)
		self.itemList[index]:SetInfo(self.clubList[rindex], true)
	end
end

function ClubSelectUI:HideAllItems()
	for i = 1, #self.itemList do
		self.itemList[i]:SetActive(false)
	end
end

function ClubSelectUI:OnRefreshDepth()

  local uiEffect = child(self.gameObject.transform, "bg/top/Title/tittle/Effect_chengyuan")
  if uiEffect and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
  end
end

return ClubSelectUI
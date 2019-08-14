local base = require("logic.framework.ui.uibase.ui_window")
local ClubCreateUI = class("ClubCreateUI", base)
local addClickCallbackSelf = addClickCallbackSelf
local UIManager = UI_Manager:Instance() 
local LanguageMgr = LanguageMgr


function ClubCreateUI:OnInit()
	self.destroyType = UIDestroyType.Immediately
	self.model = model_manager:GetModel("ClubModel")
	self.gameIds = nil
	self.locationId = nil
	self.selectIconId = 1

	self.connection = self:GetGameObject("panel/connection")
	self.intro = self:GetGameObject("panel/intro")
	self.gamesBg = self:GetComponent("panel/games/bg", typeof(UISprite))

	self.nameInputLabel = self:GetComponent("panel/name/context", typeof(UIInput))
	self.nameLabel = self:GetComponent("panel/name/context", typeof(UILabel))
	self.locationLabel = self:GetComponent("panel/area/context", typeof(UILabel))
	self.gameLabel = self:GetComponent("panel/games/context", typeof(UILabel))
	self.connectionInputLabel = self:GetComponent("panel/connection/context", typeof(UIInput))
	self.connectionLabel = self:GetComponent("panel/connection/context", typeof(UILabel))
	self.introInputLabel = self:GetComponent("panel/intro/context", typeof(UIInput))
	self.introLabel = self:GetComponent("panel/intro/context", typeof(UILabel))

	self.defaultBtnLabelGo = self:GetGameObject("panel/createBtn/Label")
	self.defaultBtnLabelGo:SetActive(true)
	self.roomCardGo = self:GetGameObject("panel/createBtn/roomCard")
	self.roomCardGo:SetActive(false)

	self.roomCardLabel = self:GetComponent("panel/createBtn/roomCard/num", typeof(UILabel))

	-- self.headIcon = self:GetComponent("panel/headbg/headIcon", typeof(UISprite))
	-- addClickCallbackSelf(self.headIcon.gameObject, self.OnIconClick, self)

	self.createBtnGo = self:GetGameObject("panel/createBtn")
	addClickCallbackSelf(self.createBtnGo, self.OnCreateBtnClick, self)

	self.nameBtnGo = self:GetGameObject("panel/name/Btn")
	addClickCallbackSelf(self.nameBtnGo, self.OnNameBtnClick, self)
	-- self.changeIconBtn = self:GetGameObject("panel/btns/changeIconBtn")
	-- addClickCallbackSelf(self.changeIconBtn, self.OnIconClick, self)
	-- id
	self.locationBtnGo = self:GetGameObject("panel/area/Btn")
	addClickCallbackSelf(self.locationBtnGo, self.OnLocationBtnClick, self)
	self.gameBtnGo = self:GetGameObject("panel/games/Btn")
	addClickCallbackSelf(self.gameBtnGo, self.OnGameBtnClick, self)
	self.gameBtnGo = self:GetGameObject("panel/connection/Btn")
	addClickCallbackSelf(self.gameBtnGo, self.OnConnectionBtnClick, self)
	self.gameBtnGo = self:GetGameObject("panel/intro/Btn")
	addClickCallbackSelf(self.gameBtnGo, self.OnIntroBtnClick, self)

	self.closeBtnGo = self:GetGameObject("panel/Panel_Top/backBtn")
	addClickCallbackSelf(self.closeBtnGo, self.OnCloseBtnClick, self)
end

function ClubCreateUI:OnOpen()
	self.gameIds = nil
	self.locationId = nil
	self.selectIconId = 1
	self:ClearContent()
	self.cost = tonumber(self.model:GetCreateClubCost())
	self.roomCardGo:SetActive(self.cost ~= 0)
	self.roomCardLabel.text = "X" .. self.cost
	self.defaultBtnLabelGo:SetActive(self.cost == 0)
	if self.model:IsAgent() then
		self.connection:SetActive(false)
		self.intro:SetActive(false)
		self.gamesBg.height = 288
		self.gameLabel.height = 230
	else
		self.connection:SetActive(true)
		self.intro:SetActive(true)
		self.gamesBg.height = 60
		self.gameLabel.height = 38
	end
end

function ClubCreateUI:PlayOpenAmination()
end

function ClubCreateUI:OnClose()
	self.connectionInputLabel.value = ""
	self.connectionInputLabel.value = ""
end

function ClubCreateUI:CheckShowRoomCard()
	local list = model_manager:GetModel("ClubModel"):GetClubListByType(ClubMemberState.agent)
	if list == nil or #list == 0 then
		return false
	else
		return true
	end
end	

function ClubCreateUI:ClearContent()
	self.nameLabel.text = ""
	self.nameInputLabel.value = ""
	self.nameInputLabel.defaultText = LanguageMgr.GetWord(10001)

	self.locationLabel.text = LanguageMgr.GetWord(10003)
	self.gameLabel.text = LanguageMgr.GetWord(10004)
	self.connectionLabel.text = ""
	self.introLabel.text = ""
	self.introInputLabel.value = ""
	self.connectionInputLabel.value = ""
	self.curLocationId = 0
end

function ClubCreateUI:OnCloseBtnClick()
	ui_sound_mgr.PlayCloseClick()
	UIManager:CloseUiForms("ClubCreateUI")
end

function ClubCreateUI:OnNameBtnClick()
	ui_sound_mgr.PlayButtonClick()
	UIManager:ShowUiForms("ClubNameInputUI", nil, nil, 1, self.nameInputLabel.value, function (tab, value )
		self.nameInputLabel.value = value
	end, self, 100)
	-- self.nameInputLabel.isSelected = true
end

function ClubCreateUI:OnConnectionBtnClick()
	ui_sound_mgr.PlayButtonClick()
	UIManager:ShowUiForms("ClubNameInputUI", nil, nil, 4, self.connectionInputLabel.value, function (tab, value )
		self.connectionInputLabel.value = value
	end, self, 20)
end

function ClubCreateUI:OnIntroBtnClick()
	ui_sound_mgr.PlayButtonClick()
	UIManager:ShowUiForms("ClubNameInputUI", nil, nil, 3, self.introInputLabel.value, function (tab, value )
		self.introInputLabel.value = value
	end, self, 30)
end

function ClubCreateUI:OnLocationBtnClick()
	ui_sound_mgr.PlayButtonClick()
	UIManager:ShowUiForms("ClubLocationChooseUI",nil, nil, self.curLocationId, self.OnLocationSelected, self)
end

function ClubCreateUI:OnGameBtnClick()
	ui_sound_mgr.PlayButtonClick()
	UIManager:ShowUiForms("ClubGameChooseUI", nil, nil, self.gameIds, self.OnGameSelected, self)
end

-- function ClubCreateUI:OnIconClick()
-- 	ui_sound_mgr.PlayButtonClick()
-- 	UIManager:ShowUiForms("ClubIconSelectUI", nil, nil, self.selectIconId, self.OnSelectIcon, self)
-- end

function ClubCreateUI:OnSelectIcon(id)
	self.selectIconId = id
	local iconName = ClubUtil.iconIdToNameMap[id]
	-- self.headIcon.spriteName = iconName
end

function ClubCreateUI:OnGameSelected(ids)
	self.gameIds = ids
	self.gameLabel.text = ClubUtil.GetGameContent(ids)
end


function ClubCreateUI:OnLocationSelected(id)
	if self.locationId == id then
		return
	end
	if id == nil or id == 0 then
		return
	end
	self.locationId = id
	self.locationLabel.text = ClubUtil.GetLocationNameById(id)
end

function ClubCreateUI:OnCreateBtnClick()
	ui_sound_mgr.PlayButtonClick()
	if self.nameInputLabel.value == "" then
		UIManager:FastTip(LanguageMgr.GetWord(10011))
		return
	end

	if self.locationId == nil or self.locationId == 0 then
		UIManager:FastTip(LanguageMgr.GetWord(10012))
		return
	end

	if self.gameIds == nil or #self.gameIds == 0 then
		UIManager:FastTip(LanguageMgr.GetWord(10013))
		return
	end
	if self.cost > 0 then
		--TER0327-label
		local msgBox = MessageBox.ShowYesNoBox("[893609]创建个人俱乐部需消耗[-][AC1421]【" .. self.cost .. "钻石】[-][893609]，确定创建吗?[-]", 
			function ()
				if data_center.CheckRoomCard(self.cost) then
					self.model:ReqCreateClub(self.nameInputLabel.value, self.gameIds, self.introInputLabel.value, self.locationId, self.selectIconId, self.connectionInputLabel.value)
				end
			end)
		if msgBox and msgBox.EnableContentBBCode then
	        msgBox:EnableContentBBCode()
	    end
	else
		self.model:ReqCreateClub(self.nameInputLabel.value, self.gameIds, self.introInputLabel.value, self.locationId, self.selectIconId, self.connectionInputLabel.value)
	end
end

function ClubCreateUI:OnRefreshDepth()
  local uiEffect = child(self.gameObject.transform, "panel/Panel_Top/bg/top/title/Effect_youxifenxiang")
  -- local effect = self:GetGameObject("panel/anim_role")
  if uiEffect and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
    -- Utils.SetEffectSortLayer(effect, topLayerIndex)
  end
end

return ClubCreateUI
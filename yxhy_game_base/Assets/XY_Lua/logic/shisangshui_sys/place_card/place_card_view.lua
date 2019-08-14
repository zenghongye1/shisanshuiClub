local place_card_view = class("place_card_view")
function place_card_view:ctor(gameObject,controlObj)
	self.gameObject = gameObject
	self.transform = gameObject.transform
	self.controlObj = controlObj
	self.cardPlaceTranList = {}					--摆牌背景，包含位置
	self.dunDownBtn = {}
	self.placeCard = nil						--牌父节点Obj
	self.cardTranTbl = {}                       --13张牌数据
	self.timeLbl = nil
--	self.timeSpt = nil
	self.prepare = nil			--摆牌完成，跟取消按钮
	self.dunTipSpt = {}			--前，中，后 三墩牌的UISprite提示
	self.recommondCardTip = {}	--右边推荐牌型提示信息按钮
	self.recommondCardTipFirstActive = {} --推荐类型选中时提示内容
	self.recommondCardTipSecondActive = {}
	self.recommondCardTipThreeActive = {}
	self.recommondCardTipFirstDeactive = {} --推荐类型非选中时提示内容
	self.recommondCardTipSecondDeactive = {}
	self.recommondCardTipThreeDeactive = {}
	self.rommondGrid = nil
	self.cardTipBtn = {}
	self.cardTransByIndex = {}
end

function place_card_view:SetUpBgData()
	for i = 1, 13 do
		local up_bg_data = {}
		self.cardPlaceTranList[i] = up_bg_data
		up_bg_data.tran = child(self.transform, "place_card_panel/Panel_TopLeft/CardBg/"..i)
		up_bg_data.blank = true
		up_bg_data.card = nil
		up_bg_data.index = i
		addClickCallbackSelf(up_bg_data.tran.gameObject,self.controlObj.CardBgClick,self.controlObj)
		UIEventListener.Get(up_bg_data.tran.gameObject).parameter = up_bg_data
	end
end

function place_card_view:Initinfor()
	for i = 1, 13 do
		local up_bg_data = {}
		self.cardPlaceTranList[i] = up_bg_data
		up_bg_data.tran = child(self.transform, "place_card_panel/Panel_TopLeft/CardBg/"..i)
		up_bg_data.blank = true
		up_bg_data.card = nil
		up_bg_data.index = i
		addClickCallbackSelf(up_bg_data.tran.gameObject,self.controlObj.CardBgClick,self.controlObj)
		UIEventListener.Get(up_bg_data.tran.gameObject).parameter = up_bg_data
	end
	
	---依赖于返回大厅的清理摆牌ui重设置
	if player_data.GetGameId() == ENUM_GAME_TYPE.TYPE_PINGTAN_SSS or player_data.GetGameId() == ENUM_GAME_TYPE.TYPE_DuoGui_SSS then	--平潭和多鬼十三水
		self.placeCard = child(self.transform, "place_card_panel/Panel_Bottom/placeCard_PTSSS")
	else
		self.placeCard = child(self.transform, "place_card_panel/Panel_Bottom/placeCard")
	end
	if self.placeCard ~= nil then
		self.placeCard.gameObject:SetActive(true)
	end
	
	self.prepare = child(self.transform, "place_card_panel/Panel_Bottom/prepare")
	if self.prepare ~= nil then
		self.prepare.gameObject:SetActive(false)
	end
	self.errorTipLbl = child(self.prepare, "errorTipLbl")
	self.timeLbl =  componentGet(child(self.transform, "place_card_panel/Panel_TopLeft/Slider/timeLbl"), "UILabel")
--	self.timeSpt =  componentGet(child(self.transform, "Panel_TopLeft/Slider/Foreground"), "UISprite")
	local dunTip3 = child(self.transform, "place_card_panel/Panel_TopLeft/thirdDun")
	self.dunTipSpt[1] = dunTip3
	local dunTip2 = child(self.transform, "place_card_panel/Panel_TopLeft/secondDun")
	self.dunTipSpt[2] = dunTip2
	local dunTip1 = child(self.transform, "place_card_panel/Panel_TopLeft/firstDun")
	self.dunTipSpt[3] = dunTip1
	
	local dunTip3 = child(self.transform, "place_card_panel/Panel_TopLeft/thirdBtn")
	self.dunDownBtn[1] = dunTip3
	local DownBtn2 = child(self.transform, "place_card_panel/Panel_TopLeft/secondBtn")
	self.dunDownBtn[2] = DownBtn2
	local DownBtn1 = child(self.transform, "place_card_panel/Panel_TopLeft/firstBtn")
	self.dunDownBtn[3] = DownBtn1
	self.cardGrid = componentGet(child(self.transform, "place_card_panel/CardGrid"), "UIGrid")
	--推荐牌型的五个结点
	for i = 1,5  do
		local obj = child(self.transform, "place_card_panel/Panel_TopRight/recommond/cardType"..i)
		table.insert(self.recommondCardTip,obj)
		local first = componentGet(child(obj.transform,"firstCardLblCheck"), "UILabel")
		local second = componentGet(child(obj.transform,"secondCardLblCheck"), "UILabel")
		local three = componentGet(child(obj.transform,"thirdCardLblCheck"), "UILabel")

		local first1 = componentGet(child(obj.transform,"firstCardLbl"), "UILabel")
		local second1 =  componentGet(child(obj.transform,"secondCardLbl"), "UILabel")
		local three1 = componentGet(child(obj.transform,"thirdCardLbl"), "UILabel")
		table.insert(self.recommondCardTipFirstActive,first)
		table.insert(self.recommondCardTipSecondActive,second)
		table.insert(self.recommondCardTipThreeActive,three)

		table.insert(self.recommondCardTipFirstDeactive,first1)
		table.insert(self.recommondCardTipSecondDeactive,second1)
		table.insert(self.recommondCardTipThreeDeactive,three1)
	end
	self.rommondGrid = componentGet(child(self.transform, "place_card_panel/Panel_TopRight/recommond"), "UIGrid")
	self.closeTopRight = child(self.transform,"place_card_panel/Panel_TopRight/closeBtn")
	if self.closeTopRight ~= nil then
		addClickCallbackSelf(self.closeTopRight.gameObject,self.closeTopRightOnClick,self)
	end
	self.openTopRight = child(self.transform,"place_card_panel/openTopRight")
	self.goToSpecialViewBtn = child(self.transform,"place_card_panel/goToSpecialView")
	
	if self.openTopRight ~= nil then
		addClickCallback(self.openTopRight.gameObject,self.openTopRightOnClick,self)
	end
	if self.goToSpecialViewBtn ~= nil then
		addClickCallback(self.goToSpecialViewBtn.gameObject,self.openSpecialOnClick,self)
	end
	
	self.topLeft = child(self.transform,"place_card_panel/Panel_TopLeft")
	self.topRight = child(self.transform,"place_card_panel/Panel_TopRight")
	
end

function place_card_view:closeTopRightOnClick()
	PlayerPrefs.SetInt("isRecommondCard",0)
	if PlayerPrefs.GetInt("isRecommondCard") == 0 then
		self:SetTopRightState(false)
	end
end

function place_card_view:openTopRightOnClick()
	PlayerPrefs.SetInt("isRecommondCard",1)
	if PlayerPrefs.GetInt("isRecommondCard") == 1 then
		self:SetTopRightState(true)
	end
end

function place_card_view:openSpecialOnClick()
	UI_Manager:Instance():CloseUiForms("place_card")
	UI_Manager:Instance():ShowUiForms("prepare_special",UiCloseType.UiCloseType_CloseNothing,nil,card_data_manage.prepare_special_CardList,card_data_manage.isSpecial,card_data_manage.nSpecialScore,card_data_manage.prepare_recommendCards)
end

function place_card_view:SetGotoSpecialBtnShow(state)
	if self.controlObj.placeCardData.nSpecialType ~= nil and state then
		self.goToSpecialViewBtn.gameObject:SetActive(true)
	else
		self.goToSpecialViewBtn.gameObject:SetActive(false)
	end
	
end

function place_card_view:IsRecommondCard()
	if PlayerPrefs.HasKey("isRecommondCard")   then
	else
		PlayerPrefs.SetInt("isRecommondCard",0)
	end
	if PlayerPrefs.GetInt("isRecommondCard") == 0 then
		self:SetTopRightState(false)
	else
		self:SetTopRightState(true)
	end
end

function place_card_view:SetTopRightState(isShow)
	if isShow == true then
		if self.topRight.gameObject.activeSelf == true then
			self.openTopRight.gameObject:SetActive(false)
			self:SetGotoSpecialBtnShow(false)
			return
		end
		self.topRight.gameObject:SetActive(true)
		self.openTopRight.gameObject:SetActive(false)	
		self:SetGotoSpecialBtnShow(false)
		
		self.topLeft.localPosition = Vector3(-257,self.topLeft.localPosition.y,self.topLeft.localPosition.z)
		self:SetcardPlaceTranListTrans()
		self.rommondGrid:Reposition()
	else
		if self.topRight.gameObject.activeSelf == false then
			self.openTopRight.gameObject:SetActive(true)
			self:SetGotoSpecialBtnShow(true)
			return 
		end
		self.topRight.gameObject:SetActive(false)
		self.openTopRight.gameObject:SetActive(true)
		self:SetGotoSpecialBtnShow(true)
		
		self.topLeft.localPosition = Vector3(0,self.topLeft.localPosition.y,self.topLeft.localPosition.z)
		self:SetcardPlaceTranListTrans()
	end
end

function place_card_view:SetcardPlaceTranListTrans()
	for i,v in ipairs(self.cardTransByIndex) do
		local cardData = UIEventListener.Get(v).parameter
		if cardData.cardType == self.controlObj.placeCardData.CardType[3] then
		--	logError("cardData"..tostring(cardData.place_up_index))
			local pos = self.cardPlaceTranList[cardData.place_up_index].tran.transform.position
			v.transform.position = pos
			v.transform.localPosition = Vector3(v.transform.localPosition.x + self.controlObj.placeCardData.cardUpXOffset,v.transform.localPosition.y + self.controlObj.placeCardData.cardUpYOffset,v.transform.localPosition.z)
		end
	end
end

--注册事件
function place_card_view:registerevent()
	local cardTip1 = child(self.placeCard, "tips/cardTip1")
	if cardTip1 ~= nil then
		self.cardTipBtn[1] = cardTip1
		addClickCallbackSelf(cardTip1.gameObject,self.controlObj.BtnClick,self.controlObj)
	end
	local cardTip2 = child(self.placeCard, "tips/cardTip2")
	if cardTip2 ~= nil then
		self.cardTipBtn[2] = cardTip2
		addClickCallbackSelf(cardTip2.gameObject,self.controlObj.BtnClick,self.controlObj)
	end
	local cardTip3 = child(self.placeCard, "tips/cardTip3")
	if cardTip3 ~= nil then
		self.cardTipBtn[3] = cardTip3
		addClickCallbackSelf(cardTip3.gameObject,self.controlObj.BtnClick,self.controlObj)
	end
	local cardTip4 = child(self.placeCard, "tips/cardTip4")
	if cardTip4 ~= nil then
		self.cardTipBtn[4] = cardTip4
		addClickCallbackSelf(cardTip4.gameObject,self.controlObj.BtnClick,self.controlObj)
	end
	local cardTip5 = child(self.placeCard, "tips/cardTip5")
	if cardTip5 ~= nil then
		self.cardTipBtn[5] = cardTip5
		addClickCallbackSelf(cardTip5.gameObject,self.controlObj.BtnClick,self.controlObj)
	end
	local cardTip6 = child(self.placeCard, "tips/cardTip6")
	if cardTip6 ~= nil then
		self.cardTipBtn[6] = cardTip6
		addClickCallbackSelf(cardTip6.gameObject,self.controlObj.BtnClick,self.controlObj)
	end
	local cardTip7 = child(self.placeCard, "tips/cardTip7")
	if cardTip7 ~= nil then
		self.cardTipBtn[7] = cardTip7
		addClickCallbackSelf(cardTip7.gameObject,self.controlObj.BtnClick,self.controlObj)
	end
	local cardTip8 = child(self.placeCard, "tips/cardTip8")
	if cardTip8 ~= nil then
		self.cardTipBtn[8] = cardTip8
		addClickCallbackSelf(cardTip8.gameObject,self.controlObj.BtnClick,self.controlObj)
	end
	local cardTip9 = child(self.placeCard, "tips/cardTip9")
	if cardTip9 ~= nil then
		self.cardTipBtn[9] = cardTip9
		addClickCallbackSelf(cardTip9.gameObject,self.controlObj.BtnClick,self.controlObj)
	end
	local cardType1 = child(self.transform, "place_card_panel/Panel_TopRight/recommond/cardType1")
	if cardType1 ~= nil then
		addClickCallbackSelf(cardType1.gameObject,self.controlObj.BtnClick,self.controlObj)
	end
	local cardType2 = child(self.transform, "place_card_panel/Panel_TopRight/recommond/cardType2")
	if cardType2 ~= nil then
		addClickCallbackSelf(cardType2.gameObject,self.controlObj.BtnClick,self.controlObj)
	end
	local cardType3 = child(self.transform, "place_card_panel/Panel_TopRight/recommond/cardType3")
	if cardType3 ~= nil then
		addClickCallbackSelf(cardType3.gameObject,self.controlObj.BtnClick,self.controlObj)
	end
	local cardType4 = child(self.transform, "place_card_panel/Panel_TopRight/recommond/cardType4")
	if cardType4 ~= nil then
		addClickCallbackSelf(cardType4.gameObject,self.controlObj.BtnClick,self.controlObj)
	end
	local cardType5 = child(self.transform, "place_card_panel/Panel_TopRight/recommond/cardType5")
	if cardType5 ~= nil then
		addClickCallbackSelf(cardType5.gameObject,self.controlObj.BtnClick,self.controlObj)
	end
	local OkBtn = child(self.transform, "place_card_panel/Panel_Bottom/prepare/OkBtn")
	if OkBtn ~= nil then
		addClickCallbackSelf(OkBtn.gameObject,self.controlObj.BtnClick,self.controlObj)
	end
	local CancelBtn = child(self.transform, "place_card_panel/Panel_Bottom/prepare/CancelBtn")
	if CancelBtn ~= nil then
		addClickCallbackSelf(CancelBtn.gameObject,self.controlObj.BtnClick,self.controlObj)
	end
	
	local firstBtn = child(self.transform, "place_card_panel/Panel_TopLeft/firstBtn")
	if firstBtn ~= nil then
		addClickCallbackSelf(firstBtn.gameObject,self.controlObj.BtnClick,self.controlObj)
	end
	
	local secondBtn = child(self.transform, "place_card_panel/Panel_TopLeft/secondBtn")
	if secondBtn ~= nil then
		addClickCallbackSelf(secondBtn.gameObject,self.controlObj.BtnClick,self.controlObj)
	end
	
	local thirdBtn = child(self.transform, "place_card_panel/Panel_TopLeft/thirdBtn")
	if thirdBtn ~= nil then
		addClickCallbackSelf(thirdBtn.gameObject,self.controlObj.BtnClick,self.controlObj)
	end
	local bg2 = child(self.transform,"collider")
	if bg2 ~= nil then
		addClickCallbackSelf(bg2.gameObject,self.controlObj.DoubleBtnClick,self.controlObj)
	end
end

function place_card_view:DunTipShow(isShowBtn)
	for i = 1, 3 do
		self.dunDownBtn[i].gameObject:SetActive(isShowBtn)
	end
	local isShowSpt = true
	if isShowBtn then
		isShowSpt = false
	end
	for i = 1, 3 do
		self.dunTipSpt[i].gameObject:SetActive(isShowSpt)
	end
end

--按扭置灰
function place_card_view:BtnGray(trans, isCanClick)
	local enbale_bg = componentGet(child(trans, "Background"), "UISprite")
	local disable_bg = componentGet(child(trans, "Background (1)"), "UISprite")
	local active1 = child(trans, "active")
	local inactive = child(trans, "inactive")
	if isCanClick then
		enbale_bg.gameObject:SetActive(true)
		disable_bg.gameObject:SetActive(false)
		active1.gameObject:SetActive(true)
		inactive.gameObject:SetActive(false)
	else
		enbale_bg.gameObject:SetActive(false)
		disable_bg.gameObject:SetActive(true)
		active1.gameObject:SetActive(false)
		inactive.gameObject:SetActive(true)
	end
end

--相公提示
function place_card_view:XiangGongTip()
	local isXiangGong = self.controlObj.placeCardData:XiangGong()
	if self.errorTipLbl ~= nil then
		if isXiangGong == true then
			self.errorTipLbl.gameObject:SetActive(true)
		else
			self.errorTipLbl.gameObject:SetActive(false)
		end
	end
end

function place_card_view:PlaceCardFinish()
	if self.placeCard ~= nil then
		self.placeCard.gameObject:SetActive(false)
	end
	if self.prepare ~= nil then
		self.prepare.gameObject:SetActive(true)
	end
	self:XiangGongTip()
end

function place_card_view:DunBtnShow(placing_index)
	local dun_max_index, dun = self.controlObj.placeCardData:GetDun(placing_index)
	print(placing_index.."  dun_max_index:..  "..dun_max_index.."   dun: "..dun)
	if dun ~= 3 then
		for i = dun_max_index, dun_max_index - 4, -1 do
			if self.cardPlaceTranList[i].blank == false then
				self.dunDownBtn[dun].gameObject:SetActive(true)
				self.dunTipSpt[dun].gameObject:SetActive(false)
				return
			end
		end
		self.dunDownBtn[dun].gameObject:SetActive(false)
		self.dunTipSpt[dun].gameObject:SetActive(true)
	else
		for i = dun_max_index, 11, -1 do
			if self.cardPlaceTranList[i].blank == false then
				self.dunDownBtn[dun].gameObject:SetActive(true)
				self.dunTipSpt[dun].gameObject:SetActive(false)
				return
			end
		end
		self.dunDownBtn[dun].gameObject:SetActive(false)
		self.dunTipSpt[dun].gameObject:SetActive(true)
	end
end

function place_card_view:RecomondBtnNone()
	for i = 1, 4 do
		local tgl = componentGet(self.recommondCardTip[i], "UIToggle")
		tgl.value = false
		local selectSp = componentGet(child(self.recommondCardTip[i].transform, "bgCheck"), "UISprite")
		selectSp.color = Color.New(1, 1, 1, 0)
		selectSp = self.recommondCardTipFirstActive[i]
		selectSp.gameObject:SetActive(false)
		selectSp = self.recommondCardTipSecondActive[i]
		selectSp.gameObject:SetActive(false)
		selectSp = self.recommondCardTipThreeActive[i]
		selectSp.gameObject:SetActive(false)
		
		selectSp = self.recommondCardTipFirstDeactive[i]
		selectSp.gameObject:SetActive(true)
		selectSp = self.recommondCardTipSecondDeactive[i]
		selectSp.gameObject:SetActive(true)
		selectSp = self.recommondCardTipThreeDeactive[i]
		selectSp.gameObject:SetActive(true)
	end
end

function place_card_view:RecomondBtnInit(obj)
	local selectSp = componentGet(child(obj.transform, "bgCheck"), "UISprite")
	selectSp.color = Color.New(1, 1, 1, 1)
	selectSp = child(obj.transform, "secondCardLblCheck")
	selectSp.gameObject:SetActive(true)
	selectSp = child(obj.transform, "firstCardLblCheck")
	selectSp.gameObject:SetActive(true)
	selectSp = child(obj.transform, "thirdCardLblCheck")
	selectSp.gameObject:SetActive(true)
end

function place_card_view:RecomondBtnEnable(state)
	for i=1,4 do 
		local boxCollider = componentGet(self.recommondCardTip[i],"BoxCollider")
		if boxCollider then
			boxCollider.enabled = state
		end
	end
end

function place_card_view:ResetCardGrid()
	local count = self.cardGrid.transform.childCount-1 or 0
	for i=count,0,-1 do
		local cardTran = self.cardGrid.transform:GetChild(i)
		GameObject.DestroyImmediate(cardTran.gameObject)
	end
end

function place_card_view:OnClose()
	self.placeCard.gameObject:SetActive(true)
	self.prepare.gameObject:SetActive(false)
	self:RecomondBtnNone()
	self:ResetCardGrid()
	self.transform.localPosition = Vector3(0,0,0)
end

return place_card_view
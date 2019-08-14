--[[(* @Description: 创建摆牌组件
 * @Author:      xuemin.lin
 * @FileName:    place_card.lua
 * @DateTime:    2017-12-5
 ]]
local base = require("logic.framework.ui.uibase.ui_window")
local place_card = class("place_card",base)
function place_card:ctor()
	base.ctor(self)
	self.fingerSelectObjs = {}
	self.selectObjs = {}
	self.selectColor = Color(0.85,0.85,0.85)
	self.unSelectColor = Color(1,1,1)	
	self.shakeCount = 0 --震动频率计数
end

function place_card:OnInit()
	--self.placeCardData = require("logic.shisangshui_sys.place_card.place_card_data"):create()
	self.placeCardView = require("logic.shisangshui_sys.place_card.place_card_view"):create(self.gameObject,self)
	self.placeCardView:Initinfor()
	self.placeCardView:registerevent()
end

function place_card:OnOpen( ... )
	self.placeCardData = require("logic.shisangshui_sys.place_card.place_card_data"):create()
	self.placeCardView:SetUpBgData()
	if self.args == nil then
		logError("摆牌的数据没有传过来！！！！")
	end
	
	self.placeCardData.cardList = self.args[1]
	local sortCards = Array.CardSort(Array.Clone(self.args[1])) 	--排序用于load
	if #self.args > 1 then
		self.placeCardData.nSpecialType = self.args[2]
	end
	if room_data.GetRecommondCard() ~= nil then
		Trace("推荐牌2")
		self.placeCardData.recommend_cards = room_data.GetRecommondCard()
	end
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/dub/chupai_nv")
	self.placeCardData.place_index = 1
	--self.placeCardData.timeSecond = os.time() + 3
	
	self.placeCardData.left_card = Array.Clone(self.placeCardData.cardList)

	self:LoadAllCard(sortCards)
	self:TipsBtnShow(self.placeCardData.cardList)
	if self.placeCardData.recommend_cards ~= nil then
		self:RecommendCardUpdate()
		self.placeCardData.isRecommond = false
	else
		self.placeCardData.isRecommond = true
	end
	self.placeCardView:DunTipShow(false)
	self.placeCardView:RecomondBtnEnable(true)
	self.placeCardData.totalTime = roomdata_center.timersetting["chooseCardTypeTimeOut"]
	self:StartTimerEscape()

	self.placeCardView:IsRecommondCard()
end

function place_card:OnClose()
	Trace("摆牌隐藏")
	self.placeCardData.isRecommond = false
	self.placeCardData.selectUpCard = nil
	self.placeCardView.cardPlaceTranList = {}
	
	self.placeCardData.selectDownCards = {}
	self.placeCardData.recommend_cards = nil
	self.placeCardData.up_placed_cards = {[1] = {}, [2] = {}, [3] = {}} 
	self.placeCardData.first_auto_all_card = {}
	if self.placeCardView.cardTranTbl ~= nil then
		for i, v in pairs(self.placeCardView.cardTranTbl) do
			GameObject.Destroy(v.tran.gameObject);
		end
	end
	self.placeCardView.cardTranTbl = {}
	self.placeCardView:OnClose()
	self.fingerSelectObjs = {}
	self.selectObjs = {}
	self.placeCardView.cardTransByIndex = {}
	UI_Manager:Instance():CloseUiForms("prepare_special")
	self:StopTimerEscape()
end

--推荐牌给的慢
function place_card:SetRecommondCard(recommendCards)
	--logError("SetRecommondCard----------"..GetTblData(recommendCards))
	if self.placeCardData.isRecommond == true then
		self.placeCardData.recommend_cards = recommendCards
		Trace("推荐牌3")
		if self.placeCardData.recommend_cards ~= nil then
			self:RecommendCardUpdate()
		end
		self.placeCardView:DunTipShow(false)
		self.placeCardData.isRecommond = true
	end
end


function place_card:OnFingerHover(fingerHoverEvent)	
	if fingerHoverEvent.Selection ~= nil then
		if self.placeCardData.hoverObj == fingerHoverEvent.Selection then
			return
		else
			if fingerHoverEvent.Selection.tag == "Card" then
				local data = UIEventListener.Get(fingerHoverEvent.Selection.gameObject).parameter
				if data ~= nil and data.cardType == self.placeCardData.CardType[3] and self.placeCardData.hoverObj == nil then
					self:CardClick(fingerHoverEvent.Selection,true,true)
				else
					self.placeCardData.hoverObj = fingerHoverEvent.Selection
					table.insert(self.fingerSelectObjs,fingerHoverEvent.Selection.gameObject)
					local selectionObj = fingerHoverEvent.Selection.gameObject
					self:SetCardColor(selectionObj,self.selectColor)
					self:RemoveInvalidCard(self.fingerSelectObjs)
				end
				self.placeCardData.hoverObj = fingerHoverEvent.Selection
			end
		end
	end
	
end

function place_card:RemoveInvalidCard(cardList)
	
	local startIndex = 0
	local endIndex = 0
	if #cardList > 0 then
		local startObj = cardList[1]
		local endObj = cardList[#cardList]
	
		if tonumber(startObj.name) < tonumber(endObj.name) then
			startIndex = tonumber(startObj.name)
			endIndex = tonumber(endObj.name)
		else
			startIndex = tonumber(endObj.name)
			endIndex = tonumber(startObj.name)
		end
	end
	for i,v in ipairs(cardList) do
		if tonumber(v.name) < startIndex or tonumber(v.name) > endIndex then
			self:SetCardColor(v.gameObject,self.unSelectColor)
			table.remove(cardList,i)
		end
	end
	local count = #self.placeCardView.cardTransByIndex
	if startIndex > 0 and startIndex <= count and endIndex > 0 and endIndex <= count then
		for i = startIndex, endIndex  do
			local obj = self.placeCardView.cardTransByIndex[i]
			local data = UIEventListener.Get(obj).parameter
			if data ~= nil and data.cardType == self.placeCardData.CardType[3]  then
			else
			
			self:SetCardColor(obj,self.selectColor)
			end
		end
	end
end

function place_card:OnFingerUp(fingerUpEvent)
	--暂时注释2017-12-27
--	Trace("Lua fingerUpEvent++++++++++")
	self.placeCardData.hoverObj = nil
	
	local startObj = nil
	local endObj = nil
	local startIndex = 0
	local endIndex = 0
	if #self.fingerSelectObjs > 0 then
		startObj = self.fingerSelectObjs[1]
		endObj = self.fingerSelectObjs[#self.fingerSelectObjs]
	
		if tonumber(startObj.name) < tonumber(endObj.name) then
			startIndex = tonumber(startObj.name)
			endIndex = tonumber(endObj.name)
		else
			startIndex = tonumber(endObj.name)
			endIndex = tonumber(startObj.name)
		end
		local count = #self.placeCardView.cardTransByIndex
		
		if startIndex > 0 and startIndex <= count and endIndex > 0 and endIndex <= count then
			for i = startIndex, endIndex  do
				local obj = self.placeCardView.cardTransByIndex[i]
				table.insert(self.selectObjs,obj)
			
				self:SetCardColor(obj,self.selectColor)
			end
		end
		
		if #self.selectObjs > 0 then
	--		Trace("selectObj count22 : "..#self.selectObjs)
			
			for i,v in ipairs(self.selectObjs) do
--				logError("selectObj name:"..v.name)
				local data = UIEventListener.Get(v.gameObject).parameter
				if data ~= nil and data.cardType == self.placeCardData.CardType[3]  then
				else
					self:CardClick(v.gameObject, true, true)
					self:SetCardColor(v.gameObject,self.unSelectColor)
				end
			end
		end
	
	end
	for i,v in ipairs(self.placeCardView.cardTransByIndex) do
		
		self:SetCardColor(v,self.unSelectColor)
	
	end
	self.fingerSelectObjs = {}
	self.selectObjs = {}
	
end

function place_card:SetCardColor(go,color)
	if go ~= nil then
		local bg = child(go.transform,"bg")
		local bg_sprite = componentGet(bg,"UISprite")
		if bg_sprite ~= nil then
			bg_sprite.color = color
		end
	end
end

function place_card:OnSwipe(myself,direction,fingerSwipe)
	Trace("Direction:"..tostring(direction))
	if tostring(direction) == "Down" then
	end
end

--[[function place_card:SetOutTime(timeo)
	self.placeCardData.timeSecond = timeo
end--]]
	
--显示最下边的提示按钮
function place_card:TipsBtnShow(cards)
	local normal_cards, nLaziCount, laiziCards = self.placeCardData:GetallCardType(Array.Clone(cards))
	local bFound, temp = sss_recommendHelper.GetLibRecomand():Get_Pt_Straight_Flush_Laizi_second(Array.Clone(normal_cards), nLaziCount)

	self.placeCardView:BtnGray(self.placeCardView.cardTipBtn[1], bFound)
	
	bFound, temp = sss_recommendHelper.GetLibRecomand():Get_Pt_Four_Laizi_second(Array.Clone(normal_cards), nLaziCount)
	self.placeCardView:BtnGray(self.placeCardView.cardTipBtn[2], bFound)
	
	bFound, temp = sss_recommendHelper.GetLibRecomand():Get_Pt_Full_Hosue_Laizi_second(Array.Clone(normal_cards), nLaziCount)
	
	self.placeCardView:BtnGray(self.placeCardView.cardTipBtn[3], bFound)
	
	bFound, temp = sss_recommendHelper.GetLibRecomand():Get_Pt_Flush_Laizi_second(Array.Clone(normal_cards), nLaziCount)
	self.placeCardView:BtnGray(self.placeCardView.cardTipBtn[4], bFound)
	
	bFound, temp = sss_recommendHelper.GetLibRecomand():Get_Pt_Straight_Laizi_second(Array.Clone(normal_cards), nLaziCount)
	self.placeCardView:BtnGray(self.placeCardView.cardTipBtn[5], bFound)
	
	bFound, temp = sss_recommendHelper.GetLibRecomand():Get_Pt_Three_Laizi_second(Array.Clone(normal_cards), nLaziCount)
	self.placeCardView:BtnGray(self.placeCardView.cardTipBtn[6], bFound)
	
	bFound, temp = sss_recommendHelper.GetLibRecomand():Get_Pt_Five_Laizi_second(Array.Clone(normal_cards), nLaziCount)
	self.placeCardView:BtnGray(self.placeCardView.cardTipBtn[7], bFound)
	
	bFound, temp = sss_recommendHelper.GetLibRecomand():Get_Pt_One_Pair_Laizi_second(Array.Clone(normal_cards),nLaziCount)
	self.placeCardView:BtnGray(self.placeCardView.cardTipBtn[8],bFound)
	
	if player_data.GetGameId() == ENUM_GAME_TYPE.TYPE_PINGTAN_SSS or player_data.GetGameId() == ENUM_GAME_TYPE.TYPE_DuoGui_SSS then
		bFound, temp = sss_recommendHelper.GetLibRecomand():Get_Pt_Six_Laizi_second(Array.Clone(normal_cards),nLaziCount)
		self.placeCardView:BtnGray(self.placeCardView.cardTipBtn[9],bFound)
	end
end

--加载13张牌
function place_card:LoadAllCard(cards)
	local CardGrid = child(self.transform, "place_card_panel/CardGrid")
	if CardGrid == nil then
		logError("place_card CardGrid == nil")
		return
	end
	
---分离重复牌，用于区别相同牌的cardTran，设定为每额外多一个+100
	local cardTranIndexTbl = Array.Clone(cards)
	self.placeCardData:FindSameCard(cardTranIndexTbl)
	
	for i = 1, #cards do
		local card = cards[i]
		local card_data = {}
		card_data.tran = poker2d_factory.GetPoker(tostring(card))
		card_data.tran.transform:SetParent(CardGrid,false)
		if card_data.tran == nil then
			UI_Manager:Instance():FastTip(LanguageMgr.GetWord(6045)..tostring(card))
			break
		end
		self.placeCardView.cardTranTbl[cardTranIndexTbl[i]] = card_data
		local k = i - 1
		card_data.tran.transform.localPosition = Vector3.New(-558 + 93 * k, 0, 0)
		card_data.tran.transform.localScale = self.placeCardData.cardDownScale
		card_data.tran.name = tostring(i)
		card_data.pos = Vector3.New(-558 + 93 * k, 0, -0.1 * i)
		card_data.name = tostring(i)
		card_data.index = i
			
		local boxCollider = componentGet(card_data.tran.transform,"BoxCollider")
		if boxCollider ~= nil then
			boxCollider.size = Vector3(144,198,i+1)
		end
		
		local object2 = card_data.tran
		local cardData = {}
		cardData.card = cards[i]
		cardData.down_index = i
		cardData.up_index = 0
		cardData.cardType = self.placeCardData.CardType[1]
		cardData.tran = card_data.tran
		cardData.pos = card_data.pos
		componentGet(child(card_data.tran.transform, "bg"),"UISprite").depth = i * 2 + 3
		componentGet(child(card_data.tran.transform, "num"),"UISprite").depth = i * 2 + 5
		componentGet(child(card_data.tran.transform, "color1"),"UISprite").depth = i * 2 + 5
		componentGet(child(card_data.tran.transform, "color2"),"UISprite").depth = i * 2 + 5
		componentGet(child(card_data.tran.transform, "guanghuan"),"UISprite").depth = i * 2 + 4
		if roomdata_center.gamesetting["nBuyCode"] > 0 and card == card_define.GetCodeCard() then
			child(card_data.tran.transform,"ma").gameObject:SetActive(true)
			componentGet(child(card_data.tran.transform, "ma"),"UISprite").depth = i * 2 + 4
		end
		UIEventListener.Get(card_data.tran.gameObject).parameter = cardData
		
		table.insert(self.placeCardView.cardTransByIndex, card_data.tran.gameObject)
	end
end

--点击牌
function place_card:CardClick(obj, fast, hover)
	
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/chupai")
	if self.placeCardData.animationMove then
		Trace("animationMove")
		return
	end
	local cardData = UIEventListener.Get(obj).parameter
	if cardData == nil then
		logError("-----cardData = nil-----")
		return
	end
	local cardNowType = cardData.cardType
	local cardNum = cardData.card
	Trace("self.placeCardData.CardType: "..tostring(cardNowType).."  num: "..cardNum)
	if(tonumber(cardNowType) == self.placeCardData.CardType[1]) then
		self.placeCardData.bottonSelectCardsBtn = 0
		if hover ~= nil and hover == true then
			local pos = obj.transform.localPosition
			obj.transform.localPosition = Vector3.New(pos.x, self.placeCardData.cardClickMoveY, pos.z)
		else
			obj.transform:DOLocalMoveY(self.placeCardData.cardClickMoveY, self.placeCardData.animationSmallTime, true)
		end
		local selectDownCardData = {}
		cardData.cardType = self.placeCardData.CardType[2]
		table.insert(self.placeCardData.selectDownCards, cardData)
		UIEventListener.Get(obj).parameter = cardData
	elseif (tonumber(cardNowType) == self.placeCardData.CardType[2]) then
		self.placeCardData.bottonSelectCardsBtn = 0
		if hover ~= nil and hover == true then
			local pos = obj.transform.localPosition
			obj.transform.localPosition = Vector3.New(pos.x, 0, pos.z)
		else
			obj.transform:DOLocalMoveY(0, self.placeCardData.animationSmallTime, true)
		end
		local selectDownCardData = {}
		cardData.cardType = self.placeCardData.CardType[1]
		UIEventListener.Get(obj).parameter = cardData
		local indexKey = self.placeCardData:GetDownCardKey(cardData)
		table.remove(self.placeCardData.selectDownCards, indexKey)
	else
		if obj.transform.localScale ~= self.placeCardData.cardUpScale then
			Trace("换牌错误")
			return
		end
		if self.placeCardData.selectUpCard == nil then
			if #self.placeCardData.selectDownCards == 1 then
				local selectCardData = UIEventListener.Get(self.placeCardData.selectDownCards[1].tran.gameObject).parameter
				local pos = selectCardData.tran.transform.localPosition
				obj.transform:DOLocalMove(Vector3.New(pos.x, 0, pos.z), self.placeCardData.animationTime, true)
				obj.transform:DOScale(self.placeCardData.cardDownScale, self.placeCardData.animationTime)
				selectCardData.tran.transform:DOLocalMove(obj.transform.localPosition, self.placeCardData.animationTime, true)
				selectCardData.tran.transform:DOScale(self.placeCardData.cardUpScale, self.placeCardData.animationTime)
				
				local _, dun, dun_no = self.placeCardData:GetDun(cardData.up_index)
				self.placeCardData.up_placed_cards[dun][dun_no] = selectCardData
				selectCardData.up_index = cardData.up_index
				selectCardData.cardType = self.placeCardData.CardType[3]
				cardData.up_index = 0
				cardData.cardType = self.placeCardData.CardType[1]
				self.placeCardData:UpdateLeftCard(self.placeCardData.left_card, self.placeCardData.selectDownCards[1].card)
				table.insert(self.placeCardData.left_card, cardData.card)
				self.placeCardData.selectDownCards[1] = nil
				self.placeCardData.selectDownCards = {}
				self:TipsBtnShow(self.placeCardData.left_card)
				self.placeCardData.animationMove = true
				coroutine.start(function ()
						coroutine.wait(self.placeCardData.animationWaitTime)
						Trace("fast1: "..tostring(fast))			
						self.placeCardView.cardGrid:Reposition()
						coroutine.wait(self.placeCardData.animationWaitTime)
						self.placeCardData.animationMove = false
					end)
			else
				self.placeCardData.selectUpCard = obj
				child(self.placeCardData.selectUpCard.transform, "guanghuan").gameObject:SetActive(true)
				UIEventListener.Get(self.placeCardData.selectUpCard.gameObject).parameter = cardData
				return
			end
		else
			--换牌
			local selectCardData = UIEventListener.Get(self.placeCardData.selectUpCard.gameObject).parameter
			obj.transform:DOLocalMove(self.placeCardData.selectUpCard.transform.localPosition, self.placeCardData.animationTime, true)
			self.placeCardData.selectUpCard.transform:DOLocalMove(obj.transform.localPosition, self.placeCardData.animationTime, true)
			
			local _, dun, dun_no = self.placeCardData:GetDun(cardData.up_index)
			local _select, select_dun, select_dun_no = self.placeCardData:GetDun(selectCardData.up_index)
			self.placeCardData.up_placed_cards[dun][dun_no], self.placeCardData.up_placed_cards[select_dun][select_dun_no] = 
				self.placeCardData.up_placed_cards[select_dun][select_dun_no], self.placeCardData.up_placed_cards[dun][dun_no]
				
			cardData.up_index, selectCardData.up_index = selectCardData.up_index, cardData.up_index
			self.placeCardData.animationMove = true
			coroutine.start(function()
					coroutine.wait(self.placeCardData.animationWaitTime)
					self.placeCardData.animationMove = false
				end)
			child(self.placeCardData.selectUpCard.transform, "guanghuan").gameObject:SetActive(false)
			self.placeCardData.selectUpCard = nil
			if self.placeCardData.place_index >= 14 then
				self.placeCardView:XiangGongTip()
			end
		end
	end
--	Trace("fast1: "..tostring(fast))
	if fast == nil or fast == false then
		self.placeCardData.animationMove = true
		coroutine.start(function ()
			coroutine.wait(self.placeCardData.animationWaitTime)
			Trace("fast2: "..tostring(fast))
			self.placeCardData.animationMove = false
		end
		)
	end
end

--点击空白可摆牌处
function place_card:CardBgClick(obj)
	if self.placeCardData.animationMove then
		return
	end
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/chupai")
	local place_up_index = tonumber(obj.name)
	local select_num = 0
	for i, v in ipairs(self.placeCardData.selectDownCards) do
		if v ~= nil then
			select_num = select_num + 1
		end
	end
	if select_num == 0 then
		return
	end
	local place_up_max = self:GetMaxFromPosInDun(place_up_index)
	if select_num > place_up_max then
		local CanPlaceMaxPos = self:GetMaxPosInDun (place_up_index)
		if select_num > CanPlaceMaxPos then
			Trace("select_num: "..tostring(select_num).." PosNUM: "..tostring(CanPlaceMaxPos))
			MessageBox.ShowSingleBox(LanguageMgr.GetWord(6035))
			return
		else
			place_up_index = self.placeCardData:GetMinDun(place_up_index)
		end
	end
	self.placeCardData.selectDownCards = self.placeCardData:CardUpSort(self.placeCardData.selectDownCards)
    local place, dun = self.placeCardData:GetDun(place_up_index)
	for i, v in ipairs(self.placeCardData.selectDownCards) do
		if self.placeCardData.place_index > 13 then
			return
		end

		for i = place_up_index, 13 do
			if self.placeCardView.cardPlaceTranList[place_up_index].blank == true then
				break
			else
				place_up_index = place_up_index + 1
			end
		end
		self.placeCardView.cardPlaceTranList[place_up_index].blank = false
		self.placeCardView.cardPlaceTranList[place_up_index].card = v.card
		
		local cardData = UIEventListener.Get(v.tran.gameObject).parameter
		local cardNum = cardData.card
		cardData.place_up_index = place_up_index
		local pos = self.placeCardView.cardPlaceTranList[place_up_index].tran.transform.position
		v.tran.transform:DOMove(pos,self.placeCardData.animationTime/2,false):OnComplete(function()
				v.tran.transform.localPosition = Vector3(v.tran.transform.localPosition.x + self.placeCardData.cardUpXOffset,v.tran.transform.localPosition.y + self.placeCardData.cardUpYOffset,v.tran.transform.localPosition.z)
		end)
		v.tran.transform:DOScale(self.placeCardData.cardUpScale, self.placeCardData.animationSmallTime)
		cardData.cardType = self.placeCardData.CardType[3]
		cardData.up_index = place_up_index
		UIEventListener.Get(v.tran.gameObject).parameter = cardData
		self.placeCardData:UpdateLeftCard(self.placeCardData.left_card, cardData.card)
		
		local dun, dun_no = self.placeCardData:GetDunNo(place_up_index)
		self.placeCardData.up_placed_cards[dun][dun_no] = cardData
		self.placeCardData.place_index = self.placeCardData.place_index + 1
		if self.placeCardData.place_index == 14 then
			self.placeCardView:PlaceCardFinish()
			break
		end
		place_up_index = place_up_index + 1
		 	end
	for k,v in ipairs(self.placeCardData.selectDownCards) do
		self.placeCardData.selectDownCards[k] = nil
	end
	self.placeCardData.allCardTypeIndex = 0
	self.placeCardData.selectDownCards = {}
	self.placeCardView:DunBtnShow(place_up_index - 1)
	self:TipsBtnShow(self.placeCardData.left_card)
	self:BuPai()

	self.placeCardData.animationMove = true
	coroutine.start(function ()
		coroutine.wait(self.placeCardData.animationWaitTime)
		self.placeCardView.cardGrid:Reposition()
		coroutine.wait(self.placeCardData.animationWaitTime)
		self.placeCardData.animationMove = false
	end
	)
end

function place_card:GetMaxPosInDun(index)
	local place_max = self.placeCardData:GetMinDun(index)
	local now_num = 0
	local num = 4
	if index > 10 then
		num = 2
	end
	for i = place_max, place_max + num do
		if self.placeCardView.cardPlaceTranList[i].blank == true then
			now_num = now_num + 1
		end
	end
	Trace("max_pos_plaxe_card_num: "..place_max)
	return now_num
end
 
function place_card:GetMaxFromPosInDun(index)
	local place_max = self.placeCardData:GetDun(index)
	local now_num = 0
	for i = index, place_max do
		if self.placeCardView.cardPlaceTranList[i].blank == true then
			now_num = now_num + 1
		end
	end
	Trace("max_pos_plaxe_card_num: "..place_max)
	return now_num
end

--按扭响应
function place_card:BtnClick(obj)
	if self.placeCardData.animationMove then
		return
	end
	--同花顺
	if obj.name == "cardTip1" then
		local active1 = child(obj.transform, "active")
		if active1.gameObject.activeSelf == false then
			return
		end
		local normal_cards, nLaziCount, laiziCards = self.placeCardData:GetallCardType(Array.Clone(self.placeCardData.left_card))
		local bFound, temp = sss_recommendHelper.GetLibRecomand():Get_Pt_Straight_Flush_Laizi_second(normal_cards, nLaziCount)
		self:CardTypeBottomClick(1, temp, laiziCards)
	--铁枝
	elseif obj.name == "cardTip2" then
		local active1 = child(obj.transform, "active")
		if active1.gameObject.activeSelf == false then
			return
		end
		local normal_cards, nLaziCount, laiziCards = self.placeCardData:GetallCardType(Array.Clone(self.placeCardData.left_card))
		local bFound, temp = sss_recommendHelper.GetLibRecomand():Get_Pt_Four_Laizi_second(normal_cards, nLaziCount)
		self:CardTypeBottomClick(2, temp, laiziCards)
	--葫芦
	elseif obj.name == "cardTip3" then
		local active1 = child(obj.transform, "active")
		if active1.gameObject.activeSelf == false then
			return
		end
		local normal_cards, nLaziCount, laiziCards = self.placeCardData:GetallCardType(Array.Clone(self.placeCardData.left_card))
		local bFound, temp = sss_recommendHelper.GetLibRecomand():Get_Pt_Full_Hosue_Laizi_second(normal_cards, nLaziCount)
	
		self:CardTypeBottomClick(3, temp, laiziCards)
		--同花
	elseif obj.name == "cardTip4" then
		local active1 = child(obj.transform, "active")
		if active1.gameObject.activeSelf == false then
			return
		end
		local normal_cards, nLaziCount, laiziCards = self.placeCardData:GetallCardType(Array.Clone(self.placeCardData.left_card))
		local bFound, temp = sss_recommendHelper.GetLibRecomand():Get_Pt_Flush_Laizi_second(normal_cards, nLaziCount)
		self:CardTypeBottomClick(4, temp, laiziCards)
		--顺子
	elseif obj.name == "cardTip5" then
		local active1 = child(obj.transform, "active")
		if active1.gameObject.activeSelf == false then
			return
		end
		local normal_cards, nLaziCount, laiziCards = self.placeCardData:GetallCardType(Array.Clone(self.placeCardData.left_card))
		local bFound, temp = sss_recommendHelper.GetLibRecomand():Get_Pt_Straight_Laizi_second(normal_cards, nLaziCount)
		self:CardTypeBottomClick(5, temp, laiziCards)
	--三条
	elseif obj.name == "cardTip6" then
		local active1 = child(obj.transform, "active")
		if active1.gameObject.activeSelf == false then
			return
		end
		local normal_cards, nLaziCount, laiziCards = self.placeCardData:GetallCardType(Array.Clone(self.placeCardData.left_card))
		local bFound, temp = sss_recommendHelper.GetLibRecomand():Get_Pt_Three_Laizi_second(normal_cards, nLaziCount)
		self:CardTypeBottomClick(6, temp, laiziCards)
		--五同
	elseif obj.name == "cardTip7" then
		local active1 = child(obj.transform, "active")
		if active1.gameObject.activeSelf == false then
			return
		end
		local normal_cards, nLaziCount, laiziCards = self.placeCardData:GetallCardType(Array.Clone(self.placeCardData.left_card))
		local bFound, temp = sss_recommendHelper.GetLibRecomand():Get_Pt_Five_Laizi_second(normal_cards, nLaziCount)
		self:CardTypeBottomClick(7, temp, laiziCards)
	elseif obj.name == "cardTip8" then
		local active1 = child(obj.transform, "active")
		if active1.gameObject.activeSelf == false then
			return
		end
		local normal_cards, nLaziCount, laiziCards = self.placeCardData:GetallCardType(Array.Clone(self.placeCardData.left_card))
		local bFound, temp = sss_recommendHelper.GetLibRecomand():Get_Pt_One_Pair_Laizi_second(normal_cards, nLaziCount)
		self:CardTypeBottomClick(8, temp, laiziCards)
	elseif obj.name == "cardTip9" then
		local active1 = child(obj.transform, "active")
		if active1.gameObject.activeSelf == false then
			return
		end
		local normal_cards, nLaziCount, laiziCards = self.placeCardData:GetallCardType(Array.Clone(self.placeCardData.left_card))
		local bFound, temp = sss_recommendHelper.GetLibRecomand():Get_Pt_Six_Laizi_second(normal_cards, nLaziCount)
		self:CardTypeBottomClick(9, temp, laiziCards)
	--确定
	elseif obj.name == "OkBtn" then
		ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
		self.placeCardData.isXiangGong = self.placeCardData:XiangGong()
		if self.placeCardData.isXiangGong then
			return
		end
		local confirm_cards = self.placeCardData:GetConfirmCard()
		for i, v in ipairs(confirm_cards) do
			if confirm_cards[i] > 100 then
				confirm_cards[i] = confirm_cards[i] % 100 --重复牌大于100，这里发送给服务器得与100求余
			end
		end
		if #confirm_cards < 13 then
			Trace("摆的牌少于13张")
			return
		end
		local check = self.placeCardData:CheckSendCard(confirm_cards)
		if check == false then
			return	
		end
		pokerPlaySysHelper.GetCurPlaySys().PlaceCard(confirm_cards)
		card_data_manage.chooseCardsTbl = confirm_cards  --缓存选定的牌型
		
		Notifier.dispatchCmd(cmd_shisanshui.PlaceCardCountDown,self.uiTime ) --让牌局UI显示剩下的时间倒计时
	elseif obj.name == "CancelBtn" then
		ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
		if self.placeCardView.placeCard ~= nil then
			self.placeCardView.placeCard.gameObject:SetActive(true)
		end
		if self.placeCardView.prepare ~= nil then
			self.placeCardView.prepare.gameObject:SetActive(false)
		end
		self.placeCardView:RecomondBtnNone()
		self:DownCardClick(1, true)
		self:DownCardClick(2, true)
		self:DownCardClick(3, true)
		self.placeCardData.animationMove = true
		coroutine.start(function ()
			coroutine.wait(self.placeCardData.animationWaitTime)
			self.placeCardData.animationMove = false
			self.placeCardView.cardGrid:Reposition()
		end
		)
	elseif obj.name == "cardType1" then
		Trace("-----cardType1-------")
		self.placeCardView:RecomondBtnInit(obj)
		self:AutoPlace1Click(1)
	elseif obj.name == "cardType2" then
		Trace("-----cardType2-------")
		self:AutoPlace1Click(2)
		self.placeCardView:RecomondBtnInit(obj)
	elseif obj.name == "cardType3" then
		Trace("-----cardType3-------")
		self:AutoPlace1Click(3)
		self.placeCardView:RecomondBtnInit(obj)

	elseif obj.name == "cardType4" then
		Trace("-----cardType4-------")
		self:AutoPlace1Click(4)
		self.placeCardView:RecomondBtnInit(obj)

	elseif obj.name == "cardType5" then
		Trace("-----cardType4-------")
		--self.gameObject:SetActive(false)
		UI_Manager:Instance():CloseUiForms("place_card")
		--prepare_special.ReShow()
		
		UI_Manager:Instance():ShowUiForms("prepare_special",UiCloseType.UiCloseType_CloseNothing,nil,card_data_manage.prepare_special_CardList,card_data_manage.isSpecial,card_data_manage.nSpecialScore,card_data_manage.prepare_recommendCards)
		
	--选好的牌下架
	elseif obj.name == "firstBtn" then
		self:DownCardClick(3,false)
		self.placeCardView:RecomondBtnNone()
	elseif obj.name == "secondBtn" then
		self:DownCardClick(2,false)	
		self.placeCardView:RecomondBtnNone()
	elseif obj.name == "thirdBtn" then
		self:DownCardClick(1,false)
		self.placeCardView:RecomondBtnNone()
	end
end

function place_card:DoubleBtnClick(obj)
	Trace("摆牌双击")
	if self.placeCardData.selectDownCards == nil then
		return
	end
	local count = #self.placeCardData.selectDownCards
	for i = count, 1, -1 do
		local data = self.placeCardData.selectDownCards[i]
		self:CardClick(data.tran.gameObject, true)
	end
	self.placeCardData.animationMove = true
	coroutine.start(function ()
			coroutine.wait(self.placeCardData.animationWaitTime)
			self.placeCardData.animationMove = false
		end)
end

function place_card:CardTypeBottomClick(index, temp, laiziCards)
	if temp == nil  or #temp == 0 then
		Trace("没有相应的推荐牌型:"..tostring(index))
		return
	end
	local allResult = sss_recommendHelper.GetLibRecomand():Get_Rec_Cards_Laizi(temp, laiziCards)
	self:DownSelectCard()
	if self.placeCardData.bottonSelectCardsBtn == index and self.placeCardData.allCardTypeIndex >= #allResult then
		self.placeCardData.allCardTypeIndex = 0
		self.placeCardData.isSelectDown = true
		return
	end
	if self.placeCardData.bottonSelectCardsBtn ~= index then
		self.placeCardData.allCardTypeIndex = 0
	end
	self.placeCardData.isSelectDown = false
	self.placeCardData.allCardTypeIndex = self.placeCardData.allCardTypeIndex + 1
	local cards = self.placeCardData:FindSameCard(allResult[self.placeCardData.allCardTypeIndex])
	for k,v in pairs(self.placeCardView.cardTranTbl) do
		
	end
	local selectTbl = {}
	for _, v in ipairs(cards) do
		if self.placeCardView.cardTranTbl[v] then
			while self.placeCardView.cardTranTbl[v].tran.transform.localPosition.y >= self.placeCardData.cardClickMoveY or selectTbl[v] do
				v = v + 100
			end
			if self.placeCardView.cardTranTbl[v] then
				self:CardClick(self.placeCardView.cardTranTbl[tonumber(v)].tran.gameObject, true)
				selectTbl[v] = true
			end
		end
	end
	self.placeCardData.animationMove = true
	coroutine.start(function ()
		coroutine.wait(self.placeCardData.animationWaitTime)
		self.placeCardData.animationMove = false
	end
	)
	self.placeCardData.bottonSelectCardsBtn = index
end

function place_card:DownSelectCard()
	for i, v in ipairs(self.placeCardData.selectDownCards) do
		local obj = v.tran.gameObject
		local cardData = UIEventListener.Get(obj).parameter
		local pos = obj.transform.localPosition
		obj.transform.localPosition = Vector3.New(pos.x, 0, pos.z)
		cardData.cardType = self.placeCardData.CardType[1]
		UIEventListener.Get(obj).parameter = cardData
	end
	self.placeCardData.selectDownCards = {}
end

--自动摆牌
function place_card:AutoPlace1Click(index)

	Trace("AutoPlace1Click index:"..tostring(index))
	if self.placeCardData.animationMove then
		return
	end
	self.placeCardView:RecomondBtnEnable(false)
	local change_cards = Array.Clone(self.placeCardData.first_auto_all_card)
	if self.placeCardData.recommend_cards ~= nil then
		local rec_cards = self.placeCardData.recommend_cards[index]["Cards"]
		change_cards = Array.Clone(rec_cards)
	end
	change_cards = self.placeCardData:FindSameCard(change_cards)
	for i = 1, #change_cards do
		
		local cardNum = change_cards[i]
		if self.placeCardView.cardTranTbl[cardNum] == nil then
			Trace("推荐的牌有一张找不到："..tostring(cardNum))
			UI_Manager:Instance():FastTip(LanguageMgr.GetWord(6020))
			self.placeCardView:RecomondBtnEnable(true)
			return
		end
		local destOjbPos = self.placeCardView.cardPlaceTranList[i].tran.transform.localPosition
	--	local destOjbPos = self.placeCardView.cardPlaceTranList[i].tran.transform.position
		local cardData = UIEventListener.Get(self.placeCardView.cardTranTbl[cardNum].tran.gameObject).parameter
		cardData.place_up_index = i
		
	--	self.placeCardView.cardTranTbl[cardNum].tran.transform.position = destOjbPos
	--	local trans =  self.placeCardView.cardTranTbl[cardNum].tran.transform
	--	trans.localPosition = Vector3(trans.localPosition.x + self.placeCardData.cardUpXOffset,trans.localPosition.y + self.placeCardData.cardUpYOffset,trans.localPosition.z)
		self.placeCardView.cardTranTbl[cardNum].tran.transform:DOLocalMove(Vector3(destOjbPos.x + self.placeCardData.XOffset,destOjbPos.y + self.placeCardData.YOffset,destOjbPos.z), self.placeCardData.animationTime, true)
		self.placeCardView.cardTranTbl[cardNum].tran.transform:DOScale(self.placeCardData.cardUpScale, self.placeCardData.animationSmallTime)
		local parameterData = UIEventListener.Get(self.placeCardView.cardTranTbl[cardNum].tran.gameObject).parameter
		parameterData.cardType = self.placeCardData.CardType[3]
		parameterData.up_index = i
		local dun, dun_no =  self.placeCardData:GetDunNo(i)
		self.placeCardData.up_placed_cards[dun][dun_no] = parameterData
		self.placeCardData:UpdateLeftCard(self.placeCardData.left_card, parameterData.card)
	end
	self.placeCardData.left_card = {}
	self.placeCardData.place_index = 14
	--]]
	for i = 1, #self.placeCardView.cardPlaceTranList do
		self.placeCardView.cardPlaceTranList[i].blank = false
	end
	self.placeCardView:DunTipShow(true)
	self.placeCardData.selectDownCards = {}
	self.placeCardView:PlaceCardFinish()
	
	self.placeCardData.animationMove = true
	coroutine.start(function ()
		coroutine.wait(self.placeCardData.animationWaitTime)
		self.placeCardData.animationMove = false
		self.placeCardView:RecomondBtnEnable(true)
	end
	)
end
	
--下牌
function place_card:DownCardClick(dun, fast)
	if self.placeCardData.animationMove then
		return
	end 
	if self.placeCardData.selectUpCard~= nil then
		child(self.placeCardData.selectUpCard.transform, "guanghuan").gameObject:SetActive(false)
		self.placeCardData.selectUpCard = nil
	end
	if self.placeCardView.placeCard ~= nil then
		self.placeCardView.placeCard.gameObject:SetActive(true)
	end
	if self.placeCardView.prepare ~= nil then
		self.placeCardView.prepare.gameObject:SetActive(false)
	end
	local dun_cards = self.placeCardData.up_placed_cards[dun]
	local num = 0
	for i, v in pairs(dun_cards) do
		self:DownOneCard(v)
	end
	
	self.placeCardData.up_placed_cards[dun] = {}
	self.placeCardView.dunDownBtn[dun].gameObject:SetActive(false)
	self.placeCardView.dunTipSpt[dun].gameObject:SetActive(true)	
	self:TipsBtnShow(self.placeCardData.left_card)
	for k,v in ipairs(self.placeCardData.selectDownCards) do
		self.placeCardData.selectDownCards[k].cardType = self.placeCardData.CardType[1]
		self.placeCardData.selectDownCards[k] = nil
	end
	self.placeCardData.selectDownCards = {}
	if fast == nil or fast == false then
		self.placeCardData.animationMove = true
		coroutine.start(function ()
			coroutine.wait(self.placeCardData.animationWaitTime)
			self.placeCardView.cardGrid:Reposition()
			coroutine.wait(self.placeCardData.animationSmallTime)
			self.placeCardData.animationMove = false
		end)
	end
end

function place_card:DownOneCard(cardData, repos)
	cardData.tran.transform:DOLocalMove(cardData.pos, self.placeCardData.animationTime, true)
	cardData.tran.transform:DOScale(self.placeCardData.cardDownScale, self.placeCardData.animationSmallTime)
	cardData.cardType = self.placeCardData.CardType[1]
	
	self.placeCardData.left_card[#self.placeCardData.left_card + 1] = cardData.card
	self.placeCardView.cardPlaceTranList[cardData.up_index].blank = true
	self.placeCardData.place_index = self.placeCardData.place_index - 1
	
	if repos ~= nil and repos == true then
		self.placeCardData.animationMove = true
		coroutine.start(function ()
			coroutine.wait(self.placeCardData.animationWaitTime)
			self.placeCardView.cardGrid:Reposition()
			coroutine.wait(self.placeCardData.animationSmallTime)
			self.placeCardData.animationMove = false
		end)
	end
end

--补牌
function place_card:BuPai()
	Trace("BuPai")
	if #self.placeCardData.left_card > 5 then
		return
	end
	if #self.placeCardData.left_card == 0 then
		return
	end
	local leftCardNum = #self.placeCardData.left_card
	local blankNum = 0
	for i = 1, 5 do
		if self.placeCardView.cardPlaceTranList[i].blank == true then
			blankNum = blankNum + 1
		end
	end
	if blankNum == leftCardNum then
		local down_card = self:GetDownCardSelect()
		self:CardBgClick(self.placeCardView.cardPlaceTranList[1].tran.gameObject)
		self.placeCardData.left_card = {}
		return
	end
	blankNum = 0
	for i = 6, 10 do
		if self.placeCardView.cardPlaceTranList[i].blank == true then
			blankNum = blankNum + 1
		end
	end
	if blankNum == leftCardNum then
		local down_card = self:GetDownCardSelect()
		self:CardBgClick(self.placeCardView.cardPlaceTranList[6].tran.gameObject)
		self.placeCardData.left_card = {}
		return
	end
	
	blankNum = 0
	for i = 11, 13 do
		if self.placeCardView.cardPlaceTranList[i].blank == true then
			blankNum = blankNum + 1
		end
	end
	if blankNum == leftCardNum then
		local down_card = self:GetDownCardSelect()
		self:CardBgClick(self.placeCardView.cardPlaceTranList[11].tran.gameObject)
		self.placeCardData.left_card = {}
		return
	end
	
	self.placeCardData.animationMove = true
	coroutine.start(function ()
		coroutine.wait(self.placeCardData.animationWaitTime * 3)
		self.placeCardData.animationMove = false
	end
	)
end

--下面选中的牌
function place_card:GetDownCardSelect()
	local downCard = {}
	for i, v in pairs(self.placeCardView.cardTranTbl) do
		local oneCard = UIEventListener.Get(v.tran.gameObject).parameter
		if oneCard.cardType == self.placeCardData.CardType[1] or oneCard.cardType == self.placeCardData.CardType[2] then
			table.insert(downCard, oneCard)
			table.insert(self.placeCardData.selectDownCards, oneCard)
		end
	end
	return downCard
end

function place_card:RecommendCardUpdate()
	
	if self.placeCardData.recommend_cards == nil then
		return
	end
	--logError("RecommendCardUpdate--------------"..GetTblData(self.placeCardData.recommend_cards))
	for i = 1, 4 do
		local tipObj = self.placeCardView.recommondCardTip[i]
		if self.placeCardData.recommend_cards[i] == nil or #self.placeCardData.recommend_cards[i]["Cards"] < 13 then
			tipObj.gameObject:SetActive(false)
		else
			tipObj.gameObject:SetActive(true)
			local gid = player_data.GetGameId()
			local types = self.placeCardData.recommend_cards[i]["Types"]
			local thirdCardLbl =  self.placeCardView.recommondCardTipThreeActive[i]
			local thirdCheckCardLbl =  self.placeCardView.recommondCardTipThreeDeactive[i]
			if thirdCardLbl ~= nil and thirdCheckCardLbl ~= nil then
				thirdCardLbl.text = card_define.GetNormalTypeName(types[1],gid)
				thirdCheckCardLbl.text = card_define.GetNormalTypeName(types[1],gid)
			end
			local secondCardLbl =  self.placeCardView.recommondCardTipSecondActive[i]
			local secondCheckCardLbl =  self.placeCardView.recommondCardTipSecondDeactive[i]
			if secondCardLbl ~= nil and secondCheckCardLbl ~= nil  then
				secondCardLbl.text = card_define.GetNormalTypeName(types[2],gid)
				secondCheckCardLbl.text = card_define.GetNormalTypeName(types[2],gid)
			end
			local firstCardLbl = self.placeCardView.recommondCardTipFirstActive[i] 
			local firstCheckCardLbl =  self.placeCardView.recommondCardTipFirstDeactive[i]
			if firstCardLbl ~= nil and firstCheckCardLbl ~= nil then
				firstCardLbl.text = card_define.GetNormalTypeName(types[3],gid)
				firstCheckCardLbl.text = card_define.GetNormalTypeName(types[3],gid)
			end
		end
	end
	local tipObj = self.placeCardView.recommondCardTip[5]
	if self.placeCardData.nSpecialType ~= nil then
		tipObj.gameObject:SetActive(true)
		local thirdCardLbl = self.placeCardView.recommondCardTipThreeActive[5]
		thirdCardLbl.text = card_define.GetSpecialTypeName(self.placeCardData.nSpecialType)
	else
		tipObj.gameObject:SetActive(false)
	end
	self.placeCardView.rommondGrid:Reposition()
end

function place_card:StartTimerEscape()
	if self.timerEscape == nil then
		self.timeEnd = room_data.GetPlaceCardTime() - os.time()
		self.placeCardView.timeLbl.text = tostring(math.floor(self.timeEnd))
		self.timerEscape = Timer.New(slot(self.OnTimer_Proc,self),1,self.timeEnd)
		self.timerEscape:Start()
	end
end

function place_card:OnTimer_Proc()
	self.shakeCount = self.shakeCount + 1
	self.timeEnd = self.timeEnd - 1
	self.placeCardView.timeLbl.text = tostring(math.floor(self.timeEnd))
	if math.floor(self.timeEnd) <= 0 then
		self.timeEnd = 0
		UI_Manager:Instance():CloseUiForms("place_card")
		return
	end
	if math.floor(self.timeEnd) <= 10 then
		ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/baipaishijianshengyu10sjinggao")
	end
	if self.shakeCount == 30 then
		Notifier.dispatchCmd(cmdName.MSG_SHAKE,{}) 
		self.shakeCount = 0
	end
	if self.placeCardData.totalTime ~= nil then
		self.uiTime = self.timeEnd
	end	
end

function place_card:StopTimerEscape()
	if self.timerEscape ~= nil then
		self.timerEscape:Stop()
		self.timerEscape = nil
		self.shakeCount = 0
	end
end

function place_card:PlayOpenAmination()
	
end

return place_card
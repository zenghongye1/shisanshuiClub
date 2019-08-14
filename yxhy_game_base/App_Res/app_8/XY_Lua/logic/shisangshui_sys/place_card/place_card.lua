--[[(* @Description: 创建摆牌组件
 * @Author:      zhy
 * @FileName:    place_card.lua
 * @DateTime:    2017-07-1
 ]]

require "logic/shisangshui_sys/lib_normal_card_logic"
--require "logic/shisangshui_sys/shisangshui_play_sys"
require "logic/shisangshui_sys/lib_laizi_card_logic"
require "logic/shisangshui_sys/common/array"
require "logic/shisangshui_sys/card_define"
-- "logic/shisangshui_sys/ui_shisangshui/shisangshui_ui_sys"
 --require "logic/shisangshui_sys/lib_recomand"

 
place_card = ui_base.New()
local this = place_card 
local transform;
--13张牌Obj
local cardTranTbl = {}
--摆牌背景，包含位置
local cardPlaceTranList = {}
--已摆好牌索引
local place_index = 1
--牌父节点Obj
local placeCard
--准备Obj
local prepare
--1,初始状态 2，选中状态 3，已摆放状态
local CardType = {1, 2, 3}
--已选中扑克
local selectDownCards = {}
--已选中扑克
local selectUpCard

local up_placed_cards = {[1] = {}, [2] = {}, [3] = {}}

--timeLbl
local timeLbl
local timeSpt
local timeSecond
--下发和13张牌
local cardList
local left_card
--前，中，后 三墩牌的UISprite提示
local dunTipSpt = {}
--前，中，后 三墩牌的下架按扭
local dunDownBtn = {}
local first_auto_all_card = {}

local cardTipBtn = {}

local isXiangGong = false

local recommend_cards

local lastTime = 0  ----倒计时

local cardGrid

local isRecommond = false

local animationMove = false

local nSpecialType

local animationSmallTime = 0.02
local animationTime = 0.3

local animationWaitTime = 0.3

local totalTime = nil
--底部按扭牌型序号
local allCardTypeIndex = 0
local bottonSelectCardsBtn = 0
local isSelectDown = false


function this.Awake() 
   this.initinfor()   
  	--this.registerevent() 
end

function this.Show(cards, specialType)
	--table.sort(cards, function(a, b) return GetCardValue(a) < GetCardValue(b) end)
	cards = Array.CardSort(cards)
	nSpecialType = specialType
--[[	if recommendCards ~= nil and #recommendCards > 0 then
		print("推荐牌1")
		recommend_cards = recommendCards
	else--]]
		if room_data.GetRecommondCard() ~= nil then
		print("推荐牌2")
			recommend_cards = room_data.GetRecommondCard()
		end
--	end
	ui_sound_mgr.PlaySoundClip("game_80011/sound/dub/chupai_nv")
	--recommendCards["cards"] = cards
	print("place_card")
	cardList = cards
	place_index = 1
	if this.gameObject==nil then
		require ("logic/shisangshui_sys/place_card/place_card")
		this.gameObject=newNormalUI("game_80011/ui/place_card")
	else
		this.gameObject:SetActive(true)
	end
	timeSecond = os.time() + 3
  	--this.addlistener()
end

--推荐牌给的慢
function this.SetRecommondCard(recommendCards)
	if isRecommond == true then
		recommend_cards = recommendCards
		print("推荐牌3")
		if recommend_cards ~= nil then
			this.RecommendCardUpdate()
		end
		this.DunTipShow(false)
		isRecommond = true
	end
end

function this.Hide()
	Trace("摆牌隐藏")
	isRecommond = false
	room_data.SetRecommondCard(nil)
	selectUpCard = nil
	cardPlaceTranList = {}
	cardTranTbl = {}
	selectDownCards = {}
	recommend_cards = nil
	up_placed_cards = {[1] = {}, [2] = {}, [3] = {}} 
	first_auto_all_card = {}
	if cardTranTbl ~= nil then
		for i, v in pairs(cardTranTbl) do
			GameObject.Destroy(v);
		end
	end
	if this.gameObject == nil then
		return
	else
		GameObject.Destroy(this.gameObject)
		this.gameObject = nil
	end
	prepare_special.Hide()
end

--[[--
 * @Description: 逻辑入口  
 ]]
function this.Start()   
	this.registerevent()
	
	--cardList = {21, 53, 37, 6, 5, 7, 22, 9, 10, 11, 12, 13, 14}
	left_card = Array.Clone(cardList)
	this.LoadAllCard(cardList)
	this.TipsBtnShow(cardList)
	if recommend_cards ~= nil then
		this.RecommendCardUpdate()
		isRecommond = false
	else
		isRecommond = true
	end
	this.DunTipShow(false)

	totalTime = room_data.GetSssRoomDataInfo().placeCardTime
end


--[[--
 * @Description: 销毁  
 ]]
function this.OnDestroy()
end

local hoverObj = nil
function this.OnFingerHover(myself, fingerHoverEvent)
	if fingerHoverEvent.Selection ~= nil then
		Trace("OnFingerHoverForLua"..tostring(fingerHoverEvent.Selection.name))
		if hoverObj == fingerHoverEvent.Selection then
			return
		else
			if fingerHoverEvent.Selection.tag == "Card" then
				local data = UIEventListener.Get(fingerHoverEvent.Selection.gameObject).parameter
				if data.cardType == CardType[3] and hoverObj ~= nil then
					return
				end
				hoverObj = fingerHoverEvent.Selection
				this.CardClick(hoverObj, true, true)
			end
		end
	end
end

function this.OnFingerUp(myself,fingerUpEvent)
	Trace("Lua fingerUpEvent++++++++++")
	hoverObj = nil
end


function this.OnSwipe(myself,direction,fingerSwipe)
	Trace("Direction:"..tostring(direction))
	if tostring(direction) == "Down" then
		--local data = UIEventListener.Get(fingerSwipe.gameObject).parameter
		--this.DownOneCard(data, true)
	end
end

---[[
function this.initinfor()
	for i = 1, 13 do
		local up_bg_data = {}
		cardPlaceTranList[i] = up_bg_data
		up_bg_data.tran = child(this.transform, "Panel_TopLeft/CardBg/"..i)
		up_bg_data.blank = true
		up_bg_data.card = nil
		up_bg_data.index = i
		UIEventListener.Get(up_bg_data.tran.gameObject).onClick = this.CardBgClick
		UIEventListener.Get(up_bg_data.tran.gameObject).parameter = up_bg_data
		placeCard = child(this.transform, "Panel_Bottom/placeCard")
		if placeCard ~= nil then
			placeCard.gameObject:SetActive(true)
		end
		prepare = child(this.transform, "Panel_Bottom/prepare")
		if prepare ~= nil then
			prepare.gameObject:SetActive(false)
		end
		timeLbl =  componentGet(child(this.transform, "Panel_TopLeft/Slider/timeLbl"), "UILabel")
		timeSpt =  componentGet(child(this.transform, "Panel_TopLeft/Slider/Foreground"), "UISprite")
	end
	
	---[[
	local dunTip3 = child(this.transform, "Panel_TopLeft/thirdDun")
	dunTipSpt[1] = dunTip3
	local dunTip2 = child(this.transform, "Panel_TopLeft/secondDun")
	dunTipSpt[2] = dunTip2
	local dunTip1 = child(this.transform, "Panel_TopLeft/firstDun")
	dunTipSpt[3] = dunTip1
	--]]
	
	local dunTip3 = child(this.transform, "Panel_TopLeft/thirdBtn")
	dunDownBtn[1] = dunTip3
	local DownBtn2 = child(this.transform, "Panel_TopLeft/secondBtn")
	dunDownBtn[2] = DownBtn2
	local DownBtn1 = child(this.transform, "Panel_TopLeft/firstBtn")
	dunDownBtn[3] = DownBtn1
	
	
	cardGrid = componentGet(child(this.transform, "CardGrid"), "UIGrid")
--]]
end

function this.SetOutTime(timeo)
	timeSecond = timeo
end

--注册事件
function this.registerevent()
--[[
	local btn_1place = child(this.transform, "Panel_TopLeft/CardBg/1")
	if btn1place ~= nil then
		addClickCallbackSelf(btn_1place.gameObject, this. )
	end
	--]]
	local cardTip1 = child(this.transform, "Panel_Bottom/placeCard/tips/cardTip1")
	if cardTip1 ~= nil then
		cardTipBtn[1] = cardTip1
		UIEventListener.Get(cardTip1.gameObject).onClick = this.BtnClick
	end
	local cardTip2 = child(this.transform, "Panel_Bottom/placeCard/tips/cardTip2")
	if cardTip2 ~= nil then
		cardTipBtn[2] = cardTip2
		UIEventListener.Get(cardTip2.gameObject).onClick = this.BtnClick
	end
	local cardTip3 = child(this.transform, "Panel_Bottom/placeCard/tips/cardTip3")
	if cardTip3 ~= nil then
		cardTipBtn[3] = cardTip3
		UIEventListener.Get(cardTip3.gameObject).onClick = this.BtnClick
	end
	local cardTip4 = child(this.transform, "Panel_Bottom/placeCard/tips/cardTip4")
	if cardTip4 ~= nil then
		cardTipBtn[4] = cardTip4
		UIEventListener.Get(cardTip4.gameObject).onClick = this.BtnClick
	end
	local cardTip5 = child(this.transform, "Panel_Bottom/placeCard/tips/cardTip5")
	if cardTip5 ~= nil then
		cardTipBtn[5] = cardTip5
		UIEventListener.Get(cardTip5.gameObject).onClick = this.BtnClick
	end
	local cardTip6 = child(this.transform, "Panel_Bottom/placeCard/tips/cardTip6")
	if cardTip6 ~= nil then
		cardTipBtn[6] = cardTip6
		UIEventListener.Get(cardTip6.gameObject).onClick = this.BtnClick
	end
	local cardTip7 = child(this.transform, "Panel_Bottom/placeCard/tips/cardTip7")
	if cardTip7 ~= nil then
		cardTipBtn[7] = cardTip7
		UIEventListener.Get(cardTip7.gameObject).onClick = this.BtnClick
	end
	local cardTip8 = child(this.transform, "Panel_Bottom/placeCard/tips/cardTip8")
	if cardTip8 ~= nil then
		cardTipBtn[8] = cardTip8
		UIEventListener.Get(cardTip8.gameObject).onClick = this.BtnClick
	end
	local cardType1 = child(this.transform, "Panel_TopRight/recommond/cardType1")
	if cardType1 ~= nil then
		UIEventListener.Get(cardType1.gameObject).onClick = this.BtnClick
	end
	local cardType2 = child(this.transform, "Panel_TopRight/recommond/cardType2")
	if cardType2 ~= nil then
		UIEventListener.Get(cardType2.gameObject).onClick = this.BtnClick
	end
	local cardType3 = child(this.transform, "Panel_TopRight/recommond/cardType3")
	if cardType3 ~= nil then
		UIEventListener.Get(cardType3.gameObject).onClick = this.BtnClick
	end
	local cardType4 = child(this.transform, "Panel_TopRight/recommond/cardType4")
	if cardType4 ~= nil then
		UIEventListener.Get(cardType4.gameObject).onClick = this.BtnClick
	end
	local cardType5 = child(this.transform, "Panel_TopRight/recommond/cardType5")
	if cardType5 ~= nil then
		UIEventListener.Get(cardType5.gameObject).onClick = this.BtnClick
	end
	local OkBtn = child(this.transform, "Panel_Bottom/prepare/OkBtn")
	if OkBtn ~= nil then
		UIEventListener.Get(OkBtn.gameObject).onClick = this.BtnClick
	end
	local CancelBtn = child(this.transform, "Panel_Bottom/prepare/CancelBtn")
	if CancelBtn ~= nil then
		UIEventListener.Get(CancelBtn.gameObject).onClick = this.BtnClick
	end
	
	local firstBtn = child(this.transform, "Panel_TopLeft/firstBtn")
	if firstBtn ~= nil then
		UIEventListener.Get(firstBtn.gameObject).onClick = this.BtnClick
	end
	
	local secondBtn = child(this.transform, "Panel_TopLeft/secondBtn")
	if secondBtn ~= nil then
		UIEventListener.Get(secondBtn.gameObject).onClick = this.BtnClick
	end
	
	local thirdBtn = child(this.transform, "Panel_TopLeft/thirdBtn")
	if thirdBtn ~= nil then
		UIEventListener.Get(thirdBtn.gameObject).onClick = this.BtnClick
	end
	local bg2 = child(this.transform, "bg (2)")
	if bg2 ~= nil then
		UIEventListener.Get(bg2.gameObject).onClick = this.DoubleBtnClick
	end
end
	
function this.TipsBtnShow(cards)
	
	local normal_cards, nLaziCount, laiziCards = this.GetallCardType(Array.Clone(cards))
	local bFound, temp = libRecomand:Get_Pt_Straight_Flush_Laizi_second(Array.Clone(normal_cards), nLaziCount)
	Trace("剩余牌的数量:"..tostring(#normal_cards))
	this.BtnGray(cardTipBtn[1], bFound)
	
	bFound, temp = libRecomand:Get_Pt_Four_Laizi_second(Array.Clone(normal_cards), nLaziCount)
	this.BtnGray(cardTipBtn[2], bFound)
	
	bFound, temp = libRecomand:Get_Pt_Full_Hosue_Laizi_second(Array.Clone(normal_cards), nLaziCount)
	--bFound, temp = libRecomand:Get_Pt_Full_Hosue_Laizi_Ext(Array.Clone(normal_cards), nLaziCount)
	
	this.BtnGray(cardTipBtn[3], bFound)
	
	bFound, temp = libRecomand:Get_Pt_Flush_Laizi_second(Array.Clone(normal_cards), nLaziCount)
	this.BtnGray(cardTipBtn[4], bFound)
	
	bFound, temp = libRecomand:Get_Pt_Straight_Laizi_second(Array.Clone(normal_cards), nLaziCount)
	this.BtnGray(cardTipBtn[5], bFound)
	
	bFound, temp = libRecomand:Get_Pt_Three_Laizi_second(Array.Clone(normal_cards), nLaziCount)
	this.BtnGray(cardTipBtn[6], bFound)
	
	bFound, temp = libRecomand:Get_Pt_Five_Laizi_second(Array.Clone(normal_cards), nLaziCount)
	this.BtnGray(cardTipBtn[7], bFound)
	
	bFound, temp = libRecomand:Get_Pt_One_Pair_Laizi_second(Array.Clone(normal_cards),nLaziCount)
	this.BtnGray(cardTipBtn[8],bFound)
end

--按扭置灰
function this.BtnGray(trans, isCanClick)
	--local collider = componentGet(trans, "BoxCollider")
	local enbale_bg = componentGet(child(trans, "Background"), "UISprite")
	local disable_bg = componentGet(child(trans, "Background (1)"), "UISprite")
	local active1 = child(trans, "active")
	local inactive = child(trans, "inactive")
	--if collider == nil or bg == nil then
	--	print("collider = nil or bg = nil : "..trans.name)
	--	return
	--end
	if isCanClick then
	
		--collider.enabled = true
	--	bg.spriteName = "pzaj-001"
		enbale_bg.gameObject:SetActive(true)
		disable_bg.gameObject:SetActive(false)
		
		active1.gameObject:SetActive(true)
		inactive.gameObject:SetActive(false)
	else
		
		--collider.enabled = false
	--	bg.spriteName = "pzaj-002"
		
		enbale_bg.gameObject:SetActive(false)
		disable_bg.gameObject:SetActive(true)
		
		active1.gameObject:SetActive(false)
		inactive.gameObject:SetActive(true)
	end
end

--加载13张牌
function this.LoadAllCard(cards)
---[[
	Trace("---------LOadAllCard-----")
	local CardGrid = child(this.transform, "CardGrid")
	if CardGrid == nil then
		print("CardGrid == nil")
		return
	end
	
	for i = 1, #cards do
		local card = cards[i]
		local card_data = {}
		card_data.tran = newNormalUI("game_80011/scene/card/"..tostring(card), CardGrid)
		if card_data.tran == nil then
			fast_tip.Show(GetDictString(6045)..tostring(card))
			break
		end
		if cardTranTbl[card] ~= nil then
			cardTranTbl[card + 100] = card_data
		else
			cardTranTbl[card] = card_data
		end
		local k = i - 1
		card_data.tran.transform.localPosition = Vector3.New(-558 + 93 * k, 0, 0)
		card_data.tran.name = tostring(i)
		card_data.pos = Vector3.New(-558 + 93 * k, 0, -0.1 * i)
		card_data.name = tostring(i)
		card_data.index = i
			
		local boxCollider = componentGet(card_data.tran.transform,"BoxCollider")
		if boxCollider ~= nil then
			boxCollider.size = Vector3(144,198,1)
		end
		
		local object2 = card_data.tran
		local cardData = {}
		cardData.card = cards[i]
		cardData.down_index = i
		cardData.up_index = 0
		cardData.cardType = CardType[1]
		cardData.tran = card_data.tran
		cardData.pos = card_data.pos
		componentGet(child(card_data.tran.transform, "bg"),"UISprite").depth = i * 2 + 3
		componentGet(child(card_data.tran.transform, "num"),"UISprite").depth = i * 2 + 5
		componentGet(child(card_data.tran.transform, "color1"),"UISprite").depth = i * 2 + 5
		componentGet(child(card_data.tran.transform, "color2"),"UISprite").depth = i * 2 + 5
		componentGet(child(card_data.tran.transform, "guanghuan"),"UISprite").depth = i * 2 + 4
		if room_data.GetSssRoomDataInfo().isChip == true and card == 40 then
			child(card_data.tran.transform,"ma").gameObject:SetActive(true)
			componentGet(child(card_data.tran.transform, "ma"),"UISprite").depth = i * 2 + 4
		end
		--UIEventListener.Get(card_data.tran.gameObject).onClick = this.CardClick
		UIEventListener.Get(card_data.tran.gameObject).onDrag = this.CardDrag
		UIEventListener.Get(card_data.tran.gameObject).parameter = cardData
		
		--增加拖动事件
		if not IsNil(card_data.tran.gameObject) then
            addDragCallbackSelf(card_data.tran.gameObject, function (go, delta) 
		--		Trace("drag: "..go.name.." delta: "..tostring(delta.x).." Y: "..tostring(delta.y))
			end)
		end
		
		if not IsNil(card_data.tran.gameObject) then
            addDragEndCallbackSelf(card_data.tran.gameObject, function (go, delta) 
--				this.DownOneCard(card_data, true)
			end)
		end
	end
	--]]

	--obj.transform.localPosition = Vector3.New(delte.x, delte.y, obj.transform.localPosition.z)
end

--点击牌
function this.CardClick(obj, fast, hover)
	ui_sound_mgr.PlaySoundClip("game_80011/sound/audio/chupai")
	if animationMove then
		return
	end
	local cardData = UIEventListener.Get(obj).parameter
	if cardData == nil then
		print("-----cardData = nil-----")
	end
	local cardNowType = cardData.cardType
	local cardNum = cardData.card
	print("CardType: "..tostring(cardNowType).."  num: "..cardNum)
	if(tonumber(cardNowType) == CardType[1]) then
		bottonSelectCardsBtn = 0
		if hover ~= nil and hover == true then
			local pos = obj.transform.localPosition
			obj.transform.localPosition = Vector3.New(pos.x, 40, pos.z)
		else
			obj.transform:DOLocalMoveY(40, animationSmallTime, true)
		end
		local selectDownCardData = {}
		cardData.cardType = CardType[2]
		--selectDownCards[tonumber(obj.name)] = cardData
		table.insert(selectDownCards, cardData)
		UIEventListener.Get(obj).parameter = cardData
	elseif (tonumber(cardNowType) == CardType[2]) then
		bottonSelectCardsBtn = 0
		if hover ~= nil and hover == true then
			local pos = obj.transform.localPosition
			obj.transform.localPosition = Vector3.New(pos.x, 0, pos.z)
		else
			obj.transform:DOLocalMoveY(0, animationSmallTime, true)
		end
		local selectDownCardData = {}
		cardData.cardType = CardType[1]
		--selectDownCards[tonumber(obj.name)] = cardData		
		UIEventListener.Get(obj).parameter = cardData
		--local _key = tonumber(obj.name)
		--selectDownCards[_key] = nil
		local indexKey = this.GetDownCardKey(cardData)
		table.remove(selectDownCards, indexKey)
	else
		if obj.transform.localScale ~= Vector3.New(0.65, 0.65, 0.65) then
			Trace("换牌错误")
			return
		end
		if selectUpCard == nil then
			if #selectDownCards == 1 then
				local selectCardData = UIEventListener.Get(selectDownCards[1].tran.gameObject).parameter
				local pos = selectCardData.tran.transform.localPosition
				obj.transform:DOLocalMove(Vector3.New(pos.x, 0, pos.z), animationTime, true)
				obj.transform:DOScale(Vector3.New(1, 1, 1), animationTime)
				selectCardData.tran.transform:DOLocalMove(obj.transform.localPosition, animationTime, true)
				selectCardData.tran.transform:DOScale(Vector3.New(0.65, 0.65, 0.65), animationTime)
				
				local _, dun, dun_no = this.GetDun(cardData.up_index)
				up_placed_cards[dun][dun_no] = selectCardData
				selectCardData.up_index = cardData.up_index
				selectCardData.cardType = CardType[3]
				cardData.up_index = 0
				cardData.cardType = CardType[1]
				this.UpdateLeftCard(left_card, selectDownCards[1].card)
				table.insert(left_card, cardData.card)
				selectDownCards[1] = nil
				selectDownCards = {}
				this.TipsBtnShow(left_card)
				animationMove = true
				coroutine.start(function ()
						coroutine.wait(animationWaitTime)
						print("fast1: "..tostring(fast))
						animationMove = false
						cardGrid:Reposition()
						coroutine.wait(animationWaitTime)
					end)
				--local _select, select_dun, select_dun_no = this.GetDun(selectCardData.up_index)
				--up_placed_cards[dun][dun_no], up_placed_cards[select_dun][select_dun_no] = 
				--	up_placed_cards[select_dun][select_dun_no], up_placed_cards[dun][dun_no]
					
				--cardData.up_index, selectCardData.up_index = selectCardData.up_index, cardData.up_index
				
				--child(selectUpCard.transform, "guanghuan").gameObject:SetActive(false)
			else
				selectUpCard = obj
				child(selectUpCard.transform, "guanghuan").gameObject:SetActive(true)
				UIEventListener.Get(selectUpCard.gameObject).parameter = cardData
				return
			end
		else
			local selectCardData = UIEventListener.Get(selectUpCard.gameObject).parameter
			obj.transform:DOLocalMove(selectUpCard.transform.localPosition, animationTime, true)
			selectUpCard.transform:DOLocalMove(obj.transform.localPosition, animationTime, true)
			
			local _, dun, dun_no = this.GetDun(cardData.up_index)
			local _select, select_dun, select_dun_no = this.GetDun(selectCardData.up_index)
			up_placed_cards[dun][dun_no], up_placed_cards[select_dun][select_dun_no] = 
				up_placed_cards[select_dun][select_dun_no], up_placed_cards[dun][dun_no]
				
			cardData.up_index, selectCardData.up_index = selectCardData.up_index, cardData.up_index
			
			child(selectUpCard.transform, "guanghuan").gameObject:SetActive(false)
			selectUpCard = nil
			if place_index >= 14 then
				this.XiangGongTip()
			end
		end
	end
	print("fast1: "..tostring(fast))
	if fast == nil or fast == false then
		animationMove = true
		coroutine.start(function ()
			coroutine.wait(animationWaitTime)
			print("fast1: "..tostring(fast))
			animationMove = false
		end
		)
	end
end

function this.GetDownCardKey(cardData)
	for i = 1, #selectDownCards do
		if selectDownCards[i].down_index == cardData.down_index then
			return i
		end
	end
end

--获得确认的牌
function this.GetConfirmCard()
	local confirmCards = {}
	local sortCard = {}
	for i = 1, 5 do
		sortCard[i] = up_placed_cards[1][i].card
	end
	this.CardSort(sortCard)
	confirmCards = Array.Add(confirmCards, sortCard)
	sortCard = {}
	for i = 1, 5 do
		sortCard[i] = up_placed_cards[2][i].card
	end
	this.CardSort(sortCard)
	confirmCards = Array.Add(confirmCards, sortCard)
	sortCard = {}
	for i = 1, 3 do
		sortCard[i] = up_placed_cards[3][i].card
	end
	this.CardSort(sortCard)
	confirmCards = Array.Add(confirmCards, sortCard)
	return confirmCards
end

--点击空白可摆牌处
function this.CardBgClick(obj)
	if animationMove then
		return
	end
	ui_sound_mgr.PlaySoundClip("game_80011/sound/audio/chupai")
	local place_up_index = tonumber(obj.name)
	local select_num = 0
	for i, v in ipairs(selectDownCards) do
		if v ~= nil then
			select_num = select_num + 1
		end
	end
	if select_num == 0 then
		return
	end
	local place_up_max = this.GetMaxFromPosInDun(place_up_index)
	if select_num > place_up_max then
		local CanPlaceMaxPos = this.GetMaxPosInDun (place_up_index)
		if select_num > CanPlaceMaxPos then
			print("select_num: "..tostring(select_num).." PosNUM: "..tostring(CanPlaceMaxPos))
			local box= message_box.ShowGoldBox(GetDictString(6035),{function ()message_box:Close()end},{"fonts_01"})
			return
		else
			place_up_index = this.GetMinDun(place_up_index)
		end
	end
	selectDownCards = this.CardUpSort(selectDownCards)
    local place, dun = this.GetDun(place_up_index)
	for i, v in ipairs(selectDownCards) do
		if place_index > 13 then
			return
		end

		for i = place_up_index, 13 do
			if cardPlaceTranList[place_up_index].blank == true then
				break
			else
				place_up_index = place_up_index + 1
			end
		end
		cardPlaceTranList[place_up_index].blank = false
		cardPlaceTranList[place_up_index].card = v.card
		local cardData = UIEventListener.Get(v.tran.gameObject).parameter
		local cardNum = cardData.card
		v.tran.transform:DOLocalMove(cardPlaceTranList[place_up_index].tran.transform.localPosition, animationTime, true)
		v.tran.transform:DOScale(Vector3.New(0.65, 0.65, 0.65), animationSmallTime)
		cardData.cardType = CardType[3]
		cardData.up_index = place_up_index
		UIEventListener.Get(v.tran.gameObject).parameter = cardData
		--print("selectDownCards: i:  "..i.."  v: "..v.tran.name)
		this.UpdateLeftCard(left_card, cardData.card)
		
		local dun, dun_no = this.GetDunNo(place_up_index)
		up_placed_cards[dun][dun_no] = cardData
		place_index = place_index + 1
		if place_index == 14 then
			this.PlaceCardFinish()
			break
		end
		place_up_index = place_up_index + 1
		 	end
	for k,v in ipairs(selectDownCards) do
		selectDownCards[k] = nil
	end
	allCardTypeIndex = 0
	selectDownCards = {}
	this.DunBtnShow(place_up_index - 1)
	this.TipsBtnShow(left_card)
	this.BuPai()

	animationMove = true
	coroutine.start(function ()
		coroutine.wait(animationWaitTime)
		cardGrid:Reposition()
		coroutine.wait(animationWaitTime)
--[[		if this.IsPlaceFinish() then
			this.PlaceCardFinish()
		end--]]
		animationMove = false
	end
	)
end

function this.IsPlaceFinish()
	for i, v in pairs(cardTranTbl) do
		if v.cardType ~= CardType[3] then
			return false
		end
	end
	return true
end
 
function this.GetMaxFromPosInDun(index)
	local place_max = this.GetDun(index)
	local now_num = 0
	for i = index, place_max do
		if cardPlaceTranList[i].blank == true then
			now_num = now_num + 1
		end
	end
	print("max_pos_plaxe_card_num: "..place_max)
	return now_num
end

function this.GetMinDun(index)
	local min
	if index <= 5 then
		min = 1
	elseif index >= 11 then
		min = 11
	else
		min = 6
	end
	return min
end

function this.GetMaxPosInDun(index)
	local place_max = this.GetMinDun(index)
	local now_num = 0
	local num = 4
	if index > 10 then
		num = 2
	end
	for i = place_max, place_max + num do
		if cardPlaceTranList[i].blank == true then
			now_num = now_num + 1
		end
	end
	print("max_pos_plaxe_card_num: "..place_max)
	return now_num
end


function this.GetDun(index)
	local place_max, dun, dun_no
	if index <= 5 then
		place_max = 5
		dun = 1
		dun_no = index
	elseif index >= 11 then
		place_max = 13
		dun = 3
		dun_no = index - 10
	else
		place_max = 10
		dun = 2
		dun_no = index - 5
	end
	return place_max, dun, dun_no
end

function this.GetDunNo(index)
	local place_max, dun_no
	if index <= 5 then
		dun = 1
		dun_no = index
	elseif index >= 11 then
		dun = 3
		dun_no = index - 10
	else
		dun = 2
		dun_no = index - 5
	end
	return dun, dun_no
end

--按扭响应
function this.BtnClick(obj)
	if animationMove then
		return
	end
	--同花顺
	if obj.name == "cardTip1" then
		local active1 = child(obj.transform, "active")
		if active1.gameObject.activeSelf == false then
			return
		end
		local normal_cards, nLaziCount, laiziCards = this.GetallCardType(Array.Clone(left_card))
		local bFound, temp = libRecomand:Get_Pt_Straight_Flush_Laizi_second(normal_cards, nLaziCount)
		this.CardTypeBottomClick(1, temp, laiziCards)
	--铁枝
	elseif obj.name == "cardTip2" then
		local active1 = child(obj.transform, "active")
		if active1.gameObject.activeSelf == false then
			return
		end
		local normal_cards, nLaziCount, laiziCards = this.GetallCardType(Array.Clone(left_card))
		local bFound, temp = libRecomand:Get_Pt_Four_Laizi_second(normal_cards, nLaziCount)
		this.CardTypeBottomClick(2, temp, laiziCards)
	--葫芦
	elseif obj.name == "cardTip3" then
		local active1 = child(obj.transform, "active")
		if active1.gameObject.activeSelf == false then
			return
		end
		local normal_cards, nLaziCount, laiziCards = this.GetallCardType(Array.Clone(left_card))
		local bFound, temp = libRecomand:Get_Pt_Full_Hosue_Laizi_second(normal_cards, nLaziCount)
		--local bFound, temp = libRecomand:Get_Pt_Full_Hosue_Laizi_Ext(normal_cards, nLaziCount)
	
		this.CardTypeBottomClick(3, temp, laiziCards)
		--同花
	elseif obj.name == "cardTip4" then
		local active1 = child(obj.transform, "active")
		if active1.gameObject.activeSelf == false then
			return
		end
		local normal_cards, nLaziCount, laiziCards = this.GetallCardType(Array.Clone(left_card))
		local bFound, temp = libRecomand:Get_Pt_Flush_Laizi_second(normal_cards, nLaziCount)
		this.CardTypeBottomClick(4, temp, laiziCards)
		--顺子
	elseif obj.name == "cardTip5" then
		local active1 = child(obj.transform, "active")
		if active1.gameObject.activeSelf == false then
			return
		end
		local normal_cards, nLaziCount, laiziCards = this.GetallCardType(Array.Clone(left_card))
		local bFound, temp = libRecomand:Get_Pt_Straight_Laizi_second(normal_cards, nLaziCount)
		this.CardTypeBottomClick(5, temp, laiziCards)
	--三条
	elseif obj.name == "cardTip6" then
		local active1 = child(obj.transform, "active")
		if active1.gameObject.activeSelf == false then
			return
		end
		local normal_cards, nLaziCount, laiziCards = this.GetallCardType(Array.Clone(left_card))
		local bFound, temp = libRecomand:Get_Pt_Three_Laizi_second(normal_cards, nLaziCount)
		this.CardTypeBottomClick(6, temp, laiziCards)
		--五同
	elseif obj.name == "cardTip7" then
		local active1 = child(obj.transform, "active")
		if active1.gameObject.activeSelf == false then
			return
		end
		local normal_cards, nLaziCount, laiziCards = this.GetallCardType(Array.Clone(left_card))
		local bFound, temp = libRecomand:Get_Pt_Five_Laizi_second(normal_cards, nLaziCount)
		this.CardTypeBottomClick(7, temp, laiziCards)
	elseif obj.name == "cardTip8" then
		local active1 = child(obj.transform, "active")
		if active1.gameObject.activeSelf == false then
			return
		end
		local normal_cards, nLaziCount, laiziCards = this.GetallCardType(Array.Clone(left_card))
		local bFound, temp = libRecomand:Get_Pt_One_Pair_Laizi_second(normal_cards, nLaziCount)
		this.CardTypeBottomClick(8, temp, laiziCards)
	elseif obj.name == "cardTip9" then
		local active1 = child(obj.transform, "active")
		if active1.gameObject.activeSelf == false then
			return
		end
		local normal_cards, nLaziCount, laiziCards = this.GetallCardType(Array.Clone(left_card))
		local bFound, temp = libRecomand:Get_Pt_Two_Pair_Laizi_second(normal_cards, nLaziCount)
		this.CardTypeBottomClick(9, temp, laiziCards)
	--确定
	elseif obj.name == "OkBtn" then
		print("------OkBtn click--")
		ui_sound_mgr.PlaySoundClip("game_80011/sound/audio/anjianxuanze")  ---按键声音
		isXiangGong = this.XiangGong()
		if isXiangGong then
			--local box= message_box.ShowGoldBox(GetDictString(6036),nil,1,{function ()message_box:Close()end},{"fonts_01"})
			--return
		end
		local confirm_cards = this.GetConfirmCard()
		for i, v in ipairs(confirm_cards) do
			if confirm_cards[i] > 100 then
				confirm_cards[i] = confirm_cards[i] - 100 --加一色的ID为大于100，这里发送给服务器得减去100
				
			end
			
		end
		if #confirm_cards < 13 then
			Trace("摆的牌少于13张")
			return
		end
		local check = this.CheckSendCard(confirm_cards)
		if check == false then
			return	
		end
		shisangshui_play_sys.PlaceCard(confirm_cards)
		
		--this.Hide()
	elseif obj.name == "CancelBtn" then
		ui_sound_mgr.PlaySoundClip("game_80011/sound/audio/anjianxuanze")  ---按键声音
		if placeCard ~= nil then
			placeCard.gameObject:SetActive(true)
		end
		if prepare ~= nil then
			prepare.gameObject:SetActive(false)
		end
		this.RecomondBtnNone()
		this.DownCardClick(1, true)
		this.DownCardClick(2, true)
		this.DownCardClick(3, true)
		animationMove = true
		coroutine.start(function ()
			coroutine.wait(animationWaitTime)
			animationMove = false
		end
		)
	elseif obj.name == "cardType1" then
		print("-----cardType1-------")
		--local selectSp = componentGet(child(this.transform, "Panel_TopRight/recommond/cardType1/bg (1)"), "UISprite")
		--selectSp.color = Color.New(1, 1, 1, 1)
		this.RecomondBtnInit(obj)
		this.AutoPlace1Click(1)
	elseif obj.name == "cardType2" then
		print("-----cardType2-------")
		this.AutoPlace1Click(2)
		this.RecomondBtnInit(obj)
		--local selectSp = componentGet(child(this.transform, "Panel_TopRight/recommond/cardType2/bg (1)"), "UISprite")
		--selectSp.color = Color.New(1, 1, 1, 1)
	elseif obj.name == "cardType3" then
		print("-----cardType3-------")
		this.AutoPlace1Click(3)
		this.RecomondBtnInit(obj)
		--local selectSp = componentGet(child(this.transform, "Panel_TopRight/recommond/cardType3/bg (1)"), "UISprite")
		--selectSp.color = Color.New(1, 1, 1, 1)
	elseif obj.name == "cardType4" then
		print("-----cardType4-------")
		this.AutoPlace1Click(4)
		this.RecomondBtnInit(obj)
		--local selectSp = componentGet(child(this.transform, "Panel_TopRight/recommond/cardType4/bg (1)"), "UISprite")
		--selectSp.color = Color.New(1, 1, 1, 1)
	elseif obj.name == "cardType5" then
		print("-----cardType4-------")
		this.gameObject:SetActive(false)
		prepare_special.ReShow()
	--选好的牌下架
	elseif obj.name == "firstBtn" then
		this.DownCardClick(3,false)
	elseif obj.name == "secondBtn" then
		this.DownCardClick(2,false)	
	elseif obj.name == "thirdBtn" then
		this.DownCardClick(1,false)
	end
end

function this.RecomondBtnInit(obj)
	local selectSp = componentGet(child(obj.transform, "bg (1)"), "UISprite")
	selectSp.color = Color.New(1, 1, 1, 1)
	selectSp = child(obj.transform, "secondCardLbl1")
	selectSp.gameObject:SetActive(true)
	selectSp = child(obj.transform, "firstCardLbl1")
	selectSp.gameObject:SetActive(true)
	selectSp = child(obj.transform, "thirdCardLbl1")
	selectSp.gameObject:SetActive(true)
end

function this.RecomondBtnNone()
	for i = 1, 4 do
		local tgl = componentGet(child(this.transform, "Panel_TopRight/recommond/cardType"..i), "UIToggle")
		tgl.value = false
		local selectSp = componentGet(child(this.transform, "Panel_TopRight/recommond/cardType"..i.."/bg (1)"), "UISprite")
		selectSp.color = Color.New(1, 1, 1, 0)
		selectSp = child(this.transform, "Panel_TopRight/recommond/cardType"..i.."/secondCardLbl1")
		selectSp.gameObject:SetActive(false)
		selectSp = child(this.transform, "Panel_TopRight/recommond/cardType"..i.."/thirdCardLbl1")
		selectSp.gameObject:SetActive(false)
		selectSp = child(this.transform, "Panel_TopRight/recommond/cardType"..i.."/firstCardLbl1")
		selectSp.gameObject:SetActive(false)
		
		selectSp = child(this.transform, "Panel_TopRight/recommond/cardType"..i.."/secondCardLbl")
		selectSp.gameObject:SetActive(true)
		selectSp = child(this.transform, "Panel_TopRight/recommond/cardType"..i.."/thirdCardLbl")
		selectSp.gameObject:SetActive(true)
		selectSp = child(this.transform, "Panel_TopRight/recommond/cardType"..i.."/firstCardLbl")
		selectSp.gameObject:SetActive(true)
	end
end

function this.DoubleBtnClick(obj)
	Trace("摆牌双击")
	if selectDownCards == nil then
		return
	end
	local count = #selectDownCards
	for i = count, 1, -1 do
		local data = selectDownCards[i]
		this.CardClick(data.tran.gameObject, true)
	end
	animationMove = true
	coroutine.start(function ()
			coroutine.wait(animationWaitTime)
			animationMove = false
		end)
end

function this.CardTypeBottomClick(index, temp, laiziCards)
	if temp == nil  or #temp == 0 then
		Trace("没有相应的推荐牌型:"..tostring(index))
		return
	end
	local allResult = libRecomand:Get_Rec_Cards_Laizi(temp, laiziCards)
	this.DownSelectCard()
	if bottonSelectCardsBtn == index and allCardTypeIndex >= #allResult then
		allCardTypeIndex = 0
		isSelectDown = true
		return
	end
	if bottonSelectCardsBtn ~= index then
		allCardTypeIndex = 0
	end
	isSelectDown = false
	allCardTypeIndex = allCardTypeIndex + 1
	local cards = this.FindSameCard(allResult[allCardTypeIndex])
	for i, v in ipairs(cards) do
		local y = cardTranTbl[v].tran.transform.localPosition.y
		if cardTranTbl[v] ~= nil and cardTranTbl[v].tran.transform.localPosition.y < 50 then
			this.CardClick(cardTranTbl[tonumber(v)].tran.gameObject, true)
		elseif cardTranTbl[tonumber(v) + 100] ~= nil then
			this.CardClick(cardTranTbl[tonumber(v) + 100].tran.gameObject, true)
		end
	end
	animationMove = true
	coroutine.start(function ()
		coroutine.wait(animationWaitTime)
		animationMove = false
	end
	)
	bottonSelectCardsBtn = index
end

function this.GetallCardType(cards)
	local normalCards = {}
    local laiziCards = {}
    for _, v in ipairs(cards) do
        local nValue = GetCardValue(v)
        if LibLaiZi:IsLaiZi(nValue) then
            table.insert(laiziCards, v)
        else
            table.insert(normalCards, v)
        end
    end
    local nLaziCount = #laiziCards
	return normalCards, nLaziCount, laiziCards
end

function this.DownSelectCard()
	---[[
	for i, v in ipairs(selectDownCards) do
		local obj = v.tran.gameObject
		local cardData = UIEventListener.Get(obj).parameter
		local pos = obj.transform.localPosition
		obj.transform.localPosition = Vector3.New(pos.x, 0, pos.z)
		cardData.cardType = CardType[1]
		--selectDownCards[tonumber(obj.name)] = cardData		
		UIEventListener.Get(obj).parameter = cardData
	end
	selectDownCards = {}
	--]]
end

function this.FindSameCard(cards)
	if cards == nil then
		Trace("FindSameCard，找相同的牌为空")
		return cards
	end
	for i = 1, #cards do
		for j = i + 1, #cards do
			if cards[i] == cards[j] then
				cards[i] = 100 + cards[i]
				break
			end
		end
	end
	return cards
end

--自动摆牌
function this.AutoPlace1Click(index)
	---[[
	if animationMove then
		return
	end
	local change_cards = Array.Clone(first_auto_all_card)
	if recommend_cards ~= nil then
		local rec_cards = recommend_cards[index]["Cards"]
		change_cards = Array.Clone(rec_cards)
	end
	change_cards = this.FindSameCard(change_cards)
	for i = 1, #change_cards do
		local destOjbPos = cardPlaceTranList[i]
		local cardNum = change_cards[i]
		if cardTranTbl[cardNum] == nil then
			Trace("推荐的牌有一张找不到："..tostring(cardNum))
			fast_tip.Show(GetDictString(6020))
			return
		end
		cardTranTbl[cardNum].tran.transform:DOLocalMove(destOjbPos.tran.transform.localPosition, animationTime, true)
		cardTranTbl[cardNum].tran.transform:DOScale(Vector3.New(0.65, 0.65, 0.65), animationSmallTime)
		local parameterData = UIEventListener.Get(cardTranTbl[cardNum].tran.gameObject).parameter
		parameterData.cardType = CardType[3]
		parameterData.up_index = i
		
		local dun, dun_no =  this.GetDunNo(i)
		up_placed_cards[dun][dun_no] = parameterData
		this.UpdateLeftCard(left_card, parameterData.card)
	end
	left_card = {}
	place_index = 14
	--]]
	for i = 1, #cardPlaceTranList do
		cardPlaceTranList[i].blank = false
	end
	this.DunTipShow(true)
	selectDownCards = {}
	this.PlaceCardFinish()
	
	animationMove = true
	coroutine.start(function ()
		coroutine.wait(animationWaitTime)
		animationMove = false
	end
	)
end

function this.DunBtnShow(placing_index)
	local dun_max_index, dun = this.GetDun(placing_index)
	print(placing_index.."  dun_max_index:..  "..dun_max_index.."   dun: "..dun)
	if dun ~= 3 then
		for i = dun_max_index, dun_max_index - 4, -1 do
			if cardPlaceTranList[i].blank == false then
				dunDownBtn[dun].gameObject:SetActive(true)
				dunTipSpt[dun].gameObject:SetActive(false)
				return
			end
		end
		dunDownBtn[dun].gameObject:SetActive(false)
		dunTipSpt[dun].gameObject:SetActive(true)
	else
		for i = dun_max_index, 11, -1 do
			if cardPlaceTranList[i].blank == false then
				dunDownBtn[dun].gameObject:SetActive(true)
				dunTipSpt[dun].gameObject:SetActive(false)
				return
			end
		end
		dunDownBtn[dun].gameObject:SetActive(false)
		dunTipSpt[dun].gameObject:SetActive(true)
	end
end

function this.DunTipShow(isShowBtn)
	for i = 1, 3 do
		dunDownBtn[i].gameObject:SetActive(isShowBtn)
	end
	local isShowSpt = true
	if isShowBtn then
		isShowSpt = false
	end
	for i = 1, 3 do
		dunTipSpt[i].gameObject:SetActive(isShowSpt)
	end
end
	
--下牌
function this.DownCardClick(dun, fast)
	if animationMove then
		return
	end 
	if selectUpCard~= nil then
		child(selectUpCard.transform, "guanghuan").gameObject:SetActive(false)
		selectUpCard = nil
	end
	if placeCard ~= nil then
		placeCard.gameObject:SetActive(true)
	end
	if prepare ~= nil then
		prepare.gameObject:SetActive(false)
	end
	local dun_cards = up_placed_cards[dun]
	local num = 0
	for i, v in pairs(dun_cards) do
	--[[	
		v.tran.transform:DOLocalMove(v.pos, animationTime, true)
		v.tran.transform:DOScale(Vector3.New(1, 1, 1), animationSmallTime)
		v.cardType = CardType[1]
		
		left_card[#left_card + 1] = v.card
		cardPlaceTranList[v.up_index].blank = true
		]]
		this.DownOneCard(v)
	end
	
	up_placed_cards[dun] = {}
	dunDownBtn[dun].gameObject:SetActive(false)
	dunTipSpt[dun].gameObject:SetActive(true)	
	this.TipsBtnShow(left_card)
	for k,v in ipairs(selectDownCards) do
		selectDownCards[k].cardType = CardType[1]
		selectDownCards[k] = nil
	end
	selectDownCards = {}
	if fast == nil or fast == false then
		animationMove = true
		coroutine.start(function ()
			coroutine.wait(animationWaitTime)
			cardGrid:Reposition()
			coroutine.wait(animationSmallTime)
			animationMove = false
		end)
	end
end

function this.DownOneCard(cardData, repos)
	cardData.tran.transform:DOLocalMove(cardData.pos, animationTime, true)
	cardData.tran.transform:DOScale(Vector3.New(1, 1, 1), animationSmallTime)
	cardData.cardType = CardType[1]
	
	left_card[#left_card + 1] = cardData.card
	cardPlaceTranList[cardData.up_index].blank = true
	place_index = place_index - 1
	
	if repos ~= nil and repos == true then
		animationMove = true
		coroutine.start(function ()
			coroutine.wait(animationWaitTime)
			cardGrid:Reposition()
			coroutine.wait(animationSmallTime)
			animationMove = false
		end)
	end
end

--补牌
function this.BuPai()
	if #left_card > 5 then
		return
	end
	if #left_card == 0 then
		return
	end
	local leftCardNum = #left_card
	local blankNum = 0
	for i = 1, 5 do
		if cardPlaceTranList[i].blank == true then
			blankNum = blankNum + 1
		end
	end
	if blankNum == leftCardNum then
		local down_card = this.GetDownCardSelect()
		this.CardBgClick(cardPlaceTranList[1].tran.gameObject)
		left_card = {}
		return
	end
	blankNum = 0
	for i = 6, 10 do
		if cardPlaceTranList[i].blank == true then
			blankNum = blankNum + 1
		end
	end
	if blankNum == leftCardNum then
		local down_card = this.GetDownCardSelect()
		this.CardBgClick(cardPlaceTranList[6].tran.gameObject)
		left_card = {}
		return
	end
	
	blankNum = 0
	for i = 11, 13 do
		if cardPlaceTranList[i].blank == true then
			blankNum = blankNum + 1
		end
	end
	if blankNum == leftCardNum then
		local down_card = this.GetDownCardSelect()
		this.CardBgClick(cardPlaceTranList[11].tran.gameObject)
		left_card = {}
		return
	end
	
	animationMove = true
	coroutine.start(function ()
		coroutine.wait(animationWaitTime * 3)
		animationMove = false
	end
	)
	
end

--下面选中的牌
function this.GetDownCardSelect()
	local downCard = {}
	for i, v in pairs(cardTranTbl) do
		local oneCard = UIEventListener.Get(v.tran.gameObject).parameter
		if oneCard.cardType == CardType[1] or oneCard.cardType == CardType[2] then
			table.insert(downCard, oneCard)
			--selectDownCards[tonumber(oneCard.card)] = oneCard
			table.insert(selectDownCards, oneCard)
		end
	end
	return downCard
end

function this.PlaceCardFinish()
	if placeCard ~= nil then
		placeCard.gameObject:SetActive(false)
	end
	if prepare ~= nil then
		prepare.gameObject:SetActive(true)
	end
	this.XiangGongTip()
end

--相公提示
function this.XiangGongTip()
	isXiangGong = this.XiangGong()
	local errorTipLbl = child(this.transform, "Panel_Bottom/prepare/errorTipLbl")
	if errorTipLbl ~= nil then
		if isXiangGong then
			errorTipLbl.gameObject:SetActive(true)
		else
			errorTipLbl.gameObject:SetActive(false)
		end
	end
end

function this.XiangGong()
	--[[local xianggong = lib_normal_card_logic:CompareCards_Laizi(this.CardGroup(1), this.CardGroup(2))
	print("isXianggong: "..tostring(xianggong))
	if xianggong >= 0 then
		xianggong = LibLaiziCardLogic:CompareCards_Laizi(this.CardGroup(2), this.CardGroup(3))
		if xianggong >= 0 then
			return false
		end
	end--]]


	--重新获取一遍
	local bSuc1, firstType, values1 = LibNormalCardLogic:GetCardTypeByLaizi(this.CardGroup(1))
	local bSuc2, secondType, values2 = LibNormalCardLogic:GetCardTypeByLaizi(this.CardGroup(2))
	local bSuc3, thirdType, values3 = LibNormalCardLogic:GetCardTypeByLaizi(this.CardGroup(3))

	--需要重新再比一次  防止换牌后还有相公
	local xianggong = true
	if LibNormalCardLogic:CompareCardsLaizi(firstType, secondType, values1, values2) < 0 then
		return true
	end
	if LibNormalCardLogic:CompareCardsLaizi(secondType, thirdType, values2, values3) < 0 then
		return true
	end
	if LibNormalCardLogic:CompareCardsLaizi(firstType, thirdType, values1, values3) < 0 then
		return true
	end


	return false
end

--之前客户端算的自动摆牌，现在不要了
---[[
function this.AtutoPlaceCardType()
	auto_place_card = Array.Clone(cardList)
	local first_five_cards = LibNormalCardLogic:GetMaxFiveCard(Array.Clone(auto_place_card))
	local card_type1 = LibNormalCardLogic:GetCardType(first_five_cards)
	local thirdCardLbl =  componentGet(child(this.transform, "Panel_TopRight/recommond/cardType1/thirdCardLbl"), "UILabel")
	local thirdCheckCardLbl =  componentGet(child(this.transform, "Panel_TopRight/recommond/cardType1/thirdCardLbl1"), "UILabel")
	if thirdCardLbl ~= nil or thirdCheckCardLbl ~=nil then
		thirdCardLbl.text = GStars_Normal_Type_Name[card_type1]
		thirdCheckCardLbl.text = GStars_Normal_Type_Name[card_type1]
	end
	auto_place_card = this.UpdateLeftCard(auto_place_card, first_five_cards)
	
	local next_five_card = LibNormalCardLogic:GetMaxFiveCard(Array.Clone(auto_place_card))
	local secondCardLbl =  componentGet(child(this.transform, "Panel_TopRight/crecommond/cardType1/secondCardLbl"), "UILabel")
	local secondCheckCardLbl =  componentGet(child(this.transform, "Panel_TopRight/recommond/cardType1/secondCardLbl1"), "UILabel")
	local card_type2 = LibNormalCardLogic:GetCardType(next_five_card)
	if secondCardLbl ~= nil or secondCheckCardLbl ~= nil then
		secondCardLbl.text = GStars_Normal_Type_Name[card_type2]
		secondCheckCardLbl.text = GStars_Normal_Type_Name[card_type2]
	end
	auto_place_card = this.UpdateLeftCard(auto_place_card, next_five_card)
	
	local firstCardLbl =  componentGet(child(this.transform, "Panel_TopRight/recommond/cardType1/firstCardLbl"), "UILabel")
	local firstCheckCardLbl =  componentGet(child(this.transform, "Panel_TopRight/recommond/cardType1/firstCardLbl1"), "UILabel")
	local card_type3 = LibNormalCardLogic:GetCardType(auto_place_card)
	if firstCardLbl ~= nil or firstCheckCardLbl ~= nil then
		firstCardLbl.text = GStars_Normal_Type_Name[card_type3]
		firstCheckCardLbl.text = GStars_Normal_Type_Name[card_type3]
	end
	local last_three_card = Array.Clone(auto_place_card)
	first_auto_all_card = {first_five_cards[1], first_five_cards[2], first_five_cards[3],
							first_five_cards[4], first_five_cards[5],
							next_five_card[1], next_five_card[2], next_five_card[3],
							next_five_card[4], next_five_card[5],
							last_three_card[1], last_three_card[2], last_three_card[3],
							last_three_card[4], last_three_card[5]}
end
--]]

function this.RecommendCardUpdate()
	if recommend_cards == nil then
		return
	end
	for i = 1, 4 do
		if recommend_cards[i] == nil or #recommend_cards[i]["Cards"] < 13 then
			local tipObj = child(this.transform, "Panel_TopRight/recommond/cardType"..i)
			tipObj.gameObject:SetActive(false)
		else
			local tipObj = child(this.transform, "Panel_TopRight/recommond/cardType"..i)
			tipObj.gameObject:SetActive(true)
			local types = recommend_cards[i]["Types"]
			local thirdCardLbl =  componentGet(child(this.transform, "Panel_TopRight/recommond/cardType"..tostring(i).."/thirdCardLbl"), "UILabel")
			local thirdCheckCardLbl =  componentGet(child(this.transform, "Panel_TopRight/recommond/cardType"..tostring(i).."/thirdCardLbl1"), "UILabel")
			if thirdCardLbl ~= nil and thirdCheckCardLbl ~= nil then
				thirdCardLbl.text = GStars_Normal_Type_Name[types[1]]
				thirdCheckCardLbl.text = GStars_Normal_Type_Name[types[1]]
			end
			local secondCardLbl =  componentGet(child(this.transform, "Panel_TopRight/recommond/cardType"..tostring(i).."/secondCardLbl"), "UILabel")
			local secondCheckCardLbl =  componentGet(child(this.transform, "Panel_TopRight/recommond/cardType"..tostring(i).."/secondCardLbl1"), "UILabel")
			if secondCardLbl ~= nil and secondCheckCardLbl ~= nil  then
				secondCardLbl.text = GStars_Normal_Type_Name[types[2]]
				secondCheckCardLbl.text = GStars_Normal_Type_Name[types[2]]
			end
			local firstCardLbl =  componentGet(child(this.transform, "Panel_TopRight/recommond/cardType"..tostring(i).."/firstCardLbl"), "UILabel")
			local firstCheckCardLbl =  componentGet(child(this.transform, "Panel_TopRight/recommond/cardType"..tostring(i).."/firstCardLbl1"), "UILabel")
			if firstCardLbl ~= nil and firstCheckCardLbl ~= nil then
				firstCardLbl.text = GStars_Normal_Type_Name[types[3]]
				firstCheckCardLbl.text = GStars_Normal_Type_Name[types[3]]
			end
		end
	end
	local tipObj = child(this.transform, "Panel_TopRight/recommond/cardType5")
	if nSpecialType ~= nil then
		tipObj.gameObject:SetActive(true)
		local thirdCardLbl =  componentGet(child(this.transform, "Panel_TopRight/recommond/cardType5/thirdCardLbl"), "UILabel")
		thirdCardLbl.text = tostring(GStars_Special_Type_Name[nSpecialType])
	else
		tipObj.gameObject:SetActive(false)
	end
	
	local grid = componentGet(child(this.transform, "Panel_TopRight/recommond"), "UIGrid")
	grid:Reposition()
end

function this.CardGroup(dun)
	local tbl ={}
	if dun == 1 then
		for i = 1, 5 do
			tbl[i] = up_placed_cards[1][i].card
		end
	elseif dun == 2 then
		for i = 1, 5 do
			tbl[i] = up_placed_cards[2][i].card
		end
	elseif dun == 3 then
		for i = 1, 3 do
			tbl[i] = up_placed_cards[3][i].card
		end
	end
	return tbl
end

--检查是否与原始牌一致
function this.CheckSendCard(sendCards)
	local clone_cards = Array.Clone(sendCards)
	local src_cards = Array.Clone(cardList)
	for i = #src_cards, 1, -1 do
		for j = #clone_cards, 1, -1 do
			if src_cards[i] == clone_cards[j] then
				table.remove(src_cards, i)
				table.remove(clone_cards, j)
			end
		end
	end
	if #clone_cards > 0 then
		fast_tip.Show(GetDictString(6021))
		return false
	end
	return true
end	
	
--只能用做有序的
function this.UpdateLeftCard(srcCard, temp)
	if type(temp) == "table" then
		Array.DelElements(srcCard, temp)
	else
		for i = #srcCard, 1, -1 do
			if temp == srcCard[i] then
				table.remove(srcCard, i)
				return srcCard
			end
		end
	end
	return srcCard
end

	
function this.Update()
	local timeEnd = room_data.GetPlaceCardTime()
	local curTime = os.time()
	local leftTime = timeEnd - curTime
	if leftTime <= 0 and curTime > timeSecond then
		this.Hide()
		return
	end
	lastTime = lastTime + Time.deltaTime
	if lastTime >= 1 and leftTime <= 11 then
		ui_sound_mgr.PlaySoundClip("game_80011/sound/audio/baipaishijianshengyu10sjinggao")
		lastTime = 0
	end
	if math.floor(leftTime) < 0 then
		leftTime = 0
	end
	timeLbl.text = tostring(math.floor(leftTime))

	if totalTime ~= nil then
		local percent = tonumber(leftTime) / tonumber(totalTime)
		if timeSpt ~= nil then 
			timeSpt.fillAmount = tonumber(percent)
		else
		end
	end
	
	
end

function this.CardSort(srcCards)
	table.sort(srcCards, function(a, b) return GetCardValue(a) < GetCardValue(b) end)
	--铁枝
	local bFound, temp = LibNormalCardLogic:Get_Max_Pt_Four(Array.Clone(srcCards))
	if temp ~= nil then
		local signleCard
		for i = 1, #srcCards - 1, 1 do
			if i < #srcCards - 1 and GetCardValue(srcCards[i]) ~= GetCardValue(srcCards[i + 1]) then 
				signleCard = srcCards[i]
				table.remove(srcCards, i)
				break
			end
		end
		table.insert(srcCards, signleCard)
		return srcCards
	end
	--葫芦
	local bFound, temp = LibNormalCardLogic:Get_Max_Pt_Full_Hosue(Array.Clone(srcCards))
	if temp ~= nil then
		if GetCardValue(srcCards[3]) == GetCardValue(srcCards[2]) then
			return srcCards
		else
			local signleCard = srcCards[2]
			table.remove(srcCards, 2)
			table.insert(srcCards, signleCard)
			
			signleCard = srcCards[1]
			table.remove(srcCards, 1)
			table.insert(srcCards, signleCard)
			return srcCards
		end
	end
	--三条
	local bFound, temp = LibNormalCardLogic:Get_Max_Pt_Three(Array.Clone(srcCards))
	if temp ~= nil then
		for i = 1, #srcCards do
			if GetCardValue(srcCards[i]) ~= GetCardValue(temp[1]) then
				table.insert(temp, srcCards[i])
			end
		end
		return temp
	end
	--二对
	local bFound, temp = LibNormalCardLogic:Get_Max_Pt_Two_Pair(Array.Clone(srcCards))
	if temp ~= nil then
		for i = 1, #srcCards do
			if GetCardValue(srcCards[i]) ~= GetCardValue(temp[1]) and  GetCardValue(srcCards[i]) ~= GetCardValue(temp[3]) then
				table.insert(temp, srcCards[i])
				break
			end
		end
		return temp
	end
	--一对
	local bFound, temp = LibNormalCardLogic:Get_Max_Pt_One_Pair(Array.Clone(srcCards))
	if temp ~= nil then
		for i = 1, #srcCards do
			if GetCardValue(srcCards[i]) ~= GetCardValue(temp[1]) then
				table.insert(temp, srcCards[i])
			end
		end
		return temp
	end
	return srcCards
end

function this.CardUpSort(srcUpCards)
	local srcCards = {}
	for i = 1, #srcUpCards do
		srcCards[i] = srcUpCards[i].card
	end
	srcCards = this.CardSort(srcCards)
	local sortUpCards = {}
	for i = 1, #srcCards do
		for j =  #srcUpCards, 1, -1 do
			if srcCards[i] == srcUpCards[j].card then
				table.insert(sortUpCards, srcUpCards[j])
				table.remove(srcUpCards, j)
				break
			end
		end
	end
	return sortUpCards
end
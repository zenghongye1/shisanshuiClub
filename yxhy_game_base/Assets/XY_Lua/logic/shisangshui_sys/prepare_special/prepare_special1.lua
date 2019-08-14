--[[--
 * @Description: 发牌下来时判断特殊牌型
 * @Author:      zhy
 * @FileName:    prepare_special.lua
 * @DateTime:    2017-07-05
 ]]

require "logic/shisangshui_sys/place_card/place_card"
require "logic/shisangshui_sys/lib/lib_sp_card_logic"
require "logic/shisangshui_sys/common/array"
require "logic/shisangshui_sys/card_define"

 
prepare_special = ui_base.New()
local this = prepare_special 
local transform;  

--计时间进度条
local timeSpt
--计时间Lbl
local timeLbl
--描述文字
local descLbl
--最大等待时间
local timeSecond = 10
--所有牌
local my_cards = {}

local cardTranTbl = {}
--特殊牌型
local card_type

local recommendCards

function this.Awake()
   this.initinfor()
  	--this.registerevent() 
end

function this.Show(cards, nSpecialType, dun, recCards)
	Trace("显示特殊牌型")
	card_type = nSpecialType
	--table.sort(cards, function(a, b) return GetCardValue(a) < GetCardValue(b) end)
	cards = Array.CardSort(cards, nSpecialType)
	timeSecond = os.time() + 5
	recommendCards = recCards
	Trace("---------cards------"..tostring(cards).."  dun: "..tostring(dun))
	my_cards = nil
	my_cards = cards
	if this.gameObject==nil then
		require ("logic/shisangshui_sys/prepare_special/prepare_special")
		this.gameObject=newNormalUI(data_center.GetResRootPath().."/ui/prepare_special")
	else
		for i, v in pairs(cardTranTbl) do
			if v ~= nil then
				GameObject.DestroyImmediate(v.gameObject)
			end
		end
        this.gameObject:SetActive(true)
	end
	this.LoadAllCard(my_cards, nSpecialType, dun)
  	--this.addlistener()
end

function this.Hide()
	if this.gameObject == nil then
		return
	else
		GameObject.Destroy(this.gameObject)
		this.gameObject = nil
	end
end

--[[--
 * @Description: 逻辑入口  
 ]]
function this.Start()
	this.registerevent()
end

--[[--
 * @Description: 销毁  
 ]]
function this.OnDestroy()
end

function this.initinfor()
	timeSpt = componentGet(child(this.transform, "ready/timeSpt"), "UISprite")
	timeLbl = componentGet(child(this.transform, "ready/timeLbl"), "UILabel")
	descLbl = componentGet(child(this.transform, "message/descLbl"), "UILabel")
end

--注册事件
function this.registerevent()
	this.BtnClickEvent()
end

function this.LoadAllCard(cards, nSpecialType, dun)
---[[
	
	local cardGrid = child(this.transform, "cardGrid")
	if cardGrid == nil then
		Trace("cardGrid == nil")
		return
	end

	for i, v in ipairs(cards) do
		local cardObj = newNormalUI(data_center.GetResPokerCommPath().."/card/"..tostring(v), cardGrid)
		cardTranTbl[i] = cardObj
		componentGet(child(cardTranTbl[i].transform, "bg"),"UISprite").depth = i * 2 + 3
		componentGet(child(cardTranTbl[i].transform, "num"),"UISprite").depth = i * 2 + 5
		componentGet(child(cardTranTbl[i].transform, "color1"),"UISprite").depth = i * 2 + 5
		componentGet(child(cardTranTbl[i].transform, "color2"),"UISprite").depth = i * 2 + 5
		if room_data.GetSssRoomDataInfo().isChip == true and v == 40 then
			child(cardTranTbl[i].transform,"ma").gameObject:SetActive(true)
			componentGet(child(cardTranTbl[i].transform, "ma"),"UISprite").depth = i * 2 + 4
		end
	end
	local grid =  componentGet(cardGrid,"UIGrid")
	if grid ~= nil then
		grid:Reposition()
	end
	this.SpecialCard(cards, nSpecialType, dun)
	--]]

	--obj.transform.localPosition = Vector3.New(delte.x, delte.y, obj.transform.localPosition.z)
end

function this.SpecialCard(cards, nSpecialType, dun)
	local dunNum = GStars_Special_Score[nSpecialType]
	descLbl.text = "出现特殊牌型"..tostring(GStars_Special_Type_Name[nSpecialType]).."，预计赢取每家"..tostring(dunNum).."水，是否按特殊牌型出牌？"
end



function this.BtnClickEvent()
	local btn_confirm = child(this.transform, "message/confirmbtn")
	if btn_confirm ~= nil then
		addClickCallbackSelf(btn_confirm.gameObject, this.ConfirmClick, this)
	end
	
	local cancelbtn = child(this.transform, "message/cancelbtn")
	if cancelbtn ~= nil then
		addClickCallbackSelf(cancelbtn.gameObject, this.CancelClick, this)
	end
end
----------------------------------按扭事件注册END-------------------------------

---------------------------点击事件-------------------------
function this.ConfirmClick(obj)
	shisangshui_play_sys.ChooseCardTypeReq(1)
	this.Hide()
	UI_Manager:Instance():CloseUiForms("place_card")
end

function this.CancelClick(obj)
	--shisangshui_play_sys.ChooseCardTypeReq(0)
	--place_card.Show(my_cards, recommendCards, card_type)
	local place_card = UI_Manager:Instance():GetUiFormsInShowList("place_card")
	if place_card ~= nil then
		place_card.gameObject:SetActive(true)
	else
	--	place_card.Show(my_cards, card_type)
		UI_Manager:Instance():ShowUiForms("place_card",UiCloseType.UiCloseType_CloseNothing,nil,my_cards,card_type)
	end
	this.gameObject:SetActive(false)
end

function this.ReShow()
	this.transform.gameObject:SetActive(true)
end
---------------------------点击事件END-------------------------

function this.Update()
	local timeEnd = room_data.GetPlaceCardTime()
	local curTime = os.time()
	local leftTime = timeEnd - curTime
	if leftTime <= 0 and curTime > timeSecond then
		--shisangshui_play_sys.PlaceCard(first_auto_all_card)
		this.Hide()
		return
	end
	if math.floor(leftTime) < 0 then
		leftTime = 0
	end
	
	timeLbl.text = tostring(math.floor(leftTime))
	timeSpt.fillAmount = math.floor(leftTime) / room_data.GetSssRoomDataInfo().placeCardTime
end


--[[--
 * @Description: 发牌下来时判断特殊牌型
 * @Author:      zhy
 * @FileName:    prepare_special.lua
 * @DateTime:    2017-07-05
 ]]

local base = require("logic.framework.ui.uibase.ui_window")
local prepare_special = class("prepare_special",base)

function prepare_special:ctor()
	base.ctor(self)
	--计时间进度条
	--self.timeSpt = nil
	--计时间Lbl
	self.timeLbl = nil
	--描述文字
	self.descLbl = nil
	--最大等待时间
	self.timeSecond = 10
	--所有牌
	self.my_cards = nil

	self.cardTranTbl = {}
	--特殊牌型
	self.card_type = nil

	--self.recommendCards = nil
end

function prepare_special:OnInit()
	self:InitView()
end

function prepare_special:OnOpen( ... )
	local cards = {}
	local nSpecialType = nil
	local nSpecialScore = nil
	local recCards = {}
	if self.args == nil or #self.args < 3 then
		Trace("特殊牌型参数传的错。请检查参数个数")
	end
	cards = self.args[1]
	nSpecialType = self.args[2]
	nSpecialScore = self.args[3]
	--recCards = self.args[4]
	
	self.card_type = nSpecialType
	--cards = Array.CardSort(cards, nSpecialType)	特殊牌型服务器排好序
	--self.recommendCards = recCards
	self.my_cards = nil
	self.my_cards = cards
	for i, v in pairs(self.cardTranTbl) do
		if v ~= nil then
			GameObject.DestroyImmediate(v.gameObject)
		end
	end
	self.cardTranTbl = {}
	self:LoadAllCard(self.my_cards, nSpecialType, nSpecialScore)
	self:StartTimer()
end

function prepare_special:OnClose()
	for i, v in pairs(self.cardTranTbl) do
		if v ~= nil then
			GameObject.DestroyImmediate(v.gameObject)
		end
	end
	self.my_cards = nil
	self.cardTranTbl = {}
	self:StopTimer()
end

function prepare_special:PlayOpenAmination()
	--打开动画重写
end

function prepare_special:InitView()
	--self.timeSpt = componentGet(child(self.transform, "ready/timeSpt"), "UISprite")
	self.timeLbl = componentGet(child(self.transform, "panel/ready/timeLbl"), "UILabel")
	self.descLbl = componentGet(child(self.transform, "panel/message/descLbl"), "UILabel")
	self.cardGrid = child(self.transform, "panel/cardGrid")
	self.btn_confirm = child(self.transform, "panel/message/confirmbtn")
	if self.btn_confirm ~= nil then
		addClickCallbackSelf(self.btn_confirm.gameObject, self.ConfirmClick, self)
	end
	self.cancelbtn = child(self.transform, "panel/message/cancelbtn")
	if self.cancelbtn ~= nil then
		addClickCallbackSelf(self.cancelbtn.gameObject, self.CancelClick, self)
	end
end

function prepare_special:LoadAllCard(cards, nSpecialType, nSpecialScore)
	if self.cardGrid == nil then
		Trace("cardGrid == nil")
		return
	end

	for i, v in ipairs(cards) do
		local cardObj = poker2d_factory.GetPoker(tostring(v))
		cardObj.transform:SetParent(self.cardGrid,false)
		self.cardTranTbl[i] = cardObj
		componentGet(child(self.cardTranTbl[i].transform, "bg"),"UISprite").depth = i * 2 + 3
		componentGet(child(self.cardTranTbl[i].transform, "num"),"UISprite").depth = i * 2 + 5
		componentGet(child(self.cardTranTbl[i].transform, "color1"),"UISprite").depth = i * 2 + 5
		componentGet(child(self.cardTranTbl[i].transform, "color2"),"UISprite").depth = i * 2 + 5
		if roomdata_center.gamesetting["nBuyCode"] > 0 and v == card_define.GetCodeCard() then
			child(self.cardTranTbl[i].transform,"ma").gameObject:SetActive(true)
			componentGet(child(self.cardTranTbl[i].transform, "ma"),"UISprite").depth = i * 2 + 4
		end
	end
	local grid =  componentGet(self.cardGrid,"UIGrid")
	if grid ~= nil then
		grid:Reposition()
	end
	self:SpecialCard(cards, nSpecialType, nSpecialScore)
end

function prepare_special:SpecialCard(cards, nSpecialType, nSpecialScore)
	self.descLbl.text = "出现特殊牌型"..card_define.GetSpecialTypeName(nSpecialType).."，预计赢取每家"..tostring(nSpecialScore).."水，是否按特殊牌型出牌？"
end

----------------------------------按扭事件注册END-------------------------------

---------------------------点击事件-------------------------
function prepare_special:ConfirmClick(obj)
	pokerPlaySysHelper.GetCurPlaySys().ChooseCardTypeReq(1)
	UI_Manager:Instance():CloseUiForms("prepare_special")
	UI_Manager:Instance():CloseUiForms("place_card")
	Notifier.dispatchCmd(cmd_shisanshui.PlaceCardCountDown,self.timeEnd ) --让牌局UI显示剩下的时间倒计时
end

function prepare_special:CancelClick(obj)
	UI_Manager:Instance():ShowUiForms("place_card",UiCloseType.UiCloseType_CloseNothing,nil,self.my_cards,self.card_type)
	UI_Manager:Instance():CloseUiForms("prepare_special")
end

function prepare_special:ReShow()
	this.transform.gameObject:SetActive(true)
end
---------------------------点击事件END-------------------------

function prepare_special:StartTimer()
	if self.timer == nil then
		self.timeEnd = room_data.GetPlaceCardTime() - os.time()
		self.timeLbl.text = tostring(math.floor(self.timeEnd))
		self.timer = Timer.New(slot(self.OnTimer_Proc,self),1,self.timeEnd)
		self.timer:Start()
	end
end

function prepare_special:OnTimer_Proc()
	self.timeEnd = self.timeEnd - 1
	self.timeLbl.text = tostring(math.floor(self.timeEnd))
	if math.floor(self.timeEnd) <= 0 then
		UI_Manager:Instance():CloseUiForms("prepare_special")
		return
	end	
end

function prepare_special:StopTimer()
	if self.timer ~= nil then
		self.timer:Stop()
		self.timer = nil
	end
end

return prepare_special


require "logic/mahjong_sys/_model/room_usersdata_center"
require "logic/mahjong_sys/_model/room_usersdata"
require "logic/mahjong_sys/_model/operatorcachedata"
require "logic/mahjong_sys/_model/operatordata"
--require "logic/shisangshui_sys/ui_shisangshui/shisanshui_player_ui"
require "logic/gvoice_sys/gvoice_sys"
require "logic/niuniu_sys/other/poker_table_coordinate"

local base = require("logic.poker_sys.common.poker_ui_base")
local shisanshui_ui = class("shisanshui_ui",base)

local shisanshui_player_ui = require("logic.shisangshui_sys.ui_shisangshui.shisanshui_player_ui")

function shisanshui_ui:ctor()
	base.ctor(self)
	self.widgetTbl = {}
	self.compTbl = {}
	self.special_card_type = {}
	self.read_card_player = {}
	self.chatTextTab = {
		"快点快点，这把我要全垒打",
		"慢死了，虾米都煮成稀饭了",
		"快点呀！我等得花都又开了",
		"辛辛苦苦很多年，一把回到解放前",
		"哎呀~为什么中枪的总是我？",
		"搏一搏，单车变摩托",
		"押得多赢得多，娶个媳妇回家暖被窝~",
		"有运气还要什么技术啊",
		"哈哈，你们赶快穿上防弹衣吧！"
	}
	self.animationTabel = {}
	self._xiaopaoTime = 0
	self.xiaopaoTimer_Elapse = nil
	self.xiaopaoCallBack = nil
	self.before_starting_operation_view = nil
	self.SpecialSetState = false		--自己是否特殊牌型
	self.destroyType = UIDestroyType.Immediately
end


function shisanshui_ui:OnInit()
	base.OnInit(self)
	self:InitWidgets()

	msg_dispatch_mgr.SetIsEnterState(true)	
end

function shisanshui_ui:OnOpen()
	base.OnOpen(self)
	self:CreatePlayerList(roomdata_center.maxSupportPlayer,shisanshui_player_ui)
	self:SetCodeCardShow()
end

function shisanshui_ui:OnClose()
	base.OnClose(self)
	gps_data.ResetGpsData()
	self:ReSetReadCard(false)
	self:ResetAll()
	
	for i ,v in pairs(self.playerList) do
		v:Hide()
	end
	self.playerList = {}

	card_define.SetCodeCardValue(0)
end

function shisanshui_ui:ExitClickCallback()
	local roomInfo = roomdata_center.gamesetting
	local bankerViewSeat = roomdata_center.zhuang_viewSeat
	if roomInfo["bSupportWaterBanker"] == true and bankerViewSeat == 1 then
		MessageBox.ShowYesNoBox("你是庄家,离开后会解散牌局,是否离开？", function() pokerPlaySysHelper.GetCurPlaySys().LeaveReq() end)
	else
		MessageBox.ShowYesNoBox(LanguageMgr.GetWord(5001),function()
			pokerPlaySysHelper.GetCurPlaySys().LeaveReq() 
		end)
	end
end

--[[--
 * @Description: 获取各节点对象  
 ]]
function shisanshui_ui:InitWidgets()
	self.widgetTbl.panel = child(self.transform, "Panel")
	self.widgetTbl.bottom = child(self.widgetTbl.panel,"Anchor_Bottom")
	--找到三个动画结点
	for i = 1,3 do
		local animObj = child(self.widgetTbl.panel, "Anchor_Amination/shisanshui_shoot_"..tostring(i))
		if animObj ~= nil then
			table.insert(self.animationTabel, animObj)
			animObj.gameObject:SetActive(false)
		end
	end
	---返回大厅按钮点击回调
	base.SetExitBtnCallback(self,slot(self.ExitClickCallback,self))

    self.before_starting_operation_view = require("logic.niuniu_sys.ui.sub_ui.before_starting_operation_view"):create(child(self.widgetTbl.panel, "Anchor_Center/readyBtns"),self)

	--剩余牌文本提示
	self.widgetTbl.lbl_leftCard = child(self.widgetTbl.panel,"Anchor_TopLeft/leftCardNum")
	if self.widgetTbl.lbl_leftCard ~= nil then
		self.widgetTbl.lbl_leftCard.gameObject:SetActive(false)
	end
	self.widgetTbl.leftCardNums = componentGet(self.widgetTbl.lbl_leftCard,"UILabel")
	--剩余牌面展示
	self.widgetTbl.tran_leftCard = child(self.widgetTbl.panel,"Anchor_TopLeft/leftCard")
	if self.widgetTbl.tran_leftCard ~= nil then
		self.widgetTbl.tran_leftCard.gameObject:SetActive(false)
	end

	---比分相关Tbl
	self.scoreTranTbl = {}
	for i=1,3 do 
		local groupScoreTran = child(self.widgetTbl.panel,"Anchor_Bottom/Score"..i)
		groupScoreTran.gameObject:SetActive(false)
		self.scoreTranTbl[i] = {}
		self.scoreTranTbl[i]["scoreTran"] = groupScoreTran
		self.scoreTranTbl[i]["posLbl"] = subComponentGet(groupScoreTran,"Label","UILabel")
		self.scoreTranTbl[i]["negLbl"] = subComponentGet(groupScoreTran,"negLabel","UILabel")
		self.scoreTranTbl[i]["changeAddLbl"] = subComponentGet(groupScoreTran,"socreChange/lblAdd","UILabel")
		self.scoreTranTbl[i]["changeRedLbl"] = subComponentGet(groupScoreTran,"socreChange/lblReduce","UILabel")
	end

	--特殊牌型图标
	self.widgetTbl.group = child(self.widgetTbl.panel,"Anchor_Center/special_card_type_group")
	if self.widgetTbl.group ~= nil then
		for i =1, roomdata_center.maxSupportPlayer do
			local special_card_icon = child(self.widgetTbl.group,"special_card_type_"..i)
			self.special_card_type["special_card_type_"..tostring(i)] = special_card_icon
			self.special_card_type["special_card_type_"..tostring(i)].gameObject:SetActive(false)
		end
	end
	
	--码牌展示
	self.widgetTbl.codeCard = child(self.widgetTbl.panel,"Anchor_TopLeft/mapai")
	if self.widgetTbl.codeCard ~= nil then
		self.widgetTbl.codeCard.gameObject:SetActive(false)
	end
	
	--自己的特殊牌型展示
	self.widgetTbl.special = child(self.widgetTbl.panel,"Anchor_Center/self_specialShow")
	if self.widgetTbl.special ~= nil then
		self.widgetTbl.special.specialType = child(self.widgetTbl.special,"specialCard")
		self.widgetTbl.special.gameObject:SetActive(false)
	end
	
	--翻牌区域
	self.widgetTbl.touchArea = child (self.widgetTbl.panel,"Anchor_Center/touchArea")
	if self.widgetTbl.touchArea ~= nil then
		UIEventListener.Get(self.widgetTbl.touchArea.gameObject).onPress = function(obj,state)
			self:OnTouchShowCards(state)
		end
		self.widgetTbl.touchArea.gameObject:SetActive(false)
	end

	--理牌提示
	self.widgetTbl.readCardGroup = child(self.widgetTbl.panel,"Anchor_Center/read_card_group")
	if self.widgetTbl.readCardGroup~=nil then
		self.widgetTbl.readCardGroup.gameObject:SetActive(true)
		for i=1,roomdata_center.maxSupportPlayer do
			local tReadCard = child(self.widgetTbl.readCardGroup,"read_card"..i)
			self.read_card_player[tostring(i)] = tReadCard
			self.read_card_player["time"..tostring(i)]={}
			tReadCard.gameObject:SetActive(false)
		end
	end

	--水庄倒计时
	self.widgetTbl.xiaopao_timePanel = child(self.widgetTbl.panel,"Anchor_Center/xiaopao_time")
	if self.widgetTbl.xiaopao_timePanel~=nil then
		self.widgetTbl.xiaopao_timePanel.gameObject:SetActive(false)
	end
	self.widgetTbl.xiaopao_time= componentGet(child(self.widgetTbl.xiaopao_timePanel,"time"),"UILabel")
	

    --创建用户列表
    self.playerList = {}
	local peopleNum = roomdata_center.maxplayernum
	Trace("PeopleNum:"..tostring(peopleNum))

	
	--倍数
    self.compTbl.xiapao = child(self.widgetTbl.panel, "Anchor_Center/xiapao")
	if self.compTbl.xiapao~=nil then
		for i=1,5 do
			local btn_xiapao = child(self.compTbl.xiapao, "pao"..i)
			addClickCallbackSelf(btn_xiapao.gameObject,
			function ()
				ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
				pokerPlaySysHelper.GetCurPlaySys().beishu(i)
				self:SetXiaoPao(0)
				self:IsShowBeiShuiBtn(false)
			end,
			self)
		end
       self.compTbl.xiapao.gameObject:SetActive(false)
    end
	
	self.widgetTbl.btn_setBanker = child(self.widgetTbl.panel,"Anchor_Center/readyBtns/setbanker")
	self.widgetTbl.btn_setBanker.gameObject:SetActive(false)
	addClickCallbackSelf(self.widgetTbl.btn_setBanker.gameObject,self.Onbtn_setBankerOnClick,self)
	
	-- --iPhoneX适配
	-- local delayTimer = Timer.New(function()
	-- local widgetPanel = child(self.transform, "Panel")
	-- if widgetPanel and data_center.GetCurPlatform() == "IPhonePlayer" and YX_APIManage.Instance:isIphoneX() then
	-- 	local Anchor_TopRight = child(widgetPanel, "Anchor_TopRight")
	-- 	if Anchor_TopRight then
	-- 		local localPos = Anchor_TopRight.gameObject.transform.localPosition
	-- 		Anchor_TopRight.gameObject.transform.localPosition = Vector3(localPos.x -60, localPos.y, localPos.z)
	-- 	end
	-- 	local Anchor_Right = child(widgetPanel, "Anchor_Right")
	-- 	if Anchor_Right then
	-- 		local localPos = Anchor_Right.gameObject.transform.localPosition
	-- 		Anchor_Right.gameObject.transform.localPosition = Vector3(localPos.x -60, localPos.y, localPos.z)
	-- 	end
	-- end
	-- end, 0.1, 1)
	-- delayTimer:Start()
end

--我要当庄
function shisanshui_ui:Onbtn_setBankerOnClick()
 	MessageBox.ShowYesNoBox("成为庄家后不可提前离场，是否确认成为庄家",function() 
		pokerPlaySysHelper.GetCurPlaySys().ChooseBankerReq()
	end)
end

function shisanshui_ui:OnTouchShowCards(state)
	Trace("---------OnTouchShowCards-------------"..tostring(state))
	for _,player in pairs(self.playerList) do
		if player.viewSeat == 1 then
			Notifier.dispatchCmd(cmd_shisanshui.OpenSelfCard,state)
			if self.SpecialSetState == true then
				Notifier.dispatchCmd(cmd_shisanshui.IsShowSelfSpecial,state)
			end
		end
	end
end

function shisanshui_ui:IsEnableTouch(state)
	self.widgetTbl.touchArea.gameObject:SetActive(state)
end

--设置剩余牌数量
function shisanshui_ui:SetLeftCardNums(num)
	if num ~= nil then
		self.widgetTbl.lbl_leftCard.gameObject:SetActive(true)
		self.widgetTbl.leftCardNums.text = "剩余牌数："..tostring(num)
	else
		self.widgetTbl.lbl_leftCard.gameObject:SetActive(false)
	end
end

function shisanshui_ui:SetLeftCard(data)
	if data ~= nil and #data == 2 then
		self:SetLeftCardShow(true)
		for i=1,2 do
			local card = child(self.widgetTbl.tran_leftCard,"card"..i)
			local go = poker2d_factory.GetPoker(tostring(data[i]))
			go.transform:SetParent(card,false)
			go.transform.localPosition = Vector3(0,0,0)
			go.transform.localScale = Vector3(1,1,1)
		end	
	end
end

function shisanshui_ui:SetLeftCardShow(state)
	self.widgetTbl.tran_leftCard.gameObject:SetActive(state)
end

function shisanshui_ui:SetLeftCardBack(state)
	for i=1,2 do
		local pokerBack = child(self.widgetTbl.tran_leftCard,"pokerBack"..i)
		pokerBack.gameObject:SetActive(state)
	end
end

function shisanshui_ui:ReSetLeftCard()
	self:SetLeftCardShow(false)
	for i=1,2 do
		local tran = child(self.widgetTbl.tran_leftCard,"card"..i)
		if tran.childCount > 0 then
			local card = tran.transform:GetChild(0)
			if card ~= nil then
				card.parent = nil
				card.gameObject:SetActive(false)
				GameObject.Destroy(card.gameObject)
			end
		end
	end
end

---左上角马牌展示
function shisanshui_ui:SetCodeCardShow()
	if roomdata_center.gamesetting["nBuyCode"] > 0 then
		self.widgetTbl.codeCard.gameObject:SetActive(true)
		if roomdata_center.gamesetting["nBuyCode"] ~= 5 then
			self:SetCodeCard()
			child(self.widgetTbl.codeCard,"card/unknown").gameObject:SetActive(false)
		else
			child(self.widgetTbl.codeCard,"card/unknown").gameObject:SetActive(true)
		end
	else
		self.widgetTbl.codeCard.gameObject:SetActive(false)
	end
end

---设置马牌值
function shisanshui_ui:SetCodeCard()
	local codeCardValue = card_define.GetCodeCard()
	if codeCardValue > 0 then
		poker2d_factory.SetPokerStyle(codeCardValue,child(self.widgetTbl.codeCard,"card/40").gameObject)
	else
		child(self.widgetTbl.codeCard,"card/unknown").gameObject:SetActive(true)
	end
end

---开马特效
function shisanshui_ui:OpenCodeCardEffect(state,isPlay)
	if roomdata_center.gamesetting["nBuyCode"] ~= 5 or card_define.GetCodeCard() <= 0 then
		return
	end
	if state then
		self:SetCodeCard()
		child(self.widgetTbl.codeCard,"card/unknown").gameObject:SetActive(false)
	else
		child(self.widgetTbl.codeCard,"card/unknown").gameObject:SetActive(true)
	end
end

--设置水庄倒计时
function shisanshui_ui:SetXiaoPao(time,callback)
	if time==nil or time<=0 then
		self:ShowXiaoPaoPanel(false)
	elseif (self.xiaopaoTimer_Elapse == nil) then
		self:StartXiaoPaoTimer(time)
		self.xiaopaoCallBack = callback
	end
end

function shisanshui_ui:StartXiaoPaoTimer(time)
	self:ShowXiaoPaoPanel(true)
	self._xiaopaoTime =math.floor(time)	
	self:SetXiaoPaoLabel(self._xiaopaoTime)	
	self.xiaopaoTimer_Elapse = Timer.New(slot(self.OnXiaopaoTimer_Proc,self),1,time)
	self.xiaopaoTimer_Elapse:Start()
end

function shisanshui_ui:OnXiaopaoTimer_Proc()
	self._xiaopaoTime = self._xiaopaoTime -1;
	self:SetXiaoPaoLabel(self._xiaopaoTime)
	if self._xiaopaoTime <= 0 then
		self:StopXiaopaoTimer()
		self:ShowXiaoPaoPanel(false)
		--时间到了处理逻辑
		if self.xiaopaoCallBack ~=nil then
			self.xiaopaoCallBack()
		end
	end
end

function shisanshui_ui:StopXiaopaoTimer()
	if self.xiaopaoTimer_Elapse ~= nil then
		self.xiaopaoTimer_Elapse:Stop()
		self.xiaopaoTimer_Elapse = nil
	end
end

function shisanshui_ui:SetXiaoPaoLabel(time)
	if  self.widgetTbl.xiaopao_time ~= nil then 
		self.widgetTbl.xiaopao_time.text = "等待其他闲家选择倍数：" .. tostring(time) .."s"
	else
		Trace("self.widgetTbl.xiaopao_time = nil")
		self:StopXiaopaoTimer()
	end
end

function shisanshui_ui:ShowXiaoPaoPanel(state)
	self.widgetTbl.xiaopao_timePanel.gameObject:SetActive(state)
end

function shisanshui_ui:ShowPlayerTotalPoints(viewSeat,totalPoint)
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetTotalPoints(totalPoint)
	end
end

function shisanshui_ui:IsShowBeiShuiBtn(isShow)
	self.compTbl.xiapao.gameObject:SetActive(isShow)
end

function shisanshui_ui:SetPlayerMachine(viewSeat, isMachine )
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetMachine(isMachine)
	end
end

function shisanshui_ui:SetPlayerLineState(viewSeat, isOnLine )
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetOffline(not isOnLine)
	end
end

function shisanshui_ui:SetHideTotaPoints()
	for i,v in pairs(self.playerList) do
		v:HideTotalPoints()
	end
end

function shisanshui_ui:SetPlayerScore(viewSeat,value)
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetScore(value)
	end
end

function shisanshui_ui:AddPlayerScore(viewSeat,value)
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:AddScore(value)
	end
end

function shisanshui_ui:SetPlayerReady( viewSeat,isReady )
	Trace("viewSeat-------------------------------------"..tostring(viewSeat))
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetReady(isReady)
	end
end

function shisanshui_ui:SetAllPlayerReady(isReady)
	for i,v in pairs(self.playerList) do
		v:SetReady(isReady)
	end
end

--设置头像的光圈
function shisanshui_ui:SetPlayerLightFrame(viewSeat)
	local Player = self.playerList[viewSeat]
	if Player ~= nil then
		Trace("当前桌面对应的座位号"..tostring(Player.viewSeat).."transformName"..tostring(Player.transform.name))
		local effect = EffectMgr.PlayEffect(data_center.GetResPokerCommPath().."/effects/Effect_win",1,1)
		effect.transform:SetParent(child(Player.transform,"winFrame"),false)
		Utils.SetEffectSortLayer(effect.gameObject,self.sortingOrder + self.m_subPanelCount + 1)
	end
end

------比牌各墩分数
function shisanshui_ui:SetGruopScore(index,score,scoreExt,scoreChange,allScore)
	local index = tonumber(index)
	if index == 0 then
		for i=1,3 do
			self.scoreTranTbl[i]["negLbl"].gameObject:SetActive(true)
			self.scoreTranTbl[i]["posLbl"].gameObject:SetActive(false)
			self.scoreTranTbl[i]["negLbl"].text = 0
			self.scoreTranTbl[i]["scoreTran"].gameObject:SetActive(true)
		end
	elseif index > 0 and index < 4 then
		self:SetScoreEffect(index,score + scoreExt,scoreChange)
	else
		---index=4不处理
	end
end

function shisanshui_ui:SetScoreEffect(i,totalScore,scoreChange)
	if not self.scoreTranTbl or not self.scoreTranTbl[i] then
		return
	end
	
	if(totalScore <= 0)	then
		local str = tostring(totalScore)
		self.scoreTranTbl[i]["negLbl"].gameObject:SetActive(true)
		self.scoreTranTbl[i]["posLbl"].gameObject:SetActive(false)
		self.scoreTranTbl[i]["negLbl"].text = str
		self.scoreTranTbl[i]["scoreTran"].gameObject:SetActive(true)
	else
		local str = "+"..tostring(totalScore)
		self.scoreTranTbl[i]["posLbl"].gameObject:SetActive(true)
		self.scoreTranTbl[i]["negLbl"].gameObject:SetActive(false)
		self.scoreTranTbl[i]["posLbl"].text = str
		self.scoreTranTbl[i]["scoreTran"].gameObject:SetActive(true)
	end
	if scoreChange then
		if  scoreChange <= 0 then
			self.scoreTranTbl[i]["changeAddLbl"].gameObject:SetActive(false)
			self.scoreTranTbl[i]["changeRedLbl"].gameObject:SetActive(true)
			self.scoreTranTbl[i]["changeRedLbl"].text = tostring(scoreChange)
			local tweenPosition = componentGet(self.scoreTranTbl[i]["changeRedLbl"].gameObject,"TweenPosition")
			local tweenAlpha = componentGet(self.scoreTranTbl[i]["changeRedLbl"].gameObject,"TweenAlpha")
			tweenPosition:ResetToBeginning()
			tweenPosition.enabled =true
			tweenAlpha:ResetToBeginning()
			tweenAlpha.enabled =true
			addTweenFinishedCallback(self.scoreTranTbl[i]["changeRedLbl"].transform, "", function ()
				self.scoreTranTbl[i]["changeRedLbl"].gameObject:SetActive(false)
			end,self)
		else
			self.scoreTranTbl[i]["changeRedLbl"].gameObject:SetActive(false)
			self.scoreTranTbl[i]["changeAddLbl"].gameObject:SetActive(true)
			self.scoreTranTbl[i]["changeAddLbl"].text = "+"..tostring(scoreChange)
			local tweenPosition = componentGet(self.scoreTranTbl[i]["changeAddLbl"].gameObject,"TweenPosition")
			local tweenAlpha = componentGet(self.scoreTranTbl[i]["changeAddLbl"].gameObject,"TweenAlpha")
			tweenPosition:ResetToBeginning()
			tweenPosition.enabled =true
			tweenAlpha:ResetToBeginning()
			tweenAlpha.enabled =true
			addTweenFinishedCallback(self.scoreTranTbl[i]["changeAddLbl"].transform, "", function ()
				self.scoreTranTbl[i]["changeAddLbl"].gameObject:SetActive(false)
			end,self)
		end
	end
end

--设置三墩比分lbl位置以适配不同机型
function shisanshui_ui:SetScoreAdaptPos(tbl)
	local offsetPos = self.widgetTbl.bottom.localPosition
	for i=1,3 do
		self.scoreTranTbl[i]["scoreTran"].localPosition = Vector3(tbl[i].x-offsetPos.x+180,tbl[i].y-offsetPos.y,0)
	end
end

function shisanshui_ui:SetShootScoreChange(tbl)
	self:SetScoreEffect(1,tbl.firstGroupScore,tbl.firstSoreChange)
	self:SetScoreEffect(2,tbl.secondGroupScore,tbl.secondSoreChange)
	self:SetScoreEffect(3,tbl.threeGroupScore,tbl.thirdSoreChange)
end

function shisanshui_ui:HideScoreGroup()
	for i=1,3 do
		self.scoreTranTbl[i]["scoreTran"].gameObject:SetActive(false)
	end
end

--播放开始比牌的动画效果
function shisanshui_ui:PlayerStartCompareAnimation()
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/dub/kaishibipai_nv")
	local effect = EffectMgr.PlayEffect(data_center.GetResRootPath().."/effects/Effect_kaishibipai",1,0.5)	--1
	effect.transform:SetParent(self.gameObject.transform,false)
end

function shisanshui_ui:SetBanker( viewSeat )
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetBanker(true)
	end
end

function shisanshui_ui:ResetAll()
	base.ResetAll(self)
	for _,v in pairs(self.playerList) do
		v:HideTotalPoints()
		if not roomdata_center.gamesetting.bSupportWaterBanker then
			v:SetBanker(false)
		end
		v:HideBeiShu()	
	end
	--self:ReSetReadCard(false)
	self.readyBtnsView:SetReadyBtnVisible(false)
	self:HideScoreGroup()
	self:HideSpecialCardIcon()
	self:IsShowSelfSpecial(false)
	self:HideDisMissCountDown()
	self:StopCountDownTimer()
	self:SetLeftCardNums()
	self:ReSetLeftCard()
	self.SpecialSetState = false
	self:OpenCodeCardEffect(false)	
	self:IsShowChooseBanker(false)
end

function shisanshui_ui:GetShootTran( viewSeat )
	if self.playerList[viewSeat] ~= nil then
		return self.playerList[viewSeat]:ShootTran()
	end
end

function shisanshui_ui:GetShootHoleTran(viewSeat, index)
	if self.playerList[viewSeat] ~= nil then
		return self.playerList[viewSeat]:ShootHoleTran(index)
	end
end

--显示特殊牌型的图标
function shisanshui_ui:ShowSpecialCardIcon(tbl)
	local iconImage = self.special_card_type["special_card_type_"..tbl.chairIndex]
	iconImage.gameObject.transform.localPosition = tbl.position
	iconImage.gameObject:SetActive(true)	
end

function shisanshui_ui:HideSpecialCardIcon()
	for i = 1,roomdata_center.maxSupportPlayer do
		self.special_card_type["special_card_type_"..i].gameObject:SetActive(false)
	end
end

--显示自己特殊牌型
function shisanshui_ui:SetSelfChooseSpecial(tbl)
	self.widgetTbl.special.localPosition = Vector3(tbl.position.x,tbl.position.y - 100,tbl.position.z)
	if self.widgetTbl.special.specialType ~= nil then
		local SpeSprite = componentGet(self.widgetTbl.special.specialType, "UISprite")
		SpeSprite.spriteName = tbl["SpecialType"]
		self.SpecialSetState = true
		self.widgetTbl.special.gameObject:SetActive(false)
	end
end

--是否显示我要选庄按钮
function  shisanshui_ui:IsShowChooseBanker(isShow)
	self.widgetTbl.btn_setBanker.gameObject:SetActive(isShow)
end

function shisanshui_ui:IsShowSelfSpecial(state)
	self.widgetTbl.special.gameObject:SetActive(state)
end

--设置理牌提示
function shisanshui_ui:SetReadCardState(tbl)
	local viewSeat = tbl.viewSeat
	local state = tbl.state
	local postion = tbl.position
	if state == true then
		self.read_card_player[tostring(viewSeat)].transform.localPosition = postion
		self.read_card_player[tostring(viewSeat)].gameObject:SetActive(true)
		self:ReadCardStartTimer(state,viewSeat)
	else
		self.read_card_player[tostring(viewSeat)].gameObject:SetActive(false)
		self:ReadCardStartTimer(state,viewSeat)
	end
end

function shisanshui_ui:SetReadCardByState(viewSeat,state,postion)
	if state == true then
		self.read_card_player[tostring(viewSeat)].transform.localPosition = postion
		self.read_card_player[tostring(viewSeat)].gameObject:SetActive(true)
		self:ReadCardStartTimer(state,viewSeat)
	else
		self.read_card_player[tostring(viewSeat)].gameObject:SetActive(false)
		self:ReadCardStartTimer(state,viewSeat)
	end
end

function shisanshui_ui:ReSetReadCard(state)
	for i =1,roomdata_center.maxSupportPlayer do
		self.read_card_player[tostring(i)].gameObject:SetActive(state)
		if not state and self.read_card_player["time"..tostring(i)] ~= nil and self.read_card_player["time"..tostring(i)].timer_Elapse ~= nil then
			self.read_card_player["time"..tostring(i)].timer_Elapse:Stop()
			self.read_card_player["time"..tostring(i)].timer_Elapse = nil
		end
	end
end

function shisanshui_ui:ReadCardStartTimer(state,viewSeat)
	if self.read_card_player["time"..tostring(viewSeat)] ~= nil and self.read_card_player["time"..tostring(viewSeat)].timer_Elapse ~= nil then
		self.read_card_player["time"..tostring(viewSeat)].timer_Elapse:Stop()
		self.read_card_player["time"..tostring(viewSeat)].timer_Elapse = nil
	end
	
	self.count = 0
	if state == true then
		self.read_card_player["time"..tostring(viewSeat)].timer_Elapse = Timer.New(
		function()
		--	logError("index："..tostring(self.count))
			local dotList = {}
			for i = 1 ,3 do
				local dotTran = child(self.read_card_player[tostring(viewSeat)].transform,"dot"..tostring(i))
				table.insert(dotList,dotTran)
			end
			if #dotList > 0 then
				for i,v in ipairs(dotList) do
					if self.count == 0 then
						v.gameObject:SetActive(false)
					else
						if i <= self.count then
							v.gameObject:SetActive(true)
						else
							v.gameObject:SetActive(false)
						end
					end
				end
			end
			self.count=self.count+1
		self.count=self.count%4
			
		end,0.5,-1)
		self.read_card_player["time"..tostring(viewSeat)].timer_Elapse:Start()
	end
end

function shisanshui_ui:SetBeiShuBtnCount()
	local roomData = roomdata_center.gamesetting
	for i = 1,5 do
		local child =  child( self.compTbl.xiapao,"pao"..tostring(i))
		if child ~= nil then
			if tonumber(i) <= tonumber(roomData["nSupportMaxMult"]) then
				child.gameObject:SetActive(true)
			else
				child.gameObject:SetActive(false)
			end
		end
	end
	local gridComp =  self.compTbl.xiapao.gameObject:GetComponent(typeof(UIGrid))
	if gridComp ~= nil then
		gridComp:Reposition()
	else
		Trace("===选择倍数UIGrid为空！===")
	end
end

--显示闲家倍数
function shisanshui_ui:SetBeiShu(viewSeat, beishu)
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetBeiShu(beishu)
	end 
end

--获取玩家头像坐标
function shisanshui_ui:GetAllShootPos(viewSeat)
	if self.playerList[viewSeat] ~= nil then
		local shooterPos = self.playerList[viewSeat].transform
		return shooterPos.localPosition
	end
end

function  shisanshui_ui:IsShowCountDownSlider(isShow)
	if isShow then
		self.countDownSlider:Show()
	else
		self.countDownSlider:Hide()
	end
end

function  shisanshui_ui:StopCountDownTimer()
	self.countDownSlider:StopCountDownTimer()
end

function  shisanshui_ui:SetCountDown(time,shakeTime,callback)
	self.countDownSlider:SetCountDown(time,shakeTime,callback)
end

function shisanshui_ui:SetPlaceCardCountDown(count)
	self:SetCountDown(count)
end

---结算自己准备了，其他人未准备倒计时时钟
function shisanshui_ui:SetReadyDisCountDowm(time)
	self.countDownSlider:SetCountDown(time)
end

return shisanshui_ui
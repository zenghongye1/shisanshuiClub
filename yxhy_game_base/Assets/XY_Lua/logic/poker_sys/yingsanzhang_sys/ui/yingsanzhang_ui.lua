require "logic/invite_sys/invite_sys"
require "logic/niuniu_sys/other/poker_table_coordinate"
local base = require("logic.poker_sys.common.poker_ui_base")
local yingsanzhang_ui = class("yingsanzhang_ui",base)

local yingsanzhang_player_ui = require("logic.poker_sys.yingsanzhang_sys.ui.yingsanzhang_player_ui")
local yingsanzhang_data_manage = require("logic.poker_sys.yingsanzhang_sys.cmd_manage.yingsanzhang_data_manage")
local before_starting_operation_view = require("logic.niuniu_sys.ui.sub_ui.before_starting_operation_view")



function yingsanzhang_ui:ctor()
	base.ctor(self)
	self.playerList = {}
	self.widgetTbl = {}
	self.compTbl = {}	
	self.bankerBtnList = {}
	self.special_card_type = {}
	self.read_card_player = {}
	self.poker_effect_mgr = require("logic.poker_sys.sangong_sys.other.poker_effect_mgr"):create()
	self.destroyType = UIDestroyType.Immediately
end

function yingsanzhang_ui:OnInit()
	base.OnInit(self)
	self:InitWidgets()
	
	msg_dispatch_mgr.SetIsEnterState(true)	
end

function yingsanzhang_ui:OnOpen()
	base.OnOpen(self)
	self:CreatePlayerList(7,yingsanzhang_player_ui)
	self:SetAllState(false)
	--self:ReSetReadCard()
end

--[[--
 * @Description: 获取各节点对象  
 ]]
function yingsanzhang_ui:InitWidgets()	

	self.widgetTbl.panel = child(self.gameObject.transform, "Panel")

	self.before_starting_operation_view = before_starting_operation_view:create(child(self.widgetTbl.panel, "Anchor_Center/readyBtns"),self)

		--理牌提示
	self.widgetTbl.readCardGroup = child(self.widgetTbl.panel,"Anchor_Center/read_card_group")
	if self.widgetTbl.readCardGroup~=nil then
		self.widgetTbl.readCardGroup.gameObject:SetActive(true)
		for i=1,6 do
			local tReadCard = child(self.widgetTbl.readCardGroup,"read_card"..i)
			self.read_card_player[tostring(i)] = tReadCard
			self.read_card_player["time"..tostring(i)]= {}
			tReadCard.gameObject:SetActive(false)
		end
	end
	
	self.OperationView_93 = require("logic.poker_sys.yingsanzhang_sys.ui.sub_ui.OperationView_93"):create(self.gameObject.transform)
	self.OperationView_93.BtnBiPaiOnClickDelegate = function()
		self:BtnBiPaiOnClick()
	end
	
	self.clickArea = child(self.widgetTbl.panel,"Anchor_Center/ClickArea")
	self.clickArea.gameObject:SetActive(false)
	local clickBg = child(self.widgetTbl.panel,"Anchor_Center/ClickArea/clickBg")
	addClickCallbackSelf(clickBg.gameObject,self.OnClickBg,self)
end

---比牌面板隐藏
function yingsanzhang_ui:OnClickBg()
	if self.clickArea.gameObject.activeSelf then
		self.clickArea.gameObject:SetActive(false)
		for i,v in pairs(self.playerList) do
			if v.viewSeat ~= 1 and not v.isOut then
				v:showBiPaiKuang(false)
			elseif v.viewSeat == 1 then	
				self:StopCountDownTimer()
				self:IsShowCountDownSlider(false)
			end
		end
	end
end


function yingsanzhang_ui:BtnBiPaiOnClick()
	self.clickArea.gameObject:SetActive(true)
	for i,v in pairs(self.playerList) do
		if v.viewSeat == 1 then	
			local timeEnd = v.timeEnd
			if timeEnd and timeEnd > 0 then
				self:SetCountDown(timeEnd)
			end
		else
			if not v.isOut then
				v:showBiPaiKuang(true)
			end
		end
	end
end

function yingsanzhang_ui:OnClose()
	base.OnClose(self)
	gps_data.ResetGpsData()
	self:ReSetReadCard()
	self:ResetAll()
	for _,v in pairs(self.playerList)do 
		v:Hide()
	end
	self.playerList = {}
	self:StopCountDownTimer()
end

function yingsanzhang_ui:AskAction(viewSeat,time)
	local actionTime = yingsanzhang_data_manage:GetInstance().roomInfo["TimerSetting"]["actionTimeOut"]
	for _,v in pairs(self.playerList) do 
		if v.viewSeat == viewSeat then
			v:SetTurnFrame(true,time,actionTime)
		else
			v:SetTurnFrame(false)
		end
	end
end

function yingsanzhang_ui:ResetTurnCount()
	for _,v in pairs(self.playerList) do
		v:SetTurnFrame(false)
	end
end

--单个人比牌（剩两人系统比牌时，数据封装后走这个）
function yingsanzhang_ui:playCompareEffect(tbl,callback)
	Trace("两人比牌-----------"..GetTblData(tbl))
	
	local amin1Pos = child(self.transform,"Aim1").position
	local amin2Pos = child(self.transform,"Aim2").position
	
	local function MoveToPos(userViewSeat,aimPos,callback)
		local headTran = self.playerList[userViewSeat].head
		local curPos = headTran.localPosition
		local user = self.playerList[userViewSeat]
		user:SetTurnFrame(false)
		headTran.transform:DOMove(aimPos,0.7,false):OnComplete(function()
			headTran.gameObject:SetActive(false)
			headTran.localPosition = curPos		
			if callback then
				callback()
			end
		end)
	end
	
	---设置胜利失败特效
	local function SetWinStateEffect(winParentTran,loseParentTran,isAskWin)
		local effectShengLi = EffectMgr.PlayEffect(data_center.GetResRootPath().."/effects/".."Effect_shengli",1)
		local effectShiBai = EffectMgr.PlayEffect(data_center.GetResRootPath().."/effects/".."Effect_shibai",1)	
		Utils.SetEffectSortLayer(effectShengLi.gameObject,self.sortingOrder + self.m_subPanelCount + 3)
		Utils.SetEffectSortLayer(effectShiBai.gameObject,self.sortingOrder + self.m_subPanelCount + 3)
		if isAskWin then
			effectShengLi.transform:SetParent(winParentTran.transform,false)
			effectShiBai.transform:SetParent(loseParentTran.transform,false)
		else
			effectShengLi.transform:SetParent(loseParentTran.transform,false)
			effectShiBai.transform:SetParent(winParentTran.transform,false)
		end
	end

	local whoAskViewSeat = player_seat_mgr.GetViewSeatByLogicSeatNum(tbl["_para"]["nAskChair"])
	local winViewSeat =  player_seat_mgr.GetViewSeatByLogicSeatNum(tbl["_para"]["nWinChair"])
	local loseViewSeat =  player_seat_mgr.GetViewSeatByLogicSeatNum(tbl["_para"]["nLooseChair"])
	local isGameDrawn = tbl["_para"]["isGameDrawn"] or false			--是否和局，系统比牌会出现和局，和局不显示胜利失败特效

	local leftUserViewSeat
	local rightUserViewSeat	
		if winViewSeat == whoAskViewSeat then
			leftUserViewSeat = winViewSeat
			rightUserViewSeat = loseViewSeat
		elseif loseViewSeat == whoAskViewSeat then
			leftUserViewSeat = loseViewSeat
			rightUserViewSeat = winViewSeat
		else
			logError("比牌error！")
			return
		end
		
	coroutine.start(function()
		MoveToPos(leftUserViewSeat,amin1Pos)
		MoveToPos(rightUserViewSeat,amin2Pos)
		coroutine.wait(0.5)
		local effectBiPai = EffectMgr.PlayEffect(data_center.GetResRootPath().."/effects/".."Effect_bipai",1,1.5)		
		Utils.SetEffectSortLayer(effectBiPai.gameObject,self.sortingOrder + self.m_subPanelCount + 1)
		local leftPlayerTran = child(effectBiPai.transform,"112/player")
		local rightPlayerTran = child(effectBiPai.transform,"113/player")
		local leftTex = subComponentGet(leftPlayerTran,"headTex","UITexture")	
		local rightTex = subComponentGet(rightPlayerTran,"headTex","UITexture")
		leftTex.gameObject:SetActive(false)
		rightTex.gameObject:SetActive(false)
		
		local leftFrame = child(effectBiPai.transform,"112/kuang57")
		local rightFrame = child(effectBiPai.transform,"113/kuang58")		
		if not isGameDrawn then
			SetWinStateEffect(leftFrame,rightFrame,leftUserViewSeat == winViewSeat)
		end
		effectBiPai.transform:SetParent(self.gameObject.transform,false)
		coroutine.wait(0.2)
		
		leftTex.gameObject:SetActive(true)
		HeadImageHelper.SetImage(leftTex,2,self.playerList[leftUserViewSeat]["userdata"]["headurl"])
		rightTex.gameObject:SetActive(true)
		HeadImageHelper.SetImage(rightTex,2,self.playerList[rightUserViewSeat]["userdata"]["headurl"])
		componentGet(leftPlayerTran.gameObject,"UIPanel").sortingOrder = self.sortingOrder + self.m_subPanelCount + 2
		componentGet(rightPlayerTran.gameObject,"UIPanel").sortingOrder = self.sortingOrder + self.m_subPanelCount + 2
		
		coroutine.wait(1.2)
		self.playerList[leftUserViewSeat].head.gameObject:SetActive(true)
		self.playerList[rightUserViewSeat].head.gameObject:SetActive(true)
		if callback then
			callback()
		end
	end)
end

---系统比牌
function yingsanzhang_ui:playAllCompareEffect(tbl)
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/dub/quanzhuobipai")
	local effectAllBiPai = EffectMgr.PlayEffect(data_center.GetResRootPath().."/effects/".."Effect_quanzhuobipai",1)
	Utils.SetEffectSortLayer(effectAllBiPai.gameObject,self.sortingOrder + self.m_subPanelCount + 1)
	effectAllBiPai.transform:SetParent(self.gameObject.transform,false)
end

--显示抢庄，不抢，搓牌中的状态
function  yingsanzhang_ui:SetState(viewSeat,isShow,str,tableObj)
	local position = nil
	if isShow == true then
		local playerList = tableObj.playerList
		for i,player in pairs(playerList) do
			if viewSeat == player.viewSeat then
				if str == niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_YIZHUNBEI and viewSeat == 1 then
					position = Vector3(0,-30,0)
					position = Vector3(position.x,position.y - 35,position.z)
				else
					position = Utils.WorldPosToScreenPos(player.gameObject.transform.position)
					if viewSeat == 1 then
					--	position = Vector3(position.x,position.y - 35,position.z)
					--如果是自己，不显示任何状态
						isShow = false
					else
						position = Vector3(position.x,position.y-15 ,position.z)
					end
				end
				break
			end
		end
	end
	self:SetReadCardByState(viewSeat,isShow,str,position)
end

function yingsanzhang_ui:SetReadCardByState(viewSeat,state,str,position)
	if state == true then
		if position ~= nil then
			self.read_card_player[tostring(viewSeat)].transform.localPosition = position
		end
		local obj = self.read_card_player[tostring(viewSeat)].gameObject
		obj:SetActive(true)
		local sprite = componentGet(child(obj.transform,"Sprite"),"UISprite")
		if sprite ~= nil then
			sprite.spriteName = str
			sprite:MakePixelPerfect()
		end
		if str == niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_QIANGZHUANGZHONG or str == niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_XIAZHUZHONG or str == niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_CUOPAIZHONG then
			self:ReadCardStartTimer(state,viewSeat)
		else
			self:ReadCardStartTimer(false,viewSeat)
		end
	else
		self.read_card_player[tostring(viewSeat)].gameObject:SetActive(false)
	end
end

function yingsanzhang_ui:ReSetReadCard(state)
	for i =1,6 do
		self.read_card_player[tostring(i)].gameObject:SetActive(state)
		if not state and self.read_card_player["time"..tostring(i)] ~= nil and self.read_card_player["time"..tostring(i)].timer_Elapse ~= nil then
			self.read_card_player["time"..tostring(i)].timer_Elapse:Stop()
			self.read_card_player["time"..tostring(i)].timer_Elapse = nil
		end
	end
end

function yingsanzhang_ui:ReadCardStartTimer(state,viewSeat)	
	if self.read_card_player["time"..tostring(viewSeat)] ~= nil and self.read_card_player["time"..tostring(viewSeat)].timer_Elapse ~= nil then
		self.read_card_player["time"..tostring(viewSeat)].timer_Elapse:Stop()
		self.read_card_player["time"..tostring(viewSeat)].timer_Elapse = nil
	end
	
	local index = 0
	local dotList = {}
	for i = 1 ,3 do
		local dotTran = child(self.read_card_player[tostring(viewSeat)].transform,"dot"..tostring(i))
		table.insert(dotList,dotTran)
	end
	if state == true then
		self.read_card_player["time"..tostring(viewSeat)].timer_Elapse = Timer.New(
		function()
			if #dotList > 0 then
				for i,v in ipairs(dotList) do
					if index == 0 then
						v.gameObject:SetActive(false)
					else
						if i <= index then
							v.gameObject:SetActive(true)
						else
							v.gameObject:SetActive(false)
						end
					end
				end
			end
		index = index + 1
		index = index%4
			
		end,0.5,-1)
		self.read_card_player["time"..tostring(viewSeat)].timer_Elapse:Start()
	else
		if #dotList > 0 then
			for i,v in ipairs(dotList) do
				v.gameObject:SetActive(false)
			end
		end
	end
end

function yingsanzhang_ui:ResetPlayerByViewSeate(viewSeat)
	self.playerList[viewSeat]:HideTotalPoints()
	self.playerList[viewSeat]:IsShowBetChip(false)
	self.playerList[viewSeat]:SetCardStateShow(false)
end

--设置赢家筹码飞动效果	endViewSeat:赢家位置，playerTotalCount：赢家总人数，playerIndex，对应的索引
function  yingsanzhang_ui:ChipFlyAnimation(endViewSeat,playerTotalCount,playerIndex)
	local endTrans = self.playerList[endViewSeat].transform
	self.OperationView_93:ChipFlyToWinViewSeat(endTrans,playerTotalCount,playerIndex)
end

--飞筹码效果
function yingsanzhang_ui:AddChip(viewSeat,coin)
	local playerTrans = self.playerList[viewSeat].transform
	self.OperationView_93:PlayChipAnimation(playerTrans,coin)
end

function  yingsanzhang_ui:SetAllState(isShow,str,tableObj)
	for i,v in pairs(self.playerList) do
		self:SetState(i,isShow,str,tableObj)
	end
end

--通用倒计时接口
function  yingsanzhang_ui:SetCountDown(time,shakeTime,callback)
	self.countDownSlider:SetCountDown(time,shakeTime,callback)
end

function  yingsanzhang_ui:StopCountDownTimer()
	self.countDownSlider:StopCountDownTimer()
end

function  yingsanzhang_ui:IsShowCountDownSlider(isShow)
	if isShow then
		self.countDownSlider:Show()
	else
		self.countDownSlider:Hide()
	end
end

--倒计时proc实现
function yingsanzhang_ui:CompareCountDown(time,totalTime)
	time = time or 100
	local totalTime = totalTime or time
	if self.compTbl.countDownTimeLabel ~= nil then 
		self.compTbl.countDownTimeLabel.text = tostring(time)
	end
end

function yingsanzhang_ui:ShowPlayerTotalPoints(viewSeat,totalPoint)
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetTotalPoints(totalPoint)
	end
end

function  yingsanzhang_ui:SetPlayerMachine(viewSeat, isMachine )
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetMachine(isMachine)
	end
end

function  yingsanzhang_ui:SetPlayerLineState(viewSeat, isOnLine )
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetOffline(not isOnLine)
	end
end

function  yingsanzhang_ui:SetHideTotaPoints()
	for i,v in pairs(self.playerList) do
		v.HideTotalPoints()
	end
end

function yingsanzhang_ui:SetPlayerScore(viewSeat,value)
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetScore(value)
	end
end

function yingsanzhang_ui:AddPlayerScore(viewSeat,value)
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:AddScore(value)
	end
end

function yingsanzhang_ui:SetPlayerReady( viewSeat,isReady )
	Trace("viewSeat-------------------------------------"..tostring(viewSeat))
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetReady(isReady)
	end
end

function yingsanzhang_ui:SetAllPlayerReady(isReady)
	for i,v in pairs(self.playerList) do
		v:SetReady(isReady)
	end
end

--设置胜利头像的光圈
function yingsanzhang_ui:SetPlayerLightFrame(viewSeat)
	local Player = self.playerList[viewSeat]
	if Player ~= nil then
		Trace("当前桌面对应的座位号"..tostring(Player.viewSeat).."transformName"..tostring(Player.transform.name))
		local effect = EffectMgr.PlayEffect(data_center.GetResPokerCommPath().."/effects/Effect_win",1,1)
		effect.transform:SetParent(child(Player.transform,"winFrame"),false)
		Utils.SetEffectSortLayer(effect.gameObject,self.sortingOrder + self.m_subPanelCount + 1)
		if Player.viewSeat == 1 then
			effect.transform.localScale = Vector3(1.35,1.35,1.35)
		else
			effect.transform.localScale = Vector3(1,1,1)
		end
	end
end

--播放游戏开始动画效果
function yingsanzhang_ui:PlayGameStartAnimation()
	local effect = EffectMgr.PlayEffect(data_center.GetResPokerCommPath().."/effects/Effect_youxikaishi",1,1)
	effect.transform:SetParent(self.gameObject.transform)
	Utils.SetEffectSortLayer(effect.gameObject,self.sortingOrder + self.m_subPanelCount + 1)
end


function yingsanzhang_ui:SetBanker(viewSeat)
	if self.playerList[viewSeat] then
		self.playerList[viewSeat]:SetBanker(true)
	end
end

function yingsanzhang_ui:HideAllBanker()
	for i,v in pairs(self.playerList) do
		if v.isBanker then
			v:SetBanker(false)
		end
	end
end

function yingsanzhang_ui:HideAllBeiShu()
	for _,v in pairs(self.playerList) do
		v:IsShowBetChip(false)
	end
end

function yingsanzhang_ui:ResetAll()
	base.ResetAll(self)
	for _,v in pairs(self.playerList) do			
		v:Reset()
		v:SetCardStateShow(false)
	end
	--self:ReSetReadCard()
	self.readyBtnsView:SetReadyBtnVisible(false)
	self.before_starting_operation_view:IsShowOpenCardBtn(false)
	self.before_starting_operation_view:IsShowCuoPaiBtn(false)
	self:StopCountDownTimer()
	self:HideDisMissCountDown()
	self:IsShowCountDownSlider(false)
	self:HideAllBanker()

end

--显示玩家下注筹码(ysz
function yingsanzhang_ui:SetBetChip(viewSeat,beishu)
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:IsShowBetChip(true,beishu)
	end 
end

return yingsanzhang_ui
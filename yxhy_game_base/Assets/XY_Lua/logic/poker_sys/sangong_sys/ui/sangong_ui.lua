require "logic/invite_sys/invite_sys"
require "logic/niuniu_sys/other/poker_table_coordinate"
local base = require("logic.poker_sys.common.poker_ui_base")
local sangong_ui = class("sangong_ui",base)

local sangong_player_ui = require("logic.poker_sys.sangong_sys.ui.sangong_player_ui")

function sangong_ui:ctor()
	base.ctor(self)
	self.playerList = {}
	self.widgetTbl = {}
	self.compTbl = {}	
	self.bankerBtnList = {}
	self.special_card_type = {}
	self.special_card_type_fengshu = {}
	self.special_card_anim = {}
	self.glodcoin = {}
	
	self.read_card_player = {}
	self.poker_effect_mgr = require("logic.poker_sys.sangong_sys.other.poker_effect_mgr"):create()
	self.destroyType = UIDestroyType.Immediately
end

function sangong_ui:OnInit()
	base.OnInit(self)
	self:InitWidgets()
	msg_dispatch_mgr.SetIsEnterState(true)	
end

function sangong_ui:OnOpen()
	base.OnOpen(self)
	self:CreatePlayerList(6,sangong_player_ui)
	--self:ReSetReadCard()
	self:SetMultipleRuleText()

	self.before_starting_operation_view.is_RubCard = require("logic.poker_sys.sangong_sys.cmd_manage.sangong_data_manage"):GetInstance().roomInfo.GameSetting.rubCard
end

--[[--
 * @Description: 获取各节点对象  
 ]]
function sangong_ui:InitWidgets()
	
	self.widgetTbl.panel = child(self.gameObject.transform, "Panel")

	---返回大厅按钮点击回调
	base.SetExitBtnCallback(self,slot(self.ExitClickCallback,self))

	self.before_starting_operation_view = require("logic.niuniu_sys.ui.sub_ui.before_starting_operation_view"):create(child(self.widgetTbl.panel, "Anchor_Center/readyBtns"),self)
	

	--提示按钮
	self.widgetTbl.btnTip = child(self.widgetTbl.panel,"Anchor_Center/readyBtns/tips")
	if self.widgetTbl.btnTip ~= nil then
		self.widgetTbl.btnTip.gameObject:SetActive(false)
	end
	
	--我要当庄按钮
	self.widgetTbl.btn_setBanker = child(self.widgetTbl.panel,"Anchor_Center/readyBtns/setbanker")
	if self.widgetTbl.btn_setBanker ~= nil then
		addClickCallbackSelf(self.widgetTbl.btn_setBanker.gameObject,self.Onbtn_setBankerOnClick,self)
		self.widgetTbl.btn_setBanker.gameObject:SetActive(false)
	end

	--特殊牌型图标
	self.widgetTbl.group = child(self.widgetTbl.panel,"Anchor_Center/special_card_type_group")
	self.widgetTbl.glodCoingroup = child(self.widgetTbl.panel,"Anchor_Center/glodcoin")
	if self.widgetTbl.group ~= nil then
		for i =1, 6 do
			local special_card_icon = child(self.widgetTbl.group,"special_card_type_"..i)
			self.special_card_type["special_card_type_"..tostring(i)] = special_card_icon
			self.special_card_type["special_card_type_"..tostring(i)].gameObject:SetActive(false)
			local fengshu = child(self.widgetTbl.group,"fengshu"..i)
			fengshu.gameObject:SetActive(false)
			table.insert(self.special_card_type_fengshu,fengshu)
			
			--找到飞金币的对象
			local coinsAnchor = child(self.widgetTbl.glodCoingroup,"coin"..i)
			local coins = {}
			for j = 1,6 do 
				local coinObj = child(coinsAnchor,"coin"..j)
				coinObj.gameObject:SetActive(false)
				table.insert(coins,coinObj)
			end
			local coinsData = {}
			coinsData.isPlaying = false
			coinsData.coins = coins
			table.insert(self.glodcoin,coinsData)
			
		end
	end
		
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
	
	self.widgetTbl.finish = child(self.widgetTbl.panel,"Anchor_Center/finish")
	if self.widgetTbl.finish ~= nil then
		--self.widgetTbl.finish.gameObject:SetActive(false)
	end
	
	self.widgetTbl.finishIcon = child(self.widgetTbl.panel,"Anchor_Center/finish/sprite")
	if self.widgetTbl.finishIcon ~= nil then
		self.widgetTbl.finishIcon.gameObject:SetActive(false)
		self.widgetTbl.finishIcon.gameObject.transform.localScale = Vector3(0.60,0.60,0.60)
	end
	
	self.widgetTbl.special_card_Anin = child(self.widgetTbl.panel,"Anchor_Center/special_card_Anim")
	if self.widgetTbl.special_card_Anin ~= nil then
		for i =1, 6 do
			local special_card_icons = child(self.widgetTbl.special_card_Anin,"special_card_type_"..i)
			self.special_card_anim["special_card_type_"..tostring(i)] = special_card_icons
			self.special_card_anim["special_card_type_"..tostring(i)].gameObject:SetActive(false)
		end
	end

	--水庄倒计时
	self.widgetTbl.xiaopao_timePanel = child(self.widgetTbl.panel,"Anchor_Center/xiaopao_time")
	if self.widgetTbl.xiaopao_timePanel~=nil then
		self.widgetTbl.xiaopao_timePanel.gameObject:SetActive(false)
	end
	self.widgetTbl.xiaopao_time= componentGet(child(self.widgetTbl.xiaopao_timePanel,"time"),"UILabel")

	self.multipleRuleLabel = componentGet(child(self.widgetTbl.panel,"Anchor_Bottom/multipleRule"),"UILabel")

	--下注分数
    self.compTbl.xiapao = child(self.widgetTbl.panel, "Anchor_Center/xiapao")
	if self.compTbl.xiapao~=nil then
		for i=1,5 do
			local btn_xiapao = child(self.compTbl.xiapao,tostring(i))
			addClickCallbackSelf(btn_xiapao.gameObject,

			function ()
				ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
				local OnAskMultData = require("logic.poker_sys.sangong_sys.cmd_manage.sangong_data_manage"):GetInstance().OnAskMultData
				local score = OnAskMultData._para.optional
				pokerPlaySysHelper.GetCurPlaySys().beishu(score[i])
				self:SetXiaoPao(0)
			--	self.IsShowBeiShuiBtn(false)
				self:SetXiaoPaoLabelByStr("请等待其他玩家下注...")
			end,
			self)
		end
       self.compTbl.xiapao.gameObject:SetActive(false)
    end
	
		--抢庄
	self.compTbl.banker = child(self.widgetTbl.panel,"Anchor_Center/banker")
	for i = 0,5 do
		local btn_banker = child(self.compTbl.banker,tostring(i))
		--如果是自由抢庄，只有抢跟不抢两个按钮
		addClickCallbackSelf(btn_banker.gameObject,function()
			ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
			local AskRobbanker = require("logic.poker_sys.sangong_sys.cmd_manage.sangong_data_manage"):GetInstance().AskRobbankerData
			
			pokerPlaySysHelper.GetCurPlaySys().robbankerReq(AskRobbanker._para.optional[i + 1])
		--	self.compTbl.banker.gameObject:SetActive(false)
			--这里得添加代码显示"请等待其他玩家抢庄"
			
			self:SetXiaoPaoLabelByStr("请等待其他玩家抢庄...")
			
		end,self)
		table.insert(self.bankerBtnList,btn_banker)
	end
	self.compTbl.banker.gameObject:SetActive(false)

end

function sangong_ui:ExitClickCallback()
	--如果是固定庄家模式，并且是庄家，则退出时要清桌，其他模式不清桌，自己退出
	local configData = require("logic.poker_sys.sangong_sys.cmd_manage.sangong_data_manage"):GetInstance().roomInfo
	local isBanker = require("logic.poker_sys.sangong_sys.cmd_manage.sangong_data_manage"):GetInstance():IsBanker()
	local takeTurnsMode = configData.GameSetting.takeTurnsMode
	if takeTurnsMode == sangong_rule_define.SUB_BULL_BANKER.SUB_BULL_BANKER_FIXED then
		if isBanker then
			MessageBox.ShowYesNoBox("你是庄家，离开后会解散牌桌，是否离开？", function() pokerPlaySysHelper.GetCurPlaySys().LeaveReq() end)
			return
		end
	end
	MessageBox.ShowYesNoBox(LanguageMgr.GetWord(5001), function() pokerPlaySysHelper.GetCurPlaySys().LeaveReq() end)
end


function sangong_ui:SetMultipleRuleText()
	local configData = require("logic.poker_sys.sangong_sys.cmd_manage.sangong_data_manage"):GetInstance().roomInfo
	local multipleRule = configData.GameSetting.multipleRule
	local count = #multipleRule
	local str = ""
	for i = count,1,-1 do
		if multipleRule[i] > 1 then
			str = str..sangong_rule_define.PT_SANGONG_Text[i].."X"..tostring(multipleRule[i]).." "
		end
	end
	self.multipleRuleLabel.text = str
end

--发送开牌消息
function sangong_ui:onbtn_openCardClick()
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音

	local tableComponent =require("logic.poker_sys.sangong_sys.cmd_manage.sangong_msg_manage"):GetInstance():GetSceneControllerInstance().tableComponent
	tableComponent:OpenLastCard()	
	pokerPlaySysHelper.GetCurPlaySys().OpenCardReq()
end

--打开搓牌界面
function sangong_ui:OnBtnCuoPaiOnClick(go)
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
	local cards = require("logic.poker_sys.sangong_sys.cmd_manage.sangong_data_manage"):GetInstance().DealData._para.stCards
	local sceneControl = require ("logic.poker_sys.sangong_sys.cmd_manage.sangong_msg_manage"):GetInstance():GetSceneControllerInstance()
	UI_Manager:Instance():ShowUiForms("cuopai_ui",nil,nil,cards,sceneControl)
end

--我要当庄
function sangong_ui:Onbtn_setBankerOnClick()
 	MessageBox.ShowYesNoBox("成为庄家后不可提前离场，是否确认成为庄家", 
 		function() 
 			pokerPlaySysHelper.GetCurPlaySys().ChooseBankerReq()
			self:IsShowBankerList(false) 
		end)
end

function sangong_ui:OnClose()
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

--是否显示我要选庄按钮
function  sangong_ui:IsShowChooseBanker(isShow)
	self.widgetTbl.btn_setBanker.gameObject:SetActive(isShow)
end

function  sangong_ui:IsShowBankerList(isShow)
	self.compTbl.banker.gameObject:SetActive(isShow)
end

--设置自由抢庄，明牌抢庄的按钮
function  sangong_ui:SetBankerBtnByMode(mode,data)
	self:IsShowBankerList(true)
	for i,v in ipairs(self.bankerBtnList) do
		v.gameObject:SetActive(false)
	end
	--自由抢庄只显示抢与不抢两个按钮
	for i,v in ipairs(data._para.optional) do
		local btn = self.bankerBtnList[i]
		btn.gameObject:SetActive(true)
		local label = child(btn.gameObject.transform,"UILabel")
		local labelcomp = componentGet(label.gameObject.transform,"UILabel")
		if v == 0 then
			labelcomp.text = "不抢"
		elseif v == 1 then
			labelcomp.text = "抢庄"
		end
		Trace("SetBankerBtnByMode:"..tostring(labelcomp.text))
	end
	local gridComp =  self.compTbl.banker.gameObject:GetComponent(typeof(UIGrid))
	if gridComp ~= nil then
		gridComp:Reposition()
	else
		Trace("===选择倍数UIGrid为空！===")
	end
	--显示时间倒计时
	self:SetCountDown(data.timeo - data.time,5,callback)	
end

function  sangong_ui:IsShowCountDownSlider(isShow)
	if isShow then
		self.countDownSlider:Show()
	else
		self.countDownSlider:Hide()
end
		end

--显示抢庄，不抢，搓牌中的状态
function  sangong_ui:SetState(viewSeat,isShow,str,tableObj)
	local position = nil
	if isShow == true then
		local playerList = tableObj.playerList
		for i,player in ipairs(playerList) do
			if viewSeat == player.viewSeat then
				if str == sangong_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_YIZHUNBEI and viewSeat == 1 then
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

function sangong_ui:SetReadCardByState(viewSeat,state,str,position)
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
		if str == sangong_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_QIANGZHUANGZHONG or str == sangong_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_XIAZHUZHONG or str == sangong_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_CUOPAIZHONG then
			self:ReadCardStartTimer(state,viewSeat)
		else
			self:ReadCardStartTimer(false,viewSeat)
		end
	else
		self.read_card_player[tostring(viewSeat)].gameObject:SetActive(false)
	end
end

function sangong_ui:ReSetReadCard(state)
	for i =1,6 do
		self.read_card_player[tostring(i)].gameObject:SetActive(state)
		if not state and self.read_card_player["time"..tostring(i)] ~= nil and self.read_card_player["time"..tostring(i)].timer_Elapse ~= nil then
			self.read_card_player["time"..tostring(i)].timer_Elapse:Stop()
			self.read_card_player["time"..tostring(i)].timer_Elapse = nil
		end
	end
end

function sangong_ui:ReadCardStartTimer(state,viewSeat)	
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
		--	logError("index："..tostring(self.count))
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

--显示下注中，庄家不显示下注中
function  sangong_ui:SetXiaZhuZhong(bankViewSeat,tableObj)
	if(bankViewSeat ~= nil) then
		for i,v in pairs(self.playerList) do
			if i == bankViewSeat then
				self:SetState(i,false)
			else
				self:SetState(i,true,sangong_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_XIAZHUZHONG,tableObj)
			end
		end	
	end
end

--重连刷新显示下注中，庄家不显示下注中
function  sangong_ui:RefreshXiaZhuZhong(bankViewSeat,multState,tableObj)
	if(bankViewSeat ~= nil and multState ~= nil) then
		for i,v in pairs(self.playerList) do
			local logicLogicSeat = player_seat_mgr.GetLogicSeatNumByViewSeat(i)
			if multState[logicLogicSeat] > 0 then
			--	self.playerList[i]:SetState(false)
				self:SetState(i,false)
				if i == 1 then
					self:SetXiaoPaoLabelByStr("请等待其他玩家下注...")		--自己已下注 显示文本
				end
			else
				if i == bankViewSeat then
					self:SetState(i,false)
					if i == 1 and bankViewSeat ~= 1 then
						self:IsShowBeiShuiBtn(true)
					end
				else
					self:SetState(i,true,sangong_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_XIAZHUZHONG,tableObj)
				end
			end
		end	
		multState = nil
	end
end

--设置赢家金币飞动效果
function  sangong_ui:glodCoinFlyAnimation(startViewSeate, endViewSeate)
	local coins = nil
	for i,v in ipairs(self.glodcoin) do
		if v.isPlaying == false then
			v.isPlaying = true
			coins = v.coins
			break
		end
	end
	if coins ~= nil then
		coroutine.start(function()
			for i,v in pairs(coins) do
				local startTrans = self.playerList[startViewSeate].transform
				local endTrans = self.playerList[endViewSeate].transform
				v.gameObject.transform.position = startTrans.position
				v.gameObject:SetActive(true)
				v.gameObject.transform:DOMove(endTrans.position,0.4,false)
				Trace("金币飞动")
				coroutine.wait(0.05)
			end
		end)
	else
		logError("金币对象为空")
	end
end

function  sangong_ui:ReSetAllGoldCoinAnimationState()
	for i,v in ipairs(self.glodcoin) do
		v.isPlaying = false
		for j,k in pairs(v.coins) do
			k.gameObject:SetActive(false)
		end
	end
end

function  sangong_ui:SetAllState(isShow,str,tableObj)
	for i,v in pairs(self.playerList) do
		self:SetState(i,isShow,str,tableObj)
	end
end

--设置水庄倒计时
function  sangong_ui:SetXiaoPao(time,callback)
	if time==nil or time<=0 then
		self:ShowXiaoPaoPanel(false)
		self:IsShowCountDownSlider(false)
	else
		self:SetCountDown(time,5,callback)
	end	
end

function  sangong_ui:SetAskPoenCard(time,callback)

	if time==nil or time<=0 then
		self:ShowXiaoPaoPanel(false)
		self:IsShowCountDownSlider(false)
	else
		self:SetCountDown(time,5,callback)
				end
				end

function  sangong_ui:StopCountDownTimer()
	self.countDownSlider:StopCountDownTimer()
end

---设置自己已经操作,用于倒计时标志
function sangong_ui:SetSelfDone(state)
	self.countDownSlider:SetSelfDone(state)
end

function  sangong_ui:SetXiaoPaoLabelByStr(str)
	if  self.widgetTbl and self.widgetTbl.xiaopao_time ~= nil then
		self:ShowXiaoPaoPanel(true)
		self.widgetTbl.xiaopao_time.text = str
	end
end

function  sangong_ui:ShowXiaoPaoPanel(state,str)
	self.widgetTbl.xiaopao_timePanel.gameObject:SetActive(state)
	self.widgetTbl.xiaopao_time.text = str
end

--通用倒计时接口
function  sangong_ui:SetCountDown(time,shakeTime,callback)
	self.countDownSlider:SetCountDown(time,shakeTime,callback)
end

function sangong_ui:ShowPlayerTotalPoints(viewSeat,totalPoint)
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetTotalPoints(totalPoint)
	end
end

function  sangong_ui:IsShowBeiShuiBtn(isShow)
	self.compTbl.xiapao.gameObject:SetActive(isShow)
	if isShow then
		local grid = componentGet(self.compTbl.xiapao.transform,"UIGrid")
		if grid ~= nil then
			grid:Reposition()
		end
	end
end

--是否显示抢庄按钮
function  sangong_ui:IsShowBankerBtn (isShow)
	self.compTbl.banker.gameObject:SetActive(isShow)
end

function  sangong_ui:SetTiposition(IsShow,posititon)
	if PlayerPrefs.HasKey("NiuNiuTips")   then
	   if PlayerPrefs.GetInt("NiuNiuTips") > 3 then
			self.widgetTbl.btnTip.gameObject:SetActive(false)
			return
		else
			local count = PlayerPrefs.GetInt("NiuNiuTips")
			if IsShow == true then
				PlayerPrefs.SetInt("NiuNiuTips",count + 1)
			end
		end
	else
		PlayerPrefs.SetInt("NiuNiuTips", 1)
	end
	self.widgetTbl.btnTip.gameObject:SetActive(false)
	if posititon ~= nil then
		self.widgetTbl.btnTip.gameObject.transform.localPosition = posititon
	end
end

function  sangong_ui:SetPlayerMachine(viewSeat, isMachine )
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetMachine(isMachine)
	end
end

function  sangong_ui:SetPlayerLineState(viewSeat, isOnLine )
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetOffline(not isOnLine)
	end
end

function  sangong_ui:SetHideTotaPoints()
	for i,v in pairs(self.playerList) do
		v.HideTotalPoints()
	end
end

function sangong_ui:SetPlayerScore(viewSeat,value)
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetScore(value)
	end
end

function sangong_ui:AddPlayerScore(viewSeat,value)
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:AddScore(value)
	end
end

function sangong_ui:SetPlayerReady( viewSeat,isReady )
	Trace("viewSeat-------------------------------------"..tostring(viewSeat))
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetReady(isReady)
	end
end

function sangong_ui:SetAllPlayerReady(isReady)
	for i,v in pairs(self.playerList) do
		v:SetReady(isReady)
	end
end

function sangong_ui:SetPlayBianKuang(viewSeatArray,bankerViewSeate,IsShow,callback)
	coroutine.start(function()
		if #viewSeatArray == 1 then
			self:SetBanker(viewSeatArray[1])
		else
			local time = 0.16
			for i = 1,3 do
				for j,v in ipairs(viewSeatArray) do
					self.playerList[v]:SetBianKuang(IsShow)
					coroutine.wait(time)
					self.playerList[v]:SetBianKuang(not IsShow)
				end
				if i == 1 then
					time = time - 0.07
				elseif i == 2 then
					time = time - 0.05
				end
			end
			self:SetBanker(bankerViewSeate)
		end
		if callback ~= nil then
			callback()
		end
	end)
end

--设置头像的光圈
function sangong_ui:SetPlayerLightFrame(viewSeat)
	local Player = self.playerList[viewSeat]
	if Player ~= nil then
		Trace("当前桌面对应的座位号"..tostring(Player.viewSeat).."transformName"..tostring(Player.transform.name))
		local effect = EffectMgr.PlayEffect(data_center.GetResPokerCommPath().."/effects/Effect_win",1,1)
		effect.transform:SetParent(child(Player.transform,"winFrame"),false)
		Utils.SetEffectSortLayer(effect.gameObject,self.sortingOrder + self.m_subPanelCount + 1)
	end
end

--播放游戏开始动画效果
function sangong_ui:PlayGameStartAnimation()
	local effect = EffectMgr.PlayEffect(data_center.GetResPokerCommPath().."/effects/Effect_youxikaishi",1,1)
	effect.transform:SetParent(self.gameObject.transform,false)
	Utils.SetEffectSortLayer(effect.gameObject,self.sortingOrder + self.m_subPanelCount + 1)
end

--通杀动画效果
function sangong_ui:PlayTongShaAnimation()
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/cardtype_audio/tongsha")
	local effect = EffectMgr.PlayEffect(data_center.GetResPokerCommPath().."/effects/Effect_tongsa",1,1)
	effect.transform:SetParent(self.gameObject.transform,false)
	Utils.SetEffectSortLayer(effect.gameObject,self.sortingOrder + self.m_subPanelCount + 1)
	--animations_sys.PlayAnimation(self.gameObject.transform,data_center.GetResRootPath().."/effects/tongsha","tongsha",100,100,false,nil,4000)
end


function sangong_ui:SetBanker( viewSeat )
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetBanker(true)
	end
end

function sangong_ui:HideAllBanker()
	for i,v in pairs(self.playerList) do
		v:SetBanker(false)
	end
end

function sangong_ui:HideAllBeiShu()
	for _,v in pairs(self.playerList) do
		v:HideBeiShu()
	end
end

function sangong_ui:ResetAll()
	base.ResetAll(self)
	for _,v in pairs(self.playerList) do		
		v:HideTotalPoints()
		v:HideBeiShu()
	end
	--self:ReSetReadCard()
	self.readyBtnsView:SetReadyBtnVisible(false)
	self:HideSpecialCardIcon()
	self:HideSpecialCardAnim()
	self.before_starting_operation_view:IsShowOpenCardBtn(false)
	self.before_starting_operation_view:IsShowCuoPaiBtn(false)
	self:SetTiposition(false)
	self:ShowXiaoPaoPanel(false)
	self:IsShowBeiShuiBtn(false)
	self:StopCountDownTimer()
	self:HideDisMissCountDown()
	self:IsShowBankerList(false)
	self:IsShowChooseBanker(false)
	self:IsShowCountDownSlider(false)
	self:SetSelfDone(false)
	self:StopShakeTimer()
	self.widgetTbl.finish.gameObject:SetActive(false)
	self:ReSetAllGoldCoinAnimationState()	
	local configData = require("logic.poker_sys.sangong_sys.cmd_manage.sangong_data_manage"):GetInstance().roomInfo
	local takeTurnsMode = configData.GameSetting.takeTurnsMode
	if takeTurnsMode ~= sangong_rule_define.SUB_BULL_BANKER.SUB_BULL_BANKER_FIXED then
		self:HideAllBanker()
	end
end

function sangong_ui:ResetPlayerByViewSeate(viewSeat)
		self.special_card_type["special_card_type_"..viewSeat].gameObject:SetActive(false)
		self.special_card_type_fengshu[viewSeat].gameObject:SetActive(false)
		self.playerList[viewSeat]:HideTotalPoints()
		self.playerList[viewSeat]:HideBeiShu()
		
		local animObj = self.special_card_anim["special_card_type_"..viewSeat]
		local components = animObj.transform:GetComponentsInChildren(typeof(UnityEngine.Animator))
		if components ~= nil then
		--	for i,v in ipairs(components) do
			for i = 0, components.Length - 1,1 do
				local v = components[i]
				EffectMgr.StopEffect(v.transform.gameObject)
			end
		end
end

function sangong_ui:ShowSpecialCardAnimation(tbl)
	Trace("!!!!!!!!!!!!!!!!!!播特殊牌型动画"..GetTblData(tbl))
	local iconImage = self.special_card_anim["special_card_type_"..tbl.viewSeat]
	local Image = self.special_card_type["special_card_type_"..tbl.viewSeat]
	Image.gameObject:SetActive(false)
	iconImage.gameObject.transform.localPosition = tbl.position
	iconImage.gameObject:SetActive(true)
	local aminationName = "niu_"..tostring(tbl.nCardType).."_"..tostring(tbl.nBeishu)
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/cardtype_audio/"..tostring(sangong_rule_define.PT_SANGONG_SOUND[tbl.nCardType]))  ---按键声音
	local scale = 1.2
	if tbl.viewSeat == 1 then
		iconImage.gameObject.transform.localPosition = Vector3(tbl.position.x  ,tbl.position.y - 23,tbl.position.z)	
		self.poker_effect_mgr:playSanGongEffect(iconImage.gameObject.transform,tbl,scale)
	else
		scale = 0.6
		iconImage.gameObject.transform.localPosition = Vector3(tbl.position.x - 20  ,tbl.position.y + 10,tbl.position.z)
		self.poker_effect_mgr:playSanGongEffect(iconImage.gameObject.transform,tbl,scale)
	end
end

function sangong_ui:HideSpecialCardIcon()
	for i =1 , 6 do
		self.special_card_type["special_card_type_"..i].gameObject:SetActive(false)
		self.special_card_type_fengshu[i].gameObject:SetActive(false)
	end
end

function sangong_ui:HideSpecialCardAnim()
	for i =1 , 6 do
		self.special_card_anim["special_card_type_"..i].gameObject:SetActive(false)
	end
	self.poker_effect_mgr:stopEffects()
end

function sangong_ui:SetBeiShuBtnCount()
	local OnAskMultData = require("logic.poker_sys.sangong_sys.cmd_manage.sangong_data_manage"):GetInstance().OnAskMultData
	for i = 1,5 do
		local childs =  child( self.compTbl.xiapao,tostring(i))
		if childs ~= nil then
			if tonumber(i) <= #OnAskMultData._para.optional then
				childs.gameObject:SetActive(true)
				local label = componentGet(child(childs.gameObject.transform,"UILabel"),"UILabel")
				label.text = tostring(OnAskMultData._para.optional[i]).."分"
				
			else
				childs.gameObject:SetActive(false)
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
function sangong_ui:SetBeiShu(viewSeat, beishu,scoreType)
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetBeiShu(beishu,scoreType)
	end 
end

--设置庄家开牌完成标志
function sangong_ui:SetFinishState(isFinsh,position)
	
	self.widgetTbl.finish.gameObject:SetActive(isFinsh)
	if position ~= nil then
	--	self.widgetTbl.finish.gameObject.transform.localPosition = Vector3.New(position.x -40,position.y - 35,position.z)
		self.widgetTbl.finish.gameObject.transform.localPosition = Vector3.New(position.x -35 ,position.y - 65,position.z)
	end
	if isFinsh == true then
		--coroutine.start(function() 
		local scale = 0.6
		
		local dataTbl = {}
		dataTbl.nCardType = 16
		dataTbl.nBeishu = 0
		self.poker_effect_mgr:playSanGongEffect(self.widgetTbl.finish.transform,dataTbl,scale)
	else
		self.widgetTbl.finishIcon.gameObject:SetActive(false)
	end
end

return sangong_ui
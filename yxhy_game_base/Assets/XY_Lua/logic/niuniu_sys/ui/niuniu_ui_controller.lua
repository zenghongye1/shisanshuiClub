--[[--
 * @Description: 牛牛UI 控制层
 * @Author:      xuemin.lin
 * @FileName:    niuniu_ui_controller.lua
 * @DateTime:    2017-10-12
 ]]


require "logic/gameplay/cmd_shisanshui"
require "logic/mahjong_sys/_model/room_usersdata_center"
require "logic/mahjong_sys/_model/room_usersdata"
require "logic/mahjong_sys/_model/operatorcachedata"
require "logic/mahjong_sys/_model/operatordata"

local base = require("logic.poker_sys.common.poker_ui_controller_base")
local niuniu_ui_controller = class("niuniu_ui_controller",base)


function niuniu_ui_controller:ctor()
	base.ctor(self)
	self.gvbl = player_seat_mgr.GetViewSeatByLogicSeat
	self.gvbln = player_seat_mgr.GetViewSeatByLogicSeatNum
	self.gmls = player_seat_mgr.GetMyLogicSeat
	self.isReconnect = false
	self.result_para_data = {}
	self.tableComponent = nil
	self.isFirstJu = true
end

function niuniu_ui_controller:InitDataAndUIMgr()
	self.data_manage = require("logic.niuniu_sys.cmd_manage.niuniu_data_manage"):GetInstance()
	self.ui = UI_Manager:Instance():GetUiFormsInShowList("niuniu_ui")
end

function niuniu_ui_controller:InitTableComponent()
	if self.tableComponent == nil then
		self.tableComponent = require("logic.niuniu_sys.cmd_manage.niuniu_msg_manage"):GetInstance():GetNiuNiuSceneControllerInstance().tableComponent
	end
end

function niuniu_ui_controller:OnAskChooseBanker()
	local tbl = self.data_manage.AskChooseBanker
	Trace("固定庄家:"..GetTblData(tbl))
	self.ui:IsShowChooseBanker(true)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_niuniu.ASK_CHOOSEBANKER)
end

function niuniu_ui_controller:OnBanker()
	Trace("定庄完成")
	self.ui:IsShowChooseBanker(false)
	self.ui:IsShowBankerList(false)--隐藏抢庄按钮
	local OnBankData = self.data_manage.BankerData
	local viewSeat = self.gvbln(OnBankData._para.banker)
	local dice = OnBankData._para.dice
	--停止抢庄的倒计时,并隐藏倒计时按钮
	self.ui:StopCountDownTimer()
	self.ui:IsShowCountDownSlider(false)
	self.ui:ShowXiaoPaoPanel(false)
	--隐藏头顶所有状态显示
	self.ui:SetAllState(false)
	local mode = self.data_manage.roomInfo.GameSetting.takeTurnsMode
	if mode ~= niuniu_rule_define.SUB_BULL_BANKER.SUB_BULL_BANKER_FIXED then
		local diceViewSeat = {}
		if dice ~= nil and #dice > 0 then
			for i,v in ipairs(dice) do
				local vs = self.gvbln(v)
				table.insert(diceViewSeat,vs)
			end
		end
		
		self.ui:SetPlayBianKuang(diceViewSeat,viewSeat,true,function()			
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_BANKER)
			return
		end)
	else
		self.ui:SetBanker(viewSeat)
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_BANKER)
	end
end

--提示抢庄(自由抢庄模式，明牌抢庄模式)
function niuniu_ui_controller:OnAskRobbanker()
	Trace("提示抢庄")
	local mode = self.data_manage.roomInfo.GameSetting.takeTurnsMode
	local tbl = self.data_manage.AskRobbankerData
	self.ui:SetBankerBtnByMode(mode,tbl)
	--显示抢庄中
	self.ui:SetAllState(true,niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_QIANGZHUANGZHONG,self.tableComponent)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmd_niuniu.ASK_ROBBANKER )
end

--抢庄倍数通知
function niuniu_ui_controller:OnRobbanker(tbl)
	Trace("抢庄倍数通知")
	--显示抢与不抢
	local robbankerData = self.data_manage.OnRobbankerData
	local viewSeat =self.gvbln(robbankerData._para._chair)
	 --0表示不抢 >0表示抢
	local state = robbankerData._para.nBeishu
	if state == 0 then
		self.ui:SetState(viewSeat,true,niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_BUQIANGZHUAN,self.tableComponent)
	else
		self.ui:SetState(viewSeat,false,niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_QIANGZHUANG,self.tableComponent)
		self.ui:SetBeiShu(viewSeat,state,"倍")
	end
	if viewSeat == 1 then
		self.ui:SetSelfDone(true)
		self.ui:IsShowBankerList(false)
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_niuniu.ROBBANKER)
end

function niuniu_ui_controller:OnGameStart()	
	base.OnGameStart(self,self.data_manage.GameStartData)
	local subRound = self.data_manage.GameStartData._para.subRound
	roomdata_center.SetSubRoundNum(subRound)
	self.ui:SetGameNum(subRound)
	self.ui:SetAllState(false)
	self.ui.readyBtnsView:SetInviteBtnVisible(false)
	self.ui.readyBtnsView:SetCloseBtnVisible(false)
	self.ui:HideDisMissCountDown()
	self.ui:HideReadyDisCountDowm()
	self.ui:SetXiaoPao(0)
	--roomdata_center.isStart = true
	ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/duijukaishi")
	--播放发牌，洗牌动画 do something
	coroutine.start(function()
		self.ui:PlayGameStartAnimation()
		coroutine.wait(0.8)
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAMESTART)
	end)
end


--提示亮牌
function niuniu_ui_controller:OnAskOpenCard()
	Trace("提示亮牌")
	local tbl = self.data_manage.OnAskOpenCardData 
	if self.isReconnect == false then
		self.ui:SetAllState(true,niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_CUOPAIZHONG,self.tableComponent)
	end
	self.ui.before_starting_operation_view:IsShowCuoPaiBtn(true)
	self.ui.before_starting_operation_view:IsShowOpenCardBtn(true)
	local timeo = tbl.timeo - tbl.time
	self.ui:SetAskPoenCard(timeo,function()
		self.ui:StopCountDownTimer()
		self.ui:IsShowCountDownSlider(false)
		self.ui:ShowXiaoPaoPanel(false)
	end)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_niuniu.ASK_OPENCARD)
end

--某人已经亮牌
function niuniu_ui_controller:OnOpenCard(tbl)
	Trace("某人已经亮牌")
	local tbl = self.data_manage.OnOpenCardData
	local viewSeat = self.gvbl(tbl._src)
	self.ui:SetState(viewSeat,false,"",self.tableComponent)
	if viewSeat == 1 then
		self.ui:SetSelfDone(true)
		self.ui.before_starting_operation_view:IsShowOpenCardBtn(false)
	end
	
end

function niuniu_ui_controller:OnCompareResult()
	self.ui:StopCountDownTimer()
	self.ui:SetAskPoenCard(0)
	self.ui.before_starting_operation_view:IsShowOpenCardBtn(false)
	self.ui.before_starting_operation_view:IsShowCuoPaiBtn(false)
	self.ui:SetFinishState(false)
	self.ui:SetTiposition(false)
	self.ui:SetAllState(false)
end

 function niuniu_ui_controller:OnCompareStart(tbl)
	self.ui.readyBtnsView:SetInviteBtnVisible(false)
	self.ui.readyBtnsView:SetCloseBtnVisible(false)
	self.ui:ReSetReadCard(false)

	coroutine.start(function ()
		 --播放比牌动画
   		self.ui:PlayerStartGameAnimation()
    	Trace("开始播放比牌动画")
    	coroutine.wait(1)
   		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.COMPARE_START)
	end)
end

 function niuniu_ui_controller:OnGameDeal( tbl )
	self.ui:IsShowBeiShuiBtn(false)
	self.isReconnect = false
end


function niuniu_ui_controller:OnGameEnd()
	self.ui:SetAllState(false)
end

 function niuniu_ui_controller:OnGameRewards()
	
	local rewardData = self.data_manage.SmallRewardData
	local rewards = rewardData._para.rewards
	local banker = self.gvbln(rewardData._para.banker)
	coroutine.start(function()		
		for i,v in ipairs(rewards) do
			local viewSeat = self.gvbl(v._chair)
			if v.all_score < 0 then
				local viewSeat = self.gvbl(v._chair)
				if viewSeat ~= banker then
					self.ui:SetPlayerLightFrame(1)
					self.ui:glodCoinFlyAnimation(viewSeat,banker)
					if v.all_score == nil then v.all_score = 0 end
					self.ui:ShowPlayerTotalPoints(viewSeat, tonumber(v.all_score))
				else
					self.ui:ShowPlayerTotalPoints(viewSeat, tonumber(v.all_score))
				end
			end
		end
		coroutine.wait(0.5)
		self.ui:ReSetAllGoldCoinAnimationState()
		for i,v in ipairs(rewards) do
			if v.all_score > 0 then
				local viewSeat = self.gvbl(v._chair)
				if viewSeat ~= banker then
					local score = v.all_score
					if score == nil then score = 0 end
					self.ui:ShowPlayerTotalPoints(viewSeat, tonumber(score))
					self.ui:SetPlayerLightFrame(viewSeat)
					self.ui:glodCoinFlyAnimation(banker,viewSeat)
					if v.all_score == nil then v.all_score = 0 end
					self.ui:ShowPlayerTotalPoints(viewSeat, tonumber(v.all_score))
				else
					self.ui:ShowPlayerTotalPoints(viewSeat, tonumber(v.all_score))
				end
			end
		end
		coroutine.wait(1)
		self.ui:ReSetAllGoldCoinAnimationState()
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SMALL_SETTLEMENT) --确认完成结算完成消息
	end)
end

--牛牛大结算处理
 function niuniu_ui_controller:ShowLargeResult(tbl)
	if roomdata_center.midJoinData:CheckPlayerIsMidJoin(1) then
		pokerPlaySysHelper.GetCurPlaySys().LeaveReq()
		return
	end
	if (tbl ~= nil ) then
		local niuniu_largeResult_data = require("logic/niuniu_sys/large_result/niuniu_largeResult_data"):create(tbl._para)
		UI_Manager:Instance():ShowUiForms("poker_largeResult_ui",UiCloseType.UiCloseType_CloseNothing,function() 
			Trace("Close poker_largeResult_ui")
		end,niuniu_largeResult_data)
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmdName.GAME_SOCKET_BIG_SETTLEMENT)
end

 function niuniu_ui_controller:OnAskReady()
	tbl = self.data_manage.AskReadyData
	local timeo = tbl.timeo
	local timeEnd = timeo
	Trace("等待举手, 时间："..tostring(timeo).."  结束时间： "..tostring(timeEnd))

	if(timeEnd ~= -1 and timeEnd > 0) then 
		self.ui:SetDisMissCountDown(timeEnd)
	end

	self.ui.readyBtnsView:SetReadyBtnVisible(true)
	--如果断线重连回来，没有比牌结果，会导致这个按钮没有清除，所以得在这里清一下。
	self.ui.before_starting_operation_view:IsShowCuoPaiBtn(false)
	self.ui:SetFinishState(false)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_ASK_READY)
end

 function niuniu_ui_controller:OnSyncBegin( tbl )
	Trace("重连同步开始")
	self.isReconnect = true
	if self.ui.voteView ~= nil then
		self.ui.voteView:Hide()
	end
	self:ReSetAll()
	self.ui:SetAllState(false)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SYNC_BEGIN)
end

--重连同步
 function niuniu_ui_controller:OnSyncTable()
	--[[
	   prepare     = "deal",       --发牌(4张)
            deal        = "robbanker",  --抢庄
            robbanker   = "mult",        --下注
            mult         = "deallast",    --发最后一张牌
            deallast    = "opencard",   --亮牌
            opencard    = "compare",    --比牌
            compare     = "reward",     --结算
            reward      = "gameend",    --游戏结束
            gameend     = "prepare",    --下一局
]]
	Trace("重连同步表")
	local tbl  = self.data_manage.OnSyncTableData
	local mode = self.data_manage.roomInfo.GameSetting.takeTurnsMode
	local nCurrJu = self.data_manage.roomInfo.nCurrJu
	local sCurrStage = tbl._para.sCurrStage
	self.ui.readyBtnsView:SetCloseBtnVisible(false)
	roomdata_center.isStart = false
	roomdata_center.midJoinData:CreateViewSeatJoinMap(tbl["_para"]["stPlayerMidJoin"])
	self.ui:SetMidJoinState()
	
	if mode == niuniu_rule_define.SUB_BULL_BANKER.SUB_BULL_BANKER_FIXED then
		if sCurrStage ~= "choosebanker" and sCurrStage ~= "prepare"  then
			roomdata_center.isStart = true
		else
			if nCurrJu > 1 then
				roomdata_center.isStart = true
			end
		end
	else
		if sCurrStage ~= "prepare"  then
			roomdata_center.isStart = true
		else
			if nCurrJu > 1 then
				roomdata_center.isStart = true
			end
		end
	end
	
	local banker = tbl._para.banker--庄家的id
	if banker ~= nil and banker > 0 then
		if self.data_manage.BankerData == nil then
			self.data_manage.BankerData = {}
			local _para = {}
			_para.banker = banker
			self.data_manage.BankerData._para = _para
		else
			self.data_manage.BankerData._para.banker = banker
		end
		
		self.ui:HideAllBanker()
		local viewSeat = self.gvbln(banker)
		self.ui:SetBanker(viewSeat)
		local bankerBeishu = tbl._para.bankerBeishu
		self.data_manage.BankerData._para.nBeishu = bankerBeishu
		if bankerBeishu ~= nil then    --(明牌抢庄)庄家倍数
			self.ui:SetBeiShu(viewSeat,bankerBeishu,"倍")
		end
	end
	
	local playerState = tbl._para.stPlayerState
	if playerState ~= nil then		 --玩家状态0没人 1 没准备 2已准备
		for i ,v in ipairs(playerState) do
			local viewSeat = self.gvbln(i)
			if v == 1 then
			--	self.ui:SetPlayerReady(viewSeat,false)
				self.ui:SetState(viewSeat,false,niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_YIZHUNBEI,self.tableComponent)
				if viewSeat == 1 then
					self.ui.readyBtnsView:SetReadyBtnVisible(true)
					
					--固定庄家模式，先选庄再准备，所以没有庄家的时候，不显示准备按钮
				
					if	mode == niuniu_rule_define.SUB_BULL_BANKER.SUB_BULL_BANKER_FIXED and banker == 0 then
						self.ui.readyBtnsView:SetReadyBtnVisible(false)
					end
					
					--如果还没准备并且是第一局而且是房主本人，那么可以解散房间
					if nCurrJu <= 1 then
						if self.data_manage:IsOwner() and roomdata_center.isStart ==false then
							self.ui.readyBtnsView:SetCloseBtnVisible(true)
						end
					end
				end
			elseif v == 2 then
				if tbl._para.sCurrStage ~= "prepare" then
				--	self.ui:SetPlayerReady(viewSeat,false)
					self.ui:SetState(viewSeat,false,niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_YIZHUNBEI,self.tableComponent)
				else
				--	self.ui:SetPlayerReady(viewSeat,true)
					self.ui:SetState(viewSeat,true,niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_YIZHUNBEI,self.tableComponent)
				end
				
				if viewSeat == 1 then
					self.ui.readyBtnsView:SetReadyBtnVisible(false)
					if nCurrJu <= 1 then
						if self.data_manage:IsOwner()  and roomdata_center.isStart ==false then
							self.ui.readyBtnsView:SetCloseBtnVisible(true)
						end
					end
				end
			end
		end
	end
	local playersUid = tbl._para.stPlayerUid ----玩家uid
	local playerRob = tbl._para.stPlayerRob		-- --玩家抢庄状态：-1还没操作, 0不抢，>0抢庄倍数
	if playerRob ~= nil and tbl._para.sCurrStage == "robbanker" then
		for i,v in ipairs(playerRob) do
			local viewSeat = self.gvbln(i)
			if v == 0 then
				self.ui:SetState(viewSeat,true,niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_BUQIANGZHUAN,self.tableComponent)
			elseif v > 0 then
					self.ui:SetState(viewSeat,false,niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_QIANGZHUANG,self.tableComponent)
					self.ui:SetBeiShu(viewSeat,v,"倍")
			end
		end
	end	
	local bankerViewSeat = self.gvbln(tbl["_para"]["banker"]) 
	local multLogicState = tbl["_para"]["stPlayerMult"]
	if (tbl~=nil and tbl["_para"]["sCurrStage"] == "mult") then
		self.ui:RefreshXiaZhuZhong(bankerViewSeat,multLogicState,self.tableComponent)
	end
	if multLogicState ~= nil  then	--玩家下注状态：-1还没操作，>0下注底分 得显示按钮跟手排
		for i,v in ipairs(multLogicState) do
			local viewSeat = self.gvbln(i)			
			if v > 0 then
				self.ui:SetBeiShu(viewSeat,v,"分")
			end
		end
	end
		--玩家亮牌状态：-1没亮，1亮
	local stPlayerBright = tbl["_para"]["stPlayerBright"]
	
	if (tbl~=nil and tbl["_para"]["sCurrStage"] == "opencard") then
		if stPlayerBright ~= nil then
			for i,v in ipairs(stPlayerBright) do
			local viewSeat = self.gvbln(i)			
			if v == -1 then
				self.ui:SetState(viewSeat,true,niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_CUOPAIZHONG,self.tableComponent)
			elseif v == 1 then
				self.ui:SetState(viewSeat,false,niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_CUOPAIZHONG,self.tableComponent)
			end
		end
		end
	end
	self:SyncPlayerLeave(tbl._para.stPlayerNoChair)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SYNC_TABLE)
end

 function niuniu_ui_controller:OnSyncEnd( tbl )
	Trace("重连同步结束")
	Trace(GetTblData(tbl))
	self.isReconnect = false
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SYNC_END)
end

 function niuniu_ui_controller:OnLeaveEnd( tbl )
	Trace("用户离开")
	self:PlayerLeave(tbl)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_PLAYER_LEAVE)
end

function niuniu_ui_controller:PlayerLeave(tbl)
	base.PlayerLeave(self,tbl)

	local logicSeat =  player_seat_mgr.GetLogicSeatByStr(tbl["_src"])
	local viewSeat = self.gvbln(logicSeat)
	self.ui:SetState(viewSeat,false,niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_YIZHUNBEI,self.tableComponent)
end

function niuniu_ui_controller:SyncPlayerLeave(notEnterPlayerList)
	if notEnterPlayerList ~= nil and #notEnterPlayerList > 0 then
		for i,v in ipairs(notEnterPlayerList) do
			local tbl = {}
			tbl._para = {}
			tbl._src = "p"..tostring(v)
			tbl._para._chair = tonumber(v)
			self:PlayerLeave(tbl)
		end
	end
end

 function niuniu_ui_controller:OnPlayerOffline()
	local tbl =  self.data_manage.offlineData
	Trace(GetTblData(tbl))
	local viewSeat = self.gvbl(tbl._src)
	if  tbl._para.active == nil  then
		if  roomdata_center.isStart == true then
		else
			self.ui:HidePlayer(viewSeat)
		end
	elseif  tbl._para.active ~= nil and tbl._para.active == 1 then
		self.ui:SetPlayerLineState(viewSeat, false)
	elseif tbl._para.active ~= nil and tbl._para.active == 0 then
		self.ui:SetPlayerLineState(viewSeat, true)
	else
		self.ui:SetPlayerLineState(viewSeat, false)
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_OFFLINE)
end

--点击亮牌之后，UI显示牛几的按钮
 function niuniu_ui_controller:RecommondCard(nCardType)
	if nCardType == nil then
		local dealData = self.data_manage.DealData
		if dealData == nil then
			logError("发牌数据为空！")
			return
		end
		nCardType = dealData._para.nCardType
	end
	self.ui.before_starting_operation_view:IsShowCuoPaiBtn(false)
	self.ui:SetTiposition(false)
	self.ui.before_starting_operation_view:IsShowOpenCardBtn(false,nCardType)
	pokerPlaySysHelper.GetCurPlaySys().OpenCardReq()
	--开牌了，隐藏搓 牌状态提示
	self.ui:SetState(1,false,"",self.tableComponent)
	Trace("点击亮牌之后，UI显示牛几的按钮:"..tostring(nCardType))
end

--//////////////////////////投票 end//////////////////////////////

 function niuniu_ui_controller:OnPointsRefresh( tbl )
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F1_POINTS_REFRESH)
end

--提示闲家选择倍数
 function niuniu_ui_controller:OnAskMult()
	Trace("提示下注选择分数")
	self.ui:HideAllBeiShu(false)
	local OnBankData = self.data_manage.BankerData
	local viewSeat = self.gvbln(OnBankData._para.banker)
	local state = OnBankData._para.nBeishu
	self.ui:SetBeiShu(viewSeat,state,"倍")
	local tbl = self.data_manage.OnAskMultData
	local timeOut = tbl["timeo"] - tbl.time
	self.ui:SetXiaoPao(tonumber(timeOut),function()
		if not self.data_manage:IsBanker() then
			self.ui:SetShakeTimer(30)			--下注超时不操作无限等待震动
		end
	end)
	self.ui:SetBeiShuBtnCount()
	sessionData = player_data.GetSessionData()
	if self.data_manage:IsBanker() then
		self.ui:SetSelfDone(true)
		self.ui:SetXiaoPaoLabelByStr("请等待其他玩家下注...")
		self.ui:IsShowBeiShuiBtn(false)
	else
		self.ui:IsShowBeiShuiBtn(true)
	end
	--除了庄家，显示下注中
	if self.isReconnect == false then
		local bankerData = self.data_manage.BankerData
		if bankerData == nil then
			logError("庄家的数据不能为空！！！！！")
		else
			local bankerViewSeat = self.gvbln(bankerData._para.banker)
			self.ui:SetXiaZhuZhong(bankerViewSeat,self.tableComponent)
			
		end
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.FuZhouSSS_ASKMULT)
end

--选择倍数回调
 function niuniu_ui_controller:OnMult(tbl)
	local tbl = self.data_manage.OnMultData
	local para = tbl["_para"]
	local p1 = para["p1"]
	local p2 = para["p2"]
	local p3 = para["p3"]
	local p4 = para["p4"]
	local p5 = para["p5"]
	local p6 = para["p6"]
	local viewSeat = 1
	local value = 0
	if p1 ~= nil then
		viewSeat =  self.gvbln(1)
		value = p1
	elseif p2 ~= nil  then
		viewSeat = self.gvbln(2)
		value = p2
	elseif p3 ~= nil then
		viewSeat =  self.gvbln(3)
		value = p3
	elseif p4 ~= nil then
		viewSeat =  self.gvbln(4)
		value = p4
	elseif p5 ~= nil then
		viewSeat =  self.gvbln(5)
		value = p5
	elseif p6 ~= nil then
		viewSeat =  self.gvbln(6)
		value = p6
	end
	if viewSeat == 1 then
		self.ui:IsShowBeiShuiBtn(false)
		self.ui:SetSelfDone(true)
		self.ui:StopShakeTimer()
	end
	self.ui:SetState(viewSeat,false,"",self.tableComponent)
	self.ui:SetBeiShu(viewSeat,value,"分")
	Trace("个人选择倍数回调，座位"..tostring(viewSeat).."倍数"..tostring(value))
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.FuZhouSSS_MULT)
end

--所有人倍数回调
 function niuniu_ui_controller:OnAllMult()
	Trace("所有人倍数回调")
	self.ui:IsShowBeiShuiBtn(false)
	self.ui:StopCountDownTimer()
	self.ui:IsShowCountDownSlider(false)
	self.ui:ShowXiaoPaoPanel(false)
	
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmd_shisanshui.FuZhouSSS_ALLMULT)
end

--显示特殊排型动画
 function niuniu_ui_controller:OnSpecialCardType(tbl)
	self.ui:ShowSpecialCardIcon(tbl)
end

function niuniu_ui_controller:ShowSpecialCardAnimation(tbl)
	self.ui:ShowSpecialCardAnimation(tbl)
end

--显示理牌提示
 function niuniu_ui_controller:OnReadCard(tbl)
	self.ui:SetReadCardState(tbl)
end

--获得最后一张牌的坐标
function niuniu_ui_controller:OnGetLastCardPosition(position)
	self.ui:SetTiposition(true,position)
end

function niuniu_ui_controller:SetFinishState(tbl)
	local viewSeat = tbl.viewSeat
	self.ui:SetFinishState(true,tbl.position)
end

function niuniu_ui_controller:ReSetAll()
	self.ui:ResetAll()
end

function niuniu_ui_controller:Init()

end

function niuniu_ui_controller:UInit()

end


return niuniu_ui_controller

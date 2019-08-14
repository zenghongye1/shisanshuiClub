--[[--
 * @Description:赢三张UI 控制层
 * @Author:      xuemin.lin
 * @FileName:    yingsanzhang_ui_controller.lua
 * @DateTime:    2017-10-12
 ]]


require "logic/gameplay/cmd_shisanshui"
require "logic/mahjong_sys/_model/room_usersdata_center"
require "logic/mahjong_sys/_model/room_usersdata"
require "logic/mahjong_sys/_model/operatorcachedata"
require "logic/mahjong_sys/_model/operatordata"

local base = require("logic.poker_sys.common.poker_ui_controller_base")
local yingsanzhang_ui_controller = class("yingsanzhang_ui_controller",base)
local yingsanzhang_data_manage = require("logic.poker_sys.yingsanzhang_sys.cmd_manage.yingsanzhang_data_manage")

function yingsanzhang_ui_controller:ctor()
	base.ctor(self)

	self.gvbl = player_seat_mgr.GetViewSeatByLogicSeat
	self.gvbln = player_seat_mgr.GetViewSeatByLogicSeatNum
	self.gmls = player_seat_mgr.GetMyLogicSeat
	self.isReconnect = false
	self.result_para_data = {}
	self.tableComponent = nil
	self.isFirstJu = true
end

function yingsanzhang_ui_controller:InitDataAndUIMgr()
	self.ui = UI_Manager:Instance():GetUiFormsInShowList("yingsanzhang_ui")
	self.data_manage = yingsanzhang_data_manage:GetInstance()
end

function yingsanzhang_ui_controller:InitTableComponent()
	if self.tableComponent == nil then
		self.tableComponent = require("logic.poker_sys.yingsanzhang_sys.cmd_manage.yingsanzhang_msg_manage"):GetInstance():GetSceneControllerInstance().tableComponent
	end
end


function yingsanzhang_ui_controller:OnPlayerEnter( tbl )
-- 	Trace("OnPlayerEnter",GetTblData(tbl))
	
-- 	local viewSeat = self.gvbl(tbl["_src"])
-- 	local logicSeat = player_seat_mgr.GetLogicSeatByStr(tbl["_src"])
-- 	local uid = tbl["_para"]["_uid"]
-- 	local userdata = room_usersdata.New()
-- 	userdata.name = tbl["_para"]["_uid"]
-- 	userdata.uid =  tbl["_para"]["_uid"]
-- 	userdata.coin = tbl["_para"]["score"]["coin"]
-- 	userdata.viewSeat = viewSeat
-- 	userdata.logicSeat = logicSeat
-- 	userdata.vip  = 0
-- 	userdata.saved = tbl["_para"]["saved"]
-- 	if self.data_manage.roomInfo.owner_uid == uid then
-- 		userdata.owner = true
-- 	end
	
-- 	room_usersdata_center.AddUser(logicSeat,userdata)
-- 	self.ui:SetPlayerInfo( viewSeat, userdata)
--     --加载头像
-- 	local param={["uid"] = userdata.uid,["type"]=1}

-- 	local nameDone = false
-- 	local urlDone = false

-- 	local name = hall_data.GetPlayerPrefs(uid.."name")
-- 	local headurl = hall_data.GetPlayerPrefs(uid.."headurl")
-- 	if name ~= nil and headurl ~= nil then
-- 		userdata.name = name
-- 		userdata.headurl = headurl
-- 		room_usersdata_center.AddUser(logicSeat,userdata)
-- 		self.ui:SetPlayerInfo(viewSeat, userdata)
-- 	end

-- 	HttpProxy.GetGameInfo(param, function(info) 
-- 		 if info.nickname~=name then
-- 			userdata.name = info.nickname
-- 			hall_data.SetPlayerPrefs(uid.."name",info.nickname)
-- 		end
-- 		if info.imageurl~=headurl then
-- 			userdata.headurl = info.imageurl
-- 			hall_data.SetPlayerPrefs(uid.."headurl",info.imageurl)
-- 		end
-- 		if info.imagetype~=imagetype then
-- 			userdata.imagetype = info.imagetype
-- 			hall_data.SetPlayerPrefs(uid.."imagetype",info.imagetype)
-- 		end
-- 		room_usersdata_center.AddUser(logicSeat,userdata)
-- 		self.ui:SetPlayerInfo(viewSeat, userdata)
-- 	end)	
	
-- 	-- http_request_interface.getGameInfo(param,function (str) 
-- 	-- 	local s=string.gsub(str,"\\/","/")
--  --        local t=ParseJsonStr(s)

--  --        if t["data"] then
-- 	--         if t["data"].nickname~=name then
-- 	-- 			userdata.name = t["data"].nickname
-- 	-- 			hall_data.SetPlayerPrefs(uid.."name",t["data"].nickname)
-- 	-- 		end
-- 	-- 		if t["data"].imageurl~=headurl then
-- 	-- 			userdata.headurl = t["data"].imageurl
-- 	-- 			hall_data.SetPlayerPrefs(uid.."headurl",t["data"].imageurl)
-- 	-- 		end
-- 	-- 		if t["data"].imagetype~=imagetype then
-- 	-- 			userdata.imagetype = t["data"].imagetype
-- 	-- 			hall_data.SetPlayerPrefs(uid.."imagetype",t["data"].imagetype)
-- 	-- 		end
-- 	-- 		room_usersdata_center.AddUser(logicSeat,userdata)
-- 	-- 		self.ui:SetPlayerInfo(viewSeat, userdata)
-- 	-- 	end
-- 	-- end)

-- 	Trace("----------------------------------------------------SetPlayerInfo")
	
-- 	local currentRoomPlayerCount = room_usersdata_center.GetRoomPlayerCount()
-- 	if tonumber(currentRoomPlayerCount) == tonumber(self.data_manage.roomInfo.nPlayerNum) then
-- 		self.ui.readyBtnsView:SetInviteBtnVisible(false) --如果进入的坐位号等于房间的人数，那么就是满员了，这时隐藏邀请按钮
-- 	else
-- 		self.ui.readyBtnsView:SetInviteBtnVisible(true)
-- 	end
-- 	self.ui:SetGameNum()--显示房间局数
-- --	self.ui:SetGameInfo("房号:", self.data_manage:GetRoomInfo().rno)
-- 	if viewSeat < 1 then
-- 		logError("座位出错，必须检查服务器数据！！！！！！！！！！！！！！！",viewSeat," ",tbl["_src"])
-- 	end
-- 	local isOwner = self.data_manage:IsOwner()
-- 	if isOwner == true then
-- 		if roomdata_center.isStart == false then
-- 			self.ui.readyBtnsView:SetCloseBtnVisible(true)--显有房主可以解散房间
-- 		end
-- 	else
-- 		self.ui.readyBtnsView:SetCloseBtnVisible(false)
-- 	end
-- 	if viewSeat == 1 then
-- 		self:ReSetAll()
-- 	end
-- 	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_ENTER) 
	base.OnPlayerEnter(self, tbl)
	local viewSeat = self.gvbl(tbl["_src"])
	if viewSeat == 1 then
		self:ReSetAll()
	end
end

function yingsanzhang_ui_controller:OnAskChooseBanker()
	--[[local tbl = self.data_manage.AskChooseBanker
	Trace("固定庄家:"..GetTblData(tbl))
--	self.ui:IsShowChooseBanker(true)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_niuniu.ASK_CHOOSEBANKER)--]]
end

function yingsanzhang_ui_controller:OnBanker()
	Trace("定庄完成")
	local OnBankData = self.data_manage.BankerData
	local viewSeat = self.gvbln(OnBankData["_para"]["banker"])
	self.ui:SetBanker(viewSeat)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_BANKER)
end

function yingsanzhang_ui_controller:OnPlayerReady()
	tbl = self.data_manage.ReadyData
	local viewSeat = self.gvbl(tbl["_src"])
	if viewSeat == 1 then
		self:ReSetAll()
		self.ui:HideDisMissCountDown()
	else
		self.ui:ResetPlayerByViewSeate(viewSeat)
	end
	self.ui:SetState(viewSeat,true,yingsanzhang_rule_define.PT_YINGSANZHANG_State.PT_YINGSANZHANG_YIZHUNBEI,self.tableComponent)
	Trace("玩家准备好"..tostring(viewSeat))
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_READY)
end

--提示抢庄(自由抢庄模式，明牌抢庄模式)
function yingsanzhang_ui_controller:OnAskRobbanker()
	--[[Trace("提示抢庄")
	local mode = self.data_manage.roomInfo.GameSetting.takeTurnsMode
	local tbl = self.data_manage.AskRobbankerData
	self.ui:SetBankerBtnByMode(mode,tbl)
	--显示抢庄中
	self.ui:SetAllState(true,niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_QIANGZHUANGZHONG,self.tableComponent)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmd_niuniu.ASK_ROBBANKER )--]]
end

--抢庄倍数通知
function yingsanzhang_ui_controller:OnRobbanker(tbl)
	--[[Trace("抢庄倍数通知")
	--显示抢与不抢
	local robbankerData = self.data_manage.OnRobbankerData
	local viewSeat =self.gvbln(robbankerData._para._chair)
	 --0表示不抢 >0表示抢
	local state = robbankerData._para.nBeishu
	if state == 0 then
		self.ui:SetState(viewSeat,true,niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_BUQIANGZHUAN,self.tableComponent)
	else
		self.ui:SetState(viewSeat,false,niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_QIANGZHUANG,self.tableComponent)
--		self.ui:SetBeiShu(viewSeat,state,"倍")
	end
	if viewSeat == 1 then
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_niuniu.ROBBANKER)--]]
end

function yingsanzhang_ui_controller:OnGameStart()	
	local subRound = self.data_manage.GameStartData._para.subRound
	roomdata_center.SetSubRoundNum(subRound)
	self.ui:SetGameNum(subRound)
--	self.ui:SetAllPlayerReady(false)
	self.ui:SetAllState(false)
	self.ui.readyBtnsView:SetInviteBtnVisible(false)
	self.ui.readyBtnsView:SetCloseBtnVisible(false)
--	self.ui:IsShowBeiShuiBtn(false)
	self.ui:HideDisMissCountDown()
	self.ui:HideReadyDisCountDowm()
--	self.ui:SetXiaoPao(0)
	roomdata_center.isStart = true
	ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/duijukaishi")
	--播放发牌，洗牌动画 do something
	coroutine.start(function()
		self.ui:PlayGameStartAnimation()
		coroutine.wait(0.8)
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAMESTART)
	end)
end

 function yingsanzhang_ui_controller:OnGameDeal(tbl)	
--	self.ui:IsShowBeiShuiBtn(false)
	self.isReconnect = false
	self.ui.OperationView_93:IsShowLabel(true)
end

function yingsanzhang_ui_controller:AfterDealBet(tbl)		
	local nBetCoin = tbl["_para"]["nBetCoin"]
	local nRoundCoin = tbl["_para"]["nRoundCoin"]
	for _,v in pairs(self.ui.playerList) do
		local viewSeat = v.viewSeat
		self.ui:AddChip(viewSeat,nBetCoin)
		self.ui:SetBetChip(viewSeat,nRoundCoin)
	end
	self.ui.OperationView_93:AfterDealBet(tbl)
end

--提示亮牌
function yingsanzhang_ui_controller:OnAskOpenCard()
	--[[Trace("提示亮牌")
	local tbl = self.data_manage.OnAskOpenCardData 
	if self.isReconnect == false then
		self.ui:SetAllState(true,niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_CUOPAIZHONG,self.tableComponent)
	end
	self.ui.before_starting_operation_view:IsShowCuoPaiBtn(true)
	self.ui.before_starting_operation_view:IsShowOpenCardBtn(true)
	local timeo = tbl.timeo - tbl.time
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_niuniu.ASK_OPENCARD)--]]
end

--某人已经亮牌
function yingsanzhang_ui_controller:OnOpenCard(tbl)	
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/dub/kanpai")
	local tbl = self.data_manage.OnOpenCardData
	local viewSeat = self.gvbl(tbl._src)
	Trace ("-------某人已经亮牌"..tostring(viewSeat))
	
	for i,v in pairs(self.ui.playerList) do
		if  v.viewSeat == viewSeat then
			if viewSeat == 1 then
				self.ui.OperationView_93.btn_opencard.gameObject:SetActive(false)
				self.data_manage:SetSelfOpenCardState(true)
				self.data_manage["betMultTbl"] = tbl["_para"]["stBaseCoin"]
				self.ui.OperationView_93:OnOpenCard(tbl)
			end
		end
	end	
end

function yingsanzhang_ui_controller:OnCompareResult()
	local tbl = self.data_manage.CompareResultData	
	local stAllCompareData = tbl["_para"]["stAllCompareData"]
	local actorNum = table.getn(stAllCompareData)
	self.ui.OperationView_93:IsShowWidgets(false)
	if actorNum > 2 then
		self.ui:playAllCompareEffect()
	elseif actorNum == 2 then								---仅两人则普通比牌
		local nWinChair = tbl["_para"]["stWinChairs"][1]
		local myLogicSeatNum = self.gmls()
		
		local data = {}
		data["_para"] = {}
		data["_para"]["nWinChair"] = nWinChair
		if table.getn(tbl["_para"]["stWinChairs"]) == 2 then
			data["_para"]["isGameDrawn"] = true					--系统比牌和局
		end	
		for _,v in ipairs(stAllCompareData) do
			if v["chairid"] ~= nWinChair then
				data["_para"]["nLooseChair"] = v["chairid"]
			end
			if v["chairid"] == myLogicSeatNum then				---自己参与则作为发起
				data["_para"]["nAskChair"] = myLogicSeatNum	
			end
		end
		if not data["_para"]["nAskChair"] then
			local temp = math.random()							---自己不参与则随机
			data["_para"]["nAskChair"] = ((temp>0.5) and data["_para"]["nWinChair"]) or data["_para"]["nLooseChair"] or nWinChair
		end
		self.ui:playCompareEffect(data)
	else
		logError("系统全桌比牌人数错误",tostring(actorNum))
	end
	
--	self.ui:SetAskPoenCard(0)
	self.ui.before_starting_operation_view:IsShowOpenCardBtn(false)
	self.ui.before_starting_operation_view:IsShowCuoPaiBtn(false)
--	self.ui:SetFinishState(false)
--	self.ui:SetTiposition(false)
	self.ui:SetAllState(false)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.COMPARE_RESULT)
end

 function yingsanzhang_ui_controller:OnCompareStart(tbl)

end

--某人亮牌显示牌型
function yingsanzhang_ui_controller:AfterOpenShowType(tbl)
	local viewSeat = tbl["viewSeat"]
	local nCardType = tbl["nCardType"]
	Trace ("-------某人已经亮牌"..tostring(viewSeat))
	
	for i,v in pairs(self.ui.playerList) do
		if  v.viewSeat == viewSeat then		
			if viewSeat == 1 then
				self.ui.OperationView_93:IsShowOpenCardBtn(false)
			end
			v:SetCardStateShow(true,nCardType)
		end
	end	
end

function yingsanzhang_ui_controller:OnGameEnd()
	self.ui:SetAllState(false)
	self.ui.OperationView_93:IsShowWidgets(false)
end

 function yingsanzhang_ui_controller:OnGameRewards()
	self.ui.OperationView_93:IsShowOptionBtn(false)
	self.ui:ResetTurnCount()
	self.ui:OnClickBg()
	local rewardData = self.data_manage.SmallRewardData
	local rewards = rewardData._para.rewards
	coroutine.start(function()
		local loseCount = 0
		for i,v in ipairs(rewards) do
			local viewSeat = self.gvbl(v._chair)
			if v["nAddScore"] <= 0 then
				loseCount = loseCount + 1
				local viewSeat = self.gvbl(v._chair)
				self.ui:ShowPlayerTotalPoints(viewSeat,tonumber(v["nAddScore"]))
			end
		end
		coroutine.wait(0.1)
		
		local winerCount = table.getn(rewards) - loseCount
		local winPlayerIndex = 0	
		for i,v in ipairs(rewards) do
			if v["nAddScore"] > 0 then
				winPlayerIndex = winPlayerIndex + 1
				local viewSeat = self.gvbl(v._chair)
				self.ui:SetPlayerLightFrame(viewSeat)
				self.ui:ChipFlyAnimation(viewSeat,winerCount,winPlayerIndex)
				self.ui:ShowPlayerTotalPoints(viewSeat,tonumber(v["nAddScore"]))
			end
		end
		coroutine.wait(1)
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SMALL_SETTLEMENT) --确认完成结算完成消息
	end)
end

--大结算处理
 function yingsanzhang_ui_controller:ShowLargeResult(tbl)
	if tbl and tbl._para then
		local largeResult_data = require("logic/poker_sys/yingsanzhang_sys/large_result/yingsanzhang_largeResult_data"):create(tbl._para)
		UI_Manager:Instance():ShowUiForms("poker_largeResult_ui",UiCloseType.UiCloseType_CloseNothing,nil,largeResult_data)
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmdName.GAME_SOCKET_BIG_SETTLEMENT)
end

 function yingsanzhang_ui_controller:OnAskReady()
	tbl = self.data_manage.AskReadyData
	local timeo = tbl.timeo
	local timeEnd = timeo
	Trace("等待举手, 时间："..tostring(timeo))

	if(timeEnd ~= -1 and timeEnd > 0 ) then 
		self.ui:SetDisMissCountDown(timeEnd)
	end

	self.ui.readyBtnsView:SetReadyBtnVisible(true)
	--如果断线重连回来，没有比牌结果，会导致这个按钮没有清除，所以得在这里清一下。
	self.ui.before_starting_operation_view:IsShowCuoPaiBtn(false)
--	self.ui:SetFinishState(false)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_ASK_READY)
end

function yingsanzhang_ui_controller:OnTrun(tbl)
	self.ui.OperationView_93:OnTrun(tbl)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmd_poker.turn)
end

function yingsanzhang_ui_controller:OnAskAction(tbl)
	local viewSeat = self.gvbl(tbl._src)
	local time = tbl["timeo"]
	if viewSeat == 1 then
		self.data_manage["betMultTbl"] = tbl["_para"]["stAction"]["stBaseCoin"]
		self.ui.OperationView_93:OnAskAction(tbl)
	end
	self.ui:AskAction(viewSeat,time)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmd_poker.ask_action)
end

function yingsanzhang_ui_controller:OnCall(tbl)
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/dub/genzhu")
	self.ui.OperationView_93:OnCall(tbl)
	local viewSeat = self.gvbl(tbl._src)
	local nBetCoin = tbl["_para"]["nBetCoin"]
	local nRoundCoin = tbl["_para"]["nRoundCoin"]
	if viewSeat == 1 then
		self.ui:OnClickBg()
	end
	self.ui:AddChip(viewSeat,nBetCoin)
	self.ui:SetBetChip(viewSeat,nRoundCoin)
	self.ui:IsShowCountDownSlider(false)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmd_poker.call)
end

function yingsanzhang_ui_controller:OnRaise(tbl)
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/dub/jiazhu")
	self.ui.OperationView_93:OnRaise(tbl)
	local viewSeat = self.gvbl(tbl._src)
	local nBetCoin = tbl["_para"]["nBetCoin"]
	local nRoundCoin = tbl["_para"]["nRoundCoin"]
	self.ui:AddChip(viewSeat,nBetCoin)
	self.ui:SetBetChip(viewSeat,nRoundCoin)
	self.ui:IsShowCountDownSlider(false)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmd_poker.raise)
end

function yingsanzhang_ui_controller:OnFold(tbl)
	local qipaiMus = {
		[1] = "qipai1",
		[2] = "qipai2",
		[3] = "qipai3"
	}
	local i = math.random(1,3)
	if qipaiMus[i] then
		ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/dub/"..qipaiMus[i])
	end
	local viewSeat = self.gvbl(tbl._src)
	if viewSeat == 1 then		
		self.ui.OperationView_93:OnFold(tbl)
		self.data_manage:SetSelfFoldState(true)
	end
	self.ui.playerList[viewSeat]:SetIsOut(true)		--设置出局
	self.ui.playerList[viewSeat]:GiveUpCalling(true)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmd_poker.fold)
end

function yingsanzhang_ui_controller:OnCompare(tbl)
	self.ui:OnClickBg()
	if self.gvbln(tbl["_para"]["nAskChair"]) ~= 1 and (self.gvbln(tbl["_para"]["nWinChair"]) == 1 or self.gvbln(tbl["_para"]["nLooseChair"]) == 1) then
		Notifier.dispatchCmd(cmdName.MSG_SHAKE,{})
	end
	local viewSeat = self.gvbl(tbl._src)
	local nBetCoin = tbl["_para"]["nBetCoin"]
	local nRoundCoin = tbl["_para"]["nRoundCoin"]
	coroutine.start(function()
		self.ui:AddChip(viewSeat,nBetCoin)		--比牌先下注
		self.ui:SetBetChip(viewSeat,nRoundCoin)
		coroutine.wait(0.6)
		self.ui:playCompareEffect(tbl,function()		--比牌动画
			self.ui.OperationView_93:OnCompare(tbl)
			local loseView = self.gvbln(tbl["_para"]["nLooseChair"])
			if loseView == 1 then
				self.data_manage:SetSelfLoseState(true)
			end
			self.ui.playerList[loseView]:SetIsOut(true)		--设置出局
			self.ui.playerList[loseView]:SetLoseGameState(true)
			local data = {}
			data["nLooseChair"] = tbl["_para"]["nLooseChair"]
			Notifier.dispatchCmd(cmd_93.SetPokerGray,data)
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmd_poker.compare)
		end)		
	end)
end

function yingsanzhang_ui_controller:OnAllCompare(tbl)
	self.ui:playAllCompareEffect(tbl)
	self.ui:IsShowCountDownSlider(false)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmd_poker.all_compare)
end

 function yingsanzhang_ui_controller:OnSyncBegin( tbl )
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
 function yingsanzhang_ui_controller:OnSyncTable()
	local currStage = {
		prepare = "prepare",	--开始准备
		banker = "banker",		--定庄
		deal = "deal",			--抓牌
		round = "round",		--游戏阶段(下注 跟注 看牌 比牌 弃牌等游戏操作)
		reward = "reward",		--结算
		gameend = "gameend"		--结束
	}
	
	---设置游戏是否已经开始
	local function SetIsStartState(sCurrStage,nCurrJu)
		if nCurrJu <= 1 and sCurrStage == currStage.prepare then
			roomdata_center.isStart = false
		else
			roomdata_center.isStart = true
		end
	end
	---设置当前牌局庄家,banker:0未定庄,其他对应逻辑位置数字
	local function SetBankerState(banker)
		self.ui:HideAllBanker()
		if banker ~= nil and banker > 0 then
			if self.data_manage.BankerData == nil then
				self.data_manage.BankerData = {}
				local _para = {}
				_para.banker = banker
				self.data_manage.BankerData._para = _para
			else
				self.data_manage.BankerData._para.banker = banker
			end		
			local viewSeat = self.gvbln(banker)
			self.ui:SetBanker(viewSeat)
		end
	end


	Trace("重连同步表")
	local tbl  = self.data_manage.OnSyncTableData
	local nCurrJu = self.data_manage.roomInfo["nCurrJu"]
	local sCurrStage = tbl["_para"]["sCurrStage"]
	self.ui.readyBtnsView:SetCloseBtnVisible(false)
	self.ui.readyBtnsView:SetReadyBtnVisible(false)
	SetIsStartState(sCurrStage,nCurrJu)
	local banker = tbl["_para"]["banker"]--庄家的id
	SetBankerState(banker)
	
	---准备阶段
	if sCurrStage == currStage.prepare then		
		local stPlayerState = tbl["_para"]["stPlayerState"]
		if stPlayerState ~= nil then		 --玩家状态0没人 1 没准备 2已准备
			for k,v in ipairs(stPlayerState) do
				local viewSeat = self.gvbln(k)
				if v == 1 then
					self.ui:SetState(viewSeat,false,yingsanzhang_rule_define.PT_YINGSANZHANG_State.PT_YINGSANZHANG_YIZHUNBEI,self.tableComponent)
					if viewSeat == 1 then
						self.ui.readyBtnsView:SetReadyBtnVisible(true)
					end
				elseif v == 2 then
					self.ui:SetState(viewSeat,true,yingsanzhang_rule_define.PT_YINGSANZHANG_State.PT_YINGSANZHANG_YIZHUNBEI,self.tableComponent)
					if viewSeat == 1 then
						self.ui.readyBtnsView:SetReadyBtnVisible(false)
					end
				else				
				end
				if viewSeat == 1 then
					--第一局未开局且是房主本人，可以解散房间
					if nCurrJu <= 1 then
						if self.data_manage:IsOwner() and roomdata_center.isStart == false then
							self.ui.readyBtnsView:SetCloseBtnVisible(true)
						end
					end
				end
			end
		end
		self:SyncPlayerLeave(tbl["_para"]["stPlayerNoChair"])	---未坐人的座位隐藏
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SYNC_TABLE)
	---游戏阶段
	elseif sCurrStage == currStage.round then	
		local actionViewSeat = self.gvbln(tbl["_para"]["whoisOnTurn"])
		if actionViewSeat ~= 1 then
			local timeEnd = tbl["_para"]["nLeftTime"]
			local actionTime = self.data_manage.roomInfo["TimerSetting"]["actionTimeOut"]
			for _,v in pairs(self.ui.playerList) do
				if v.viewSeat == actionViewSeat then
					v:SetTurnFrame(true,timeEnd,actionTime)
				else
					v:SetTurnFrame(false,true)
				end
			end
		end
		---UI相关的放到发牌后回调SyncAfterDeal里处理
		
	elseif sCurrStage == currStage.reward then
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SYNC_TABLE)
	else
		logError("重连阶段未处理------"..tostring(sCurrStage))
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SYNC_TABLE)
	end
end

--重连发完牌后的处理
function yingsanzhang_ui_controller:SyncAfterDeal(tbl)
	local curBetChipTbl = tbl["_para"]["stRoundMult"]
	if curBetChipTbl then
		for _,v in pairs(self.ui.playerList) do
			local viewSeat = v.viewSeat
			local logicSeatNum = player_seat_mgr.GetLogicSeatNumByViewSeat(viewSeat)
			self.ui:AddChip(viewSeat,curBetChipTbl[logicSeatNum])
			self.ui:SetBetChip(viewSeat,curBetChipTbl[logicSeatNum])
		end
	end
	
	local stPlayerEndTbl = tbl["_para"]["stPlayerEnd"]
	if stPlayerEndTbl then
		for _,v in pairs(self.ui.playerList) do
			local viewSeat = v.viewSeat
			local logicSeatNum = player_seat_mgr.GetLogicSeatNumByViewSeat(viewSeat)
			if stPlayerEndTbl[logicSeatNum] == 1 then
				if viewSeat == 1 then
					self.data_manage:SetSelfFoldState(true)
				end
				self.ui.playerList[viewSeat]:SetIsOut(true)		--设置出局
				v:GiveUpCalling(true)
				local data = {}
				data["nLooseChair"] = logicSeatNum
				Notifier.dispatchCmd(cmd_93.SetPokerGray,data)	--置灰手牌
			elseif stPlayerEndTbl[logicSeatNum] == 2 then
				if viewSeat == 1 then
					self.data_manage:SetSelfLoseState(true)
				end	
				self.ui.playerList[viewSeat]:SetIsOut(true)		--设置出局
				v:SetLoseGameState(true)
				local data = {}
				data["nLooseChair"] = logicSeatNum
				Notifier.dispatchCmd(cmd_93.SetPokerGray,data)	--置灰手牌
			else
				v:SetLoseGameState(false)
			end
		end
	end

	local stPlayerOpenTbl = tbl["_para"]["stPlayerOPen"]
	local selfCardType = tbl["_para"]["nCardType"]
	if stPlayerOpenTbl then
		for _,v in pairs(self.ui.playerList) do
			local viewSeat = v.viewSeat
			local logicSeatNum = player_seat_mgr.GetLogicSeatNumByViewSeat(viewSeat)
			if stPlayerOpenTbl[logicSeatNum] == 1 then
				if viewSeat == 1 then
					self.data_manage:SetSelfOpenCardState(true)
					v:SetCardStateShow(true,selfCardType)
				else
					--if not v.isOut then
						v:SetCardStateShow(true,0)
					--end
				end
			end
		end
	end	
	self.ui.OperationView_93:OnSyncTable(tbl)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SYNC_TABLE)
end

 function yingsanzhang_ui_controller:OnSyncEnd( tbl )
	Trace("重连同步结束"..GetTblData(tbl))
	self.isReconnect = false
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SYNC_END)
end

 function yingsanzhang_ui_controller:OnLeaveEnd( tbl )
	Trace("用户离开")
	self:PlayerLeave(tbl)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_PLAYER_LEAVE)
end

function yingsanzhang_ui_controller:PlayerLeave(tbl)
	base.PlayerLeave(self,tbl)

	local logicSeat =  player_seat_mgr.GetLogicSeatByStr(tbl["_src"])
	local viewSeat = self.gvbln(logicSeat)
	self.ui:SetState(viewSeat,false,yingsanzhang_rule_define.PT_YINGSANZHANG_State.PT_YINGSANZHANG_YIZHUNBEI,self.tableComponent)
end

function yingsanzhang_ui_controller:SyncPlayerLeave(notEnterPlayerList)
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

 function yingsanzhang_ui_controller:OnPlayerOffline()
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
 function yingsanzhang_ui_controller:RecommondCard(nCardType)
	--[[if nCardType == nil then
		local dealData = self.data_manage.DealData
		if dealData == nil then
			logError("发牌数据为空！")
			return
		end
		nCardType = dealData._para.nCardType
	end
	self.ui.before_starting_operation_view:IsShowCuoPaiBtn(false)
	self.ui.before_starting_operation_view:IsShowOpenCardBtn(false,nCardType)
	pokerPlaySysHelper.GetCurPlaySys().OpenCardReq()
	--开牌了，隐藏搓 牌状态提示
	self.ui:SetState(1,false,"",self.tableComponent)
	Trace("点击亮牌之后，UI显示牛几的按钮:"..tostring(nCardType))--]]
end

--//////////////////////////投票 end//////////////////////////////

 function yingsanzhang_ui_controller:OnPointsRefresh( tbl )
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F1_POINTS_REFRESH)
end

--提示闲家选择倍数
 function yingsanzhang_ui_controller:OnAskMult()
	
	--[[Trace("提示下注选择分数")
	self.ui:HideAllBeiShu(false)
	local OnBankData = self.data_manage.BankerData
	local viewSeat = self.gvbln(OnBankData._para.banker)
	local state = OnBankData._para.nBeishu
--	self.ui:SetBeiShu(viewSeat,state,"倍")
	
	local tbl = self.data_manage.OnAskMultData
	local timeOut = tbl["timeo"] - tbl.time
--	self.ui:SetXiaoPao(tonumber(timeOut),function()end)
--	self.ui:SetBeiShuBtnCount()
	sessionData = player_data.GetSessionData()
	if self.data_manage:IsBanker() then
--		self.ui:SetXiaoPaoLabelByStr("请等待其他玩家下注...")
--		self.ui:IsShowBeiShuiBtn(false)
	else
--		self.ui:IsShowBeiShuiBtn(true)
	end
	--除了庄家，显示下注中
	if self.isReconnect == false then
		local bankerData = self.data_manage.BankerData
		if bankerData == nil then
			logError("庄家的数据不能为空！！！！！")
		else
			local bankerViewSeat = self.gvbln(bankerData._para.banker)
--			self.ui:SetXiaZhuZhong(bankerViewSeat,self.tableComponent)
		end
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.FuZhouSSS_ASKMULT)--]]
end

--选择倍数回调
 function yingsanzhang_ui_controller:OnMult(tbl)
	--[[local tbl = self.data_manage.OnMultData
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
--		self.ui:IsShowBeiShuiBtn(false)
	end
	self.ui:SetState(viewSeat,false,"",self.tableComponent)
	Trace("个人选择倍数回调，座位"..tostring(viewSeat).."倍数"..tostring(value))
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.FuZhouSSS_MULT)--]]
end

--所有人倍数回调
 function yingsanzhang_ui_controller:OnAllMult()
	--[[Trace("所有人倍数回调")
	self.ui:StopCountDownTimer()
	self.ui:IsShowCountDownSlider(false)
	
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmd_shisanshui.FuZhouSSS_ALLMULT)--]]
end

--[[--显示特殊排型动画
 function yingsanzhang_ui_controller:OnSpecialCardType(tbl)
--	self.ui:ShowSpecialCardIcon(tbl)
--	self.ui:ShowSpecialCardAnimation(tbl)
end--]]

--[[function yingsanzhang_ui_controller:ShowSpecialCardAnimation(tbl)
--	self.ui:ShowSpecialCardAnimation(tbl)
end
--]]
--显示理牌提示
 function yingsanzhang_ui_controller:OnReadCard(tbl)
	--[[self.ui:SetReadCardState(tbl)--]]
end

--获得最后一张牌的坐标
function yingsanzhang_ui_controller:OnGetLastCardPosition(position)
--	self.ui:SetTiposition(true,position)
end

--[[function yingsanzhang_ui_controller:SetFinishState(tbl)
	local viewSeat = tbl.viewSeat
	--self.ui:SetFinishState(true,tbl.position)
end--]]

function yingsanzhang_ui_controller:ReSetAll()
	self.ui:ResetAll()
	self.ui.OperationView_93:Reset()
end

function yingsanzhang_ui_controller:Init()

end

function yingsanzhang_ui_controller:UInit()

end

return yingsanzhang_ui_controller

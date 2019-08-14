--[[--
 * @Description: 麻将UI 控制层
 * @Author:      ShushingWong
 * @FileName:    mahjong_ui_sys.lua
 * @DateTime:    2017-06-20 15:59:13
 ]]
require "logic/shisangshui_sys/shoot_ui/shoot_ui"
require "logic/shisangshui_sys/card_data_manage"
require "logic/shisangshui_sys/special_card_show/special_card_show"
require "logic/shisangshui_sys/place_card/place_card"
require "logic/gameplay/cmd_shisanshui"

local base = require("logic.poker_sys.common.poker_ui_controller_base")
shisanshui_ui_sys = class("shisanshui_ui_sys",base)


function shisanshui_ui_sys:ctor()
	base.ctor(self)
	self.gvbl = player_seat_mgr.GetViewSeatByLogicSeat
	self.gvbln = player_seat_mgr.GetViewSeatByLogicSeatNum
	self.gmls = player_seat_mgr.GetMyLogicSeat
	self.isReconnect = false
	self.result_para_data = {}
	self.firstGroupScore = 0
	self.secondGroupScore = 0
	self.threeGroupScore = 0
	self.isFirstJu = true
end

function shisanshui_ui_sys:InitDataAndUIMgr()
	self.ui = UI_Manager:Instance():GetUiFormsInShowList("shisanshui_ui")
end


-- function shisanshui_ui_sys:OnPlayerEnter( tbl )
-- 	Trace(GetTblData(tbl))
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
-- 	userdata.owner = roomdata_center.ownerId == uid
-- 	room_usersdata_center.AddUser(logicSeat,userdata)
-- 	self.ui:SetPlayerInfo( viewSeat, userdata)
--     --加载头像
-- 	local param={["uid"]=uid,["type"]=1}

-- 	local name = hall_data.GetPlayerPrefs(uid.."name")
-- 	local headurl = hall_data.GetPlayerPrefs(uid.."headurl")
-- 	local imagetype = hall_data.GetPlayerPrefs(uid.."imagetype")
-- 	if name~=nil and headurl~=nil and imagetype~=nil then
-- 		userdata.name = name
-- 		userdata.headurl = headurl
-- 		userdata.imagetype = imagetype
-- 		room_usersdata_center.AddUser(logicSeat,userdata)
-- 		self.ui:SetPlayerInfo(viewSeat, userdata)
-- 	end

-- 	HttpProxy.GetGameInfo(param, function(info) 
-- 		  if info.nickname~=name then
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
	
-- 	Trace("----------------------------------------------------SetPlayerInfo")
	
-- 	local currentRoomPlayerCount = room_usersdata_center.GetRoomPlayerCount()
-- 	if tonumber(currentRoomPlayerCount) == tonumber(roomdata_center.maxplayernum) then
-- 		self.ui.readyBtnsView:SetInviteBtnVisible(false) --如果进入的坐位号等于房间的人数，那么就是满员了，这时隐藏邀请按钮
-- 	else
-- 		self.ui.readyBtnsView:SetInviteBtnVisible(true)
-- 	end
	
-- 	self.ui:SetGameNum()--显示房间局数
-- 	if viewSeat < 1 then
-- 		logError("座位出错，必须检查服务器数据！！！！！！！！！！！！！！！",viewSeat," ",tbl["_src"])
-- 	end
-- 	local isOwner = roomdata_center.IsOwner()
-- 	if isOwner == true then
-- 		if roomdata_center.isStart == false then
-- 			self.ui.readyBtnsView:SetCloseBtnVisible(true)--显有房主可以解散房间
-- 		end
-- 	else
-- 		self.ui.readyBtnsView:SetCloseBtnVisible(false)
-- 	end
	
-- 	--是否选择加一色坐庄，如果是，显示庄的头像
-- 	--[[local roomInfo = roomdata_center.gamesetting
-- 	if roomInfo["bSupportWaterBanker"] == true then
-- 		if tonumber(logicSeat) == 1 then --如果是P1房主则设置庄家标志
-- 			self.ui:SetBanker(viewSeat)
-- 		end
-- 	end--]]
-- 	Trace("OnPlayerEnter------------------"..tostring(tonumber(gmls)))
-- 	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_ENTER) 
-- end

function shisanshui_ui_sys:OnPlayerReady( tbl )
	local logicSeat =  player_seat_mgr.GetLogicSeatByStr(tbl["_src"])
	local viewSeat = self.gvbl(tbl["_src"])
	if viewSeat == 1 then
		self.ui:ResetAll()
		self.ui:HideDisMissCountDown()
		self:ReSetAll()
	end
	self.ui:SetPlayerReady(viewSeat, true)
	Trace("玩家准备好"..tostring(logicSeat))
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_READY)
end

function shisanshui_ui_sys:OnGameStart( tbl )
	local subRound = tbl._para.subRound
	roomdata_center.SetSubRoundNum(subRound)
	self.ui:SetGameNum(subRound)--显示房间局数
	self.ui.readyBtnsView:SetInviteBtnVisible(false)
	self.ui.readyBtnsView:SetCloseBtnVisible(false)
	self.ui:IsShowBeiShuiBtn(false)
	self.ui:SetXiaoPao(0)
	self.ui:HideDisMissCountDown()	---游戏开始移除解散倒计时
	self.ui:HideReadyDisCountDowm()	---游戏开始移除解散倒计时
	roomdata_center.isStart = true
	ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/duijukaishi")
	self.ui:ResetAll()	
	self.ui:SetAllPlayerReady(false)
	if tbl["_para"]["nCodeCard"] > 0 then
		card_define.SetCodeCardValue(tbl["_para"]["nCodeCard"])
		self.ui:OpenCodeCardEffect(true)
	end
end

 function shisanshui_ui_sys:OnPlayStart( tbl )
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_PLAY_CARDSTART)
end

 function shisanshui_ui_sys:OnCompareStart(tbl)
	self.ui:IsShowCountDownSlider(false)
	self.ui:StopCountDownTimer()
	UI_Manager:Instance():CloseUiForms("place_card")
	UI_Manager:Instance():CloseUiForms("prepare_special")
end

 function shisanshui_ui_sys:OnGameDeal( tbl )
	self.ui:IsShowBeiShuiBtn(false)
	self.ui:SetAllPlayerReady(false)
end

 function shisanshui_ui_sys:OnGameRewards( tbl )
	self.isReconnect = false

	-- self.ui:DisablePlayerLightFrame()--关闭头像的光圈
	Trace("OnGameRewards结算。。。。t"..GetTblData(tbl))
	
	if tbl ~= nil and tbl._para ~= nil then
		self.result_para_data.data = tbl._para
		UI_Manager:Instance():ShowUiForms("shisanshui_smallResult_ui",UiCloseType.UiCloseType_CloseNothing,nil,tbl._para)
		self.result_para_data.state = 0
	end
	if tbl == nil or tbl._para == nil then
		Trace("tbl == nil or tbl._para = nil")
	end
	if tbl ~= nil and tbl._para ~= nil then
		local rewards = tbl._para.rewards
		if rewards ~= nil and #rewards > 0 then
			for i,reward in ipairs(rewards) do
				local viewSeat = self.gvbl(reward["_chair"])
				local score = reward["all_score"]
				if score == nil then score = 0 end
				self.ui:SetPlayerScore(viewSeat, tonumber(score))
		--		Trace("座位号:"..tostring(viewSeat).." 总积分:"..tostring(score))
			end
		end
	end
	if tbl["_para"]["curr_ju"] < tbl["_para"]["ju_num"] then
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SMALL_SETTLEMENT) --确认完成小结算完成消息
	end
end

 function shisanshui_ui_sys:OnAskReady( tbl )
	local timeo = tbl.timeo
	local timeEnd = timeo
	Trace("等待举手, 时间："..tostring(timeo).."  结束时间： "..tostring(timeEnd))
	local small_result = UI_Manager:Instance():GetUiFormsInShowList("shisanshui_smallResult_ui")
	if small_result ~= nil then
		if small_result.IsOpened == true then
			small_result:SetTimerStart(timeEnd - tbl.time)
		end
	else
		if(timeEnd ~= -1 and timeEnd > 0 ) then 
			self.ui:SetDisMissCountDown(timeEnd)
		end
	end
	self.ui.readyBtnsView:SetReadyBtnVisible(true)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_ASK_READY)
end

 function shisanshui_ui_sys:OnSyncBegin( tbl )
	Trace("重连同步开始")
	self.isReconnect = true
	self.ui:ResetAll()
	if self.ui.voteView ~= nil then
		self.ui.voteView:Hide()
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SYNC_BEGIN)
end

--重连同步
 function shisanshui_ui_sys:OnSyncTable( tbl )
	Trace("重连同步表---------"..GetTblData(tbl))
	local currStage = {
		prepare = "prepare",			--准备
		choosebanker = "choosebanker",	--定庄
		mult   = "mult",      			--下注
		deal = "deal",					--抓牌
		choose = "choose",     			--出牌(选择牌型)
		compare = "compare",			--比牌
		reward = "reward",				--结算
		gameend = "gameend"				--结束
	}

	local ePara = tbl._para
	local game_state = ePara.sCurrStage 		-- 游戏阶段
	local player_state = ePara.stPlayerState 	-- 玩家状态
	local player_UID = ePara.stPlayerUid 	-- 玩家状态
	
	local playMode_shisanshui = require ("logic.shisangshui_sys.cmd_manage.shisanshui_msg_manage"):GetInstance():GetPlayModeShiSanShuiInstance()
	local tableCtl = playMode_shisanshui:GetTabComponent()
	local playerList = tableCtl.PlayerList
	
	local stCards = ePara.stCards
	roomdata_center.isStart = true
	if roomdata_center.gamesetting["bSupportWaterBanker"] then
		local bankerViewSeat = self.gvbln(tbl["_para"]["banker"])
		if bankerViewSeat > 0 then
			self:SetBanker(bankerViewSeat)
		end
	end
	
	self.ui.readyBtnsView:SetCloseBtnVisible(false)
	UI_Manager:Instance():CloseUiForms("shisanshui_smallResult_ui")
	UI_Manager:Instance():CloseUiForms("place_card")
	if tbl["_para"]["nCodeCard"] > 0 then
		card_define.SetCodeCardValue(tbl["_para"]["nCodeCard"])
		self.ui:OpenCodeCardEffect(true)
	end
	if game_state == currStage.prepare then  
		--牌隐藏
		for _,v in pairs(playerList) do
			v.playerObj:SetActive(false)
		end		--准备阶段
		--标记不用投票可直接退出
		if roomdata_center.nCurrJu <= 1 then
			roomdata_center.isStart = false
			if roomdata_center.IsOwner() then
				self.ui.readyBtnsView:SetCloseBtnVisible(true)
			end
		end
		--显示准备提示准备
		for i=1,#player_state do
			--准备按扭
			local state = player_state[i]
			local userData = room_usersdata_center.GetUserByUid(player_UID[i])
			if state ~= nil and userData ~= nil then
				local viewSeat = userData.viewSeat
				if state == 2 then
					self.ui:SetPlayerReady(viewSeat, true)
					if viewSeat == 1 then
						self.ui.readyBtnsView:SetReadyBtnVisible(false)
					end
				elseif state == 1 then
					self.ui:SetPlayerReady(viewSeat, false)
					if viewSeat == 1 then
						self.ui.readyBtnsView:SetReadyBtnVisible(true)
					end
				end
			end
		end
	elseif game_state == currStage.choosebanker then
		if roomdata_center.IsOwner() then
			self.ui.readyBtnsView:SetCloseBtnVisible(true)
		end
		
	elseif  game_state == currStage.mult then
		self.ui:SetXiaoPao(ePara["nleftTime"])	----水庄玩法倒计时label
		--牌隐藏
		for i,v in pairs(playerList) do
			self.ui:SetPlayerReady(i, false)
		end	
		self.ui.readyBtnsView:SetReadyBtnVisible(false)
		for _,v in pairs(playerList) do
			v.playerObj:SetActive(false)
		end	
		local roomInfo = roomdata_center.gamesetting
		local multState = ePara.nMult
		if multState ~= -1 then
			self.ui:IsShowBeiShuiBtn(false)
		else
			if roomInfo["bSupportWaterBanker"]  then
				self.ui:IsShowBeiShuiBtn(false)
			else
				self.ui:IsShowBeiShuiBtn(true)
			end
		end
	else
		self.ui:ShowXiaoPaoPanel(false)	----水庄玩法倒计时label隐藏
		self.ui.readyBtnsView:SetReadyBtnVisible(false)
		self.ui.readyBtnsView:SetCloseBtnVisible(false)
		self.ui:SetAllPlayerReady(false)
		for _,v in pairs(playerList) do
			v.playerObj:SetActive(true)
		end
		--摆牌阶段
		if (game_state == currStage.deal or game_state == currStage.choose) then
			if stCards == nil then
				logError("重连牌为空")
				return
			end
			local stPlayerChoose = ePara.stPlayerChoose 	-- 玩家状态
			--显示是否已經擺好牌
			for i=1,#stPlayerChoose do
				local state = stPlayerChoose[i]
				local userData = room_usersdata_center.GetUserByUid(player_UID[i])
				if state ~= nil and userData ~= nil then
					local viewSeat = userData.viewSeat
					if state == 0 then --没摆
						playerList[viewSeat]:shuffle(false)
						local position = Utils.WorldPosToScreenPos(playerList[viewSeat].playerObj.transform.position)	
						self.ui:SetReadCardByState(viewSeat,true,position)
					elseif state == 1 then --已摆
						if (viewSeat == 1) then
							self.ui:IsEnableTouch(true)
							playerList[viewSeat]:SetSelfCardMesh(stCards)
							playerList[viewSeat]:ShowAllCard(180)
						else
							playerList[viewSeat]:ShowAllCard(180)	
						end
					end
				end
			end			
			--未摆牌
			local timeo = ePara.nleftTime
			if ePara.nChoose == 0 then
				
				room_data.SetPlaceCardSerTime(timeo)
				local nSpecialType = ePara.nSpecialType
				local nSpecialScore = ePara.nSpecialScore
				local recommendCards =  ePara.recommendCards
				if recommendCards ~= nil and #recommendCards > 0 then
					
				else
					recommendCards = sss_recommendHelper.GetLibRecomand():SetRecommandLaizi(stCards)
				end
					room_data.SetRecommondCard(recommendCards)
					
					card_data_manage.prepare_special_CardList = {}
					card_data_manage.isSpecial = nil
					card_data_manage.nSpecialScore = nil
					card_data_manage.prepare_recommendCards = {}
					card_data_manage.prepare_special_CardList = stCards
					card_data_manage.isSpecial = nSpecialType
					card_data_manage.nSpecialScore = nSpecialScore
					card_data_manage.prepare_recommendCards = recommendCards
				if nSpecialType ~= nil and nSpecialType > 0 then
					UI_Manager:Instance():ShowUiForms("prepare_special",UiCloseType.UiCloseType_CloseNothing,nil,stCards,nSpecialType,nSpecialScore)
				else
					UI_Manager:Instance():ShowUiForms("place_card",UiCloseType.UiCloseType_CloseNothing,nil,stCards)
				end
			--已摆牌
			elseif ePara.nChoose == 1 then
				UI_Manager:Instance():CloseUiForms("place_card")
				Trace("摆牌剩余时间:"..tostring(timeo))
				self.ui:SetPlaceCardCountDown(timeo)
			--已摆特殊牌
			elseif ePara.nChoose == 2 then
				UI_Manager:Instance():CloseUiForms("place_card")
				local data = {}
				data.SpecialType = ePara["nSpecialType"]
				data.position = Utils.WorldPosToScreenPos(playerList[1].playerObj.transform.position)
				Notifier.dispatchCmd(cmd_shisanshui.SpecialChoose_Show,data)
				self.ui.SpecialSetState = true
				self.ui:SetPlaceCardCountDown(timeo)		
			end
		end
		
		if game_state == currStage.compare then 
			UI_Manager:Instance():CloseUiForms("place_card")
			local stCompare = ePara.stCompare
			local stAllCompareData = stCompare.stAllCompareData
			for i,v in pairs(playerList) do
				v.playerObj:SetActive(true)
				v:ShowAllCard(0)
				local _, logicId = room_usersdata_center.GetUserByViewSeat(i)
				local comp_cards = stAllCompareData[logicId].stCards
				v:SetCardMesh(comp_cards)
			end
		end
	end
	self:SyncPlayerLeave(tbl._para.stPlayerNoChair)
	UI_Manager:Instance():CloseUiForms("special_card_show")
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SYNC_TABLE)
end

 function shisanshui_ui_sys:OnSyncEnd( tbl )
	Trace("重连同步结束")
	Trace(GetTblData(tbl))
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SYNC_END)
end

 function shisanshui_ui_sys:OnLeaveEnd( tbl )
	Trace("用户离开")
	self:PlayerLeave(tbl)
end

function shisanshui_ui_sys:PlayerLeave(tbl)
	if tbl._st == "nti" then
		if tbl._para.reason ~= nil then
			if tbl._para.reason == 2  and self.isReconnect == true then
				return
			end
		end
	end
	base.PlayerLeave(self,tbl)

	local logicSeat =  player_seat_mgr.GetLogicSeatByStr(tbl["_src"])
	local viewSeat = self.gvbln(logicSeat)
	self.ui:SetPlayerReady(viewSeat,false)
	
end

function shisanshui_ui_sys:SyncPlayerLeave(notEnterPlayerList)
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

 function shisanshui_ui_sys:OnPlayerOffline( tbl )
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

function shisanshui_ui_sys:OnAskChooseBanker(tbl)
	local viewSeat = self.gvbl(tbl._src)
	if viewSeat == 1 then
		self.ui:IsShowChooseBanker(true)
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_niuniu.ASK_CHOOSEBANKER)
end

function shisanshui_ui_sys:OnBanker(tbl)
	local viewSeat = self.gvbln(tbl["_para"]["banker"])
	self:SetBanker(viewSeat)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_BANKER)
end

function shisanshui_ui_sys:SetBanker(viewSeat)
	self.ui:IsShowChooseBanker(false)
	self.ui:SetBanker(viewSeat)
	roomdata_center.SetBanker(viewSeat)
end

 function shisanshui_ui_sys:OnGroupCompareResult(scoreData)
	local index = scoreData.index
	local ntotalScore = scoreData.totallScore
	local scoreStr = ""
	local scoreExtStr = ""
	local score = 0
	local scoreExt = 0
	local allScore = 0
	if tonumber(index) == 1 then
		--scoreStr = "nFirstScore"
		--scoreExtStr = "nFirstScoreExt"
		
		self.firstGroupScore = self.firstGroupScore + ntotalScore
		score = self.firstGroupScore
	elseif tonumber(index) == 2 then 
		--scoreStr = "nSecondScore"
		--scoreExtStr = "nSecondScoreExt"
		
		self.secondGroupScore = self.secondGroupScore + ntotalScore
		score = self.secondGroupScore
	elseif tonumber(index) == 3 then 
		--scoreStr = "nThirdScore"
		--scoreExtStr = "nThirdScoreExt"
		
		self.threeGroupScore = self.threeGroupScore + ntotalScore
		score = self.threeGroupScore
	end
	self.ui:SetGruopScore(index, score ,scoreExt,ntotalScore,allScore)
end

--显示每一墩牌的数据 
 function shisanshui_ui_sys:OnShowPokerCard(tbl)
	if tbl == nil then
		Trace("OnShowPokerCard....tbl == nil")
		return
	end
	local position = tbl.nguiPosition
	local index = tbl.index
	
	self:ShowCommonCard(tbl.cardTable,tbl.type, position,index)
	Trace("显示每一墩牌的数据")
end

--设置初始分零分和位置
function shisanshui_ui_sys:SetInitialScore(tbl)

	self.ui:SetGruopScore(0) 
	self.ui:SetScoreAdaptPos(tbl)
end

--打枪更新三墩分数
function shisanshui_ui_sys:SetShootScore(tbl)
	self.firstGroupScore = self.firstGroupScore + ( tbl.stSoreChange[1][2] - tbl.stSoreChange[1][1] )
	self.secondGroupScore = self.secondGroupScore + ( tbl.stSoreChange[2][2] - tbl.stSoreChange[2][1] )
	self.threeGroupScore = self.threeGroupScore + ( tbl.stSoreChange[3][2] - tbl.stSoreChange[3][1] )
	local scoreDetail = {}
	scoreDetail["firstGroupScore"] = self.firstGroupScore
	scoreDetail["secondGroupScore"] = self.secondGroupScore
	scoreDetail["threeGroupScore"] = self.threeGroupScore
	scoreDetail["firstSoreChange"]= tbl.stSoreChange[1][2] - tbl.stSoreChange[1][1]
	scoreDetail["secondSoreChange"]= tbl.stSoreChange[2][2] - tbl.stSoreChange[2][1]
	scoreDetail["thirdSoreChange"]= tbl.stSoreChange[3][2] - tbl.stSoreChange[3][1]
	Trace("打枪更新三墩分数"..GetTblData(scoreDetail))
	self.ui:SetShootScoreChange(scoreDetail)
end

--比牌码牌分数更新
function shisanshui_ui_sys:SetCodeScore(tbl)
	self.firstGroupScore = self.firstGroupScore + tbl[1]
	self.secondGroupScore = self.secondGroupScore + tbl[2]
	self.threeGroupScore = self.threeGroupScore + tbl[3]
	local scoreDetail = {}
	scoreDetail["firstGroupScore"] = self.firstGroupScore
	scoreDetail["secondGroupScore"] = self.secondGroupScore
	scoreDetail["threeGroupScore"] = self.threeGroupScore
	scoreDetail["firstSoreChange"]= tbl[1]
	scoreDetail["secondSoreChange"]= tbl[2]
	scoreDetail["thirdSoreChange"]= tbl[3]
	Trace("比牌码牌分数更新分数"..GetTblData(scoreDetail))
	self.ui:SetShootScoreChange(scoreDetail)
end

--全垒打更新三墩分数
function shisanshui_ui_sys:SetAllShootScore(tbl)
	local scoreDetail = {}
	scoreDetail["firstSoreChange"] = 0
	scoreDetail["secondSoreChange"] = 0
	scoreDetail["thirdSoreChange"] = 0
	if (tbl.selfAllShoot == true) then
		for _,v in ipairs(tbl) do
			scoreDetail["firstSoreChange"] = scoreDetail["firstSoreChange"] + (v.stSoreChange[1][4] - v.stSoreChange[1][3])
			scoreDetail["secondSoreChange"] = scoreDetail["secondSoreChange"] + (v.stSoreChange[2][4] - v.stSoreChange[2][3])
			scoreDetail["thirdSoreChange"] = scoreDetail["thirdSoreChange"] + (v.stSoreChange[3][4] - v.stSoreChange[3][3])
		end
	else
		scoreDetail["firstSoreChange"] = scoreDetail["firstSoreChange"] + (tbl.stSoreChange[1][4] - tbl.stSoreChange[1][3])
		scoreDetail["secondSoreChange"] = scoreDetail["secondSoreChange"] + (tbl.stSoreChange[2][4] - tbl.stSoreChange[2][3])
		scoreDetail["thirdSoreChange"] = scoreDetail["thirdSoreChange"] + (tbl.stSoreChange[3][4] - tbl.stSoreChange[3][3])
	end
	self.firstGroupScore = self.firstGroupScore + scoreDetail["firstSoreChange"]
	self.secondGroupScore = self.secondGroupScore + scoreDetail["secondSoreChange"]
	self.threeGroupScore = self.threeGroupScore + scoreDetail["thirdSoreChange"]
	scoreDetail["firstGroupScore"] = self.firstGroupScore
	scoreDetail["secondGroupScore"] = self.secondGroupScore
	scoreDetail["threeGroupScore"] = self.threeGroupScore
	Trace("全垒打更新三墩分数"..GetTblData(scoreDetail))
	self.ui:SetShootScoreChange(scoreDetail)
end

--显示自己的特殊牌型
function shisanshui_ui_sys:ShowSpecial(tbl)
	Trace("显示自己的特殊牌型"..GetTblData(tbl))
	self.ui:SetSelfChooseSpecial(tbl)
end

function shisanshui_ui_sys:IsShowSelfSpecial(state)
	Trace("显示自己的特殊牌型"..tostring(state))
	self.ui:IsShowSelfSpecial(state)
end

--展示大结算
function shisanshui_ui_sys:ShowLargeResult(tbl)
	if (tbl ~= nil) then
		if tbl._para ~= nil then
			local shisanshui_largeResult_data = require("logic/shisangshui_sys/large_result/shisanshui_largeResult_data"):create(tbl._para)
			UI_Manager:Instance():ShowUiForms("poker_largeResult_ui",UiCloseType.UiCloseType_CloseNothing,function() 
				Trace("Close poker_largeResult_ui")
			end,shisanshui_largeResult_data)
		else
			pokerPlaySysHelper.GetCurPlaySys().LeaveReq()
		end
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmdName.GAME_SOCKET_BIG_SETTLEMENT)
end

--
function shisanshui_ui_sys:RecommondCard(tbl)
	
	recommendCards = tbl["_para"]["recommendCards"]
	if recommendCards ~= nil and #recommendCards > 0 then
		room_data.SetRecommondCard(recommendCards)
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.Card_RECOMMEND)
end

--//////////////////////////投票 end//////////////////////////////

 function shisanshui_ui_sys:OnPointsRefresh( tbl )
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F1_POINTS_REFRESH)
end

--提示闲家选择倍数
 function shisanshui_ui_sys:OnAskMult(tbl)
	Trace("提示闲家选择倍数")
	local timeOut = tbl["timeo"]
	self.ui:SetXiaoPao(tonumber(timeOut),function()
		self.ui:IsShowBeiShuiBtn(false)
	end)
	self.ui:SetBeiShuBtnCount()
	self.ui:SetAllPlayerReady(false)
	local roomInfo = roomdata_center.gamesetting
	if roomInfo["bSupportWaterBanker"] == true then
		local bankerViewSeat = roomdata_center.zhuang_viewSeat
		if bankerViewSeat == 1 then
			self.ui:IsShowBeiShuiBtn(false)
		else
			self.ui:IsShowBeiShuiBtn(true)		
			if tonumber(roomInfo.max_multiple) == 1 then
				pokerPlaySysHelper.GetCurPlaySys().beishu(1)
				self.ui:SetXiaoPao(0)
				self.ui:IsShowBeiShuiBtn(false)
			end
		end
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.FuZhouSSS_ASKMULT)
end

--选择倍数回调
 function shisanshui_ui_sys:OnMult(tbl)
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
		self.ui:SetBeiShu(viewSeat,value)
		Trace("个人选择倍数回调，座位"..tostring(viewSeat).."倍数"..tostring(value))
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.FuZhouSSS_MULT)
end

--所有人倍数回调
 function shisanshui_ui_sys:OnAllMult(tbl)
	Trace("所有人倍数回调")
	self.ui:IsShowBeiShuiBtn(false)
	self.ui:SetXiaoPao(0)
end

--显示特殊排型图标
 function shisanshui_ui_sys:OnSpecialCardType(tbl)
	if not IsNil(self.ui.gameObject) then
		self.ui:ShowSpecialCardIcon(tbl)
	end
end

--显示理牌提示
 function shisanshui_ui_sys:OnReadCard(tbl)
	if not IsNil(self.ui.gameObject) then
		self.ui:SetReadCardState(tbl)
	end
end

function shisanshui_ui_sys:ReSetAll()
	self.firstGroupScore = 0
	self.secondGroupScore = 0
	self.threeGroupScore = 0
end

function shisanshui_ui_sys:PlaceCardCountDown(time)
	self.ui:SetPlaceCardCountDown(time)
end

function shisanshui_ui_sys:ReadyDisCountDowm(time)
	self.ui:SetReadyDisCountDowm(time)
end

function shisanshui_ui_sys:Init()

end

function shisanshui_ui_sys:UInit()

end

function shisanshui_ui_sys:ShowCommonCard(cards, nType, pos,index)
	Trace("显示普通牌型"..tostring(nType).."当前组:"..tostring(index))

	UI_Manager:Instance():ShowUiForms("common_card",UiCloseType.UiCloseType_CloseNothing,nil,cards,nType,pos,0,index)
end


return shisanshui_ui_sys

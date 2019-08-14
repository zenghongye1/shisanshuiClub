--[[--
 * @Description: 麻将UI 控制层
 * @Author:      ShushingWong
 * @FileName:    mahjong_ui_sys.lua
 * @DateTime:    2017-06-20 15:59:13
 ]]
require "logic/shisangshui_sys/shoot_ui/shoot_ui"
require "logic/shisangshui_sys/card_data_manage"
require "logic/shisangshui_sys/common_card/common_card"
require "logic/shisangshui_sys/small_result/small_result"
require "logic/shisangshui_sys/special_card_show/special_card_show"
--require "logic/shisangshui_sys/play_mode_shisangshui"
require "logic/shisangshui_sys/place_card/place_card"
--require "logic/hall_sys/openroom/room_data"
require "logic/shisangshui_sys/lib_recomand"
require "logic/gameplay/cmd_shisanshui"
shisanshui_ui_sys = class("shisanshui_ui_sys")


function shisanshui_ui_sys:ctor()
	self.gvbl = player_seat_mgr.GetViewSeatByLogicSeat
	self.gvbln = player_seat_mgr.GetViewSeatByLogicSeatNum
	self.gmls = player_seat_mgr.GetMyLogicSeat
	self.isReconnect = false
	self.result_para_data = {}
end

function shisanshui_ui_sys:OnPlayerEnter( tbl )
	Trace(GetTblData(tbl))
	local viewSeat = self.gvbl(tbl["_src"])
	local logicSeat = player_seat_mgr.GetLogicSeatByStr(tbl["_src"])
	local uid = tbl["_para"]["_uid"]
	local userdata = room_usersdata.New()
	userdata.name = tbl["_para"]["_uid"]
	userdata.uid =  tbl["_para"]["_uid"]
	userdata.coin = tbl["_para"]["score"]["coin"]
	userdata.viewSeat = viewSeat
	userdata.logicSeat = logicSeat
	userdata.vip  = 0
	if room_data.GetSssRoomDataInfo().owner_uid == uid then
		userdata.owner = true
	end
	room_usersdata_center.AddUser(logicSeat,userdata)
	shisangshui_ui.SetPlayerInfo( viewSeat, userdata)
    --加载头像
	local param={["uid"] = userdata.uid,["type"]=1}

	local nameDone = false
	local urlDone = false

	local name = hall_data.GetPlayerPrefs(uid.."name")
	local headurl = hall_data.GetPlayerPrefs(uid.."headurl")
	if name~=nil and headurl~=nil then
		userdata.name = name
		userdata.headurl = headurl
		room_usersdata_center.AddUser(logicSeat,userdata)
		shisangshui_ui.SetPlayerInfo(viewSeat, userdata)
	end

	http_request_interface.getGameInfo(param,function (str) 
		local s=string.gsub(str,"\\/","/")
        local t=ParseJsonStr(s)

        if t["data"].nickname~=name then
			userdata.name = t["data"].nickname
			hall_data.SetPlayerPrefs(uid.."name",t["data"].nickname)
		end

		nameDone = true
		if urlDone then
			room_usersdata_center.AddUser(logicSeat,userdata)
			shisangshui_ui.SetPlayerInfo(viewSeat, userdata)
		end
	end)

	http_request_interface.getImage({tbl["_para"]["_uid"]},function(str2)
		local s2=string.gsub(str2,"\\/","/")
    	local t2=ParseJsonStr(s2)
    	
    	if t2["data"][1].imageurl~=headurl then
			userdata.headurl = t2["data"][1].imageurl
			userdata.imagetype = t2["data"][1].imagetype
			hall_data.SetPlayerPrefs(uid.."headurl",t2["data"][1].imageurl)
		end

		urlDone = true
		if nameDone then
			room_usersdata_center.AddUser(logicSeat,userdata)
			shisangshui_ui.SetPlayerInfo(viewSeat, userdata)
		end
	end)
	
	Trace("----------------------------------------------------SetPlayerInfo")
	
--	shisangshui_ui.ShowDissolveRoom(false)
	local currentRoomPlayerCount = room_usersdata_center.GetRoomPlayerCount()
	if tonumber(currentRoomPlayerCount) == tonumber(room_data.GetSssRoomDataInfo().people_num) then
		shisangshui_ui.ShowInviteBtn(false) --如果进入的坐位号等于房间的人数，那么就是满员了，这时隐藏邀请按钮
	else
		shisangshui_ui.ShowInviteBtn(true)
	end
	
	shisangshui_ui.SetLeftCard()--显示房间局数
	shisangshui_ui.SetGameInfo("房号:", roomdata_center.roomnumber)
	if viewSeat < 1 then
		logError("座位出错，必须检查服务器数据！！！！！！！！！！！！！！！",viewSeat," ",tbl["_src"])
	end
	local isOwner = room_data.IsOwner()
	if isOwner == true then
		if roomdata_center.isStart == false then
			shisangshui_ui.ShowDissolveRoom(true)--显有房主可以解散房间
		end
	else
		shisangshui_ui.ShowDissolveRoom(false)
	end
	
	--是否选择加一色坐庄，如果是，显示庄的头像
	local roomInfo = room_data.GetSssRoomDataInfo()
	if roomInfo.isZhuang == true then
		if tonumber(logicSeat) == 1 then --如果是P1房主则设置庄家标志
			shisangshui_ui.SetBanker(viewSeat)
		end
	end
	Trace("OnPlayerEnter------------------"..tostring(tonumber(gmls)))
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_ENTER) 
end

function shisanshui_ui_sys:OnPlayerReady( tbl )
--	small_result.Hide()
	local logicSeat =  player_seat_mgr.GetLogicSeatByStr(tbl["_src"])
	local viewSeat = self.gvbl(tbl["_src"])
	shisangshui_ui.SetLeftCard()--显示房间局数
	if viewSeat == 1 then
		shisangshui_ui.ResetAll()
		shisangshui_ui.SetLeftCard()--显示房间局数
	end
	shisangshui_ui.SetPlayerReady(viewSeat, true)
	Trace("玩家准备好"..tostring(logicSeat))
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_READY)
end

function shisanshui_ui_sys:OnGameStart( tbl )
	shisangshui_ui.ShowInviteBtn(false)
	shisangshui_ui.ShowDissolveRoom(false)
	shisangshui_ui.IsShowBeiShuiBtn(false)
	shisangshui_ui.ShowDisTimerLab(false)
	shisangshui_ui.SetXiaoPao(0)
	roomdata_center.isStart = true
	ui_sound_mgr.PlaySoundClip("app_8/sound/common/duijukaishi")
	shisangshui_ui.ResetAll()
end

 function shisanshui_ui_sys:OnPlayStart( tbl )
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_PLAY_CARDSTART)
end

 function shisanshui_ui_sys:OnCompareStart(tbl)
	shisangshui_ui.ShowInviteBtn(false)
	shisangshui_ui.ShowDissolveRoom(false)
	shisangshui_ui.ReSetReadCard(false)
	
	coroutine.start(function ()
		 --播放比牌动画
   		shisangshui_ui.PlayerStartGameAnimation()
    	Trace("开始播放比牌动画")
    	coroutine.wait(1)
   		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.COMPARE_START)
	end)
end

 function shisanshui_ui_sys:OnGameDeal( tbl )
	shisangshui_ui.SetAllPlayerReady(false)
	shisangshui_ui.IsShowBeiShuiBtn(false)
	local  nNeedRecommend = tbl["_para"]["nNeedRecommend"] ----是否有服务端下发推荐牌型,0不需要 1需要
	if tonumber(nNeedRecommend) ==0 then
		local recommendCards = libRecomand:SetRecommandLaizi(tbl["_para"]["stCards"])
		room_data.SetRecommondCard(recommendCards)
	end
end

 function shisanshui_ui_sys:OnGameRewards( tbl )
	self.isReconnect = false
	Trace(GetTblData(tbl))
	shisangshui_ui.DisablePlayerLightFrame()--关闭头像的光圈
	Trace("结算。。。。t")
	if tbl ~= nil and tbl._para ~= nil then
		self.result_para_data.data = tbl._para
		small_result.Show(tbl)
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
			--	Trace("总分： "..tostring(score))
				if score == nil then score = 0 end
				shisangshui_ui.SetPlayerScore(viewSeat, tonumber(score))
		--		Trace("座位号:"..tostring(viewSeat).." 总积分:"..tostring(score))
			end
		end
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SMALL_SETTLEMENT) --确认完成结算完成消息
end

 function shisanshui_ui_sys:OnGameBigRewards( tbl )
	if tbl == nil or tbl.rid == nil then
		large_result.Show()
	else
		large_result.Show()
	end
end

 function shisanshui_ui_sys:OnAskReady( tbl )
	local timeo = tbl.timeo
	local timeEnd = timeo
	Trace("等待举手, 时间："..tostring(timeo).."  结束时间： "..tostring(timeEnd))
	if small_result.gameObject ~= nil then
		small_result.SetTimerStart(timeEnd - tbl.time)
	else
		room_data.SetReadyTime(timeEnd - tbl.time)
		if(self.isReconnect == true and timeEnd ~= -1 ) then 
			shisangshui_ui.dismissLeftime(timeEnd)
		end
	end
	shisangshui_ui.ShowReadyBtn()
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_ASK_READY)
end

 function shisanshui_ui_sys:OnSyncBegin( tbl )
	Trace("重连同步开始")
	self.isReconnect = true
	shisangshui_ui.ResetAll()
	if shisangshui_ui.voteView ~= nil then
		shisangshui_ui.voteView:Hide()
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SYNC_BEGIN)
end

--重连同步
 function shisanshui_ui_sys:OnSyncTable( tbl )
	Trace("重连同步表")
	--[[
		self.m_stageNext = {
            prepare     = "mult",       --加倍
            mult        = "deal",       --发牌
            deal        = "choose",     --出牌(选择牌型)
            choose      = "compare",    --比牌
            compare     = "reward",     --结算
            reward      = "gameend",    --游戏结算
            gameend     = "prepare",    --下一局
        }
    else
        self.m_stageNext = {
            prepare     = "deal",       --发牌
            deal        = "choose",     --出牌(选择牌型)
            choose      = "compare",    --比牌
            compare     = "reward",     --结算
            reward      = "gameend",    --游戏结算
            gameend     = "prepare",    --下一局
        }
	]]
	local ePara = tbl._para
	local game_state = ePara.sCurrStage 		-- 游戏阶段
	local player_state = ePara.stPlayerState 	-- 玩家状态
	local player_UID = ePara.stPlayerUid 	-- 玩家状态
	
	local play_mshisangshui = require ("logic.shisangshui_sys.cmd_manage.shisanshui_msg_manage"):GetInstance():GetPlayModeShiSanShuiInstance()
	local tableCtl = play_mshisangshui:GetTabComponent()
	local playerList = tableCtl.PlayerList
	
	local stCards = ePara.stCards
	roomdata_center.isStart = true

	shisangshui_ui.ShowDissolveRoom(false)
	small_result.Hide()
	place_card.Hide()
	if game_state == "prepare" then  
		--牌隐藏
		for i = 1, #playerList do
			playerList[i].playerObj:SetActive(false)
		end		--准备阶段
		--标记不用投票可直接退出
		if roomdata_center.nCurrJu <= 1 then
			roomdata_center.isStart = false
			if room_data.IsOwner() then
				shisangshui_ui.ShowDissolveRoom(true)
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
					shisangshui_ui.SetPlayerReady(viewSeat, true)
					if viewSeat == 1 then
						shisangshui_ui.HideReadyBtn()
					end
				elseif state == 1 then
					shisangshui_ui.SetPlayerReady(viewSeat, false)
					if viewSeat == 1 then
						shisangshui_ui.ShowReadyBtn()
					end
				end
			end
		end
	elseif  game_state == "mult" then
		--牌隐藏
		for i = 1, #playerList do
			shisangshui_ui.SetPlayerReady(i, true)
		end	
		shisangshui_ui.HideReadyBtn()
		for i = 1, #playerList do
			playerList[i].playerObj:SetActive(false)
		end	
		local roomInfo = room_data.GetSssRoomDataInfo()
		local multState = ePara.nMult
		if multState ~= -1 then
			shisangshui_ui.IsShowBeiShuiBtn(false)
		else
			if roomInfo.isZhuang  then
				shisangshui_ui.IsShowBeiShuiBtn(false)
			else
				shisangshui_ui.IsShowBeiShuiBtn(true)
			end
		end
	else
		shisangshui_ui.HideReadyBtn()
		shisangshui_ui.ShowDissolveRoom(false)
		shisangshui_ui.SetAllPlayerReady(false)
		for i = 1, #playerList do
			playerList[i].playerObj:SetActive(true)
		end
		--摆牌阶段
		if (game_state == "deal" or game_state == "choose") then
			if stCards == nil then
				Trace("重连牌为空")
				return
			end
			local stPlayerChoose = ePara.stPlayerChoose 	-- 玩家状态
			--显示是否已經擺好牌
			for i=1,#stPlayerChoose do
				local state = stPlayerChoose[i]
				local userData = room_usersdata_center.GetUserByUid(player_UID[i])
				if state ~= nil and userData ~= nil then
					local viewSeat = userData.viewSeat
					--local _, logicId = room_usersdata_center.GetUserByViewSeat(i)
					if state == 0 then --没摆
						playerList[viewSeat]:shuffle()
						local position = Utils.WorldPosToScreenPos(playerList[viewSeat].playerObj.transform.position)	
						shisangshui_ui.SetReadCardByState(viewSeat,true,position)
					elseif state == 1 then --已摆
						playerList[viewSeat].ShowAllCard(180)
					end
				end
			end			
			--未摆牌
			if ePara.nChoose == 0 then
				local timeo = ePara.nleftTime
				room_data.SetPlaceCardSerTime(timeo)
				local nSpecialType = ePara.nSpecialType
				local recommendCards =  ePara.recommendCards
				if recommendCards ~= nil and #recommendCards > 0 then
					
				else
					recommendCards = libRecomand:SetRecommandLaizi(stCards)
				end
					room_data.SetRecommondCard(recommendCards)
				if nSpecialType ~= nil and nSpecialType > 0 then
					prepare_special.Show(stCards, nSpecialType, 3, recommendCards)
				else
					place_card.Show(stCards)
				end
			--已摆牌
			elseif ePara.nChoose == 1 or  ePara.nChoose == 2 then
				place_card.Hide()
			end
		end
		if game_state == "compare" then 
			place_card.Hide()
			for i = 1, #playerList do
				playerList[i].playerObj:SetActive(true)
			end
			local stCompare = ePara.stCompare
			local stAllCompareData = stCompare.stAllCompareData
			for i = 1, #playerList do
				playerList[i].ShowAllCard(0)
				local _, logicId = room_usersdata_center.GetUserByViewSeat(i)
				local comp_cards = stAllCompareData[i].stCards
				playerList[logicId]:SetCardMesh(comp_cards)
			end
		end
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SYNC_TABLE)
end

 function shisanshui_ui_sys:OnSyncEnd( tbl )
	Trace("重连同步结束")
	Trace(GetTblData(tbl))
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SYNC_END)
end

 function shisanshui_ui_sys:OnLeaveEnd( tbl )
	Trace("用户离开")
	if tbl._st == "nti" then
		if tbl._para.reason ~= nil then
			if tbl._para.reason == 2  and self.isReconnect == true then
				large_result.Show()
				return
			end
		end
	end
	
	local viewSeat = self.gvbl(tbl._src)
	shisangshui_ui.HidePlayer(viewSeat)
	local logicSeat =  player_seat_mgr.GetLogicSeatByStr(tbl["_src"])
	local viewSeat = self.gvbln(logicSeat)
	shisangshui_ui.SetPlayerReady(viewSeat,false)
	room_usersdata_center.RemoveUser(logicSeat)
	local sessionData = player_data.GetSessionData()
	if tonumber(tbl._para._chair) == tonumber(sessionData["_chair"]) then
		room_usersdata_center.RemoveAll()
	end
	local currentRoomPeopleCount = room_usersdata_center.GetRoomPlayerCount()
	local roomMaxPeopleCount = room_data.GetSssRoomDataInfo().people_num
	if tonumber(currentRoomPeopleCount) < tonumber(roomMaxPeopleCount) then
		shisangshui_ui.ShowInviteBtn(true)
	else
		shisangshui_ui.ShowInviteBtn(false)
	end
end

 function shisanshui_ui_sys:OnPlayerOffline( tbl )
	Trace(GetTblData(tbl))
	local viewSeat = self.gvbl(tbl._src)
	if  tbl._para.active == nil  then
		if  roomdata_center.isStart == true then
		else
			shisangshui_ui.HidePlayer(viewSeat)
		end
	elseif  tbl._para.active ~= nil and tbl._para.active == 1 then
		shisangshui_ui.SetPlayerLineState(viewSeat, false)
	elseif tbl._para.active ~= nil and tbl._para.active == 0 then
		shisangshui_ui.SetPlayerLineState(viewSeat, true)
	else
		shisangshui_ui.SetPlayerLineState(viewSeat, false)
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_OFFLINE)
end

 function shisanshui_ui_sys:OnGroupCompareResult(scoreData)
	local index = scoreData.index
	local ntotalScore = scoreData.totallScore
	Trace("+++++++++++++++++++OnGroupCompareResult+++++++++"..tostring(index))
	local scoreStr = ""
	local scoreExtStr = ""
	local score = 0
	local scoreExt = 0
	local allScore = 0
	if tonumber(index) == 1 then
		scoreStr = "nFirstScore"
		scoreExtStr = "nFirstScoreExt"
	elseif tonumber(index) == 2 then 
		scoreStr = "nSecondScore"
		scoreExtStr = "nSecondScoreExt"
	elseif tonumber(index) == 3 then 
		scoreStr = "nThirdScore"
		scoreExtStr = "nThirdScoreExt"
	end
	local compareScores = card_data_manage.compareResultPara["stCompareScores"]
	if compareScores ~= nil then
		for i,v in ipairs(compareScores) do
			if scoreStr ~= "" and scoreExtStr ~= "" then 
				score = score + v[scoreStr]
				scoreExt = scoreExt + v[scoreExtStr]
			end
		end
		
		Trace("++++++++++compareScores"..tostring(score).."+++++"..tostring(scoreExt))
		shisangshui_ui.SetGruopScord(index, score ,scoreExt,allScore)
	end
	
	if tonumber(index) == 4 then
		if ntotalScore ~= nil then
			shisangshui_ui.SetGruopScord(index, score ,scoreExt,ntotalScore)
		end
	end
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

--//////////////////////////投票 start////////////////////////////

 function shisanshui_ui_sys:OnVoteDraw(tbl)
	local viewSeat = self.gvbl(tbl["_src"])
	--[[local st = tbl["_st"]
	if tostring(st) == "err" then
		local errno = tbl["_para"]["_errno"]
		if tonumber(errno) == 5001 then
			--请求次数太过多
			fast_tip.Show("解散功能时间冷却中，请稍后再试.")
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_NIT_VOTE_DRAW)
			return
		end
	end--]]
	vote_quit_ui.AddVote(tbl._para.accept, viewSeat)
	shisangshui_ui.voteView:AddVote(tbl._para.accept, viewSeat)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_NIT_VOTE_DRAW)
end

 function shisanshui_ui_sys:OnVoteStart(tbl)
	Trace("OnVoteStart~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	local viewSeat = self.gvbln(tbl["_para"].who)
	if viewSeat == 1 then
		roomdata_center.isSelfVote = true
	end
	local time = tbl._para.timeout
	local name = room_usersdata_center.GetUserByViewSeat(viewSeat).name
	if viewSeat ~= 1 then
		vote_quit_ui.Show(name, function(value) if value == true then
			end
			shisangshui_play_sys.VoteDrawReq(value)
		 end, roomdata_center.MaxPlayer(), time)
	end
	shisangshui_ui.voteView:Show(roomdata_center.MaxPlayer())
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_VOTE_DRAW_START)
end

 function shisanshui_ui_sys:OnVoteEnd(tbl)
	local confirm = tbl._para.confirm
	if confirm == false and roomdata_center.isSelfVote == true then
		message_box.ShowGoldBox(GetDictString(6048),  {function() message_box.Close() end},
		{"fonts_01"})
	end
	roomdata_center.isSelfVote = false

	vote_quit_ui.Hide()
	shisangshui_ui.voteView:Hide()
	--true: 协商和局成立； false:协商和局失败或超时
	if tbl["_para"]["confirm"] == true then
	
	end
	
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_VOTE_DRAW_END)
end

--更新玩家积分
 function shisanshui_ui_sys:RoomSumScore(tbl)
	Trace("更新玩家积分")
	local _para = tbl._para
	
	local viewSeat = self.gvbl(tbl["_src"])
	local score = _para["nRoomSumScore"]
	--local viewSeat = _para["_chair"]
	print("总分： "..tostring(score))
	if score == nil then score = 0 end
	shisangshui_ui.AddPlayerScore(viewSeat, tonumber(score))
	Trace("座位号:"..tostring(viewSeat).." 总积分:"..tostring(score))
	
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.ROOM_SUM_SCORE)
end
--
 function shisanshui_ui_sys:RecommondCard(tbl)
	
	player_component.CardList = tbl["_para"]["stCards"]
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

--聊天
 function shisanshui_ui_sys:OnPlayerChat( tbl )
	local viewSeat = self.gvbl(tbl._src)
	local contentType = tbl["_para"]["contenttype"]
	local content = tbl["_para"]["content"]
	local givewho = self.gvbl(tbl["_para"]["givewho"])

	if roomdata_center.isStart == true then		
	else		
	end
	chat_ui.DealChat(viewSeat,contentType,content,givewho)
--	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_CHAT)
end

--提示闲家选择倍数
 function shisanshui_ui_sys:OnAskMult(tbl)
	Trace("提示闲家选择倍数")
	local timeOut = tbl["timeo"]
	shisangshui_ui.SetXiaoPao(tonumber(timeOut),function()
		shisangshui_ui.IsShowBeiShuiBtn(false)
	end)
	shisangshui_ui.SetBeiShuBtnCount()
	shisangshui_ui.SetAllPlayerReady(false)
	local roomInfo = room_data.GetSssRoomDataInfo()
	if roomInfo.isZhuang == true then
		sessionData = player_data.GetSessionData()
		if tonumber(sessionData["_chair"]) == 1 then
			shisangshui_ui.IsShowBeiShuiBtn(false)
		else
			shisangshui_ui.IsShowBeiShuiBtn(true)
			
			if tonumber(roomInfo.max_multiple) == 1 then
				shisangshui_play_sys.beishu(1)
				shisangshui_ui.SetXiaoPao(0)
				shisangshui_ui.IsShowBeiShuiBtn(false)
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
		shisangshui_ui.SetBeiShu(viewSeat,value)
		Trace("个人选择倍数回调，座位"..tostring(viewSeat).."倍数"..tostring(value))
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.FuZhouSSS_MULT)
end

--所有人倍数回调
 function shisanshui_ui_sys:OnAllMult(tbl)
	Trace("所有人倍数回调")
	shisangshui_ui.IsShowBeiShuiBtn(false)
	shisangshui_ui.SetXiaoPao(0)
end

--显示特殊排型图标
 function shisanshui_ui_sys:OnSpecialCardType(tbl)
	shisangshui_ui.ShowSpecialCardIcon(tbl)
end

--显示理牌提示
 function shisanshui_ui_sys:OnReadCard(tbl)
	shisangshui_ui.SetReadCardState(tbl)
end

function shisanshui_ui_sys:EarlySettlement(tbl)
	Trace("管理员强制提前进行游戏结算")
	fast_tip.Show("本房间已被管理员解散，牌局即将结束")
	place_card.Hide()
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MSG_EARLY_SETTLEMENT)
end

function shisanshui_ui_sys:FreezeUser(tbl)
	Trace("管理员封号")
	message_box.Close()
	game_scene.gotoLogin()
    game_scene.GoToLoginHandle()
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MSG_FREEZE_USER)
end

function shisanshui_ui_sys:FreezeOwner(tbl)
	Trace("管理员封号")
	message_box.Close()
	game_scene.gotoLogin()
    game_scene.GoToLoginHandle()
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MSG_FREEZE_OWNER)
end

function shisanshui_ui_sys:Init()

end

function shisanshui_ui_sys:UInit()

end

---------------缓存头像到本地-----------------
function shisanshui_ui_sys:GetHeadPic(textureComp, url )
	Trace("GetHeadPic "..url)

	DownloadCachesMgr.Instance:LoadImage(url,function( code,texture )
		--Trace("!!!!!!!!!state:"..tostring(state))
		textureComp.mainTexture = texture 
	end)
end

--打枪
function ShootingPlayerList(player_list)

end

function shisanshui_ui_sys:ShowShootKuang(tran, callback)
	animations_sys.PlayAnimation(tran,"shisanshui_shoot_kuang","bomb box",100,100,false,callback,1401)
end

function shisanshui_ui_sys:ShowShoot(tran, callback)
	animations_sys.PlayAnimation(tran,"shisanshui_shoot","Shoot",100,100,false, callback,1401)
end

function shisanshui_ui_sys:ShowShootHole(tran, callback)
	animations_sys.PlayAnimation(tran,"shisanshui_shoot","Shoot2",100,100,false, callback,1401)
end

function shisanshui_ui_sys:ShowCommonCard(cards, nSpecitialType, pos,index)
	--判断对鬼冲三
	if tonumber(index) == 1 then
		local count  = 0
		for i,v in pairs(cards) do
			Trace("首墩牌值:"..tostring(v))
			if tonumber(v) == 79 or tonumber(v) == 95 then
				count = count + 1
			end
		end
		if tonumber(count) == 2 then
			nSpecitialType = 13
		end
	end
	Trace("显示普通牌型"..tostring(nSpecitialType).."当前组:"..tostring(index))

	common_card.Show(cards, nSpecitialType, pos,0,index)

end

function shisanshui_ui_sys:getuserimage(tx,itype,iurl)
    itype=itype or data_center.GetLoginUserInfo().imagetype
    iurl=iurl or data_center.GetLoginUserInfo().imageurl
    local imagetype=itype
    local imageurl=iurl
    if  tonumber(imagetype)~=2 then
        imageurl="https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=190291064,674331088&fm=58"  
    end
    http_request_interface.getimage(imageurl,tx.width,tx.height,function (states,tex)tx.mainTexture=tex end)
end

return shisanshui_ui_sys

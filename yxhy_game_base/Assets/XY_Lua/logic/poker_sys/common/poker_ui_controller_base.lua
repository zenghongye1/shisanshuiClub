--[[--
 * @Description: 扑克通用UI_Controller基类
 * @Author:      ZWX
 * @FileName:    poker_ui_controller_base.lua
 * @DateTime:    20180410
 ]]
local poker_ui_controller_base = class("poker_ui_controller_base")

function poker_ui_controller_base:ctor()
	self:InitDataAndUIMgr()
end

function poker_ui_controller_base:InitDataAndUIMgr()
end

function poker_ui_controller_base:InitTableComponent()
end


function poker_ui_controller_base:OnPlayerEnter(tbl)
	Trace("OnPlayerEnter-------"..GetTblData(tbl))
	-- if self.tableComponent == nil then
	-- 	self.tableComponent = require("logic.niuniu_sys.cmd_manage.niuniu_msg_manage"):GetInstance():GetNiuNiuSceneControllerInstance().tableComponent
	-- end
	self:InitTableComponent()
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
	userdata.saved = tbl["_para"]["saved"]
	if self.data_manage ~= nil then
		if self.data_manage.roomInfo.owner_uid == uid then
			userdata.owner = true
		end
	else
		-- 兼容十三水
		userdata.owner = roomdata_center.ownerId == uid
	end
	
	room_usersdata_center.AddUser(logicSeat,userdata)
	self.ui:SetPlayerInfo( viewSeat, userdata)
    --加载头像
	local param={["uid"] = userdata.uid,["type"]=1}

	local name = hall_data.GetPlayerPrefs(uid.."name")
	local headurl = hall_data.GetPlayerPrefs(uid.."headurl")
	if name ~= nil and headurl ~= nil then
		userdata.name = name
		userdata.headurl = headurl
		room_usersdata_center.AddUser(logicSeat,userdata)
		self.ui:SetPlayerInfo(viewSeat, userdata)
	end

	HttpProxy.GetGameInfo(param, function(info) 
		 if info.nickname~=name then
			userdata.name = info.nickname
			hall_data.SetPlayerPrefs(uid.."name",info.nickname)
		end
		if info.imageurl~=headurl then
			userdata.headurl = info.imageurl
			hall_data.SetPlayerPrefs(uid.."headurl",info.imageurl)
		end
		if info.imagetype~=imagetype then
			userdata.imagetype = info.imagetype
			hall_data.SetPlayerPrefs(uid.."imagetype",info.imagetype)
		end
		room_usersdata_center.AddUser(logicSeat,userdata)
		self.ui:SetPlayerInfo(viewSeat, userdata)
	end)	

	Trace("----------------------------------------------------SetPlayerInfo")
	
	local currentRoomPlayerCount = room_usersdata_center.GetRoomPlayerCount()
	local maxCount, isOwner
	if self.data_manage == nil then
		maxCount = tonumber(roomdata_center.maxplayernum)
		isOwner = roomdata_center.IsOwner()
	else
		maxCount = tonumber(self.data_manage.roomInfo.nPlayerNum)
		isOwner = self.data_manage:IsOwner()
	end
	if roomdata_center.isRoundStart then
		self.ui.readyBtnsView:SetInviteBtnVisible(false) --如果进入的坐位号等于房间的人数，那么就是满员了，这时隐藏邀请按钮
	else
		if tonumber(currentRoomPlayerCount) == maxCount then
			self.ui.readyBtnsView:SetInviteBtnVisible(false)
		else
			self.ui.readyBtnsView:SetInviteBtnVisible(true)
		end		
	end
	self.ui:SetGameNum()--显示房间局数
	if viewSeat < 1 then
		logError("座位出错，必须检查服务器数据！！！！！！！！！！！！！！！",viewSeat," ",tbl["_src"])
	end
	if isOwner == true then
		if roomdata_center.isStart == false then
			self.ui.readyBtnsView:SetCloseBtnVisible(true)--显有房主可以解散房间
		end
	else
		self.ui.readyBtnsView:SetCloseBtnVisible(false)
	end
	Trace("OnPlayerEnter------------------"..tostring(tonumber(gmls)))
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_ENTER) 

	self:CheckMidJoinState(viewSeat)
end

function poker_ui_controller_base:CheckMidJoinState(viewSeat)
	if roomdata_center.midJoinData:CheckPlayerIsMidJoin(viewSeat) then
		self.ui:CallPlayer(viewSeat, "ShowHeadMask")
	end
end

function poker_ui_controller_base:OnPlayerReady()
	if self.data_manage == nil then
		logError("self.data_manage is nil")
	end
	tbl = self.data_manage.ReadyData
	local viewSeat = self.gvbl(tbl["_src"])
	if viewSeat == 1 then
		self:ReSetAll()
		self.ui:HideDisMissCountDown()
	else
		self.ui:ResetPlayerByViewSeate(viewSeat)
	end
--	self.ui:SetPlayerReady(viewSeat, true)
	self.ui:SetState(viewSeat,true,niuniu_rule_define.SUB_BULL_STATE.SUB_BULL_STATE_YIZHUNBEI,self.tableComponent)
	Trace("玩家准备好"..tostring(viewSeat))
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_READY)
end


function poker_ui_controller_base:OnGameStart(tbl)
	local viewSeat = self.gvbl(tbl["_src"])
	roomdata_center.isRoundStart = true
	roomdata_center.midJoinData:CreateViewSeatJoinMap(tbl["_para"]["stPlayerMidJoin"])
	if not roomdata_center.midJoinData:CheckPlayerIsMidJoin(viewSeat) then
		roomdata_center.isStart = true
		self.ui:HideMidJoinTip()
	end
	self.ui:SetMidJoinState()
end

--更新玩家积分
 function poker_ui_controller_base:RoomSumScore(tbl)
	local viewSeat = self.gvbl(tbl["_src"])
	local score = tbl["_para"]["nRoomSumScore"] or 0
	self.ui:AddPlayerScore(viewSeat, tonumber(score))
	Trace("更新玩家积分座位号:"..tostring(viewSeat).." 总积分:"..tostring(score))
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmd_poker.room_sum_score)
end

--聊天
 function poker_ui_controller_base:OnPlayerChat(tbl)
	local viewSeat = self.gvbl(tbl._src)
	local contentType = tbl["_para"]["contenttype"]
	local content = tbl["_para"]["content"]
	local givewho = self.gvbl(tbl["_para"]["givewho"])

	if roomdata_center.isStart == true then
	else		
	end
	model_manager:GetModel("ChatModel"):DealChat(viewSeat,contentType,content,givewho)
end
--------------------------- Dissolution 投票 end ------------------------------
function poker_ui_controller_base:OnVoteDraw(tbl)
	local viewSeat = self.gvbl(tbl["_src"])
	local logicSeatNum = player_seat_mgr.GetLogicSeatByStr(tbl["_src"])
	local logicSeatIndex = room_usersdata_center.GetLogicSeatIndex(logicSeatNum)
	Notifier.dispatchCmd(GameEvent.OnAddVote,tbl["_para"]["accept"],viewSeat)
	self.ui.voteView:AddVote(tbl["_para"]["accept"], logicSeatIndex)
	if viewSeat == 1 and tbl["_para"]["accept"] then
		UI_Manager:Instance():CloseUiForms("VoteQuitUI")
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_NIT_VOTE_DRAW)
end

 function poker_ui_controller_base:OnVoteStart(tbl)
	Trace("OnVoteStart~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	local viewSeat = self.gvbln(tbl["_para"]["who"])
	if viewSeat == 1 then
		roomdata_center.isSelfVote = true
	end
	local time = tbl["_para"]["timeout"]
	local name = room_usersdata_center.GetUserByViewSeat(viewSeat).name
	if viewSeat ~= 1 then
		UI_Manager:Instance():ShowUiForms("VoteQuitUI", nil, nil, name,function(value)
			pokerPlaySysHelper.GetCurPlaySys().VoteDrawReq(value) 
		end, time)
	end
	self.ui.voteView:Show(room_usersdata_center.GetRoomPlayerCount(),time)
	
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_VOTE_DRAW_START)
end

 function poker_ui_controller_base:OnVoteEnd(tbl)
	local confirm = tbl["_para"]["confirm"]
	if not confirm and roomdata_center.isSelfVote == true then
		MessageBox.ShowSingleBox(LanguageMgr.GetWord(6048))
	end
	roomdata_center.isSelfVote = false
	UI_Manager:Instance():CloseUiForms("VoteQuitUI")
	self.ui.voteView:Hide()
	if tbl["_para"]["confirm"] == true then
		--true: 协商和局成立； false:协商和局失败或超时
	end

	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_VOTE_DRAW_END)
end

--//////////////////////////投票 start////////////////////////////
 function poker_ui_controller_base:OnPlayerCanVoteStart(tbl)
 	local bShowStart = tbl._para.bShowStart
 	if bShowStart then
 		self.ui.readyBtnsView:SetApplyPlayBtnVisible(true)
 	else
 		self.ui.readyBtnsView:SetApplyPlayBtnVisible(false)
 	end
 	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_VOTE_START_SHOW)
end

 function poker_ui_controller_base:OnVoteStartPlay(tbl)
	local viewSeat = self.gvbln(tbl["_para"].who)
	--vote_quit_ui.AddVote(tbl._para.accept, viewSeat)
	local logicSeatIndex = room_usersdata_center.GetLogicSeatIndex(tbl["_para"].who)
	Notifier.dispatchCmd(GameEvent.OnAddVote, tbl._para.bStatus == 1, viewSeat)
	self.ui.voteView:AddVote(tbl._para.bStatus == 1, logicSeatIndex)
	if viewSeat == 1 and tbl._para.bStatus == 1 then
		UI_Manager:Instance():CloseUiForms("VoteQuitUI")
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_VOTE_START)
end

 function poker_ui_controller_base:OnVoteStartPlayStartflag(tbl)
	Trace("OnVoteStart~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	local viewSeat = self.gvbln(tbl["_para"].who)
	local nActiveNum = tbl["_para"].nActiveNum
	if viewSeat == 1 then
		roomdata_center.isSelfVote = true
	end
	local time = tbl.timeo
	local name = room_usersdata_center.GetUserByViewSeat(viewSeat).name
	if viewSeat ~= 1 then
		UI_Manager:Instance():ShowUiForms("VoteQuitUI", nil, nil, name, 
			function(value)	pokerPlaySysHelper.GetCurPlaySys().ApplyForReq((value and 1) or 0) end, time,true)
	end
	self.ui.voteView:Show(nActiveNum,time)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_VOTE_STARTFLAG)
end

 function poker_ui_controller_base:OnVoteStartPlayResult(tbl)
	local bResult = tbl._para.bResult
	
	local viewSeat = self.gvbln(tbl["_para"].who)
	if bResult == false and viewSeat~=1 then
		local name = room_usersdata_center.GetUserByViewSeat(viewSeat).name
		UIManager:FastTip("【"..name.."】拒绝开始游戏")
	end
	roomdata_center.isSelfVote = false

	UI_Manager:Instance():CloseUiForms("VoteQuitUI")
	self.ui.voteView:Hide()
	--true: 协商和局成立； false:协商和局失败或超时
	if tbl["_para"]["bResult"] == true then
	
	end
	
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_VOTE_RESULT)
end

 function poker_ui_controller_base:OnVoteStartPlayStop(tbl)
	local whoenter = tbl._para.whoenter

	MessageBox.ShowSingleBox("有新玩家加入/退出，请重新发起申请！")
	roomdata_center.isSelfVote = false

	UI_Manager:Instance():CloseUiForms("VoteQuitUI")
	self.ui.voteView:Hide()
	
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_VOTE_STOP)
end

function poker_ui_controller_base:OnReadyCountTimer(tbl)
	local timeout = tbl._para.timeout
	self.ui:SetCountDown(timeout)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_READY_COUNT_TIMER)
end


function poker_ui_controller_base:PlayerLeave(tbl)
	local viewSeat = self.gvbl(tbl._src)
	self.ui:HidePlayer(viewSeat)
	local logicSeat =  player_seat_mgr.GetLogicSeatByStr(tbl["_src"])
	room_usersdata_center.RemoveUser(logicSeat)
	local sessionData = player_data.GetSessionData()
	if tonumber(tbl._para._chair) == tonumber(sessionData["_chair"]) then
		room_usersdata_center.RemoveAll()
	end
	local currentRoomPeopleCount = room_usersdata_center.GetRoomPlayerCount()
	local roomMaxPeopleCount = roomdata_center.maxplayernum
	if roomdata_center.isRoundStart then
		self.ui.readyBtnsView:SetInviteBtnVisible(false)
	else
		if tonumber(currentRoomPeopleCount) == roomMaxPeopleCount then
			self.ui.readyBtnsView:SetInviteBtnVisible(false)
		else
			self.ui.readyBtnsView:SetInviteBtnVisible(true)
		end		
	end
	self.ui:IsShowCountDownSlider(false)
end

function poker_ui_controller_base:OnMidJoin(tbl)
	local logicSeat = tbl._para.who
	local viewSeat = self.gvbln(logicSeat)
	roomdata_center.midJoinData:CreateViewSeatJoinMap(tbl["_para"]["stPlayerMidJoin"])
	if viewSeat == 1 then
		self.ui:ShowMidJoinTip("游戏正在进行，请等待本局游戏结束\n准备后将加入下一局游戏")
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_poker.MID_JOIN)
end


function poker_ui_controller_base:EarlySettlement(tbl)
	Trace("会长强制解散房间提前进行游戏结算")
	local clubInfo = model_manager:GetModel("ClubModel").clubMap[roomdata_center.roomCid]
	MessageBox.ShowSingleBox(LanguageMgr.GetWord(9005, clubInfo.nickname))
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MSG_EARLY_SETTLEMENT)
end

function poker_ui_controller_base:FreezeUser(tbl)
	Trace("管理员封号")
	UI_Manager:Instance():CloseUiForms("message_box")
	game_scene.gotoLogin()
    game_scene.GoToLoginHandle()
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MSG_FREEZE_USER)
end

function poker_ui_controller_base:FreezeOwner(tbl)
	Trace("管理员封号")
	UI_Manager:Instance():CloseUiForms("message_box")
	game_scene.gotoLogin()
    game_scene.GoToLoginHandle()
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MSG_FREEZE_OWNER)
end

return poker_ui_controller_base
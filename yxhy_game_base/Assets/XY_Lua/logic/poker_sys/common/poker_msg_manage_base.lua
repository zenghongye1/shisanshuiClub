local poker_msg_manage_base = class("poker_msg_manage_base")

function poker_msg_manage_base:ctor()
	
end

function poker_msg_manage_base:Initialize()
	Notifier.regist(cmdName.GAME_SOCKET_GAMESTART, slot(self.OnGameStart,self))					--游戏开始
	Notifier.regist(cmdName.GAME_SOCKET_CHAT, slot(self.OnPlayerChat,self))						--用户聊天
	Notifier.regist(cmdName.GAME_NIT_VOTE_DRAW,  slot(self.OnVoteDraw,self))					--请求和局/投票
	Notifier.regist(cmdName.GAME_VOTE_DRAW_START, slot(self.OnVoteStart,self))					--请求和局开始
	Notifier.regist(cmdName.GAME_VOTE_DRAW_END,  slot(self.OnVoteEnd,self))						--请求和局结束	
	Notifier.regist(cmdName.GAME_VOTE_START_SHOW,  slot(self.OnPlayerCanVoteStart,self))		-- 显示请求开始按钮
	Notifier.regist(cmdName.GAME_VOTE_STARTFLAG,  slot(self.OnVoteStartPlayStartflag,self))		-- 投票开始命令
	Notifier.regist(cmdName.GAME_VOTE_START,  slot(self.OnVoteStartPlay,self))					-- 游戏开始 投票
	Notifier.regist(cmdName.GAME_VOTE_RESULT,  slot(self.OnVoteStartPlayResult,self))			-- 手动开始投票结果
	Notifier.regist(cmdName.GAME_VOTE_STOP,  slot(self.OnVoteStartPlayStop,self))				-- 投票过程中有人进来,终止投票
	Notifier.regist(cmdName.GAME_READY_COUNT_TIMER, slot(self.OnReadyCountTimer,self))			-- 人满弹准备倒计时
	Notifier.regist(cmdName.GAME_SOCKET_PLAYER_LEAVE, slot(self.OnUserLeave,self))				--游戏结束离开通知
	Notifier.regist(cmdName.F3_START_FLAG, slot(self.OnStartFlag,self))							-- 游戏是否开始标记
	
	Notifier.regist(cmd_poker.room_sum_score,slot(self.RoomSumScore,self))						--更新总积分
end

function poker_msg_manage_base:Uninitialize()
	Notifier.remove(cmdName.GAME_SOCKET_GAMESTART, slot(self.OnGameStart,self))					--游戏开始
	Notifier.remove(cmdName.GAME_SOCKET_CHAT, slot(self.OnPlayerChat,self))						--用户聊天
	Notifier.remove(cmdName.GAME_NIT_VOTE_DRAW,  slot(self.OnVoteDraw,self))					--请求和局/投票
	Notifier.remove(cmdName.GAME_VOTE_DRAW_START, slot(self.OnVoteStart,self))					--请求和局开始
	Notifier.remove(cmdName.GAME_VOTE_DRAW_END,  slot(self.OnVoteEnd,self))						--请求和局结束	
	Notifier.remove(cmdName.GAME_VOTE_START_SHOW,  slot(self.OnPlayerCanVoteStart,self))		-- 显示请求开始按钮
	Notifier.remove(cmdName.GAME_VOTE_STARTFLAG,  slot(self.OnVoteStartPlayStartflag,self))		-- 投票开始命令
	Notifier.remove(cmdName.GAME_VOTE_START,  slot(self.OnVoteStartPlay,self))					-- 游戏开始 投票
	Notifier.remove(cmdName.GAME_VOTE_RESULT,  slot(self.OnVoteStartPlayResult,self))			-- 手动开始投票结果
	Notifier.remove(cmdName.GAME_VOTE_STOP,  slot(self.OnVoteStartPlayStop,self))				-- 投票过程中有人进来,终止投票
	Notifier.remove(cmdName.GAME_READY_COUNT_TIMER, slot(self.OnReadyCountTimer,self))			-- 人满弹准备倒计时
	Notifier.remove(cmdName.GAME_SOCKET_PLAYER_LEAVE, slot(self.OnUserLeave,self))				--游戏结束离开通知
	Notifier.remove(cmdName.F3_START_FLAG, slot(self.OnStartFlag,self))							-- 游戏是否开始标记
	
	Notifier.remove(cmd_poker.room_sum_score,  slot(self.RoomSumScore,self))					--更新总积分
end

 function poker_msg_manage_base:OnGameStart(tbl)
 	local votechair = tbl._para.votechair
	if votechair then
		roomdata_center.curplayernum = table.getn(votechair)
	end

 	if self.data_manage then
 		self.data_manage.GameStartData = tbl
 	end
	slot(self.ui_controller:OnGameStart(tbl),self.ui_controller)
end

 function poker_msg_manage_base:OnPlayerChat(tbl)
	slot(self.ui_controller:OnPlayerChat(tbl),self.ui_controller)
end

 function poker_msg_manage_base:OnVoteStart(tbl)
	
	slot(self.ui_controller:OnVoteStart(tbl),self.ui_controller)
end

 function poker_msg_manage_base:OnVoteDraw(tbl)
	slot(self.ui_controller:OnVoteDraw(tbl),self.ui_controller)
end

 function poker_msg_manage_base:OnVoteEnd(tbl)
	slot(self.ui_controller:OnVoteEnd(tbl),self.ui_controller)
end

-- 请求开始
 function poker_msg_manage_base:OnPlayerCanVoteStart(tbl)
	slot(self.ui_controller:OnPlayerCanVoteStart(tbl),self.ui_controller)
end

 function poker_msg_manage_base:OnVoteStartPlayStartflag(tbl)
	slot(self.ui_controller:OnVoteStartPlayStartflag(tbl),self.ui_controller)
end

 function poker_msg_manage_base:OnVoteStartPlay(tbl)
	slot(self.ui_controller:OnVoteStartPlay(tbl),self.ui_controller)
end

 function poker_msg_manage_base:OnVoteStartPlayResult(tbl)
	slot(self.ui_controller:OnVoteStartPlayResult(tbl),self.ui_controller)
end

 function poker_msg_manage_base:OnVoteStartPlayStop(tbl)
	slot(self.ui_controller:OnVoteStartPlayStop(tbl),self.ui_controller)
end
-- 请求开始

function poker_msg_manage_base:OnReadyCountTimer(tbl)
	slot(self.ui_controller:OnReadyCountTimer(tbl),self.ui_controller)
end

function poker_msg_manage_base:OnUserLeave(tbl)
	slot(self.ui_controller:OnLeaveEnd(tbl),self.ui_controller)	
	if self.scene_controller then
		slot(self.scene_controller:OnLeaveEnd(tbl),self.scene_controller)
	end	
end

function poker_msg_manage_base:OnStartFlag(tbl)
	roomdata_center.isRoundStart = tbl._para.flag == 1
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmdName.F3_START_FLAG)
end

---总积分更新
function poker_msg_manage_base:RoomSumScore(tbl)
	slot(self.ui_controller:RoomSumScore(tbl),self.ui_controller)
end

return poker_msg_manage_base
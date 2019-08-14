require "logic/shisangshui_sys/cmd_manage/play_mode_shisanshui"
require "logic/shisangshui_sys/cmd_manage/shisanshui_ui_sys"
shisanshui_msg_manage_instance = nil

local shisanshui_msg_manage = class("shisanshui_msg_manage")

function shisanshui_msg_manage:ctor()
	self.play_mode_shisanshui = nil
	self.shisanshui_ui_sys = nil
	self.play_mode_shisanshui = require("logic.shisangshui_sys.cmd_manage.play_mode_shisanshui"):create()
	self.shisanshui_ui_sys = require("logic.shisangshui_sys.cmd_manage.shisanshui_ui_sys"):create()
--	self.play_mode_shisanshui:ConstructComponents()
	self:Initialize()
	Trace("=================shisanshui_msg_manage:ctor================")
end


function shisanshui_msg_manage:GetInstance()
    if shisanshui_msg_manage_instance == nil  then
		Trace("Error !! shisanshui_msg_manage no create")
		shisanshui_msg_manage_instance = require ("logic.shisangshui_sys.cmd_manage.shisanshui_msg_manage"):create()
    end
    return shisanshui_msg_manage_instance
end

function shisanshui_msg_manage:GetPlayModeShiSanShuiInstance()
	if self.play_mode_shisanshui == nil then
		Trace("+++++++Error!!!!!!!!+++++++++".."get play_mode_shisanshui instance error!!!!!")
	end
	return self.play_mode_shisanshui
end

function shisanshui_msg_manage:GetShiSanShuiUiSysInstance()
	if self.shisanshui_ui_sys == nil then
		Trace("+++++++Error!!!!!!!!+++++++++".."get shisanshui_ui_sys instance error!!!!!")
	end
	return self.shisanshui_ui_sys
end

function shisanshui_msg_manage:OnPlayerEnter(tbl)
	Trace("++++++++++++++OnPlayerEnter++++++++++++++="..tostring(tbl))
	slot(self.play_mode_shisanshui:OnPlayerEnter(tbl),self.play_mode_shisanshui)
	slot(self.shisanshui_ui_sys:OnPlayerEnter(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnPlayerReady(tbl)
--	slot(self.play_mode_shisanshui:OnPlayerReady(tbl),self.play_mode_shisanshui)
	slot(self.shisanshui_ui_sys:OnPlayerReady(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnGameStart(tbl)
	slot(self.play_mode_shisanshui:OnGameStart(tbl),self.play_mode_shisanshui)
	slot(self.shisanshui_ui_sys:OnGameStart(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnGameDeal(tbl)
	slot(self.play_mode_shisanshui:OnGameDeal(tbl),self.play_mode_shisanshui)
	slot(self.shisanshui_ui_sys:OnGameDeal(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnAskChoose(tbl)
	slot(self.play_mode_shisanshui:OnAskChoose(tbl),self.play_mode_shisanshui)
	
end

 function shisanshui_msg_manage:OnChooseOK(tbl)
	slot(self.play_mode_shisanshui:OnChooseOK(tbl),self.play_mode_shisanshui)
	
end

 function shisanshui_msg_manage:OnCompareStart(tbl)
	slot(self.play_mode_shisanshui:OnCompareStart(tbl),self.play_mode_shisanshui)
	slot(self.shisanshui_ui_sys:OnCompareStart(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnCompareResult(tbl)
	slot(self.play_mode_shisanshui:OnCompareResult(tbl),self.play_mode_shisanshui)
end

 function shisanshui_msg_manage:OnCompareEnd(tbl)
	slot(self.play_mode_shisanshui:OnCompareEnd(tbl),self.play_mode_shisanshui)
	
end

 function shisanshui_msg_manage:OnGameRewards(tbl)
	
	slot(self.shisanshui_ui_sys:OnGameRewards(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnGameEnd(tbl)
	slot(self.play_mode_shisanshui:OnGameEnd(tbl),self.play_mode_shisanshui)
end

 function shisanshui_msg_manage:OnSyncBegin(tbl)
	slot(self.play_mode_shisanshui:OnSyncBegin(tbl),self.play_mode_shisanshui)
	slot(self.shisanshui_ui_sys:OnSyncBegin(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnSyncTable(tbl)
	slot(self.play_mode_shisanshui:OnSyncTable(tbl),self.play_mode_shisanshui)
	slot(self.shisanshui_ui_sys:OnSyncTable(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnUserLeave(tbl)
	slot(self.play_mode_shisanshui:OnUserLeave(tbl),self.play_mode_shisanshui)
	slot(self.shisanshui_ui_sys:OnLeaveEnd(tbl),self.shisanshui_ui_sys)	
end

 function shisanshui_msg_manage:OnAllMult(tbl)
	slot(self.play_mode_shisanshui:OnAllMult(tbl),self.play_mode_shisanshui)
	slot(self.shisanshui_ui_sys:OnAllMult(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnPlayStart(tbl)
	slot(self.shisanshui_ui_sys:OnPlayStart(tbl),self.shisanshui_ui_sys)
end

function shisanshui_msg_manage:OnGameBigRewards(tbl)
	
	slot(self.shisanshui_ui_sys:OnGameBigRewards(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnPointsRefresh(tbl)
	
	slot(self.shisanshui_ui_sys:OnPointsRefresh(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnAskReady(tbl)
	
	slot(self.shisanshui_ui_sys:OnAskReady(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnSyncEnd(tbl)
	
	slot(self.shisanshui_ui_sys:OnSyncEnd(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnPlayerOffline(tbl)
	
	slot(self.shisanshui_ui_sys:OnPlayerOffline(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnGroupCompareResult(tbl)
	
	slot(self.shisanshui_ui_sys:OnGroupCompareResult(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnShowPokerCard(tbl)
	
	slot(self.shisanshui_ui_sys:OnShowPokerCard(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:ShootingPlayerList(tbl)

	slot(self.shisanshui_ui_sys:ShootingPlayerList(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnVoteDraw(tbl)
	
	slot(self.shisanshui_ui_sys:OnVoteDraw(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnPlayerChat(tbl)
	
	slot(self.shisanshui_ui_sys:OnPlayerChat(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnVoteStart(tbl)
	
	slot(self.shisanshui_ui_sys:OnVoteStart(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnVoteEnd(tbl)
	
	slot(self.shisanshui_ui_sys:OnVoteEnd(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:RoomSumScore(tbl)
	
	slot(self.shisanshui_ui_sys:RoomSumScore(tbl),self.shisanshui_ui_sys)
end
 
 function shisanshui_msg_manage:OnSpecialCardType(tbl)
	
	
	slot(self.shisanshui_ui_sys:OnSpecialCardType(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnReadCard(tbl)

	slot(self.shisanshui_ui_sys:OnReadCard(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnAskMult(tbl)
--	slot(self.play_mode_shisanshui:OnAskMult(tbl),self.play_mode_shisanshui)
	slot(self.shisanshui_ui_sys:OnAskMult(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:OnMult(tbl)
	slot(self.shisanshui_ui_sys:OnMult(tbl),self.shisanshui_ui_sys)
end

 function shisanshui_msg_manage:RecommondCard(tbl)
	slot(self.shisanshui_ui_sys:RecommondCard(tbl),self.shisanshui_ui_sys)
end

function shisanshui_msg_manage:EarlySettlement(tbl)
	slot(self.shisanshui_ui_sys:EarlySettlement(tbl),self.shisanshui_ui_sys)
end
	
function shisanshui_msg_manage:FreezeUser(tbl)
	slot(self.shisanshui_ui_sys:FreezeUser(tbl),self.shisanshui_ui_sys)
end
	
function shisanshui_msg_manage:FreezeOwner(tbl)
	slot(self.shisanshui_ui_sys:FreezeOwner(tbl),self.shisanshui_ui_sys)
end

function shisanshui_msg_manage:Initialize()
	Notifier.regist(cmdName.GAME_SOCKET_ENTER, slot(self.OnPlayerEnter,self))--玩家进入
	Notifier.regist(cmdName.GAME_SOCKET_ASK_READY, slot(self.OnAskReady,self))--请求准备
	Notifier.regist(cmdName.GAME_SOCKET_READY, slot(self.OnPlayerReady,self))--玩家准备
	Notifier.regist(cmdName.GAME_SOCKET_GAMESTART, slot(self.OnGameStart,self))--游戏开始
	Notifier.regist(cmdName.GAME_SOCKET_GAME_DEAL, slot(self.OnGameDeal,self))--发牌
	Notifier.regist(cmd_shisanshui.ASK_CHOOSE,  slot(self.OnAskChoose,self)) --摆牌
	Notifier.regist(cmd_shisanshui.CHOOSE_OK, slot(self.OnChooseOK,self))
	Notifier.regist(cmd_shisanshui.COMPARE_START, slot(self.OnCompareStart,self))  --比牌开始
	Notifier.regist(cmd_shisanshui.COMPARE_RESULT, slot(self.OnCompareResult,self)) --比牌结果
	Notifier.regist(cmd_shisanshui.COMPARE_END, slot(self.OnCompareEnd,self)) -- 比牌结束
	Notifier.regist(cmdName.GAME_SOCKET_SMALL_SETTLEMENT, slot(self.OnGameRewards,self))--结算
	Notifier.regist(cmdName.GAME_SOCKET_GAMEEND, slot(self.OnGameEnd,self))--游戏结束
	Notifier.regist(cmdName.GAME_SOCKET_SYNC_BEGIN, slot(self.OnSyncBegin,self))--重连同步开始
	Notifier.regist(cmdName.GAME_SOCKET_SYNC_TABLE, slot(self.OnSyncTable,self))--重连同步表
	Notifier.regist(cmdName.GAME_SOCKET_SYNC_END, slot(self.OnSyncEnd,self))--重连同步结束
	Notifier.regist(cmdName.GAME_SOCKET_PLAYER_LEAVE, slot(self.OnUserLeave,self))--游戏结束离开通知。
	Notifier.regist(cmd_shisanshui.FuZhouSSS_ALLMULT,  slot(self.OnAllMult,self))  --选择倍数通知(所有人的选择倍数)
	Notifier.regist(cmdName.MAHJONG_PLAY_CARDSTART, slot(self.OnPlayStart,self))--打牌开始
	Notifier.regist(cmdName.GAME_SOCKET_LUMP_SUM, slot(self.OnGameBigRewards,self))--大结算
	Notifier.regist(cmdName.F1_POINTS_REFRESH, slot(self.OnPointsRefresh,self))--玩家金币更新
	Notifier.regist(cmdName.GAME_SOCKET_OFFLINE, slot(self.OnPlayerOffline,self))--用户掉线
	Notifier.regist(cmd_shisanshui.Group_Compare_result, slot(self.OnGroupCompareResult,self)) --第一组比牌完成通知
	Notifier.regist(cmd_shisanshui.ShowPokerCard, slot(self.OnShowPokerCard,self))
	Notifier.regist(cmd_shisanshui.ShootingPlayerList, slot(self.ShootingPlayerList,self))
	Notifier.regist(cmdName.GAME_SOCKET_CHAT, slot(self.OnPlayerChat,self))--用户聊天

	Notifier.regist(cmdName.GAME_NIT_VOTE_DRAW,  slot(self.OnVoteDraw,self))		--请求和局/投票
	Notifier.regist(cmdName.GAME_VOTE_DRAW_START, slot(self. OnVoteStart,self))		--请求和局开始
	Notifier.regist(cmdName.GAME_VOTE_DRAW_END,  slot(self.OnVoteEnd,self))		--请求和局结束	
	Notifier.regist(cmd_shisanshui.ROOM_SUM_SCORE,  slot(self.RoomSumScore,self))		--重入更新积分
	Notifier.regist(cmd_shisanshui.SpecialCardType, slot(self.OnSpecialCardType,self)) -- 在特殊排型上显一个张特殊牌型的图标
	Notifier.regist(cmd_shisanshui.ReadCard, slot(self.OnReadCard,self)) -- 理牌
	Notifier.regist(cmd_shisanshui.FuZhouSSS_ASKMULT, slot(self.OnAskMult,self)) --等待闲家选择倍数 
	Notifier.regist(cmd_shisanshui.FuZhouSSS_MULT,  slot(self.OnMult,self))  -- 选择倍数通知(回复自己选择倍数)
	Notifier.regist(cmd_shisanshui.Card_RECOMMEND,  slot(self.RecommondCard,self))		--推荐牌
	
	Notifier.regist(cmdName.MSG_EARLY_SETTLEMENT,slot(self.EarlySettlement,self)) -- 管理员强制提前进行游戏结算
	Notifier.regist(cmdName.MSG_FREEZE_USER,slot(self.FreezeUser,self)) --冻结帐号
	Notifier.regist(cmdName.MSG_FREEZE_OWNER,slot(self.FreezeOwner,self)) --未开局管理员封房主号
	
end

function shisanshui_msg_manage:Uninitialize()
	Notifier.remove(cmdName.GAME_SOCKET_ENTER,  slot(self.OnPlayerEnter,self))--玩家进入
	Notifier.remove(cmdName.GAME_SOCKET_READY, slot(self.OnPlayerReady,self))--玩家准备
	Notifier.remove(cmdName.GAME_SOCKET_GAMESTART, slot(self.OnGameStart,self))--游戏开始
	Notifier.remove(cmdName.GAME_SOCKET_GAME_DEAL, slot(self.OnGameDeal,self))--发牌
	Notifier.remove(cmd_shisanshui.ASK_CHOOSE,  slot(self.OnAskChoose,self)) --摆牌
	Notifier.remove(cmd_shisanshui.CHOOSE_OK, slot(self.OnChooseOK,self))
	Notifier.remove(cmd_shisanshui.COMPARE_START, slot(self.OnCompareStart,self))  --比牌开始
	Notifier.remove(cmd_shisanshui.COMPARE_RESULT, slot(self.OnCompareResult,self)) --比牌结果
	Notifier.remove(cmd_shisanshui.COMPARE_END, slot(self.OnCompareEnd,self)) -- 比牌结束
	Notifier.remove(cmdName.GAME_SOCKET_SMALL_SETTLEMENT, slot(self.OnGameRewards,self))--结算
	Notifier.remove(cmdName.GAME_SOCKET_GAMEEND, slot(self.OnGameEnd,self))--游戏结束
	Notifier.remove(cmdName.GAME_SOCKET_SYNC_BEGIN, slot(self.OnSyncBegin,self))--重连同步开始
	Notifier.remove(cmdName.GAME_SOCKET_SYNC_TABLE, slot(self.OnSyncTable,self))--重连同步表
	Notifier.remove(cmdName.GAME_SOCKET_PLAYER_LEAVE, slot(self.OnUserLeave,self))--游戏结束离开通知。
	Notifier.remove(cmd_shisanshui.FuZhouSSS_ALLMULT,  slot(self.OnAllMult,self))  --选择倍数通知(所有人的选择倍数)
	Notifier.remove(cmdName.MAHJONG_PLAY_CARDSTART, slot(self.OnPlayStart,self))--打牌开始
	Notifier.remove(cmdName.GAME_SOCKET_LUMP_SUM, slot(self.OnGameBigRewards,self))--大结算
	Notifier.remove(cmdName.GAME_SOCKET_ASK_READY, slot(self.OnAskReady,self))--请求准备
	Notifier.remove(cmdName.GAME_SOCKET_SYNC_END, slot(self.OnSyncEnd,self))--重连同步结束
	Notifier.remove(cmdName.GAME_SOCKET_OFFLINE, slot(self.OnPlayerOffline,self))--用户掉线
	Notifier.remove(cmd_shisanshui.Group_Compare_result, slot(self.OnGroupCompareResult,self)) --第一组比牌完成通知
	Notifier.remove(cmd_shisanshui.ShowPokerCard, slot(self.OnShowPokerCard,self))
	Notifier.remove(cmd_shisanshui.ShootingPlayerList, slot(self.ShootingPlayerList,self))
	Notifier.remove(cmdName.GAME_SOCKET_CHAT, slot(self.OnPlayerChat,self))--用户聊天
	Notifier.remove(cmdName.F1_POINTS_REFRESH, slot(self.OnPointsRefresh,self))--玩家金币更新
	Notifier.remove(cmdName.GAME_NIT_VOTE_DRAW,  slot(self.OnVoteDraw,self))		--请求和局/投票
	Notifier.remove(cmdName.GAME_VOTE_DRAW_START, slot(self. OnVoteStart,self))		--请求和局开始
	Notifier.remove(cmdName.GAME_VOTE_DRAW_END,  slot(self.OnVoteEnd,self))		--请求和局结束	
	Notifier.remove(cmd_shisanshui.ROOM_SUM_SCORE,  slot(self.RoomSumScore,self))		--重入更新积分
	Notifier.remove(cmd_shisanshui.SpecialCardType, slot(self.OnSpecialCardType,self)) -- 在特殊排型上显一个张特殊牌型的图标
	Notifier.remove(cmd_shisanshui.ReadCard, slot(self.OnReadCar,self)) -- 理牌
	Notifier.remove(cmd_shisanshui.FuZhouSSS_ASKMULT, slot(self.OnAskMult,self)) --等待闲家选择倍数 
	Notifier.remove(cmd_shisanshui.FuZhouSSS_MULT,  slot(self.OnMult,self))  -- 选择倍数通知(回复自己选择倍数)
	Notifier.remove(cmd_shisanshui.Card_RECOMMEND,  slot(self.RecommondCard,self))		--推荐牌
	Notifier.remove(cmdName.MSG_EARLY_SETTLEMENT,slot(self.EarlySettlement,self)) -- 管理员强制提前进行游戏结算
	Notifier.remove(cmdName.MSG_FREEZE_USER,slot(self.FreezeUser,self)) --冻结帐号
	Notifier.remove(cmdName.MSG_FREEZE_OWNER,slot(self.FreezeOwner,self)) --未开局管理员封房主号
	
	shisanshui_msg_manage_instance = nil
	room_usersdata_center.RemoveAll()
	large_result.Hide()
	place_card.Hide()
	small_result.Hide()
	common_card.Hide()
	prepare_special.Hide()
end

return shisanshui_msg_manage
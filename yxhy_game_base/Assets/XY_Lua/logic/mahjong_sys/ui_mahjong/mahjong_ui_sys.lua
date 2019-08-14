--[[--
 * @Description: 麻将UI 控制层
 * @Author:      ShushingWong
 * @FileName:    mahjong_ui_sys.lua
 * @DateTime:    2017-06-20 15:59:13
 ]]


mahjong_ui_sys = {}

-- require("logic/voteQuit/vote_quit_ui")

local this = mahjong_ui_sys

local gvbl = player_seat_mgr.GetViewSeatByLogicSeat
local gvbln = player_seat_mgr.GetViewSeatByLogicSeatNum
local gmls = player_seat_mgr.GetMyLogicSeat

function this.ChangeTable()
	mahjong_ui:ResetAll()
	for i=2, 4 do
		mahjong_ui:HidePlayer(i)
	end
	mahjong_ui:ShowMatching()	
end

local function OnBuyCode( tbl )
 	local action = this.actionCtrl:GetAction("buycode")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
end

local function OnBaoInfo( tbl )
 	local action = this.actionCtrl:GetAction("game_baoInfo")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
end

local function OnJiType( tbl )
 	local action = this.actionCtrl:GetAction("game_jiType")
 	if action ~= nil then 
 		action:Execute(tbl)
 	end
end

local function OnPlayerEnter( tbl )
 	local action = this.actionCtrl:GetAction("player_enter")
 	if action ~= nil then
 		action:Execute(tbl)
 	end	

	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_ENTER)
end

local function OnPlayerReady( tbl )
 	local action = this.actionCtrl:GetAction("player_ready")
 	if action ~= nil then
 		action:Execute(tbl)
 	end

 	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_READY)
end

local function OnGameStart(tbl)
 	local action = this.actionCtrl:GetAction("game_start")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
end

------河南相关开始------------------
local function OnGoXiaPao( tbl )
	local action = this.actionCtrl:GetAction("game_ask_xiaPao")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F1_GAME_GOXIAPAO)
end
 

local function OnPlayerXiaPao( tbl )
	local action = this.actionCtrl:GetAction("game_xiaPao")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F1_GAME_XIAPAO)
end

local function OnALLPlayerXiaPao( tbl )
	local action = this.actionCtrl:GetAction("game_all_xiaPao")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F1_GAME_ALLXIAPAO)
end

local function OnGameLaiZi( tbl )	
	ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("laizi"))
end

local function OnGameCi(tbl)
    ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("laizi"))
end

local function OnPointsRefresh( tbl )
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F1_POINTS_REFRESH)
end

------河南相关结束------------------



local function OnGameBanker( tbl )
 	local action = this.actionCtrl:GetAction("game_banker")
 	if action ~= nil then
 		action:Execute(tbl)
 	end

	--Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_BANKER)
end

local function OnPlayStart( tbl )
	-- 播放动画
    
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_PLAY_CARDSTART)
end

local function OnGameDeal( tbl )
 	local action = this.actionCtrl:GetAction("game_deal")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
end


local function OnGameAskBlock( tbl )
	local action = this.actionCtrl:GetAction("game_askBlock")
 	if action ~= nil then
 		action:Execute(tbl)
 	end

	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_ASK_BLOCK)
end

local function OnPlayCard( tbl )  
	local action = this.actionCtrl:GetAction("game_playCard")
 	if action ~= nil then
 		action:Execute(tbl)
 	end 

end

local function OnGiveCard( tbl )
	local action = this.actionCtrl:GetAction("game_giveCard")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
 end


local function OnTriplet( tbl )
	local action = this.actionCtrl:GetAction("game_triplet")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
end

local function OnQuadruplet( tbl )
	local action = this.actionCtrl:GetAction("game_quadruplet")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
end

local function OnCollect( tbl )
	local action = this.actionCtrl:GetAction("game_collect")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
end

local function OnTing(tbl )
	local action = this.actionCtrl:GetAction("game_ting")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
end


local function OnTingType(tbl)  
	local action = this.actionCtrl:GetAction("game_tingType")
 	if action ~= nil then
 		action:Execute(tbl)
 	end

 	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_TING_TYPE)
end

local function OnYouJinCount(tbl)
	local action = this.actionCtrl:GetAction("game_youjin_count")
 	if action ~= nil then
 		action:Execute(tbl)
 	end

 	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_YOUJIN_COUNT)
end

local function OnGameWin( tbl )
 	local action = this.actionCtrl:GetAction("game_win")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
end

function this.OnGameRewards( tbl )
 	local action = this.actionCtrl:GetAction("small_reward") 
 	if action ~= nil then
 		action:Execute(tbl)
 	end	

	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SMALL_SETTLEMENT)
end

local function OnGameBigRewards( tbl )
 	local action = this.actionCtrl:GetAction("game_bigRewards")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
end

local function OnTotalreward( tbl )
	local action = this.actionCtrl:GetAction("total_reward")
 	if action ~= nil then
 		action:Execute(tbl)
 	end

 	if roomdata_center.needShowTotalReward then
 		UI_Manager:Instance():ShowUiForms("bigSettlement_ui")
 	end
 	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_BIG_SETTLEMENT)
end

local function OnGameEnd( tbl )
 	local action = this.actionCtrl:GetAction("game_end")
 	if action ~= nil then
 		action:Execute(tbl)
 	end 	
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAMEEND)
end

local function OnAskReady( tbl )
 	local action = this.actionCtrl:GetAction("askReady")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_ASK_READY)
end

local function OnSyncBegin( tbl )
	roomdata_center.isReconnecting = true
 	local action = this.actionCtrl:GetAction("game_syncBegin")
 	if action ~= nil then
 		action:Execute(tbl)
 	end

	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SYNC_BEGIN)
end

local function OnSyncTable( tbl )
 	local action = this.actionCtrl:GetAction("game_syncTable")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SYNC_TABLE)
end


local function OnSyncEnd( tbl )
	Trace(GetTblData(tbl))
	Trace("重连同步结束")
	roomdata_center.isReconnecting = false
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SYNC_END)
end

local function OnLeaveEnd( tbl )
 	local action = this.actionCtrl:GetAction("player_leave")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
	
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_PLAYER_LEAVE)
end

local function OnPlayerOffline( tbl )
 	local action = this.actionCtrl:GetAction("player_offline")
 	if action ~= nil then
 		action:Execute(tbl)
 	end

	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_OFFLINE)
end

local function OnPlayerChat( tbl )    
 	local action = this.actionCtrl:GetAction("player_chat")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
   --	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_CHAT)
end

local function OnAutoPlay( tbl )
 	local action = this.actionCtrl:GetAction("game_autoPlay")
 	if action ~= nil then
 		action:Execute(tbl)
 	end 
	if roomdata_center.isReconnecting then
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_AUTOPLAY)
	end
end

---- 河北  暂未注册
local function OnTingInfo(tbl)
	local action = this.actionCtrl:GetAction("game_tingInfo")
 	if action ~= nil then
 		action:Execute(tbl)
 	end

 	--Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_TING_INFO)
end


local function OnYoustatus(tbl)
 	local action = this.actionCtrl:GetAction("game_youStatus")
 	if action ~= nil then
 		action:Execute(tbl)
 	end

	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_20_YOU_STATUS)
end

local function OnFollowBanker(tbl)
	local action = this.actionCtrl:GetAction("game_followBanker")
 	if action ~= nil then
 		action:Execute(tbl)
 	end

	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_26_FOLLOW_BANKER)
end

local function OnThreePeng( tbl )
	local action = this.actionCtrl:GetAction("game_treePeng")
 	if action ~= nil then
 		action:Execute(tbl)
 	end

	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_43_THREE_PENG)
end

local function OnChangeFlower(tbl) 
	mahjong_ui:SetAllHuaPointVisible(true)
	--local flowerCounts = tbl._para["nTotalFlowerCard"]
    --local viewSeat = gvbln(tbl._para[nFlowerWho])
end

local function OnOpenGold()
end


local function OnLeftCardUpdate(leftCard)
	mahjong_ui:SetLeftCard(leftCard)
end

local function ShowWarning()
	mahjong_ui:ShowWarning()
end

local function OnPlayerHuaCardUpdate(tbl)
	local action = this.actionCtrl:GetAction("game_huaCardUpdate")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
end

local function OnVoteDraw(tbl)
	local action = this.actionCtrl:GetAction("vote_draw")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_NIT_VOTE_DRAW)
end

local function OnVoteStart(tbl)
	local action = this.actionCtrl:GetAction("vote_start")
 	if action ~= nil then
 		action:Execute(tbl)
 	end

	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_VOTE_DRAW_START)
end

local function OnVoteEnd(tbl)
	local action = this.actionCtrl:GetAction("vote_end")
 	if action ~= nil then
 		action:Execute(tbl)
 	end

	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_VOTE_DRAW_END)
end

local function OnReadyCountTimer(tbl)
	local action = this.actionCtrl:GetAction("ready_count_timer")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_READY_COUNT_TIMER)
end

local function OnAskPlay(tbl)
	local action = this.actionCtrl:GetAction("game_askPlay")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
end

local function OnBZZ(tbl)
	local action = this.actionCtrl:GetAction("bzz")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
end

-- 玩家分数更新
local function OnAccountUpadte(tbl)
	-- local scores = tbl._para.totalscore
	-- for i = 1, #scores do
	-- 	local viewSeat = gvbln(i)
	-- 	mahjong_ui.SetPlayerScore(viewSeat, scores[i])
	-- end
	local action = this.actionCtrl:GetAction("account_update")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F3_ACCOUNT)
end

local function OnStartFlag(tbl)
	roomdata_center.isRoundStart = tbl._para.flag == 1
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F3_START_FLAG)
end

local function OnLastLap(tbl)
	local action = this.actionCtrl:GetAction("game_lastLap")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.LASTLAP)
end

local function EarlySettlement(tbl)
	Trace("会长强制解散房间提前进行游戏结算")
	local clubInfo = model_manager:GetModel("ClubModel").clubMap[roomdata_center.roomCid]
	MessageBox.ShowSingleBox(LanguageMgr.GetWord(9005, clubInfo.nickname))
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MSG_EARLY_SETTLEMENT)
end

local function FreezeUser(tbl)
	Trace("管理员封号")
--	UI_Manager:Instance():CloseUiForms("message_box") 
	MessageBox.HideBox()
	game_scene.gotoLogin() 
    game_scene.GoToLoginHandle()
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MSG_FREEZE_USER)
end

local function FreezeOwner(tbl)
	Trace("管理员封号")
--	UI_Manager:Instance():CloseUiForms("message_box") 
	MessageBox.HideBox()
	game_scene.gotoLogin() 
    game_scene.GoToLoginHandle()
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MSG_FREEZE_OWNER)
end

local function OnChangeTable(tbl)
	this.ChangeTable()
end

local function OnAskBuySelfdraw(tbl)
	local action = this.actionCtrl:GetAction("buySelfdraw")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_ASK_BUYSELFDRAW)
end

local function OnBuySelfdrawResult(tbl)
	local action = this.actionCtrl:GetAction("buySelfdrawResult")
 	if action ~= nil then
 		action:Execute(tbl)
 	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_BUYSELFDRAW_RESULT)
end

function this:InitActionCtrl()
	local actionCtrlClass = require "logic/mahjong_sys/action/common/mahjong_action_ctrl"
	this.actionCtrl = actionCtrlClass.new()
	this.actionCtrl:Init(1)
end


function this.Init()
	Trace("-----------Start Regist Event UI ---------------!!!!!!!!!!")
	this:InitActionCtrl() 
	Notifier.regist(cmdName.GAME_SOCKET_ENTER, OnPlayerEnter)--玩家进入
	Notifier.regist(cmdName.GAME_SOCKET_READY, OnPlayerReady)--玩家准备
	Notifier.regist(cmdName.GAME_SOCKET_GAMESTART,OnGameStart)--游戏开始
	Notifier.regist(cmdName.GAME_SOCKET_BANKER,OnGameBanker)--定庄
	Notifier.regist(cmdName.F1_GAME_GOXIAPAO,OnGoXiaPao)--通知下跑
	Notifier.regist(cmdName.F1_GAME_XIAPAO,OnPlayerXiaPao)--玩家下跑
	Notifier.regist(cmdName.F1_GAME_ALLXIAPAO,OnALLPlayerXiaPao)--所有玩家下跑


	Notifier.regist(cmdName.MAHJONG_PLAY_CARDSTART,OnPlayStart)--打牌开始
	Notifier.regist(cmdName.GAME_SOCKET_GAME_DEAL,OnGameDeal)--发牌
	Notifier.regist(cmdName.F1_GAME_LAIZI,OnGameLaiZi)--定赖
    Notifier.regist(cmdName.MAHJONG_CI,OnGameCi)--定赖
    

	Notifier.regist(cmdName.MAHJONG_GIVE_CARD,OnGiveCard)--摸牌
	Notifier.regist(cmdName.MAHJONG_PLAY_CARD,OnPlayCard)--出牌

	Notifier.regist(cmdName.MAHJONG_ASK_BLOCK,OnGameAskBlock)--提示吃碰杠胡操作
	Notifier.regist(cmdName.MAHJONG_TRIPLET_CARD,OnTriplet)--碰牌
    Notifier.regist(cmdName.MAHJONG_QUADRUPLET_CARD,OnQuadruplet)--杠牌
	Notifier.regist(cmdName.MAHJONG_COLLECT_CARD,OnCollect)--吃牌
    

	Notifier.regist(cmdName.MAHJONG_HU_CARD,OnGameWin)--胡
    --Notifier.regist(cmdName.GAME_SOCKET_SMALL_SETTLEMENT,OnGameRewards)--结算
	Notifier.regist(cmdName.GAME_SOCKET_LUMP_SUM,OnGameBigRewards)--大结算
	Notifier.regist(cmdName.F1_POINTS_REFRESH,OnPointsRefresh)--玩家金币更新

	Notifier.regist(cmdName.GAME_SOCKET_GAMEEND,OnGameEnd)--游戏结束
	Notifier.regist(cmdName.GAME_SOCKET_ASK_READY,OnAskReady)--通知准备


	Notifier.regist(cmdName.GAME_SOCKET_SYNC_BEGIN,OnSyncBegin)--重连同步开始
	Notifier.regist(cmdName.GAME_SOCKET_SYNC_TABLE,OnSyncTable)--重连同步表
	Notifier.regist(cmdName.GAME_SOCKET_SYNC_END,OnSyncEnd)--重连同步结束


	Notifier.regist(cmdName.GAME_SOCKET_PLAYER_LEAVE,OnLeaveEnd)--用户离开
	Notifier.regist(cmdName.GAME_SOCKET_OFFLINE,OnPlayerOffline)--用户掉线 和 用户离开


	Notifier.regist(cmdName.GAME_SOCKET_CHAT,OnPlayerChat)--用户聊天
	Notifier.regist(cmdName.GAME_SOCKET_AUTOPLAY,OnAutoPlay)--托管


	Notifier.regist(cmdName.MAHJONG_CHANGE_FLOWER, OnChangeFlower)  -- 补花
	Notifier.regist(cmdName.MAHJONG_OPEN_GOLD, OnOpenGold) -- 开金

	Notifier.regist(cmdName.MAHJONG_20_YOU_STATUS,OnYoustatus)--双游 三游状态
	Notifier.regist(cmdName.MAHJONG_26_FOLLOW_BANKER,OnFollowBanker) -- 分饼（跟庄）
	Notifier.regist(cmdName.MAHJONG_43_THREE_PENG,OnThreePeng) -- 开局三连碰

	Notifier.regist(cmdName.GAME_NIT_VOTE_DRAW, OnVoteDraw)		--请求和局/投票
	Notifier.regist(cmdName.GAME_VOTE_DRAW_START, OnVoteStart)		--请求和局开始
	Notifier.regist(cmdName.GAME_VOTE_DRAW_END, OnVoteEnd)		--请求和局结束

	Notifier.regist(cmdName.GAME_READY_COUNT_TIMER, OnReadyCountTimer)		-- 人满弹准备倒计时
    
	Notifier.regist(cmdName.MAHJONG_ASK_PLAY_CARD, OnAskPlay)    --通知出牌

	Notifier.regist(cmdName.F3_ACCOUNT, OnAccountUpadte) -- 玩家分数刷新
	Notifier.regist(cmdName.F3_START_FLAG, OnStartFlag)		-- 游戏是否开始标记

	Notifier.regist(cmdName.LASTLAP, OnLastLap)		-- 最后一圈牌
	Notifier.regist(cmdName.GAME_SOCKET_BIG_SETTLEMENT, OnTotalreward)		-- socket大结算

	Notifier.regist(cmdName.MAHJONG_TING_CARD, OnTing)       --胡牌提示
	Notifier.regist(cmdName.MAHJONG_TING_TYPE, OnTingType)       -- 报听

	Notifier.regist(cmdName.MAHJONG_YOUJIN_COUNT, OnYouJinCount)       -- 游金圈数
	Notifier.regist(cmdName.GAME_CHANGE_TABLE, OnChangeTable)
	Notifier.regist(cmdName.MAHJONG_ASK_BUYSELFDRAW, OnAskBuySelfdraw)       -- 通知买自摸
	Notifier.regist(cmdName.MAHJONG_BUYSELFDRAW_RESULT, OnBuySelfdrawResult)       -- 买自摸后通知所有人

	Notifier.regist(cmdName.MAHJONG_BUYCODE, OnBuyCode)       -- 结算买马
	
	Notifier.regist(cmdName.MAHJONG_BAOINFO, OnBaoInfo)       -- 定宝换宝
	Notifier.regist(cmdName.MAHJONG_JITYPE, OnJiType)       -- 鸡牌播报

	Notifier.regist(cmdName.MAHJONG_FLAG_BZZ, OnBZZ)       -- 边钻砸通知

	------------------------------游戏逻辑刷新-----------------------

	Notifier.regist(cmdName.MSG_UPDATE_ROOM_LEFT_CARD, OnLeftCardUpdate) -- 剩余牌数更新
	Notifier.regist(cmdName.MSG_UPDATE_PLAYER_HUA_CARD, OnPlayerHuaCardUpdate) -- 玩家花牌更新
	Notifier.regist(cmdName.MSG_MJ_OUT_WARNING, ShowWarning)
	Notifier.regist(cmdName.MSG_EARLY_SETTLEMENT,EarlySettlement) -- 管理员强制提前进行游戏结算
	Notifier.regist(cmdName.MSG_FREEZE_USER,FreezeUser)  -- 封号
	Notifier.regist(cmdName.MSG_FREEZE_OWNER,FreezeOwner) --未开局管理员封房主号	
end

function this.UInit()
	this.actionCtrl:UnInit()
	
	Notifier.remove(cmdName.GAME_SOCKET_ENTER, OnPlayerEnter)--玩家进入
	Notifier.remove(cmdName.GAME_SOCKET_READY,OnPlayerReady)--玩家准备
	Notifier.remove(cmdName.GAME_SOCKET_GAMESTART,OnGameStart)--游戏开始
	Notifier.remove(cmdName.GAME_SOCKET_BANKER,OnGameBanker)--定庄
	Notifier.remove(cmdName.F1_GAME_GOXIAPAO,OnGoXiaPao)--通知下跑
	Notifier.remove(cmdName.F1_GAME_XIAPAO,OnPlayerXiaPao)--玩家下跑
	Notifier.remove(cmdName.F1_GAME_ALLXIAPAO,OnALLPlayerXiaPao)--所有玩家下跑


	Notifier.remove(cmdName.MAHJONG_PLAY_CARDSTART,OnPlayStart)--打牌开始
	Notifier.remove(cmdName.GAME_SOCKET_GAME_DEAL,OnGameDeal)--发牌
	Notifier.remove(cmdName.F1_GAME_LAIZI,OnGameLaiZi)--定赖
    Notifier.remove(cmdName.MAHJONG_CI,OnGameCi)--定赖

	Notifier.remove(cmdName.MAHJONG_GIVE_CARD,OnGiveCard)--摸牌
	Notifier.remove(cmdName.MAHJONG_PLAY_CARD,OnPlayCard)--出牌

    
	Notifier.remove(cmdName.MAHJONG_ASK_BLOCK,OnGameAskBlock)--提示吃碰杠胡操作
	Notifier.remove(cmdName.MAHJONG_TRIPLET_CARD,OnTriplet)--碰牌
    Notifier.remove(cmdName.MAHJONG_QUADRUPLET_CARD,OnQuadruplet)--杠牌
    Notifier.remove(cmdName.MAHJONG_COLLECT_CARD,OnCollect)--吃牌


    Notifier.remove(cmdName.MAHJONG_HU_CARD,OnGameWin)--胡
	-- Notifier.remove(cmdName.GAME_SOCKET_SMALL_SETTLEMENT,OnGameRewards)--结算
	Notifier.remove(cmdName.GAME_SOCKET_LUMP_SUM,OnGameBigRewards)--大结算
	Notifier.remove(cmdName.F1_POINTS_REFRESH,OnPointsRefresh)--玩家金币更新

	Notifier.remove(cmdName.GAME_SOCKET_GAMEEND,OnGameEnd)--游戏结束
	Notifier.remove(cmdName.GAME_SOCKET_ASK_READY,OnAskReady)--通知准备


	Notifier.remove(cmdName.GAME_SOCKET_SYNC_BEGIN,OnSyncBegin)--重连同步开始
	Notifier.remove(cmdName.GAME_SOCKET_SYNC_TABLE,OnSyncTable)--重连同步表
	Notifier.remove(cmdName.GAME_SOCKET_SYNC_END,OnSyncEnd)--重连同步结束


	Notifier.remove(cmdName.GAME_SOCKET_PLAYER_LEAVE,OnLeaveEnd)--用户离开
	Notifier.remove(cmdName.GAME_SOCKET_OFFLINE,OnPlayerOffline)--用户掉线


	Notifier.remove(cmdName.GAME_SOCKET_CHAT,OnPlayerChat)--用户聊天
	Notifier.remove(cmdName.GAME_SOCKET_AUTOPLAY,OnAutoPlay)--托管


	Notifier.remove(cmdName.MAHJONG_CHANGE_FLOWER, OnChangeFlower)  -- 补花
	Notifier.remove(cmdName.MAHJONG_OPEN_GOLD, OnOpenGold) -- 开金

	Notifier.remove(cmdName.MAHJONG_20_YOU_STATUS,OnYoustatus)--双游 三游状态
	Notifier.remove(cmdName.MAHJONG_26_FOLLOW_BANKER,OnFollowBanker) -- 分饼（跟庄）
	Notifier.remove(cmdName.MAHJONG_43_THREE_PENG,OnThreePeng) -- 开局三连碰

	Notifier.remove(cmdName.GAME_NIT_VOTE_DRAW, OnVoteDraw)		--请求和局/投票
	Notifier.remove(cmdName.GAME_VOTE_DRAW_START, OnVoteStart)		--请求和局开始
	Notifier.remove(cmdName.GAME_VOTE_DRAW_END, OnVoteEnd)		--请求和局结束

	Notifier.remove(cmdName.GAME_READY_COUNT_TIMER, OnReadyCountTimer)		-- 人满弹准备倒计时

	Notifier.remove(cmdName.MAHJONG_ASK_PLAY_CARD, OnAskPlay)    --通知出牌

	Notifier.remove(cmdName.F3_ACCOUNT, OnAccountUpadte) -- 玩家分数刷新

	Notifier.remove(cmdName.F3_START_FLAG, OnStartFlag)		-- 游戏是否开始标记

	Notifier.remove(cmdName.LASTLAP, OnLastLap)		-- 最后一圈牌
	Notifier.remove(cmdName.GAME_SOCKET_BIG_SETTLEMENT, OnTotalreward)		-- socket大结算

	Notifier.remove(cmdName.MAHJONG_TING_CARD, OnTing)       --胡牌提示
	Notifier.remove(cmdName.MAHJONG_TING_TYPE, OnTingType)       -- 报听

	Notifier.remove(cmdName.MAHJONG_YOUJIN_COUNT, OnYouJinCount)       -- 游金圈数
	Notifier.remove(cmdName.GAME_CHANGE_TABLE, OnChangeTable)
	Notifier.remove(cmdName.MAHJONG_ASK_BUYSELFDRAW, OnAskBuySelfdraw)       -- 通知买自摸
	Notifier.remove(cmdName.MAHJONG_BUYSELFDRAW_RESULT, OnBuySelfdrawResult)       -- 买自摸后通知所有人

	Notifier.remove(cmdName.MAHJONG_BUYCODE, OnBuyCode)       -- 结算买马
	Notifier.remove(cmdName.MAHJONG_BAOINFO, OnBaoInfo)       -- 定宝换宝
	Notifier.remove(cmdName.MAHJONG_JITYPE, OnJiType)       -- 鸡牌播报

	Notifier.remove(cmdName.MAHJONG_FLAG_BZZ, OnBZZ)       -- 边钻砸通知

	------------------------------游戏逻辑刷新-----------------------

	Notifier.remove(cmdName.MSG_UPDATE_ROOM_LEFT_CARD, OnLeftCardUpdate) -- 剩余牌数更新
	Notifier.remove(cmdName.MSG_UPDATE_PLAYER_HUA_CARD, OnPlayerHuaCardUpdate) -- 玩家花牌更新
	Notifier.remove(cmdName.MSG_MJ_OUT_WARNING, ShowWarning)
	Notifier.remove(cmdName.MSG_EARLY_SETTLEMENT,EarlySettlement) -- 管理员强制提前进行游戏结算
	Notifier.remove(cmdName.MSG_FREEZE_USER,FreezeUser) --冻结帐号
	Notifier.remove(cmdName.MSG_FREEZE_OWNER,FreezeOwner) --未开局管理员封房主号
end




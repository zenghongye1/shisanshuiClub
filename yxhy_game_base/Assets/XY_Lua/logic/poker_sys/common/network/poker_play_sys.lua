--[[--
 * @Description: 扑克通用协议基类
 * @Author:      ZWX
 * @FileName:    poker_play_sys.lua
 * @DateTime:    20180331
 ]]

require "logic/poker_sys/common/network/poker_request_interface"

poker_play_sys = class("poker_play_sys")
local this = poker_play_sys

local sessionData = {}

function poker_play_sys.ctor()
end

---game_scene加载完场景后第一件事
function poker_play_sys.HandleLevelLoadComplete()
  	gs_mgr.ChangeState(gs_mgr.state_mahjong)
    map_controller.SetIsLoadingMap(false)
	msg_dispatch_mgr.SetIsEnterState(true)	
end

---game_scene退出场景时做的最后一件事
function poker_play_sys.ExitSystem()
    this.Uninitialize()
    roomdata_center.ClearData()
	roomdata_center.UnInitAllData()
end

---enter时必须设置session
function poker_play_sys.HandlerEnterGame()
	sessionData = player_data.GetSessionData()
	this.Initialize()
end

function poker_play_sys.Initialize()
		
end

function poker_play_sys.Uninitialize()
	mode_manager.UninitializeCurrMode()
	msg_dispatch_mgr.SetIsEnterState(false)
	msg_dispatch_mgr.ResetMsgQueue()	
end

---enter请求
function poker_play_sys.EnterGameReq(enterData)
	poker_request_interface.EnterGameReq(enterData)
end

---ready请求
function poker_play_sys.ReadyGameReq()
	poker_request_interface.ReadyGameReq(sessionData["_gt"],sessionData["_chair"])
end

---ready请求
function poker_play_sys.ApplyForReq(bStatus)
	poker_request_interface.ApplyForReq(sessionData["_chair"],bStatus)
end

--leave请求
function poker_play_sys.LeaveReq()
	poker_request_interface.LeaveReq()
end

--请求解散房间
function poker_play_sys.DissolutionRoom()
	poker_request_interface.Dissolution(sessionData["_gid"],sessionData["_gt"],sessionData["_chair"])
end

--请求投票
function poker_play_sys.VoteDrawReq(value)
	poker_request_interface.VoteDrawReq(value,sessionData["_gt"],sessionData["_chair"])
end

--chat请求
function poker_play_sys.ChatReq(contenttype,content,givewho)
    poker_request_interface.ChatReq(contenttype,content,sessionData["_gt"],sessionData["_chair"],givewho)
end

--倍数请求
function poker_play_sys.beishu(beishu)
	poker_request_interface.MultReq(beishu,sessionData["_gt"], sessionData["_chair"])
end

--定庄请求
function poker_play_sys.ChooseBankerReq()
	poker_request_interface.ChooseBankerReq(sessionData["_gt"],sessionData["_chair"])
end

--亮牌请求
function poker_play_sys.OpenCardReq()	
	poker_request_interface.OpenCardReq(sessionData["_gt"], sessionData["_chair"])
end

--抢庄请求
function poker_play_sys.robbankerReq(beishu)
	poker_request_interface.robbankerReq(beishu,sessionData["_gt"], sessionData["_chair"])
end

---测试用
function poker_play_sys.LogTest()
	logError("poker LogTest")
end

return poker_play_sys
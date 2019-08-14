--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--endregion

require  "logic/network/shisanshui_request_interface"

require "logic/gameplay/cmd_shisanshui"

require "logic/shisangshui_sys/cmd_manage/shisanshui_msg_manage"

shisangshui_play_sys = {}
local this = shisangshui_play_sys
local sessionData = {}

local heartTimer = nil

local shisanshui_msg_manage_Inst = nil

function this.RegisterEvent()

end

function this.UnRegisterEvents()

end

function this.Initialize()
    this.RegisterEvent()
end

function this.Uninitialize()   
    this.UnRegisterEvents()

	mode_manager.UninitializeCurrMode()
	msg_dispatch_mgr.SetIsEnterState(false)
	msg_dispatch_mgr.ResetMsgQueue()  
	if heartTimer~=nil then
		heartTimer:Stop()
		heartTimer = nil
	end    
end

function this.HandlerEnterGame()
    map_controller.LoadLevelScene(900003, shisangshui_play_sys)
	sessionData = player_data.GetSessionData()	
end


--[[--
 * @Description: 进入游戏请求  
 ]]
function this.EnterGameReq(enterData, dst)
	--majong_request_interface.EnterGameReq(messagedefine.chessPath, enterData)
	shisanshui_request_interface.EnterGameReq(messagedefine.chessPath, enterData, dst)
end

--加载完场景后第一件事
function this.HandleLevelLoadComplete()
    Trace("============================shisangshui_play_sys")
    gs_mgr.ChangeState(gs_mgr.state_mahjong)
    map_controller.SetIsLoadingMap(false)
 --   mode_manager.InitializeMode(2)
 --   mode_manager.StartCurrentMode() 
	  --发送游戏中心跳处理 定时发送
 
	heartTimer = Timer.New(this.HeartBeatReq, 5, -1)
	heartTimer:Start()   

	--加载十三水牌桌
--	play_mode_shisangshui.GetInstance()
	--加载牌桌结束，重连通知
	--Notifier.dispatchCmd(cmdName.LoadTableEnd)
	
	
	
		shisanshui_msg_manage_Inst = require ("logic.shisangshui_sys.cmd_manage.shisanshui_msg_manage"):GetInstance()
	--	shisanshui_msg_manage_Instance = shisanshui_msg_manage:GetInstance()
	
end

function this.ExitSystem()
	shisanshui_msg_manage_Inst:Uninitialize()
    this.Uninitialize()
    roomdata_center.ClearData()
    if vote_quit_ui ~= nil then
		vote_quit_ui:Hide()
    end  
end

--[[--
 * @Description: 关闭游戏中心跳  
 ]]
function this.StopChessHearBeat()
  heartTimer:Reset(this.HeartBeatReq, 5, -1)
  heartTimer:Stop()  
end

--[[--
 * @Description: 重启心跳包  
 ]]
function this.ReStartHearBeat()
  if heartTimer ~= nil then
    heartTimer:Start()
  else
    heartTimer = Timer.New(this.HeartBeatReq, 5, -1)
    heartTimer:Start()    
  end
end


--重置所有游戏状态，用于打完一局游戏进入下一局
function this.ReSetAllStatus()
--	local instance = play_mode_shisangshui.GetInstance()
--instance:ReSetAllStatus()
end

function this.ReadyGameReq()	
	shisanshui_request_interface.ReadyGameReq(sessionData["_gt"], sessionData["_chair"])
end

--比牌动画结束发送给服务端的消息
function this.CompareFinish()
	shisanshui_request_interface.CompareFinish(sessionData["_gt"], sessionData["_chair"])
end

--摆牌
function this.PlayCardAnimation(args)

end

function this.beishu(beishu)
	shisanshui_request_interface.beishuReq(beishu,sessionData["_gt"], sessionData["_chair"])
end

--是否选择特殊牌型
function this.ChooseCardTypeReq(nSelect)	
	shisanshui_request_interface.ChooseCardTypeReq(sessionData["_gt"], sessionData["_chair"], nSelect)
end

--摆牌
function this.PlaceCard(cards)
	shisanshui_request_interface.PlaceCard(sessionData["_gt"], sessionData["_chair"], cards)
end

--玩家退出
function this.LeaveReq()
  shisanshui_request_interface.LeaveReq(sessionData["_gt"],sessionData["_chair"])
end

-- 解散房间
function this.DissolutionRoom()
  shisanshui_request_interface.Dissolution(sessionData["_gid"], sessionData["_gt"],sessionData["_chair"])
end


--心跳
function this.HeartBeatReq()
	-- local beatTbl = {}
	-- beatTbl["_gt"] = sessionData["_gt"]
	-- beatTbl["_chair"] = sessionData["_chair"]
 --    shisanshui_request_interface.HeartBeatReq(beatTbl)
end

function this.VoteDrawReq(flag)
	shisanshui_request_interface.VoteDrawReq(flag, sessionData["_gt"], sessionData["_chair"])
end

--聊天
function this.ChatReq(contenttype,content,givewho)
    shisanshui_request_interface.ChatReq(contenttype,content,sessionData["_gt"],sessionData["_chair"],givewho)
end


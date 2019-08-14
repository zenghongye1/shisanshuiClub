				  ---三公协议---
---通用协议:enter,ready,leave,chat,dissolution,vote,beishu,chooseBanker,robBanker,openCard---
---独立协议:---
				---增删请维护这个---

require "logic/poker_sys/utils/poker3D_dictionary"
require "logic/poker_sys/common/poker2d_factory"

local base = require "logic.poker_sys.common.network.poker_play_sys"
sangong_play_sys = class("sangong_play_sys",base)

local sessionData = nil
local msg_manage_Inst = nil
local sangong_msg_manage = require("logic.poker_sys.sangong_sys.cmd_manage.sangong_data_manage")

function sangong_play_sys.ctor()
	base.ctor()
end

function sangong_play_sys.HandleLevelLoadComplete()
	base.HandleLevelLoadComplete()
	roomdata_center.SetMaxSupportPlayer(6)
	UI_Manager:Instance():ShowUiForms("sangong_ui",UiCloseType.UiCloseType_CloseOther)
	msg_manage_Inst = require("logic.poker_sys.sangong_sys.cmd_manage.sangong_msg_manage"):GetInstance()
end

function sangong_play_sys.ExitSystem()
	base.ExitSystem()
	UI_Manager:Instance():CloseUiForms("VoteQuitUI")
	UI_Manager:Instance():CloseUiForms("sangong_ui")
	msg_manage_Inst:Uninitialize()
end

function sangong_play_sys.HandlerEnterGame(msg)
	base.HandlerEnterGame()
	sangong_msg_manage:GetInstance():SetRoomInfo(msg)
    map_controller.LoadLevelScene(900002,sangong_play_sys)
	sessionData = player_data.GetSessionData()
end

function sangong_play_sys.LogTest()
	logError("三公LogTest")
end

return sangong_play_sys
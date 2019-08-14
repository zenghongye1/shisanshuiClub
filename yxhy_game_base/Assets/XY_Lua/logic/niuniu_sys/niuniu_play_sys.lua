				  ---牛牛协议---
---通用协议:enter,ready,leave,chat,dissolution,vote,beishu,chooseBanker,robBanker,openCard---
---独立协议:---
				---增删请维护这个---

require "logic/poker_sys/utils/poker3D_dictionary"
require "logic/poker_sys/common/poker2d_factory"
require "logic/niuniu_sys/other/niuniu_rule_define"

local base = require "logic.poker_sys.common.network.poker_play_sys"
niuniu_play_sys = class("niuniu_play_sys",base)

local sessionData = nil
local msg_manage_Inst = nil
local niuniu_data_manage = require("logic.niuniu_sys.cmd_manage.niuniu_data_manage")

function niuniu_play_sys.ctor()
	base.ctor()
end

function niuniu_play_sys.HandleLevelLoadComplete()
	base.HandleLevelLoadComplete()
	roomdata_center.SetMaxSupportPlayer(6)
	UI_Manager:Instance():ShowUiForms("niuniu_ui",UiCloseType.UiCloseType_CloseOther)
	msg_manage_Inst = require("logic.niuniu_sys.cmd_manage.niuniu_msg_manage"):GetInstance()
end

function niuniu_play_sys.ExitSystem()
	base.ExitSystem()
	UI_Manager:Instance():CloseUiForms("VoteQuitUI")
	UI_Manager:Instance():CloseUiForms("niuniu_ui")
	msg_manage_Inst:Uninitialize()
end

function niuniu_play_sys.HandlerEnterGame(msg)
	base.HandlerEnterGame()
	niuniu_data_manage:GetInstance():SetNiuNiuRoomInfo(msg)
    map_controller.LoadLevelScene(900002,niuniu_play_sys)
	sessionData = player_data.GetSessionData()
end

function niuniu_play_sys.LogTest()
	logError("牛牛LogTest")
end

return niuniu_play_sys
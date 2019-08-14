				  ---赢三张协议---
---通用协议:enter,ready,leave,chat,dissolution,vote,openCard---
---独立协议:Raise,Call,Fold,Compare---
				---增删请维护这个---

require "logic/poker_sys/utils/poker3D_dictionary"
require "logic/poker_sys/yingsanzhang_sys/other/yingsanzhang_rule_define"
require "logic/poker_sys/yingsanzhang_sys/cmd_manage/cmd_93"

local base = require "logic.poker_sys.common.network.poker_play_sys"
yingsanzhang_play_sys = class("yingsanzhang_play_sys",base)

local sessionData = nil
local msg_manage_Inst = nil
local yingsanzhang_data_manage = require("logic.poker_sys.yingsanzhang_sys.cmd_manage.yingsanzhang_data_manage")

function yingsanzhang_play_sys.ctor()
	base.ctor()
end

function yingsanzhang_play_sys.HandleLevelLoadComplete()
	base.HandleLevelLoadComplete()
	roomdata_center.SetMaxSupportPlayer(6)
	UI_Manager:Instance():ShowUiForms("yingsanzhang_ui",UiCloseType.UiCloseType_CloseOther)
	msg_manage_Inst = require("logic.poker_sys.yingsanzhang_sys.cmd_manage.yingsanzhang_msg_manage"):GetInstance()
end

function yingsanzhang_play_sys.ExitSystem()
	base.ExitSystem()
	UI_Manager:Instance():CloseUiForms("VoteQuitUI")
	UI_Manager:Instance():CloseUiForms("yingsanzhang_ui")
	msg_manage_Inst:Uninitialize()
end

function yingsanzhang_play_sys.HandlerEnterGame(msg)
	base.HandlerEnterGame()
	yingsanzhang_data_manage:GetInstance():SetRoomInfo(msg)
    map_controller.LoadLevelScene(900002,yingsanzhang_play_sys)
	sessionData = player_data.GetSessionData()
end

--加注
function yingsanzhang_play_sys.RaiseReq(nBetCoin)
	yingsanzhang_request_interface.RaiseReq(nBetCoin)
end
--跟注
function yingsanzhang_play_sys.CallReq()
	yingsanzhang_request_interface.CallReq()
end
--弃牌
function yingsanzhang_play_sys.FoldReq()
	yingsanzhang_request_interface.FoldReq()
end
--比牌
function yingsanzhang_play_sys.CompareReq(nWhoChair)
	yingsanzhang_request_interface.CompareReq(nWhoChair)
end

function yingsanzhang_play_sys.LogTest()
	logError("赢三张LogTest")
end

return yingsanzhang_play_sys
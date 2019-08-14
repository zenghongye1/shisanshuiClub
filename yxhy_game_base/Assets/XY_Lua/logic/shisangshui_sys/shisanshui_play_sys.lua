				  ---十三水协议---
---通用协议:enter,ready,leave,chat,dissolution,vote,beishu---
---独立协议:compareFinish,chooseCard,placeCard---
				---增删请维护这个---


require  "logic/network/shisanshui_request_interface"
require "logic/gameplay/cmd_shisanshui"
require "logic/shisangshui_sys/cmd_manage/shisanshui_msg_manage"

require "logic/poker_sys/utils/poker3D_dictionary"
require "logic/shisangshui_sys/common/array"
require "logic/shisangshui_sys/card_define"
require "logic/poker_sys/common/poker2d_factory"

require "logic/shisangshui_sys/Utils/sss_recommendHelper"

local base = require "logic.poker_sys.common.network.poker_play_sys"
shisanshui_play_sys = class("shisanshui_play_sys",base)

local sessionData = nil
local shisanshui_msg_manage_Inst = nil

function shisanshui_play_sys.ctor()
	base.ctor()
end

function shisanshui_play_sys.HandleLevelLoadComplete()
	base.HandleLevelLoadComplete()
	card_define.UpdateGameRuleSetting(roomdata_center.gamesetting)	--设置推荐算法规则
	roomdata_center.SetMaxSupportPlayer(8)
	UI_Manager:Instance():ShowUiForms("shisanshui_ui",UiCloseType.UiCloseType_CloseOther)
	shisanshui_msg_manage_Inst = require ("logic.shisangshui_sys.cmd_manage.shisanshui_msg_manage"):GetInstance()
end

function shisanshui_play_sys.ExitSystem()
	base.ExitSystem()
	UI_Manager:Instance():CloseUiForms("VoteQuitUI")
	UI_Manager:Instance():CloseUiForms("shisanshui_ui")
	shisanshui_msg_manage_Inst:Uninitialize()
end

function shisanshui_play_sys.HandlerEnterGame()
	base.HandlerEnterGame()
	sss_recommendHelper.SetRecommendHelper(player_data.GetGameId())   ----设置不同十三水的推荐算法,现已统一
    map_controller.LoadLevelScene(900002, shisanshui_play_sys)
	sessionData = player_data.GetSessionData()
end

--比牌动画结束发送给服务端的消息
function shisanshui_play_sys.CompareFinish()
	shisanshui_request_interface.CompareFinish(sessionData["_gt"], sessionData["_chair"])
end

--是否选择特殊牌型
function shisanshui_play_sys.ChooseCardTypeReq(nSelect)	
	shisanshui_request_interface.ChooseCardTypeReq(sessionData["_gt"], sessionData["_chair"], nSelect)
end

--摆牌
function shisanshui_play_sys.PlaceCard(cards)
	shisanshui_request_interface.PlaceCard(sessionData["_gt"], sessionData["_chair"], cards)
end

function shisanshui_play_sys.LogTest()
	logError("十三水LogTest")
end

return shisanshui_play_sys
local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameEnd = class("mahjong_action_gameEnd", base)



function mahjong_action_gameEnd:Execute(tbl)
	roomdata_center.isStart = false
	roomdata_center.beginSendCard = false
	mahjong_ui:GameEnd()
	roomdata_center.isTing=false 
	roomdata_center.playerFlowerCards = {}
	
end

return mahjong_action_gameEnd
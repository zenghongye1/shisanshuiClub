local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameGiveCard = class("mahjong_action_gameGiveCard", base)



function mahjong_action_gameGiveCard:Execute(tbl)
	mahjong_ui:HideOperTips()
end

return mahjong_action_gameGiveCard
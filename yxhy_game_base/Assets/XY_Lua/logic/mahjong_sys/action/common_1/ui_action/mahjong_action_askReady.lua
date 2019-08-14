local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_askReady = class("mahjong_action_askReady", base)



function mahjong_action_askReady:Execute(tbl)
	if not roomdata_center.isRoundStart then
		mahjong_ui:ShowReadyBtns()
	end
end

return mahjong_action_askReady
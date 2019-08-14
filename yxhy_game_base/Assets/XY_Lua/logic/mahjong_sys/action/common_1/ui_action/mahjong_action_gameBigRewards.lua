local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameBigRewards = class("mahjong_action_gameBigRewards", base)



function mahjong_action_gameBigRewards:Execute(tbl)
	mahjong_ui:HideRewards()
	-- if tbl == nil or tbl.rid == nil then
	-- 	bigSettlement_ui.Show(roomdata_center.rid)
	-- else
	-- 	bigSettlement_ui.Show(tbl.rid)
	-- end
	UI_Manager:Instance():ShowUiForms("bigSettlement_ui")
end

return mahjong_action_gameBigRewards
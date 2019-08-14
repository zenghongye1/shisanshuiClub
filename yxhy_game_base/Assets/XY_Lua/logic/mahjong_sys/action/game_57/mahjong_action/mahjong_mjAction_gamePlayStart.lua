local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_mjAction_gamePlayStart = class("mahjong_mjAction_gamePlayStart", base)



function mahjong_mjAction_gamePlayStart:Execute(tbl)
	Trace(GetTblData(tbl))
	self.compTable:HideAllFlowerInTable()
	mahjong_ui:SetAllHuaPointVisible(true)

	mahjong_anim_state_control.SetStateByName(MahjongGameAnimState.none)
end

return mahjong_mjAction_gamePlayStart
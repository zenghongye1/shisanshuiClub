local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameHuaCardUpdate_40 = class("mahjong_action_gameHuaCardUpdate_40", base)



function mahjong_action_gameHuaCardUpdate_40:Execute(tbl)
	mahjong_ui:SetFlowerCardNum(tbl[1], tbl[2])

	if tbl[1] == 1 and tbl[2] == 4 then
		mahjong_effectMgr:PlayUIEffectById(20009,mahjong_ui.playerList[1].transform.parent)
	end
end

return mahjong_action_gameHuaCardUpdate_40
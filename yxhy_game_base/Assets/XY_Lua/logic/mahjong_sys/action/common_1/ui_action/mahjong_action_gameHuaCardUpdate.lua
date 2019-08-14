local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameHuaCardUpdate = class("mahjong_action_gameHuaCardUpdate", base)



function mahjong_action_gameHuaCardUpdate:Execute(tbl)
	mahjong_ui:SetFlowerCardNum(tbl[1], tbl[2])
end

return mahjong_action_gameHuaCardUpdate
local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_game_threePeng = class("mahjong_action_game_threePeng", base)

local game_threePeng_ui = nil

function mahjong_action_game_threePeng:Execute(tbl)
	Trace(GetTblData(tbl))
	local nThreePeng = tbl._para.nThreePeng

	if game_threePeng_ui == nil then
		game_threePeng_ui = require "logic/mahjong_sys/ui_mahjong/game/game_threePeng_ui"
	end

	if nThreePeng and tonumber(nThreePeng) == 3 then
		game_threePeng_ui.Show()
	end
	
end

return mahjong_action_game_threePeng
local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_buySelfdraw = class("mahjong_action_buySelfdraw", base)

function mahjong_action_buySelfdraw:Execute(tbl)
	local nChair = tbl._para.nChair
	if nChair and nChair == self.gmlsFun() then
		mahjong_ui:ShowBuySelfdrawView()
	end
end

return mahjong_action_buySelfdraw
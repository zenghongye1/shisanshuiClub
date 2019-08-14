local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameAutoPlay = class("mahjong_action_gameAutoPlay", base)



function mahjong_action_gameAutoPlay:Execute(tbl)
	Trace(GetTblData(tbl))

	local viewSeat = self.gvblFun(tbl._src)
	local state = tbl["_para"]["setStatus"]

	if roomdata_center.isStart == true then		 
	else		
	end
	--mahjong_ui:SetPlayerMachine(viewSeat, state)
end

return mahjong_action_gameAutoPlay
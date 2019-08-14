local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_playerLeave = class("mahjong_action_playerLeave", base)



function mahjong_action_playerLeave:Execute(tbl)
	local viewSeat = self.gvblFun(tbl._src)
	if roomdata_center.isStart == true then
		--mahjong_ui:SetPlayerMachine(viewSeat, true)
	else
		mahjong_ui:HidePlayer(viewSeat)
		room_usersdata_center.RemoveUser(player_seat_mgr.GetLogicSeatByStr(tbl["_src"]))
	end

	mahjong_ui:SetPlayerReady(viewSeat, false)
end

return mahjong_action_playerLeave
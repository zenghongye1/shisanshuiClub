local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameYouStatus = class("mahjong_action_gameYouStatus", base)



function mahjong_action_gameYouStatus:Execute(tbl)
	Trace(GetTblData(tbl))
	local gvbln = player_seat_mgr.GetViewSeatByLogicSeatNum

	local viewSeat = gvbln(tbl["_para"]["nChair"])
	local status = tbl["_para"]["nStatus"]

	local aniId = 20010
	if status == 2 then -- 双游
		aniId = 20010
	elseif status ==3 then -- 三游
		aniId = 20011
	elseif status ==1 then -- 游金
		aniId = 20013
	end
	mahjong_ui:SetYoustatus(viewSeat,aniId)
end

return mahjong_action_gameYouStatus
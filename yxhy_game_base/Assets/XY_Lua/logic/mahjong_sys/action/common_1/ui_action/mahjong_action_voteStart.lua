
local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_voteStart = class("mahjong_action_voteStart", base)



function mahjong_action_voteStart:Execute(tbl)
	local viewSeat = self.gvblnFun(tbl["_para"].who)
	if viewSeat == 1 then
		roomdata_center.isSelfVote = true
	end
	local time = tbl._para.timeout
	local name = room_usersdata_center.GetUserByViewSeat(viewSeat).name
	if viewSeat ~= 1 then
		-- vote_quit_ui.Show(name, function(value) 
		-- 	mahjong_play_sys.VoteDrawReq(value)
		--  end, roomdata_center.MaxPlayer(), time)
		UI_Manager:Instance():ShowUiForms("VoteQuitUI",nil, nil, name, 
			function(value)
				mahjong_play_sys.VoteDrawReq(value)
			end, time)
	end

	-- UI_Manager:Instance():CloseUiForms("message_box")
	MessageBox.HideBox()
	mahjong_ui.voteView:Show(room_usersdata_center.GetRoomPlayerCount(),time)
end

return mahjong_action_voteStart
local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_playerOffline = class("mahjong_action_playerOffline", base)



function mahjong_action_playerOffline:Execute(tbl)
	Trace(GetTblData(tbl))
	
	local viewSeat = self.gvblFun(tbl._src)
	if tbl._para.reason~=nil and tbl._para.reason == 0 and tbl._para.active == nil  then
		if tbl._para.ingame == 1 or roomdata_center.isStart == true then
			--mahjong_ui:SetPlayerMachine(viewSeat, true)
		else
			mahjong_ui:HidePlayer(viewSeat)
		end
	elseif tbl._para.reason~=nil and tbl._para.reason == 1 and tbl._para.active ~= nil and tbl._para.active == 1 then
		mahjong_ui:SetPlayerLineState(viewSeat, false)
	elseif tbl._para.active ~= nil and tbl._para.active == 0 then
		--UpdatePlayerEnter(tbl)
		mahjong_ui:SetPlayerLineState(viewSeat, true)
		--[[
		local userdata = room_usersdata.New()
		userdata.name = tbl["_para"]["_uid"]
		userdata.coin = tbl["_para"]["score"]["coin"]
		userdata.vip  = 0
		userdata.headurl = "http://img.qq1234.org/uploads/allimg/150612/8_150612153203_7.jpg"
		room_usersdata_center.AddUser(player_seat_mgr.GetLogicSeatByStr(viewSeat,userdata)) 
		mahjong_ui:SetPlayerInfo(viewSeat,userdata)]]
	else
		mahjong_ui:SetPlayerLineState(viewSeat, false)
	end
end
 
return mahjong_action_playerOffline
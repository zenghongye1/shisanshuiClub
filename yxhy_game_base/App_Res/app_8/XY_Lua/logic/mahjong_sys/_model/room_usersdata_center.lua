--[[--
 * @Description: 房间玩家数据缓存中心
 * @Author:      ShushingWong
 * @FileName:    room_usersdata_center.lua
 * @DateTime:    2017-06-19 15:25:45
 ]]


require "logic/mahjong_sys/utils/player_seat_mgr"

room_usersdata_center = {}
local this = room_usersdata_center

local usersDataList = {}
local tempUserDataList = {}

function this.SetMyLogicSeat( serverSeat )
	player_seat_mgr.SetMyServerSeatId(serverSeat)
end

function this.AddUser( logicSeat ,userdata)
	usersDataList[logicSeat] = userdata
	tempUserDataList[logicSeat] = userdata
end

function this.RemoveUser(logicSeat)
	if usersDataList[logicSeat] ~= nil then
		usersDataList[logicSeat] = nil
	end
end

function this.RemoveAll()
	usersDataList = {}
end

function this.GetRoomPlayerCount()
	local count = 0
--	if usersDataList ~= nil then
--		count = #usersDataList
--	end
	count = Utils.get_length_from_any_table(usersDataList)
	return count
end

function this.GetUserByLogicSeat( logicSeat )
	return usersDataList[logicSeat]
end

function this.GetTempUserByLogicSeat(LogicSeat)
	return tempUserDataList[LogicSeat]
end

function this.GetUserByUid(uid)
	for i, v in pairs(usersDataList) do
		if tonumber(v.uid) == tonumber(uid) then
			return v
		end
	end
end

function this.GetUserByViewSeat( viewSeat )
	local logicSeat = player_seat_mgr.GetLogicSeatNumByViewSeat(viewSeat)

	if logicSeat>roomdata_center.MaxPlayer() then
		logicSeat = logicSeat-roomdata_center.MaxPlayer()
	elseif logicSeat<1 then
		logicSeat = logicSeat+roomdata_center.MaxPlayer()
	end

	return usersDataList[logicSeat], logicSeat
end




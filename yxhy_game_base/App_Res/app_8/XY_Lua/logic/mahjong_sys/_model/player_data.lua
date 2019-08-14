--[[--
 * @Description: 玩家自己相关数据
 * @Author:      ShushingWong
 * @FileName:    player_data.lua
 * @DateTime:    2017-06-20 17:18:06
 ]]

require "logic/mahjong_sys/_model/room_usersdata_center"
player_data = {}

local this = player_data

local sessionData = {}

local gidTbl = {}

local para = {}

--[[--
 * @Description: 
   {"_cmd":"session","_para":{"_chair":4,"_gid":4,"_glv":"","_gsc":"default","_gt":0},"_src":"t","_st":"nti"}  
 ]]
function this.SetSessionData(msg)
	sessionData["_chair"] = msg["_para"]._chair
	sessionData["_gid"] = msg["_para"]._gid
	sessionData["_glv"] = msg["_para"]._glv
	sessionData["_gsc"] = msg["_para"]._gsc
	sessionData["_gt"] = msg["_para"]._gt

	room_usersdata_center.SetMyLogicSeat(sessionData["_chair"])
end

function this.ReSetSessionData(msg)
	sessionData["_chair"] = msg._dst._chair
	sessionData["_gid"] = msg._dst._gid
	sessionData["_glv"] = msg._dst._glv
	sessionData["_gsc"] = msg._dst._gsc
	sessionData["_gt"] = msg._dst._gt

	room_usersdata_center.SetMyLogicSeat(sessionData["_chair"])
end

--[[--
 * @Description: 设置gid列表，进入游戏时候使用  
 ]]
function this.SetGidTbl(_gidTbl)
	gidTbl = _gidTbl
end

--[[--
 * @Description: 设置重连参数  
 ]]
function this.SetReconnectEpara(epara)
	para = epara
end

function this.GetReconnetEpara()
	return para
end

function this.GetSessionData()
	return sessionData
end

function this.GetGameId()
	return sessionData["_gid"]
end

function this.GetUserLogicSeat()
	return sessionData["_chair"]
end

function this.GetGidTbl()
	return gidTbl
end
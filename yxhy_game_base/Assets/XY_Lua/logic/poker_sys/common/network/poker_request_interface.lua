require "logic/poker_sys/common/network/poker_request_protocol"
poker_request_interface = {}
local this = poker_request_interface

--进入游戏请求
function this.EnterGameReq(gameData)
	local userInfo =  data_center.GetLoginUserInfo()
	local session_key = userInfo.sessionkey
	local srvName = ""
	local srvID = nil

	if gameData._dst ~= nil then
		srvName = gameData._dst._svr_t
		srvID = gameData._dst._svr_id
	else
		srvName = gameData._svr_t 
		srvID = gameData._svr_id
		if not srvName and not srvID then
			srvName = "chess"
			srvID = 1
		end
	end

	local urlStr = string.format(global_define.gamewsurl, srvName, srvID, data_center.GetLoginUserInfo().uid, session_key)

	SocketManager:createSocket("game",urlStr,srvName,tonumber(srvID),gameData._dst)
	SocketManager:onGameOpenCallBack(function()
		local pkgBuffer = poker_request_protocol.EnterGameReq(gameData,gameData._dst)
		Trace("EnterGameReq pkgBuffer================"..GetTblData(pkgBuffer))
		network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
	end)  
end

--准备请求
function this.ReadyGameReq(_tableId, _seat)
    local pkgBuffer = poker_request_protocol.ReadyGame(_tableId, _seat)
    Trace("ReadyGameReq pkgBuffer================"..tostring(pkgBuffer))
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--准备请求
function this.ApplyForReq(nChair, bStatus)
    local pkgBuffer = poker_request_protocol.ApplyForGame(nChair, bStatus)
    Trace("ReadyGameReq pkgBuffer================"..tostring(pkgBuffer))
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

----解散请求
function this.Dissolution(gid,tableid,seat)
    local pkgBuffer = poker_request_protocol.requestDissolution(gid,tableid, seat)
    Trace("Dissolution pkgBuffer==============="..tostring(pkgBuffer))
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--投票请求
function this.VoteDrawReq(flag,tableID,seat)
    local pkgBuffer = poker_request_protocol.requestVoteDraw(flag,tableID,seat)
    Trace("VoteDrawReq pkgBuffer==================================="..tostring(pkgBuffer))
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--离桌请求
function this.LeaveReq()
     local pkgBuffer = poker_request_protocol.requestLeave()
     Trace("LeaveReq pkgBuffer==================================="..tostring(pkgBuffer))
	 network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--聊天请求
function this.ChatReq(contenttype,content,tableID,seat,givewho)
    local pkgBuffer = poker_request_protocol.requestChat(contenttype,content,tableID,seat,givewho)
	Trace("ChatReq pkgBuffer==================================="..tostring(pkgBuffer))
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--选择倍数
function this.MultReq(beishu,tableID,seat)
    local pkgBuffer = poker_request_protocol.requestMult(beishu,tableID,seat)
    Trace("pkgBuffer================"..tostring(pkgBuffer));
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--选庄(固定庄家)
function this.ChooseBankerReq(_tableId,_seat)
	local pkgBuffer = poker_request_protocol.ChooseBankerReq(_tableId,_seat)
	Trace("pkgBuffer================"..tostring(pkgBuffer))
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)	
end

--抢庄
function this.robbankerReq(beishu,tableID,seat)
	local pkgBuffer = poker_request_protocol.robbankerReq(beishu,tableID,seat)
    Trace("pkgBuffer================"..tostring(pkgBuffer))
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

--亮牌
function this.OpenCardReq()
	local pkgBuffer = poker_request_protocol.OpenCardReq()
    Trace("pkgBuffer================"..tostring(pkgBuffer))
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end
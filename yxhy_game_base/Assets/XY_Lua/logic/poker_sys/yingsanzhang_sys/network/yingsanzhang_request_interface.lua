require "logic/poker_sys/yingsanzhang_sys/network/yingsanzhang_request_protocol"
require "logic/network/messagedefine"

yingsanzhang_request_interface = {}
local this = yingsanzhang_request_interface

--加注
function this.RaiseReq(nBetCoin)
	local pkgBuffer = yingsanzhang_request_protocol.RaiseReq(nBetCoin)
	Trace("pkgBuffer================"..tostring(pkgBuffer));
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end
--跟注
function this.CallReq()
	local pkgBuffer = yingsanzhang_request_protocol.CallReq()
	Trace("pkgBuffer================"..tostring(pkgBuffer));
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end
--弃牌
function this.FoldReq()
	local pkgBuffer = yingsanzhang_request_protocol.FoldReq()
	Trace("pkgBuffer================"..tostring(pkgBuffer));
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end
--比牌
function this.CompareReq(nWhoChair)
	local pkgBuffer = yingsanzhang_request_protocol.CompareReq(nWhoChair)
	Trace("pkgBuffer================"..tostring(pkgBuffer));
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end












  
require "logic/network/shisanshui_request_protocol"
require "logic/network/messagedefine"

shisanshui_request_interface = {}
local this = shisanshui_request_interface

---比牌结束
function this.CompareFinish(_tableId,_seat)
	local pkgBuffer = shisanshui_request_protocol.cancel_compare(_tableId, _seat);
    Trace("pkgBuffer================"..tostring(pkgBuffer));
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

---出特殊牌型
function this.ChooseCardTypeReq(_tableId, _seat, nSelect)
    local pkgBuffer = shisanshui_request_protocol.ChooseCardType(_tableId, _seat, nSelect);
    Trace("pkgBuffer================"..tostring(pkgBuffer));
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

---摆牌
function this.PlaceCard(_tableId, _seat, cards)
    local pkgBuffer = shisanshui_request_protocol.PlaceCard(_tableId, _seat, cards);
    Trace("pkgBuffer================"..tostring(pkgBuffer));
    network_mgr.sendPkgNoWaitForRsp(network_mgr.CMD_LOGIN_HALL,pkgBuffer)
end

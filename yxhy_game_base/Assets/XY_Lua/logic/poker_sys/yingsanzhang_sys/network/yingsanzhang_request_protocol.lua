require "logic/network/messagedefine"
require "logic/common_ui/fast_tip"
yingsanzhang_request_protocol = {}
local this = yingsanzhang_request_protocol


--加注
function this.RaiseReq(nBetCoin)
	local eventTbl = {}
	local paraTbl = {}
	--events
	eventTbl[messagedefine.EField_EID] = "raise"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	paraTbl.nBetCoin = nBetCoin
	return eventTbl
end

--跟注
function this.CallReq()
	local eventTbl = {}
	local paraTbl = {}
	--events
	eventTbl[messagedefine.EField_EID] = "call"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	return eventTbl
end

--弃牌
function this.FoldReq()
	local eventTbl = {}
	local paraTbl = {}
	--events
	eventTbl[messagedefine.EField_EID] = "fold"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	return eventTbl
end

--比牌，和谁比。
function this.CompareReq(nWhoChair)
	local eventTbl = {}
	local paraTbl = {}
	--events
	eventTbl[messagedefine.EField_EID] = "compare"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	paraTbl.nWhoChair = nWhoChair
	return eventTbl
end



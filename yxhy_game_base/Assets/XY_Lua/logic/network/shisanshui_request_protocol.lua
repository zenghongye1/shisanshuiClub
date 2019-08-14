require "logic/network/messagedefine"

shisanshui_request_protocol = {}
local this = shisanshui_request_protocol

--------------------------------
-- @TER0512
-- @des: 选特殊牌型
-- @param: xx
function this.ChooseCardType(_tableID, _seat, nSelect)

	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "choose_sp"
	msgTbl[messagedefine.EField_Ver] = 1
	
	msgTbl[messagedefine.EField_Session] = sessionTbl
	sessionTbl[messagedefine.EField_TableID] = _tableID
	sessionTbl[messagedefine.EField_SeatID] = _seat
	--events
	
	eventTbl[messagedefine.EField_EID] = "choose_sp"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	paraTbl.nSelect = nSelect

	return eventTbl
end

--------------------------------
-- @TER0512
-- @des: 摆牌
-- @param: xx
function this.PlaceCard(_tableID, _seat, cards)

	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "choose_normal"
	msgTbl[messagedefine.EField_Ver] = 1
	msgTbl[messagedefine.EField_Session] = sessionTbl
	sessionTbl[messagedefine.EField_TableID] = _tableID
	sessionTbl[messagedefine.EField_SeatID] = _seat
	--events
	
	eventTbl[messagedefine.EField_EID] = "choose_normal"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	paraTbl.cards = cards

	return eventTbl
end


---比牌动画完成通知服务器
function this.cancel_compare(_tableID,_seat)

	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "cancle_compare"
	msgTbl[messagedefine.EField_Ver] = 1

	msgTbl[messagedefine.EField_Session] = sessionTbl
	sessionTbl[messagedefine.EField_TableID] = _tableID
	sessionTbl[messagedefine.EField_SeatID] = _seat
	--events
	
	eventTbl[messagedefine.EField_EID] = "cancle_compare"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	
	return eventTbl	
end
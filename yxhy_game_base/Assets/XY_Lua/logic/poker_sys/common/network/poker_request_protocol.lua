poker_request_protocol = {}
local this  = poker_request_protocol

-- @des: 请求进入游戏
-- @param: _app_id(应用id), gameData(php下发房间数据)
function this.EnterGameReq(gameData,dst)
	local msgTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	local saved = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "enter"
	msgTbl[messagedefine.EField_Ver] = 1
	msgTbl[messagedefine.EField_Session] = gameData[messagedefine.EField_Session] or {}
	--重入
	if dst ~= nil then
		msgTbl[messagedefine.EField_Session] = dst
	end
	--events
	eventTbl[messagedefine.EField_EID] = "enter"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	paraTbl[messagedefine.EField_Rule] = "default"	 -- 固定值
	paraTbl["_gid"] = gameData.gid
	paraTbl[messagedefine.EField_SitMode] = "byCard" 	----根据什么来找房, 支持bykey, byid, 但对应的字段得带上
	paraTbl[messagedefine.EFiled_TableKey] = "" 	---房间key, 是php用base64(AES）
	paraTbl[messagedefine.EField_TableConfig] = gameData 	----房间配置
	paraTbl["saved"] = saved
	saved.latitude = player_data.localtionData.latitude
	saved.longitude = player_data.localtionData.longitude
	
	return eventTbl
end

-- @TER0419
-- @des: 请求准备游戏
-- @param: _tableID(桌位ID), _seat(座位)
function this.ReadyGame(_tableID, _seat)
	local eventTbl = {}
	local paraTbl = {}

	--events
	eventTbl[messagedefine.EField_EID] = "ready"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	return eventTbl
end

-- @TER0419
-- @des: 请求准备游戏
-- @param: _tableID(桌位ID), _seat(座位)
function this.ApplyForGame(nChair, bStatus)
	local eventTbl = {}
	local paraTbl = {}
	paraTbl.nChair = nChair
	paraTbl.bStatus = bStatus
	--events
	eventTbl[messagedefine.EField_EID] = "applyfor"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	return eventTbl
end

-- 房主解散房间
function this.requestDissolution(gid,tableid,seat)
	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "dissolution"
	msgTbl[messagedefine.EField_Ver] = 1
	msgTbl[messagedefine.EField_Session] = sessionTbl
	sessionTbl[messagedefine.EField_TableID] = tableid
	sessionTbl[messagedefine.EField_SeatID] = seat
	--events
	eventTbl[messagedefine.EField_EID] = "dissolution"
	eventTbl[messagedefine.EField_EType] = "req"
	eventTbl[messagedefine.EField_EPath] = "p1"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	paraTbl["gid"] = gid
	paraTbl[messagedefine.EField_Rule] = "default"
	return eventTbl

end

--请求合局
function this.requestVoteDraw(flag,tableID,seat)
	if not tableID or not seat  then
		return
	end
	local acceptStatus = false
	if flag == true then
		acceptStatus = true
	end
	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "vote_draw"
	msgTbl[messagedefine.EField_Ver] = 1
	msgTbl[messagedefine.EField_Session] = sessionTbl
	sessionTbl[messagedefine.EField_TableID] = tableID
	sessionTbl[messagedefine.EField_SeatID] = seat
	--events
	eventTbl[messagedefine.EField_EID] = "vote_draw"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	paraTbl["accept"] = acceptStatus
	return eventTbl
end

--玩家退出
function this.requestLeave()
	local eventTbl = {}
	local paraTbl = {}
	--events
	eventTbl[messagedefine.EField_EID] = "leave"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl

	return eventTbl
end

function this.requestChat(contenttype,content,tableID,seat,givewho)
	if not tableID or not seat  or not contenttype or not content then
		return
	end

	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "chat"
	msgTbl[messagedefine.EField_Ver] = 1
	msgTbl[messagedefine.EField_Session] = sessionTbl
	sessionTbl[messagedefine.EField_TableID] = tableID
	sessionTbl[messagedefine.EField_SeatID] = seat
	--events
	
	eventTbl[messagedefine.EField_EID] = "chat"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	paraTbl["contenttype"] = contenttype
	paraTbl["content"] = content
	paraTbl["givewho"] = givewho

	return eventTbl
end

-- @des: 请求下注倍数
-- @param:beishu(倍数) _tableID(桌位ID), _seat(座位)
function this.requestMult(beishu, tableID, seat)
	if not beishu  or  not tableID or  not seat then 
		return
	end
	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "mult"
	msgTbl[messagedefine.EField_Ver] = 1
	msgTbl[messagedefine.EField_Session] = sessionTbl
	sessionTbl[messagedefine.EField_TableID] = tableID
	sessionTbl[messagedefine.EField_SeatID] = seat
	--events
	
	eventTbl[messagedefine.EField_EID] = "mult"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	paraTbl["nBeishu"] = beishu

	return eventTbl	
end

-- @des: 请求我要做庄
-- @param: _tableID(桌位ID), _seat(座位)
function this.ChooseBankerReq(_tableID,_seat)
	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	local sessionTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "choosebanker"
	msgTbl[messagedefine.EField_Ver] = 1
	msgTbl[messagedefine.EField_Session] = sessionTbl
	sessionTbl[messagedefine.EField_TableID] = _tableID
	sessionTbl[messagedefine.EField_SeatID] = _seat
	--events
	eventTbl[messagedefine.EField_EID] = "choosebanker"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	return eventTbl
end

-- @des: 请求我抢庄
-- @param: _tableID(桌位ID), _seat(座位)
function this.robbankerReq(beishu,tableID,seat)
	if not beishu  or  not tableID or  not seat then 
		return
	end
	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "robbanker"
	msgTbl[messagedefine.EField_Ver] = 1
	msgTbl[messagedefine.EField_Session] = sessionTbl
	sessionTbl[messagedefine.EField_TableID] = tableID
	sessionTbl[messagedefine.EField_SeatID] = seat
	--events
	eventTbl[messagedefine.EField_EID] = "robbanker"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	paraTbl["nBeishu"] = beishu
	return eventTbl	
end

-- @des: 请求我要看牌
-- @param:
function this.OpenCardReq()
	local eventTbl = {}
	local paraTbl = {}

	--events
	eventTbl[messagedefine.EField_EID] = "opencard"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	return eventTbl
end
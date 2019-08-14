--region *.lua
--Date
--Create by xuemin.lin

--endregion

require "logic/network/messagedefine"
 require "logic/common_ui/fast_tip"
shisanshui_request_protocol = {}
local this = shisanshui_request_protocol

--消息头
function this.GetMsgHead(urlValue)
	-- return string.format("host=dstars&uri=%s&msgid=http_req@@@@", urlValue or "/chess/1")
	return ""
end

function this.EnterGameReq(urlValue, gameData, dst)
	local strMsgHead = this.GetMsgHead(urlValue)
	
	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	local configTbl = {}
	local cfgTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "enter"
	msgTbl[messagedefine.EField_Ver] = 1
	msgTbl[messagedefine.EField_Session] = gameData[messagedefine.EField_Session] or {}
	--重入
	if dst ~= nil then
		msgTbl[messagedefine.EField_Session] = dst
	--sessionTbl[messagedefine.EField_TableID] = 0
	--sessionTbl[messagedefine.EField_SeatID] = 1
	end
	--events
	
	eventTbl[messagedefine.EField_EID] = "enter"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl

	paraTbl[messagedefine.EField_Rule] = "default" -- 固定值
	paraTbl["_gid"] = gameData.gid
	paraTbl[messagedefine.EField_SitMode] = "byCard" ---- 根据什么来找房, 支持bykey, byid, 但对应的字段得带上
	--Trace("gameData.table_key-------------------------------"..tostring(gameData.table_key))
	paraTbl[messagedefine.EFiled_TableKey] = "" ---- 房间key, 是php用base64(AES）
	paraTbl[messagedefine.EField_TableConfig] = configTbl ---- 房间配置
	configTbl["accountc"] = gameData["account"] or {}
	configTbl["cfg"] = cfgTbl
	cfgTbl["nGhostAdd"] = gameData["nGhostAdd"]
	cfgTbl["nColorAdd"] = gameData["nColorAdd"]
	cfgTbl["pnum"] = gameData["pnum"]
	cfgTbl["rounds"] = gameData["rounds"]
	cfgTbl["nBuyCode"] = gameData["nBuyCode"]
	cfgTbl["nWaterBanker"] = gameData["nWaterBanker"]
	cfgTbl["nMaxMult"] = gameData["nMaxMult"]
	configTbl["clog"] = {}
	configTbl["cost"] = "2"
	configTbl["ctime"] = "1498533736"
	
	configTbl["expiretime"] = "1498540936"
	configTbl["gamedir"] = "G_3"
	configTbl["gid"] = gameData.gid
	configTbl["log"] = ""
	configTbl["rid"] = gameData["rid"] or ""
	configTbl["rno"] = gameData["rno"]
	configTbl["status"] = "0"
	configTbl["uid"] = gameData["uid"]
	configTbl["uri"] = gameData["uri"] or "/chess/1"
	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
	-- return strMsg
	return eventTbl
end

--------------------------------
-- @TER0419
-- @des: 请求准备游戏
-- @param: _tableID(桌位ID), _seat(座位)
function this.ReadyGame(urlValue, _tableID, _seat)
	--[[if not _tableID or not _seat then
		messagedefine.log("readyGame error: ", _tableID, _seat)
		return
	end]]

	local strMsgHead = this.GetMsgHead(urlValue)

	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "ready"
	msgTbl[messagedefine.EField_Ver] = 1

	msgTbl[messagedefine.EField_Session] = sessionTbl
	sessionTbl[messagedefine.EField_TableID] = _tableID
	sessionTbl[messagedefine.EField_SeatID] = _seat
	--events
	
	eventTbl[messagedefine.EField_EID] = "ready"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	
	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
	return eventTbl
end

--------------------------------
-- @TER0512
-- @des: 选特殊牌型
-- @param: xx
function this.ChooseCardType(urlValue, _tableID, _seat, nSelect)
	local strMsgHead = this.GetMsgHead(urlValue)

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

	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
	return eventTbl
end

--------------------------------
-- @TER0512
-- @des: 进入大厅查询游戏状态(重连)
-- @param: xx
function this.QueryGameState(urlValue)
	local strMsgHead = this.GetMsgHead(urlValue)

	local msgTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "query_state"
	msgTbl[messagedefine.EField_Ver] = 1
	--events
	
	eventTbl[messagedefine.EField_EID] = "query_state"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl

	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
	return eventTbl
end

--------------------------------
-- @TER0512
-- @des: 摆牌
-- @param: xx
function this.PlaceCard(urlValue, _tableID, _seat, cards)
	local strMsgHead = this.GetMsgHead(urlValue)

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

	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
	return eventTbl
end



--------------------------------
-- @TER0512
-- @des: 心跳
-- @param: xx
function this.HeartBeat(urlValue, heartBeatsession)
	if not heartBeatsession then return end
	local strMsgHead = this.GetMsgHead(urlValue)

	local msgTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "heart_beat"
	msgTbl[messagedefine.EField_Ver] = 1
	msgTbl[messagedefine.EField_Session] = heartBeatsession
	--events
	
	eventTbl[messagedefine.EField_EID] = "heart_beat"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	
	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
	return eventTbl
end

function this.readyGame( urlValue, _tableID, _seat)
	if not _tableID or not _seat then
		return
	end
     local strMsgHead = this.GetMsgHead(urlValue)

	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "ready"
	msgTbl[messagedefine.EField_Ver] = 1
	msgTbl[messagedefine.EField_Session] = sessionTbl
	sessionTbl[messagedefine.EField_TableID] = _tableID
	sessionTbl[messagedefine.EField_SeatID] = _seat
	--events
	
	eventTbl[messagedefine.EField_EID] = "ready"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl

	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
    
	return eventTbl
end

--比牌动画完成通知服务器
function this.cancel_compare(urlValue,_tableID,_seat)
	local strMsgHead = this.GetMsgHead(urlValue)

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
	
	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
	return eventTbl
	
end

function this.requestMult(urlValue,beishu, tableID, seat)
	if not beishu  or  not tableID or  not seat then 
		return
	end
	
	local strMsgHead = this.GetMsgHead(urlValue)
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

	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
	return eventTbl	
end

function this.requestOutCard(urlValue,cardValue,tableID,seat)
	if not cardValue  or  not tableID or  not seat then 
		return
	end
	
	local strMsgHead = this.GetMsgHead(urlValue)
	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "play"
	msgTbl[messagedefine.EField_Ver] = 1
	msgTbl[messagedefine.EField_Session] = sessionTbl
	sessionTbl[messagedefine.EField_TableID] = tableID
	sessionTbl[messagedefine.EField_SeatID] = seat
	--events
	
	eventTbl[messagedefine.EField_EID] = "play"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	paraTbl["cards"] = {cardValue}

	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
	return eventTbl	
end


function this.requestHu(urlValue,cardValue,tableID,seat)
	if not cardValue  or  not tableID or  not seat then 
		return
	end
	 local strMsgHead = this.GetMsgHead(urlValue)
	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "win"
	msgTbl[messagedefine.EField_Ver] = 1
	msgTbl[messagedefine.EField_Session] = sessionTbl
	sessionTbl[messagedefine.EField_TableID] = tableID
	sessionTbl[messagedefine.EField_SeatID] = seat
	--events
	
	eventTbl[messagedefine.EField_EID] = "win"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	paraTbl["cardWin"] = cardValue

	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
	return eventTbl	
end



function this.requestTing(urlValue,cardValue,tableID,seat)
	if not cardValue  or  not tableID or  not seat then 
		return
	end
	
	local strMsgHead = this.GetMsgHead(urlValue)
	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "ting"
	msgTbl[messagedefine.EField_Ver] = 1
	msgTbl[messagedefine.EField_Session] = sessionTbl
	sessionTbl[messagedefine.EField_TableID] = tableID
	sessionTbl[messagedefine.EField_SeatID] = seat
	--events
	
	eventTbl[messagedefine.EField_EID] = "ting"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	paraTbl["card"] = cardValue

	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
	return eventTbl
end

--碰牌
function this.requestTriplet(urlValue,cardTab,tableID,seat)
	if not cardTab  or  not tableID or  not seat then 
		messagedefine.log("requestTriplet------error")
		return
	end
	
	local strMsgHead = this.GetMsgHead(urlValue)
	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "triplet"
	msgTbl[messagedefine.EField_Ver] = 1
	msgTbl[messagedefine.EField_Session] = sessionTbl
	sessionTbl[messagedefine.EField_TableID] = tableID
	sessionTbl[messagedefine.EField_SeatID] = seat
	--events
	
	eventTbl[messagedefine.EField_EID] = "triplet"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	paraTbl["cardTriplet"] = cardTab

	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
	return eventTbl	
end

--杠
function this.requestQuadruplet(urlValue,cardTab,tableID ,seat)
	if not cardTab  or  not tableID or  not seat then 
		return
	end
	
	local strMsgHead = this.GetMsgHead(urlValue)
	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "quadruplet"
	msgTbl[messagedefine.EField_Ver] = 1
	msgTbl[messagedefine.EField_Session] = sessionTbl
	sessionTbl[messagedefine.EField_TableID] = tableID
	sessionTbl[messagedefine.EField_SeatID] = seat
	--events
	
	eventTbl[messagedefine.EField_EID] = "quadruplet"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	paraTbl["cardQuadruplet"] = cardTab

	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
	return eventTbl	
end

--吃
function this.requestCollect(urlValue,cardTab,tableID,seat)
	if not cardTab  or  not tableID or  not seat then 
		return
	end
	
	local strMsgHead = this.GetMsgHead(urlValue)
	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "collect"
	msgTbl[messagedefine.EField_Ver] = 1
	msgTbl[messagedefine.EField_Session] = sessionTbl
	sessionTbl[messagedefine.EField_TableID] = tableID
	sessionTbl[messagedefine.EField_SeatID] = seat
	--events
	
	eventTbl[messagedefine.EField_EID] = "collect"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl
	paraTbl["cardCollect"] = cardTab

	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
	return eventTbl
end

--过
function this.requestGiveUp(urlValue,tableID,seat)
	if not tableID or  not seat then 
		return
	end
	
	local strMsgHead = this.GetMsgHead(urlValue)
	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "giveup"
	msgTbl[messagedefine.EField_Ver] = 1
	msgTbl[messagedefine.EField_Session] = sessionTbl
	sessionTbl[messagedefine.EField_TableID] = tableID
	sessionTbl[messagedefine.EField_SeatID] = seat
	--events
	
	eventTbl[messagedefine.EField_EID] = "giveup"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl

	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
	return eventTbl	
end

--请求合局
function this.requestVoteDraw(urlValue, flag ,tableID,seat)
	if not tableID or not seat  or not flag then
		return
	end
	local acceptStatus = false
	if flag == 1 then
		acceptStatus = true
	end
	
	local strMsgHead = this.GetMsgHead(urlValue)
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

	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
	return eventTbl
end

--玩家退出
function this.requestLeave(urlValue,tableID,seat)
	if not tableID or not seat  then
		return
	end

	local strMsgHead = this.GetMsgHead(urlValue)
	local msgTbl = {}
	local sessionTbl = {}
	local eventTbl = {}
	local paraTbl = {}
	--msg
	msgTbl[messagedefine.EField_Sn] = "leave"
	msgTbl[messagedefine.EField_Ver] = 1
	msgTbl[messagedefine.EField_Session] = sessionTbl
	sessionTbl[messagedefine.EField_TableID] = tableID
	sessionTbl[messagedefine.EField_SeatID] = seat
	--events
	
	eventTbl[messagedefine.EField_EID] = "leave"
	eventTbl[messagedefine.EField_EType] = "req"
	--para
	eventTbl[messagedefine.EField_EPara] = paraTbl

	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
	return eventTbl
end


-- 房主解散房间
function this.requestDissolution( urlValue, gid, tableid, seat )
	local strMsgHead = this.GetMsgHead(urlValue)
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
	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
	return eventTbl

end


function this.requestChat(urlValue, contenttype,content,tableID,seat,givewho)
	if not tableID or not seat  or not contenttype or not content then
		return
	end

	local strMsgHead = this.GetMsgHead(urlValue)
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

	-- local strMsg = strMsgHead..CombinJsonStr(msgTbl)
	return eventTbl
end




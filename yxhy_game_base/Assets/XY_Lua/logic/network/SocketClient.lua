

local SocketClient = class("SocketClient")


--	ERRORLOG  输出错误日志 需要替换
--  DEBUGLOG  输出调试日志 需要替换


local NetStatus = {
	closed = "closed", -- 已关闭

	connecting = "connecting", -- 正在连接
	connected = "connected", -- 已连接
	
	reconnect = "reconnect", -- 重连
	
	stoped = "stoped" , -- 连接停止了
}
local DEBUGLOG = LogW
local ERRORLOG = LogW


netCoroutine = nil 

function SocketClient:ctor(_chlName, _addr, _timeout, _maxRetryTimes)
	self:Init(_chlName, _addr, _timeout, _maxRetryTimes)
end


function SocketClient:Init(_chlName, _addr, _timeout, _maxRetryTimes )
	self._chlName = _chlName
	self._addr = _addr .. "&chl=" .. _chlName
	self._svrName = ""
	self._svrID = -1
	self._dst = nil
	self._timeout = tonumber(_timeout)
	if not self._timeout or self._timeout < 1 or self._timeout > 5 then
		self._timeout = 3
	end
	self._maxRetryTimes = tonumber(_maxRetryTimes)
	if not self._maxRetryTimes or self._maxRetryTimes < 1  then
		self._maxRetryTimes = 10000
	end

	DEBUGLOG(self._chlName, ": " , "timeout: ", self._timeout, "maxRetryTimes: ", self._maxRetryTimes)
	
	self._retryTimes = 0
	-- 接收数据回调
	self._rcvCallback = nil
	-- 网络状态回调
	self._statusCallback = nil
	
	self._lastReconnectTime = 0
	
	self._leaveTime = 0
	self._wsocket = nil
	self._lastSendTime = os.time()
	self._lastRecvTime = self._lastSendTime

	self.heartTimer = nil

	self:clearSocket(true)
	DEBUGLOG(self._chlName, ": " , "Init: ", self._svrName, "ID: ", self._svrID, "Dst:", self._dst)
end


function SocketClient:BindingServer(_svrName, _svrID, _dst)
	self._svrName = _svrName
	self._svrID = _svrID
	self._dst = _dst
	DEBUGLOG(self._chlName, ": " , "BindingServer: ", self._svrName, "ID: ", self._svrID, "Dst:", self._dst)

end

function SocketClient:SetDst(_dst)
	self._dst = _dst

end
-- @TER0419
-- @des: 清理socket状态数据
-- @param: xx 
function SocketClient:clearSocket(needReconnect)
	if self._wsocket then
		
		self._wsocket.OnOpen =  nil
		self._wsocket.OnMessage =  nil
		self._wsocket.OnClosed =  nil
		self._wsocket.OnError =  nil
		self._wsocket.OnErrorDesc = nil
		self._wsocket:Close()
		self._wsocket = nil
	end
	DEBUGLOG(self._chlName, ": " , "ClearSocket,status = ", self._connectStatus," needReconnect = ", needReconnect)
	self._connectStatus = NetStatus.closed
	
	self._lastSN = -1
	self._checkList = {}
	self._checkNum = 10000
end
--------------------------------
-- @TER0419
-- @des: 请求连接服务器，



function SocketClient:connect()
	--[[if self._chlName== "game" then
		coroutine.start(function ()	
			while(self._wsocket ~= nil and self._wsocket.IsOpen)			
			do
				self:clearSocket(false)
				coroutine.wait(0.5)
			end
		end)
	end]]
	DEBUGLOG(self._chlName, ": " , "连接服务器..", self._addr)

	if self._wsocket then
		self:clearSocket(false)
	end	

	if not self._addr or self._addr == "" then
		ERRORLOG(self._chlName, ": " ,"Server addr is null")
		return false
	end
	
	--修改成cs导出的接口
	self._wsocket = WebSocket.New(Uri.New(self._addr))


	-- create ws
	if not self._wsocket then
		ERRORLOG(self._chlName, ": " ,"WebSocket:create failed")
		self:close()
		return false
	else
		self._lastSendTime = os.time()
		self._lastRecvTime = self._lastSendTime
		self._lastHeartBeatTime = os.time()
		self._connectStatus = NetStatus.connecting
	end
	
	
	-- gt.showLoading(true, gt.getLocationString("server_reconnect_tips"))


	self:OnStatusCallback(NetStatus.connecting)
	
	local wsOpen = function(_ws)
		if self._connectStatus == NetStatus.connected then
			ERRORLOG(self._chlName, ": " , "self._connectStatus is already connected.")	
			return
		end
	    DEBUGLOG(self._chlName, ": " , "websocket is connected.")
		self._lastSendTime = os.time()
		self._lastRecvTime = self._lastSendTime
		self._retryTimes = 0

		self:OnStatusCallback(NetStatus.connected)
		self._connectStatus = NetStatus.connected
		--self:sendHeartBeat()
		if _chlName == "game" then
			self:sendHeartBeat()
		else
			self:SendHallHeartBeat()
		end
	end

	local wsMessage = function(_ws, strData)
	   -- DEBUGLOG(self._chlName, ": " , "websocket receive data..", strData, self._connectStatus )
		
	    self._lastRecvTime = os.time()


	    local res, needReconnect 
	    if self._chlName == "game" then
	     	res, needReconnect = self:OnRecvData(strData)
	    else
	    	res, needReconnect = self:OnRecvHallData(strData)
	    end
	    --DEBUGLOG(self._chlName, ": " , "wsMessage time", self._lastRecvTime, self._lastSendTime)
	    if res == false then
	    	if needReconnect then
	    		self:clearSocket(needReconnect)
	    	else
	    		self:close()
	    	end
		end
	end

	local wsClose = function(_ws)
		-- gt.showLoading(false)
	    DEBUGLOG(self._chlName, ": " , "websocket instance closed.", strData)
		self:OnStatusCallback(NetStatus.closed)
	    self:clearSocket(true)
	end

	local wsError = function(_ws,ex)
		-- gt.showLoading(false)
	    DEBUGLOG(self._chlName, ": " , "websocket error!", strData, "status ", self._connectStatus)

		self:clearSocket(true)

		-- if self._rcvCallback then
		-- 	self._rcvCallback(cc.WEBSOCKET_ERROR)
		-- end
	end

	local wsErrorDesc = function(_ws,errMsg)
		-- gt.showLoading(false)
	    DEBUGLOG(self._chlName, ": " , "websocket wsErrorDesc!", strData, "status ", self._connectStatus, "errMsg ",errMsg)

		self:clearSocket(true)

		-- if self._rcvCallback then
		-- 	self._rcvCallback(cc.WEBSOCKET_ERROR)
		-- end
	end
	-- register
	-- 修改成cs导出的绑定回调
     self._wsocket.OnOpen =  wsOpen
     self._wsocket.OnMessage =  wsMessage
     self._wsocket.OnClosed =  wsClose
     --self._wsocket.OnError =  wsError
     self._wsocket.OnErrorDesc =  wsErrorDesc

	self._wsocket:Open()
	-- 启动定时器
 	if self._chlName == "hall" then
 		if self.heartTimer ~= nil then
 			self.heartTimer:Stop()
 		end
		self.heartTimer = Timer.New(function ()
			self:update()
		end, 2, -1)
		self.heartTimer:Start() 		

 		--[[YX_APIManage.Instance:setHallTimer(function (  )
 		-- Trace("---------updateNetTimer-----")
 			self:update()
 		end)
		]]
 	elseif self._chlName == "game" then

 		if self.heartTimer ~= nil then
 			self.heartTimer:Stop()
 		end
 		self.heartTimer = Timer.New(function ()
			self:update()
		end, 3, -1)
		self.heartTimer:Start() 
 		--[[YX_APIManage.Instance:setGameTimer(function (  )
 		-- Trace("---------updateNetTimer-----")
 			self:update()
 		end)]]
 	end

	-- 返回true, 通知上层创建成功了, 启动定时器
    return true
end

--------------------------------
-- @TER0419
-- @des: 消息回调处理
-- @param: _rcvCallback(_msgType, _msgData)
function SocketClient:setRcvCallback(_rcvCallback)
	self._rcvCallback = _rcvCallback
end
function SocketClient:setStatusCallback(_statusCallback)
	self._statusCallback = _statusCallback
end

function SocketClient:OnStatusCallback(_status)
	if self._statusCallback then
		self._statusCallback(_status)
		DEBUGLOG(self._chlName, "notify status ", _status)
	end
end




--------------------------------
-- @TER0419
-- @des: 发送心跳消息
-- @param: xx
-- function SocketClient:sendHeartBeat()

-- 	if self._heartBeatMsg then
-- 		self:sendMessage(self._heartBeatMsg,true)
-- 	end
-- end 

--------------------------------
-- @TER0419
-- @des: 主动关闭socket连接,清空self._addr
function SocketClient:close()


	self:clearSocket(false)
	--self._addr = nil

	self._lastSendTime = os.time()
	self._lastHeartBeatTime = os.time()
	self._lastRecvTime = self._lastSendTime
	self._retryTimes = 0
	self._connectStatus = NetStatus.stoped

	self._leaveTime = 0
	
	-- 关闭定时器
	DEBUGLOG("close socket Name == " .. self._chlName)

	if self.heartTimer ~= nil then
		self.heartTimer:Stop()
		self.heartTimer = nil 
	end

 	--[[if self._chlName == "hall" then
 		YX_APIManage.Instance:setHallTimer(function (  )
 			
 		end)

 	elseif self._chlName == "game" then

 		YX_APIManage.Instance:setGameTimer(function (  )
 			
 		end)
 	end]]

	-- if netCoroutine then
	-- 	coroutine.stop(netCoroutine)
	-- 	netCoroutine = nil
	-- end
	--通知上层停止了, 该停掉定时器了
	self:OnStatusCallback(NetStatus.stoped)
end


-- @des: 设置程序切到后台的时间,在切换到后台的时候开始到切换到前台
-- @param: xx
function SocketClient:setLeaveTime(_leaveTime)
	self._leaveTime = _leaveTime
end

function SocketClient:SendHallHeartBeat()
	local param = {}
	if model_manager:GetModel("ClubModel").cidList ~= nil then
		param.filter = {}
		param.filter.cid = model_manager:GetModel("ClubModel").cidList
	end
	if hall_msg_mgr.GetMsgseq() then
		param.msgseq = hall_msg_mgr.GetMsgseq()
	end
	self:SendHallEvent("heart_beat", param)
end


--------------------------------
-- @TER0419
-- @des: 发送心跳消息
-- @param: xx
function SocketClient:sendHeartBeat()
	local tblEvent ={}
	tblEvent["_cmd"] = "heart_beat"
	tblEvent["_st"] = "req"
	tblEvent["_para"] = {}
	if self._chlName == "hall" then
		if model_manager:GetModel("ClubModel").cidList ~= nil then
			tblEvent["_para"].filter = {}
			tblEvent._para.filter.cid = model_manager:GetModel("ClubModel").cidList
		end
		if msg_dispatch_mgr.GetMsgseq() then
			tblEvent._para.msgseq = msg_dispatch_mgr.GetMsgseq()
		end
	end
	-- if self._chlName ~= "hall" then
	-- 	logError("send")
	-- end
	self._lastHeartBeatTime = os.time()
	self:sendEvent(tblEvent)
end

function SocketClient:genCheckNum()
	local _check = self._checkNum 
	self._checkNum  = self._checkNum  + 1
	self._checkList[#self._checkList+1] = _check
	return _check
end

--检查消息的_check字段
function SocketClient:checkMsg(tblMsg)
	if not tblMsg["_check"] then 
		return true
	end
	local _check = tblMsg["_check"]
	if #self._checkList == 0 then 
		return false
	end
	if _check ~= self._checkList[1] then 
		ERRORLOG(self._chlName, ": " , "self._check: ",self._checkList[1] , " _check: ", _check)
		return false
	end
	table.remove(self._checkList, 1)
	return true
end

--检查时间的sn字段
function SocketClient:checkEvent(tblEvent)
	if not tblEvent["_sn"]  or tblEvent["_sn"]  <= 0 then 
		return true
	end
	local event_sn = tblEvent["_sn"] 
	if self._lastSN < 0 then
		self._lastSN = event_sn
		return true
	end
	if self._lastSN + 1 ~= event_sn then 
		logError(self._chlName, ": " , "self._lastSN: ", self._lastSN , " Event_SN: ", event_sn)
		return false
	end 
	self._lastSN = tblEvent["_sn"]
	return true
end 



function SocketClient:OnRecvData(_strMsg)
	-- sc
	local tblMsg = ParseJsonStr(_strMsg)
	if not tblMsg then
		ERRORLOG(self._chlName, "Msg Decode failed:" , _strMsg )
		return false, false
	end
	if tblMsg["_errno"] == 404 then
		ERRORLOG(self._chlName, "Server Unreachable:" , _strMsg )
		return false, false
	end 
	if self._rcvCallback == nil then
		return true
	end

	if not self:checkEvent(tblMsg) then
		return false, true
	end
	

	if not tblMsg["_events"] or #tblMsg["_events"] == 0 then
		return true
	end


	local _svrName = tblMsg["_svr_t"]
	local _svrID = tblMsg["_svr_id"]

	local index = 1
    while index <= #tblMsg["_events"] do
		local _event = tblMsg["_events"][index]
		-----这个可能有错误
		if _event["_cmd"] ~= "heart_beat" then
			DEBUGLOG(self._chlName, "Process Cmd:", _event["_cmd"]," Event:", _event , " from ", _svrName, _svrID)
		end
		self._lastRecvTime = os.time()
		if self._rcvCallback ~= nil and false  == self._rcvCallback(_svrName, _svrID, _event) then 
			ERRORLOG(self._chlName, "Failed Event:", _event , "from ", _svrName, _svrID)
			return false, true
		end
		index = index + 1
	end
	return true
end

function SocketClient:OnRecvHallData(_strMsg)
	local tblMsg = ParseJsonStr(_strMsg)
	-- if tblMsg._func ~= "heart_beat" then
	-- end
	if not tblMsg then
		ERRORLOG(self._chlName, "Msg Decode failed:" , _strMsg )
		return false, false
	end
	if tblMsg["_errno"] == 404 then
		ERRORLOG(self._chlName, "Server Unreachable:" , _strMsg )
		return false, false
	end 
	if self._rcvCallback == nil then
		return true
	end
	self._lastRecvTime = os.time()
	if self._rcvCallback ~= nil and false  == self._rcvCallback(_svrName, _svrID, tblMsg) then
		ERRORLOG(self._chlName, "Failed Event:", _event , "from ", _svrName, _svrID)
		return false, true
	end
	return true
end


-- 大厅socket通信
function SocketClient:SendHallEvent(funName, params)
	if not self._wsocket then
		return 
	end
	local param = {}
	param._mod = "online"
	param._func = funName
	param._param = params
	local _strMsg = CombinJsonStr(param)

	--Trace("sendEvent====" .. _strMsg)
		
	self._lastSendTime = os.time()
	self._wsocket:Send(_strMsg)
end


-- @TER0419
-- @des: 发送消息
function SocketClient:sendEvent(tblEvent, _dst, _svrName, _svrID)

	if not self._wsocket or not tblEvent then
		return 
	end
	if not _dst then
		_dst = self._dst
	end
	if not _svrName then 
		_svrName = self._svrName
		_svrID = self._svrID
	end
	local tblMsg = {}
	tblMsg["_events"] = {tblEvent}
	--table.insert(tblMsg["_events"], tblEvent)

	-- tblMsg["_mod"] = _svrName
	-- if _svrID >= 0 and _svrName ~= nil then
	-- 	tblMsg["_mod"] = tblMsg["_mod"] .. "." .. _svrID
	-- end
	tblMsg["_func"] = "event"
	tblMsg["_check"] = self:genCheckNum()
	tblMsg["_ver"] =  1
	

	if _dst then
		tblMsg["_dst"] = _dst
	end
	
	-- --sc
	-- tblMsg["_events"] = {}
	-- tblMsg["_events"][1] = tblEvent
	
	local _strMsg = CombinJsonStr(tblMsg)

	--Trace("sendEvent====" .. _strMsg)
		
	self._lastSendTime = os.time()
	self._wsocket:Send(_strMsg)
	
	if tblEvent["_cmd"] ~= "heart_beat" then
		DEBUGLOG(self._chlName, ": " , "_wsocket:sendString Msg ", _strMsg, "_dst: ", _dst)
	end
end


function SocketClient:sendEvent_old(tblEvent, _dst, _svrName, _svrID)
	if not self._wsocket or not tblEvent then
		return 
	end
	if not _dst then
		_dst = self._dst
	end
	if not _svrName then 
		_svrName = self._svrName
		_svrID = self._svrID
	end
	local tblMsg = {}
	tblMsg["_events"] = {tblEvent}
	--table.insert(tblMsg["_events"], tblEvent)


	tblMsg["_check"] = self:genCheckNum()
	tblMsg["_ver"] =  1
	

	if _dst then
		tblMsg["_dst"] = _dst
	end
	
	-- --sc
	-- tblMsg["_events"] = {}
	-- tblMsg["_events"][1] = tblEvent
	
	local _strMsg = "host=dstars&msgid=http_req&uri=/" .. (_svrName or "online")
	if _svrID >= 0 and _svrName then
		_strMsg = _strMsg .. "/" .. _svrID
	end
	
	--sc
	_strMsg = _strMsg .. "@@@@" .. CombinJsonStr(tblMsg)

	--Trace("sendEvent====" .. _strMsg)
		
	self._lastSendTime = os.time()
	self._wsocket:Send(_strMsg)
	
	if tblEvent["_cmd"] ~= "heart_beat" then
		DEBUGLOG(self._chlName, ": " , "_wsocket:sendString Msg ", _strMsg, "_dst: ", _dst)
	end
	logError(_strMsg)
end

--------------------------------

--------------------------------
-- @TER0419
-- @des: 通过self._addr重连
-- @param: xx
function SocketClient:reconnect()
	--[[while(self._wsocket ~= nil and self._wsocket.IsOpen)			
	do
		self:clearSocket(false)
		--coroutine.wait(0.5)
	end]]
	if self._connectStatus == NetStatus.closed then

		self._retryTimes = self._retryTimes +1
		if self._retryTimes == 1 then
			DEBUGLOG(self._chlName, ": " , "real begin reconect ---", self._retryTimes)
			
			self:connect(self._addr)
		else
			self._lastReconnectTime = os.time()
		
			DEBUGLOG(self._chlName,  "prepare to reconnect on status " , self._connectStatus, "at : ", self._lastReconnectTime, " _retryTimes ", self._retryTimes , "_maxRetryTimes:", self._maxRetryTimes)
			self._connectStatus = NetStatus.reconnect
		end

	elseif self._connectStatus == NetStatus.reconnect then 
		if self._lastReconnectTime +1 < os.time() then
			-- self._rcvCallback(cc.onreconnect)
			
			DEBUGLOG(self._chlName, ": " , "real begin reconect ---", self._retryTimes)
			self:connect(self._addr)
		end
	else
		DEBUGLOG(self._chlName,  "unknow status " , self._connectStatus)
	
	end
end
--------------------------------
-- @TER0529
-- @des: 强行重连
-- @param: xx
function SocketClient:forceReconnect()
	self._retryTimes = 0
	self._lastReconnectTime = 0
	self._leaveTime = 0
	self._lastSendTime = os.time()
	self._lastRecvTime = self._lastSendTime

	self:clearSocket(true)
	self:connect()
end
function SocketClient:destroy()
	DEBUGLOG(self._chlName, "Destroy")
	self:setRcvCallback(nil)
	self:setStatusCallback(nil)
	self:close()
end
--------------------------------
-- @TER0419
-- @des: 发送心跳包，处理发送消息队列与接收消息队列缓存
-- @param: xx
function SocketClient:update()
	-- Trace("SocketClient:update------")
	local curTime = os.time()
	if self._connectStatus ==NetStatus.connecting then

		if self._lastSendTime + self._timeout < curTime  then
			DEBUGLOG(self._chlName,  "connect timeout")
			self:clearSocket(true)
		end
		return

	elseif self._connectStatus == NetStatus.closed then
		if self._retryTimes >= self._maxRetryTimes then
		
			DEBUGLOG(self._chlName,  "retry to reconnect too much-----")

			self:close()

			-- close 里面会通知stoped
			--OnStatusCallback(NetStatus.stoped)
		else
 
			self:reconnect()
			
		end
		return 
	elseif self._connectStatus == NetStatus.reconnect then 
		self:reconnect()
		return
	elseif self._connectStatus== NetStatus.closing then
		return
	end

-- 	-- connected status
-- 	if self._leaveTime > 10 then
-- 		DEBUGLOG(self._chlName,  "_leaveTime1", self._leaveTime)
-- 		self._leaveTime = 0
-- 		DEBUGLOG(self._chlName,  "leaveTime timeout , reconnect it")
-- 		self:clearSocket(true)-- 标志状态, 等待重连通统一处理
-- 		return
	 
-- 	elseif self._leaveTime >= self._timeout  then
-- 		DEBUGLOG(self._chlName,  "_leaveTime2", self._leaveTime)
-- 		self._leaveTime = 0
-- 		self._lastRecvTime = curTime  - self._timeout *2 +0.5
-- 		self:sendHeartBeat()
-- 		return 
-- 	end

-- 	if nil == self._wsocket then
-- 		DEBUGLOG(self._chlName, ": " , "nil == self._wsocket , reconnect it")

-- 		self:clearSocket(true) -- 标志状态, 等待重连通统一处理
-- 		return
-- 	end
-- --	DEBUGLOG(self._chlName, ": " , "tttt", curTime -self._lastRecvTime)
-- 	-- if self._lastSendTime + self._timeout  < curTime then
-- 	-- 	self:sendHeartBeat()
-- 	if self._lastRecvTime + self._timeout  * 2.5 <= curTime then
-- 		DEBUGLOG(self._chlName, ": " , "recv data timeout , reconnect it")
-- 		self:clearSocket(true)-- 标志状态, 等待重连通统一处理
-- 		return	
-- 	else
-- 		self:sendHeartBeat()
-- 	end
	
	if self._leaveTime > 10 then  -- 切后台超时
		self._leaveTime = 0
		self:clearSocket(true)
		return
	end

	if self._lastRecvTime + self._timeout * 2.5 < curTime then
		self:clearSocket(true)
		return
	end

	-- if self._last + self._timeout < curTime then
	if self._chlName == "game" then
		self:sendHeartBeat()
	else
		self:SendHallHeartBeat()
	end
	-- end
end

--------------------------------



return SocketClient

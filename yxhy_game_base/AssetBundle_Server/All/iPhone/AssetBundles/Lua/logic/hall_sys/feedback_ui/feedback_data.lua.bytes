--用户反馈数据
require("logic/network/http_request_interface")
require("logic/hall_sys/feedback_ui/feedback_msg")

local feedback_data = class("feedback_data")

function feedback_data:ctor(Ui)	
	self.MaxMsgNum = 20 --界面显示消息的最大条数
	self.feedback_ui = Ui
end

local msgList = {} --所有消息列表
local tipList = {} --自动回复列表


function feedback_data:Init(Ui)
	msgList = {}
end

function feedback_data:getMsgList()
	return msgList
end

function feedback_data:getTipList()
	return tipList
end

function feedback_data:FullMsgList(time,type,msg,sendState)
	local msgBody = feedback_msg.New()
	msgBody.time = time
	msgBody.type = type
	msgBody.msg = msg
	msgBody.sendState = sendState
	table.insert(msgList,msgBody)
	if table.getCount(msgList) > self.MaxMsgNum then
		table.remove(msgList,1)
		self:OverflowTips()
	end
end

function feedback_data:OverflowTips()
	for i = table.getCount(tipList),1,-1 do
    	if tipList[i] == 1 then
    		table.remove(tipList,i)
    	else
    		tipList[i] = tipList[i] -1
    	end
    end
end

function feedback_data:AddMsg(time,type,msg,callback)
	if type == 0 then
		http_request_interface.feedBack(msg,function (str)
			Trace("feedBack-----------"..GetTblData(str))
			local s=string.gsub(str,"\\/","/")
			local t=ParseJsonStr(s)
			if t.ret == 0 then
				self:FullMsgList(time,type,msg,0)			    
	            local tTime=os.date("%Y/%m/%d %H:%M",math.floor(tonumber(t["data"])))
	            local finallyMsg = self:FindMsg(#msgList)
	            finallyMsg.sendState = 1
	            finallyMsg.time=tTime
	            callback();
			else
				UI_Manager:Instance():FastTip("含有未知内容，发送失败")
				return
			end
		end)
	else
		self:FullMsgList(time,type,msg,1)
    	callback();
	end
end

function feedback_data:ReAddMsg(time,type,msg,callback,index)
	if type == 0 then
		http_request_interface.feedBack(msg,function (str)
			--Trace("self.ReAddMsg-----------"..GetTblData(str))
			local s=string.gsub(str,"\\/","/")
			local t=ParseJsonStr(s)
			local tTime=os.date("%Y/%m/%d %H:%M",math.floor(tonumber(t["data"])))
			local finallyMsg = self:FindMsg(tonumber(index))
			finallyMsg.sendState = 1
			finallyMsg.time = tTime
			callback();
		end)
	else
		self:FullMsgList(time,type,msg,1)
    	callback();
	end
end

function feedback_data:FindMsg(index)
	return msgList[index]
end

function feedback_data:getFeedBack(callback)		
	http_request_interface.getFeedBack({},function (str)
		Trace("getFeedBack-----------"..GetTblData(str))

		local s=string.gsub(str,"\\/","/")
		local t=ParseJsonStr(s)
		if t.ret == 0 then
			local msgCount = table.getCount(t.feedback)
			local tIndex = 1
			if msgCount < self.MaxMsgNum then
				tIndex = 1
			else
				tIndex = msgCount - self.MaxMsgNum + 1
			end

			for i = tIndex,table.getCount(t.feedback),1 do

				local tTime=os.date("%Y/%m/%d %H:%M",math.floor(tonumber(t.feedback[i].ptime)))
				local tType=t.feedback[i].isback
				local tMsg=t.feedback[i].content
				self:FullMsgList(tTime,tType,tMsg,1)
			end
		end   
		if callback ~= nil then
			callback()
		end    
	end)
end

function feedback_data:RefreshPushMsg(t)
	if self.feedback_ui ~= nil then
		local timePrefix = os.date("%Y/%m/%d %H:%M",os.time())
		local msgType = 1
		local msgStr = t.data["content"]
		self:AddMsg(timePrefix,msgType,msgStr,function()
			self.feedback_ui:ReflushUI()
			if self.feedback_ui.gameObject.activeSelf == true then
				hall_ui:ShowFeedBackRedPoint(false)
			end
		end)	
	end
end

return feedback_data

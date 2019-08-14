--用户反馈数据
require("logic/network/http_request_interface")
require("logic/hall_sys/feedback_ui/feedback_msg")

feedback_data = {}
local this = feedback_data

local msgList = {} --所有消息列表
this.MaxMsgNum = 50 --界面显示消息的最大条数

local tipList = {} --自动回复列表

function this.Init()
	
end

function this.getMsgList()
	return msgList
end

function this.getTipList()
	return tipList
end

function this.FullMsgList(time,type,msg)
	local msgBody = feedback_msg.New()
	msgBody.time = time
	msgBody.type = type
	msgBody.msg = msg
	table.insert(msgList,msgBody)

	if table.getCount(msgList) > this.MaxMsgNum then
		table.remove(msgList,1)
		this.OverflowTips()
	end
end

function this.OverflowTips()
	for i = table.getCount(tipList),1,-1 do
    	if tipList[i] == 1 then
    		table.remove(tipList,i)
    	else
    		tipList[i] = tipList[i] -1
    	end
    end
end

function this.AddMsg(time,type,msg,callback)

	if type == 0 then
		http_request_interface.feedBack(msg,function (code,m,str)
			if code then		
			end
			local s=string.gsub(str,"\\/","/")
	        local t=ParseJsonStr(s)
	        local tTime=os.date("%Y/%m/%d %H:%M",math.floor(tonumber(t["data"])))
	        
			this.FullMsgList(tTime,type,msg)
	        callback();
		end)
	else
		this.FullMsgList(time,type,msg)
    	callback();
	end
end

function this.getFeedBack(callback)
	http_request_interface.getFeedBack({},function (code,m,str)
		print(str)
		if code then		
		end

		local s=string.gsub(str,"\\/","/")
        local t=ParseJsonStr(s)

        local msgCount = table.getCount(t.feedback)
        local tIndex = 1
        if msgCount < this.MaxMsgNum then
        	tIndex = 1
        else
        	tIndex = msgCount - this.MaxMsgNum + 1
        end

        for i = tIndex,table.getCount(t.feedback),1 do

        	local tTime=os.date("%Y/%m/%d %H:%M",math.floor(tonumber(t.feedback[i].ptime)))
        	local tType=t.feedback[i].state
        	local tMsg=t.feedback[i].content

        	this.FullMsgList(tTime,tType,tMsg)
        end   
        callback()    
	end)
end

mail_data = {}
local this = mail_data

local mailRecord = {}

---请求邮件数据
function this.ReqMailData(callback)
	http_request_interface.getEmails(0,function(str)
		local s = string.gsub(str,"\\/","/")  
		local t = ParseJsonStr(s) 
		if t.ret == 0 then
			mailRecord = t.data
			if callback ~= nil then
				callback()
			end
		end
    end)
end

---请求删除一封邮件
function this.ReqDeleteMail(rIndex,callback)      
    http_request_interface.delEmail(mailRecord[rIndex].eid,function(str) 
		local str = ParseJsonStr(str)
		if str.ret == 0 then
			this.RemoveOneMail(rIndex)
			if callback then
				callback()
			end
		end
    end)
end

---请求领取一封邮件附件
function this.ReqGetReward(rIndex,callback)
	http_request_interface.getEmailAttachment(mailRecord[rIndex].eid,function(str) 
        local str = ParseJsonStr(str)
		if str.ret == 0 then
			this.SetOneGet(rIndex,1)
			if callback then
				callback()
			end
		end
    end)
end

---请求已读一封邮件
function this.ReqReadMail(rIndex,callback)
	if mailRecord[rIndex].status ~= 1 then
		http_request_interface.readEmail(mailRecord[rIndex].eid,function(str)
			local t=ParseJsonStr(str)
			if t.ret == 0 then
				this.SetOneRead(rIndex,1)
				if callback then
					callback()
				end
			end	
		end)  
	end
end

---删除一条本地邮件数据
function this.RemoveOneMail(rIndex)
	table.remove(mailRecord,rIndex)
end

---设置一条本地邮件已读,(status:0,1)
function this.SetOneRead(rIndex,status)
	mailRecord[rIndex]["status"] = status
end

---设置一条本地邮件附件已领取,(status:0,1)
function this.SetOneGet(rIndex,status)
	mailRecord[rIndex]["isget"] = status
end

-----------------外部接口---------------

---检测全部已读
function this.CheckAllRead()
    for i=1,table.getn(mailRecord) do 
        if mailRecord[i]["status"] ~= 1 then
			return false
		end
    end
	return true
end

---获取邮件数据
function this.GetMailData()
	return mailRecord
end

---获取邮件数量
function this.GetMailDataCount()
	return table.getn(mailRecord)
end
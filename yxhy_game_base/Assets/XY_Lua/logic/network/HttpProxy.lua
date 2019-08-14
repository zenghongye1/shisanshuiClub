local HttpProxy = {}
local ErrorHandler = ErrorHandler
HttpProxy.HttpMode = 
{
	Club = "club",
	Room = "room",
	User = "user",
	App = "app",
	Global = ""
}

HttpProxy.DefaultSendCfg = 
{
	showWaiting = false,
	needRetry = true,
	noTips = false
}


HttpProxy.ShowWaitingSendCfg = 
{
	showWaiting = true,
	needRetry = true,
	noTips = false
}



local url = ""
local port = 0
local uid = 0
local session_key = ""
local HttpRequestUrl = ""
local json = require "cjson"

local GlobelSeverUrl = "http://192.168.2.23:8000/global"

function HttpProxy.InitUrlAndPort(Url, Port)
	url = Url
	port = Port
end

function HttpProxy.InitUidAndToken(userId, sessionkey)
	uid = userId
	session_key = sessionkey
	-- HttpRequestUrl = table.concat({"http://192.168.2.20:8001/", "?uid=", uid, "&token=", session_key})
	HttpRequestUrl = table.concat({"http://", url, ":", port, "/?uid=", uid, "&token=", sessionkey})
end


function HttpProxy.GetRequestTable(mod, funcName, paramTable)
	local t = {}
	t._mod = mod
	t._func = funcName
	t._param = paramTable or {}
	return t
end

function HttpProxy.ShowError(url, paramStr ,callback, needRetry)
    UI_Manager:Instance():CloseUiForms("waiting_ui")
    MessageBox.ShowYesNoBox("网络请求失败，是否重新请求",  
        function() 
            HttpProxy.SendInternal(url, paramStr,callback, needRetry) 
            -- waiting_ui.Show()
            UI_Manager:Instance():ShowUiForms("waiting_ui")
        end)
end


function HttpProxy.SendInternal(url, paramStr, callback, needRetry, retryTime)
	if Debugger.useLog then
		logWarning("send : " .. (paramStr or ""))
	end

	NetWorkManage.Instance:HttpPostRequestWithData(url, paramStr, function(code, msg, str)
		if Debugger.useLog then
			logWarning("receive : " .. str .. "   " .. paramStr)
		end
		if code == 0 then
            UI_Manager:Instance():CloseUiForms("waiting_ui")
            callback(str,code, msg)
        else
        	if needRetry == nil then
        		needRetry = true
        	end
        	if not needRetry or retryTime == 3 then
        		HttpProxy.ShowError(url, paramStr, callback, needRetry)
        		return
        	end
        	retryTime = retryTime or 1
        	retryTime = retryTime + 1
        	HttpProxy.SendInternal(url, paramStr, callback, needRetry, retryTime)
        end
	end)
end


function HttpProxy.SendRequesetInternal(url, mode, key, param, callback, target, sendCfg)
	sendCfg = sendCfg or HttpProxy.DefaultSendCfg
	if sendCfg.showWaiting then
		UI_Manager:Instance():ShowUiForms("waiting_ui")
	end
	-- waiting 相关
	local t = HttpProxy.GetRequestTable(mode, key, param)
	local paramStr = json.encode(t) 
	HttpProxy.SendInternal(url, paramStr, function(str, code, msg) 
		local s =string.gsub(str,"\\/","/")
		local tab = nil
	    if not pcall( function () tab = json.decode(s) end) then
	        logError(key,"json decode error",str)
	        UI_Manager:Instance():CloseUiForms("waiting_ui")
	        return
	    end
	    if not ErrorHandler.CheckMsgErrorNo(tab, sendCfg.noTips, sendCfg.errorHandler) then
	    	sendCfg.errorHandler = nil
	    	return
	    end
	    sendCfg.errorHandler = nil
	    if callback == nil then
	    	 Notifier.dispatchCmd(key, tab._param, tab._errno)
	    else
	    	if target ~= nil then
	            callback(target, tab._param, tab._errno)
	        else
	            callback(tab._param, tab._errno)
	        end
	    end
	end, (sendCfg.needRetry or true))
end


function HttpProxy.SendRequest(mod, key, param, callback, target ,sendCfg)
	HttpProxy.SendRequesetInternal(HttpRequestUrl, mod, key, param, callback, target, sendCfg )
end


function HttpProxy.SendRoomRequest(key, param, callback, target, sendCfg)
	HttpProxy.SendRequest(HttpProxy.HttpMode.Room, key, param, callback, target, sendCfg)
end

function HttpProxy.SendUserRequest(key, param, callback, target, sendCfg)
	HttpProxy.SendRequest(HttpProxy.HttpMode.User, key, param, callback, target, sendCfg)
end


--获取个人游戏信息{"uid":113565,"type":1}
function HttpProxy.GetGameInfo(param, callback)
	HttpProxy.SendUserRequest(HttpCmdName.GetGameInfo, param, callback)
end


function HttpProxy.SendGlobalRequest(suffix, funcName, param, callback)
	local url = NetWorkManage.Instance.GlobalServerUrl .. suffix
	HttpProxy.SendRequesetInternal(url, "", funcName, param, callback, nil)
end


function HttpProxy.GetClientConfig(callback)
	local param = {}
	param.appid = global_define.appConfig.appId
	HttpProxy.SendGlobalRequest("/app.json",HttpCmdName.GetClientConfig, param, callback)
end


return HttpProxy
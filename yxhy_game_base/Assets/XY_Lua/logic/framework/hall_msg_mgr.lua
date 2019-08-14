local hall_msg_mgr = {}

local msgseq = 0
local json = require( "cjson")
local MsgSeqKey = "MSGSEQ_"

function hall_msg_mgr.InitMsgSeq(uid)
	MsgSeqKey = "MSGSEQ_" .. (uid or 0)
	if PlayerPrefs.HasKey(MsgSeqKey) then
		msgseq = PlayerPrefs.GetInt(MsgSeqKey)
	end
	if msgseq == nil then
		msgseq = 0
	end
end

function hall_msg_mgr.SaveMsgReq()
	if msgseq ~= nil and msgseq > 0 then
		PlayerPrefs.SetInt(MsgSeqKey, msgseq)
	end
end

function hall_msg_mgr.OnReceiveData( msg)
  if not ErrorHandler.CheckMsgErrorNo(msg) then
    logError(msg._errno, msg._errstr)
    return
  end
	hall_msg_mgr.HandleRecvData(msg)
end

function hall_msg_mgr.HandleRecvData(msg)
	if msg._func ~= "heart_beat" then
		logWarning(GetTblData(msg))
	end
	if msg._func == "heart_beat" then
		hall_msg_mgr.HandleHeartBeat(msg)
	elseif msg._func == "push_msg" then
		hall_msg_mgr.HandlePushMsg(msg._param)
	end
end

function hall_msg_mgr.HandleHeartBeat(data)
	--[[//错误码定义:
	var GLOBAL_SYSTEMERROR = ErrRsp{100000, "系统错误"}     // global 100
	var GLOBAL_NOAPP = ErrRsp{1000001, "非法appID"}     // global 100
	var GLOBAL_INVALIDPARAM = ErrRsp{1000002, "参数错误"} // global 100
	var GLOBAL_NOSESSION = ErrRsp{1000004, "没有登录态"} // global 100--/]]

	if data._errno ~= 0 and data._errno == 1000004 then
		return
	end

end

function hall_msg_mgr.HandlePushMsg(data)
	if data.events == nil or #data.events == 0 then
		return
	end
	for i = 1, #data.events do
		hall_msg_mgr.HandleSinglePushMsg(data.events[i])
	end
end

function hall_msg_mgr.HandleSinglePushMsg(event)
	if not hall_msg_mgr.CheckAndUpdateMsgseq(event) then
		return
	end
	local tmp = event.msg
    --local t = json.encode(tmp)
    local s=string.gsub(tmp,"\\/","/")
    s=string.sub(s, 1, -1)
    if s== nil or s =="" then
      return
    end
    if not pcall(function() t = json.decode(s) end) then
      logError("解析协议失败", s)
      return
    end

    if t ~= nil then 
  		if t["type"]==10003 then 
  			Notifier.dispatchCmd(cmdName.MSG_EmailMsg,t)
  		end
  		if t["type"] == 10004 then
  			http_request_interface.getAccount("",function (str)
  				local t=ParseJsonStr(str) 
  				local ret = t.ret
  				if ret and tonumber(ret) == 0 then
  					Trace("push10004 ----- getAccount:"..GetTblData(t))
  					local account = t.account
  					--local card = account.card 
  					Notifier.dispatchCmd(cmdName.MSG_ROOMCARD_REFRESH,account) 
  				end
  			end)
  		end
  		if t["type"] == 10006 then 
  			Notifier.dispatchCmd(cmdName.MSG_HASACTIVITY,t.data.hasact)
  		end
  		if t["type"]==10007 then 
  			if tonumber(t.data.appid) ~= global_define.appConfig.appId then   --验证appid过滤公告
  				return
  			end 
        -- 推送不做区分
  			-- if tonumber(t.data.dtype)==tonumber(data_center.GetUserInfoTbl().passport.dtype) or tonumber(t.data.dtype)==0 then  --0全部 1安卓 2IOS 
  			-- 	if tonumber(t.data.ptype)==tonumber(data_center.GetUserInfoTbl()["xlb"].ptype) or tonumber(t.data.ptype)==0 then --0全部 1代理商 2 普通 
  					UIManager:ShowUiForms("global_notice_ui", nil, nil,t.data.msg,5)
  				-- end
  			-- end
  		end
  		if t["type"]==10008 then 
  			game_scene.gotoLogin() 
  			game_scene.GoToLoginHandle() 
  		end
  		
  		if t["type"]==10009 then 
  			Notifier.dispatchCmd(cmdName.MSG_FeedBackMsg,t)
  		end

      if t["type"]==10015 then 
        model_manager:GetModel("ClubModel"):OnPushBeAgent()
        -- Notifier.dispatchCmd(HttpCmdName.ClubBindAgent, t)
      end
    end
    Notifier.dispatchCmd(GameEvent.OnPushMsg, t)


end


function hall_msg_mgr.GetMsgseq()
  return msgseq
end

function hall_msg_mgr.CheckAndUpdateMsgseq(event)
  local _msgseq = event.msgseq
  if _msgseq == nil then
  	return true
  end
  if _msgseq and tonumber(_msgseq) > msgseq then
    msgseq = _msgseq
    hall_msg_mgr.SaveMsgReq()
    return true
  end
  if _msgseq and tonumber(_msgseq) < 0 then -- 小于0的_msgseq不需要校验
    return true
  end
end



return hall_msg_mgr
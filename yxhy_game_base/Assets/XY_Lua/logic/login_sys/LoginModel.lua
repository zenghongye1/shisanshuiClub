local LoginModel = class("LoginModel")
local json = require "cjson"

function LoginModel:Init()
	self.serverAddr = ""
	self.serverPort = 0
	self.firstLogin = true
	self:AddListener()
end

function LoginModel:Clear()
	-- self:RemoveListener()
end

function LoginModel:AddListener()
    Notifier.regist(cmdName.MSG_CHANGE_ACCOUNT, self.OnChangeAccount,self)
    Notifier.regist(cmdName.SHOW_PAGE_HALL, self.OnLoginComplite,self)
end

function LoginModel:RemoveListener()
	Notifier.remove(cmdName.MSG_CHANGE_ACCOUNT, self.OnChangeAccount,self)
	Notifier.remove(cmdName.SHOW_PAGE_HALL, self.OnLoginComplite,self)
end

function LoginModel:ReqUserLogin(loginType, accessToken, openId, autoLogin, shareUid)
	local param = {}
	param.appid = global_define.appConfig.appId
	param.version = data_center.GetVerCommInfo().versionNum
	param.accesstoken = tostring(accessToken)
	param.devicetype = data_center.GetDeviceType()
	param.siteid = data_center.GetSiteId()
	param.openid = openId
	param.subrtype = autoLogin and "openid" or "code"   -- 自动登录使用openid
	param.rtype = loginType
	param.shareuid = shareUid
	HttpProxy.SendGlobalRequest("/login", HttpCmdName.UserLogin, param, function(userInfo) self:OnResUserLogin(userInfo, accessToken) end, self)
end


function LoginModel:OnResUserLogin(userInfo)
	if userInfo.ret ~= 0 and userInfo.ret ~= nil then
		UIManager:FastTip(LanguageMgr.GetWord(8033))
		return
	end
	data_center.SetUserInfo(userInfo)
	HttpProxy.InitUidAndToken(userInfo.uid, userInfo.sessionkey)
	hall_msg_mgr.InitMsgSeq(userInfo.uid)
	http_request_interface.setUserInfo(userInfo.uid,userInfo.sessionkey,0,data_center.GetDeviceType(),data_center.GetSiteId(),"") 
	self:OnLoginSuccess()
	Notifier.dispatchCmd(GameEvent.LoginSuccess)
 	if userInfo.ret == 0 or userInfo.ret == nil then --登录成功
		data_center.SetIsUpdateState(true)
		PlayerPrefs.SetInt("LoginType", userInfo.rtype) 
		PlayerPrefs.SetString("AccessToken", userInfo.sitemid)
		PlayerPrefs.SetString("OpenID",userInfo.openid)   
		login_sys.EnterHallRsp("")
		local urlStr = string.format(global_define.wsurl,userInfo.uid,userInfo.sessionkey)
		SocketManager:createSocket("hall",urlStr)	 
        return true
    else
	    Trace("LoginError:"..data_center.GetUserInfoTbl().msg..tostring(data_center.GetUserInfoTbl().ret));
        return false
    end 
end


function LoginModel:OnChangeAccount()
	self.firstLogin = true
end

function LoginModel:OnLoginComplite()
	if self.firstLogin then
		join_room_ctrl.QueryState(function()
			invite_sys.CheckClipBoardAndJoinRoom()
		end)
	end
	self.firstLogin = false
	hall_data.ShowApply = true
end

function LoginModel:GetClientConfig(callback)
	HttpProxy.GetClientConfig(function(serverData, errorCode) 
		self:LoadServerAddrAndPort(serverData)
		self:LoadCommonCfg(serverData)

		if callback ~= nil then
			callback()
		end
	end)
end

function LoginModel:OnLoginSuccess()
	model_manager:GetModel("GameModel"):ReqGetCardGameList()
	model_manager:GetModel("openroom_model"):ReqGetCardGameCost()

	-- 登录请求货币信息
	http_request_interface.getAccount("",function (str)
		local t=ParseJsonStr(str) 
		local ret = t.ret
		if ret and tonumber(ret) == 0 then
			local account = t.account
			data_center.GetLoginUserInfo().card = account.card or 0
			--local card = account.card 
			Notifier.dispatchCmd(cmdName.MSG_ROOMCARD_REFRESH,account) 
		end
	end)
end

function LoginModel:LoadServerAddrAndPort(serverData)
	local count = #serverData.ConnServer
	local index = 1
	if count > 1 then
		local index = math.round(count + 1)
		if index > count then
			index = count
		end
	end
	self.serverAddr = serverData.ConnServer[index].ServerAddr
	self.serverPort = serverData.ConnServer[index].ServerPort

	global_define.wsurl = "ws://"..self.serverAddr..":"..self.serverPort.."/?uid=%s&token=%s"
	global_define.wsurl = global_define.wsurl .. "&lz=1"
	global_define.gamewsurl = "ws://"..self.serverAddr..":"..self.serverPort.."/%s/%s/?uid=%s&token=%s&lz=1"


	HttpProxy.InitUrlAndPort(self.serverAddr, self.serverPort)
end


function LoginModel:LoadCommonCfg(serverData)
	self.acturl = serverData.CommonConfig.acturl
	self.downloadUrl = serverData.CommonConfig.downloadurl
	self.mjupdateurl = serverData.CommonConfig.mjupdateurl
	self.clubagenturl = serverData.CommonConfig.clubagenturl -- 代理商后台地址
	self.sharelang = serverData.CommonConfig.sharelang -- 分享文本
	self.kickclubcfg = serverData.CommonConfig.kickclubcfg -- 踢人原因文本
	self.customerservice = serverData.CommonConfig.customerservice -- 客服号文本
	self.is_pop = serverData.CommonConfig.is_pop or 0
	self.mall_broadcast = serverData.CommonConfig.mall_broadcast or ""
	data_center.jcGameUrl = serverData.CommonConfig.jcgameurl or "";

	model_manager:GetModel("ClubModel").noagentclubcost = serverData.CommonConfig.noagentclubcost or 3000
	model_manager:GetModel("ClubModel").moreclubcost = serverData.CommonConfig.moreclubcost or 300

	global_define.SetURL(self.acturl,self.downloadUrl)
	
	global_define.appConfig.hallShareTitle = serverData.CommonConfig.hallShareTitle
	global_define.appConfig.hallShareQTitle = serverData.CommonConfig.hallShareQTitle
	global_define.appConfig.hallShareFriendContent = serverData.CommonConfig.hallShareFriendContent
	global_define.appConfig.hallShareFriendQContent = serverData.CommonConfig.hallShareFriendQContent

	if self.kickclubcfg == "" then
		self.kickclubcfg = "{}"
	end

	global_define.SetServiceNumber(self.customerservice )
	global_define.SetClubKickReason(json.decode(self.kickclubcfg))		--设置踢人原因文本

	-- global_define.winXin = serverData.CommonConfig.

--	global_define.SetShareContext(self.sharelang)			--设置分享文本
--	global_define.SetClubKickReason(self.kickclubcfg)		--设置踢人原因文本
--	global_define.SetServiceNumber(self.customerservice)		--设置客服号文本
end

return LoginModel
--[[--
* @Description: 登陆流程管理类
* @Author:      shine
* @FileName:    login_sys.lua
* @DateTime:    2017-05-16 11:50:39
]]

SocketManager = require("logic.network.SocketManager"):create()
	

login_sys = {}
local this = login_sys

local logoutTimer = nil

this.isAgreeContract = true	--是否同意用户协议
--[[local LoginType=
{
    WXLOGIN=2,
    QQLOGIN=3,
    YOUKE=9,
}--]]
this.isClicked = false 		--判断登录界面快速多次点击限制
this.share_uid = "" 		--分享用户id 

G_isAppleVerifyInvite = false --代理商邀请码屏蔽--

--[[--
 * @Description: 将各个系统的lua文件集中包含
 ]]
function RequireSystemLuas()
	require "logic/common/pool_manager"
	require "logic/common/local_storage_sys"  --本地存储

	--通用的ui lua
	require "logic/common_ui/ui_base_tween"
	require "logic/common_ui/ui_base_grid"
	require "logic/common_ui/global_notice_ui"	

	--加载消息管理模块
	require "logic/framework/msg_dispatch_mgr"
	msg_dispatch_mgr.Init()	

end

--[[--
* @Description: 启动游戏
]]
function this.StartGame()
	RequireSystemLuas()
	
	--联网模式下不需要调用，由服务器切换
	if TestMode.IsCmdSingleMode() then
		--直接进入大厅（To do）
	end
end


function this.InitPlugins(istest)
	YX_APIManage.Instance:InitPlugins(istest)
	YX_APIManage.Instance:YX_IsEnableBattery(true);
	YX_APIManage.Instance:YX_GetPhoneStreng();
	--test
	YX_APIManage.Instance:locationStart(function(msg)
		local locationTable = ParseJsonStr(msg)
		local latitude = tonumber(locationTable.latitude) or 0
		if player_data and latitude > 0 then
			player_data.localtionData.latitude = latitude
		end
		local longitude = tonumber(locationTable.longitude) or 0
		if player_data and longitude > 0 then
			player_data.localtionData.longitude = longitude
		end
	end)
end


function this.CheckBox()
    if this.isAgreeContract == false then
		--弹出提示框没有同意服务条款
		UI_Manager:Instance():FastTip(LanguageMgr.GetWord(6013))
		this.isClicked = false
		return false
	end
    return true
end


function this.CheckSupportLz()
	local t = typeof("LuaHelper")
	local method = tolua.getmethod(t, "GetCSAbility")
	if method == nil then
		return false
	end

	local s = LuaHelper.GetCSAbility()
	local data = ParseJsonStr(s)
	if data.supportLz == 1 then
		return  true
	else
		return false
	end
end

--[[--
 * @Description: 检测版本更新处理  
 ]]
function this.CheckUpdateHandler(data, callback)
	--先判断需不需要强更
	if data ~= nil and data["version"] then
		local isForce = data["version"]["forced"]
		local url = data["version"]["url"]
		if isForce then
			MessageBox.ShowSingleBox("已有新的版本，是否跳到商店进行更新？", 
				function() 
					Application.OpenURL(url)
					Application.Quit() 
				end, 
				nil, 
				function () Application.Quit() end)
		    return 				    
		else					
			if url ~= nil and url ~= "" then
				MessageBox.ShowYesNoBox("已有新的版本，是否跳到商店进行更新？", 
				function() 							-- 确定
					Application.OpenURL(url)
			        Application.Quit()
				end, 
				function() 							-- 取消
					 if callback ~= nil then
		            	callback()
		            	callback = nil
		            end
				end, 
				function ()  						-- 关闭
					if callback ~= nil then
		            	callback()
		            	callback = nil
		            end 
		        end)
			    return 								    
			end					
		end
	end

	if callback ~= nil then
		callback()
		callback = nil
	end
end

function this.AppleCheck()
	if data_center.GetCurPlatform() ==  "IPhonePlayer" then
		G_isAppleVerifyInvite = LuaHelper.isAppleVerify
	end
	--重设微信登录按钮	
	login_ui:RegisterEvents()
	login_ui:RfreshBtnState()
end
--[[
登录请求服务器
]]
function this.RequestToServer(msgTable,isauto)
	model_manager:GetModel("LoginModel"):ReqUserLogin(msgTable.loginType, msgTable.access_token, msgTable.openId, isauto, this.share_uid)
 --    local code ="code" 
 --    isauto=isauto or false
 --    if isauto then
 --        code ="openid"
 --    end
 --    http_request_interface.otherLogin(msgTable.loginType,msgTable.openId,msgTable.access_token,0,code,this.share_uid,function (code,m,str)
	--     this.isClicked = false
	--     local s=string.gsub(str,"\\/","/")
	--     local t=ParseJsonStr(s)
	--     logError(GetTblData(t))
	--     data_center.SetLoginUserInfo(t)
	--     logError(data_center.GetLoginUserInfo().card)
	--     HttpProxy.InitUidAndToken(data_center.GetLoginUserInfo().uid, t["session_key"])
	--     hall_msg_mgr.InitMsgSeq(data_center.GetLoginUserInfo().uid)
	--     model_manager:GetModel("LoginModel"):OnLoginSuccess()
 --        http_request_interface.setUserInfo(t["user"]["uid"],t["session_key"],t["user"]["deviceid"],1,t["passport"]["siteid"],"") 
 --        Notifier.dispatchCmd(GameEvent.LoginSuccess)
	--     if data_center.GetUserInfoTbl().ret == 0 then --登录成功
	-- 		data_center.SetIsUpdateState(true)
	-- 		PlayerPrefs.SetInt("LoginType", msgTable.loginType) 
	-- 		PlayerPrefs.SetString("AccessToken", t.access_token)
	-- 		PlayerPrefs.SetString("OpenID",t.openid)   
	-- 		this.EnterHallRsp("")
	-- 		local urlStr = string.format(global_define.wsurl,data_center.GetLoginUserInfo().uid,t["session_key"])
	-- 		SocketManager:createSocket("hall",urlStr,this.binderName, this._svrID)	 
 --            return true
	--     else
	-- 	    Trace("LoginError:"..data_center.GetUserInfoTbl().msg..tostring(data_center.GetUserInfoTbl().ret));
 --            return false
	--     end 


	-- end,true)
end

function this.AutoLogin()
    local logintype = PlayerPrefs.GetInt("LoginType")	
	if data_center.GetCurPlatform() == "WindowsEditor" then
		if logintype > 0 then			
		    return this.Login(LoginType.YOUKE)
        end
	elseif data_center.GetCurPlatform()  == "Android" or data_center.GetCurPlatform() == "IPhonePlayer" then
		if PlayerPrefs.HasKey("LoginType") and PlayerPrefs.HasKey("AccessToken") and PlayerPrefs.HasKey("OpenID") then				
			if logintype > 0 then				
				local msgTable = {}
				msgTable.loginType = logintype
				msgTable.AccessToken = PlayerPrefs.GetString("AccessToken")
				msgTable.OpenID = PlayerPrefs.GetString("OpenID")

				--如果是安卓手机游客登录流程
				if logintype == LoginType.YOUKE then
					local ret = this.Login(LoginType.YOUKE)
					return ret 
				else --微信或QQ自动登录流程
					return this.Login(msgTable.loginType,true,msgTable)						
				end
			end
		end				
	end
	return false
end

--[[--
* @Description: 平台登陆成功回调
* @param:       平台登陆信息
]]
function this.Login(loginType,isAuto,t)
    if not this.CheckBox() then
        return
    end
    this.StartGame() 
	this.setShareUidFromPlatfrom() 
    if isAuto then 
        --t.openId=t.access_token
		t.access_token = PlayerPrefs.GetString("AccessToken")
		t.openId = PlayerPrefs.GetString("OpenID")

		local platform = "weixin"
		if loginType == LoginType.QQLOGIN then
			platform = "qq"
		elseif logintype == LoginType.YOUKE then
			platform = "weibo"
		end
		 --DouyouLogin
            YX_APIManage.Instance:douYouLogin(platform, t.openId, function(msg)
            	-- body
            end)
    	return this.RequestToServer(t,true)  
    end
	print("---------------------------设置数据start------------------------")
    local msgTable={}
    if loginType == LoginType.WXLOGIN then
		local isWeChatInstall = false
        YX_APIManage.Instance:WeiXinLogin(function(msg)
			isWeChatInstall = true	
		    msgTable = ParseJsonStr(msg) 
		    logError(msg)
		    if msgTable.access_token == nil then
			    UI_Manager:Instance():FastTip("登录失败")
			    return
		    end
		    if tonumber(msgTable.result) == 0 then 
                msgTable.loginType = LoginType.WXLOGIN
                msgTable.openId = msgTable.access_token

                --DouyouLogin
                YX_APIManage.Instance:douYouLogin("weixin", msgTable.openId, function(msg)
                	-- body
                end)
                return this.RequestToServer(msgTable)
		    else
			    this.isClicked = false
		        --[[YX_APIManage.Instance:CheckWXInstall(function (msg)
		    	    Trace("CheckWXInstall-----" .. msg)
		    	    local msgNum = tonumber(msg) or 0;
		    	    if msgNum == 1 then
		    	    else
		    		    UI_Manager:Instance():FastTip("微信未安装")
		    	    end
		        end)--]]
			    Trace("Login Failed"..tostring(msgTable))
		    end
	    end) 
		if not isWeChatInstall then
			YX_APIManage.Instance:CheckWXInstall(function (msg)
				Trace("CheckWXInstall-----" .. msg)
				local msgNum = tonumber(msg) or 0;
				if msgNum == 1 then
				else
					UI_Manager:Instance():FastTip("微信未安装")
				end
			end)
		end
    elseif loginType == LoginType.QQLOGIN then
    	
		local isInstall = true
		YX_APIManage.Instance:CheckQQInstall(function (msg)
			Trace("CheckQQInstall-----" .. msg)
			local msgNum = tonumber(msg) or 0;
			if msgNum == 1 then
			else
				UI_Manager:Instance():FastTip("QQ未安装")
				isInstall = false
			end
		end)
		if not isInstall then
			return false
		end

        YX_APIManage.Instance:QQLogin(function(msg)
			msgTable = ParseJsonStr(msg)
			logError(msg)
			if msgTable.access_token == nil then
					UI_Manager:Instance():FastTip("登录失败")
					return 
				end
			if tonumber(msgTable.result) == 0 then
				msgTable.loginType = LoginType.QQLOGIN
				--msgTable.openId = msgTable.access_token

	            --DouyouLogin
	            YX_APIManage.Instance:douYouLogin("qq", msgTable.openId, function(msg)
	            	-- body
	            end)
				return this.RequestToServer(msgTable)
			else
				this.isClicked = false
				Trace("Login Failed"..GetTblData(msgTable))
			end
	    end)
    elseif loginType == LoginType.YOUKE then
        this.AppleCheck() 
        msgTable.loginType = LoginType.YOUKE
	    msgTable.access_token = 0
	    msgTable.openId = NetWorkManage.Instance:GetMacAddress()
		
		--[[ QQ账号登陆
		msgTable.loginType = LoginType.QQLOGIN
	    msgTable.access_token = "533BBD309A9011D1D7234B9175210B3F"
	    msgTable.openId = "0E1B9F5ED6FA1114FC4BA86E39BBB8DB"--]]
		
        --DouyouLogin
        YX_APIManage.Instance:douYouLogin("weibo", msgTable.openId, function(msg)
        	-- body
        end)
	
	    --平台成功回调后开始连接服务器并登陆服务器  
        return this.RequestToServer(msgTable) 
    end

end

function this.setShareUidFromPlatfrom(  )
	Trace("login_sys setShareUidFromPlatfrom onEnter-----")
	local s= YX_APIManage.Instance:read("temp.txt")
	if s~=nil then
      Trace("login_sys temp.txt str-----" .. s)
		
		local t = nil
		if not pcall( function() t = ParseJsonStr(s) end) then
			return
		end
      if t.uid then
      	this.share_uid = t.uid
      end
   	end
end



--[[--
* @Description: 注销回包
]]
function this.OnLogout(pkgData)	
	if logoutTimer ~= nil then 
		logoutTimer:Stop()
	end
	this.HandleLogout()
end

--[[--
* @Description: 处理登出
]]
function this.HandleLogout(reason)
	network_mgr.ResetNetWork()
	game_scene.DestroyCurSence()
	GameKernel.ShowUpdateUI()
end

--[[--
 * @Description: 加载完场景做的第一件事
 ]]
function this.HandleLevelLoadComplete()
	gs_mgr.ChangeState(gs_mgr.state_login)

	require "logic/scene_sys/map_controller"
	map_controller.SetIsLoadingMap(false)

    this.AppleCheck()	
end

--[[--
	*@Description: 退出场景前做的最后一件事
]]
function this.ExitSystem()

end

--[[--
 * @Description: 登录大厅处理
 ]]
function this.EnterHallRsp(buffer)
	this.isClicked = false
	Trace("登录大厅成功")
	
	this.preloadWeb()		--网页预加载
	this.preloadAdPic()		--广告预下载
	map_controller.LoadHallScene(900001)	
end

 --[[--
 * @Description: 进入游戏
 ]]
function this.EnterGame()
	this.ReqEnterGame()
end

---活动预加载
function this.preloadWeb()
	local url = global_define.GetUrlData()
	if not this.webCom and url then
		UI_Manager:Instance():ShowUiForms("activity_ui")
		UI_Manager:Instance():CloseUiForms("activity_ui")
	end
end

---广告图预下载
function this.preloadAdPic()
	http_request_interface.GetClubAds(function(str)	
	    local s = string.gsub(str,"\\/","/")
	    local t = ParseJsonStr(s)
		Trace("GetClubAds-----------"..GetTblData(t))
		if t.ret == 0 then
			global_define.SetAdUrlTbl(t["adscfg"])				--设置广告图config
			local adUrlTbl = global_define.adUrlTbl
			for k,v in ipairs(adUrlTbl) do
				DownloadCachesMgr.Instance:LoadImage(v["icon"],function(code,texture,url)		
				end)
			end
		end
	end)
end

----------------------外部获取数据------------------
function this.GetLoginType()
    return LoginType
end
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
local LoginType=
{
    WXLOGIN=2,
    QQLOGIN=3,
    YOUKE=9,
}
this.isClicked = false 		--判断登录界面快速多次点击限制
this.share_uid = "" 		--分享用户id 


--[[--
 * @Description: 将各个系统的lua文件集中包含
 ]]
function RequireSystemLuas()
	require "logic/common/pool_manager"
	require "logic/common/local_storage_sys"  --本地存储

	--通用的ui lua
	require "logic/common_ui/ui_base_tween"
	require "logic/common_ui/ui_base_grid"
	require "logic/common_ui/notice_ui"	

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
end

function this.GetAllUrl(callback)
	http_request_interface.getClientConfig(nil, function (str)
		  Trace("this.GetAllUrl============"..str)
		  local realUrl =nil
		  local s = string.gsub(str,"\\/","/")
		  local data = ParseJsonStr(s)
		  if str == nil then
		  	logError("请求服务器地址错误")
		    return 
		  else
		  	data_center.SetClientConfData(data)

		    if data ~= nil and data["server"] then      
		    	local server = data["server"][1]
			    if server.uri~=nil then
			    	local uri = server.uri
			    	local first = string.find(uri, "/")
			    	local second = string.find(uri, "/",first+1)
			    	this.binderName = string.sub(uri,first+1,second-1)
					this._svrID = tonumber(string.sub(uri,second+1))
				end 
		      	global_define.wsurl = "ws://"..server.svrip..":"..server.svrport.."/?uid=%s&token=%s"
                global_define.SetURL(data["useragreeurl"],data["protocolurl"],data["privacyurl"],data["acturl"],data["downloadurl"]) 
	            webview.InitwithSize(global_define.GetFwtkUrl(), 180, 30, 180, 180) 
		    else
				message_box.Close()
				logError("获取服务器地址有误!!!!!!!!!!!!")
		    end

		    if callback ~= nil then
		    	callback()
		    	callback = nil
		    end

		    --this.CheckUpdateHandler(data, callback)
		end
	end,true)
end
function this.CheckBox()
    if this.isAgreeContract == false then
		--弹出提示框没有同意服务条款
		fast_tip.Show(GetDictString(6013))
		this.isClicked = false
		return false
	end
    return true
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
		    message_box.ShowGoldBox("已有新的版本，是否跳到商店进行更新？", 
			    {function ()					        	
		            message_box.Close()
		            Application.OpenURL(url)
		            Application.Quit()
		        end}, {"fonts_01"}) 

	    	message_box.SetBtnCloseCallBack(function ()
				Application.Quit()	
			end)
		    return 				    
		else					
			if url ~= nil and url ~= "" then
			    message_box.ShowGoldBox("已有新的版本，是否跳到商店进行更新？", 
			    	{function ()
			            message_box.Close()
			            --Application.Quit()
			            if callback ~= nil then
			            	callback()
			            	callback = nil
			            end
			        end, 
			        function ()					        	
			            message_box.Close()
			            Application.OpenURL(url)
			            Application.Quit()
			        end}, {"fonts_02", "fonts_01"})		

		    	message_box.SetBtnCloseCallBack(function ()
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
--如果是ios 则再请求一次审核标志
	if tostring(Application.platform) == "IPhonePlayer" then
    	if PlayerPrefs.HasKey("ioscard") and PlayerPrefs.GetInt("ioscard") == 0 then
			LuaHelper.isAppleVerify = false
			NetWorkManage.Instance.BaseUrl = "http://fjmj.dstars.cc/dstars/api/flashapi.php"
    	else 
		    http_request_interface.fetchCheckTag(function (str)
		    	Trace("str--------------------------------------"..str)
		    	local ret = ParseJsonStr(str)
		    	Trace("ret.ioscard ------------------------"..tostring(ret.data.ioscard))
		    	if ret.data.ioscard == 0 or ret.data.ioscard == nil then
		    		LuaHelper.isAppleVerify = false
		    		PlayerPrefs.SetInt("ioscard", 0)	
                    NetWorkManage.Instance.BaseUrl = "http://fjmj.dstars.cc/dstars/api/flashapi.php"	    		
		    		--重设微信登录按钮
		    		login_ui.RfreshBtnState() 
		    	else
		    		LuaHelper.isAppleVerify = true
		    	end
		    end,true)
		end
        Notifier.dispatchCmd(cmdName.MSG_LOGIN_NOTIFY)
   end		
end
--[[
登录请求服务器
]]
function this.RequestToServer(msgTable,isauto)
    local code ="code" 
    isauto=isauto or false
    if isauto then
        code ="openid"
    end
    http_request_interface.otherLogin(msgTable.loginType,msgTable.openId,msgTable.access_token,0,code,this.share_uid,function (code,m,str)
	    this.isClicked = false
	    local s=string.gsub(str,"\\/","/")
	    local t=ParseJsonStr(s) 
	    data_center.SetLoginUserInfo(t) 
        Trace(str)
        http_request_interface.setUserInfo(t["user"]["uid"],t["session_key"],t["user"]["deviceid"],1,t["passport"]["siteid"],"") 
	    if data_center.GetUserInfoTbl().ret == 0 then --登录成功  
			PlayerPrefs.SetInt("LoginType", msgTable.loginType) 
			PlayerPrefs.SetString("AccessToken", t["access_token"])
			PlayerPrefs.SetString("OpenID",t["openid"])   
			this.EnterHallRsp("")
			local urlStr = string.format(global_define.wsurl,data_center.GetLoginUserInfo().uid,t["session_key"])
			SocketManager:createSocket("hall",urlStr,this.binderName, this._svrID)	 
            return true
	    else
		    Trace("LoginError:"..data_center.GetUserInfoTbl().msg..tostring(data_center.GetUserInfoTbl().ret));
            return false
	    end 
	end,true)
end

function this.AutoLogin()
    local logintype=PlayerPrefs.GetInt("LoginType")	
	if tostring(Application.platform) == "WindowsEditor" then
		if logintype > 0 then			
		    return this.Login(LoginType.YOUKE)
        end
	elseif tostring(Application.platform)  == "Android" or tostring(Application.platform) == "IPhonePlayer" then
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
    	return this.RequestToServer(t,true)  
    end
    local msgTable={}
    if loginType==LoginType.WXLOGIN then
        YX_APIManage.Instance:WeiXinLogin(function(msg)	
		    msgTable = ParseJsonStr(msg) 
		    if msgTable.access_token == nil then
			    fast_tip.Show("登录失败")
			    return
		    end 
		    if msgTable.result == 0 then 
                msgTable.loginType=LoginType.WXLOGIN
                msgTable.openId=msgTable.access_token
                return this.RequestToServer(msgTable)
		    else
			    this.isClicked = false
		        YX_APIManage.Instance:CheckWXInstall(function (msg)
		    	    Trace("CheckWXInstall-----" .. msg)
		    	    local msgNum = tonumber(msg) or 0;
		    	    if msgNum == 1 then
		    	    else
		    		    fast_tip.Show("微信未安装")
		    	    end
		        end)
			    Trace("Login Failed"..tostring(msgTable))
		    end
	    end) 
    elseif loginType==LoginType.QQLOGIN then
        YX_APIManage.Instance:QQLogin(function(msg)
		msgTable = ParseJsonStr(msg) 
	    if msgTable.result == 0 then
            msgTable.loginType=LoginType.QQLOGIN
            msgTable.openId=msgTable.access_token
	        this.RequestToServer(msgTable)
	    else
		    Trace("Login Failed"..tostring(msgTable))
	    end
	    end)
    elseif loginType==LoginType.YOUKE then
        this.AppleCheck() 
        msgTable.loginType=LoginType.YOUKE
	    msgTable.access_token =0
	    msgTable.openId =NetWorkManage.Instance:GetMacAddress()
	    --平台成功回调后开始连接服务器并登陆服务器  
        return this.RequestToServer(msgTable) 
    end

end

function this.setShareUidFromPlatfrom(  )
	Trace("login_sys setShareUidFromPlatfrom onEnter-----")
	local s= YX_APIManage.Instance:read("temp.txt")
	if s~=nil then
      Trace("login_sys temp.txt str-----" .. s)
      local t=ParseJsonStr(s)
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

    --删除掉资源热更界面
    local assetUpdateObj = find("AssetUpdateManager")
    if assetUpdateObj ~= nil then
    	destroy(assetUpdateObj)
    end		
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
	map_controller.LoadHallScene(900001)	
end

 --[[--
 * @Description: 进入游戏
 ]]
function this.EnterGame()
	this.ReqEnterGame()
end
----------------------外部获取数据------------------


function this.GetLoginType()
    return LoginType
end
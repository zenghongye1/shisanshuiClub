--[[--
 * @Description: 登陆界面
 * @Author:      shine
 * @FileName:    login_ui.lua
 * @DateTime:    2017-05-18 15:06:02
 ]]

--require "common/TestMode"
require "logic/login_sys/login_sys" 
require"logic/common_ui/webview_ui"
login_ui = ui_base.New()
local this = login_ui

local logoCoroutine = nil
local btnWeiXin = nil 
local btnYouKe = nil 
local btnQQ = nil 

local timerClickReset = nil

--[[--
* @Description: 显示登陆ui
]]
function this.Show()
	if this.gameObject==nil then
		require ("logic/login_sys/login_ui")
		newNormalUI("Prefabs/UI/Login/login_ui")
		--测试用，直接登录		
	else
		this.gameObject:SetActive(true)
	end    
end

local iscomplete=false
--[[--
 * @Description: 启动事件
 ]] 
function this.Start()	  
   ui_sound_mgr.SceneLoadFinish()    
    local animations=child(this.transform,"tex_bg") 
    if animations~=nil then
        componentGet(animations.gameObject,"SkeletonAnimation"):ChangeQueue(2999)
    end
    local animations=child(this.transform,"logo") 
    if animations~=nil then
        componentGet(animations.gameObject,"SkeletonAnimation"):ChangeQueue(3000)
    end
    webview.InitwithSize(global_define.GetFwtkUrl(),180,30,180,180) 
	waiting_ui.Show()
    login_sys.GetAllUrl(function()
        if not login_sys.AutoLogin() then
		    this.RegisterEvents()
		    this:RegistUSRelation()
		    login_sys.isAgreeContract = true		
		    login_sys.InitPlugins(true)
            waiting_ui.Hide()	
	    end
    end)
	if IS_URL_TEST == true then
		newNormalUI("Prefabs/UI/testCmd/testUrl")
	end
end


function this.OnDestroy()
	this:UnRegistUSRelation()
	if logoCoroutine ~= nil then
		coroutine.stop(logoCoroutine)
	end   
	if IS_URL_TEST == true then
		require "logic/testCmd/testUrl"
		testUrl.Hide()
	end

	if timerClickReset ~= nil then
		timerClickReset:Stop()
		timerClickReset = nil
end
end

function this.OnApplicationQuit()
	
end

--[[--
 * @Description: 注册UI事件
 ]]
function this.RegisterEvents()
	btnYouKe = child(this.transform, "btn_grid/btn_youke_login")
	btnYouKe.gameObject:SetActive(LuaHelper.openGuestMode)
	if btnYouKe ~= nil then
		addClickCallbackSelf(btnYouKe.gameObject, this.OnBtnYouKeClick, this)
	end
     
    
	btnQQ = child(this.transform, "btn_grid/btn_qq_login")
	if btnQQ ~= nil then
		addClickCallbackSelf(btnQQ.gameObject, this.OnBtnQQClick, this)
	end

	btnWeiXin = child(this.transform, "btn_grid/btn_weixin_login")
	if btnWeiXin ~= nil then
		addClickCallbackSelf(btnWeiXin.gameObject, this.OnBtnWeiXinClick, this)
	end    
    initToggleObj(this.transform,"checkBox",this.OnCheckStatusChange,this)    
	
	local btnService = child(this.transform,"checkBox/bg")
	if btnService ~= nil then 
		addClickCallbackSelf(btnService.gameObject,this.OnServiceClick, this)
	end
 
 	this.RfreshBtnState()
end

function this.OnServiceClick() 
    webview_ui.url=global_define.GetFwtkUrl()   
    webview_ui:Show()
    webview_ui.UpdateTitle("fwtk") 
end

--[[--
 * @Description: 刷新按钮状态  
 ]]
function this.RfreshBtnState()
	if LuaHelper.isAppleVerify then
		btnYouKe.gameObject:SetActive(true)
		btnQQ.gameObject:SetActive(false)
		btnWeiXin.gameObject:SetActive(false)	
	else
		btnWeiXin.gameObject:SetActive(true)
	end
	subComponentGet(this.transform, "btn_grid", typeof(UIGrid)):Reposition()
  end  

function this.OnCheckStatusChange()
	local checkStatue = UIToggle.current.value
	if checkStatue == true then		
		login_sys.isAgreeContract = true;
		Trace("------------------------togglechgeistrue"..tostring(login_sys.isAgreeContract))		
	else
		login_sys.isAgreeContract = false;
		Trace("------------------------togglechgeisFlase"..tostring(login_sys.isAgreeContract))
	end
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
end

function this.OnBtnYouKeClick() 
	--界面处理 （To do）
	if login_sys.isClicked == true then
		Trace("is clicked,hold on!")
		return
	else
		login_sys.isClicked = true
	end
	timerClickReset = Timer.New(function ()
			login_sys.isClicked = false
	   end, 3, 1)
	timerClickReset:Start()
	
	login_sys.Login(login_sys.GetLoginType().YOUKE) 
end

function this.OnBtnQQClick() 
    if login_sys.isClicked == true then
    	Trace("is clicked,hold on!")
    	return
    else
    	login_sys.isClicked = true
    end
    
    --测试用，直接登录
    Trace("-------------------------------------OnBtnQQClick")
    
    login_sys.Login(login_sys.GetLoginType().QQLOGIN) 
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click") 
end

function this.OnBtnWeiXinClick() 
	  --界面处理 （To do）
	if login_sys.isClicked == true then
		Trace("is clicked,hold on!")
		return
	else
		login_sys.isClicked = true
	end

	 timerClickReset = Timer.New(function ()
	 		login_sys.isClicked = false
	 end, 3, 1)
	 timerClickReset:Start() 

	--测试用，直接登录
	Trace("-------------------------------------OnBtnWeiXinClick")
	if tostring(Application.platform) ==  "WindowsEditor"   then
		login_sys.Login(login_sys.GetLoginType().YOUKE) 
	elseif  tostring(Application.platform) == "Android" or  tostring(Application.platform) == "IPhonePlayer" then
		login_sys.Login(login_sys.GetLoginType().WXLOGIN) 
	end
	  ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click") 
end




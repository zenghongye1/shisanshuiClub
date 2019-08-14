--[[--
 * @Description: 登陆界面
 * @Author:      shine
 * @FileName:    login_ui.lua
 * @DateTime:    2017-05-18 15:06:02
 ]]

require "logic/login_sys/login_sys" 
require "logic/framework/ui/uibase/ui_window"


local base = require("logic.framework.ui.uibase.ui_window")
local BaseClass = class("login_ui",base)

local logoCoroutine = nil
local btnWeiXin = nil 
local btnYouKe = nil 
local btnQQ = nil 
local btnPhone = nil

local iscomplete=false
local timerClickReset = nil

function BaseClass:OnInit()
	self.loginModel = model_manager:GetModel("LoginModel")
	self.destroyType = UIDestroyType.Immediately
  --OnInit
end

function BaseClass:OnOpen(data)
  if not self.updateTimer then
      self.updateTimer = FrameTimer.New(function()
          self:ShowUI()
          -- self:RegistEvent()
          self.updateTimer = nil
        end,1,1)
      self.updateTimer:Start()
  end
end

function BaseClass:OnClose()
	-- self:UnregistEvent()
end

function BaseClass:PlayOpenAmination()
end

function BaseClass:OnRefreshDepth()

  local uiEffect = child(self.gameObject.transform, "Effect_guangxian")
  local effect = self:GetGameObject("oemBg/anim_role")
  if uiEffect and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
    Utils.SetEffectSortLayer(effect, topLayerIndex - 1)
  end
end

--[[--
* @Description: 显示登陆ui
]]
function BaseClass:ShowUI()
   ui_sound_mgr.SceneLoadFinish()    
   ui_sound_mgr.StopBgSound()
   --[[ local animations=child(self.transform,"tex_bg") 
    if animations~=nil then
        componentGet(animations.gameObject,"SkeletonAnimation"):ChangeQueue(2999)
    end
    local animations=child(self.transform,"logo") 
    if animations~=nil then
        componentGet(animations.gameObject,"SkeletonAnimation"):ChangeQueue(3000)
    end
    --]]
    local skeletonAnimComponet = self:GetComponent("oemBg/anim_role","SkeletonAnimation")
	if skeletonAnimComponet ~= nil then
	    skeletonAnimComponet:ChangeQueue(3001)
	end
	-- waiting_ui.Show()
	UI_Manager:Instance():ShowUiForms("waiting_ui")


	self.loginModel:GetClientConfig(slot(self.GetClientConfigCallback, self))
	 -- login_sys.GetAllUrl(function()
  --  --      if not login_sys.AutoLogin() then
		--  --    if tostring(Application.platform) ~= "IPhonePlayer" then
		-- 	-- 	self:RegisterEvents()
		-- 	-- else
		-- 	-- 	if PlayerPrefs.HasKey("ioscard") and PlayerPrefs.GetInt("ioscard") == 0 then
		-- 	-- 		self:RegisterEvents()
		-- 	-- 	end
		-- 	-- end

		--  --    login_sys.isAgreeContract = true		
		--  --    login_sys.InitPlugins(true)
		-- 	-- -- waiting_ui.Hide()
		-- 	-- UI_Manager:Instance():CloseUiForms("waiting_ui")
	 --  --   end
  --   end)


	-- if data_center.GetCurPlatform() == "IPhonePlayer" and YX_APIManage.Instance:isIphoneX() then
	-- 	local tex_bg=child(self.transform,"tex_bg") 
	-- 	if tex_bg then
	-- 		tex_bg.gameObject:SetActive(false)
	-- 	end
	-- 	local oemBg=child(self.transform,"oemBg")
	-- 	if oemBg then
	-- 		oemBg.gameObject:SetActive(true)
	-- 	end
	-- end
end


function BaseClass:GetClientConfigCallback()
    if not login_sys.AutoLogin() then
	    if tostring(Application.platform) ~= "IPhonePlayer" then
			self:RegisterEvents()
		else
			if PlayerPrefs.HasKey("ioscard") and PlayerPrefs.GetInt("ioscard") == 0 then
				self:RegisterEvents()
			end
		end

	    login_sys.isAgreeContract = true		
	    login_sys.InitPlugins(true)
		-- waiting_ui.Hide()
		UI_Manager:Instance():CloseUiForms("waiting_ui")
    end
end



--[[--
 * @Description: 注册UI事件
 ]]
function BaseClass:RegisterEvents()
	btnYouKe = child(self.transform, "btn_grid/btn_youke_login")
	btnYouKe.gameObject:SetActive(LuaHelper.openGuestMode)
	if btnYouKe ~= nil then
		addClickCallbackSelf(btnYouKe.gameObject, self.OnBtnYouKeClick, self)
	end
      
	btnQQ = child(self.transform, "btn_grid/btn_qq_login")
	if btnQQ ~= nil then
		addClickCallbackSelf(btnQQ.gameObject, self.OnBtnQQClick, self)
	end

	btnWeiXin = child(self.transform, "btn_grid/btn_weixin_login")
	if btnWeiXin ~= nil then
		addClickCallbackSelf(btnWeiXin.gameObject, self.OnBtnWeiXinClick, self)
	end
	--手机登录
	btnPhone = child(self.transform,"phone_login/Label")
	if btnPhone ~= nil then
		addClickCallbackSelf(btnPhone.gameObject,self.OnBtnPhoneClick,self)
	end

    initToggleObj(self.transform,"checkBox",self.OnCheckStatusChange,self)    
	
	local btnService = child(self.transform,"checkBox/bg")
	if btnService ~= nil then 
		addClickCallbackSelf(btnService.gameObject,self.OnServiceClick, self)
	end
 	
 	if tostring(Application.platform) == "IPhonePlayer" then
 		btnYouKe.gameObject:SetActive(false)
		btnQQ.gameObject:SetActive(false)
		btnWeiXin.gameObject:SetActive(false)
			-- 获取本地过审标志，初始化http URL
		if PlayerPrefs.HasKey("ioscard") and PlayerPrefs.GetInt("ioscard") == 0 then
			btnWeiXin.gameObject:SetActive(true)
			btnQQ.gameObject:SetActive(true)
		end
	else
 		self:RfreshBtnState()
	end
	subComponentGet(self.transform, "btn_grid", typeof(UIGrid)):Reposition()
end

function BaseClass:OnServiceClick() 
	UI_Manager:Instance():ShowUiForms("textView_ui",UiCloseType.UiCloseType_CloseNothing,function() 
		Trace("Close textView_ui__1")
	end,1)
end

--[[--
 * @Description: 刷新按钮状态  
 ]]
function BaseClass:RfreshBtnState()
	if LuaHelper.isAppleVerify then
		btnYouKe.gameObject:SetActive(true)
		btnQQ.gameObject:SetActive(false)
		btnWeiXin.gameObject:SetActive(false)

		local btn_grid = child(self.transform, "btn_grid")
		if btn_grid then
			local btnPos = btn_grid.gameObject.transform.localPosition
			btn_grid.gameObject.transform.localPosition = Vector3(280, btnPos.y, btnPos.z)
		end
	else
		btnWeiXin.gameObject:SetActive(true)
		btnQQ.gameObject:SetActive(true)
	end
	subComponentGet(self.transform, "btn_grid", typeof(UIGrid)):Reposition()
  end

--测试登录
function BaseClass:OpenTestLoginBtn()
	self:RegisterEvents()
	btnYouKe.gameObject:SetActive(true)
	btnWeiXin.gameObject:SetActive(true)
	btnQQ.gameObject:SetActive(true)
	subComponentGet(self.transform, "btn_grid", typeof(UIGrid)):Reposition()
 end

function BaseClass:OnCheckStatusChange()
	local checkStatue = UIToggle.current.value
	if checkStatue == true then		
		login_sys.isAgreeContract = true;
		Trace("------------------------togglechgeistrue"..tostring(login_sys.isAgreeContract))		
	else
		login_sys.isAgreeContract = false;
		Trace("------------------------togglechgeisFlase"..tostring(login_sys.isAgreeContract))
	end
    ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_button_click")
end

function BaseClass:OnBtnYouKeClick()

	--界面处理 （To do）
	if login_sys.isClicked == true then
		Trace("OnBtnYouKeClick is clicked,hold on!")
		return
	else
		login_sys.isClicked = true
	end
	timerClickReset = Timer.New(function ()
			login_sys.isClicked = false
	   end, 5, 1)
	timerClickReset:Start()
	
	login_sys.Login(login_sys.GetLoginType().YOUKE)
	ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_button_click")
end

function BaseClass:OnBtnQQClick()
	
--[[	UI_Manager:Instance():ShowUiForms("UiTest",UiCloseType.UiCloseType_Navigation,function() 
		Trace("Close uitest_a")
	end)
	UI_Manager:Instance():FastTip("adsafsdfasdfsdafsdfsdf")
--]]
	
	
   if login_sys.isClicked == true then
    	Trace("OnBtnQQClick is clicked,hold on!")
    	return
    else
    	login_sys.isClicked = true
    end
    timerClickReset = Timer.New(function ()
		login_sys.isClicked = false
	end, 5, 1)
	timerClickReset:Start() 
	
    --测试用，直接登录
    Trace("-------------------------------------OnBtnQQClick")
	if data_center.GetCurPlatform() ==  "WindowsEditor"   then
		login_sys.Login(login_sys.GetLoginType().YOUKE) 
	elseif  data_center.GetCurPlatform() == "Android" or data_center.GetCurPlatform() == "IPhonePlayer" then
		login_sys.Login(login_sys.GetLoginType().QQLOGIN) 
	end
    ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_button_click") 
end

function BaseClass:OnBtnWeiXinClick() 
	if login_sys.isClicked == true then
		Trace("OnBtnWeiXinClick is clicked,hold on!")
		return
	else
		login_sys.isClicked = true
	end
	timerClickReset = Timer.New(function ()
		login_sys.isClicked = false
	end, 5, 1)
	timerClickReset:Start() 

	--测试用，直接登录
	Trace("-------------------------------------OnBtnWeiXinClick")
	if data_center.GetCurPlatform() ==  "WindowsEditor" or data_center.GetCurPlatform() == "OSXEditor"  then
		login_sys.Login(login_sys.GetLoginType().YOUKE) 
	elseif  data_center.GetCurPlatform() == "Android" or  data_center.GetCurPlatform() == "IPhonePlayer" then
		login_sys.Login(login_sys.GetLoginType().WXLOGIN) 
	end
	  ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_button_click") 
end

function BaseClass:OnBtnPhoneClick()
	UI_Manager:Instance():ShowUiForms("phoneLogin_ui")
end

return BaseClass

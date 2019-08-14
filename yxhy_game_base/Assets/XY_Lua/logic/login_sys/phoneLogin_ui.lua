local base = require("logic.framework.ui.uibase.ui_window")
local phoneLogin_ui = class("phoneLogin_ui",base) 
local param = {}
	local account = nil
	local password = nil
	local tAccount = nil
	local tPassword =nil
function phoneLogin_ui:ctor()
	base.ctor(self)
end

function phoneLogin_ui:OnInit()
	self.loginModel = model_manager:GetModel("LoginModel")
	self:InitView()
	self.isRember = false
end

function phoneLogin_ui:OnOpen()
	self.remberValue = 0
	self:UpdateView()
end


function phoneLogin_ui:InitView()
	local btn_close = child(self.gameObject.transform,"phoneLogin_panel/Panel_Top/btn_close")
	if btn_close ~= nil then
		addClickCallbackSelf(btn_close.gameObject,self.CloseWin,self)
	end
	local btn_sure = child(self.gameObject.transform,"phoneLogin_panel/Panel_Top/btn_sure")
	if btn_sure ~= nil then
		addClickCallbackSelf(btn_sure.gameObject,self.OnSureClick,self)
	end
	local Panel_Middle = child(self.gameObject.transform,"phoneLogin_panel/Panel_Middle")
	self.btn_forget = child(Panel_Middle,"forget_password/Label")
	if self.btn_forget then
		addClickCallbackSelf(self.btn_forget.gameObject,self.OnForgetClick,self)
	end

	self.accountInput = componentGet(child(Panel_Middle,"account_num/type_phonenum"),"UIInput")
	self.passwordInput = componentGet(child(Panel_Middle,"password_num/type_password"),"UIInput")

	self.remberBtn = child(Panel_Middle,"Rember_password")
	self.Checkmark = child(self.remberBtn.transform,"Checkmark")
	if self.remberBtn then
		addClickCallbackSelf(self.remberBtn.gameObject,self.OnRemberBtnClick,self)
	end
end

function phoneLogin_ui:UpdateView()
	self.accountInput.value = ""
	self.passwordInput.value = ""
	if PlayerPrefs.HasKey(global_define.RemberPassWordFlag) then
		local remberFlag = PlayerPrefs.GetString(global_define.RemberPassWordFlag)
		self.remberValue = tonumber(remberFlag)
		if self.remberValue then
			if PlayerPrefs.HasKey(global_define.Password) then
				local pass = PlayerPrefs.GetString(global_define.Password)
				self.passwordInput.value = pass
			end
			if PlayerPrefs.HasKey(global_define.Account) then
				local account = PlayerPrefs.GetString(global_define.Account)
				self.accountInput.value = account
			end
		end
	end
	if self.remberValue == 1 then
		self.Checkmark.gameObject:SetActive(true)
	end	
end

function phoneLogin_ui:CloseWin()
	ui_sound_mgr.PlayCloseClick()
	UI_Manager:Instance():CloseUiForms("phoneLogin_ui")
end

function phoneLogin_ui:OnSureClick()
	
	param = {}
	tAccount = self.accountInput.value
	tPassword = self.passwordInput.value
	if tAccount == "" or string.len(tAccount) ~= 11 then
		UI_Manager:Instance():FastTip(LanguageMgr.GetWord(10311))
		return
	elseif tPassword == "" or string.len(tPassword) < 6 or string.len(tPassword) > 15  then
		UI_Manager:Instance():FastTip(LanguageMgr.GetWord(10308))
		return
	else
		param.appid = global_define.appConfig.appId
		param.devicetype = data_center.GetDeviceType()
		param.version = data_center.GetVerCommInfo().versionNum
		param.phone = tAccount
		param.pwd = tPassword
		self:SaveRemberValue()--保存记住密码
		HttpProxy.SendGlobalRequest("/login",HttpCmdName.UserPhoneLogin,param,
			function (userInfo)
				if userInfo.ret == 1000004 then -- 手机号或密码错误
	 				UI_Manager:Instance():FastTip(LanguageMgr.GetWord(1000004))
	 				return
				else
					self.loginModel:OnResUserLogin(userInfo)
				end
			end,self)
	end
end

function phoneLogin_ui:OnRemberBtnClick()
	if not self.isRember then
		self.Checkmark.gameObject:SetActive(true)
		self.remberValue = 1--记住密码
		self.isRember = true 
	else
		self.Checkmark.gameObject:SetActive(false)
		self.remberValue = 2--不记住
		self.isRember = false
	end
end

function phoneLogin_ui:SaveAccount_Pass()
	if self.remberValue == 1 then
		account = tAccount
		password = tPassword
	else
		account = tAccount
		password = ""
	end
end

function phoneLogin_ui:SaveRemberValue()
	self:SaveAccount_Pass()

	--记住密码  持久化保存
	if not PlayerPrefs.HasKey(global_define.RemberPassWordFlag) then
		PlayerPrefs.SetString(global_define.RemberPassWordFlag,(self:GetRemberValue() and 1) or 0)
		return
	end
	PlayerPrefs.SetString(global_define.RemberPassWordFlag,(self:GetRemberValue() and 1) or 0)
	--记住账号
	if not PlayerPrefs.HasKey(global_define.Account) then
		PlayerPrefs.SetString(global_define.Account,tostring(account))
		return
	end
	PlayerPrefs.SetString(global_define.Account,tostring(account))
	--记住密码
	if not PlayerPrefs.HasKey(global_define.Password) then
		PlayerPrefs.SetString(global_define.Password,tostring(password))
		return
	end
	PlayerPrefs.SetString(global_define.Password,tostring(password))
end


function phoneLogin_ui:OnForgetClick()
	ui_sound_mgr.PlayCloseClick()
	UI_Manager:Instance():ShowUiForms("forgetPassword_ui")
end

function phoneLogin_ui:GetRemberValue()
	if self.remberValue == 1 then
		return true 
	end
	return false
end

return phoneLogin_ui
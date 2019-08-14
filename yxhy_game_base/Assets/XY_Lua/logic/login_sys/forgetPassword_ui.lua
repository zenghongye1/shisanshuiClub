local base = require("logic.framework.ui.uibase.ui_window")
local forgetPassword_ui = class("forgetPassword_ui",base)


local param = {}
	local tel_num = nil
	local ver_num = nil
	local password = nil


function forgetPassword_ui:ctor()
	base.ctor(self)
end

function forgetPassword_ui:OnInit()
	self:InitView()
end

function forgetPassword_ui:OnOpen()
	self:UpdateView()
end

function forgetPassword_ui:PlayOpenAmination()
	
end

function forgetPassword_ui:InitView()
	local btn_close = child(self.gameObject.transform,"forgetPassword_panel/Panel_Top/btn_close")
	if btn_close ~= nil then
		addClickCallbackSelf(btn_close.gameObject,self.CloseWin,self)
	end
	local btn_sure = child(self.gameObject.transform,"forgetPassword_panel/Panel_Top/btn_sure")
	if btn_sure ~= nil then
		addClickCallbackSelf(btn_sure.gameObject,self.OnSureClick,self)
	end
	--绑定
	local Panel_Middle = child(self.gameObject.transform,"forgetPassword_panel/Panel_Middle")
	self.accountInput = componentGet(child(Panel_Middle,"tel_num/type_phonenum"),"UIInput")--手机号
	self.vernumInput = componentGet(child(Panel_Middle,"ver_num/type_vernum"),"UIInput")--验证码
	self.passwordInput = componentGet(child(Panel_Middle,"password/type_password"),"UIInput")--密码
	self.getVer_Btn = child(Panel_Middle,"getVerBtn")
	if self.getVer_Btn then
		addClickCallbackSelf(self.getVer_Btn.gameObject,self.OnGetVerClick,self)
	end

end


function forgetPassword_ui:GetValue()
	tel_num = self.accountInput.value
	ver_num = self.vernumInput.value
	password = self.passwordInput.value
end


function forgetPassword_ui:UpdateView()
	self.accountInput.value = ""
	self.vernumInput.value = ""
	self.passwordInput.value = ""
end

function forgetPassword_ui:CloseWin()
	ui_sound_mgr.PlayCloseClick()
	UI_Manager:Instance():CloseUiForms("forgetPassword_ui")
end

function forgetPassword_ui:OnGetVerClick()
	self:GetValue()
	if tel_num == "" or string.len(tel_num) ~= 11 then
		UI_Manager:Instance():FastTip(LanguageMgr.GetWord(10311))
		return
	end

	param.appid = global_define.appConfig.appId
	param.phone = tel_num
	HttpProxy.SendGlobalRequest("/login",HttpCmdName.GetPhoneVerifyCode,param,
		function (msgTab)
			logError(1111,GetTblData(msgTab))
		end,self)
end

function forgetPassword_ui:OnClose()
	self.accountInput.value = ""
	self.vernumInput.value = ""
	self.passwordInput.value = ""

end


function forgetPassword_ui:OnSureClick()
	param = {}
	self:GetValue()
	if tel_num == "" or string.len(tel_num) ~= 11 then
		UI_Manager:Instance():FastTip(LanguageMgr.GetWord(10311))
		return
	elseif ver_num == "" or string.len(ver_num) ~= 6 then
		UI_Manager:Instance():FastTip(LanguageMgr.GetWord(10310))
		return
	elseif password == "" or string.len(password) < 6 or string.len(password) > 15 then
		UI_Manager:Instance():FastTip(LanguageMgr.GetWord(10308))
		return
	end
	param.appid = global_define.appConfig.appId
	param.vercode = ver_num
	param.phone = tel_num
	param.pwd = password
	HttpProxy.SendGlobalRequest("/login",HttpCmdName.UpdatePwdByPhone,param,
		function (userInfo)
			logError(22222,GetTblData(userInfo))
		end,self)
	UI_Manager:Instance():CloseUiForms("forgetPassword_ui")
		
end

return forgetPassword_ui

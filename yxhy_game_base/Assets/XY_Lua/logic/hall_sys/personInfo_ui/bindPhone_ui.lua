local base = require("logic.framework.ui.uibase.ui_window")
local bindPhone_ui = class("bindPhone_ui",base)


local param = {}
local phone = 0
local opttype = 0
	local tel_num = nil
	local ver_num = nil
	local password = nil
	local newtelnum = nil
function bindPhone_ui:ctor()
	base.ctor(self)
	self.isRevise = false
end

function bindPhone_ui:OnInit()
	self:InitView()
	opttype = 0
end

function bindPhone_ui:OnOpen(force,callback,target)
	self.closecallback  = callback
	self.target = target
	if not force then
		self.isRevise = true
		opttype = 1
	end
	self:UpdateView()
end

function bindPhone_ui:PlayOpenAmination()
	
end

function bindPhone_ui:InitView()
	local btn_close = child(self.gameObject.transform,"bindPhone_panel/Panel_Top/btn_close")
	if btn_close ~= nil then
		addClickCallbackSelf(btn_close.gameObject,self.CloseWin,self)
	end
	local btn_sure = child(self.gameObject.transform,"bindPhone_panel/Panel_Top/btn_sure")
	if btn_sure ~= nil then
		addClickCallbackSelf(btn_sure.gameObject,self.OnSureClick,self)
	end
	--绑定
	self.Panel_Bind = child(self.gameObject.transform,"bindPhone_panel/Panel_Bind")
	self.tel_numInput_b = componentGet(child(self.Panel_Bind,"tel_num/type_phonenum"),"UIInput")--手机号
	self.ver_numInput_b = componentGet(child(self.Panel_Bind,"ver_num/type_vernum"),"UIInput")--验证码
	self.passwordInput_b = componentGet(child(self.Panel_Bind,"password/type_password"),"UIInput")--密码
	self.getVer_Btn_b = child(self.Panel_Bind,"getVerBtn")
	if self.getVer_Btn_b then
		addClickCallbackSelf(self.getVer_Btn_b.gameObject,self.OnGetVerClick,self)
	end
	--修改
	self.Panel_Revise = child(self.gameObject.transform,"bindPhone_panel/Panel_Revise")
	self.getVer_Btn_r = child(self.Panel_Revise,"getVerBtn")
	if self.getVer_Btn_r then
		addClickCallbackSelf(self.getVer_Btn_r.gameObject,self.OnGetVerClick,self)
	end
	--componentGet(child(self.gameObject.transform,"certification_panel/Panel_Middle/lbl_name/Input"),"UIInput")
	self.tel_numInput_r = componentGet(child(self.Panel_Revise,"telnum/type_phonenum"),"UIInput")--手机号
	self.ver_numInput_r = componentGet(child(self.Panel_Revise,"vernum/type_vernum"),"UIInput")--验证码
	self.passwordInput_r = componentGet(child(self.Panel_Revise,"password/type_password"),"UIInput")--密码
	self.newtel_numInput_r = componentGet(child(self.Panel_Revise,"newtelnum/type_newphonenum"),"UIInput")
end

function bindPhone_ui:GetValue()
	if not self.isRevise then
		newtelnum = self.tel_numInput_b.value
		ver_num = self.ver_numInput_b.value
		password = self.passwordInput_b.value
	else
		tel_num = self.tel_numInput_r.value
		ver_num = self.ver_numInput_r.value
		password = self.passwordInput_r.value
		newtelnum = self.newtel_numInput_r.value
	end
end


function bindPhone_ui:UpdateView()

	self.tel_numInput_b.value = ""
	self.ver_numInput_b.value = ""
	self.passwordInput_b.value = ""
	self.tel_numInput_r.value = ""
	self.ver_numInput_r.value = ""
	self.passwordInput_r.value = "" 
	self.newtel_numInput_r.value = ""
	if self.isRevise then
		self.Panel_Revise.gameObject:SetActive(true)
		self.Panel_Bind.gameObject:SetActive(false)
	else
		self.Panel_Bind.gameObject:SetActive(true)
		self.Panel_Revise.gameObject:SetActive(false)
	end
end

function bindPhone_ui:CloseWin()
	ui_sound_mgr.PlayCloseClick()
	UI_Manager:Instance():CloseUiForms("bindPhone_ui")
end

function bindPhone_ui:OnClose()
	self.tel_numInput_b.value = ""
	self.ver_numInput_b.value = ""
	self.passwordInput_b.value = ""
	self.tel_numInput_r.value = ""
	self.ver_numInput_r.value = ""
	self.passwordInput_r.value = "" 
	self.newtel_numInput_r.value = ""
	if self.closecallback ~= nil then
		self.closecallback(self.target,phone)
		self.closecallback = nil
	end
end

function bindPhone_ui:OnGetVerClick()
	param = {}
	self:GetValue()
	if newtelnum == ""  or string.len(newtelnum) ~= 11 then--or type(newtelnum) ~= "number"
		UI_Manager:Instance():FastTip(LanguageMgr.GetWord(10311))
		return
	end
	param.appid = global_define.appConfig.appId
	param.phone = newtelnum
	HttpProxy.SendGlobalRequest("/login",HttpCmdName.GetPhoneVerifyCode,param,
		function (msgTab)
			logError(1111,GetTblData(msgTab))
		end,self)
end

function bindPhone_ui:OnSureClick()
	param = {}
	self:GetValue()
	if newtelnum == "" or string.len(newtelnum) ~= 11 then
		UI_Manager:Instance():FastTip(LanguageMgr.GetWord(10311))
		return
	elseif ver_num == "" or string.len(ver_num) ~= 6 then
		UI_Manager:Instance():FastTip(LanguageMgr.GetWord(10310))
		return
	elseif password == "" or string.len(password) < 6 or string.len(password) > 15 then
		UI_Manager:Instance():FastTip(LanguageMgr.GetWord(10309))
		return
	else
		param.appid = global_define.appConfig.appId
		param.uid = data_center.GetLoginUserInfo().uid
		param.opttype = opttype
		param.vercode = ver_num
		param.newphone = newtelnum
		param.pwd = password
		if opttype == 1 then
			param.oldphone = tel_num
			param.newphone = newtelnum
		end
		HttpProxy.SendUserRequest(HttpCmdName.BindPhone,param,
		function (msgTab)
			if msgTab.ret ~= nil then
				if msgTab.ret == 1030003 then 
					UI_Manager:Instance():FastTip(LanguageMgr.GetWord(1030003))--手机号或密码错误
				elseif msgTab.ret == 1000003 then --验证失败 
					UI_Manager:Instance():FastTip(LanguageMgr.GetWord(1000003))
				end
			elseif msgTab.phone == newtelnum then
				UI_Manager:Instance():FastTip(LanguageMgr.GetWord(10312))--绑定成功
			end
			data_center.SetPhoneNum(tonumber(msgTab.phone))
			phone =tonumber(msgTab.phone) 
		end, nil, HttpProxy.ShowWaitingSendCfg)
	end
end

return bindPhone_ui

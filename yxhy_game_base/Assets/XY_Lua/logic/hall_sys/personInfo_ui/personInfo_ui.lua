local base = require("logic.framework.ui.uibase.ui_window")
local personInfo_ui = class("personInfo_ui",base)
local bindPhone_ui = require "logic/hall_sys/personInfo_ui/bindPhone_ui"
local loginIcon = {
	[LoginType.WXLOGIN] = "icon_06",
	[LoginType.QQLOGIN] = "icon_26",
	[LoginType.YOUKE] = "icon_06",
}

local loginTypeCache = -1

function personInfo_ui:ctor()
	base.ctor(self)
	self.curLocationId = 0
	self.selfUserInfo = nil
	self.isLoginOut = false
end

function personInfo_ui:OnInit()
	self:InitView()
end

function personInfo_ui:OnOpen(id,isLoginOut)
	self.isLoginOut = isLoginOut or false
	self.uid = id or data_center.GetLoginUserInfo().uid
	self:UpdateView(self.uid)
end

function personInfo_ui:PlayOpenAmination()
 	--打开动画重写
 end

function personInfo_ui:OnRefreshDepth()
	--[[local uiEffect = child(self.gameObject.transform, "personInfo_panel/Panel_Top/Title/Effect_youxifenxiang")
	if uiEffect and self.sortingOrder then
	local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
		Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
	end--]]
end

--[[function personInfo_ui:PlayOpenAnimationFinishCallBack()	--tween动画播放再刷新界面，否则会出现渲染空白的问题
	-- self:UpdateView(self.uid)
end--]]

function personInfo_ui:InitView()
	local btn_close = child(self.gameObject.transform,"personInfo_panel/Panel_Top/btn_close")
	if btn_close ~= nil then
		addClickCallbackSelf(btn_close.gameObject,self.CloseWin,self)
	end
	
	local Panel_Middle = child(self.gameObject.transform,"personInfo_panel/Panel_Middle")
	self.tex_photo = subComponentGet(Panel_Middle,"head","UITexture")
	self.lbl_name = subComponentGet(Panel_Middle,"info/name","UILabel")
	self.lbl_id = subComponentGet(Panel_Middle,"info/id","UILabel")
	self.lbl_address = subComponentGet(Panel_Middle,"info/address","UILabel")
	
	self.btn_copy = child(Panel_Middle,"info/copyBtn")
	if self.btn_copy ~= nil then
		addClickCallbackSelf(self.btn_copy.gameObject,self.ClickCopyBtn,self)
	end
	self.btn_address = child(Panel_Middle,"info/switchBtn")
	if self.btn_address ~= nil then
		addClickCallbackSelf(self.btn_address.gameObject,self.SwitchAddress,self)
	end
	self.btn_change = child(Panel_Middle,"changeBtn")
	if self.btn_change then
		addClickCallbackSelf(self.btn_change.gameObject,self.ChangeAccount,self)
	end
	self.loginIconSp = subComponentGet(self.btn_change,"icon","UISprite")
	self.sure_btn = child(self.gameObject.transform,"personInfo_panel/Panel_Bottom/sureBtn")
	if self.sure_btn then
		addClickCallbackSelf(self.sure_btn.gameObject,self.SureOnClick,self)
	end
	--绑定
	self.bound = child(self.gameObject.transform,"personInfo_panel/Panel_Middle/bound")
	self.btn_bind = child(Panel_Middle,"bound/boundBtn")
	if self.btn_bind then
		addClickCallbackSelf(self.btn_bind.gameObject,self.BindOnClick,self)
	end
	--修改
	self.revise = child(self.gameObject.transform,"personInfo_panel/Panel_Middle/revise")
	self.btn_revise = child(Panel_Middle,"revise/reviseBtn")
	if self.btn_revise then
		addClickCallbackSelf(self.btn_revise.gameObject,self.ReviseOnClick,self)
	end
	self.phonenum = subComponentGet(self.revise,"phonenum","UILabel")
	self.bound.gameObject:SetActive(true)
end

function personInfo_ui:UpdateView(uid)
	local loginType = data_center.GetPlatform()
	if loginType ~= loginTypeCache then
		loginTypeCache = loginType
		self.loginIconSp.spriteName = loginIcon[loginTypeCache]
	end
	self.btn_address.gameObject:SetActive(uid == data_center.GetLoginUserInfo().uid)
	self.btn_change.gameObject:SetActive(uid == data_center.GetLoginUserInfo().uid and self.isLoginOut)
	self:SetInfoData(uid,function ()
		if self.IsOpened then
			self:UpdateUserInfo()
		end
	end)
end

function personInfo_ui:UpdateUserInfo()
	if not self.userInfo or isEmpty(self.userInfo) then
		return
	end
	HeadImageHelper.SetImage(self.tex_photo,2,self.userInfo.imageurl)
	self.lbl_name.text = "昵称："..self.userInfo.nickname
	self.lbl_id.text = "ID ："..self.userInfo.uid
	
	if self.userInfo.city == nil or tonumber(self.userInfo.city) == 0 then
		self.lbl_address.text = "位置：".."中国"
	else
		self.lbl_address.text = "位置："..ClubUtil.GetLocationNameById(tonumber(self.userInfo.city),"中国")
	end

	if data_center.GetLoginUserInfo().phone ~= nil then
		self.phonenum.text = data_center.GetLoginUserInfo().phone
		self.revise.gameObject:SetActive(true)
		self.bound.gameObject:SetActive(false)
	end
end


--请求数据
function personInfo_ui:SetInfoData(uid,callback)
	self:UseSelfCacheData(uid, callback)
	http_request_interface.GetUserInfo(uid,function (str)
		local s = string.gsub(str,"\\/","/")  
		local t = ParseJsonStr(s)
		if t.ret == 0 then
			self.userInfo = t.userinfo
			if callback then
				callback()
			end

			if t.userinfo.uid == data_center.GetLoginUserInfo().uid then	
				self.selfUserInfo = t.userinfo
			end
		else
			UI_Manager:Instance():FastTip("获取玩家信息失败！")
		end
	end)
end

--缓存
function personInfo_ui:UseSelfCacheData(uid ,callback)
	if uid ~= data_center.GetLoginUserInfo().uid then
		return
	end
	if self.selfUserInfo then
		self.userInfo = self.selfUserInfo
		if callback then
			callback()
		end
	end
end

function personInfo_ui:SwitchAddress()
	ui_sound_mgr.PlayCloseClick()
	UIManager:Instance():ShowUiForms("ClubLocationChooseUI", nil, nil, self.curLocationId, self.OnPositionSelected, self)
end


function personInfo_ui:OnPositionSelected(id)

	if id == nil or id == 0 then
		return
	end
	if self.curLocationId == id then
		return
	end
	self:SetUserCity(id,function()	
		self.curLocationId = id
		self.lbl_address.text = "位置："..ClubUtil.GetLocationNameById(id,"中国")
	end)
end

function personInfo_ui:SetUserCity(cityID,callback)
	http_request_interface.SetUserCity(cityID,function (str)
		local s = string.gsub(str,"\\/","/")  
		local t = ParseJsonStr(s)
		if t.ret == 0 then
			callback()
		else
			UI_Manager:Instance():FastTip("设置位置失败！")
		end
	end)
end

---复制id
function personInfo_ui:ClickCopyBtn()	
	ui_sound_mgr.PlayCloseClick()
	local str = self.userInfo.uid or data_center.GetLoginUserInfo().uid
	Trace("Id --- OnCopyBtnClick:"..tostring(str))
	YX_APIManage.Instance:onCopy(str,function()UI_Manager:Instance():FastTip(LanguageMgr.GetWord(6043))end)
end

function personInfo_ui:ChangeAccount()
	ui_sound_mgr.PlayCloseClick()
	MessageBox.ShowYesNoBox(LanguageMgr.GetWord(6029),function() 
   		UI_Manager:Instance():CloseUiForms("personInfo_ui")
   		Notifier.dispatchCmd(cmdName.MSG_CHANGE_ACCOUNT, nil)
		game_scene.gotoLogin()  		
        game_scene.GoToLoginHandle()
   	end)
end

function personInfo_ui:SureOnClick()
	ui_sound_mgr.PlayCloseClick()
	UI_Manager:Instance():CloseUiForms("personInfo_ui")
end
--绑定手机号
function personInfo_ui:BindOnClick()
	ui_sound_mgr.PlayCloseClick()
	UIManager:Instance():ShowUiForms("bindPhone_ui", nil, nil,true,self.OnChangePhoneNum, self)
end
--修改手机号
function personInfo_ui:ReviseOnClick()
	ui_sound_mgr.PlayCloseClick()
	UI_Manager:Instance():ShowUiForms("bindPhone_ui",nil,nil,false,self.OnChangePhoneNum, self)
end

function personInfo_ui:OnChangePhoneNum(phone)
	logError(234432,phone)
	if phone == nil or phone == 0 then
		return
	end
	logError(345543,phone)
	self.revise.gameObject:SetActive(true)
	self.bound.gameObject:SetActive(false)
	if self.phonenum then
		logError(456654,phone)
		self.phonenum.text = phone
	end
end

function personInfo_ui:CloseWin()
	ui_sound_mgr.PlayCloseClick()
	UI_Manager:Instance():CloseUiForms("personInfo_ui")
end

function personInfo_ui:ReSetState()
	self.tex_photo.mainTexture = newNormalObjSync(data_center.GetAppConfDataTble().appPath.."/uitextures/art/common_head", typeof(UnityEngine.Texture2D))
	self.lbl_name.text = "昵称："
	self.lbl_id.text = "ID："
	self.lbl_address.text = "位置："
end

function personInfo_ui:OnClose()
	self:ReSetState()
end

return personInfo_ui
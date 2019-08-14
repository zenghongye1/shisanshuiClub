local hall_setting = class("hall_setting")

function hall_setting:ctor(Ui)	
	self.hall_setting = Ui
	self.personInfo = {}
	self:InitView()
	self:UpdateView()
end

local iconList = 
{
	[LoginType.WXLOGIN] = "icon_06",
	[LoginType.QQLOGIN] = "icon_26",
}

function hall_setting:InitView()
	self.personInfo.tex_photo = child(self.hall_setting,"tex_photo") 
    self.personInfo.lbl_name = child(self.personInfo.tex_photo,"lab_name")  
	self.personInfo.lbl_id = child(self.personInfo.tex_photo,"lab_id")   
	self.personInfo.lbl_vipLevel = child(self.personInfo.tex_photo,"vipIcon/level")
	
	self.lbl_version = subComponentGet(self.hall_setting, "lab_version", "UILabel")
	
	self.btn_change = child(self.hall_setting,"btn_change")
	if self.btn_change ~= nil then	
		addClickCallbackSelf(self.btn_change.gameObject,self.ChangeClick, self)
	end
	
	self.btn_rule = child(self.hall_setting,"btn_rule")	--规则
    if self.btn_rule ~= nil then
        addClickCallbackSelf(self.btn_rule.gameObject,self.RuleClick,self)
    end
	
	self.btn_update = child(self.hall_setting,"btn_update")	--更新
    if self.btn_update ~= nil then
        addClickCallbackSelf(self.btn_update.gameObject,self.UpdateClick,self)
    end
	
	self.tran_vip = child(self.personInfo.tex_photo,"vipIcon")	--为设计先屏蔽
	self.tran_vip.gameObject:SetActive(false)
end

function hall_setting:UpdateView()
	if self.personInfo ~= nil and not isEmpty(self.personInfo) then			--个人信息
		HeadImageHelper.SetImage(componentGet(self.personInfo.tex_photo,"UITexture"))
		componentGet(self.personInfo.lbl_name.gameObject,"UILabel").text = data_center.GetLoginUserInfo().nickname
		componentGet(self.personInfo.lbl_id.gameObject,"UILabel").text = "ID："..data_center.GetLoginUserInfo().uid
		componentGet(self.personInfo.lbl_vipLevel.gameObject,"UILabel").text = "2" 	--VIP等级待处理
	end
	
	if self.lbl_version ~= nil then
		self.lbl_version.text = "当前版本：V"..data_center.GetVerCommInfo().versionNum
    end
	
	if self.btn_change ~= nil then	
		local iconSp = subComponentGet(self.btn_change, "icon","UISprite")
		local loginType = data_center.GetPlatform()
		if loginType == LoginType.WXLOGIN then
			iconSp.spriteName = iconList[LoginType.WXLOGIN]
		elseif loginType == LoginType.QQLOGIN then
			iconSp.spriteName = iconList[LoginType.QQLOGIN]
		else
			iconSp.spriteName = iconList[LoginType.WXLOGIN]
		end
		iconSp:MakePixelPerfect()
		self.btn_change.gameObject:SetActive(true)
	end
end

function hall_setting:ChangeClick()
   MessageBox.ShowYesNoBox(GetDictString(6029), 
   	function() 
   		UI_Manager:Instance():CloseUiForms("setting_ui")
		game_scene.gotoLogin()  		
        game_scene.GoToLoginHandle()
   	end)
end

function hall_setting:RuleClick()
	ui_sound_mgr.PlayButtonClick()
	UI_Manager:Instance():ShowUiForms("help_ui",UiCloseType.UiCloseType_CloseNothing,function() 
			Trace("Close help_ui")
		end, ENUM_GAME_TYPE.TYPE_SHISHANSHUI)
end

function hall_setting:UpdateClick()
	local version = data_center.GetVerCommInfo().versionNum  
	http_request_interface.GetVersionUp(version,function (str)
		local s = string.gsub(str, "\\/", "/")
		local retStr = ParseJsonStr(s)
		if retStr ~= nil and retStr.ret == 0 then
			if not isEmpty(retStr["updateInfo"]) then		
				local isNeed = retStr["updateInfo"]["forceUpdate"]["isNeed"] or false
				if isNeed then
					if retStr["updateInfo"]["forceUpdate"]["url"] ~= "" then
						local url = retStr["updateInfo"]["forceUpdate"]["url"]
						MessageBox.ShowYesNoBox("发现新的内容需要更新，\n是否现在进行更新？",function() 
							Application.OpenURL(url)
							UI_Manager:Instance():CloseUiForms("MessageBox")
						end,function()
							UI_Manager:Instance():CloseUiForms("MessageBox")
						end)
					end
				else
					UI_Manager:Instance():FastTip("暂无更新")
				end
			end
		end
 	end)
end

return hall_setting
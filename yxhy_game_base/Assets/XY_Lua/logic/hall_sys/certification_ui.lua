local base = require("logic.framework.ui.uibase.ui_window")
local certification_ui = class("certification_ui",base)

function certification_ui:OnInit()
	self.destroyType = UIDestroyType.Immediately
	self:InitView()
end

function certification_ui:OnOpen() 	
	self:UpdateView()	 
end

function certification_ui:InitView()
	local btnClose = child(self.transform, "certification_panel/Panel_Top/btn_close")
	if btnClose ~= nil then 
	   addClickCallbackSelf(btnClose.gameObject,self.CloseWin,self)
	end
	
	local btnSend = child(self.transform, "certification_panel/Panel_Middle/btn_submit")
	if btnSend ~= nil then
		addClickCallbackSelf(btnSend.gameObject,self.OnBtnSendClick, self)
	end
	
	self.mNameInput = componentGet(child(self.gameObject.transform,"certification_panel/Panel_Middle/lbl_name/Input"),"UIInput") 
	self.mIdentity = componentGet(child(self.gameObject.transform,"certification_panel/Panel_Middle/lbl_code/Input"),"UIInput") 
end

function certification_ui:UpdateView()
	self.mNameInput.value = ""
	self.mIdentity.value = ""
end

function certification_ui:OnBtnSendClick()
	local tName = self.mNameInput.value
	local tIdentity = self.mIdentity.value
	local tIdentityCount = string.len(tIdentity)
	 
	if tName == "" then
		UI_Manager:Instance():FastTip(LanguageMgr.GetWord(6005))
	elseif tIdentity == "" then
		UI_Manager:Instance():FastTip(LanguageMgr.GetWord(6006))
	elseif tIdentityCount ~= 15 and tIdentityCount ~= 18 then
		UI_Manager:Instance():FastTip(LanguageMgr.GetWord(6007))
	else	
		http_request_interface.idCardVerify(tName,tIdentity,function (str) 
			local s = string.gsub(str,"\\/","/")
			local t = ParseJsonStr(s)					
			--判断实名认证是否成功		
			local ret = t.ret;				
			local tState = false
			if ret == 0 then
				tState = true
			end		
			if tState == false then 
				UI_Manager:Instance():FastTip(LanguageMgr.GetWord(6008))
			else 
				UI_Manager:Instance():FastTip(LanguageMgr.GetWord(6009))
				self:CloseWin()
				if hall_ui then
					hall_ui:SetAuthShow(false)		
				end	
			end
		end)
	end
end

function certification_ui:CloseWin()
	ui_sound_mgr.PlayCloseClick()
	UI_Manager:Instance():CloseUiForms("certification_ui")
end

function certification_ui:OnRefreshDepth()

  local uiEffect = child(self.gameObject.transform, "certification_panel/Panel_Top/Title/Effect_youxifenxiang")
  if uiEffect and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
  end
end

return certification_ui
 
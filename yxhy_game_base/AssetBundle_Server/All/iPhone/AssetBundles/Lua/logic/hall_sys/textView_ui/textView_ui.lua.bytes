local base = require("logic.framework.ui.uibase.ui_window")
local textView_ui = class("textView_ui",base)

function textView_ui:ctor()
	base.ctor(self) 
	self.index = 1
	self.toggleTbl = {}
end

function textView_ui:OnInit()
	self:InitView()
end

function textView_ui:OnOpen(index)
	self.index = index or 1 
	self:UpdateView(self.index)
end

function textView_ui:PlayOpenAmination()
	--打开动画重写
end

function textView_ui:InitView()
	local Panel_Top = child(self.gameObject.transform,"textview_panel/Panel_Top")
	local Panel_Middle = child(self.gameObject.transform,"textview_panel/Panel_Middle")
	
	local toggle_fwtk = child(Panel_Top,"fwtkBtn")
	if toggle_fwtk ~= nil then
		addClickCallbackSelf(toggle_fwtk.gameObject,self.ToggleClick,self)
		table.insert(self.toggleTbl,toggle_fwtk)
	end
	toggle_yszc = child(Panel_Top,"yszcBtn")
	if toggle_yszc ~= nil then
		addClickCallbackSelf(toggle_yszc.gameObject,self.ToggleClick,self)
		table.insert(self.toggleTbl,toggle_yszc)
	end
	toggle_mzsm = child(Panel_Top,"mzsmBtn")
	if toggle_mzsm ~= nil then
		addClickCallbackSelf(toggle_mzsm.gameObject,self.ToggleClick,self)
		table.insert(self.toggleTbl,toggle_mzsm)
	end
	local btnClose = child(Panel_Top,"backBtn")
	if btnClose ~= nil then
		addClickCallbackSelf(btnClose.gameObject,self.CloseWin,self)
	end
	
	self.lbl_title = componentGet(child(Panel_Middle, "center/title"),"UILabel")
	self.scrollview = componentGet(child(Panel_Middle, "center/ScrollView"),"UIScrollView")
	self.scrollview_text = componentGet(child(Panel_Middle, "center/ScrollView/TextLbl"),"UILabel")
end

function textView_ui:UpdateView(index)
	if not isEmpty(self.toggleTbl) then
		componentGet(self.toggleTbl[index].gameObject,"UIToggle").value = true
		self.toggle_selected = self.toggleTbl[index].gameObject
		self:UpdateScrollText()
	end
end

function textView_ui:ToggleClick(obj)
	ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_button_click")
	self.toggle_selected = obj.gameObject
	self:UpdateScrollText()
end

function textView_ui:UpdateScrollText()
	self.lbl_title.text = componentGet(child(self.toggle_selected.transform, "lbl"),"UILabel").text
	local name = string.sub(self.toggle_selected.name,1,4)	
	local path = data_center.GetAppConfDataTble().appPath.."/config/txt/article/" .. name
	local txt = newNormalObjSync(path,typeof(UnityEngine.TextAsset)) 
    if txt == nil then
        logError(path..".txt 不存在")
        return
    end
	self.scrollview_text.text = tostring(txt)
	self.scrollview:ResetPosition()
end

function textView_ui:CloseWin()
	ui_sound_mgr.PlayCloseClick()
	UI_Manager:Instance():CloseUiForms("textView_ui")
end

return textView_ui
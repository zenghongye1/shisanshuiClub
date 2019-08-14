local base = require("logic.framework.ui.uibase.ui_window")
local UiTest_a = class("UiTest",base)

function UiTest_a:ctor()
	base.ctor(self)
end

function UiTest_a:OnInit()
	base.OnInit(self)
	Trace("OnInit UiTest_a")
	self.m_UiLayer = UILayerEnum.UILayerEnum_Top
	self:InitItem()
end

function UiTest_a:OnOpen(...)

	base.OnOpen(self,...)
	Trace("OnOpen UiTest_a")
end

function UiTest_a:InitItem()
	 self.lab_name=child(self.gameObject.transform,"setting_panel/panel_middle/tex_photo/lab_name") 
    componentGet(self.lab_name.gameObject,"UILabel").text="AAAAAAAA"
	self.btn_close=child(self.gameObject.transform,"setting_panel/btn_close")
    if self.btn_close~=nil then
        addClickCallbackSelf(self.btn_close.gameObject,self.closeWin,self)
    end 
	
	self.btn_change=child(self.gameObject.transform,"setting_panel/panel_middle/toggle/btn_change")
     if self.btn_change ~= nil then      
		addClickCallbackSelf(self.btn_change.gameObject, self.changeclick, self)
	end 
   
end

function UiTest_a:closeWin()
	UI_Manager:Instance():CloseUiForms("UiTest_a")
	
end

function UiTest_a:changeclick()
	UI_Manager:Instance():ShowUiForms("UiTest_b",UiCloseType.UiCloseType_Navigation,function() 
			Trace("Close uitest_a")
		end)
	
end

return UiTest_a
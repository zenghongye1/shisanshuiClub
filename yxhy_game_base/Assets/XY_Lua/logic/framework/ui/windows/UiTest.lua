--[[
	测试代码，后面会删除
	]]
local base = require("logic.framework.ui.uibase.ui_window")
local UiTest = class("UiTest",base)

function UiTest:ctor()
	base.ctor(self)
	
end

function UiTest:Update()
	
end

function UiTest:OnInit()
	base.OnInit(self)
	Trace("OnInit UiTest")
	self:InitItem()
end

function UiTest:OnOpen(...)
	base.OnOpen(self,...)
	Trace("OnOpen UiTest")
end

function UiTest:InitItem()
	 self.lab_name=child(self.gameObject.transform,"setting_panel/panel_middle/tex_photo/lab_name") 
    componentGet(self.lab_name.gameObject,"UILabel").text="00000000000"
	self.btn_close=child(self.gameObject.transform,"setting_panel/btn_close")
    if self.btn_close~=nil then
        addClickCallbackSelf(self.btn_close.gameObject,self.closeWin,self)
    end 
	self.btn_change=child(self.gameObject.transform,"setting_panel/panel_middle/toggle/btn_change")
     if self.btn_change ~= nil then      
		addClickCallbackSelf(self.btn_change.gameObject, self.changeclick, self)
	end
	self:InitTab()
end

function UiTest:InitTab()
	self.tabRoot = child(self.gameObject.transform,"setting_panel/TabRoot")
	self.tab = require("logic.framework.ui.ui_tab"):create("TabTitle","TabWindows","Tab_a","Set_12","tishi_di")
	self.tab.gameObject = self.tabRoot.gameObject
	self.tab:Open(self.tabRoot.gameObject)
	self.tab.onSwitchCallBack = function(Object)
		Trace("页面切换完成："..Object)
	end
end

function UiTest:closeWin()
	
	UI_Manager:Instance():CloseUiForms("UiTest")
end
function UiTest:changeclick()
	UI_Manager:Instance():ShowUiForms("UiTest_a",UiCloseType.UiCloseType_Navigation,function() 
		Trace("Close uitest_a")
	end)
	
	
end

--如果想自定义打开动画，就重写这个方法，如果用默认打开动画就不需要实现这个方法
--[[function UiTest:PlayOpenAmination()
	
	base.PlayOpenAmination(self)
end--]]

return UiTest
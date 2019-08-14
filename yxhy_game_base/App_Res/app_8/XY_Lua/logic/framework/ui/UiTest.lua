local UiTest = class("UiTest",require("logic.framework.ui.ui_window"))

function UiTest:ctor()
end

function UiTest:OnInit()
	self.super:OnInit()
	Trace("UiTest OnInit")
end

function UiTest:OnOpen(...)
	self.super:OnOpen(...)
	Trace("Open UiTest")
end

return UiTest
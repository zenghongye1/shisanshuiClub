require "logic/framework/ui/ui_enum"
ui_manager_instace = nil
local ui_manager = class("ui_manager")

function ui_manager:ctor()
	self.m_CacheAllUiForms = {}
	self.m_NavigationStackUiForms = require("logic.framework.ui.stack"):create()
	self.m_UiRoot = UnityEngine.GameObject.Find("uiroot_xy/Camera")
end

function ui_manager:Instance()
	if ui_manager_instace == nil then
		ui_manager_instace = require("logic.framework.ui.ui_manager"):create()
	end
	return ui_manager_instace
end

function ui_manager:ShowUiForms(UiFormName)
	local Ui = self.m_CacheAllUiForms[ui_enum[UiFormName]]
	if Ui == nil then
		Ui = self:LoadFormsToCache(UiFormName)
	end
	Ui:Open()
	
end

function ui_manager:LoadFormsToCache(UiFormName)
	if ui_enum[UiFormName] == nil then
		return
	end
	return self:LoadUIForm(UiFormName)
	
end

function ui_manager:LoadUIForm(UiFormName)
	local path = ui_enum[UiFormName]
	local Ui = newNormalUI(path)
	Ui.gameObject.transform.parent = self.m_UiRoot.gameObject.transform
	local UiBaseScript = componentGet(Ui.transform,typeof(UI_Base))
	local luaFile = UiBaseScript.fullLuaFileName
	local luaFileObj = require(luaFile):create()
	luaFileObj.gameObject = Ui
	table.insert(self.m_CacheAllUiForms,luaFileObj)
	return luaFileObj
	
	
end

return ui_manager
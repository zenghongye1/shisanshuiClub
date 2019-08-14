local base = require "logic.framework.ui.uibase.ui_view_base"
local ui_load_view_base = class("ui_load_view_base", base)


function ui_load_view_base:ctor()
	base.ctor(self)
	self:InitPrefabPath()
end

function ui_load_view_base:InitPrefabPath()
	self.prefabPath = ""
end

function ui_load_view_base:Show(...)
	if IsNil(self.gameObject) then
		self:Load()
	end
	self:SetActive(true)
	self:Refresh(...)
end

function ui_load_view_base:Hide()
	if IsNil(self.gameObject) then
		return
	end
	self:SetActive(false)
end

function ui_load_view_base:Load()
	local go = newNormalObjSync(self.prefabPath, typeof(GameObject))
	if go == nil then 
		return 
	end
	self:SetGo(newobject(go))
	self:SetActive(false)
	self:OnLoaded()
end

function ui_load_view_base:SetParent(parentTr)
	self.transform:SetParent(parentTr, false)
end


function ui_load_view_base:OnLoaded()
end

function ui_load_view_base:Refresh(...)
end


return ui_load_view_base
--[[
	这个类用于UI里面的子UI处理。 子UI尽可能用这种方式，可以把子UI逻辑跟主UI逻辑解耦出来
]]
local ui_childwindow = class("ui_childwindow")

function ui_childwindow:ctor(...)
	self.parent = nil
	self.UiFormName = nil
	self.gameObject = nil
	self.args = nil
	self.openAnim = nil
	self.AnimDelay = 0
	self.inited = false
	self.m_OnClose = nil
end

function ui_childwindow:Init()
	if self.inited == true then return end
	self:OnInit()
	self.inited = true
end

function ui_childwindow:Open(gameObject,...)
	if gameObject ~= nil then
		self.gameObject = gameObject
	end
	if {...} ~= nil then
		self.args = {...}
	end
	self:Init()
	self.gameObject:SetActive(true)
	self:OnOpen(...)
	self:PlayAnimation()
end

function ui_childwindow:OpenByParent(parent)
end

function ui_childwindow:PlayAnimation()

end

function ui_childwindow:OnInit()
	
end

function ui_childwindow:OnOpen()
	
end

function ui_childwindow:OnClose()
	
end

function ui_childwindow:Close()
	if self == nil or self.gameObject == nil then
		logError("this childwindow is alrady destory")
	end
	if self.m_OnClose ~= nil then
		self.m_OnClose()
		self.m_OnClose = nil
	end
	self:OnClose()
	self.gameObject:SetActive(false)
end

return ui_childwindow
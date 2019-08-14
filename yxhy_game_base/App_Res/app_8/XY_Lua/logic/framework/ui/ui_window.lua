local ui_window = class("ui_window")

function ui_window:ctor()
	self.args = nil
	self.gameObject = nil
	self.m_OpenAnim = nil
	self.m_CloseAnim = nil
	self.m_OnBack = nil
	self.m_inited = false
	self.m_OnClose = nil
	
end

function ui_window:Init()
	if self.m_inited == true then return end
	self.m_inited = true
	self:OnInit()
end

function ui_window:OnInit()
	Trace("super_window")
end

function ui_window:Open(OnClose,...)
	self.args = {...}
	self:Init()
	self:OnOpen({...})
	self:PlayeOpenAmination()
	if OnClose ~= nil then
		self.m_OnClose = OnClose
	end
end

function ui_window:OnOpen(...)
	
end

function ui_window:PlayeOpenAmination()
	
end

return ui_window
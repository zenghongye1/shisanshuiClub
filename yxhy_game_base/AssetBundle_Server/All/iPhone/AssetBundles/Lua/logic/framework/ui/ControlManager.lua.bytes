require "logic/framework/ui/ui_enum"
local ControlManager = class("ControlManager")

function ControlManager:ctor()
	self.controlMap = {}
	self:LoadControl()
	UpdateBeat:Add(function() self:Update() end)
end

function ControlManager:LoadControl()
	for i,v in pairs(ui_control_enum) do
		local luaFileObj = require(v):create()
		self.controlMap[luaFileObj.__cname] = luaFileObj
	end	
end

function ControlManager:Init()
	for k,ctrl in pairs(self.controlMap) do
		if ctrl.Init and "function" == type(ctrl.Init) then
			ctrl:Init()
		end
	end
end

function ControlManager:Clear()
	for k, ctrl in pairs(self.controlMap) do
		if ctrl.Clear and "function" == type(ctrl.Clear) then
			ctrl:Clear()
		end
	end
	self.modelMap = {}
end

function ControlManager:GetCtrl(CtrlName)
	if self.controlMap[CtrlName] then
		return self.controlMap[CtrlName]
	end
end


function ControlManager:Update()
	for k, v in pairs(self.controlMap) do
		v:Update()
	end
end

return ControlManager
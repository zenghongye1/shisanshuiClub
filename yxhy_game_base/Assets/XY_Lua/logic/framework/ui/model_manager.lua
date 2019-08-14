require "logic/framework/ui/ui_enum"
local model_manager = class("model_manager")

function model_manager:ctor()
	self.modelMap = {}
	self:LoadModel()
end

function model_manager:GetModel(ModelName)
	if self.modelMap[ModelName] then
		return self.modelMap[ModelName]
	end
end

function model_manager:LoadModel()
	for i,v in pairs(ui_model_enum) do
		local luaFileObj = require(v):create()
		self.modelMap[luaFileObj.__cname] = luaFileObj
	end	
end

function model_manager:Init()
	for k,model in pairs(self.modelMap) do
		if model.Init and "function" == type(model.Init) then
			model:Init()
		end
	end
end

function model_manager:Clear()
	for k, model in pairs(self.modelMap) do
		if model.Clear and "function" == type(model.Clear) then
			model:Clear()
		end
	end
	self.modelMap = {}
end

return model_manager
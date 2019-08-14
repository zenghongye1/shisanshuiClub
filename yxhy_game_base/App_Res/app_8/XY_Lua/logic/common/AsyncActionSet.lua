--[[--
 * @Description: 目前只负责ui-scene绑定关系
 * @Author:      shine
 * @FileName:    AsyncActionSet.lua
 * @DateTime:    2017-05-16 14:20:39 
 ]]


AsyncActionSet = 
{
	prefabs = {},
	finishDict = {},
}

AsyncActionSet.__index = AsyncActionSet

function AsyncActionSet.New()
	local self = {}
	setmetatable(self, AsyncActionSet)
	self.prefabs = {}
	self.param1 = nil
	self.param2 = nil
	self.param3 = nil
	self.param4 = nil
	self.finishDict = {}
	self.func = nil
	return self
end

function AsyncActionSet:AddPrefabs(prefabs, func, param1, param2, param3, param4)
	self.prefabs = prefabs
	self.param1 = param1
	self.param2 = param2
	self.param3 = param3
	self.param4 = param4
	for k, v in ipairs(self.prefabs) do
		self.finishDict[k] = -1
	end

	self.func = func
end

function AsyncActionSet:ModifyFinishFlag(path, obj)
	local idx = -1
	for k, v in ipairs(self.prefabs) do
		if (v.strPrefab == path) then
			idx = k
			break
		end
	end

	if (idx ~= -1) then
		self.finishDict[idx] = obj
		self:Check()
	end	
end

function AsyncActionSet:Check()
	local ret = true
	local retObjs = {}
	for k, v in ipairs(self.finishDict) do
		if v == -1 then
			ret = false
			break
		end
		table.insert(retObjs, v)
	end

	if (ret and self.func ~= nil) then
		self.func(retObjs, self.param1, self.param2, self.param3, self.param4)
	end
end


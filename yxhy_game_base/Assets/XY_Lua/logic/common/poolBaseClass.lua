--[[--
 * @Description: GameObject 对象池基类  
 ]]
local poolBaseClass = class("poolBaseClass")

function poolBaseClass:ctor(newFunc,resetFunc,recycleFunc,maxCount)
	self.newFunc = newFunc
	self.resetFunc = resetFunc
	self.recycleFunc = recycleFunc
	self.pool = {}
	self.maxCount = maxCount or 9999
end

function poolBaseClass:Get()
	if 0 == #self.pool then
		return self.newFunc()
	else
		while(#self.pool > 0)
		do
			if not IsNil(self.pool[#self.pool]) then
				local obj = table.remove(self.pool)
				if self.resetFunc then
					self.resetFunc(obj)
				end
				return obj
			else
				table.remove(self.pool)
			end
		end
		return self:Get()
	end
end

function poolBaseClass:Recycle(obj)
	if not IsNil(obj) then
		if #self.pool < self.maxCount then
			if self.recycleFunc then
				self.recycleFunc(obj)
			end
			table.insert(self.pool,obj)
		else
			GameObject.Destroy(obj)
		end
	end
end

return poolBaseClass
local comp_mjDirection = class("comp_mjDirection")

function comp_mjDirection:ctor()
	self.tr = nil
	self.lightDirTr = nil
	-- self.darkDirGoList = {}
	-- self.lightDirGoList = {}
	self.lightItemGoList = {}

	-- 1  : 东南西北
	-- 2  ：南西北东
	-- 3  ：西北东南
	-- 4  ：北东南西
	self.direction = 1
	self.curLightItemGo = nil
	self.offset = 0
end

function comp_mjDirection:Init(tr )
	self.tr = tr
	-- for i = 1, 4 do
	-- 	local dir = child(tr, "dark_dir/direction_0" .. i)
	-- 	dir.gameObject:SetActive(false)
	-- 	table.insert(self.darkDirGoList , dir.gameObject)
	-- end

	-- for i = 1, 4 do
	-- 	local dir = child(tr, "light_dir/direction_" .. i)
	-- 	dir.gameObject:SetActive(false)
	-- 	table.insert(self.lightDirGoList , dir.gameObject)
	-- end

	self.lightDirTr = child(tr, "light_dir/direction_1")
end

function comp_mjDirection:InitLightItems()
	for i = 1, 4 do
		local go = child(self.lightDirTr, "direction_0" .. i).gameObject
		go:SetActive(false)
		self.lightItemGoList[i] = go
	end
end

function comp_mjDirection:ShowObjByDirection(direction)
	self.tr.localEulerAngles = Vector3(0,(direction-1)*90,0)
	-- for i = 1, 4 do
	-- 	self.darkDirGoList[i]:SetActive(direction == i)
	-- 	self.lightDirGoList[i]:SetActive(direction == i)
	-- end
end

function comp_mjDirection:SetDirection(logicSeat)
	self.direction = logicSeat
	self.offset = logicSeat - 1
	self:SetLightItem(-1)
	self:ShowObjByDirection(self.direction)
	self:InitLightItems()
end

function comp_mjDirection:SetLightItem(index)
	if index < 5 and index > 0 then
		index = index + self.offset
		if index > 4 then
			index = index - 4
		end
	end
	for i = 1, #self.lightItemGoList do
		self.lightItemGoList[i]:SetActive(i == index)
	end
end

return comp_mjDirection

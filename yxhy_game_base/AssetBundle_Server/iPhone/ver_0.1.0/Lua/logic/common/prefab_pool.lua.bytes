--[[--
 * @Description: 文本tips，持续一段时间后自动关闭
 * @Author:      shine
 * @FileName:    prefab_pool.lua
 * @DateTime:    2015-08-06
 ]]

local prefab_pools_container = nil
local m_coroutine = nil
local m_initPoolFinish = false
local m_waitInitPoolFinishCoroutine = nil

prefab_pool = 
{
	name = "prefab_pool",
	spawned   = {},   --使用节点列表
	despawned = {},   --空闲节点列表
	spawnNewCallbackTable = {},		--存储回调函数
	tempPrefabCountTab = {},	--准备建立的对象个数
	prefabItemCount = 0,	--对象池中对象个数，默认值为0
	maxItemCount = 50,  --对象池的最大个数，默认最大值
	IsFIFOLoop = false,      --是否队列循环，设置为true；队列满后，则取第一个使用
	curTotalCount = 0,   --当前总数
	prefabName = nil,    --prefab名
	prefabObject = nil,  --prefab对象
	parentObj = nil,   --父节点	
	existPool = false,	--池是否存在，默认不存在
}

prefab_pool.__index = prefab_pool

function prefab_pool.New()
	local self = {}
	setmetatable(self, prefab_pool)

	self.name = "prefab_pool"
	self.spawned   = {}  
	self.despawned = {} 
	self.spawnNewCallbackTable = {}
	self.tempPrefabCountTab = {}
	self.prefabItemCount = 0
	self.maxItemCount = 50  
	self.IsFIFOLoop = false     
	self.curTotalCount = 0   
	self.prefabName = nil    
	self.prefabObject = nil  
	self.parentObj = nil  
	self.existPool = false

	return self
end

--[[--
 * @Description: --初始化一个池
 * @parm:参数1：prefab名 参数2：要创建的预设数 参数3：池大小 参数4：是否队列
 ]]
function prefab_pool:InitPool(pName, prefabCount, maxCount, FIFO)
	--maxCount = 1
	if pName == nil then
		return false
	end

	if self.prefabObject ~= nil then  --对象不为空，重入
		self:DestroyPool()
	end

	self.prefabName = pName
	if prefabCount ~= nil then
		table.insert(self.tempPrefabCountTab, prefabCount)
	else
		table.insert(self.tempPrefabCountTab, 5)	--默认创建5个对象
	end
	
	if maxCount ~= nil and self.maxItemCount < maxCount then
		self.maxItemCount = maxCount
	end

	if FIFO ~= nil then
		self.IsFIFOLoop = FIFO
	end

	if IsNil(prefab_pools_container) then
		prefab_pools_container = GameObject("prefab_pools_container")
		--GameObject.DontDestroyOnLoad(prefab_pools_container)
	end

	if IsNil(self.parentObj) then
		self.parentObj = GameObject(self.prefabName.." pool")
		self.parentObj.transform.parent = prefab_pools_container.transform
	end

	if self.existPool == false then
		self:InitPoolObject()
	end
end

--[[--
 * @Description: 初始创建对象池gameobject
 ]]
function prefab_pool:InitPoolObject()
	if self.prefabName == nil then
		return
	end

	if self.prefabObject == nil then
		newNormalObjAsync(self.prefabName, typeof(GameObject), function(abi) self:LoadResAsyncCallback(abi) end)
		self.existPool = true
	end
end

function prefab_pool:LoadResAsyncCallback(abi)
	local prefabCount = table.remove(self.tempPrefabCountTab, 1)
	if prefabCount ~= nil then
		if (self.prefabItemCount + prefabCount < self.maxItemCount) then
			self.prefabItemCount = self.prefabItemCount + prefabCount
		else
			prefabCount = self.maxItemCount - self.prefabItemCount
			self.prefabItemCount = self.maxItemCount
		end
	end

	self.prefabObject = abi.mainObject

	if self.prefabObject == nil or self.curTotalCount >= self.maxItemCount then
		return
	end

	m_coroutine = coroutine.start(function ()
		for i=1,prefabCount do
			local item = self:InitCreateObj(self.prefabName)
			if item ~= nil then
				item:SetActive(false)
				table.insert(self.despawned, item)
			end
		end

		for k,v in pairs(self.spawnNewCallbackTable) do
			local inst = table.remove(self.spawned, k)
			self:Spawn(v)
		end
    end)
end

--[[--
 * @Description: 销毁内存池
 ]]
function prefab_pool:DestroyPool()
	for k,v in pairs(self.spawned) do
		if v ~= nil then
			destroy(v)
		end
	end
	for k1,v1 in pairs(self.despawned) do
		if v1 ~= nil then
			destroy(v1)
		end
	end

	if self.parentObj ~= nil then
		destroy(self.parentObj)
		self.parentObj = nil
	end

	if self.prefabName ~= nil then
		unloadobj(self.prefabName, typeof(GameObject))
	end

	self.spawned = {}
	self.despawned = {}
	self.spawnNewCallbackTable = {}
	self.tempPrefabCountTab = {}
	self.prefabItemCount = 0
	self.curTotalCount = 0
	self.maxItemCount = 0
	self.IsFIFOLoop = false
	self.prefabName = nil
	self.prefabObject = nil
	self.parentObj = nil  
	self.existPool = false

	if m_coroutine ~= nil then
		coroutine.stop(m_coroutine)
	end
end

--[[--
 * @Description: 获取一个对象
 ]]
function prefab_pool:Spawn(actionSet)
	local inst = nil
	if self.IsFIFOLoop and table.getn(self.spawned) >= self.maxItemCount then
		self:Despawn(self.spawned[1])
	end

	if table.getn(self.despawned) <= 0 then
		self:SpawnNew(self.prefabName, actionSet)
	elseif self.despawned[1] ~= nil then
		inst = table.remove(self.despawned, 1)
		table.insert(self.spawned, inst)
		actionSet:ModifyFinishFlag(self.prefabName, inst)
	else
		Fatal("prefab_pool:Spawn(), self.despawned[1] == nil, self.prefabName: "..self.prefabName)
	end
end

--[[--
 * @Description: 回收对象
 ]]
function prefab_pool:Despawn(go,notHud)
	for k,v in pairs(self.spawned) do
		if v == go then
			local inst = table.remove(self.spawned, k)
			if self.curTotalCount > self.maxItemCount then
				GameObject.Destroy(inst)
				self.curTotalCount = self.curTotalCount - 1
			else
				if not(notHud) then
					inst.transform.parent = self.parentObj.transform
				end
				table.insert(self.despawned, inst)
			end
			return true
		end
	end
	return false
end

--[[--
 * @Description: 创建一个新对象
 ]]
function prefab_pool:SpawnNew(strPrefab, actionSet)
	if strPrefab == nil or (IsNil(self.prefabObject)) then
		local exist = false
		if #(self.spawnNewCallbackTable) > 0 then
			for k, v in ipairs(self.spawnNewCallbackTable) do
				--if table.getn(v.prefabs) ~= table.getn(actionSet.prefabs) then
				--	exist = false
				--else
					for x, y in ipairs(v.prefabs) do
						local strPrefab1 = y.strPrefab
						local strPrefab2 = actionSet.prefabs[x].strPrefab

						if y.guid ~= nil then
							strPrefab1 = strPrefab1..(y.guid)
						end

						if actionSet.prefabs[x].guid ~= nil then
							strPrefab2 = strPrefab2..(actionSet.prefabs[x].guid)
						end

						if strPrefab1 == strPrefab2 then
							exist = true
							break
						end
					end
				--end
			end
		else
			exist = false
		end

		if exist == false then
			table.insert(self.spawnNewCallbackTable, actionSet)
		end
	else
		self.curTotalCount = self.curTotalCount + 1
		local newItem = newobject(self.prefabObject)
		if newItem == nil then
			Fatal(" prefab_pool:SpawnNew, newItem is nil!")
			return
		end
		local name = string.format("%s%03d", newItem.name, self.curTotalCount)
		newItem.name = name

		newItem.transform.parent = self.parentObj.transform
		table.insert(self.spawned, newItem)

		actionSet:ModifyFinishFlag(self.prefabName, newItem)
	end
end

--[[--
 * @Description: 在对象池创建好后，创建初始化时该创建的新对象
 ]]
function prefab_pool:InitCreateObj(strPrefab)
	if strPrefab == nil or (IsNil(self.prefabObject)) then
		Fatal("对象池没有初始化")
		return nil
	end

	self.curTotalCount = self.curTotalCount + 1
	local newItem = newobject(self.prefabObject)
	
	local name = string.format("%s%03d", newItem.name, self.curTotalCount)
	newItem.name = name
	
	if not IsNil(self.parentObj) and not IsNil(newItem.transform) then
		newItem.transform.parent = self.parentObj.transform
	end
	return newItem
end

logicLuaObjMgr.registerLuaClass("prefab_pool",prefab_pool.New)
--[[--
 * @Description: gameobject 多对象线程管理
 * @Author:      shine
 * @FileName:    pool_manager.lua
 * @DateTime:    2015-08-06
 ]]

require "logic/common/prefab_pool"
require "logic/common/AsyncActionSet"

pool_manager = {} 
local this = pool_manager
-------------------------
local spawn_pools = {}

--[[--
 * @Description: 创建一个对象池  
 * @param:        参数1：prefab作为key ,  
 				  参数2：在对象池中创建的对象数
 				  参数3：对象池的大小
 				  参数4：元素满后，是否自动淘汰第一个
 * @return:      prefab对象
 ]]
function this.CreatePrefabPool(prefabName, prefabCount, maxCount, fifo)
	if spawn_pools[prefabName] == nil then
		spawn_pools[prefabName] = prefab_pool.New()
	end

	if spawn_pools[prefabName] == nil then
		Fatal("CreatePrefabPool fail!!!")
		return
	end

	spawn_pools[prefabName]:InitPool(prefabName, prefabCount, maxCount, fifo)

	return spawn_pools[prefabName]
end

function this.Clear()
	spawn_pools = {}
end

--[[--
 * @Description: 销毁内存池  
 * @param:       prefab名
 ]]
function this.DestroyPrefabPool(prefabName)
	if spawn_pools[prefabName] == nil then 
		return
	end

	spawn_pools[prefabName]:DestroyPool()
	spawn_pools[prefabName] = nil
end

function this.NewSpawnTable(strPrefab, guid)
	local retValue = {}
	retValue.strPrefab = strPrefab
	retValue.guid = guid
	return retValue
end

--[[--
 * @Description: 获取prefab内存对象  
 * @param:prefabsTable 	table，存储要加载的预设名
 * @param:func 		回调函数，除了回调中的objs，最多可带4个参数
 * @param:param1 	回调函数中的第2个参数值，第一个是objs
 * @param:param2 	回调函数中的第3个参数值，第一个是objs
 * @param:param3 	回调函数中的第4个参数值，第一个是objs
 * @param:param4 	回调函数中的第5个参数值，第一个是objs
 ]]
function this.Spawn(prefabsTable, func, param1, param2, param3, param4)

	local actionSet = AsyncActionSet.New()
	actionSet:AddPrefabs(prefabsTable, func, param1, param2, param3, param4)

	for k,v in ipairs(prefabsTable) do
		if spawn_pools[v.strPrefab] == nil then 
			spawn_pools[v.strPrefab] = this.CreatePrefabPool(v.strPrefab)
		end

		if spawn_pools[v.strPrefab] == nil then
			Trace("if spawn_pools[strPrefab] == nil then")
		else
			spawn_pools[v.strPrefab]:Spawn(actionSet)
		end
	end
end

--[[--
 * @Description: 回收内存池对象  
 * @param:       参数1：所在prefab,填nil则全局遍历,  参数2：回收的对象,参数3：回收时是否挂到指定的根节点下
 ]]
function this.Despawn(strPrefab, go, notHand)
	if strPrefab ~= nil then
		if spawn_pools[strPrefab] ~= nil then
			spawn_pools[strPrefab]:Despawn(go,notHand)
		end	
		return 
	end

	for k,v in pairs(spawn_pools) do
		if v:Despawn(go,notHand) == true then
			return
		end
	end
end
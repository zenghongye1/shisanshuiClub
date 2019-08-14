--//////////////////////////日志控制相关 start ////////////////////////

TIME_NAME = 
{
	SECOND = 1,
	MINUTE = 2,
	HOUR   = 3,
	DAY    = 4,
}

LOG = 
{
    login= 6,          -- 登录
    hall = 8,          -- 大厅
}

-- 模块的前缀
local logFilterDict = 
{
	[LOG.login] 		= "[login]",
	[LOG.hall] 			= "[hall]",
}

BestLog = {}
BestLog.filterCode = nil -- 过滤码默认为空

IS_URL_TEST = false    --是否测试修改URL

local setmetatableindex_
setmetatableindex_ = function(t, index)
    if type(t) == "userdata" then
        local peer = tolua.getpeer(t)
        if not peer then
            peer = {}
            tolua.setpeer(t, peer)
        end
        setmetatableindex_(peer, index)
    else
        local mt = getmetatable(t)
        if not mt then mt = {} end
        if not mt.__index then
            mt.__index = index
            setmetatable(t, mt)
        elseif mt.__index ~= index then
            setmetatableindex_(mt, index)
        end
    end
end
setmetatableindex = setmetatableindex_


function class(classname, ...)
    local cls = {__cname = classname}

    local supers = {...}
    for _, super in ipairs(supers) do
        local superType = type(super)
        assert(superType == "nil" or superType == "table" or superType == "function",
            string.format("class() - create class \"%s\" with invalid super class type \"%s\"",
                classname, superType))

        if superType == "function" then
            assert(cls.__create == nil,
                string.format("class() - create class \"%s\" with more than one creating function",
                    classname));
            -- if super is function, set it to __create
            cls.__create = super
        elseif superType == "table" then
            if super[".isclass"] then
                -- super is native class
                assert(cls.__create == nil,
                    string.format("class() - create class \"%s\" with more than one creating function or native class",
                        classname));
                cls.__create = function() return super:create() end
            else
                -- super is pure lua class
                cls.__supers = cls.__supers or {}
                cls.__supers[#cls.__supers + 1] = super
                if not cls.super then
                    -- set first super pure lua class as class.super
                    cls.super = super
                end
            end
        else
            error(string.format("class() - create class \"%s\" with invalid super type",
                        classname), 0)
        end
    end

    cls.__index = cls
    if not cls.__supers or #cls.__supers == 1 then
        setmetatable(cls, {__index = cls.super})
    else
        setmetatable(cls, {__index = function(_, key)
            local supers = cls.__supers
            for i = 1, #supers do
                local super = supers[i]
                if super[key] then return super[key] end
            end
        end})
    end

    if not cls.ctor then
        -- add default constructor
        cls.ctor = function() end
    end
    cls.new = function(...)
        local instance
        if cls.__create then
            instance = cls.__create(...)
        else
            instance = {}
        end
        setmetatableindex(instance, cls)
        instance.class = cls
        instance:ctor(...)
        return instance
    end
    cls.create = function(_, ...)
        return cls.new(...)
    end

    return cls
end

local prefixLog = ""
local function MakePrefixStr(filterCode)
	if (filterCode ~= nil and logFilterDict[filterCode] ~= nil) then
		prefixLog = logFilterDict[filterCode]			
	else
		prefixLog = ""
	end
end

--跟踪日志--
function Trace(str, filterCode)
	if (BestLog.filterCode == filterCode or BestLog.filterCode == nil) then
		MakePrefixStr(filterCode)
		local strValue = str
		if (type(str) ~= "string") then
			strValue = tostring(str)
		end
		print(prefixLog..strValue);  	
    end
end

function DebugLog(func, str, filterCode)
	if (DEBUG_TRACE == nil or DEBUG_TRACE == false) then
		return
	end
	func(str, filterCode)
end

--调试日志--
function Debug(str, filterCode)
	if (BestLog.filterCode == filterCode or BestLog.filterCode == nil) then
		MakePrefixStr(filterCode)
		local strValue = str
		if (type(str) ~= "string") then
			strValue = tostring(str)
		end
		print(prefixLog..strValue);   	
    end
end

--服务日志--
function Info(str, filterCode)
	if (BestLog.filterCode == filterCode or BestLog.filterCode == nil) then
		MakePrefixStr(filterCode)
		local strValue = str
		if (type(str) ~= "string") then
			strValue = tostring(str)
		end
		print(prefixLog..strValue);   	
    end
end

--警告日志--
function warning(str, filterCode) 
	if (BestLog.filterCode == filterCode or BestLog.filterCode == nil) then
		MakePrefixStr(filterCode)
		local strValue = str
		if (type(str) ~= "string") then
			strValue = tostring(str)
		end
		Debugger.LogWarning(prefixLog..strValue)
	end
end

--错误日志--
function Fatal(str) 
	Debugger.LogError(str)
end

-- 带堆栈的log
function logNormal(...)
	local tab = {}
	for k, v in pairs({...}) do
		table.insert(tab, tostring(v))
	end
	local str = table.concat(tab, "\t")
	local output = str ..'\n'.. debug.traceback()..'\n'
	Debugger.Log(output)
end

-- 带堆栈的log
function logWarning(value)
	local str = tostring(value)
	local output = str ..'\n'.. debug.traceback()..'\n'
	Debugger.LogWarning(output)
end


-- 带堆栈的log
function logError(...)
	local tab = {}
	for k, v in pairs({...}) do
		table.insert(tab, tostring(v))
	end
	local str = table.concat(tab, "\t")
	local output = str ..'\n'.. debug.traceback()..'\n'
	Debugger.LogError(output)
end

--设置日志等级--
--[[function SetLoggerLevel(level)
	Util.SetLogLevel(level);
end]]

--设置日志打印开关--
--[[function SetWriteLoggerToggle(toggle)
	Util.SetLogLevel(toggle);
end]]


--//////////////////////////日志控制相关 end ////////////////////////

--查找对象--
function find(str)
	return GameObject.Find(str);
end

function destroy(obj)
	if (not IsNil(obj)) then
		GameObject.Destroy(obj);
	end
end

function newobject(prefab)
	if prefab ~= nil then
		return GameObject.Instantiate(prefab);
	else
		return nil
	end
end

local resMgr = nil
--同步加载资源对象 ----Start----------->
--[[--
 * @Description: 通过名字获取子控件  
 * @param:       assetType----> Normal = 0,    TempResident = 1,    Resident = 2,    buildin = 3,
 * @return:      返回子控件Transform
 ]]
function newNormalObjSync(path, _type, assetType)
	if resMgr == nil then
		resMgr = GameKernel.GetResourceMgr()
	end

	if assetType == nil then
		assetType = 0
	end
		
	local abp = AssetBundleParams.New(path, _type, assetType)
	local retGo = resMgr:LoadNormalObjSync(abp)

	return retGo
end

function newSceneResidentMemoryObjSync(path, type)
	if resMgr == nil then
		resMgr = GameKernel.GetResourceMgr()
	end
	local abp = AssetBundleParams.New(path, type, 0)
	local retGo = resMgr:LoadSceneResidentMemoryObjSync(abp)

	return retGo
end

function newResidentMemoryObjSync(path, type)
	if resMgr == nil then
		resMgr = GameKernel.GetResourceMgr()
	end
	local abp = AssetBundleParams.New(path, type, 0)
	local retGo = resMgr:LoadResidentMemoryObjSync(abp)

	return retGo
end
--同步加载资源对象 ----End----------->

--异步加载资源对象 ----Start----------->
function newNormalObjAsync(path, type, loadCallback, isSort)
	if resMgr == nil then
		resMgr = GameKernel.GetResourceMgr()
	end
	local abp = AssetBundleParams.New(path, type, 0)
	if isSort ~= nil then
		abp.IsSort = isSort
	end
	resMgr:LoadNormalObjAsync(abp, Best.AssetBundleInfo.LoadAssetCompleteHandler(loadCallback))
end

function newSceneResidentMemoryObjAsync(path, type, loadCallback, isSort)
	if resMgr == nil then
		resMgr = GameKernel.GetResourceMgr()
	end
	local abp = AssetBundleParams.New(path, type,0)
	if isSort ~= nil then
		abp.IsSort = isSort
	end
	resMgr:LoadSceneResidentMemoryObjAsync(abp, Best.AssetBundleInfo.LoadAssetCompleteHandler(loadCallback))
end

function newResidentMemoryObjAsync(path, type, loadCallback, isSort)
	if resMgr == nil then
		resMgr = GameKernel.GetResourceMgr()
	end
	local abp = AssetBundleParams.New(path, type,0)
	if isSort ~= nil then
		abp.IsSort = isSort
	end
	resMgr:LoadResidentMemoryObjAsync(abp, Best.AssetBundleInfo.LoadAssetCompleteHandler(loadCallback))
end
--异步加载资源对象 ----End----------->

--同步加载UI预设 ----Start----------->
function newNormalUI(path, parent)
    local prefab = newNormalObjSync(path, typeof(GameObject))
	local obj = newNormalUIprefab(prefab, parent)	
	if obj ~= nil then
		local ctrl = obj:AddComponent(typeof(XYHY.LuaDestroyBundle))
		ctrl.BundleName = path
		ctrl.ResType = typeof(GameObject)
	end
	
	return obj
end

function newSceneResidentMemoryUI(path, parent)
    local prefab = newSceneResidentMemoryObjSync(path, typeof(GameObject))
	local obj = newNormalUIprefab(prefab, parent)
	if obj ~= nil then
		local ctrl = obj:AddComponent(typeof(XYHY.LuaDestroyBundle))
		ctrl.BundleName = path
		ctrl.ResType = typeof(GameObject)
	end
	
	return obj
end

function newResidentMemoryUI(path, parent)
    local prefab = newResidentMemoryObjSync(path, typeof(GameObject))
	local obj = newNormalUIprefab(prefab, parent)
	if obj ~= nil then
		local ctrl = obj:AddComponent(typeof(XYHY.LuaDestroyBundle))
		ctrl.BundleName = path
		ctrl.ResType = typeof(GameObject)
	end
	
	return obj
end
--同步加载UI预设 ----End----------->

--异步加载UI预设 ----Start----------->
function newNormalUIAsync(path, func, isSort)
	UISys.Instance:DisableUICamera()
	newNormalObjAsync(path, typeof(GameObject), func, isSort)
end

function newSceneResidentMemoryUIAsync(path, func, isSort)
	UISys.Instance:DisableUICamera()
	newSceneResidentMemoryObjAsync(path, typeof(GameObject), func, isSort)
end

function newResidentMemoryUIAsync(path, func, isSort)
	UISys.Instance:DisableUICamera()
	newResidentMemoryObjAsync(path, typeof(GameObject), func, isSort)
end

function newUIAsyncCallback(abi)
	local go = newNormalUIprefab(abi.mainObject)
	local ctrl = go:AddComponent(typeof(Best.LuaDestroyBundle))
	ctrl.BundleName = abi.GoPath
	ctrl.ResType = abi.GoType
	UISys.Instance:EnableUICamera()

	return go
end
--异步加载UI预设 ----End----------->

function  newNormalUIprefab(prefab, parent)
	local obj = newobject(prefab)	
	
	--parent, default ui root
	local ui_root_trans = parent
	if ui_root_trans == nil then
		ui_root_trans = UISys.Instance.transform
	end
	
	if obj ~= nil and obj.transform.parent ~= ui_root_trans then
		obj.transform.parent = ui_root_trans
		obj.transform.localScale = Vector3.one;
		obj.transform.localPosition = Vector3.zero
	end
	
	return obj
end

function unloadobj(path, type)
	if resMgr == nil then
		resMgr = GameKernel.GetResourceMgr()
	end
	resMgr:UnloadResource(path, type)
end

--[[--
 * @Description: 通过名字获取子控件  
 * @param:       父控件的Transform,子控件名字 
 * @return:      返回子控件Transform
 ]]
function child(go ,str)
	if go == nil then
		Trace("go == nil . Can not find the child "..str)
		return nil
	end
	return go:FindChild(str);
end

--[[--
 * @Description: 通过名字获取子控件（深度优先搜索，拿到即止，不需要指定路径，但需要细心规划控件名字，不要重名）  
 * @param:       trans      父控件的Transform
                 childName  子控件名字   
 * @return:      子控件Transform
 ]]
function child_ext(trans, childName)
	local ret = nil
	local childNum = trans.childCount

	for k = 0, childNum-1 do
		local childTrans = trans:GetChild(k)
		if (childTrans ~= nil) then
			if (childTrans.gameObject.name == childName) then
				ret = childTrans
				break
			else
				ret = child_ext(childTrans, childName)
				if (ret ~= nil) then
					break
				end
			end
		end
	end

	return ret
end

--[[--
 * @Description: 获取子控件组件
 * @param:       控件transfrom，组件名
 * @return:      返回子控件Transform
 ]]
function componentGet(trans , typeName)		
	if trans == nil then
		Trace("componentGet trans is nil")
		return nil
	end
	--Trace(typeName)
	return trans.gameObject:GetComponent(typeName);
end

--[[--
 * @Description: 获取子控件组件
 * @param:       控件transform，子控件名称 , 组件名 
 * @return:      返回子控件Transform
 ]]
function subComponentGet(trans , childCompName, typeName)		
	if trans == nil then
		Trace("subComponentGet trans is nil")
		return nil
	end
	local transChild = child(trans, childCompName)
	if transChild == nil then
		return nil
	end
	return transChild.gameObject:GetComponent(typeName)
end

--[[--
 * @Description: 获取子控件组件
 * @param:       控件transform
 		         子控件名称 (非路径方式)
 		         组件名 
 * @return:      返回子控件Transform
 ]]
function subComponentGet_ext(trans , childCompName, typeName)		
	if trans == nil then
		Trace("subComponentGet_ext trans is nil")
		return nil
	end
	local transChild = child_ext(trans, childCompName)
	if transChild == nil then
		return nil
	end
	return transChild.gameObject:GetComponent(typeName)
end

function findPanel(str) 
	local obj = find(str);
	if obj == nil then
		Fatal(str.." is null");
		return nil;
	end
	return obj:GetComponent("BaseLua");
end

--[[--
 * @Description: 按钮点击事件注册  
 * @param:       控件transform，子控件名称 , 回调函数
 ]]
function addClickCallback(trans, para1, para2, para3)
	if (type(para1) == "string") then
		local child_trans = trans:Find(para1)
		if (child_trans ~= nil) then
			local btnObj = child_trans.gameObject

			if (para3 ~= nil) then
				UIEventListener.Get(btnObj).onClick = function (...)
					para2(para3, ...)
				end
			else
				UIEventListener.Get(btnObj).onClick = para2
			end
		else
			Fatal("can not find the control, its name is: "..para1)
		end
	elseif (type(para1) == "function") then
		if (para2 == nil) then
			UIEventListener.Get(trans.gameObject).onClick = para1
		else
			UIEventListener.Get(trans.gameObject).onClick = function (...)
					para1(para2, ...)
				end
		end
	end
end

--[[--
 * @Description: 按钮点击事件注册  
 * @param:       控件transform，子控件名称 , 回调函数
 ]]
function addClickCallback_ext(trans, para1, para2)
	if (type(para1) == "string") then
		local child_trans = child_ext(trans, para1)
		if (child_trans ~= nil) then
			local btnObj = child_trans.gameObject
			UIEventListener.Get(btnObj).onClick = para2
		else
			Fatal("can not find the control, its name is: "..para1)
		end
	elseif (type(para1) == "function") then
		UIEventListener.Get(trans.gameObject).onClick = para1
	end
end
--[[--
 * @Description: 按钮点击事件注册  
 * @param:       控件obj，子控件名称, 回调函数
 ]]
function AddListener(obj,path,f)
    obj=obj or nil
    if obj==nil then
        Fatal("obj is nil")
        return
    end
    local ui=child(obj.transform,path)
    if f~=nil and ui~=nil then
       addClickCallbackSelf(ui.gameObject,f,this)
    end 
    if ui==nil then
        Fatal("ui not find")
    end
    return ui
 end

--[[--
 * @Description: 按钮点击事件注册  
 * @param:       控件transform，子控件名称 , 回调函数
 ]]
function addDBClickCallbackSelf(go, callback)
	if (go ~= nil) then
		UIEventListener.Get(go).onDoubleClick = callback
	else
		Fatal("can not find the control, its name is: "..controlName)
	end
end

--[[--
 * @Description: 按钮点击事件注册  
 * @param:       控件transform，子控件名称 , 回调函数
 ]]
function addClickCallbackSelf(go, callback, self)
	if (go ~= nil) then
		if self ~= nil then
		    UIEventListener.Get(go).onClick = function(obj) callback(self, obj) end
		else
		    UIEventListener.Get(go).onClick = callback
		end
	else
		Fatal("can not find the control, its name is: "..controlName)
	end
end


--[[--
 * @Description: 按钮点击事件注册  
 * @param:       控件transform，子控件名称, 回调函数
 ]]
function addPressedCallback(parentTrans, controlName, callback)
	local trans = parentTrans:Find(controlName)
	if (trans ~= nil) then
		local btnObj = trans.gameObject

		UIEventListener.Get(btnObj).onPress = callback
	else
		Fatal("can not find the control, its name is: "..controlName)
	end
end

--[[--
 * @Description: 按钮点击事件注册  
 * @param:       控件transform，子控件名称, 回调函数
 ]]
function addPressedCallbackSelf(parentTrans, controlName, callback, self)
	local trans = parentTrans:Find(controlName)
	if (trans ~= nil) then
		local btnObj = trans.gameObject
		if self ~= nil then 

			UIEventListener.Get(btnObj).onPress = function(...) callback(self, ...) end
		else

			UIEventListener.Get(btnObj).onPress = callback
		end
	else
		Fatal("can not find the control, its name is: "..controlName)
	end
end

--[[--
 * @Description: 按钮点击事件注册  
 * @param:       控件transform，子控件名称, 回调函数
 ]]
function addDropCallbackSelf(go, callback, self)
	if (go ~= nil) then
		if (self == nil) then
			UIEventListenerEx.GetEx(go).onDrop = callback
		else
			UIEventListenerEx.GetEx(go).onDrop = function(...) callback(self, ...) end
		end
	else
		Fatal("can not drop the nil control")
	end
end

--[[--
 * @Description: 按钮点击事件注册  
 * @param:       控件transform，子控件名称, 回调函数
 ]]
function addDragCallbackSelf(go, callback, self)
	if (go ~= nil) then
		if self == nil then
			UIEventListener.Get(go).onDrag = callback
		else
			UIEventListener.Get(go).onDrag = function( ... ) callback(self, ...) end
		end
	else
		Fatal("can not drop the nil control")
	end
end


function addDragStartCallbackSelf(go, callback, self)
	if (go ~= nil) then
		if (self == nil) then

			UIEventListener.Get(go).onDragStart = callback
		else

			UIEventListener.Get(go).onDragStart = function(...) callback(self, ...) end
		end
	else
		Fatal("can not drag the nil control")
	end
end

function addOnValueChangeCallbackSelf(go,callback,self)
	if (go~=nil) then 
		if(self==nil) then
			UIEventListener.Get(go).onChange = callback
		else
			UIEventListener.Get(go).onChange = function ( obj )callback(self,obj)end
		end
	else
		Fatal("can not drag the nil control")
	end
end

function addDragEndCallbackSelf(go, callback, self)
	if (go ~= nil) then
		if (self == nil) then

			UIEventListener.Get(go).onDragEnd = callback
		else

			UIEventListener.Get(go).onDragEnd = function(...) callback(self, ...) end
		end
	else
		Fatal("can not drag the nil control")
	end
end

function addSelectCallbackSelf(go, callback, self)
	if (go ~= nil) then
		if self ~= nil then
			UIEventListenerEx.GetEx(go).onSelect = function(...) callback(self, ...) end
		else
			UIEventListenerEx.GetEx(go).onSelect = callback
		end
	else
		Fatal("can not drag the nil control")
	end
end

--[[--
 * @Description: press事件注册  
 * @param:       控件transform，子控件名称 , 回调函数
 ]]
function addPressBoolCallback(parentTrans, controlName,callback, self)
	local trans = parentTrans:Find(controlName)
	if (trans ~= nil) then
		local btnObj = trans.gameObject
		if self ~= nil then
			UIEventListenerEx.GetEx(btnObj).onPress = function(...) callback(self, ...) end
		else
			UIEventListenerEx.GetEx(btnObj).onPress = callback
		end
	else
		Fatal("can not find the control, its name is: "..controlName)
	end
end

--[[--
 * @Description: press事件注册  
 * @param:       控件transform，子控件名称 , 回调函数
 ]]
function addPressBoolCallbackSelf(go, callback, self)
	if (go ~= nil) then
		if self ~= nil then
			UIEventListenerEx.GetEx(go).onPress = function(...) callback(self, ...) end
		else
			UIEventListenerEx.GetEx(go).onPress = callback
		end
	else
		Fatal("can not find the control, its name is: "..controlName)
	end
end

--[[--
 * @Description: 添加Tween动画结束回调
 * @param:       控件transform，子控件名称 , 回调函数
 ]]
function addTweenFinishedCallback(parentTrans, controlName, callback ,self)
	local tween = subComponentGet(parentTrans, controlName , "UITweener")

	if (trans ~= nil) then
		tween:AddOnFinished(EventDelegate.Callback(function( ) callback(self) end))
	else
		Fatal("can not find the control, its name is: "..controlName)
	end
end

--[[--
 * @Description: 添加uitoggle结束回调
 * @param:       控件transform，子控件名称 , 回调函数
 ]]
function initToggleObj(parentTrans, controlName, callback, self)
	local toggleObj = nil
	if controlName ~= nil then
		toggleObj = subComponentGet(parentTrans, controlName, 'UIToggle')
	else
		toggleObj = componentGet(parentTrans, 'UIToggle')
	end
	
	if (toggleObj ~= nil) then
		if self ~= nil then
			EventDelegate.Add(toggleObj.onChange, EventDelegate.Callback(function() callback(self) end))
		else
			EventDelegate.Add(toggleObj.onChange, EventDelegate.Callback(callback))
		end
	end

	return toggleObj
end

function destroyAllChild(trans)
	local childNum = trans.childCount
	for k = 0, childNum-1 do
		local childTrans = trans:GetChild(k)
		if (childTrans ~= nil) then 
			destroy(childTrans.gameObject)
		end
	end
end

function destroyAllChildImmediate(trans)
	local childNum = trans.childCount
	for k = childNum-1,0,-1  do
		local childTrans = trans:GetChild(k)
		if (childTrans ~= nil) then 
			if (not IsNil(childTrans.gameObject)) then
				GameObject.DestroyImmediate(childTrans.gameObject);
			end
		end
	end
end

--[[--
 * @Description: 一系列帮助函数  
 ]]
function Vector3ToTriple(vec3, trip)
	trip.x = math.ceil(vec3.x * 100)
	trip.y = math.ceil(vec3.y * 100)
	trip.z = math.ceil(vec3.z * 100)
end

function TripleToVector3(trip)
	local vec3 = Vector3.zero
	if trip ~= nil then
		vec3.x = (trip.x) / 100
		vec3.y = (trip.y) / 100
		vec3.z = (trip.z) / 100
	end
	return vec3
end

function CopyTriple(outDat, inData)
	outDat.x = inData.x
	outDat.y = inData.y
	outDat.z = inData.z
end

function PosEquals(v1, v2, precision)
	if precision == nil then
	    precision = 0.01
	end
	
	if math.abs(v1.x - v2.x) < precision and math.abs(v1.z - v2.z) < precision then
		return true
	else
		return false
	end
end

function DirEquals(v1, v2)
    if math.abs(v1.x - v2.x) < 0.01 and math.abs(v1.z - v2.z) < 0.01 then
		return true
	else
		return false
	end
end

function DirCalc(v1, v2)
	local Dir = v1 - v2
	Dir.y = 0
	Dir:SetNormalize()
	return Dir
end

function SetLableName(parentTrans, name, text)
	local label = subComponentGet(parentTrans, name, "UILabel")
	if label ~= nil then
		label.text = text
	end
end

function TimeSecToString(sec)
	if (sec ~= nil) then
		local intTime = math.floor(sec)
		return string.format("%02d:%02d", math.floor(intTime / 60), math.floor(intTime % 60))
	else
		return ""
	end
end

--[[--
 * @Description: 将毫秒转化为 天时分秒的格式  不足1秒大于0 默认返回1秒  大于1秒后面尾数舍去
 * @param:       msec (毫秒)
 * @return:      day(天) hour(时) minute(分) second(秒)
 ]]
function TimeMillisecondToParams(msec)
	local timesprit = {1000, 1000*60, 1000*60*60, 1000*60*60*24}
	local time_array = {0, 0, 0, 0}
	if msec~=nil and msec>0 then
	 	local len = table.getn(timesprit)

		local isLessthenSec = true
		local timeMod = msec
		for i=len,1,-1 do
			local intsTime = timeMod/timesprit[i]
			time_array[i] = math.floor(intsTime)
			if time_array[i] ~= 0 and isLessthenSec == true then
				isLessthenSec = false
			end
			timeMod = timeMod%timesprit[i]
			if timeMod == 0 then
				break
			end
		end

		if timeMod ~= 0 and isLessthenSec == true then
			time_array[TIME_NAME.SECOND] = time_array[TIME_NAME.SECOND] + 1
		end
	end
	--print(time_array[TIME_NAME.DAY].."天 "..time_array[TIME_NAME.HOUR].."h "..time_array[TIME_NAME.MINUTE].."m "..time_array[TIME_NAME.SECOND].."s")
	return time_array[TIME_NAME.DAY],time_array[TIME_NAME.HOUR],time_array[TIME_NAME.MINUTE],time_array[TIME_NAME.SECOND]
end

function Vector3.DistanceXZ(va, vb)
	return math.sqrt((va.x - vb.x)^2 + (va.z - vb.z)^2)
end

function Vector3.SqrDistanceXZ(va,vb)
	return (va.x - vb.x)^2 + (va.z - vb.z)^2
end

function GetCurrSceneType()
	return game_scene.getCurSceneType()
end

--[[--
 * @Description: 递归设置UI角色层
 ]]
function RecursiveSetLayerVal(node, layer)
    if (node == nil) then
        return
    end
    for i=1,node.childCount do
        local child = node:GetChild(i-1)
        if (child ~= nil) then
            child.gameObject.layer = layer
            RecursiveSetLayerVal(child, layer)
        end
    end
end

--[[--
 * @Description: 递归设置UI角色层
 ]]
function RecursiveSetLayerValIncludeSelf(node, layer)
    if (node == nil) then
        return
    end
    node.gameObject.layer = layer
    for i=1,node.childCount do
        local child = node:GetChild(i-1)
        if (child ~= nil) then
            child.gameObject.layer = layer
            RecursiveSetLayerVal(child, layer)
        end
    end
end

--[[--
 * @Description: Restart ParticleSystem In Children
 ]]
function RestartParticleSystem(go)
    if (go == nil) then
        return
    end
    local childrenParticleSystems = go:GetComponentsInChildren(typeof(UnityEngine.ParticleSystem))
    local len = childrenParticleSystems.Length -1 
	if len >= 0 then
		for i=0,len do
			childrenParticleSystems[i]:Simulate(0, true, true)
			childrenParticleSystems[i]:Play(true)
		end
	end
end


function SetHeroCameraFollow(gameObject)
	if (gameObject ~= nil) then
		local cameraObj = GameObject.FindGameObjectWithTag("MainCamera")
		if (cameraObj ~= nil) then
			local tpCamera = cameraObj:GetComponent("ThirdPersonCameraHall")
			if (tpCamera ~= nil) then
				tpCamera:SetFollowObject(gameObject)
			end
		end
	end
end

--[[--
 * @Description: 替换掉str中的脏字和敏感词，变温*号，返回替换后的字符串；如果没有脏字
                 和敏感词，返回原字符串
 ]]
local trieFilter = nil 
function CheckAndReplaceForBadWords(str)
	if (trieFilter == nil) then
		trieFilter = TrieFilter.GetInstance()
	end
	return trieFilter:Replace(str)
end

--[[--
 * @Description: 给UILabel设置文字，超出fixedLength的部分，用...表示
 	注意，label应该要被设置成resizeFreely的overFlow方式，否则没有用
 ]]
function SetLabelTextByShort(label, text, fixedLength)
	label.text = text
	label:UpdateNGUIText()

    local stringLen = NGUIText.CalculatePrintedSize(text).x
    if(stringLen > fixedLength) then
    	local chars = Utils.splitWord(text)
    	local okFlag = false
    	local currEndPos = chars.size - 1
    	while(not okFlag) do
    		currEndPos = currEndPos - 1
    		local currText = ""
    		for j = 1, currEndPos do
				local charTmp = chars:at(j)
				currText = currText..charTmp
			end
			currText = currText.."..."
			label.text = currText
			label:UpdateNGUIText()
			if (NGUIText.CalculatePrintedSize(currText).x < fixedLength) then
				okFlag = true
			end
    	end
    end
end

--[[--
	判断table里面是否有这个值
 ]]
function DectTableValue(T,value)
	for i ,v in pairs (T) do
		if value == v then
			return true
		end
	end
	return false
end

--[[--
	组装Json字符串
	键值对(key, value)形式
 ]]
function CombinJsonStr(...)
	local tmpTbl = {...}
	if type(tmpTbl[1]) =="table" then
		return json.encode(tmpTbl[1])
	end

    -- 键值对处理
    local tbl = {}
    local key = nil
    for i,v in ipairs({...}) do
        if key then
            tbl[key] = v or ""
            key = nil
        else
            key = v
        end
    end
    return json.encode(tbl)
end

--[[--
	解析Json字符串
 ]]
function ParseJsonStr(jsStr)
    if not jsStr then
        return {}
    end
    return json.decode(jsStr)
end


function LoadTable(t)
  if type(t) ~= "table" then 
    return t
  end 

  local tab = ""
  local strArr = {}
  table.insert(strArr, "")
  for k,v in pairs(t) do 
    if v ~= nil then 
      local key = tab
      if type(k) == "string" then
        key =  string.format("%s[\"%s\"] = ", key, tostring(k) )
      else 
        key =  string.format("%s[%s] = ", key, tostring(k) )
      end 
      
      table.insert(strArr, key)
      if type(v) == "table" then 
        table.insert(strArr, LoadTable(v) )
      elseif type(v) == "string" then 
        table.insert(strArr, string.format("\"%s\";\n",tostring(v)))
      else 
        table.insert(strArr, string.format("%s;\n",tostring(v)))
      end 
    end 
  end 
  
  local str = string.format("\n%s{\n%s%s};\n", tab, table.concat(strArr), tab)
  return str
end 

function GetTblData(...)
  local strArr = {}
  table.insert(strArr, "")
  for _,v in pairs({...}) do
    local tempType = type(v)
    if tempType == "table" then
      table.insert(strArr, LoadTable(v) )
    else
      table.insert(strArr, tostring(v) )
    end
    table.insert(strArr, " ")
  end
  
  return string.format("GAME_LOG: %s \n", table.concat(strArr))
end

-- 写日志
function LogW(...)
	local timePrefix = os.date("%Y-%m-%d %H:%M:%S",os.time())
	local msg = timePrefix .. "  " .. GetTblData(...)
	local logPath  -- log 需要写入的路径
	Trace(msg)

	if logPath then
		local LogTxt = io.open(logPath, "a+")
		if LogTxt then
			LogTxt:write(msg)
			LogTxt:flush()
		end
	end
end

--世界坐标切换成屏幕坐标
function WorldToScreenPos( worldPos )
	local screenPos = Camera.main.WorldToScreenPoint(worldPos) -- 目的获取z，在Start方法
	screenPos.z = 0
	return screenPos
end

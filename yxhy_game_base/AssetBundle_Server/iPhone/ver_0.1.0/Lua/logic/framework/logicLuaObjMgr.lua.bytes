--[[--
 * @Description: 用来对可挂接到GameObject的Lua脚本进行统一管理
 * @Author:      shine
 * @FileName:    logicLuaObjMgr.lua
 * @DateTime:    2017-05-16 14:50:39
 ]]


logicLuaObjMgr = {}
local this = logicLuaObjMgr
local constructTable = {}
local luaObjectTable = {}

--[[--
 * @Description: 注册某类  
 * @param:       luaClassName : 某类的名字
                 constructFunc: 某类的构造函数
 ]]
function this.registerLuaClass(luaClassName, constructFunc)
	constructTable[luaClassName] = constructFunc
end

--[[--
 * @Description: 根据luaClassName创建某lua类 
 * @param:       luaClassName 某类的名字 
 ]]
function this.createLuaObject(luaClassName, gameObject, ID)
	local constructFunc = constructTable[luaClassName]
	if (nil ~= constructTable[luaClassName]) then
		local luaObject = constructFunc()
		luaObjectTable[gameObject] = luaObject
		luaObject.gameObject = gameObject
		luaObject.transform = gameObject.transform
		luaObject.ID = ID
	end
end

function this.AddLuaUIObject(go, luaObj)
	luaObjectTable[go] = luaObj
end

function this.RemoveLuaUIObject(go)
	luaObjectTable[go] = nil
end

--[[--
 * @Description: 根据gameobject得到绑定的相应lua对象
 * @param:       gameObject u3d object对象 
 ]]
function this.getLuaObjByGameObj(gameObject)
	return luaObjectTable[gameObject]	
end

function this.Awake(UiFormsName)
--	logError("logicLuaObjMgr.Awake")
	UI_Manager:Instance():Awake(UiFormsName)
end

function this.Update(UiFormsName)
	UI_Manager:Instance():Update(UiFormsName)
end

function this.Start(UiFormsName)
	UI_Manager:Instance():Start(UiFormsName)
end

function this.OnEnable(UiFormsName)
	UI_Manager:Instance():OnEnable(UiFormsName)
end

function this.OnDisable(UiFormsName)
	UI_Manager:Instance():OnDisable(UiFormsName)
end

function this.OnTriggerEnter(UiFormsName,collider)
	UI_Manager:Instance():OnTriggerEnter(UiFormsName,collider)
end

function this.OnTriggerStay(UiFormsName,collider)
	UI_Manager:Instance():OnTriggerStay(UiFormsName,collider)
end

function this.OnTriggerExit(UiFormsName,collider)
	UI_Manager:Instance():OnTriggerExit(UiFormsName,collider)
end

function this.OnCollisionEnter(UiFormsName,collision)
	UI_Manager:Instance():OnCollisionEnter(UiFormsName,collision)
end

function this.OnCollisionStay(UiFormsName,collision)
	UI_Manager:Instance():OnCollisionStay(UiFormsName,collision)
end

function this.OnCollisionExit(UiFormsName,collision)
	UI_Manager:Instance():OnCollisionExit(UiFormsName,collision)
end

function this.OnFingerHover(UiFormsName,e)
	UI_Manager:Instance():OnFingerHover(UiFormsName,e)
end

function this.OnSwipe(UiFormsName,Direction,SelectObj)
	UI_Manager:Instance():OnSwipe(UiFormsName,Direction,SelectObj)
end

function this.OnFingerUp(UiFormsName,fingerUp)
	UI_Manager:Instance():OnFingerUp(UiFormsName,fingerUp)
end

function this.OnFingerDown(UiFormsName,fingerDown)
	UI_Manager:Instance():OnFingerUp(UiFormsName,fingerUp)
end

function this.OnTap(UiFormsName,tap)
	UI_Manager:Instance():OnTap(UiFormsName,tap)
end

function this.OnDragRecognizer(UiFormsName,DeltaMove,normalizedTime)
	UI_Manager:Instance():OnDragRecognizer(UiFormsName,DeltaMove,normalizedTime)
end
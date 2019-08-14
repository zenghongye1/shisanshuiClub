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
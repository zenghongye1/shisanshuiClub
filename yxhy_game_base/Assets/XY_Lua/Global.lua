--[[--
 * @Description: 最先被C#包含的lua文件，用来放置一些常用的
                 C#导出类，以及基本的lua文件，还有常用的一些lua函数（这些函数可以考虑
                 整理到其他工具lua文件中）
 * @Author:      shine
 * @FileName:    Golbal.lua
 * @DateTime:    2015-05-16 11:00:18
 ]]

require "common/json"
require "common/functions"

require "logic/report_sys/report_sys"
String 			= System.String
Screen			= UnityEngine.Screen
GameObject 		= UnityEngine.GameObject
Transform 		= UnityEngine.Transform
--Space			= UnityEngine.Space
--DictInt2Int		= System.Collections.Generic.DictInt2Int
--DictString2Object	= System.Collections.Generic.DictString2Object
--DictInt2Double	= System.Collections.Generic.DictInt2Double
--DictGameObject2LuaTable = System.Collections.Generic.DictGameObject2LuaTable

Camera			= UnityEngine.Camera
--QualitySettings = UnityEngine.QualitySettings
Input			= UnityEngine.Input
--KeyCode		= UnityEngine.KeyCode
AudioClip		= UnityEngine.AudioClip
--AudioSource		= UnityEngine.AudioSource
Physics			= UnityEngine.Physics

--RenderSettings  = UnityEngine.RenderSettings
MeshRenderer	= UnityEngine.MeshRenderer
--ParticleAnimator= UnityEngine.ParticleAnimator
--TouchPhase 		= UnityEngine.TouchPhase
PlayerPrefs = UnityEngine.PlayerPrefs

GCloudVoiceMode = gcloud_voice.GCloudVoiceMode

-- 额外昵称，方便使用
GameKernel 		= Framework.GameKernel
ProtobufDataConfigMgr = ProtobufDataConfig.ProtobufDataConfigMgr

--List_uint = System.Collections.Generic.List_uint
Application = UnityEngine.Application

Uri = System.Uri
WebSocket = BestHTTP.WebSocket.WebSocket

UILabelFormat = UILabel.MyFormat

require "common/Utils"
require "utils/string_handler"

require "common/Object"
require "common/Notifier"

require "logic/framework/cmdName"
require "logic/framework/logicLuaObjMgr"

require "logic/common/screenshotHelper" 
require "logic/common/shareHelper"
require "logic/common/jumpHelper"

--通用的lua
require "logic/common_ui/ui_base"
require "logic/common_ui/fast_tip"
require "logic/common_ui/exit_ui"
require "logic/common_ui/waiting_ui"
require "logic/common_ui/chat_ui"
require "logic/gps_sys/gps_data"

--网络
require "logic/network/network_mgr"
require "logic/network/netdata_rsp_handler"

require "logic/common_ui/ui_sound_mgr"

config_mgr = require "config/config_mgr"
GameUtil = require "utils/GameUtil"
InputManager = require "logic/framework/InputManager"

require "logic/mahjong_sys/_model/player_data"

function printf(format, ...)
	Debugger.Log(string.format(format, ...))
end

function LuaGC()
  local c = collectgarbage("count")
  Debugger.Log("Begin gc count = {0} kb", c)
  collectgarbage("collect")
  c = collectgarbage("count")
  Debugger.Log("End gc count = {0} kb", c)
end

function RemoveTableItem(list, item, removeAll)
    local rmCount = 0
    for i = 1, #list do
        if list[i - rmCount] == item then
            table.remove(list, i - rmCount)

            if removeAll then
                rmCount = rmCount + 1
            else
                break
            end
        end
    end
end

--unity 对象判断为空, 如果你有些对象是在c#删掉了，lua 不知道
--判断这种对象为空时可以用下面这个函数。
function IsNil(uobj)
	local ret = false
	if (uobj == nil) then
		ret = true
	end

	if (uobj ~= nil ) then
		if (uobj:Equals(nil)) then
			ret = true
		end
	end

	return ret
end

-- isnan
function isnan(number)
	return not (number == number)
end


function string:split(sep)
	local sep, fields = sep or ",", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) table.insert(fields, c) end)
	return fields
end

function GetDir(path)
	return string.match(fullpath, ".*/")
end

function GetFileName(path)
	return string.match(fullpath, ".*/(.*)")
end

function table.contains(table, element)
  if table == nil then
        return false
  end

  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function table.getCount(self)
	local count = 0
	
	for k, v in pairs(self) do
		count = count + 1	
	end
	
	return count
end

function DumpTable(t)
	for k,v in pairs(t) do
		if v ~= nil then
			Debugger.Log("Key: {0}, Value: {1}", tostring(k), tostring(v))
		else
			Debugger.Log("Key: {0}, Value nil", tostring(k))
		end
	end
end

 function PrintTable(tab)
    local str = {}

    local function internal(tab, str, indent)
        for k,v in pairs(tab) do
            if type(v) == "table" then
                table.insert(str, indent..tostring(k)..":\n")
                internal(v, str, indent..' ')
            else
                table.insert(str, indent..tostring(k)..": "..tostring(v).."\n")
            end
        end
    end

    internal(tab, str, '')
    return table.concat(str, '')
end

function PrintLua(name, lib)
	local m
	lib = lib or _G

	for w in string.gmatch(name, "%w+") do
       lib = lib[w]
     end

	 m = lib

	if (m == nil) then
		Debugger.Log("Lua Module {0} not exists", name)
		return
	end

	Debugger.Log("-----------------Dump Table {0}-----------------",name)
	if (type(m) == "table") then
		for k,v in pairs(m) do
			Debugger.Log("Key: {0}, Value: {1}", k, tostring(v))
		end
	end

	local meta = getmetatable(m)
	Debugger.Log("-----------------Dump meta {0}-----------------",name)

	while meta ~= nil and meta ~= m do
		for k,v in pairs(meta) do
			if k ~= nil then
			Debugger.Log("Key: {0}, Value: {1}", tostring(k), tostring(v))
			end

		end

		meta = getmetatable(meta)
	end

	Debugger.Log("-----------------Dump meta Over-----------------")
	Debugger.Log("-----------------Dump Table Over-----------------")
end

function stringToTable(str)
   local ret = loadstring("return "..str)()
   return ret
end

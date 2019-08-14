--[[--
 * @Description: 本地存储系统，区分纬度如下：
                 1. machine   机器
                 2. role      角色
 * @Author:      shine
 * @FileName:    local_storage_sys.lua
 * @DateTime:    2017-05-16 14:50:39
 ]]
require("logic/framework/data_center")

local_storage_sys = {
	--定义一些变量，省得调用的地方可能会不统一
	role_accounts = "login_role_id",
	role_passwd = "login_role_passwd",
	login_areaid = "key_login_areaid"
}

local this = local_storage_sys

local PREFIX_MACHINE = "PREFIX_MACHINE"

local MakeFullMachineKey = nil
local MakeFullRoleKey = nil

local roleKey = nil

function MakeFullMachineKey(key)
	return PREFIX_MACHINE..key
end

function MakeFullRoleKey(key)
	if (roleKey == nil) then
		roleKey = toUint64String(data_center.GetRoleID())
	end

	return roleKey..key
end


-------------------///////////////global control//////////////////----------------------------
function this.HasKey_Machine(key)
	return PlayerPrefs.HasKey(MakeFullMachineKey(key))
end

function this.HasKey_Role(key)
	return PlayerPrefs.HasKey(MakeFullRoleKey(key))
end

function this.HasKey_LastOpenBagTime(key)
	return PlayerPrefs.HasKey(MakeFullMachineKey(key))
end

function this.HasKey_NewBagItemMark(key)
	return PlayerPrefs.HasKey(MakeFullMachineKey(key))
end


function this.DeleteKey_Machine(key)
	PlayerPrefs.DeleteKey(MakeFullMachineKey(key))
end

function this.DeleteKey_Role(key)
	PlayerPrefs.DeleteKey(MakeFullRoleKey(key))
end

-------------////////////////////string start///////////////////------------------------------
function this.SetString_Machine(key, stringValue)
	PlayerPrefs.SetString(MakeFullMachineKey(key), stringValue)
end

function this.SetString_Role(key, stringValue)
	PlayerPrefs.SetString(MakeFullRoleKey(key), stringValue)
end

function this.GetString_Machine(key)
	return PlayerPrefs.GetString(MakeFullMachineKey(key), "")
end

function this.GetString_Role(key)
	return PlayerPrefs.GetString(MakeFullRoleKey(key), "")
end
-------------////////////////////string end///////////////////------------------------------


-------------////////////////////int start///////////////////------------------------------
function this.SetInt_Machine(key, intValue)
	PlayerPrefs.SetInt(MakeFullMachineKey(key), intValue)
end

function this.SetInt_Role(key, intValue)
	PlayerPrefs.SetInt(MakeFullRoleKey(key), intValue)
end

function this.SetInt_LastOpenBagTime(key, intValue)
	PlayerPrefs.SetInt(MakeFullMachineKey(key), intValue)
end

function this.SetInt_NewBagItemMark(key, intValue)
	PlayerPrefs.SetInt(MakeFullMachineKey(key), intValue)
end

function this.SetInt_FirstMark(key,intValue)
	PlayerPrefs.SetInt(MakeFullMachineKey(key),intValue)
end

function this.GetInt_Machine(key)
	return math.floor(PlayerPrefs.GetInt(MakeFullMachineKey(key), -1))
end

function this.GetInt_Role(key)
	return math.floor(PlayerPrefs.GetInt(MakeFullRoleKey(key), -1))
end

function this.GetInt_LastOpenBagTime(key)
	return math.floor(PlayerPrefs.GetInt(MakeFullMachineKey(key), -1))
end

function this.GetInt_NewBagItemMark(key)
	return math.floor(PlayerPrefs.GetInt(MakeFullMachineKey(key), -1))
end

function this.GetInt_FirstMark(key)
	return math.floor(PlayerPrefs.GetInt(MakeFullMachineKey(key),-1))
end
-------------////////////////////int end///////////////////------------------------------

-------------////////////////////float start///////////////////------------------------------
function this.SetFloat_Machine(key, floatValue)
	PlayerPrefs.SetFloat(MakeFullMachineKey(key), floatValue)
end

function this.SetFloat_Role(key, floatValue)
	PlayerPrefs.SetFloat(MakeFullRoleKey(key), floatValue)
end

function this.GetFloat_Machine(key)
	return PlayerPrefs.GetFloat(MakeFullMachineKey(key), -1)
end

function this.GetFloat_Role(key)
	return PlayerPrefs.GetFloat(MakeFullRoleKey(key), -1)
end
-------------////////////////////float end///////////////////------------------------------

-------------////////////////////table start///////////////////------------------------------
function this.SetTable_Machine(key, tableValue)
	local stringValue = Utils.tableToString(tableValue)
	PlayerPrefs.SetString(MakeFullMachineKey(key), stringValue)
end

function this.SetTable_Role(key, tableValue)
	local stringValue = Utils.tableToString(tableValue)
	PlayerPrefs.SetString(MakeFullRoleKey(key), stringValue)
end

function this.GetTable_Machine(key)
	local ret = {}
	local stringValue = PlayerPrefs.GetString(MakeFullMachineKey(key), "")
	if (stringValue ~= "") then
		ret = Utils.stringToTable(stringValue)
	end

	return ret
end

function this.GetTable_Role(key)
	local ret = {}
	local stringValue = PlayerPrefs.GetString(MakeFullRoleKey(key), "")
	if (stringValue ~= "") then
		ret = Utils.stringToTable(stringValue)
	end

	return ret
end
-------------////////////////////table end///////////////////------------------------------

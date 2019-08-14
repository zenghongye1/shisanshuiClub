--[[--
 * @Description: 模式管理器
 * @Author:      shine
 * @FileName:    mode_manager.lua
 * @DateTime:    2017-06-12 20:50:03
 ]]

require "logic/mahjong_sys/const/mahjongConst"
require "logic/mahjong_sys/utils/MahjongTools"
--加载具体玩法
--require "logic/mahjong_sys/fuzhou_mahjong/play_mode_henan"
require "logic/mahjong_sys/fuzhou_mahjong/play_mode_fuzhou"


mode_manager = {}
local this = mode_manager
local currentMode = nil                -- 当前模式

--// 麻将模式字典
local playModeDict = 
{
	--[1] = play_mode_henan,      --河南麻将玩法
    [ENUM_GAME_TYPE.TYPE_SHISHANSHUI] = play_mode_shisangshui,
    [ENUM_GAME_TYPE.TYPE_FUZHOU_MJ] = play_mode_fuzhou,
}


function this.StartCurrentMode()
	if (currentMode ~= nil) then
		currentMode:Start()
	end
end

--[[--
 * @Description: 初始化麻将模式
 ]]
function this.InitializeMode()
    local gid = player_data.GetGameId()
	local play_mode = playModeDict[gid]
	if GameUtil.CheckGameIdIsMahjong(gid) then
		play_mode = play_mode_fuzhou
	end
	--Trace("Play_mode"..tostring(Play_mode))
	if (play_mode ~= nil) then
		currentMode = play_mode.GetInstance()
	end

	Trace("-------------------------------InitializeMode")
	currentMode:Initialize()
end

--[[--
 * @Description: 返回当前模式
 ]]
function this.GetCurrentMode()
	return currentMode
end

--[[--
 * @Description: 反初始化当前模式
 ]]
function this.UninitializeCurrMode()
	if (currentMode ~= nil) then
		currentMode:Uninitialize()
		currentMode = nil
	end
end

--[[--
 * @Description: 得到模式模式类型
 ]]
function this.GetMahjongModeType()
	return levelModeType
end

pokerPlaySysHelper = {}
local this = pokerPlaySysHelper

local curGameSys = nil

local playSysConfig = {
	[ENUM_GAME_TYPE.TYPE_SHISHANSHUI] = "logic/shisangshui_sys/shisanshui_play_sys",
	[ENUM_GAME_TYPE.TYPE_NIUNIU] = "logic/niuniu_sys/niuniu_play_sys",
	[ENUM_GAME_TYPE.TYPE_PINGTAN_SSS] = "logic/shisangshui_sys/shisanshui_play_sys",
	[ENUM_GAME_TYPE.TYPE_SANGONG] = "logic/poker_sys/sangong_sys/sangong_play_sys",
	[ENUM_GAME_TYPE.TYPE_YINGSANZHANG] = "logic/poker_sys/yingsanzhang_sys/yingsanzhang_play_sys",
	[ENUM_GAME_TYPE.TYPE_PUXIAN_SSS] = "logic/shisangshui_sys/shisanshui_play_sys",
	[ENUM_GAME_TYPE.TYPE_ShuiZhuang_SSS] = "logic/shisangshui_sys/shisanshui_play_sys",
	[ENUM_GAME_TYPE.TYPE_DuoGui_SSS] = "logic/shisangshui_sys/shisanshui_play_sys",
	[ENUM_GAME_TYPE.TYPE_BaRen_SSS] = "logic/shisangshui_sys/shisanshui_play_sys",
	[ENUM_GAME_TYPE.TYPE_ChunSe_SSS] = "logic/shisangshui_sys/shisanshui_play_sys",
}

function this.SetCurPlaySys(gid)
	Trace("---------设置gid:",gid,"的玩法--------------")
	local curGid = gid or player_data.GetGameId()
	if not GameUtil.CheckGameIdIsMahjong(curGid) then
		curGameSys = require(playSysConfig[curGid]).create()
	else
		logError(gid,"不是扑克玩法")
	end
end

function this.GetCurPlaySys()
	if not curGameSys then
		this.SetCurPlaySys()
	end
	-- curGameSys.LogTest()
	return curGameSys
end

function this.ClearCurSys()
	curGameSys = nil
end

--[[--
 * @Description: 洛阳麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_9 = {}
setmetatable(mahjong_config_9, {__index = config_common})

mahjong_config_9.wallDunCountMap = 
{
	17,17,17,17
}

mahjong_config_9.beishu_wintype_dic = 
{
	["gangci"] = {"bGangCiAdd", {3, 4}}, 	-- 杠次   未勾选时3倍
	["pici"] = {"bSupportPiCi", {0, 3}}, 	-- 皮次	
}

mahjong_config_9.uiActionCfg.game_giveCard = {9,"mahjong_action_gameGiveCard"}
mahjong_config_9.uiActionCfg.small_reward = {9, "mahjong_action_small_reward_9"}

mahjong_config_9.mahjongActionCfg.game_askPlay = {8, "mahjong_mjAction_gameAskPlay"}
mahjong_config_9.mahjongActionCfg.game_playStart = {8, "mahjong_mjAction_gamePlayStart"}
mahjong_config_9.mahjongActionCfg.game_ci = {9, "mahjong_mjAction_gameCi"}
return mahjong_config_9
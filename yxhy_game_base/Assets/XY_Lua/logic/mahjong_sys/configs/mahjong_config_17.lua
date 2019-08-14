
--[[--
 * @Description: 廊坊麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_17 = {}
setmetatable(mahjong_config_17, {__index = config_common})

mahjong_config_17.wallDunCountMap = 
{
	17,17,17,17
}

mahjong_config_17.beishu_wintype_dic = 
{
	["nSelfDraw"] = 2,
	["nGun"] = 1,
}

mahjong_config_17.mahjongActionCfg.game_askPlay = {8, "mahjong_mjAction_gameAskPlay"}
mahjong_config_17.mahjongActionCfg.game_playStart = {15, "mahjong_mjAction_gamePlayStart"}
mahjong_config_17.mahjongActionCfg.game_laiZi = {17, "mahjong_mjAction_gameLaiZi"}
mahjong_config_17.uiActionCfg.small_reward = {17, "mahjong_action_small_reward_17"}
mahjong_config_17.uiActionCfg.game_followBanker = {15, "mahjong_action_follow_banker_15"}
mahjong_config_17.uiActionCfg.game_askBlock = {15,"mahjong_action_gameAskBlock"}
 

return mahjong_config_17
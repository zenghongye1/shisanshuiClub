
--[[--
 * @Description: 河北沧州麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_82 = {}
setmetatable(mahjong_config_82, {__index = config_common})

mahjong_config_82.MahjongTotalCount = 136  -- 麻将总数量

mahjong_config_82.wallDunCountMap = 
{
	17,17,17,17
}

mahjong_config_82.beishu_wintype_dic = 
{
	["nSelfDraw"] = 2,
	["nGun"] = 1,
}

mahjong_config_82.mahjongActionCfg.game_playStart = {15, "mahjong_mjAction_gamePlayStart"}
mahjong_config_82.uiActionCfg.game_askBlock = {82,"mahjong_action_gameAskBlock"}

mahjong_config_82.uiActionCfg.game_triplet = {82,"mahjong_action_gameTriplet"}
mahjong_config_82.uiActionCfg.game_quadruplet = {82,"mahjong_action_gameQuadruplet"}
mahjong_config_82.uiActionCfg.game_collect = {82,"mahjong_action_gameCollect"}

mahjong_config_82.uiActionCfg.small_reward = {82, "mahjong_action_small_reward_82"} 
mahjong_config_82.uiActionCfg.bzz = {82, "mahjong_action_gamebzz"}

mahjong_config_82.mahjongActionCfg.game_askPlay = {8, "mahjong_mjAction_gameAskPlay"}

return mahjong_config_82
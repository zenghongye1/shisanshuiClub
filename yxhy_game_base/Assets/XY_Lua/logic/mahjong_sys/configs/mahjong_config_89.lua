
--[[--
 * @Description: 河北邯郸麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_89 = {}
setmetatable(mahjong_config_89, {__index = config_common})

mahjong_config_89.MahjongTotalCount = 136  -- 麻将总数量

mahjong_config_89.wallDunCountMap = 
{
	17,17,17,17
}

mahjong_config_89.beishu_wintype_dic = 
{
	["nSelfDraw"] = 2,
	["nGun"] = 1,
}

mahjong_config_89.mahjongActionCfg.game_playStart = {15, "mahjong_mjAction_gamePlayStart"}
mahjong_config_89.uiActionCfg.game_askBlock = {15,"mahjong_action_gameAskBlock"}
mahjong_config_89.uiActionCfg.small_reward = {89, "mahjong_action_small_reward_89"} 

mahjong_config_89.mahjongActionCfg.game_askPlay = {8, "mahjong_mjAction_gameAskPlay"}

return mahjong_config_89
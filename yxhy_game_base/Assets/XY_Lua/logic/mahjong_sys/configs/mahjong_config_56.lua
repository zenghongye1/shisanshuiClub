
--[[--
 * @Description: 周口麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_56 = {}
setmetatable(mahjong_config_56, {__index = config_common})

mahjong_config_56.wallDunCountMap = 
{
	17,17,17,17
}

mahjong_config_56.uiActionCfg.small_reward = {56, "mahjong_action_small_reward_56"}

mahjong_config_56.mahjongActionCfg.game_askPlay = {8, "mahjong_mjAction_gameAskPlay"}
mahjong_config_56.mahjongActionCfg.game_playStart = {8, "mahjong_mjAction_gamePlayStart"}
mahjong_config_56.mahjongActionCfg.game_laiZi = {8, "mahjong_mjAction_gameLaiZi"}

return mahjong_config_56
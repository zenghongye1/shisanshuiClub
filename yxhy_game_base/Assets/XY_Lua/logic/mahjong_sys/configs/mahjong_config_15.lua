
--[[--
 * @Description: 石家庄好友房玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_15 = {}
setmetatable(mahjong_config_15, {__index = config_common})

mahjong_config_15.wallDunCountMap = 
{
	17,17,17,17
}

mahjong_config_15.uiActionCfg.small_reward = {15, "mahjong_action_small_reward_15"}
mahjong_config_15.uiActionCfg.game_followBanker = {15, "mahjong_action_follow_banker_15"}
mahjong_config_15.uiActionCfg.game_askBlock = {15,"mahjong_action_gameAskBlock"}

mahjong_config_15.mahjongActionCfg.game_askPlay = {8, "mahjong_mjAction_gameAskPlay"}
mahjong_config_15.mahjongActionCfg.game_playStart = {15, "mahjong_mjAction_gamePlayStart"}

return mahjong_config_15
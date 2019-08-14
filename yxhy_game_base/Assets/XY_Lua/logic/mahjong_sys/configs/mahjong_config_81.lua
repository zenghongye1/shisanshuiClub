
--[[--
 * @Description: 河北邢台麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_81 = {}
setmetatable(mahjong_config_81, {__index = config_common})

mahjong_config_81.MahjongTotalCount = 136  -- 麻将总数量

mahjong_config_81.wallDunCountMap = 
{
	17,17,17,17
}

mahjong_config_81.beishu_wintype_dic = 
{
	["nSelfDraw"] = 2,
	["nGun"] = 1,
}

mahjong_config_81.mahjongActionCfg.game_playStart = {15, "mahjong_mjAction_gamePlayStart"}
mahjong_config_81.uiActionCfg.game_askBlock = {15,"mahjong_action_gameAskBlock"}
mahjong_config_81.uiActionCfg.small_reward = {81, "mahjong_action_small_reward_81"} 

mahjong_config_81.mahjongActionCfg.game_askPlay = {8, "mahjong_mjAction_gameAskPlay"}

return mahjong_config_81
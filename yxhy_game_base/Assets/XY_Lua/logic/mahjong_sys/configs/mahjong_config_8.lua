
--[[--
 * @Description: 郑州麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_8 = {}
setmetatable(mahjong_config_8, {__index = config_common})

mahjong_config_8.MahjongTotalCount = 136  -- 麻将总数量

mahjong_config_8.wallDunCountMap = 
{
	17,17,17,17
}

mahjong_config_8.beishu_wintype_dic = 
{
	["qidui"] = {"bSupportSevenDoubleAdd", {1, 2}},
	["gangflower"] = {"bSupportGangFlowAdd", {1, 2}},
}
 
mahjong_config_8.uiActionCfg.small_reward = {8, "mahjong_action_small_reward_8"}

mahjong_config_8.mahjongActionCfg.game_askPlay = {8, "mahjong_mjAction_gameAskPlay"}
mahjong_config_8.mahjongActionCfg.game_playStart = {8, "mahjong_mjAction_gamePlayStart"}
mahjong_config_8.mahjongActionCfg.game_laiZi = {8, "mahjong_mjAction_gameLaiZi"}

return mahjong_config_8
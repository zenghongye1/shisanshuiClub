--region *.lua
--Date
--此文件由[BabeLua]插件自动生成


--[[--
 * @Description: 驻马店麻将玩法配置
 * @FileName:    mahjong_config_10.lua
 ]]
--endregion
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_10 = {}
setmetatable(mahjong_config_10, {__index = config_common})

mahjong_config_10.wallDunCountMap = 
{
	17,17,17,17
}

mahjong_config_10.beishu_wintype_dic = 
{
	["qidui"] = {"bSupportSevenDoubleAdd", {1, 2}},
	["gangflower"] = {"bSupportGangFlowAdd", {1, 2}},
}

mahjong_config_10.uiActionCfg.small_reward = {8, "mahjong_action_small_reward_8"}

mahjong_config_10.mahjongActionCfg.game_askPlay = {8, "mahjong_mjAction_gameAskPlay"}
mahjong_config_10.mahjongActionCfg.game_playStart = {8, "mahjong_mjAction_gamePlayStart"}
mahjong_config_10.mahjongActionCfg.game_laiZi = {8, "mahjong_mjAction_gameLaiZi"}
return mahjong_config_10
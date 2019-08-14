
--[[--
 * @Description: 霞浦麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_91 = {}
setmetatable(mahjong_config_91, {__index = config_common})

mahjong_config_91.MahjongBaseCount = 108  -- 用于计算的基础数
mahjong_config_91.MahjongTotalCount = 108  -- 麻将总数量

mahjong_config_91.wallDunCountMap = 
{
	14,14,14,14
}

mahjong_config_91.game_state = {
    none         = "none",
    prepare      = "prepare",        --开始
    banker       = "banker",          --定庄
    deal         = "deal",               --抓牌
    changeflower = "changeflower",      --补花
    opengold     = "opengold",         --开金
    round        = "round",        --游戏阶段
    reward       = "reward",       --结算
    gameend      = "gameend",       --结束
}

mahjong_config_91.ignoreSound = {
	[31] = true
}

mahjong_config_91.uiActionCfg.small_reward = {91, "mahjong_action_small_reward_91"}


mahjong_config_91.mahjongActionCfg.game_setting = {91, "mahjong_action_gameSetting_91"}
mahjong_config_91.mahjongActionCfg.game_openGlod = {42, "mahjong_mjAction_gameOpenGlod_42"}


mahjong_config_91.stateAnimMap[MahjongGameAnimState.openGold] = {20006, mahjong_path_enum.mjCommon, "fangjin", 1}

return mahjong_config_91
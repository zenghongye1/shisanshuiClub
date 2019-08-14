
--[[--
 * @Description: 福清麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_65 = {}
setmetatable(mahjong_config_65, {__index = config_common})

mahjong_config_65.game_state = {
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

mahjong_config_65.ignoreSound = {
	[31] = true
}

mahjong_config_65.uiActionCfg.small_reward = {65,"mahjong_action_small_reward_65"}

mahjong_config_65.mahjongActionCfg.game_openGlod = {18, "mahjong_mjAction_gameOpenGlod_18"}

return mahjong_config_65
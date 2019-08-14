
--[[--
 * @Description: 红中麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_40 = {}
setmetatable(mahjong_config_40, {__index = config_common})

mahjong_config_40.MahjongTotalCount = 112  -- 麻将总数量

mahjong_config_40.wallDunCountMap = 
{
	14,14,14,14
}

mahjong_config_40.game_state = {
    none         = "none",
    prepare      = "prepare",        --开始
    banker       = "banker",          --定庄
    deal         = "deal",               --抓牌
    changeflower = "changeflower",      --补花
    round        = "round",        --游戏阶段
    reward       = "reward",       --结算
    gameend      = "gameend",       --结束
}

mahjong_config_40.uiActionCfg.small_reward = {40, "mahjong_action_small_reward_40"}

mahjong_config_40.uiActionCfg.game_huaCardUpdate = {40, "mahjong_action_gameHuaCardUpdate_40"}

mahjong_config_40.mahjongActionCfg.game_playStart = {40,"mahjong_mjAction_gamePlayStart"}


mahjong_config_40.stateAnimList = {
	MahjongGameAnimState.start,
	MahjongGameAnimState.none,
}

return mahjong_config_40
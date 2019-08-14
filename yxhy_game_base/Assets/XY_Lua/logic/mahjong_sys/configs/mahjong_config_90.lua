
--[[--
 * @Description: 福安麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_90 = {}
setmetatable(mahjong_config_90, {__index = config_common})

mahjong_config_90.MahjongTotalCount = 112  -- 麻将总数量

mahjong_config_90.wallDunCountMap = 
{
	14,14,14,14
}

mahjong_config_90.game_state = {
    none         = "none",
    prepare      = "prepare",        --开始
    banker       = "banker",          --定庄
    deal         = "deal",               --抓牌
    opengold     = "opengold",         --开金
    round        = "round",        --游戏阶段
    reward       = "reward",       --结算
    gameend      = "gameend",       --结束
}

mahjong_config_90.uiActionCfg.small_reward = {90, "mahjong_action_small_reward_90"}


mahjong_config_90.mahjongActionCfg.game_openGlod = {42, "mahjong_mjAction_gameOpenGlod_42"}

mahjong_config_90.stateAnimMap[MahjongGameAnimState.openGold] = {20006, mahjong_path_enum.mjCommon, "fangjin", 1}

return mahjong_config_90
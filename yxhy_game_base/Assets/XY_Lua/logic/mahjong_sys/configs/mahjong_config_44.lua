
--[[--
 * @Description: 莆田麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_44 = {}
setmetatable(mahjong_config_44, {__index = config_common})

mahjong_config_44.MahjongTotalCount = 112  -- 麻将总数量

mahjong_config_44.wallDunCountMap = 
{
	14,14,14,14
}

mahjong_config_44.game_state = {
    none         = "none",
    prepare      = "prepare",        --开始
    banker       = "banker",          --定庄
    deal         = "deal",               --抓牌
    opengold     = "opengold",         --开金
    round        = "round",        --游戏阶段
    reward       = "reward",       --结算
    gameend      = "gameend",       --结束
}

mahjong_config_44.uiActionCfg.small_reward = {44, "mahjong_action_small_reward_44"}
mahjong_config_44.uiActionCfg.game_tingType = {0,"mahjong_action_gameTingType"}
mahjong_config_44.uiActionCfg.game_youjin_count = {44,"mahjong_action_gameYouJinCount"}


mahjong_config_44.mahjongActionCfg.game_openGlod = {25, "mahjong_mjAction_gameOpenGlod_25"}
mahjong_config_44.mahjongActionCfg.game_playStart = {40,"mahjong_mjAction_gamePlayStart"}

mahjong_config_44.stateAnimMap[MahjongGameAnimState.openGold] = {20006, mahjong_path_enum.mjCommon, "fangjin", 1}

mahjong_config_44.stateAnimList = {
	MahjongGameAnimState.start,
	MahjongGameAnimState.openGold,
	MahjongGameAnimState.none,
}

return mahjong_config_44
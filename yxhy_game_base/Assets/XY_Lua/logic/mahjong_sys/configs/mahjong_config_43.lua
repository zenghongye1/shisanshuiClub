
--[[--
 * @Description: 三明麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_43 = {}
setmetatable(mahjong_config_43, {__index = config_common})



mahjong_config_43.game_state = {
    none         = "none",
    prepare      = "prepare",        --开始
    banker       = "banker",          --定庄
    deal         = "deal",               --抓牌
    opengold     = "opengold",         --开金
    round        = "round",        --游戏阶段
    reward       = "reward",       --结算
    gameend      = "gameend",       --结束
}

mahjong_config_43.uiActionCfg.small_reward = {43, "mahjong_action_small_reward_43"}
mahjong_config_43.uiActionCfg.game_followBanker = {26,"mahjong_action_game_followBanker"}
mahjong_config_43.uiActionCfg.game_treePeng = {43,"mahjong_action_game_threePeng"}
mahjong_config_43.uiActionCfg.game_tingType = {0,"mahjong_action_gameTingType"}


mahjong_config_43.mahjongActionCfg.game_openGlod = {18, "mahjong_mjAction_gameOpenGlod_18"}


mahjong_config_43.stateAnimMap[MahjongGameAnimState.openGold] = {20006, mahjong_path_enum.mjCommon, "fangjin", 1}


return mahjong_config_43
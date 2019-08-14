
--[[--
 * @Description: 龙岩麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_41 = {}
setmetatable(mahjong_config_41, {__index = config_common})

mahjong_config_41.game_state = {
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

mahjong_config_41.uiActionCfg.small_reward = {41, "mahjong_action_small_reward_41"}
mahjong_config_41.uiActionCfg.account_update = {20, "mahjong_action_account_update_20"}
mahjong_config_41.uiActionCfg.game_youStatus = {20,"mahjong_action_gameYouStatus"}
mahjong_config_41.uiActionCfg.game_followBanker = {26,"mahjong_action_game_followBanker"}


mahjong_config_41.mahjongActionCfg.game_openGlod = {41, "mahjong_mjAction_gameOpenGlod_41"}


mahjong_config_41.stateAnimMap[MahjongGameAnimState.openGold] = {20006, mahjong_path_enum.mjCommon, "fangjin", 1}

mahjong_config_41.GetReplaceSpecialCardValue = function () return 37 end

return mahjong_config_41
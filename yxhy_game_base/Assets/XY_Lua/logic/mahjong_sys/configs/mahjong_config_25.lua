
--[[--
 * @Description: 厦门麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_25 = {}
setmetatable(mahjong_config_25, {__index = config_common})



mahjong_config_25.game_state = {
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

mahjong_config_25.uiActionCfg.small_reward = {25, "mahjong_action_small_reward_25"}
mahjong_config_25.uiActionCfg.account_update = {25, "mahjong_action_account_update_25"}
mahjong_config_25.uiActionCfg.game_youStatus = {20,"mahjong_action_gameYouStatus"}



mahjong_config_25.mahjongActionCfg.game_openGlod = {25, "mahjong_mjAction_gameOpenGlod_25"}


mahjong_config_25.stateAnimMap[MahjongGameAnimState.openGold] = {20006, mahjong_path_enum.mjCommon, "fangjin", 1}

mahjong_config_25.GetReplaceSpecialCardValue = function () return 37 end

return mahjong_config_25
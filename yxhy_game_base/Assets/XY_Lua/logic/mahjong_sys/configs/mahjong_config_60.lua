
--[[--
 * @Description: 大溪麻将玩法配置
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_60 = {}
setmetatable(mahjong_config_60, {__index = config_common})

mahjong_config_60.game_state = {
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

mahjong_config_60.uiActionCfg.small_reward = {60, "mahjong_action_small_reward_60"}
mahjong_config_60.uiActionCfg.account_update = {25, "mahjong_action_account_update_25"}
mahjong_config_60.uiActionCfg.game_youStatus = {20,"mahjong_action_gameYouStatus"}

mahjong_config_60.mahjongActionCfg.game_openGlod = {26, "mahjong_mjAction_gameOpenGlod_26"}

mahjong_config_60.stateAnimMap[MahjongGameAnimState.openGold] = {20006, mahjong_path_enum.mjCommon, "fangjin", 1}

mahjong_config_60.GetReplaceSpecialCardValue = function () return 37 end

return mahjong_config_60
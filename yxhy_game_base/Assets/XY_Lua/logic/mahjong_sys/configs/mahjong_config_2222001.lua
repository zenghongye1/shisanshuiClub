
--[[--
 * @Description: 松原麻将玩法配置
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_2222001 = {}
setmetatable(mahjong_config_2222001, {__index = config_common})

mahjong_config_2222001.MahjongTotalCount = 112  -- 麻将总数量

mahjong_config_2222001.wallDunCountMap = 
{
	14,14,14,14
}

mahjong_config_2222001.game_state = {
    none         = "none",
    prepare      = "prepare",        --开始
    banker       = "banker",          --定庄
    deal         = "deal",               --抓牌
    round        = "round",        --游戏阶段
    reward       = "reward",       --结算
    gameend      = "gameend",       --结束
}

mahjong_config_2222001.uiActionCfg.small_reward = {2222001, "mahjong_action_small_reward_2222001"}
mahjong_config_2222001.uiActionCfg.game_askBlock = {2222001, "mahjong_action_gameAskBlock"}
mahjong_config_2222001.uiActionCfg.game_baoInfo = {2222001, "mahjong_action_gameBaoInfo"}

return mahjong_config_2222001
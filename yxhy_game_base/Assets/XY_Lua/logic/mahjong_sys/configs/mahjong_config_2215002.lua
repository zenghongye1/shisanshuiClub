
--[[--
 * @Description: 兴安盟麻将玩法配置
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_2215002 = {}
setmetatable(mahjong_config_2215002, {__index = config_common})

mahjong_config_2215002.MahjongTotalCount = 120  -- 麻将总数量

mahjong_config_2215002.wallDunCountMap = 
{
	15,15,15,15
}

mahjong_config_2215002.game_state = {
    none         = "none",
    prepare      = "prepare",        --开始
    banker       = "banker",          --定庄
    deal         = "deal",               --抓牌
    round        = "round",        --游戏阶段
    reward       = "reward",       --结算
    gameend      = "gameend",       --结束
}

mahjong_config_2215002.uiActionCfg.small_reward = {2215002, "mahjong_action_small_reward_2215002"}

mahjong_config_2215002.uiActionCfg.game_askBlock = {2215002,"mahjong_action_gameAskBlock"}

return mahjong_config_2215002
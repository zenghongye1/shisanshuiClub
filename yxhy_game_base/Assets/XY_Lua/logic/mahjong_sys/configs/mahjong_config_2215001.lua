
--[[--
 * @Description: 通辽麻将玩法配置
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_2215001 = {}
setmetatable(mahjong_config_2215001, {__index = config_common})

mahjong_config_2215001.MahjongTotalCount = 120  -- 麻将总数量

mahjong_config_2215001.wallDunCountMap = 
{
	15,15,15,15
}

mahjong_config_2215001.game_state = {
    none         = "none",
    prepare      = "prepare",        --开始
    banker       = "banker",          --定庄
    deal         = "deal",               --抓牌
    round        = "round",        --游戏阶段
    reward       = "reward",       --结算
    gameend      = "gameend",       --结束
}

mahjong_config_2215001.uiActionCfg.game_tingType = {2215001,"mahjong_action_gameTingType"}
mahjong_config_2215001.uiActionCfg.small_reward = {2215001, "mahjong_action_small_reward_2215001"}

mahjong_config_2215001.uiActionCfg.buySelfdraw = {2215001, "mahjong_action_buySelfdraw"}
mahjong_config_2215001.uiActionCfg.buySelfdrawResult = {2215001, "mahjong_action_buySelfdrawResult"}
mahjong_config_2215001.uiActionCfg.game_askBlock = {2215001,"mahjong_action_gameAskBlock"}


return mahjong_config_2215001
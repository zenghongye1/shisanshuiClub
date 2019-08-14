
--[[--
 * @Description: 贵阳捉鸡麻将玩法配置
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_2252001 = {}
setmetatable(mahjong_config_2252001, {__index = config_common})

mahjong_config_2252001.MahjongTotalCount = 108  -- 麻将总数量

mahjong_config_2252001.wallDunCountMap = 
{
	14,14,13,13
}

mahjong_config_2252001.game_state = {
    none         = "none",
    prepare      = "prepare",        --开始
    banker       = "banker",          --定庄
    deal         = "deal",               --抓牌
    round        = "round",        --游戏阶段
    reward       = "reward",       --结算
    gameend      = "gameend",       --结束
}

mahjong_config_2252001.uiActionCfg.small_reward = {2252001, "mahjong_action_small_reward_2252001"}
-- mahjong_config_2252001.uiActionCfg.game_tingType = {2242001,"mahjong_action_gameTingType"}
-- mahjong_config_2252001.uiActionCfg.game_ting = {2242001,"mahjong_action_gameTing"}
mahjong_config_2252001.uiActionCfg.game_askBlock = {2252001,"mahjong_action_gameAskBlock"}
-- mahjong_config_2252001.uiActionCfg.buycode = {2242001, "mahjong_action_buycode"}
mahjong_config_2252001.uiActionCfg.game_jiType = {2252001,"mahjong_action_gameJiType"}

return mahjong_config_2252001
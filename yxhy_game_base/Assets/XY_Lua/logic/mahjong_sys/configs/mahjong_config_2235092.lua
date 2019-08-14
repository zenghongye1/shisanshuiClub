
--[[--
 * @Description: 仙游麻将玩法配置
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_2235092 = {}
setmetatable(mahjong_config_2235092, {__index = config_common})

mahjong_config_2235092.MahjongTotalCount = 112  -- 麻将总数量

mahjong_config_2235092.wallDunCountMap = 
{
	14,14,14,14
}

mahjong_config_2235092.game_state = {
    none         = "none",
    prepare      = "prepare",        --开始
    banker       = "banker",          --定庄
    deal         = "deal",               --抓牌
    opengold     = "opengold",         --开金
    round        = "round",        --游戏阶段
    reward       = "reward",       --结算
    gameend      = "gameend",       --结束
}

mahjong_config_2235092.uiActionCfg.small_reward = {2235092, "mahjong_action_small_reward_2235092"}
mahjong_config_2235092.uiActionCfg.game_youStatus = {20,"mahjong_action_gameYouStatus"}


mahjong_config_2235092.mahjongActionCfg.game_openGlod = {2235092, "mahjong_mjAction_gameOpenGlod_2235092"}
mahjong_config_2235092.mahjongActionCfg.game_playStart = {40,"mahjong_mjAction_gamePlayStart"}
mahjong_config_2235092.stateAnimMap[MahjongGameAnimState.openGold] = {20006, mahjong_path_enum.mjCommon, "fangjin", 1}

mahjong_config_2235092.GetReplaceSpecialCardValue = function () 
	if roomdata_center.gamesetting.nSupportBaiStyle and roomdata_center.gamesetting.nSupportBaiStyle == 2 then
		return 37 
	else
		return 0 
	end
end

return mahjong_config_2235092
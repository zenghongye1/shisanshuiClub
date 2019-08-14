
--[[--
 * @Description: 福鼎麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_45 = {}
setmetatable(mahjong_config_45, {__index = config_common})



mahjong_config_45.game_state = {
    none         = "none",
    prepare      = "prepare",        --开始
    banker       = "banker",          --定庄
    deal         = "deal",               --抓牌
    opengold     = "opengold",         --开金
    changeflower = "changeflower",      --补花
    round        = "round",        --游戏阶段
    reward       = "reward",       --结算
    gameend      = "gameend",       --结束
}

mahjong_config_45.mahjongSyncGameState = 
{
    reward = 0,  --结算阶段 
    gameend = 100, --结束阶段
    prepare = 200, --准备阶段
    xiapao = 300, -- 下跑  发牌之前显示
    deal = 400,  -- 发牌
    laizi = 500, --癞子
    opengold = 520, -- 开金
    changeflower = 530, -- 补花
    round = 600, -- 出牌阶段
}

mahjong_config_45.uiActionCfg.small_reward = {45, "mahjong_action_small_reward_45"}


mahjong_config_45.mahjongActionCfg.game_setWind = {45, "mahjong_action_gameSetWind"}
mahjong_config_45.mahjongActionCfg.game_openGlod = {45, "mahjong_mjAction_gameOpenGlod_45"}
mahjong_config_45.mahjongActionCfg.game_playStart = {40,"mahjong_mjAction_gamePlayStart"}

mahjong_config_45.stateAnimList = {
	MahjongGameAnimState.start,
	MahjongGameAnimState.openGold,
	MahjongGameAnimState.changeFlower,
	MahjongGameAnimState.grabGold,
	MahjongGameAnimState.none,
}


mahjong_config_45.stateAnimMap[MahjongGameAnimState.openGold] = {20006, mahjong_path_enum.mjCommon, "fangjin", 1}

mahjong_config_45.GetSpecialCardValue = function (value) 
	if MahjongTools.IsSeason(value) then
        return {41,42,43,44}
    elseif MahjongTools.IsFlower(value) then
        return {45,46,47,48}
    else
        return value
    end
end


return mahjong_config_45
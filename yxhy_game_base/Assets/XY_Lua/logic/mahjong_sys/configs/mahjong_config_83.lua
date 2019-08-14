
--[[--
 * @Description: 河北张家口麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_83 = {}
setmetatable(mahjong_config_83, {__index = config_common})

mahjong_config_83.MahjongDunCount = 14				-- 一排多少墩
mahjong_config_83.MahjongTotalCount = 108  -- 麻将总数量

mahjong_config_83.ignoreEffect = {
	[13] = true,
	[15] = true,
	[16] = true,
	[17] = true,
	[18] = true,
	[19] = true,
	[20] = true,
	[24] = true,
	[26] = true,
	[36] = true,
}


mahjong_config_83.wallDunCountMap = 
{
	14,14,14,14
}

mahjong_config_83.big_settlement_show = {}
mahjong_config_83.big_settlement_show.win_type = {
	["selfdraw"] = "selfdraw", 		-- 自摸
	["gunwin"] = "gunwin", 		-- 点炮
	["gangflower"] = "gangflower", 	-- 杠上花
	["huangpai"] = "huangpai", -- 荒庄
}

mahjong_config_83.beishu_wintype_dic = 
{
	["nSelfDraw"] = 2,
	["nGun"] = 1,
}

mahjong_config_83.big_settlement_show.byFanType = {
	"gunwin", -- 点炮
	"selfdraw", -- 自摸
	"nQiDui", -- 七对胡
	"nGangFlower", -- 杠上花
	"nGangGun",--杠上炮
    "nDragon",
    "nQinYise",
    "nShiSanYao",
    "nHQidui",
    "nPengPengHu",--碰碰胡
    "nWukui",--捉五魁
	"conceled_gang_count", -- 暗杠
	"revealed_gang_count", -- 明杠 
}

mahjong_config_83.big_settlement_mustShow = 
{
	"selfdraw",
	"gunwin",
}


mahjong_config_83.mahjongActionCfg.game_playStart = {15, "mahjong_mjAction_gamePlayStart"}
mahjong_config_83.uiActionCfg.game_askBlock = {15,"mahjong_action_gameAskBlock"}
mahjong_config_83.uiActionCfg.small_reward = {83, "mahjong_action_small_reward_83"} 
mahjong_config_83.uiActionCfg.total_reward = {0, "mahjong_action_totalreward"}
mahjong_config_83.mahjongActionCfg.game_askPlay = {8, "mahjong_mjAction_gameAskPlay"}

return mahjong_config_83
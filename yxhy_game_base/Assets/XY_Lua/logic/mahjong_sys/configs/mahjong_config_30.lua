
--[[--
 * @Description: 周口麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_30 = {}
setmetatable(mahjong_config_30, {__index = config_common})

mahjong_config_30.wallDunCountMap = 
{
	17,17,17,17
}

mahjong_config_30.beishu_wintype_dic = 
{
	["gangflower"] = {"bSupportGangFlowAdd", {2, 4}},
}

mahjong_config_30.beishu_wininfo_dic = 
{
	{"bSupportSevenDoubleAdd", "nQiDui", 4, 2},
	{"bQiangGangAdd", "nQiangGang", 15, 2},
	{"bFourHunAdd", "nHunHu", 57, 2},
	{"bWindDrawAdd", "bWindDraw", 58, 0},
	{"bMissHuAdd", "bMissHu", 59, 0},
	{"bDanDiaoAddScore", "bDanDiaoHu", 60, 0},
}

--[[function mahjong_config_30:SetMahjongTotalCount(hasWind)
	if not hasWind then
		mahjong_config_30.MahjongTotalCount = 136 - 28
	end
end]]

--[[function mahjong_config_30:SetWallDunCount(hasWind, zhuangViewSeat)
	if not hasWind then
	    for i=1, #mahjong_config_30.wallDunCountMap do                
	       if (i == zhuangViewSeat+1) or (i == (zhuangViewSeat+2)%4) then
	        mahjong_config_30.wallDunCountMap[i] = mahjong_config_30.wallDunCountMap[i] - 3
	       else 
	        mahjong_config_30.wallDunCountMap[i] = mahjong_config_30.wallDunCountMap[i] - 4
	       end
	    end	
	end
end]]



--mahjong_config_30.uiActionCfg.getBigSettlementData = {8, "mahjong_action_getBigSettlementData_8"}
mahjong_config_30.uiActionCfg.small_reward = {30, "mahjong_action_small_reward_30"}

mahjong_config_30.mahjongActionCfg.game_askPlay = {8, "mahjong_mjAction_gameAskPlay"}
mahjong_config_30.mahjongActionCfg.game_playStart = {8, "mahjong_mjAction_gamePlayStart"}
mahjong_config_30.mahjongActionCfg.game_laiZi = {8, "mahjong_mjAction_gameLaiZi"}

return mahjong_config_30

--[[--
 * @Description: 南阳麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_29 = {}
setmetatable(mahjong_config_29, {__index = config_common})

mahjong_config_29.wallDunCountMap = 
{
	17,17,17,17
}

mahjong_config_29.beishu_wintype_dic = 
{	
	["gangflower"] = {"bSupportGangFlowAdd", {1, 2}},
}

mahjong_config_29.beishu_wininfo_dic = 
{
	{"bSupportSevenDoubleAdd", "nQiDui", 4, 2},
	{"bQiangGangAdd", "nQiangGang", 15, 2},
	{"bSuHuAdd", "nSuHu", 37, 2},
	{"bKaWuAdd", "nWukui", 56, 4},
	{"bFourHunAdd", "nHunHu", 57, 4},
	{"bWindDrawAdd", "bWindDraw", 58, 0},
	{"bMissHuAdd", "bMissHu", 59, 0},
	{"bDanDiaoAddScore", "bDanDiaoHu", 60, 0},
}


--[[function mahjong_config_29:SetMahjongTotalCount(hasWind)
	if not hasWind then
		mahjong_config_29.MahjongTotalCount = 136 - 28
	end
end

function mahjong_config_29:SetWallDunCount(hasWind, zhuangViewSeat)
	if not hasWind then
	    for i=1, #mahjong_config_29.wallDunCountMap do                
	       if (i == zhuangViewSeat+1) or (i == (zhuangViewSeat+2)%4) then
	        mahjong_config_29.wallDunCountMap[i] = mahjong_config_29.wallDunCountMap[i] - 3
	        Trace("mahjong_config_29.wallDunCountMap[i]--------------------"..tostring(mahjong_config_29.wallDunCountMap[i]))
	       else 
	        mahjong_config_29.wallDunCountMap[i] = mahjong_config_29.wallDunCountMap[i] - 4
	        Trace("mahjong_config_29.wallDunCountMap[i]--------------------"..tostring(mahjong_config_29.wallDunCountMap[i]))
	       end
	    end	
	end
end
]]



--mahjong_config_29.uiActionCfg.getBigSettlementData = {8, "mahjong_action_getBigSettlementData_8"}
mahjong_config_29.uiActionCfg.small_reward = {29, "mahjong_action_small_reward_29"}

mahjong_config_29.mahjongActionCfg.game_askPlay = {8, "mahjong_mjAction_gameAskPlay"}
mahjong_config_29.mahjongActionCfg.game_playStart = {8, "mahjong_mjAction_gamePlayStart"}

mahjong_config_29.mahjongActionCfg.game_laiZi = {8, "mahjong_mjAction_gameLaiZi"}

return mahjong_config_29
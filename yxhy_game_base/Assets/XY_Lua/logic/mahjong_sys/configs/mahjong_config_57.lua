
--[[--
 * @Description: 商丘麻将玩法配置
 * @FileName:    play_mode_config_fuzhou.lua
 ]]
local config_common = require "logic/mahjong_sys/configs/mahjong_config_common":create()

local mahjong_config_57 = {}
setmetatable(mahjong_config_57, {__index = config_common})

mahjong_config_57.wallDunCountMap = 
{
	18,18,18,18
}

mahjong_config_57.MahjongTotalCount=144
function mahjong_config_57:SetMahjongTotalCount(hasWind)
	if not hasWind then
		self.MahjongTotalCount = 144 - 28
	else
		self.MahjongTotalCount = 144 
	end
end
function mahjong_config_57:SetWallDunCount(hasWind, p1Seat)
	if not hasWind then		
	    for i=1, #self.wallDunCountMap do  
	    	local p2Seat = p1Seat+1
	    	if p2Seat > 4 then
	    		p2Seat = p2Seat%4
	    	end

	       if (i == p1Seat) or (i == p2Seat) then	       	
	        self.wallDunCountMap[i] = 18 - 3
	       else 
	        self.wallDunCountMap[i] = 18 - 4
	       end
	    end	
	else
		self.wallDunCountMap = {18, 18, 18, 18}
	end
end

mahjong_config_57.uiActionCfg.game_askBlock = {57,"mahjong_action_gameAskBlock"}
mahjong_config_57.uiActionCfg.small_reward = {57, "mahjong_action_small_reward_57"}

mahjong_config_57.mahjongActionCfg.game_askPlay = {8, "mahjong_mjAction_gameAskPlay"}
mahjong_config_57.mahjongActionCfg.game_setting = {57, "mahjong_mjAction_gameSetting"}
mahjong_config_57.mahjongActionCfg.game_playStart = {40, "mahjong_mjAction_gamePlayStart"}
mahjong_config_57.mahjongActionCfg.game_laiZi = {8, "mahjong_mjAction_gameLaiZi"}

return mahjong_config_57
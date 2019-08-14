-- 初始化特殊玩法设置
local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameSetting_91 = class("mahjong_action_gameSetting_91", base)

function mahjong_action_gameSetting_91:Execute()
	local nFlower = roomdata_center.gamesetting.nFlower
	if nFlower then
		self.config.MahjongTotalCount = self.config.MahjongBaseCount + tonumber(nFlower)
		local baseDun = math.floor(self.config.MahjongTotalCount/8)
		local leftDun = (self.config.MahjongTotalCount - baseDun*8)/2
		for i=1,4 do
			if i<=leftDun then
				self.config.wallDunCountMap[i] = baseDun + 1
			else
				self.config.wallDunCountMap[i] = baseDun
			end
		end
	end
end

return mahjong_action_gameSetting_91
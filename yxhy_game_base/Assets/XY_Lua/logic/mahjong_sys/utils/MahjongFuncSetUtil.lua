MahjongFuncSetUtil = {}


-- 获取发牌位置
function MahjongFuncSetUtil.GetSendIndexNormal(dun, viewSeat, config)
	local wallCounts = config.wallDunCountMap
	local fontCount = 0
	for i=1,viewSeat-1 do
		fontCount = fontCount + wallCounts[i] * 2
	end
	return dun * 2 + fontCount --发牌位置
end








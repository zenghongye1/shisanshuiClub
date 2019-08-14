local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameYouJinCount = class("mahjong_action_gameYouJinCount", base)

function mahjong_action_gameYouJinCount:Execute(tbl)
	local nCount = tbl._para.nCount
	local nChair = tbl._para.nChair
	local viewSeat = self.gvblnFun(nChair)
	mahjong_ui:SetYoustatus(viewSeat,20013)
end


return mahjong_action_gameYouJinCount
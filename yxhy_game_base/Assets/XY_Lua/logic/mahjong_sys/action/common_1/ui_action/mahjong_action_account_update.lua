-- 通用分数刷新

local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_account_update = class("mahjong_action_account_update", base)




function mahjong_action_account_update:Execute(tbl)
	local scores = tbl._para.totalscore
	for i = 1, #scores do
		local viewSeat = self.gvblnFun(i)
		mahjong_ui:SetPlayerScore(viewSeat, scores[i])
	end
end

return mahjong_action_account_update
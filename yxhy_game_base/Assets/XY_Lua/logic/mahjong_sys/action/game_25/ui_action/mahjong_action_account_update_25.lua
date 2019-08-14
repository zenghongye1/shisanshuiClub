-- 通用分数刷新

local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_account_update_25 = class("mahjong_action_account_update_25", base)


local animations_sys = animations_sys
local roomdata_center = roomdata_center


function mahjong_action_account_update_25:Execute(tbl)
	local gvbln = player_seat_mgr.GetViewSeatByLogicSeatNum
	local scores = tbl._para.totalscore
	for i = 1, #scores do
		local viewSeat = gvbln(i)
		mahjong_ui:SetPlayerScore(viewSeat, scores[i])
	end

	if roomdata_center.bSupportKe then
		local loseNum = 0
		for i,v in ipairs(scores) do
			if tonumber(v) <= 0 then
				loseNum = loseNum + 1
			end
		end

		if loseNum >0 then
			roomdata_center.keEnd = true
		end
	end
end

return mahjong_action_account_update_25
local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_follow_banker_15 = class("mahjong_action_follow_banker_15", base)

function mahjong_action_follow_banker_15:Execute(tbl)
	Trace(GetTblData(tbl))
	local para = tbl._para
	local followNum = para.followNum or 0
	mahjong_ui:ShowGenZhuang(followNum)
end

return mahjong_action_follow_banker_15
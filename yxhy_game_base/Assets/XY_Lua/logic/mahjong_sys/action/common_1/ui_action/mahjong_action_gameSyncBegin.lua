local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameSyncBegin = class("mahjong_action_gameSyncBegin", base)



function mahjong_action_gameSyncBegin:Execute(tbl)
	Trace(GetTblData(tbl))
	Trace("重连同步开始")
	if mahjong_ui.voteView ~= nil then
		mahjong_ui.voteView:Hide()
	end
	
end

return mahjong_action_gameSyncBegin
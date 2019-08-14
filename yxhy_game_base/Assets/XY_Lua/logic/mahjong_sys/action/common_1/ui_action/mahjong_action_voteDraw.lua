
local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_voteDraw = class("mahjong_action_voteDraw", base)



function mahjong_action_voteDraw:Execute(tbl)
	local viewSeat = self.gvblFun(tbl["_src"])
	--[[local st = tbl["_st"]
	if tostring(st) == "err" then
		local errno = tbl["_para"]["_errno"]
		if tonumber(errno) == 5001 then
			--请求次数太过多
			UI_Manager:Instance():FastTip("解散功能时间冷却中，请稍后再试.")
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F1_VOTE_DRAW)
			return
		elseif tonumber(errno) == 5002 then
			UI_Manager:Instance():FastTip("等待牌局结束后，房间将会解散.")
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F1_VOTE_DRAW)
			return
		elseif tonumber(errno) == 5003 then
			UI_Manager:Instance():FastTip("投票正在进行中，请稍后再试.")
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F1_VOTE_DRAW)
			return
		end
	end--]]
	Notifier.dispatchCmd(GameEvent.OnAddVote, tbl._para.accept, viewSeat)
	mahjong_ui.voteView:AddVote(tbl._para.accept, viewSeat)
	if viewSeat == 1 and tbl._para.accept then
		UI_Manager:Instance():CloseUiForms("VoteQuitUI")
	end
end

return mahjong_action_voteDraw
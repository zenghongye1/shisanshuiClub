
local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_voteEnd = class("mahjong_action_voteEnd", base)



function mahjong_action_voteEnd:Execute(tbl)
	local confirm = tbl._para.confirm
	if confirm == false and roomdata_center.isSelfVote == true then
		MessageBox.ShowSingleBox(LanguageMgr.GetWord(6048))
	end
	roomdata_center.isSelfVote = false
	UI_Manager:Instance():CloseUiForms("VoteQuitUI")
	mahjong_ui.voteView:Hide()
end

return mahjong_action_voteEnd
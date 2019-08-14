local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameBanker = class("mahjong_action_gameBanker", base)



function mahjong_action_gameBanker:Execute(tbl)
	local viewSeat = self.gvblnFun(tbl["_para"]["banker"])
	roomdata_center.zhuang_viewSeat = viewSeat
	mahjong_ui:SetBanker(viewSeat)
	local lianZhuang = tbl["_para"]["lianZhuang"]
	mahjong_ui:SetLianZhuang(viewSeat,lianZhuang)

	ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("zhuang"))
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_BANKER)
end

return mahjong_action_gameBanker
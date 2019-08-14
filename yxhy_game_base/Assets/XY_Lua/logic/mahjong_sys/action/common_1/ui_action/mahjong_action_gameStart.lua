local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameStart = class("mahjong_action_gameStart", base)



function mahjong_action_gameStart:Execute(tbl)
	roomdata_center.ClearData()
	roomdata_center.isStart = true
	roomdata_center.isTing=false
	roomdata_center.isRoundStart = true
	ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("duijukaishi"))

	mahjong_ui:ResetAll()
	mahjong_ui:HideAllReadyBtns()

	for i=1,roomdata_center.MaxPlayer() do
		mahjong_ui:SetPlayerReady(i, false)
	end

	if tbl._para.subRound then
		mahjong_ui:SetRoundInfo(tbl._para.subRound, roomdata_center.nJuNum)
	end
end

return mahjong_action_gameStart
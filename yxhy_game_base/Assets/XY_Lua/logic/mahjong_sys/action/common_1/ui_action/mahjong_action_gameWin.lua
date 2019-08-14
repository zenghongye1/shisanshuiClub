local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameWin = class("mahjong_action_gameWin", base)



function mahjong_action_gameWin:Execute(tbl)
	mahjong_ui:HideOperTips()
	local gvbln = player_seat_mgr.GetViewSeatByLogicSeatNum
	local win_type = tbl._para.stWinList[1].winType
	local stWinList = tbl._para.stWinList

	if win_type == "huangpai" then
 		mahjong_ui:ShowHuang()
 	else
 		for _,v in ipairs(stWinList) do
 			local winner = v.winner
			local win_viewSeat = gvbln(winner)
			local typeId = 9002
	 		local soundName = "hu"
	 		if win_type == "gunwin" then
	 			typeId = 9002
	 			soundName = "hu"
	 		elseif win_type == "robgangwin" then
	 			typeId = 20005
	 			soundName = "hu"
	 		elseif win_type == "selfdraw" then
	 			typeId = 9001
	 			soundName = "zimo"
	 		elseif win_type == "robgoldwin" then
	 			typeId = 9004
	 			soundName = "qiangjin"
	 		end

	 		ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjSoundPath(soundName))
	 		mahjong_effectMgr:PlayUIEffectById(typeId,mahjong_ui.playerList[win_viewSeat].operPos)
 		end
 	end
end

return mahjong_action_gameWin
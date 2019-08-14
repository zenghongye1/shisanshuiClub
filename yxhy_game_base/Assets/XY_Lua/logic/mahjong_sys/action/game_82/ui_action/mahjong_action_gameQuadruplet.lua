local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameQuadruplet = class("mahjong_action_gameQuadruplet", base)



function mahjong_action_gameQuadruplet:Execute(tbl)
	logError(json.encode(tbl))
	local operPlayViewSeat = self.gvblFun(tbl._src)
	if operPlayViewSeat ==1 then
		mahjong_ui:HideOperTips()
		--mahjong_ui:HideTingBackBtn()

		roomdata_center.CheckTingWhenGiveCard(-1)
		mahjong_ui.cardShowView:ShowHuBtn(roomdata_center.isTing)
	end
	local aninID = 20003
	if tbl._para.nbzz and tonumber(tbl._para.nbzz) ~= 0 then
		if tonumber(tbl._para.nbzz) == 1 then
			aninID = 20029
		end
	end
	mahjong_effectMgr:PlayUIEffectById(aninID,mahjong_ui.playerList[operPlayViewSeat].operPos)

end

return mahjong_action_gameQuadruplet
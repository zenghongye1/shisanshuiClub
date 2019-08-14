local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_buySelfdrawResult = class("mahjong_action_buySelfdrawResult", base)

function mahjong_action_buySelfdrawResult:Execute(tbl)
	local nBuySelfDraw = tbl._para.nBuySelfDraw
	local nChair = tbl._para.nChair
	local operPlayViewSeat = self.gvblnFun(nChair)
	if operPlayViewSeat == 1 then
		mahjong_ui:HideBuySelfdrawView()
	end
	if nBuySelfDraw == 1 then
		mahjong_effectMgr:PlayUIEffectById(20023,mahjong_ui.playerList[operPlayViewSeat].operPos)
		for i=1,roomdata_center.MaxPlayer() do
			if operPlayViewSeat ~= i then
				mahjong_ui:ShowPlayerTotalPoints(i,1)
			end
		end
		coroutine.start(function ()
			coroutine.wait(1)
			mahjong_ui:SetHideTotaPoints()
		end)	
	end
end

return mahjong_action_buySelfdrawResult
local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gamePlayCard = class("mahjong_action_gamePlayCard", base)



function mahjong_action_gamePlayCard:Execute(tbl)
	local operPlayViewSeat = self.gvblFun(tbl._src)
	if operPlayViewSeat ==1 then
		mahjong_ui:HideOperTips()
		mahjong_ui:HideTingBackBtn()
		mahjong_ui:HideKouOperTips()

		-- 胡牌提示相关处理
		-- if roomdata_center.tingType == 0 then -- 不等于0为进行报听操作，固定听牌
		-- 	local paiValue = tbl._para.cards[1]
		-- 	roomdata_center.CheckTingWhenGiveCard(paiValue)
		-- 	mahjong_ui.cardShowView:ShowHuBtn(roomdata_center.isTing)
		-- else
		-- 	roomdata_center.CheckTingWhenGiveCard(-1)
		-- 	mahjong_ui.cardShowView:ShowHuBtn(roomdata_center.isTing)
		-- end
		local paiValue = tbl._para.cards[1]
		roomdata_center.curFilterCards = {}
		roomdata_center.CheckTingWhenGiveCard(paiValue)
		mahjong_ui.cardShowView:ShowHuBtn(roomdata_center.isTing)
	end
end

return mahjong_action_gamePlayCard
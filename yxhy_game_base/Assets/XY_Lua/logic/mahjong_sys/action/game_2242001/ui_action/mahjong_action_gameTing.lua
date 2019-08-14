local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameTing = class("mahjong_action_gameTing", base)



function mahjong_action_gameTing:Execute(tbl)
	local player = self.compPlayerMgr:GetPlayer(1)
	if tbl then
		if not player.canOutCard then
			mahjong_ui:HideOperTips()
			return
		end
		-- 可以扣牌
		if tbl.turnCard and #tbl.turnCard > 0 then
			mahjong_ui:ShowKouOperTips()
			mahjong_ui:HideOperTips()
			mahjong_ui.cardShowView:ShowKou(tbl.turnCard)
			player:HideTingInHand()
			player:SetAllHandCardDisable()
		else
			mahjong_ui:ShowTingBackBtn()
			mahjong_ui:HideOperTips()

			local data = {}
			data._para = {}
			data._para.stTingCards = tbl.tingInfo
			roomdata_center.SetHintInfoMap(data)
			roomdata_center.tingType = tbl.tingType

			player:ShowTingInHand()
			local stTingCards = tbl.tingInfo
	        local filterCards = self:GetFilterCards(player.handCardList,stTingCards)
	        player:SetDisableCardShow(self.cfg.showTingDisableCard)
	        player:SetCanOut(true, filterCards,true)
	    end
	else
		mahjong_ui:HideTingBackBtn()
		mahjong_ui:ShowOperTips()

		roomdata_center.CheckTingWhenGiveCard(-1)
  		roomdata_center.tingType = 0
  		roomdata_center.kouCardList = nil

		player:HideTingInHand()
		player:SetCanOut(true,roomdata_center.curFilterCards)
	end
end

function mahjong_action_gameTing:GetFilterCards( handCardList,stTingCards )
	local filterCards = {}
    for _,v in ipairs(handCardList) do
    	local isTing = true
    	for _,u in ipairs(stTingCards) do
    		if v.paiValue == u.give then
    			isTing = false
    			break
    		end
    	end
    	if isTing then
    		table.insert(filterCards,v.paiValue)
    	end
    end
    return filterCards
end

return mahjong_action_gameTing
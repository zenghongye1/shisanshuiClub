local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameTingType = class("mahjong_action_gameTingType", base)

function mahjong_action_gameTingType:Execute(tbl)
	 local tingType = tbl._para.tingType
	 local tingChair = tbl._para.tingChair
	 local turnCard = tbl._para.turnCard
	 local handCard = tbl._para.handCard
	 local operPlayViewSeat = self.gvblnFun(tingChair)

	 local aniId = 20004
	 if self.cfg.tingTypeMap[tingType] then
		aniId = self.cfg.tingTypeMap[tingType][2]
	end
	 if not roomdata_center.IsPlayerTing(operPlayViewSeat) then
	 	mahjong_ui:SetYoustatus(operPlayViewSeat,aniId) -- 20024
	 end

	 roomdata_center.tingPlayerSign[tingChair] = true

 	if tingChair == player_seat_mgr.GetMyLogicSeat() then
 		roomdata_center.tingType = tingType
    	roomdata_center.isTing=true   
 		local player = self.compPlayerMgr:GetPlayer(1)
    	self.compPlayerMgr.selfPlayer:SetDisableCardShow(self.cfg.showTingDisableCard)
 		player:SetCanOut(false, self:GetFilterCards(player.handCardList))
        if player:IsRoundSendCard(#player.handCardList) then 
            if player.handCardList[#player.handCardList]~=nil  then   
               player.handCardList[#player.handCardList]:SetDisable(false)     
            end  
	 	end
	 	player:SetKouInHand(turnCard)
	 else
	 	-- 处理亮倒
	 	self.compPlayerMgr:GetPlayer(operPlayViewSeat):SetShowAndNotShowCards(handCard, turnCard)
	end
end

function mahjong_action_gameTingType:GetFilterCards( handCardList )
	local filterCards = {}
    for _,v in ipairs(handCardList) do
    	table.insert(filterCards,v.paiValue)
    end
    return filterCards
end

return mahjong_action_gameTingType
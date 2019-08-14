local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameTingType = class("mahjong_action_gameTingType", base)

function mahjong_action_gameTingType:Execute(tbl)
	local tingType = tbl._para.tingType
	local tingChair = tbl._para.tingChair
	local handCard = tbl._para.handCard
	local operPlayViewSeat = self.gvblnFun(tingChair)

	roomdata_center.tingPlayerSign[tingChair] = true
	local aniId = 20004
	if self.cfg.tingTypeMap[tingType] then
		aniId = self.cfg.tingTypeMap[tingType][2]
	end
	if roomdata_center.bSupportMT then
		aniId = 20030
		if tingChair == player_seat_mgr.GetMyLogicSeat() then
			roomdata_center.tingType = tingType
			roomdata_center.isTing = true
			local player = self.compPlayerMgr:GetPlayer(1)
			self.compPlayerMgr.selfPlayer:SetDisableCardShow(self.cfg.showTingDisableCard)
			player:SetCanOut(false,self:GetFilterCards(player.handCardList))
			if player:IsRoundSendCard(#player.handCardList) then
				if player.IsRoundSendCard[#player.handCardList] ~= nil then
					player.handCardList[#player.handCardList]:SetDisable(false)
				end
			end
		else
			local clientTingType = MahjongOperTipsEnum.MT
		 	local operData = operatordata:New(clientTingType,nil, handCard)
		 	self.compPlayerMgr:GetPlayer(operPlayViewSeat):OperateCard(operData)
		end

		mahjong_ui:SetYoustatus(operPlayViewSeat,aniId)
		return
	end


	 -- 待处理，倒牌听
	if tingType == 8 then
	 	if tingChair == player_seat_mgr.GetMyLogicSeat() then
		 	roomdata_center.tingType = tingType
	        roomdata_center.isTing=true   
	    end
	 	local callback = function ()
			mahjong_ui:SetYoustatus(operPlayViewSeat,aniId)         				
		end

		local noDownCardIndex = {}
		if table.getn(handCard) % 3  == 2 then --	还没有出牌
			table.insert(noDownCardIndex ,table.getn(handCard))
		end
        self.compPlayerMgr:GetPlayer(operPlayViewSeat):ShowTingCards(handCard, callback, 1,noDownCardIndex)
        return
    end

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
	end
	mahjong_ui:SetYoustatus(operPlayViewSeat,aniId)
end

function mahjong_action_gameTingType:GetFilterCards( handCardList )
	local filterCards = {}
    for _,v in ipairs(handCardList) do
    	table.insert(filterCards,v.paiValue)
    end
    return filterCards
end

return mahjong_action_gameTingType
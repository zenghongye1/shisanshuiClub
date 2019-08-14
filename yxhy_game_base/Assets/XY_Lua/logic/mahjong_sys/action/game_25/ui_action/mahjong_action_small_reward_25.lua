-- 厦门麻将小结算
local base = require "logic.mahjong_sys.action.game_20/ui_action/mahjong_action_small_reward_20"
local mahjong_action_small_reward_25 = class("mahjong_action_small_reward_25", base)

function mahjong_action_small_reward_25:GetTitleInfo(data,win_type,win_viewSeat,byFanType,byFanNumber)
 	data.isWinBG = true
 	data.winViewSeat = win_viewSeat
 	if win_type == "huangpai" then
 		data.isHuang = true
		data.titleIndex = self.cfg.huangArtId
		data.isWinBG = false
	else
		if byFanType>0 then
			data.titleIndex = byFanType
			data.number = byFanNumber
		else
 			if win_type == "gunwin" then
				data.titleIndex = 0
			elseif win_type == "robgoldwin" then
				data.titleIndex = 31
				data.number = 2
			else
				data.titleIndex = 18
				data.number = 2
			end
		end
	end
	return data
end

function mahjong_action_small_reward_25:GetOperValueList( combineTile )
	local list = {}
	for i,operData in ipairs(combineTile) do
		local valueList = {}
		if operData.ucFlag == 16 then
			local cardValue1 = self:GetReplaceCard(operData.card)
            local cardValue2 = self:GetReplaceCard(cardValue1 + 1)
            local cardValue3 = self:GetReplaceCard(cardValue1 + 2)
			table.insert(valueList,operData.card)
	        table.insert(valueList,cardValue2)
	        table.insert(valueList,cardValue3)
		elseif operData.ucFlag == 17 then
			table.insert(valueList,operData.card)
	        table.insert(valueList,operData.card)
	        table.insert(valueList,operData.card)
		elseif operData.ucFlag == 18 then
			table.insert(valueList,operData.card)
	        table.insert(valueList,operData.card)
	        table.insert(valueList,operData.card)
	        table.insert(valueList,operData.card)
		elseif operData.ucFlag == 19 then
			table.insert(valueList,0)
	        table.insert(valueList,0)
	        table.insert(valueList,0)
	        table.insert(valueList,operData.card)
		elseif operData.ucFlag == 20 then
			table.insert(valueList,operData.card)
	        table.insert(valueList,operData.card)
	        table.insert(valueList,operData.card)
	        table.insert(valueList,operData.card)
	    elseif operData.ucFlag == 9 then
	    	table.insert(valueList,35)
	        table.insert(valueList,36)
	        table.insert(valueList,37)
	    else
	    	logError("not define operData.ucFlag",operData.ucFlag)
		end
		table.insert(list,valueList)
	end
	return list
end

function mahjong_action_small_reward_25:GetReplaceCard(card)
    if card == self.config.GetReplaceSpecialCardValue() and card ~= 0 then
        return roomdata_center.specialCard[1] or card
    elseif card == roomdata_center.specialCard[1] and self.config.GetReplaceSpecialCardValue() ~= 0 then
        return self.config.GetReplaceSpecialCardValue()
    else
        return card
    end
end

function mahjong_action_small_reward_25:GetHandCard(rewards,win_viewSeat,viewSeat)
	local handCards = rewards.cards
	local win_card = rewards.win_card[1]
	local win_type = rewards.win_type

	if (win_type == "selfdraw" and IsTblIncludeValue(viewSeat,win_viewSeat)) then
		local lastItem = nil
		for j,v in ipairs(handCards) do
			if v == win_card then
				lastItem = table.remove(handCards,j)
				break
			end
		end
		if lastItem == nil then
			logError("自摸手牌找不到胡的牌")
		end
		table.sort(handCards)
		-- 白板代替金
		for j=1,#handCards do
		  if handCards[j] == self.config.GetReplaceSpecialCardValue() and roomdata_center.specialCard[1] then
		      local index = j-1
		      while index > 0 and handCards[index] > roomdata_center.specialCard[1] do 
		          local temp = handCards[index]
		          handCards[index] = handCards[index+1]
		          handCards[index+1] = temp
		          index = index -1
		      end
		  end
		end
		-- 金前置
		for j=1,#handCards do
		  if roomdata_center.CheckIsSpecialCard(handCards[j]) then
		      local index = j-1
		      while index > 0 and not roomdata_center.CheckIsSpecialCard(handCards[index]) do 
		          local temp = handCards[index]
		          handCards[index] = handCards[index+1]
		          handCards[index+1] = temp
		          index = index -1
		      end
		  end
		end
		table.insert(handCards,lastItem)
	else
		table.sort(handCards)
		-- 白板代替金
		for j=1,#handCards do
		  if handCards[j] == self.config.GetReplaceSpecialCardValue() and roomdata_center.specialCard[1] then
		      local index = j-1
		      while index > 0 and handCards[index] > roomdata_center.specialCard[1] do 
		          local temp = handCards[index]
		          handCards[index] = handCards[index+1]
		          handCards[index+1] = temp
		          index = index -1
		      end
		  end
		end
		--金前置
		for j=1,#handCards do
		  if roomdata_center.CheckIsSpecialCard(handCards[j]) then
		      local index = j-1
		      while index > 0 and not roomdata_center.CheckIsSpecialCard(handCards[index]) do 
		          local temp = handCards[index]
		          handCards[index] = handCards[index+1]
		          handCards[index+1] = temp
		          index = index -1
		      end
		  end
		end
      	if IsTblIncludeValue(viewSeat,win_viewSeat) then
			table.insert(handCards,win_card)
		end
	end
	return handCards
end

function mahjong_action_small_reward_25:GetPlayerMoreInfo(playerInfo,rewards,win_type,win_viewSeat,viewSeat,isBanker)
 	playerInfo.difen = self:GetDiFen(rewards,isBanker).."底"

 	if IsTblIncludeValue(viewSeat,win_viewSeat) then
		playerInfo.pan = self:GetTotalPan(rewards).."水"
	end

 	if IsTblIncludeValue(viewSeat,win_viewSeat) then
		playerInfo.scoreItem = self:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat)
	end
 	return playerInfo
end

function mahjong_action_small_reward_25:GetDiFen(rewards,isBanker)
 	local fen = 0
 	if roomdata_center.bSupportKe then 
 		if isBanker then
 			fen = 16
 		else
 			fen = 8
 		end
 	else
 		if isBanker then
 			fen = 2
 		else
 			fen = 1
 		end
 	end
 	if isBanker and rewards.lianZhuangFan>0 then
		fen = fen * (2^(rewards.lianZhuangFan))
 	end
 	return fen
end

function mahjong_action_small_reward_25:GetTotalPan(rewards)
	local pan = 0
 	if rewards.laizi_count>0 or 
 		rewards.flowerFan>0 or 
 		rewards.nWinTripleNum>0 or 
 		rewards.nWinXuKeZi>0 or 
 		rewards.nWinZiKeZi>0 or 
 		rewards.nWinGangFan>0 or
 		rewards.nflower_flag_cxqd>0 or
 		rewards.nflower_flag_mlzj>0 then

 		if rewards.laizi_count>0 then
 			pan = pan + rewards.laizi_count
 		end
 		if rewards.flowerFan>0 and roomdata_center.bSupportKe then
 			pan = pan + rewards.flowerFan
 		end
 		if rewards.nWinTripleNum>0 and roomdata_center.bSupportKe then
 			pan = pan + rewards.nWinTripleNum
 		end
 		if rewards.nWinXuKeZi>0 and roomdata_center.bSupportKe then
 			pan = pan + rewards.nWinXuKeZi
 		end
 		if rewards.nWinZiKeZi>0 and roomdata_center.bSupportKe then
 			pan = pan + rewards.nWinZiKeZi * 2
 		end
 		if rewards.nWinGangFan>0 then
 			pan = pan + rewards.nWinGangFan
 		end
 		if rewards.nflower_flag_cxqd and rewards.nflower_flag_cxqd>0 then
 			pan = pan + rewards.nflower_flag_cxqd
 		end
 		if rewards.nflower_flag_mlzj and rewards.nflower_flag_mlzj>0 then
 			pan = pan + rewards.nflower_flag_mlzj
 		end
 	end
 	return pan
end

function mahjong_action_small_reward_25:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat)
	local scoreItem = {}

 	if rewards.laizi_count > 0 then
 		local item3 = {}
 		item3.des = "金牌"
 		item3.num = ""..rewards.laizi_count.."水"
 		table.insert(scoreItem,item3)
 	end

 	if roomdata_center.bSupportKe and rewards.flowerFan > 0 then
 		local item4 = {}
 		item4.des = "花牌"
 		item4.num = ""..rewards.flowerFan.."水"
 		table.insert(scoreItem,item4)
 	end

 	if roomdata_center.bSupportKe and rewards.nWinTripleNum > 0 then
 		local item5 = {}
 		item5.des = "碰牌"
 		item5.num = ""..rewards.nWinTripleNum.."水"
 		table.insert(scoreItem,item5)
 	end

 	if roomdata_center.bSupportKe and rewards.nWinXuKeZi > 0 then
 		local item6 = {}
 		item6.des = "序数"
 		item6.num = ""..rewards.nWinXuKeZi.."水"
 		table.insert(scoreItem,item6)
 	end

 	if roomdata_center.bSupportKe and rewards.nWinZiKeZi > 0 then
 		local item7 = {}
 		item7.des = "字牌"
 		item7.num = ""..(rewards.nWinZiKeZi * 2).."水"
 		table.insert(scoreItem,item7)
 	end

 	if rewards.nWinGangFan > 0 then
 		local item8 = {}
 		item8.des = "杠牌"
 		item8.num = ""..rewards.nWinGangFan.."水"
 		table.insert(scoreItem,item8)
 	end

 	if rewards.nflower_flag_cxqd and rewards.nflower_flag_cxqd > 0 then
 		local item9 = {}
 		item9.des = "春夏秋冬"
 		item9.num = ""..rewards.nflower_flag_cxqd.."水"
 		table.insert(scoreItem,item9)
 	end

 	if rewards.nflower_flag_mlzj and rewards.nflower_flag_mlzj > 0 then
 		local item10 = {}
 		item10.des = "梅兰竹菊"
 		item10.num = ""..rewards.nflower_flag_mlzj.."水"
 		table.insert(scoreItem,item10)
 	end

 	if rewards.qingyise and rewards.qingyise==1 then
 		local item5 = {}
 		item5.des = "清一色"
 		item5.num = "2倍"
 		table.insert(scoreItem,item5)
 	end

 	if rewards.xiapao and rewards.xiapao > 0 then
 		local item5 = {}
 		item5.des = "下注"
 		item5.num = "+"..rewards.xiapao
 		table.insert(scoreItem,item5)
 	end
 	return scoreItem
end

return mahjong_action_small_reward_25
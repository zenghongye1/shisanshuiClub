-- 通辽麻将小结算
local base = require "logic.mahjong_sys.action.game_18/ui_action/mahjong_action_small_reward_18"
local mahjong_action_small_reward_2215001 = class("mahjong_action_small_reward_2215001", base)

function mahjong_action_small_reward_2215001:GetPlayerMoreInfo(playerInfo,rewards,win_type,win_viewSeat,viewSeat,isBanker)
	playerInfo.scoreItem = self:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat,isBanker)
 	return playerInfo
end

function mahjong_action_small_reward_2215001:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat,isBanker)
	local scoreItem = {}

    if isBanker then
    	local item6 = {}
 		item6.des = "庄"
 		item6.num = "1分"
 		table.insert(scoreItem,item6)
 	end

	if rewards.win_info.nFanDetailInfo~=nil then
		if IsTblIncludeValue(viewSeat,win_viewSeat) then
			
			for i,v in ipairs(rewards.win_info.nFanDetailInfo) do
	 			if v.byFanType ~= 18 then
	 				local item1 = {}
		 			item1.des = tostring(v.szFanName)
			 		item1.num = ""..v.byFanNumber.."分"
		 			table.insert(scoreItem,item1)
			 	end
	 		end

	 		if win_type == "selfdraw" then
				for i,v in ipairs(rewards.win_info.nFanDetailInfo) do
		 			if v.byFanType == 18 then
		 				local item1 = {}
			 			item1.des = tostring(v.szFanName)
			 			if rewards.bSelfAdd and rewards.bSelfAdd == 1 then
			 				item1.num = v.byFanNumber.."分"
			 			else
				 			item1.num = "x"..v.byFanNumber
				 		end
			 			table.insert(scoreItem,item1)
				 	end
		 		end
			end
		end
 	end

 	if isBanker then
		if rewards.buynum and rewards.buynum == 1 then
			local item6 = {}
	 		item6.des = "买自摸x2"
	 		table.insert(scoreItem,item6)
	 	end
	 end

 	if rewards.buy_selfdraw_score ~= 0 then
 		local item6 = {}
 		item6.des = "买自摸"
 		item6.num = ""..rewards.buy_selfdraw_score.."分"
 		table.insert(scoreItem,item6)
 	end

 	if rewards.gang_score ~= 0 then
 		local item6 = {}
 		item6.des = "杠"
 		item6.num = ""..rewards.gang_score.."分"
 		table.insert(scoreItem,item6)
 	end
 	
 	return scoreItem
end

return mahjong_action_small_reward_2215001
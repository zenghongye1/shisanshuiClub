-- 兴安盟穷胡麻将小结算
local base = require "logic.mahjong_sys.action.game_2215001/ui_action/mahjong_action_small_reward_2215001"
local mahjong_action_small_reward_2215003 = class("mahjong_action_small_reward_2215003", base)

function mahjong_action_small_reward_2215003:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat)
	local scoreItem = {}

	local item_hu = {}

	local hu_score_str = rewards.hu_score
	if hu_score_str then
		if hu_score_str > 0 then
			hu_score_str = "+"..hu_score_str
		end
	end

	if IsTblIncludeValue(viewSeat,win_viewSeat) then
		local win_type_str = ""
		if win_type == "gunwin" then
			win_type_str = "点炮"
		elseif win_type == "selfdraw" then
			win_type_str = "自摸"
		elseif win_type == "robgangwin" then
			win_type_str = "抢杠"
		else
			logError(win_type)
		end

		local hu_type_str = ""
		if rewards.win_info then
			local nFanDetailInfo = rewards.win_info.nFanDetailInfo
			if nFanDetailInfo then
				for _,v in ipairs(nFanDetailInfo) do
					if v.byFanType ~= 13 and v.byFanType ~= 14 and v.byFanType ~= 15 and v.byFanType ~= 18 and v.byFanType ~= 19 and v.byFanType ~= 2 then
						hu_type_str = hu_type_str.."、"..v.szFanName..v.byFanNumber.."分"
					end
				end
				for _,v in ipairs(nFanDetailInfo) do
					if v.byFanType == 13 or v.byFanType == 14 or v.byFanType == 2 then
						hu_type_str = hu_type_str.."、"..v.szFanName.."x"..v.byFanNumber
					end
				end
			end
		end

		if rewards.bSelfAdd and rewards.bSelfAdd ~= 0 then
 			hu_type_str = hu_type_str.."、自摸x2"
 		end

		if rewards.bMenHu then
			hu_type_str = hu_type_str.."、闷胡x2"
		end

		if rewards.nLiangXiTimes and rewards.nLiangXiTimes > 0 then
			hu_type_str = hu_type_str.."、亮喜x"..(rewards.nLiangXiTimes*2)
		end

		item_hu.des = "胡牌分"..hu_score_str.."("..win_type_str..hu_type_str..")"
	else
		if rewards.nLiangXiTimes and rewards.nLiangXiTimes > 0 then
			local item6 = {}
	 		item6.des = "亮喜"
	 		item6.num = "x"..(rewards.nLiangXiTimes*2)
	 		table.insert(scoreItem,item6)
		end
		-- item_hu.des = "胡牌分"..hu_score_str
	end

	table.insert(scoreItem,item_hu)

 	if rewards.gang_score ~= 0 then
 		local item6 = {}
 		item6.des = "杠"
 		item6.num = ""..rewards.gang_score.."分"
 		table.insert(scoreItem,item6)
 	end

 	if rewards.pao_score and rewards.pao_score ~= 0 then
 		local item5 = {}
 		item5.des = "跑分"
 		if rewards.pao_score > 0 then
 			item5.num = "+"..rewards.pao_score
 		else
 			item5.num = rewards.pao_score
 		end
 		table.insert(scoreItem,item5)
 	end
 	
 	return scoreItem
end

return mahjong_action_small_reward_2215003
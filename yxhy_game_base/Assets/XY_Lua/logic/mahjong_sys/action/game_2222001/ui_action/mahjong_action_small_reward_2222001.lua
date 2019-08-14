-- 松原麻将小结算
local base = require "logic.mahjong_sys.action.game_18/ui_action/mahjong_action_small_reward_18"
local mahjong_action_small_reward_2222001 = class("mahjong_action_small_reward_2222001", base)

function mahjong_action_small_reward_2222001:GetPlayerMoreInfo(playerInfo,rewards,win_type,win_viewSeat,viewSeat,isBanker)
	playerInfo.scoreItem = self:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat,isBanker)
 	return playerInfo
end

function mahjong_action_small_reward_2222001:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat,isBanker)
	local scoreItem = {}

    if isBanker then
    	local item6 = {}
 		item6.des = "庄翻倍"
 		table.insert(scoreItem,item6)
 	end

 	if rewards.bBaoHu and rewards.nJiePao == 1 then
 		local item6 = {}
 		item6.des = "未上听包胡"
 		table.insert(scoreItem,item6)
 	end

	local item6 = {}
	item6.des = "底"
	item6.num = "1分"
	table.insert(scoreItem,item6)

	local item_hu = {}

	local hu_score_str = rewards.hu_score
	if hu_score_str then
		if hu_score_str > 0 then
			hu_score_str = "+"..hu_score_str
		end
	end

	local hu_type_str = ""

	if IsTblIncludeValue(viewSeat,win_viewSeat) then
		-- local win_type_str = ""
		-- if win_type == "gunwin" then
		-- 	win_type_str = "点炮"
		-- elseif win_type == "selfdraw" then
		-- 	win_type_str = "自摸"
		-- elseif win_type == "robgangwin" then
		-- 	win_type_str = "抢杠"
		-- else
		-- 	logError(win_type)
		-- end

		if rewards.win_info then
			local nFanDetailInfo = rewards.win_info.nFanDetailInfo
			if nFanDetailInfo then
				for _,v in ipairs(nFanDetailInfo) do
					if hu_type_str~="" then
						hu_type_str = hu_type_str.."、"
					end
					if v.byFanNumber == 0 or v.byFanNumber == 1 or v.byFanNumber == 4 or v.byFanNumber == 80 then
						hu_type_str = hu_type_str..v.szFanName..v.byFanNumber.."分"
					else
						hu_type_str = hu_type_str..v.szFanName..v.byFanNumber.."倍"
					end
				end
			end
		end

		item_hu.des = "胡牌分"..hu_score_str.."("..hu_type_str..")"
	else

		if hu_type_str ~= "" then
			item_hu.des = "胡牌分"..hu_score_str.."("..hu_type_str..")"
		else
			item_hu.des = "胡牌分"..hu_score_str
		end
		
	end

	table.insert(scoreItem,item_hu)

 	if rewards.gang_score ~= 0 then
 		local item6 = {}
 		item6.des = "杠分"
 		if rewards.gang_score > 0 then
 			item6.num = "+"..rewards.gang_score
 		else
 			item6.num = rewards.gang_score
 		end
 		table.insert(scoreItem,item6)
 	end

 	return scoreItem
end

return mahjong_action_small_reward_2222001
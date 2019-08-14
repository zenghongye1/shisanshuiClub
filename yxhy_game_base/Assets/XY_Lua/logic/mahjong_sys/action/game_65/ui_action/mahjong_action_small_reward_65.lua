---- 福清麻将小结算

local base = require "logic.mahjong_sys.action.game_18/ui_action/mahjong_action_small_reward_18"
local mahjong_action_small_reward_65 = class("mahjong_action_small_reward_65", base)

function mahjong_action_small_reward_65:GetPlayerMoreInfo(playerInfo,rewards,win_type,win_viewSeat,viewSeat,isBanker)
	playerInfo.difen = self:GetDiFen(rewards,isBanker).."底"

	if win_type ~= "huangpai" then
	 	playerInfo.scoreItem = self:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat)
 	end
 	return playerInfo
end

function mahjong_action_small_reward_65:GetDiFen(rewards,isBanker)
	local fen = 1
	if isBanker then
		fen = 3
	end
 	return fen
end

function mahjong_action_small_reward_65:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat)
	local scoreItem = {}

	local multiple = 1

	if IsTblIncludeValue(viewSeat,win_viewSeat) and rewards.win_info and rewards.win_info.nFanDetailInfo~=nil then
 		for i,v in ipairs(rewards.win_info.nFanDetailInfo) do
 			local item1 = {}
 			local szFanName = tostring(v.szFanName)
 			local byFanNumber = v.byFanNumber
 			if v.byFanType == 0 then
 				if win_type == "gunwin" then
 					szFanName = "点炮"
 				elseif win_type == "robgangwin" then
 					szFanName = "抢杠"
 				elseif win_type == "selfdraw" then
 					szFanName = "自摸"
 				end
 			end
 			item1.des = szFanName
 			local num = ""
 			if v.byFanNumber and v.byFanNumber > 1 then
 				num = num..v.byFanNumber.."倍"
 			end
 			if v.byFanScore and v.byFanScore > 0 then
 				num = num..v.byFanScore.."分"
 			end
	 		item1.num = num
	 		table.insert(scoreItem,item1)
 		end
 	end

	if rewards.lianZhuangFan>0 then
 		local item2 = {}
 		item2.des = "连庄"
 		item2.num = ""..rewards.lianZhuangFan*multiple.."分"
 		table.insert(scoreItem,item2)
 	end

 	if IsTblIncludeValue(viewSeat,win_viewSeat) and rewards.nPengGangCount > 0 or rewards.nMingGangCount > 0 then
 		local item8 = {}
 		item8.des = "明杠"
 		item8.num = ""..(rewards.nPengGangCount + rewards.nMingGangCount).."分"
 		table.insert(scoreItem,item8)
 	end

 	if IsTblIncludeValue(viewSeat,win_viewSeat) and rewards.nAnGangCount > 0 then
 		local item8 = {}
 		item8.des = "暗杠"
 		item8.num = ""..(rewards.nAnGangCount*2).."分"
 		table.insert(scoreItem,item8)
 	end

 	if IsTblIncludeValue(viewSeat,win_viewSeat) and rewards.flowerFan > 0 then
 		local item4 = {}
 		item4.des = "花牌"
 		item4.num = ""..rewards.flowerFan*multiple.."分"
 		table.insert(scoreItem,item4)
 	end

 	if IsTblIncludeValue(viewSeat,win_viewSeat) and rewards.laizi_count > 0 then
 		local item5 = {}
 		item5.des = "金牌"
 		item5.num = ""..rewards.laizi_count*multiple.."分"
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

return mahjong_action_small_reward_65

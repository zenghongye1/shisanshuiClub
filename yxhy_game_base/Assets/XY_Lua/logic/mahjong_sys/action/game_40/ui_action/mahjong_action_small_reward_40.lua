-- 红中麻将小结算
local base = require "logic.mahjong_sys.action.game_18/ui_action/mahjong_action_small_reward_18"
local mahjong_action_small_reward_40 = class("mahjong_action_small_reward_40", base)

function mahjong_action_small_reward_40:GetPlayerMoreInfo(playerInfo,rewards,win_type,win_viewSeat,viewSeat,isBanker)
	playerInfo.scoreItem = self:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat)
	if rewards.flowerFan > 0 and IsTblIncludeValue(viewSeat,win_viewSeat) then
		playerInfo.specialFlower = {35,rewards.flowerFan}
	end
 	return playerInfo
end

function mahjong_action_small_reward_40:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat)
	local scoreItem = {}

	if rewards.hu_score ~= 0 then
 		local item4 = {}
 		item4.des = "胡牌"
 		item4.num = ""..rewards.hu_score.."分"
 		table.insert(scoreItem,item4)
 	end

	if rewards.nhzhScore and rewards.nhzhScore~=0 then
		local item5 = {}
		item5.des = "四中会" 
		item5.num = rewards.nhzhScore.."分"
		table.insert(scoreItem,item5)
	end

 	if rewards.nWinGangFan and rewards.nWinGangFan~=0 then
 		local item3 = {}
 		item3.des = "杠牌"
 		item3.num = ""..rewards.nWinGangFan.."分"
 		table.insert(scoreItem,item3)
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

return mahjong_action_small_reward_40
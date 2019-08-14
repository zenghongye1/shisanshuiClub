-- 霞浦麻将小结算
local base = require "logic.mahjong_sys.action.game_25/ui_action/mahjong_action_small_reward_25"
local mahjong_action_small_reward_91 = class("mahjong_action_small_reward_91", base)

function mahjong_action_small_reward_91:GetTitleInfo(data,win_type,win_viewSeat)
	data.isWinBG = false
 	data.winViewSeat = win_viewSeat
 	if win_type == "huangpai" then
		data.titleIndex = self.cfg.huangArtId
		data.isHuang = true
	elseif IsTblIncludeValue(1,win_viewSeat) then
		data.titleIndex = 10001
		data.isWinBG = true
	else
		data.titleIndex = 10002
	end
	return data
end

function mahjong_action_small_reward_91:GetPlayerMoreInfo(playerInfo,rewards,win_type,win_viewSeat,viewSeat,isBanker)
	playerInfo.scoreItem = self:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat)

 	return playerInfo
end

function mahjong_action_small_reward_91:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat)
	local scoreItem = {}

	if rewards.win_info.nFanDetailInfo~=nil then

		if IsTblIncludeValue(viewSeat,win_viewSeat) then
			local item = {}
			if win_type == "selfdraw" then
				item.des = "自摸"
			 	table.insert(scoreItem,item)
			elseif win_type == "robgoldwin" then
				item.des = "抢金"
			 	table.insert(scoreItem,item)
			end

	 	 	for i,v in ipairs(rewards.win_info.nFanDetailInfo) do
	 			if v.byFanType ~= 0 and v.byFanNumber ~= 0 then
	 				local item1 = {}
		 			item1.des = tostring(v.szFanName)
			 		item1.num = ""..v.byFanNumber.."分"
		 			table.insert(scoreItem,item1)
			 	end
	 		end
		end
 	end

 	if rewards.ping_hu and rewards.ping_hu>0 then
 		local item2 = {}
 		item2.des = "平胡"
 		item2.num = ""..rewards.ping_hu.."分"
 		table.insert(scoreItem,item2)
 	end

 	if rewards.laizi_count > 0 and IsTblIncludeValue(viewSeat,win_viewSeat) then
 		local item3 = {}
 		item3.des = "金牌"
 		item3.num = ""..rewards.laizi_count.."分"
 		table.insert(scoreItem,item3)
 	end

 	 if rewards.flowerFan > 0 and IsTblIncludeValue(viewSeat,win_viewSeat) then
 		local item3 = {}
 		item3.des = "花牌"
 		item3.num = ""..rewards.flowerFan.."分"
 		table.insert(scoreItem,item3)
 	end

 	if rewards.an_gang > 0 and IsTblIncludeValue(viewSeat,win_viewSeat) then
 		local item6 = {}
 		item6.des = "暗杠"
 		item6.num = ""..(rewards.an_gang*2).."分"
 		table.insert(scoreItem,item6)
 	end

 	if rewards.ming_gang > 0 and IsTblIncludeValue(viewSeat,win_viewSeat) then
 		local item7 = {}
 		item7.des = "明杠"
 		item7.num = ""..rewards.ming_gang.."分"
 		table.insert(scoreItem,item7)
 	end

 	if rewards.xiapao and rewards.xiapao > 0 then
 		local item5 = {}
 		item5.des = "下注"
 		item5.num = "+"..rewards.xiapao
 		table.insert(scoreItem,item5)
 	end
 	
 	return scoreItem
end

return mahjong_action_small_reward_91
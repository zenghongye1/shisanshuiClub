-- 宁德麻将小结算
local base = require "logic.mahjong_sys.action.game_25/ui_action/mahjong_action_small_reward_25"
local mahjong_action_small_reward_42 = class("mahjong_action_small_reward_42", base)

function mahjong_action_small_reward_42:GetTitleInfo(data,win_type,win_viewSeat)
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

function mahjong_action_small_reward_42:GetPlayerMoreInfo(playerInfo,rewards,win_type,win_viewSeat,viewSeat,isBanker)
 	playerInfo.pan = self:GetTotalPan(rewards).."分"

	playerInfo.scoreItem = self:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat)
 	return playerInfo
end

function mahjong_action_small_reward_42:GetTotalPan(rewards)
	local pan = 0
 	if rewards.laizi_count>0 or
 		rewards.an_gang>0 or
 		rewards.ming_gang>0 or 
 		rewards.gold_gang>0 then

 		if rewards.laizi_count>0 then
 			pan = pan + rewards.laizi_count
 		end

 		if rewards.an_gang>0 then
 			pan = pan + rewards.an_gang*2
 		end

 		if rewards.ming_gang>0 then
 			pan = pan + rewards.ming_gang
 		end

 		if rewards.gold_gang>0 then
 			pan = pan + rewards.gold_gang*6
 		end
 	end

 	local double = 1
	if win_type == "selfdraw" or win_type == "robgoldwin" then
		double = 2
	end

 	return pan*double
end

function mahjong_action_small_reward_42:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat)
	local scoreItem = {}

	if rewards.win_info.nFanDetailInfo~=nil then
		for i,v in ipairs(rewards.win_info.nFanDetailInfo) do
 			if v.byFanType ~= 0 then
		 		if IsTblIncludeValue(viewSeat,win_viewSeat) then
					local item = {}
					if win_type == "gunwin" then
						item.des = "点炮"
					elseif win_type == "selfdraw" then
						item.des = "自摸"
					elseif win_type == "robgangwin" then
						item.des = "抢杠"
					end
				 	table.insert(scoreItem,item)
				end
				break
			end
		end

 		for i,v in ipairs(rewards.win_info.nFanDetailInfo) do
 			local item1 = {}
 			item1.des = ""
		 	item1.num = ""
 			if v.byFanType ~= 0 then
	 			item1.des = tostring(v.szFanName)
		 		item1.num = ""..v.byFanNumber.."分"
		 	else
		 		if win_type == "selfdraw" then
		 			item1.des = "自摸"
		 			item1.num = "4分"
		 		elseif win_type == "gunwin" then
		 			item1.des = "点炮"
		 			item1.num = "2分"
		 		elseif win_type == "robgangwin" then
		 			item1.des = "抢杠"
		 			item1.num = "2分"
		 		else
		 			logError("未知win_type："..tostring(win_type))
		 		end
		 	end
	 		table.insert(scoreItem,item1)
 		end
 	end

	if rewards.lianZhuangFan>0 then
 		local item2 = {}
 		item2.des = "连庄"
 		item2.num = ""..rewards.lianZhuangFan.."次"
 		table.insert(scoreItem,item2)
 	end

 	if rewards.laizi_count > 0 then
 		local item3 = {}
 		item3.des = "金牌"
 		item3.num = ""..rewards.laizi_count.."分"
 		table.insert(scoreItem,item3)
 	end

 	if rewards.an_gang > 0 then
 		local item6 = {}
 		item6.des = "暗杠"
 		item6.num = ""..(rewards.an_gang*2).."分"
 		table.insert(scoreItem,item6)
 	end

 	if rewards.ming_gang > 0 then
 		local item7 = {}
 		item7.des = "明杠"
 		item7.num = ""..rewards.ming_gang.."分"
 		table.insert(scoreItem,item7)
 	end

 	if rewards.gold_gang > 0 then
 		local item8 = {}
 		item8.des = "金杠"
 		item8.num = ""..(rewards.gold_gang * 6).."分"
 		table.insert(scoreItem,item8)
 	end

 	if rewards.xiapao and rewards.xiapao > 0 then
 		local item5 = {}
 		item5.des = "下注"
 		item5.num = "+"..rewards.xiapao
 		table.insert(scoreItem,item5)
 	end
 	
 	return scoreItem
end

return mahjong_action_small_reward_42
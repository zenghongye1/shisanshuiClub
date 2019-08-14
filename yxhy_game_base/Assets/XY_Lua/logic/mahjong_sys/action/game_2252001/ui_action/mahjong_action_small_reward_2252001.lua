-- 贵阳捉鸡麻将小结算
local base = require "logic.mahjong_sys.action.game_18/ui_action/mahjong_action_small_reward_18"
local mahjong_action_small_reward_2252001 = class("mahjong_action_small_reward_2252001", base)

local jiStrTbl = 
{
	["cardji"] = "幺鸡",
	["rushji"] = "冲锋鸡",
	["dutyji"] = "乌骨鸡",
	["turnji"] = "翻牌鸡",
	["weekji"] = "星期鸡",
	["wuguji"] = "乌骨鸡",
	["rushwg"] = "冲锋乌骨鸡",
	["dutywg"] = "责任乌骨鸡",
}

function mahjong_action_small_reward_2252001:GetPlayerMoreInfo(playerInfo,rewards,win_type,win_viewSeat,viewSeat,isBanker)
	playerInfo.scoreItem = self:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat,isBanker)
 	return playerInfo
end

function mahjong_action_small_reward_2252001:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat,isBanker)
	local scoreItem = {}

	-- local item6 = {}
	-- item6.des = "底"
	-- item6.num = "1分"
	-- table.insert(scoreItem,item6)

	local item_hu = {}

	local hu_score_str = rewards.hu_score
	if hu_score_str then
		if hu_score_str > 0 then
			hu_score_str = "+"..hu_score_str
		end
	end

	local hu_type_str = ""

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

		-- if rewards.nBaseBet and rewards.nBaseBet > 1 then
		-- 	hu_type_str = hu_type_str.."、上楼x"..rewards.nBaseBet
		-- end

		-- if rewards.liangdao and rewards.liangdao == 1 then
		-- 	hu_type_str = hu_type_str.."、亮倒x2"
		-- end

		if rewards.win_info then
			local nFanDetailInfo = rewards.win_info.nFanDetailInfo
			if nFanDetailInfo then
				for _,v in ipairs(nFanDetailInfo) do
					hu_type_str = hu_type_str.."、"..v.szFanName.."+"..v.byFanNumber
				end
			end
		end

		-- if rewards.lianZhuangFan and rewards.lianZhuangFan ~= 0 then
		-- 	if rewards.lianZhuangFan > 0 then
	 -- 			hu_type_str = hu_type_str.."、连庄+"..rewards.lianZhuangFan
	 -- 		else
	 -- 			hu_type_str = hu_type_str.."、连庄"..rewards.lianZhuangFan
	 -- 		end
		-- end

		item_hu.des = "胡牌分"..hu_score_str.."("..win_type_str..hu_type_str..")"
	else
		-- if rewards.lianZhuangFan and rewards.lianZhuangFan ~= 0 then
		-- 	if rewards.lianZhuangFan > 0 then
	 -- 			hu_type_str = hu_type_str.."连庄+"..rewards.lianZhuangFan
	 -- 		else
	 -- 			hu_type_str = hu_type_str.."连庄"..rewards.lianZhuangFan
	 -- 		end
		-- end

		-- if rewards.liangdao and rewards.liangdao == 1 then
		-- 	if hu_type_str ~= "" then
		-- 		hu_type_str = hu_type_str.."、"
		-- 	end
		-- 	hu_type_str = hu_type_str.."亮倒x2"
		-- end

		if hu_type_str ~= "" then
			item_hu.des = "胡牌分"..hu_score_str.."("..hu_type_str..")"
		else
			item_hu.des = "胡牌分"..hu_score_str
		end
		
	end

	table.insert(scoreItem,item_hu)

	if rewards.lianZhuangFan and rewards.lianZhuangFan ~= 0 then
 		local item5 = {}
 		item5.des = "连庄"
 		if rewards.lianZhuangFan > 0 then
 			item5.num = "+"..rewards.lianZhuangFan
 		else
 			item5.num = rewards.lianZhuangFan
 		end
 		table.insert(scoreItem,item5)
 	end

 	if rewards.xiapao and rewards.xiapao ~= 0 then
 		local item5 = {}
 		item5.des = "估卖"
 		if rewards.xiapao > 0 then
 			item5.num = "+"..rewards.xiapao
 		else
 			item5.num = rewards.xiapao
 		end
 		table.insert(scoreItem,item5)
 	end

 	if rewards.gangFan ~= 0 then
 		local item6 = {}
 		item6.des = "杠分"
 		if rewards.gangFan > 0 then
 			item6.num = "+"..rewards.gangFan
 		else
 			item6.num = rewards.gangFan
 		end
 		table.insert(scoreItem,item6)
 	end

 	if rewards.ji_score ~= 0 then
 		local item6 = {}
 		local str = ""
 		if rewards.ji_score > 0 then
 			str = "鸡分+"..rewards.ji_score
 		else
 			str = "鸡分"..rewards.ji_score
 		end
 		local jiStr = ""
 		local isHas = false
 		
 		for serverStr,num in pairs(rewards.jipai_info) do
 			if num ~= 0 then
 				if isHas then
 					jiStr = jiStr.."、"
 				end
 				if num > 0 then
		 			jiStr = jiStr..(jiStrTbl[serverStr].."+"..num)
		 		else
		 			jiStr = jiStr..(jiStrTbl[serverStr]..num)
		 		end
 				isHas = true
 			end
 		end
 		if isHas then
 			str = str.."("..jiStr..")"
 		end
 		item6.des = str
 		table.insert(scoreItem,item6)
 	end

 	return scoreItem
end

return mahjong_action_small_reward_2252001
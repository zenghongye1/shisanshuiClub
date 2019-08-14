-- 福鼎麻将小结算
local base = require "logic.mahjong_sys.action.game_18/ui_action/mahjong_action_small_reward_18"
local mahjong_action_small_reward_45 = class("mahjong_action_small_reward_45", base)

function mahjong_action_small_reward_45:GetPlayerInfo(playerInfo,rewards,i,banker,win_viewSeat,win_type,dice)
	local isBanker = i==banker
	local viewSeat = self.gvblnFun(i)
	playerInfo.nickname = room_usersdata_center.GetUserByLogicSeat(i).name
	playerInfo.totalScore = rewards[i].all_score
	if isBanker then
		playerInfo.isBanker = true
	else
		playerInfo.isBanker = false
	end
	playerInfo.headUrl = room_usersdata_center.GetUserByLogicSeat(i).headurl

	if rewards[i].nJiePao then
		playerInfo.nJiePao = rewards[i].nJiePao
	end

	playerInfo.handCards = self:GetHandCard( rewards[i],win_viewSeat,viewSeat)
	playerInfo.valueList =self:GetOperValueList(rewards[i].combineTile) 
	playerInfo.flowers = rewards[i].stFlowerCards

	playerInfo = self:GetPlayerMoreInfo(playerInfo,rewards[i],win_type,win_viewSeat,viewSeat,banker,i,dice)

 	return playerInfo
end

function mahjong_action_small_reward_45:GetPlayerMoreInfo(playerInfo,rewards,win_type,win_viewSeat,viewSeat,banker,logicSeat,dice)
	local windName = self:GetDirection(viewSeat,banker,dice)
	playerInfo.difen = windName
 	playerInfo.pan = self:GetTotalPan(rewards)

	playerInfo.scoreItem = self:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat,logicSeat==banker,windName)
 	return playerInfo
end

function mahjong_action_small_reward_45:GetDirection(viewSeat,banker,dice)
	local dirString = {"东","南","西","北"}

	local bankerViewSeat = self.gvblnFun(banker)
	local bankerIndex = player_seat_mgr.ViewSeatToIndex(bankerViewSeat)
	local dir = bankerIndex + dice[1] + dice[2] -1
    dir = dir % 4
    if dir == 0 then
        dir = 4
    end

    local offset = player_seat_mgr.ViewSeatToIndex(viewSeat) - dir
    if offset < 0 then
    	offset = offset + 4
    end

	return dirString[offset + 1]
end

function mahjong_action_small_reward_45:GetTotalPan(rewards)
	local stTaiInfo = rewards.stTaiInfo
	local stHuInfo = rewards.stHuInfo
	return rewards.nTaishu.."台"..rewards.nHushu.."胡="..rewards.nSumHu.."胡"
end

function mahjong_action_small_reward_45:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat,isBanker,windName)
	local scoreItem = {}
	local stTaiInfo = rewards.stTaiInfo
	local stHuInfo = rewards.stHuInfo

	if isBanker and win_type ~= "huangpai" then
 		local item = {}
 		item.des = "庄"
 		item.num = "X2"
 		table.insert(scoreItem,item)
 	end

 	if rewards.win_info.nFanDetailInfo then
	 	for _,v in ipairs(rewards.win_info.nFanDetailInfo) do
			local item1 = {}
			if v.byFanType ~= 0 then
				item1.des = tostring(v.szFanName)
		 		item1.num = ""..v.byFanNumber.."胡"
				table.insert(scoreItem,item1)
				return scoreItem
		 	end
		end
	end

	-- 台数
	if stTaiInfo.nSelfdraw and stTaiInfo.nSelfdraw ~= 0 then
 		local item = {}
 		item.des = "自摸"
 		item.num = ""..stTaiInfo.nSelfdraw.."台"
 		table.insert(scoreItem,item)
 	end

 	if stTaiInfo.nTaiLaizi and stTaiInfo.nTaiLaizi ~= 0 then
 		local item = {}
 		item.des = "金牌"
 		item.num = ""..stTaiInfo.nTaiLaizi.."台"
 		table.insert(scoreItem,item)
 	end

 	if stTaiInfo.nTaiFlower and stTaiInfo.nTaiFlower ~= 0 then
 		local item = {}
 		item.des = "花牌"
 		item.num = ""..stTaiInfo.nTaiFlower.."台"
 		table.insert(scoreItem,item)
 	end

 	if stTaiInfo.nTaiBai and stTaiInfo.nTaiBai ~= 0 then
 		local item = {}
 		item.des = "白板"
 		item.num = ""..stTaiInfo.nTaiBai.."台"
 		table.insert(scoreItem,item)
 	end

 	if stTaiInfo.nRedFlower and stTaiInfo.nRedFlower ~= 0 then
 		local item = {}
 		item.des = "四红花"
 		item.num = ""..stTaiInfo.nRedFlower.."台"
 		table.insert(scoreItem,item)
 	end

 	if stTaiInfo.nBlackFlower and stTaiInfo.nBlackFlower ~= 0 then
 		local item = {}
 		item.des = "四黑花"
 		item.num = ""..stTaiInfo.nBlackFlower.."台"
 		table.insert(scoreItem,item)
 	end

 	if stTaiInfo.nZhong and stTaiInfo.nZhong ~= 0 then
 		local item = {}
 		item.des = "红中"
 		item.num = ""..stTaiInfo.nZhong.."台"
 		table.insert(scoreItem,item)
 	end

 	if stTaiInfo.nFa and stTaiInfo.nFa ~= 0 then
 		local item = {}
 		item.des = "发财"
 		item.num = ""..stTaiInfo.nFa.."台"
 		table.insert(scoreItem,item)
 	end

 	if stTaiInfo.nHunYiSe and stTaiInfo.nHunYiSe ~= 0 then
 		local item = {}
 		item.des = "混一色"
 		item.num = ""..stTaiInfo.nHunYiSe.."台"
 		table.insert(scoreItem,item)
 	end

 	if stTaiInfo.nPPHu and stTaiInfo.nPPHu ~= 0 then
 		local item = {}
 		item.des = "对对胡"
 		item.num = ""..stTaiInfo.nPPHu.."台"
 		table.insert(scoreItem,item)
 	end

 	if stTaiInfo.nWind and stTaiInfo.nWind ~= 0 then
 		local item = {}
 		item.des = windName
 		item.num = ""..stTaiInfo.nWind.."台"
 		table.insert(scoreItem,item)
 	end

 	-- 胡数
 	if stHuInfo.nBaseHu and stHuInfo.nBaseHu ~= 0 then
 		local item = {}
 		item.des = "底胡"
 		item.num = ""..stHuInfo.nBaseHu.."胡"
 		table.insert(scoreItem,item)
 	end

 	if stHuInfo.nHuFlower and stHuInfo.nHuFlower ~= 0 then
 		local item = {}
 		item.des = "花牌"
 		item.num = ""..stHuInfo.nHuFlower.."胡"
 		table.insert(scoreItem,item)
 	end

 	if stHuInfo.nHuBai and stHuInfo.nHuBai ~= 0 then
 		local item = {}
 		item.des = "白板"
 		item.num = ""..stHuInfo.nHuBai.."胡"
 		table.insert(scoreItem,item)
 	end

 	if stHuInfo.nHuLaizi and stHuInfo.nHuLaizi ~= 0 then
 		local item = {}
 		item.des = "金牌"
 		item.num = ""..stHuInfo.nHuLaizi.."胡"
 		table.insert(scoreItem,item)
 	end

 	if stHuInfo.stXushu then
 		for _,data in ipairs(stHuInfo.stXushu) do
 			local item = {}
	 		item.des = MahjongTools.MahjongValueToChinese(data.nCard)
	 		item.num = ""..data.nHushu.."胡"
	 		table.insert(scoreItem,item)
 		end
 	end

 	if rewards.xiapao and rewards.xiapao > 0 then
 		local item5 = {}
 		item5.des = "下注"
 		item5.num = "+"..rewards.xiapao
 		table.insert(scoreItem,item5)
 	end
 	return scoreItem
end

return mahjong_action_small_reward_45
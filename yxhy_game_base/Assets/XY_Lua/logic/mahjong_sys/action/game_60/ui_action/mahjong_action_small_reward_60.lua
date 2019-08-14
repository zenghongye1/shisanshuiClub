-- 漳州麻将小结算
local base = require "logic.mahjong_sys.action.game_25/ui_action/mahjong_action_small_reward_25"
local mahjong_action_small_reward_60 = class("mahjong_action_small_reward_60", base)

function mahjong_action_small_reward_60:GetTitleInfo(data,win_type,win_viewSeat,byFanType,byFanNumber,byCount,win_info)
 	data.isWinBG = true
 	data.winViewSeat = win_viewSeat
 	if win_type == "huangpai" then
 		data.isHuang = true
		data.titleIndex = self.cfg.huangArtId
		data.isWinBG = false
	else

		if win_info == nil then
			logError()
			return data
		end
		local winT = win_info.szWinType
		if winT then
			if winT == "pinghu" then
				if win_type == "gunwin" then
					data.titleIndex = 0
					data.number = 1
				elseif win_type == "robgangwin" then
					data.titleIndex = 5
					data.number = 2
				elseif win_type == "selfdraw" then
					data.titleIndex = 18
					data.number = 2
				elseif win_type == "robgoldwin" then
					data.titleIndex = 31
					data.number = 2
				end
			elseif winT == "youjin" then
				data.titleIndex = 38
				data.number = 4
			elseif winT == "twoyou" then
				data.titleIndex = 39
				data.number = 8
			elseif winT == "thryou" then
				data.titleIndex = 40
				data.number = 16
			elseif winT == "fouryou" then
				data.titleIndex = 1040
				data.number = 32
			elseif winT == "fiveyou" then
				data.titleIndex = 2040
				data.number = 64
			end
		end
	end
	return data
end

function mahjong_action_small_reward_60:GetPlayerMoreInfo(playerInfo,rewards,win_type,win_viewSeat,viewSeat,isBanker)
 	if IsTblIncludeValue(viewSeat,win_viewSeat) then
		playerInfo.pan = self:GetTotalPan(rewards).."水"
		playerInfo.scoreItem = self:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat)
	end
 	return playerInfo
end

-- function mahjong_action_small_reward_60:GetDiFen(rewards,isBanker)
-- 	local fen = 0
-- 	if isBanker then
-- 		fen = 6
-- 	else
-- 		fen = 5
-- 	end

--  	if rewards.lianZhuangFan>0 then
-- 		fen = fen + rewards.lianZhuangFan
--  	end
--  	return fen
-- end

function mahjong_action_small_reward_60:GetTotalPan(rewards)
	local pan = 0
	if rewards.flowerFan and roomdata_center.bSupportKe then
		pan = pan + rewards.flowerFan
	end
	if rewards.laizi_count then
		pan = pan + rewards.laizi_count
	end
	if rewards.nWinTripleNum then
		pan = pan + rewards.nWinTripleNum
	end
	if rewards.nWinXuKeZi then
		pan = pan + rewards.nWinXuKeZi
	end
	if rewards.nAnGangCount then
		pan = pan + rewards.nAnGangCount*4
	end
	if rewards.nPengGangCount then
		pan = pan + rewards.nPengGangCount*2
	end
	if rewards.nMingGangCount then
		pan = pan + rewards.nMingGangCount*2
	end
 	return pan
end

function mahjong_action_small_reward_60:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat)
	local scoreItem = {}

 	if rewards.laizi_count > 0 then
 		local item11 = {}
 		item11.des = "金牌"
 		item11.num = ""..rewards.laizi_count.."水"
 		table.insert(scoreItem,item11)
 	end

 	if roomdata_center.bSupportKe and rewards.flowerFan > 0 then
 		local item4 = {}
 		item4.des = "花牌"
 		item4.num = ""..rewards.flowerFan.."水"
 		table.insert(scoreItem,item4)
 	end

 	if rewards.nPengGangCount > 0 or rewards.nMingGangCount > 0 then
 		local item8 = {}
 		item8.des = "明杠"
 		item8.num = ""..((rewards.nPengGangCount + rewards.nMingGangCount)*2).."水"
 		table.insert(scoreItem,item8)
 	end

 	if rewards.nAnGangCount > 0 then
 		local item8 = {}
 		item8.des = "暗杠"
 		item8.num = ""..(rewards.nAnGangCount*4).."水"
 		table.insert(scoreItem,item8)
 	end

 	if rewards.nWinTripleNum > 0 then
 		local item11 = {}
 		item11.des = "中发白碰"
 		item11.num = ""..rewards.nWinTripleNum.."水"
 		table.insert(scoreItem,item11)
 	end

 	if rewards.nWinXuKeZi > 0 then
 		local item11 = {}
 		item11.des = "暗刻"
 		item11.num = ""..rewards.nWinXuKeZi.."水"
 		table.insert(scoreItem,item11)
 	end

 	return scoreItem
end

return mahjong_action_small_reward_60
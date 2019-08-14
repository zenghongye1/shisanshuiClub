----河南麻将小结算
local base = require "logic/mahjong_sys/action/game_8/ui_action/mahjong_action_small_reward_8"
local mahjong_action_small_reward_10 = class("mahjong_action_small_reward_10", base)

function mahjong_action_small_reward_10:GetScoreItem(rewards, win_type, win_viewSeat, viewSeat, i, who_win,bGangAddNoWin,banker)
	local scoreItem = {}

	local base = 0
	local pao_type = 1
	local lib_beishu_c = lib_beishu:create(self.mode)
	local beishu = 1 
	if who_win ~= nil then		
		beishu = lib_beishu_c:CaculateBeishuByWinInfo(rewards[who_win].win_info)
		if beishu == nil or beishu < 1 then
			beishu = 1
		end
	end 
	local isBaoci = false       -- 是否存在包次玩家
	local maxPlayer = roomdata_center.MaxPlayer()
	local isHadHangFen = false

	local lib_common_c = lib_common:create(self.mode)

	local lib_hupai_score_c = lib_hupai_score:create(self.mode)
	if win_type == "huangpai" then
		ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_liuju"))  
		local item_huang = lib_hupai_score_c:GetHuangpaiScore(bGangAddNoWin)		
		if item_huang ~= nil then
			table.insert(scoreItem, item_huang)
		end		
		isHadGangFen = lib_common_c:GetGangAddNoWin(bGangAddNoWin)
	else	
		isHadGangFen = true	
	 	local item_hu = lib_hupai_score_c:GetHuPaiScore(rewards, banker, self.who_win, win_type, i, base, beishu, pao_type)
	 	if item_hu ~= nil then
	 		table.insert(scoreItem, item_hu)
	 	end
 	end

 	------------------------------------------杠分结算-----------------------------------------------
 	local lib_gang_score_c = lib_gang_score:create(self.mode)
 	local gangScoreTbl = lib_gang_score_c:GetGangScore(isHadGangFen, rewards, banker, i, base, 1, pao_type) 	
 	for i,v in ipairs(gangScoreTbl) do
 		table.insert(scoreItem, v)
 	end

 	if lib_common_c:GetSupportDealerAdd() then
 		if win_type ~= "gunwin" or (rewards[i].nJiePao and rewards[i].nJiePao == 1) or i == who_win then
 			if i == banker or who_win == banker then
		 		local item_dealer = {}
		 		item_dealer.des = "庄家加底" 				 	
		 		table.insert(scoreItem, item_dealer)
	 		end
 		end
 	end	

 	return scoreItem
end

return mahjong_action_small_reward_10

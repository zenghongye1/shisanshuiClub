----河南麻将小结算
local base = require "logic/mahjong_sys/action/game_29/ui_action/mahjong_action_small_reward_29"
local mahjong_action_small_reward_30 = class("mahjong_action_small_reward_30", base)

local lib_hupai_score = require "logic/mahjong_sys/action/common_2/lib/lib_hupai_score"
local lib_gang_score = require "logic/mahjong_sys/action/common_2/lib/lib_gang_score"
local lib_beishu = require "logic/mahjong_sys/action/common_2/lib/lib_beishu"
local lib_common = require "logic/mahjong_sys/action/common_2/lib/lib_common"

function mahjong_action_small_reward_30:GetScoreItem(rewards, win_type, win_viewSeat, viewSeat, i, who_win,bGangAddNoWin,banker)
	local base = 0
	local lib_common_c = lib_common:create(self.mode)	
	local pao_type = 2
	local lib_beishu_c = lib_beishu:create(self.mode)	
	local beishu = lib_beishu_c:CaculateBeishuByWinType(win_type)
	if who_win ~= nil then	
		if beishu == 1 then
			local fanshu = lib_beishu_c:CaculateBeishuByWinInfo(rewards[who_win].win_info)
			if fanshu > 0 then
				beishu = beishu * fanshu
			end
		else
			beishu = beishu + lib_beishu_c:CaculateBeishuByWinInfo(rewards[who_win].win_info)		
		end			
	end 
	local maxPlayer = roomdata_center.MaxPlayer()
	local isHadHangFen = false

	local scoreItem = {}

 	if rewards[i].xiapao and rewards[i].xiapao > 0 then
 		local item_pao = {}
 		item_pao.des = "跑分"..rewards[i].xiapao.."分"
 		table.insert(scoreItem,item_pao)
 	end

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
		--ui_sound_mgr.PlaySoundClip("common/audio_win")

	 	-----------------------------------翻倍结算--------------------------------------------
	 	local beiTbl = {}	
	 	local nHunHu = rewards[who_win].win_info.nHunHu 
	 	if nHunHu and nHunHu == 1 and roomdata_center.gamesetting.bFourHunAdd then
	 		local item_bei = {}
	 		item_bei.num = "x2"
	 		item_bei.des = "四混胡"		 		
	 		table.insert(beiTbl, item_bei)	
	 	end	 	

	 	local nQiDui = rewards[who_win].win_info.nQiDui
	 	if nQiDui and nQiDui == 1 and roomdata_center.gamesetting.bSupportSevenDoubleAdd then
	 		local item_bei = {}
	 		item_bei.num = "x2"
	 		item_bei.des = "七小对"	
	 		table.insert(beiTbl, item_bei)	
	 	end
	 	

	 	local item_hu = lib_hupai_score_c:GetHuPaiScore(rewards, banker, self.who_win, win_type, i, base, beishu, pao_type)
	 	if item_hu ~= nil then
	 		table.insert(scoreItem, item_hu)
	 	end
	 	if beishu > 1 and item_hu ~= nil then
	 		--item_hu.num = "x"..tostring(beishu)	 		
		 	for i,v in ipairs(beiTbl) do
				--table.insert(scoreItem, v)		 		
		 	end		 		
	 	end		 		 	 	
 	end

 	------------------------------------------杠分结算-----------------------------------------------
 	local lib_gang_score_c = lib_gang_score:create(self.mode)
 	local gangScoreTbl = lib_gang_score_c:GetGangScore(isHadGangFen, rewards, banker, i, base, 1, pao_type) 	
 	for i,v in ipairs(gangScoreTbl) do
 		table.insert(scoreItem, v)
 	end
 	
 	if lib_common_c:GetSupportDealerAdd() then
 		if self:CheckIsBank(win_type,who_win,i,rewards,banker)  then 
		 	local item_dealer = {}
		 	item_dealer.des = "庄家加底" 				 	
		 	table.insert(scoreItem, item_dealer) 
        end
 	end	

 	return scoreItem
end

return mahjong_action_small_reward_30



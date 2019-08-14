----麻将小结算
local base = require "logic/mahjong_sys/action/game_8/ui_action/mahjong_action_small_reward_8"
local mahjong_action_small_reward_85 = class("mahjong_action_small_reward_85", base)

function mahjong_action_small_reward_85:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat, i, who_win,base,bGangAddNoWin,banker)

	local scoreItem = {}
    local base = 1
	local isHadGangFen = true   -- 是否计算杠分
	local isBaoci = false       -- 是否存在包次玩家
	local maxPlayer = roomdata_center.MaxPlayer() 
		local lib_hupai_score=require"logic/mahjong_sys/action/common_3/lib/lib_hupai_score"
		local lib_hupai_score_c =  lib_hupai_score:create(self.mode)
		local lib_common=require"logic/mahjong_sys/action/common_3/lib/lib_common" 
		local lib_common_c=lib_common:create(self.mode)
		local lib_gang_score=require"logic/mahjong_sys/action/common_3/lib/lib_gang_score"
		local lib_gang_score_c= lib_gang_score:create(self.mode)

	if lib_common_c:GetSupportDealerAdd() and win_type~="huangpai" then  
        if self:CheckIsBank(win_type,who_win,i,rewards,self.banker)  then 
		 	local item_dealer = {}
		 	item_dealer.des = "庄家加底x2"	 	
		 	table.insert(scoreItem, item_dealer) 
        end
 	end	


	if win_type == "huangpai" then
		ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_liuju"))
		local item_huang = lib_hupai_score_c:GetHuangpaiScore(bGangAddNoWin)		
		if item_huang ~= nil then
			return  
		end		
		isHadGangFen = lib_common_c:GetGangAddNoWin(bGangAddNoWin)
	else	
		isHadGangFen = true	
	 	local item_hu = lib_hupai_score_c:GetHuPaiScore(rewards, banker, self.who_win, win_type, i)
	 	if item_hu ~= nil then
	 		table.insert(scoreItem, item_hu)
	 	end
	------------------------------------------杠分结算-----------------------------------------------
		local t= lib_gang_score_c:GetGangScore(isHadGangFen, rewards, banker, i,base) 
	    for m=1,#t do 
	       table.insert(scoreItem, t[m])
	    end		 	
 	end

	------------------------------------------跟庄分结算-----------------------------------------------
 	if rewards[i].follow_score~=nil and rewards[i].follow_score > 0 then
	 	local item_follow = {} 	
	 	item_follow.money = rewards[i].follow_score
	 	item_follow.des = "跟庄"
	 	item_follow.num = "+"..rewards[i].follow_score
	 	table.insert(scoreItem, item_follow)
 	end

 	return scoreItem
end

function mahjong_action_small_reward_85:CheckIsBank(win_type,who_win,i,rewards,banker) 
    if win_type=="gunwin" then
        if who_win==banker or rewards[banker].nJiePao==1 then
            if i==banker or who_win==i or rewards[i].nJiePao==1 then
                return true
            end
        else
            return false
        end
    else
        if who_win==banker then
            return true
        else
            if i==banker or who_win==i then
                return true
            else
                return false 
            end
        end
    end
end


return mahjong_action_small_reward_85
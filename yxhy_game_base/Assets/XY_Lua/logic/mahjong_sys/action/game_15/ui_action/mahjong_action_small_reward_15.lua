----麻将小结算
local base = require "logic/mahjong_sys/action/game_8/ui_action/mahjong_action_small_reward_8"
local mahjong_action_small_reward_15 = class("mahjong_action_small_reward_15", base)
  

  function mahjong_action_small_reward_15:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat, i, who_win,basescore,bGangAddNoWin,banker)
	local scoreItem = {}
    basescore=basescore or 1 
	local isHadGangFen = true   -- 是否计算杠分
	local isBaoci = false       -- 是否存在包次玩家
	local maxPlayer = roomdata_center.MaxPlayer() 
    local lib_hupai_score=require"logic/mahjong_sys/action/common_3/lib/lib_hupai_score"
    local lib_hupai_score_c = lib_hupai_score:create(self.mode)
    local lib_common=require"logic/mahjong_sys/action/common_3/lib/lib_common" 
    local lib_common_c=lib_common:create(self.mode) 
    local lib_gang_score=require"logic/mahjong_sys/action/common_3/lib/lib_gang_score"
    local lib_gang_score_c= lib_gang_score:create(self.mode) 

 	if rewards[i].xiapao and rewards[i].xiapao > 0 then
 		local item_pao = {}
 		item_pao.des = "跑分"..rewards[i].xiapao.."分"
 		table.insert(scoreItem,item_pao)
 	end

	if win_type == "huangpai" then
		ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_liuju"))
		local item_huang = lib_hupai_score_c:GetHuangpaiScore(bGangAddNoWin,basescore)		
		if item_huang ~= nil then
			table.insert(scoreItem, item_huang)
		end
		isHadGangFen = lib_common_c:GetGangAddNoWin(bGangAddNoWin)
	else  
    	if IsTblIncludeValue(1,win_viewSeat) then
        	local item_hu = lib_hupai_score_c:GetHuPaiScore(rewards,banker, self.who_win, win_type, i,basescore) 
	        if item_hu~=nil then
	           table.insert(scoreItem, item_hu) 
	        end
	    end
		for k,o in pairs(win_viewSeat) do 
           if lib_common_c:GetSupportDealerAdd() then  
 		      if self:CheckIsBank(win_type,self.glbvFun(o),i,rewards,banker) then
			      local item_dealer = {}
			      item_dealer.des = "庄家加番" 	 
			      table.insert(scoreItem, item_dealer)
                  break
	 	      end 
 	       end
        end 

        local t= lib_gang_score_c:GetGangScore(isHadGangFen, rewards, banker, i,basescore) 
	    for m=1,#t do 
	       table.insert(scoreItem, t[m])
	    end
 	end 

     
 	
    if rewards[i].follow_score~=nil and rewards[i].follow_score > 0 then
	 	local item_follow = {} 	
	 	item_follow.money = rewards[i].follow_score
	 	item_follow.des = "跟庄"
	 	item_follow.num = "+"..rewards[i].follow_score
	 	table.insert(scoreItem, item_follow)
 	end
 	return scoreItem
end  


return mahjong_action_small_reward_15


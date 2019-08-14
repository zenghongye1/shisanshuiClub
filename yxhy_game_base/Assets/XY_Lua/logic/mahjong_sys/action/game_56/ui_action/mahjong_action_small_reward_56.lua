----河南麻将小结算
local base = require "logic/mahjong_sys/action/game_8/ui_action/mahjong_action_small_reward_8"
local mahjong_action_small_reward_56 = class("mahjong_action_small_reward_56", base)

function mahjong_action_small_reward_56:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat, i, who_win,basescore,bGangAddNoWin,banker)
	local scoreItem = {}
    basescore=basescore or 1 
	local isHadGangFen = true   -- 是否计算杠分
	local isBaoci = false       -- 是否存在包次玩家
	local maxPlayer = roomdata_center.MaxPlayer() 
    local lib_hupai_score=require"logic/mahjong_sys/action/common_2/lib/lib_hupai_score"
    local lib_hupai_score_c = lib_hupai_score:create(self.mode)
    local lib_common=require"logic/mahjong_sys/action/common_2/lib/lib_common" 
    local lib_common_c=lib_common:create(self.mode) 
    local lib_gang_score=require"logic/mahjong_sys/action/common_2/lib/lib_gang_score"
    local lib_gang_score_c= lib_gang_score:create(self.mode) 

 	if rewards[i].xiapao and rewards[i].xiapao > 0 then
 		local item_pao = {}
 		item_pao.des = "跑分"..rewards[i].xiapao.."分"
 		table.insert(scoreItem,item_pao)
 	end

	if win_type == "huangpai" then
		ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_liuju"))
		local item_huang = lib_hupai_score_c:GetHuangpaiScore(bGangAddNoWin,basescore)	
        if rewards[i].all_score~=0 then
            if item_huang==nil then
                item_huang={}
            end
            item_huang.des="庄家包庄"
            item_huang.money=rewards[i].all_score*basescore
        end		
		if item_huang ~= nil then
			table.insert(scoreItem, item_huang)
		end
		isHadGangFen = lib_common_c:GetGangAddNoWin(bGangAddNoWin)
	else 
	 	local item_hu = {} 
        local item_hu = lib_hupai_score_c:GetHuPaiScore(rewards,banker, self.who_win, win_type, i,basescore) 
         
        if item_hu~=nil then
           table.insert(scoreItem, item_hu) 
        end 
        if  rewards[i].FlowerNum~=nil and rewards[i].flower_score~=0  then 
            local item_hua={}   
            local num=rewards[i].flower_score
            if num>0 then
               item_hua.des="花牌+"..rewards[i].flower_score
            else 
               item_hua.des="花牌"..rewards[i].flower_score
            end
            table.insert(scoreItem,item_hua) 
       end
 	end 
    local t= lib_gang_score_c:GetGangScore(isHadGangFen, rewards, banker, i,basescore) 
    
    for m=1,#t do 
       table.insert(scoreItem, t[m])
    end
     
 	if lib_common_c:GetSupportDealerAdd() and win_type~="huangpai" then  
 		if self:CheckIsBank(win_type,who_win,i,rewards,banker)  then 
		 	local item_dealer = {}
			item_dealer.des = "庄家加底" 	
            if self.mode.game_id==69 then
                item_dealer.num ="2倍"	
            else
                item_dealer.num ="1倍"	
            end				 	
			table.insert(scoreItem, item_dealer)
        end 
 	end
 
 	return scoreItem
end  

function mahjong_action_small_reward_56:PlayAnimationAndShowUI(data,win_type,byFanType,FanName, win_viewSeat,callback)
    if win_type == "huangpai" then
        self:PlayHuangAnimation(callback,data)
    else
        if byFanType>0 then
            Trace("byFanType-----"..byFanType)
            if byFanType==2 then
                if FanName=="清一色连6" then
                    byFanType=1206
                elseif FanName=="清一色连9" then
                    byFanType=1209
                end
            end
            if byFanType==130 then
                if FanName=="连6" then
                    byFanType=1306
                elseif FanName=="连9" then
                    byFanType=1309
                end
            end
			local effectTime = 0
            for i=1,1 do            
                if self.cfg.ignoreEffect and IsTblIncludeValue(byFanType,self.cfg.ignoreEffect) then
                    break
                end
                local hutypeConfig = config_mgr.getConfig(self.cfg.huTypeTable,byFanType)
                if hutypeConfig == nil then
                    logError("byFanType error"..byFanType)
                    break
                end
                local artId = hutypeConfig.artId
                local artIdByGameId = hutypeConfig.artIdByGameId
                if artIdByGameId then
                    local newArtId = artIdByGameId[self.mode.game_id]
                    if newArtId then
                        artId = newArtId
                    end
                end
                if artId == nil then
                    logError("artId error"..byFanType)
                    break
                end

                if not self.config.ignoreSound[byFanType] then
                    local fanSound
                    local fanConfig = config_mgr.getConfig("cfg_artconfig",artId)
                    if fanConfig then
                        fanSound = fanConfig.soundName
                    end

                    if fanSound then
                        ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjSoundPath(fanSound))
                    end
                end
				effectTime = 1.5
                if #win_viewSeat == 1 then
                    mahjong_effectMgr:PlayUIEffectById(artId,mahjong_ui.playerList[win_viewSeat[1]].transform.parent)
                else
                    mahjong_effectMgr:PlayUIEffectById(9005,mahjong_ui.playerList[win_viewSeat[1]].transform.parent)
                end
            end
            self.showUI_c = coroutine.start(function ()
				 	coroutine.wait(effectTime)
                callback(data)
                end)
        else
            callback(data)
        end
    end
end

return mahjong_action_small_reward_56

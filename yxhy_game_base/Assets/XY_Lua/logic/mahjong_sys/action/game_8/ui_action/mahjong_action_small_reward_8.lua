----河南麻将小结算
local base = require "logic.mahjong_sys.action.game_18/ui_action/mahjong_action_small_reward_18"
local mahjong_action_small_reward_8 = class("mahjong_action_small_reward_8", base)

local data_class = require "logic/mahjong_sys/data/mahjong_data_class/mahjong_small_reward_data"
local player_data_class = require "logic/mahjong_sys/data/mahjong_data_class/mahjong_small_reward_player_data"

function mahjong_action_small_reward_8:Execute(tbl)	
	Trace("tbl------------------------------"..GetTblData(tbl))
	self:CleanUp()
	local para = tbl._para
	self:SetPara(para)
	local banker = para.banker
	local curr_ju = para.curr_ju
	local ju_num = para.ju_num
	local dice = para.dice
	local rewards = para.rewards --包含4个玩家信息的table
	local who_win = para.who_win
	local win_type = para.win_type
	local rid = para.rid
	local bGangAddNoWin = para.bGangAddNoWin   -- 是否计算杠分
	local win_viewSeat = {}
 	if who_win then
 		for _,v in ipairs(who_win) do
 			table.insert(win_viewSeat,self.gvblnFun(v))
 		end
 	end
 	local win_info,byFanNumber,byFanType,byCount,FanName = self:GetBigFanIfno(rewards,who_win)

 	local data = data_class:create()
 	data.type = self.cfg.small_reward_type
 	data.specialCardType = self.cfg.specialCardSpriteName
 	data.specialCardValues = roomdata_center.specialCard or {}
 	data = self:GetTitleInfo(data,win_type,win_viewSeat,byFanType,byFanNumber,byCount,win_info)

	data.playersInfo ={}
 	for i=1,roomdata_center.MaxPlayer() do
 		local viewSeat = self.gvblnFun(i)
 		local playerInfo = player_data_class:create()
 		data.playersInfo[viewSeat] = self:GetPlayerInfo(playerInfo,rewards,i,banker,win_viewSeat,win_type, who_win[1],bGangAddNoWin)
 	end

 	self:PlayAnimationAndShowUI(data, win_type, byFanType, FanName, win_viewSeat, function(_data)
 		if UI_Manager:Instance():GetUiFormsInShowList("bigSettlement_ui") == nil then
 			UI_Manager:Instance():ShowUiForms("mahjong_small_reward_ui",UiCloseType.UiCloseType_CloseNothing,nil,_data)
 		end
 	end)
end

--[[--
 * @Description: 最大牌型信息  
 ]]
function mahjong_action_small_reward_8:GetBigFanIfno(rewards,who_win)
 	local win_info
 	local byFanNumber = 0
	local byFanType = 0
	local FanName=nil 
	local byCount = 0
	local ignoreEffect = self.cfg.ignoreEffect
 	if who_win and who_win[1] then
 		win_info = rewards[who_win[1]].win_info
 		if win_info then
 			local fanInfo = win_info.nFanDetailInfo
		 	if fanInfo then
			 	for i,v in ipairs(fanInfo) do
			 		if (not ignoreEffect[v.byFanType]) and v.byFanType > byFanType then
			 			if v.byFanNumber > byFanNumber then
			 				byFanNumber = v.byFanNumber
			 				byFanType = v.byFanType
			 				FanName =v.szFanName 
			 				byCount = v.byCount
			 			end
			 		end
			 	end
			end
		else
 			logError("win_info nil")
 		end
 	end
 	return win_info,byFanNumber,byFanType,byCount,FanName
end

function mahjong_action_small_reward_8:GetPlayerInfo(playerInfo, rewards, i, banker,win_viewSeat, win_type, who_win, bGangAddNoWin)
	local isBanker = i==banker
	local viewSeat = self.gvblnFun(i)
	playerInfo.nickname = room_usersdata_center.GetUserByLogicSeat(i).name
	playerInfo.totalScore = rewards[i].all_score
	playerInfo.isBanker = isBanker  
	playerInfo.headUrl = room_usersdata_center.GetUserByLogicSeat(i).headurl
	playerInfo.headType = room_usersdata_center.GetUserByLogicSeat(i).imagetype
	playerInfo.handCards = self:GetHandCard(rewards[i], win_viewSeat, viewSeat)
	playerInfo.valueList = self:GetOperValueList(rewards[i].combineTile)

    if win_type == "huangpai" then
        playerInfo.isHuang=true
    else
        playerInfo.isHuang=false
    end
	if rewards[i].nJiePao then
		playerInfo.nJiePao = rewards[i].nJiePao
	end
	local scoreItem = self:GetScoreItem(rewards, win_type, win_viewSeat, viewSeat, i, who_win,bGangAddNoWin,banker)
 	playerInfo.scoreItem = scoreItem
 	playerInfo.point = tostring(rewards[i].all_score)
 	return playerInfo
end

function mahjong_action_small_reward_8:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat, i, who_win,bGangAddNoWin,banker)
	local scoreItem = {}

	local base = 0
	local pao_type = 1
	local isHadGangFen = true   -- 是否计算杠分
	local isBaoci = false       -- 是否存在包次玩家
	local maxPlayer = roomdata_center.MaxPlayer()
    	local lib_hupai_score=require"logic/mahjong_sys/action/common_2/lib/lib_hupai_score"
    	local lib_hupai_score_c = lib_hupai_score:create(self.mode)
    	local lib_common=require"logic/mahjong_sys/action/common_2/lib/lib_common" 
    	local lib_common_c=lib_common:create(self.mode) 
    	local lib_gang_score=require"logic/mahjong_sys/action/common_2/lib/lib_gang_score"
    	local lib_gang_score_c= lib_gang_score:create(self.mode) 

 	if lib_common_c:GetSupportDealerAdd() and win_type~="huangpai" then  
        if self:CheckIsBank(win_type,who_win,i,rewards,banker)  then 
		 	local item_dealer = {}
		 	item_dealer.des = "庄家加底"	 	
		 	table.insert(scoreItem, item_dealer) 
        end
 	end	

 	if rewards[i].xiapao and rewards[i].xiapao > 0 then
 		local item_pao = {}
 		item_pao.des = "跑分"..rewards[i].xiapao.."分"
 		table.insert(scoreItem,item_pao)
 	end

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

 	------------------------------------------杠分结算-----------------------------------------------
 	local gangScoreTbl = lib_gang_score_c:GetGangScore(isHadGangFen, rewards, banker, i, base, 1, pao_type) 	
 	for i,v in ipairs(gangScoreTbl) do
 		table.insert(scoreItem, v)
 	end

 	return scoreItem
end

function mahjong_action_small_reward_8:CheckIsBank(win_type,who_win,i,rewards,banker) 
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

return mahjong_action_small_reward_8


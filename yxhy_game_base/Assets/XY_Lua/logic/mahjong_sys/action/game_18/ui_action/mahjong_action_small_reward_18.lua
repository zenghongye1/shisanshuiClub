---- 福州麻将小结算

local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_small_reward_18 = class("mahjong_action_small_reward_18", base)

local data_class = require "logic/mahjong_sys/data/mahjong_data_class/mahjong_small_reward_data"
local player_data_class = require "logic/mahjong_sys/data/mahjong_data_class/mahjong_small_reward_player_data"
local room_usersdata_center = room_usersdata_center

function mahjong_action_small_reward_18:CleanUp()
	self.para = nil
end

function mahjong_action_small_reward_18:Execute(tbl)

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
 		data.playersInfo[viewSeat] = self:GetPlayerInfo(playerInfo,rewards,i,banker,win_viewSeat,win_type,dice)
 	end

 	self:PlayAnimationAndShowUI(data, win_type, byFanType, FanName, win_viewSeat, function(_data)
 		if UI_Manager:Instance():GetUiFormsInShowList("bigSettlement_ui") == nil then
 			UI_Manager:Instance():ShowUiForms("mahjong_small_reward_ui",UiCloseType.UiCloseType_CloseNothing,nil,_data)
 		end
 	end)
end

function mahjong_action_small_reward_18:SetPara(para)
	self.para = para
	self.banker = para.banker
	self.curr_ju = para.curr_ju
	self.ju_num = para.ju_num
	self.dice = para.dice
	self.rewards = para.rewards --包含4个玩家信息的table
	self.who_win = para.who_win
	self.win_type = para.win_type
	self.rid = para.rid
	self.bGangAddNoWin = para.bGangAddNoWin   -- 是否计算杠分
end

--[[--
 * @Description: 最大牌型信息  
 ]]
function mahjong_action_small_reward_18:GetBigFanIfno(rewards,who_win)
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
			 		if (not ignoreEffect[v.byFanType]) and v.byFanType > 0 then
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

function mahjong_action_small_reward_18:GetTitleInfo(data,win_type,win_viewSeat,byFanType,byFanNumber)
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

function mahjong_action_small_reward_18:GetPlayerInfo(playerInfo,rewards,i,banker,win_viewSeat,win_type)
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

	playerInfo = self:GetPlayerMoreInfo(playerInfo,rewards[i],win_type,win_viewSeat,viewSeat,isBanker)

 	return playerInfo
end

function mahjong_action_small_reward_18:GetPlayerMoreInfo(playerInfo,rewards,win_type,win_viewSeat,viewSeat,isBanker)
	if win_type ~= "huangpai" and IsTblIncludeValue(viewSeat,win_viewSeat) then
	 	playerInfo.scoreItem = self:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat)
 	end
 	return playerInfo
end

function mahjong_action_small_reward_18:GetHandCard(rewards,win_viewSeat,viewSeat)
	local handCards = rewards.cards
	local win_card = rewards.win_card[1]
	local win_type = rewards.win_type

	if (win_type == "selfdraw" and IsTblIncludeValue(viewSeat,win_viewSeat)) then
		local lastItem = nil
		for j,v in ipairs(handCards) do
			if v == win_card then
				lastItem = table.remove(handCards,j)
				break
			end
		end
		if lastItem == nil then
			logError("自摸手牌找不到胡的牌")
		end
		table.sort(handCards)
		--金前置
		for j=1,#handCards do
		  if roomdata_center.CheckIsSpecialCard(handCards[j]) then
		      local index = j-1
		      while index > 0 and not roomdata_center.CheckIsSpecialCard(handCards[index]) do 
		          local temp = handCards[index]
		          handCards[index] = handCards[index+1]
		          handCards[index+1] = temp
		          index = index -1
		      end
		  end
		end
		table.insert(handCards,lastItem)
	else
		table.sort(handCards)
		--金前置
		for j=1,#handCards do
		  if roomdata_center.CheckIsSpecialCard(handCards[j]) then
		      local index = j-1
		      while index > 0 and not roomdata_center.CheckIsSpecialCard(handCards[index]) do 
		          local temp = handCards[index]
		          handCards[index] = handCards[index+1]
		          handCards[index+1] = temp
		          index = index -1
		      end
		  end
		end
      	if IsTblIncludeValue(viewSeat,win_viewSeat) then
			table.insert(handCards,win_card)
		end
	end
	return handCards
end

function mahjong_action_small_reward_18:GetOperValueList( combineTile )
	local list = {}
	for i,operData in ipairs(combineTile) do
		local valueList = {}
		if operData.ucFlag == 16 then
			table.insert(valueList,operData.card)
	        table.insert(valueList,operData.card+1)
	        table.insert(valueList,operData.card+2)
		elseif operData.ucFlag == 17 then
			table.insert(valueList,operData.card)
	        table.insert(valueList,operData.card)
	        table.insert(valueList,operData.card)
		elseif operData.ucFlag == 18 then
			table.insert(valueList,operData.card)
	        table.insert(valueList,operData.card)
	        table.insert(valueList,operData.card)
	        table.insert(valueList,operData.card)
		elseif operData.ucFlag == 19 then
			table.insert(valueList,0)
	        table.insert(valueList,0)
	        table.insert(valueList,0)
	        table.insert(valueList,operData.card)
		elseif operData.ucFlag == 20 then
			table.insert(valueList,operData.card)
	        table.insert(valueList,operData.card)
	        table.insert(valueList,operData.card)
	        table.insert(valueList,operData.card)
	    elseif operData.ucFlag == 9 then
	    	table.insert(valueList,35)
	        table.insert(valueList,36)
	        table.insert(valueList,37)
	    else
	    	logError("not define operData.ucFlag",operData.ucFlag)
		end
		table.insert(list,valueList)
	end
	return list
end

function mahjong_action_small_reward_18:GetScoreItem(rewards,win_type,win_viewSeat,viewSeat)
	local scoreItem = {}

	local double = 1
	if win_type == "selfdraw" or win_type == "robgoldwin" then
		double = 2
	end

	if rewards.win_info.nFanDetailInfo~=nil then
 		for i,v in ipairs(rewards.win_info.nFanDetailInfo) do
 			local item1 = {}
 			item1.des = tostring(v.szFanName)
	 		item1.num = ""..v.byFanNumber.."番"
	 		table.insert(scoreItem,item1)
 		end
 	end

	if rewards.lianZhuangFan>0 then
 		local item2 = {}
 		item2.des = "连庄"
 		item2.num = ""..rewards.lianZhuangFan*double.."番"
 		table.insert(scoreItem,item2)
 	end

 	if rewards.gangFan > 0 then
 		local item3 = {}
 		item3.des = "杠牌"
 		item3.num = ""..rewards.gangFan*double.."番"
 		table.insert(scoreItem,item3)
 	end

 	if rewards.flowerFan > 0 then
 		local item4 = {}
 		item4.des = "花牌"
 		item4.num = ""..rewards.flowerFan*double.."番"
 		table.insert(scoreItem,item4)
 	end

 	if rewards.laizi_count > 0 then
 		local item5 = {}
 		item5.des = "金牌"
 		item5.num = ""..rewards.laizi_count*double.."番"
 		table.insert(scoreItem,item5)
 	end

 	if rewards.xiapao and rewards.xiapao > 0 then
 		local item5 = {}
 		item5.des = "下注"
 		item5.num = "+"..rewards.xiapao
 		table.insert(scoreItem,item5)
 	end
 	
 	return scoreItem
end

function mahjong_action_small_reward_18:PlayAnimationAndShowUI(data,win_type,byFanType,FanName, win_viewSeat,callback)
 	if win_type == "huangpai" then
 		self:PlayHuangAnimation(callback,data)
 	else
		if byFanType>0 then
			Trace("byFanType-----"..byFanType)
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

function mahjong_action_small_reward_18:PlayHuangAnimation(callback,data)
	mahjong_effectMgr:PlayUIEffectById(self.cfg.huangArtId,mahjong_ui.playerList[1].transform.parent)
	self.showUI_c = coroutine.start(function ()
	 	coroutine.wait(1)
		callback(data)
	end)
end

function mahjong_action_small_reward_18:Uninitialize()
	if self.showUI_c then
		coroutine.stop(self.showUI_c)
		self.showUI_c = nil
	end
end

return mahjong_action_small_reward_18

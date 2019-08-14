local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameAskBlock = class("mahjong_action_gameAskBlock", base)

local mahjong_ui = mahjong_ui

function mahjong_action_gameAskBlock:Execute(tbl)
	--[[
	MahjongOperTipsEnum = {
	    None                = 0x0001,
	    GiveUp              = 0x0002,--过,
	    Collect             = 0x0003,--吃,
	    Triplet             = 0x0004,--碰,
	    Quadruplet          = 0x0005,--杠,
	    Ting                = 0x0006,--听,
	    Hu                  = 0x0007,--胡,
	}
	 ]]
	
	Trace("mahjong_action_gameAskBlock-------------------"..GetTblData(tbl))
	operatorcachedata.ClearOperTipsList()

	local lastPlayViewSeat = self.gvblnFun(tbl._para.lastPlay)
	local bCanQuadruplet = tbl._para.bCanQuadruplet -- 是否可杠牌
	local bCanTriplet = tbl._para.bCanTriplet--是否可碰牌
	local bCanBZZ = tbl._para.bCanBZZ--是否可边钻砸

	--胡牌
	local bCanWin = tbl._para.bCanWin
	local cardWin = tbl._para.cardWin
	if bCanWin then
		local operData = operatorTipsData:New(MahjongOperTipsEnum.Hu,cardWin)  --modify by cgg
		operatorcachedata.AddOperTips(operData)
	end

	-- 必须胡
	local nbixuhu = tbl._para.nbixuhu
	if nbixuhu then
		if bCanWin and cardWin and (cardWin.nCard or cardWin.card) then
			mahjong_play_sys.HuPaiReq(cardWin.nCard or cardWin.card)
			return
		end
	end

	--听牌
	local bCanTing = tbl._para.bCanTing
	if bCanTing then
		local operData = nil
		logError("1"..tostring(roomdata_center.bSupportMT))
		if roomdata_center.bSupportMT then
			operData = operatorTipsData:New(MahjongOperTipsEnum.MT,tbl._para.cardTingGroup)
		else
		--	tingType听牌类型(0x5:听牌    0X6:天听	0X7:地听	0X8:潇洒)
			if tbl._para.cardTingGroup.tingType == 8 then

				operData = operatorTipsData:New(MahjongOperTipsEnum.Xiao, tbl._para.cardTingGroup)
			else
				operData = operatorTipsData:New(MahjongOperTipsEnum.Ting,tbl._para.cardTingGroup)
			end
		end
		operatorcachedata.AddOperTips(operData)
		
		local data = {}
		data._para = {}  
		data._para.stTingCards = tbl._para.cardTingGroup.tingInfo 
		roomdata_center.SetHintInfoMap(data) 
	end

	--边砸钻
	if bCanBZZ ~= nil then
		if roomdata_center.hasBZZ ~= 0 then
			if roomdata_center.hasBZZ ==  bit._and(bCanBZZ,2)  then
				local operData = operatorTipsData:New(MahjongOperTipsEnum.N_ZUAN_FLAG, nil)
				operatorcachedata.AddOperTips(operData)
			elseif roomdata_center.hasBZZ == bit._and(bCanBZZ,4) then
				local operData = operatorTipsData:New(MahjongOperTipsEnum.N_BIAN_FLAG, nil)
				operatorcachedata.AddOperTips(operData)
			elseif bCanQuadruplet == true and roomdata_center.hasBZZ == bit._and(bCanBZZ,1) and bCanTriplet == false then
				local operData = operatorTipsData:New(MahjongOperTipsEnum.N_ZAGANG_FLAG, tbl._para.cardQuadruplet)
				operatorcachedata.AddOperTips(operData)
			elseif roomdata_center.hasBZZ == bit._and(bCanBZZ,1) and bCanTriplet == false and bCanQuadruplet == false then
				local operData = operatorTipsData:New(MahjongOperTipsEnum.N_ZA_FLAG, nil)
				operatorcachedata.AddOperTips(operData)
			end
		else
			if bit._and(bCanBZZ,2) == 2 and roomdata_center.hasBZZ == 0 then
				local operData = operatorTipsData:New(MahjongOperTipsEnum.N_ZUAN_FLAG, nil)
				operatorcachedata.AddOperTips(operData)
			end
			if bit._and(bCanBZZ,4) == 4 and roomdata_center.hasBZZ == 0 then
				local operData = operatorTipsData:New(MahjongOperTipsEnum.N_BIAN_FLAG, nil)
				operatorcachedata.AddOperTips(operData) 
			end
			if bit._and(bCanBZZ,1) == 1 and bCanTriplet== false and bCanQuadruplet == false and roomdata_center.hasBZZ == 0 then --第一次砸   自己摸到的牌 
				local operData = operatorTipsData:New(MahjongOperTipsEnum.N_ZA_FLAG, nil)
				operatorcachedata.AddOperTips(operData) 
			end
			if bit._and(bCanBZZ,1) == 1 and bCanQuadruplet == true and bCanTriplet == false and roomdata_center.hasBZZ == 0 then--第一次砸杠 自己摸到的牌 
				local operData = operatorTipsData:New(MahjongOperTipsEnum.N_ZAGANG_FLAG, tbl._para.cardQuadruplet)
				operatorcachedat33a.AddOperTips(operData)
			end
		end
	end

	--杠牌
	if bCanQuadruplet then
		if roomdata_center.hasBZZ ~= 0 then
			if roomdata_center.hasBZZ ~= 1 and bCanQuadruplet == true then
				local operData = operatorTipsData:New(MahjongOperTipsEnum.Quadruplet,tbl._para.cardQuadruplet)
				operatorcachedata.AddOperTips(operData)
			else
				local operData = operatorTipsData:New(MahjongOperTipsEnum.N_ZAGANG_FLAG,tbl._para.cardQuadruplet)
				operatorcachedata.AddOperTips(operData)
			end
		else
			local operData = operatorTipsData:New(MahjongOperTipsEnum.Quadruplet,tbl._para.cardQuadruplet)
			operatorcachedata.AddOperTips(operData)	

			if bCanBZZ ~= nil then -- 第一次砸杠  别人
				if bit._and(bCanBZZ,1) == 1 and roomdata_center.hasBZZ == 0 and bCanTriplet == true then
					local operData = operatorTipsData:New(MahjongOperTipsEnum.N_ZAGANG_FLAG,tbl._para.cardQuadruplet)
					operatorcachedata.AddOperTips(operData)
				end
			end
		end
	end

	--碰牌
	if bCanTriplet then
		if roomdata_center.hasBZZ ~= 0 then
			if roomdata_center.hasBZZ ~= 1 and bCanTriplet == true then
				local operData = operatorTipsData:New(MahjongOperTipsEnum.Triplet,tbl._para.cardTriplet)
				operatorcachedata.AddOperTips(operData)				
			else
				local operData = operatorTipsData:New(MahjongOperTipsEnum.N_ZA_FLAG,tbl._para.cardTriplet)
				operatorcachedata.AddOperTips(operData)
			end
		else
			local operData = operatorTipsData:New(MahjongOperTipsEnum.Triplet,tbl._para.cardTriplet)
			operatorcachedata.AddOperTips(operData)

			if bCanBZZ ~= nil then   --第一次砸  别人
				if bit._and(bCanBZZ,1) == 1 and roomdata_center.hasBZZ == 0 then
					local operData = operatorTipsData:New(MahjongOperTipsEnum.N_ZA_FLAG,tbl._para.cardTriplet)
					operatorcachedata.AddOperTips(operData)
				end
			end
		end
	end


	-- 吃牌 	最后一次打牌的人 吃谁的 碰谁的 杠谁的 胡谁的
	local bCanCollect = tbl._para.bCanCollect
	if bCanCollect then
		local operData = operatorTipsData:New(MahjongOperTipsEnum.Collect,tbl._para.cardCollect)
		operatorcachedata.AddOperTips(operData)
	end

    --过
	if bCanCollect or bCanTriplet or bCanQuadruplet or bCanTing or bCanWin or bCanBZZ or roomdata_center.hasBZZ == bCanBZZ then
		if not (roomdata_center.IsPlayerTing(1) and not self.cfg.specialCardCanSend ) then  
			if roomdata_center.hasBZZ and roomdata_center.hasBZZ == bCanBZZ then
				local operData = operatorTipsData:New(MahjongOperTipsEnum.GiveUp, nil)
				operatorcachedata.AddOperTips(operData)
			else
				local operData = operatorTipsData:New(MahjongOperTipsEnum.GiveUp, nil)
				operatorcachedata.AddOperTips(operData)
			end
		end

		mahjong_ui:ShowOperTips()		

		ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_tip_operate"))

		Notifier.dispatchCmd(cmdName.MSG_SHAKE,{}) 
	end
end

return mahjong_action_gameAskBlock
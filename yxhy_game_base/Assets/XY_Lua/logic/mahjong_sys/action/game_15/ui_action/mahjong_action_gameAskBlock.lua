local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameAskBlock = class("mahjong_action_gameAskBlock", base)



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
	
	Trace(GetTblData(tbl))
	operatorcachedata.ClearOperTipsList()

	local lastPlayViewSeat = self.gvblnFun(tbl._para.lastPlay)

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
		--	tingType听牌类型(0x5:听牌    0X6:天听	0X7:地听	0X8:潇洒)
		if tbl._para.cardTingGroup.tingType == 8 then
			operData = operatorTipsData:New(MahjongOperTipsEnum.Xiao, tbl._para.cardTingGroup)
		else
			operData = operatorTipsData:New(MahjongOperTipsEnum.Ting,tbl._para.cardTingGroup)
		end
		operatorcachedata.AddOperTips(operData)
		
		local data = {}
		data._para = {}  
		data._para.stTingCards = tbl._para.cardTingGroup.tingInfo 
		roomdata_center.SetHintInfoMap(data) 
	end


	--边砸钻
	local bCanBZZ = tbl._para.bCanBZZ
	--边砸钻
	if bCanBZZ ~= nil then
		if bit._and(bCanBZZ,2) == 2 then
			local operData = operatorTipsData:New(MahjongOperTipsEnum.N_ZUAN_FLAG, tbl._para.cardTriplet)
			operatorcachedata.AddOperTips(operData)

			local operatorTips = operatorcachedata.GetOperTipsList()
			Trace("operatorTips-----========wwwwwwwwwww=======--------"..json.encode(operatorTips)) -- 19
		end
		if bit._and(bCanBZZ,4) == 4 then
			local operData = operatorTipsData:New(MahjongOperTipsEnum.N_BIAN_FLAG, tbl._para.cardTriplet)
			operatorcachedata.AddOperTips(operData) 
			local operatorTips = operatorcachedata.GetOperTipsList()
			Trace("operatorTips-----========wwwwwwwwwww=======--------"..json.encode(operatorTips))	--20
		end
	end
	--杠牌
	local bCanQuadruplet = tbl._para.bCanQuadruplet
	if bCanQuadruplet then
		local operData = operatorTipsData:New(MahjongOperTipsEnum.Quadruplet,tbl._para.cardQuadruplet)
		operatorcachedata.AddOperTips(operData)
	
		if bCanBZZ ~= nil then
			if bit._and(bCanBZZ,1) == 1 then
				local operData = operatorTipsData:New(MahjongOperTipsEnum.N_ZAGANG_FLAG,tbl._para.cardQuadruplet)
				operatorcachedata.AddOperTips(operData)
			end
		end
	end

	--碰牌
	local bCanTriplet = tbl._para.bCanTriplet
	if bCanTriplet then
		local operData = operatorTipsData:New(MahjongOperTipsEnum.Triplet,tbl._para.cardTriplet)
		operatorcachedata.AddOperTips(operData)

		if bCanBZZ ~= nil then
			if bit._and(bCanBZZ,1) == 1 then
				local operData = operatorTipsData:New(MahjongOperTipsEnum.N_ZA_FLAG,tbl._para.cardTriplet)
				operatorcachedata.AddOperTips(operData)
			end
		end
	end


	-- 吃牌 	最后一次打牌的人 吃谁的 碰谁的 杠谁的 胡谁的
	local bCanCollect = tbl._para.bCanCollect
	if bCanCollect then
		local operData = operatorTipsData:New(MahjongOperTipsEnum.Collect,tbl._para.cardCollect)
		operatorcachedata.AddOperTips(operData)
	end

	if bCanCollect or bCanTriplet or bCanQuadruplet or bCanTing or bCanWin or bCanBZZ then
		if not (roomdata_center.IsPlayerTing(1) and not self.cfg.specialCardCanSend) then  
			local operData = operatorTipsData:New(MahjongOperTipsEnum.GiveUp, nil)
			operatorcachedata.AddOperTips(operData)
		end

		mahjong_ui:ShowOperTips()		

		ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_tip_operate"))

		Notifier.dispatchCmd(cmdName.MSG_SHAKE,{}) 
	end
end

return mahjong_action_gameAskBlock
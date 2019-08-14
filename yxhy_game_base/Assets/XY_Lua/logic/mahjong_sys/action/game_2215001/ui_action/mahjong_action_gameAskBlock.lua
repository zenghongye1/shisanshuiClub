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
	local nWinFalg = tbl._para.nWinFalg
	if bCanWin then
		if nWinFalg and nWinFalg == 1 then
			local operData = operatorTipsData:New(MahjongOperTipsEnum.Qiang,cardWin)
			operatorcachedata.AddOperTips(operData)
		else
			local operData = operatorTipsData:New(MahjongOperTipsEnum.Hu,cardWin)
			operatorcachedata.AddOperTips(operData)
		end
	end

	-- 必须胡
	local nbixuhu = tbl._para.nbixuhu
	if nbixuhu then
		if bCanWin and cardWin and cardWin.nCard then
			mahjong_play_sys.HuPaiReq(cardWin.nCard)
			return
		end
	end

	--听牌
	local bCanTing = tbl._para.bCanTing
	if bCanTing then
		roomdata_center.tingType = 0
		local cardTingGroup = tbl._para.cardTingGroup
		if cardTingGroup and cardTingGroup.tingNBJ and cardTingGroup.tingNBJ == 9 then
			local cardTingGroup_NiuBi = {
				tingType = 9,
				tingInfo = cardTingGroup.tingInfo
			}
			operatorcachedata.AddOperTips(operatorTipsData:New(MahjongOperTipsEnum.NiuBiJiao,cardTingGroup_NiuBi))
		end
		local tingTipsType = MahjongOperTipsEnum.Ting
		if self.cfg.tingTypeMap[cardTingGroup.tingType] then
			tingTipsType = MahjongOperTipsEnum[self.cfg.tingTypeMap[cardTingGroup.tingType][1]]
		end
		local operData = operatorTipsData:New(tingTipsType,cardTingGroup)
		operatorcachedata.AddOperTips(operData)
	end

	--杠牌
	local bCanQuadruplet = tbl._para.bCanQuadruplet
	if bCanQuadruplet then
		local operData = operatorTipsData:New(MahjongOperTipsEnum.Quadruplet,tbl._para.cardQuadruplet)
		operatorcachedata.AddOperTips(operData)
	end

	--碰牌
	local bCanTriplet = tbl._para.bCanTriplet
	if bCanTriplet then
		local operData = operatorTipsData:New(MahjongOperTipsEnum.Triplet,tbl._para.cardTriplet)
		operatorcachedata.AddOperTips(operData)
	end

	-- 吃牌 	最后一次打牌的人 吃谁的 碰谁的 杠谁的 胡谁的
	local bCanCollect = tbl._para.bCanCollect
	if bCanCollect then
		local operData = operatorTipsData:New(MahjongOperTipsEnum.Collect,tbl._para.cardCollect)
		operatorcachedata.AddOperTips(operData)
	end

	if bCanCollect or bCanTriplet or bCanQuadruplet or bCanTing or bCanWin then
		local bNeedGiveUp = tbl._para.bNeedGiveUp
		if bNeedGiveUp == nil or bNeedGiveUp == true then
			local operData = operatorTipsData:New(MahjongOperTipsEnum.GiveUp,nil)
			operatorcachedata.AddOperTips(operData)
		end

		mahjong_ui:ShowOperTips()

		ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_tip_operate"))

		Notifier.dispatchCmd(cmdName.MSG_SHAKE,{}) 
	end

	if mahjong_gm_manager and mahjong_gm_manager.isOpenGMMode then
        mahjong_gm_manager:AskBlock()
    end
end

return mahjong_action_gameAskBlock
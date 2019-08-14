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

    mahjong_ui:ChangeGuobtn("oper_guo") 
	--胡牌
	local bCanWin = tbl._para.bCanWin
	local cardWin = tbl._para.cardWin
    local s=self.compPlayerMgr.selfPlayer:IsRoundSendCard(#self.compPlayerMgr.selfPlayer.handCardList) 
	if bCanWin then 
		local operData = operatorTipsData:New(MahjongOperTipsEnum.Hu,cardWin)  --modify by cgg
		operatorcachedata.AddOperTips(operData) 
         
        if s==false then  
            mahjong_ui:ChangeGuobtn("paiju_109") 
        else  
            mahjong_ui:ChangeGuobtn("oper_guo") 
        end
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
		roomdata_center.tingType = 0
		local cardTingGroup = tbl._para.cardTingGroup
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

    --[[
    听牌过处理
    ]]
    local seat=self.gvblFun(tbl._src) 
    if roomdata_center.IsPlayerTing(seat) and bCanWin then
		if roomdata_center.specialCard[1] and comp_show_base.cardLastDraw and roomdata_center.specialCard[1]==comp_show_base.cardLastDraw then 
            mahjong_ui:SetGuoBtnActive(false)
        end
    end 

	if mahjong_gm_manager and mahjong_gm_manager.isOpenGMMode then
        mahjong_gm_manager:AskBlock()
    end
end

return mahjong_action_gameAskBlock
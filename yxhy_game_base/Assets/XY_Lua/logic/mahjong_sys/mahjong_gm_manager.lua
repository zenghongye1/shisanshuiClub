local mahjong_gm_manager = class("mahjong_gm_manager")

function mahjong_gm_manager:ctor(mode)
	self.mode = mode
	self.config = mode.config
	self.compTable = mode:GetComponent("comp_mjTable")
    self.compResMgr = mode:GetComponent("comp_resMgr")
    self.compMjItemMgr = mode:GetComponent("comp_mjItemMgr")
    self.compPlayerMgr = mode:GetComponent("comp_playerMgr")
    self.compDice = mode:GetComponent("comp_dice")

    self.gvblFun = player_seat_mgr.GetViewSeatByLogicSeat
    self.gvblnFun = player_seat_mgr.GetViewSeatByLogicSeatNum
    self.gmlsFun = player_seat_mgr.GetMyLogicSeat 

    self.isOpenGMMode = false
	self.isAutoPlay = true -- 自动出牌，默认
	self.isCancelBlock = true -- 自动过 吃碰杠，默认
	self.isCancelHu = false -- 自动过 胡

	self.isHu = false
end

function mahjong_gm_manager:OpenGMMode()
	self.isOpenGMMode = not self.isOpenGMMode
	logError("GM模式："..tostring(self.isOpenGMMode))
end

function mahjong_gm_manager:SetAutoPlay()
	self.isAutoPlay = not self.isAutoPlay
end

function mahjong_gm_manager:SetCancelBlock()
	self.isCancelBlock = not self.isCancelBlock
end

function mahjong_gm_manager:SetCancelHu()
	self.isCancelHu = not self.isCancelHu
end

-- function mahjong_gm_manager:PlayCard(tbl)
-- 	local src = tbl["_src"]
--     local viewSeat = player_seat_mgr.GetViewSeatByLogicSeat(src)
--     local value = tbl["_para"]["cards"][1]
-- 	self.compPlayerMgr:GetPlayer(viewSeat):OutCard(value, function (pos)
--         self.compResMgr:SetOutCardEfObj(pos)
--            Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_PLAY_CARD)
--         end)

--     roomdata_center.AddMj(value)
-- end

function mahjong_gm_manager:AskPlay(index)
	if self.isAutoPlay then
		local player = self.compPlayerMgr.selfPlayer
		local list = player.handCardList
		local index = index or #list
		local mj = list[index]
		local paiVal = mj.paiValue
	    if player.canOutCard and ((not self.isHu) or self.isCancelHu) then
	        if player:CheckCanSendOut(paiVal) then
	            player.curReqOutItem = mj
	            mahjong_play_sys.OutCardReq(paiVal)
	            player:AutoOutCard(paiVal)
	            self.isHu = false
	        else
	        	self:AskPlay(index-1)
	        end
	    end
	end
end

function mahjong_gm_manager:AskBlock()
	local operTipDataList = operatorcachedata.GetOperTipsList()
	if #operTipDataList == 0 then
		return
	end

	local operEnumList = {}
	for i = 1, #operTipDataList do
		operEnumList[i] = operTipDataList[i].operType
	end
	table.sort(operEnumList, function(a,b) return a > b end)

	self.isHu = false
	if operEnumList[1]>=MahjongOperTipsEnum.Ting then
		self.isHu = true
		if self.isCancelHu then
			mahjong_play_sys.GiveUp()
		end
		return
	end

	if self.isCancelBlock then
		mahjong_play_sys.GiveUp()
	end

end

return mahjong_gm_manager
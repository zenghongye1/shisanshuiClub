local base = require "logic/framework/ui/uibase/ui_view_base"
local OperTipsView = class("OperTipsView", base)
local operatorcachedata = operatorcachedata
local addClickCallbackSelf = addClickCallbackSelf
local mahjong_play_sys = mahjong_play_sys
local MahjongOperTipsEnum = MahjongOperTipsEnum


function OperTipsView:ctor(go)
	self.operNameTable = 
	{
		["hu"] 				 = {MahjongOperTipsEnum.Hu, OperTipsView.OnHuClick},
		["ting"] 			 = {MahjongOperTipsEnum.Ting, OperTipsView.OnTingClick},
		["tingJinKan"] 		 = {MahjongOperTipsEnum.TingJinKan, OperTipsView.OnTingJinKanClick},
		["tingYouJin"] 		 = {MahjongOperTipsEnum.TingYouJin, OperTipsView.OnTingYouJinClick},
		["tingDouJin"] 		 = {MahjongOperTipsEnum.TingDouJin, OperTipsView.OnTingDouJinClick},
		["tingThrJin"] 		 = {MahjongOperTipsEnum.TingThrJin, OperTipsView.OnTingThrJinClick},
		["gang"] 			 = {MahjongOperTipsEnum.Quadruplet, OperTipsView.OnGangClick},
		["peng"] 			 = {MahjongOperTipsEnum.Triplet, OperTipsView.OnPengClick},
		["chi"] 			 = {MahjongOperTipsEnum.Collect, OperTipsView.OnChiClick},
		["guo"] 			 = {MahjongOperTipsEnum.GiveUp, OperTipsView.OnGuoClick},
		["xiao"] 			 = {MahjongOperTipsEnum.Xiao, OperTipsView.OnXiaoClick},
		["niuBiJiao"]		 = {MahjongOperTipsEnum.NiuBiJiao, OperTipsView.OnNiuBiJiaoClick},
		["liangXiEr"]		 = {MahjongOperTipsEnum.LiangXiEr, OperTipsView.OnLiangXiErClick},
		["liang"]			 = {MahjongOperTipsEnum.Liang, OperTipsView.OnLiangClick},
		["tianTing"]		 = {MahjongOperTipsEnum.TianTing, OperTipsView.OnTianTingClick},
		["yingBao"] 		 = {MahjongOperTipsEnum.YingBao, OperTipsView.OnYingBaoClick},
		["qiangTing"] 		 = {MahjongOperTipsEnum.QiangTing, OperTipsView.OnQiangTingClick},
		["qiang"]			 = {MahjongOperTipsEnum.Qiang, OperTipsView.OnQiangClick},
		["N_ZA_FLAG"]		 = {MahjongOperTipsEnum.N_ZA_FLAG, OperTipsView.OnZaClick},
		["N_ZUAN_FLAG"]		 = {MahjongOperTipsEnum.N_ZUAN_FLAG, OperTipsView.OnZuanClick},
		["N_BIAN_FLAG"]		 = {MahjongOperTipsEnum.N_BIAN_FLAG, OperTipsView.OnBianClick},	
		["N_ZAGANG_FLAG"]	 = {MahjongOperTipsEnum.N_ZAGANG_FLAG, OperTipsView.OnZagangClick},
		["MT"] 				 = {MahjongOperTipsEnum.MT, OperTipsView.OnMTClick},
	}


	base.ctor(self, go)

end

function OperTipsView:InitView()
	self.itemGoMap = {}
	self.operTipEffect = nil

	for k, tab in pairs(self.operNameTable) do
		local btnGo = self:GetGameObject("Grid/" .. k)
		if btnGo then
			btnGo:SetActive(false)
			addClickCallbackSelf(
				btnGo, 
				function ()
					tab[2]()
					self:Hide()
				end,
				self)
			self.itemGoMap[tab[1]] = btnGo
		else
			logWarning(k.." btn is not exist")
		end
	end
	self:SetActive(false)
end

function OperTipsView:Show()
	local operTipDataList = operatorcachedata.GetOperTipsList() 
	if #operTipDataList == 0 then
		return
	end 
	local operEnumList = {}
	for i = 1, #operTipDataList do
		operEnumList[i] = operTipDataList[i].operType
	end
	table.sort(operEnumList, function(a,b) return a > b end)

	for i = 1, #operEnumList do
		local go = self.itemGoMap[operEnumList[i]]
		go.transform.localPosition = Vector3(-130*(#operTipDataList-i),0,0)
		go:SetActive(true)
	end


	local effName 
	local enum = operEnumList[1]
	if enum == MahjongOperTipsEnum.Hu then
		effName = "hu"
	else
		effName = "chi"
	end

	self.operTipEffect = EffectMgr.PlayEffect(mahjong_path_mgr.GetEffPath("Effect_Anniu",mahjong_path_enum.mjCommon),1,-1)
	self.operTipEffect.transform:SetParent(self.itemGoMap[enum].transform,false)
	if self.operTipEffect and self.sortingOrder and self.m_subPanelCount then
		local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
		Utils.SetEffectSortLayer(self.operTipEffect, topLayerIndex)
	end

	self:SetActive(true)
end

function OperTipsView:Hide()
	if self.isActive == false then
		return
	end
	self:SetActive(false)
	self:HideEff()
	for k, go in pairs(self.itemGoMap) do
		go:SetActive(false)
	end
end

function OperTipsView:HideEff()
	if self.operTipEffect ~=nil then
		EffectMgr.StopEffect(self.operTipEffect)
	end
end
 
---- callbacks -----
function OperTipsView:OnHuClick()
	local tbl = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.Hu)
	mahjong_play_sys.HuPaiReq(tbl.nCard or tbl.card)
end

function OperTipsView:OnTingClick() 
	local tbl = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.Ting)  
	Notifier.dispatchCmd(cmdName.MAHJONG_TING_CARD, tbl)
end

function OperTipsView:OnYingBaoClick() 
	mahjong_play_sys.TingReq()
end

function OperTipsView:OnQiangTingClick() 
	local tbl = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.QiangTing)
	mahjong_play_sys.QiangTingReq(tbl)
end

--明提
function OperTipsView:OnMTClick()
	Trace("Onbtn_MTClick")
	local tbl = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.MT) 
	Notifier.dispatchCmd(cmdName.MAHJONG_TING_CARD, tbl)
end

function OperTipsView:OnXiaoClick()
    local tbl = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.Xiao) 
	Notifier.dispatchCmd(cmdName.MAHJONG_TING_CARD, tbl)
end

function OperTipsView:OnNiuBiJiaoClick()
    local tbl = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.NiuBiJiao) 
	Notifier.dispatchCmd(cmdName.MAHJONG_TING_CARD, tbl)
end

function OperTipsView:OnLiangXiErClick()
    local tbl = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.LiangXiEr) 
	mahjong_play_sys.LiangXiErReq(tbl)
end

function OperTipsView:OnTianTingClick() 
	local tbl = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.TianTing)  
	Notifier.dispatchCmd(cmdName.MAHJONG_TING_CARD, tbl)
end

function OperTipsView:OnLiangClick() 
	local tbl = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.Liang)  
	Notifier.dispatchCmd(cmdName.MAHJONG_TING_CARD, tbl)
end

function OperTipsView:OnTingJinKanClick()
	local tbl = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.TingJinKan)
	Notifier.dispatchCmd(cmdName.MAHJONG_TING_CARD, tbl)
end

function OperTipsView:OnTingYouJinClick()
	local tbl = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.TingYouJin)
	Notifier.dispatchCmd(cmdName.MAHJONG_TING_CARD, tbl)
end

function OperTipsView:OnTingDouJinClick()
	local tbl = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.TingDouJin)
	Notifier.dispatchCmd(cmdName.MAHJONG_TING_CARD, tbl)
end

function OperTipsView:OnTingThrJinClick()
	local tbl = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.TingThrJin)
	Notifier.dispatchCmd(cmdName.MAHJONG_TING_CARD, tbl)
end

function OperTipsView:OnGangClick()
	Trace("Onbtn_gangClick")
	local cardCanQuadruplet = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.Quadruplet)
	if #cardCanQuadruplet ~= 1 and type(cardCanQuadruplet[1]) ~= "number" then
		mahjong_ui.cardShowView:ShowGang(cardCanQuadruplet)
	else
		-- 风杠
		if #cardCanQuadruplet == 4 and type(cardCanQuadruplet[1]) == "number" then
			mahjong_play_sys.QuadrupletReq(cardCanQuadruplet)
		else
			local cardValues = cardCanQuadruplet[1]
			if type(cardValue) == "number" then
		      cardValues = {cardValues,cardValues,cardValues,cardValues}
		   	end
		  	mahjong_play_sys.QuadrupletReq(cardValues)
		end
	end

end

function OperTipsView:OnPengClick()
	--Trace("Onbtn_pengClick")
	mahjong_play_sys.TripletReq()
end

--边
function OperTipsView:OnBianClick()
	Trace("Onbtn_OnBianClick")
	roomdata_center.nbzz = 4
	roomdata_center.isNeedOutCard = true
	--将手牌与最后所摸到的牌能够组成边的牌型置为不能点击
	OperTipsView:SetBZZCardsState(roomdata_center.nbzz,nil)
end

--钻
function OperTipsView:OnZuanClick()
	Trace("Onbtn_OnZuanClick")
	roomdata_center.nbzz = 2
	roomdata_center.isNeedOutCard = true
	OperTipsView:SetBZZCardsState(roomdata_center.nbzz,nil)
end

--砸
function OperTipsView:OnZaClick()
	Trace("Onbtn_OnZaClick")
	roomdata_center.nbzz = 1
	local cardCanTriplet = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.N_ZA_FLAG)
	if cardCanTriplet ~= nil then
		mahjong_play_sys.TripletReq(nil, roomdata_center.nbzz)
	else
		roomdata_center.isNeedOutCard = true
		OperTipsView:SetBZZCardsState(roomdata_center.nbzz,nil)
	end
end

--砸杠
function OperTipsView:OnZagangClick()
	Trace("Onbtn_OnZagangClick")
	roomdata_center.nbzz = 1
	local cardCanQuadruplet = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.N_ZAGANG_FLAG)
	Trace("type(cardCanQuadruplet[1]) == "..json.encode(cardCanQuadruplet[1]))

	if #cardCanQuadruplet == 1 then
	  	mahjong_play_sys.QuadrupletReq(cardCanQuadruplet[1],roomdata_center.nbzz)
	elseif #cardCanQuadruplet == 4 and type(cardCanQuadruplet[1]) == "number" and type(cardCanQuadruplet[2]) == "number" and type(cardCanQuadruplet[3]) == "number" and type(cardCanQuadruplet[4]) == "number" then
		mahjong_play_sys.QuadrupletReq(cardCanQuadruplet,roomdata_center.nbzz)
	else
	  	mahjong_ui.cardShowView:ShowGang(cardCanQuadruplet)
	end
end


function OperTipsView:OnQiangClick()
	Trace("Onbtn_qiangClick")
	local tbl = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.Qiang)
	mahjong_play_sys.HuPaiReq(tbl.nCard)
end

function OperTipsView:OnChiClick()
	Trace("Onbtn_chiClick")
	local cardCanCollect = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.Collect)
	if #cardCanCollect == 1 then
		mahjong_play_sys.CollectReq(cardCanCollect[1])
	else
		mahjong_ui.cardShowView:ShowChi(cardCanCollect)
	end
end

function OperTipsView:OnGuoClick()
	Trace("Onbtn_guoClick")
	mahjong_play_sys.GiveUp()
  	Notifier.dispatchCmd(cmdName.MSG_ON_GUO_CLICK, nil)
end

function OperTipsView:SetGuoBtnActive(value)
	local btnGo = self:GetGameObject("Grid/guo")
	btnGo:SetActive(value)
end


--根据最后摸到的一张牌生成边钻砸的牌型
function OperTipsView:SetBZZCardsState(nbzz, bGangFlag)
	local compPlayerMgr = mode_manager.GetCurrentMode():GetComponent("comp_playerMgr")
	local handCardList = compPlayerMgr.selfPlayer.handCardList
	local lastCardItem = handCardList[table.getn(handCardList)]
	local nCard = lastCardItem.paiValue

    local stCards = {}

    if nbzz == 4 then
        if (0< nCard and nCard < 30 and nCard%10 == 3) or nCard == 37 then
	        stCards = {nCard-2,nCard-1}    		
        elseif (0< nCard and nCard < 30 and nCard%10 == 7) then
            stCards = {nCard+1,nCard+2}
        end
    elseif nbzz == 2 then
    	if ( 0 < nCard and nCard < 30 and 1 < nCard%10 and nCard % 10 < 9) or nCard == 36 then
	    	stCards = {nCard-1,nCard+1}
    	end
    else		
        stCards = {nCard,nCard}
    end
 	--将手牌与最后所摸到的牌能够组成边的牌型置为不能点击
    local targetCards = self:GetSelfCardsByCardValueList(stCards, false)

    if lastCardItem then
    	table.insert(targetCards, lastCardItem)
    end

    for i,v in ipairs(targetCards) do
    	v:SetDisable(true)
    end
end

-- 获取自己手牌中指定列表的手牌索引
function OperTipsView:GetSelfCardsByCardValueList(cardValues, reverse)
    local count = #cardValues
    if count == 0 then
        return nil
    end

    local compPlayerMgr = mode_manager.GetCurrentMode():GetComponent("comp_playerMgr")
    local tmpHandCardList = compPlayerMgr.selfPlayer.handCardList
    local beginInex = (reverse and #tmpHandCardList) or 1
    local step = (reverse and -1) or 1
    local endIndex = (reverse and 1) or #tmpHandCardList
    local targetList = {}
    for i = 1, #cardValues do
        for j = beginInex, endIndex, step do
            if cardValues[i] == tmpHandCardList[j].paiValue and not table.contains(targetList,tmpHandCardList[j]) then
                table.insert(targetList, tmpHandCardList[j])
                break
            end
        end
    end
    if #targetList ~= #cardValues then
        logError('补花异常，数目不对应', #cardValues, #targetList)
    end

    return targetList
end


return OperTipsView
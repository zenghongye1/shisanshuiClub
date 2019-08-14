--[[--
 * @Description: 发牌下来时判断特殊牌型
 * @Author:      zhy
 * @FileName:    prepare_special.lua
 * @DateTime:    2017-07-05
 ]]

local base = require("logic.framework.ui.uibase.ui_window")
local special_card_show = class("special_card_show",base)

function special_card_show:ctor()
	base.ctor(self)
	self.timeSecond = 3		--最大等待时间
	self.my_cards = {}		--所有牌
	self.cardTranTbl = {}
	self.animalPar = nil
	self.timeDelt = 0
	self.tex_photo = nil
	self.NameLbl = nil
	self.cardGrid = nil
end

function special_card_show:OnInit()
	 self:initinfor()
end

function special_card_show:OnOpen(...)
	self:OnClose()
	local cards = {}
	local nSpecialType = nil
	local viewSeat = nil
	local show_time = 0
	if self.args == nil or #self.args < 3 then
		Trace("特殊牌型参数传的错。请检查参数个数")
	end
	cards = self.args[1]
	nSpecialType = self.args[2]
	viewSeat = self.args[3]
	show_time = self.args[4]
	
	--cards = Array.CardSort(cards, nSpecialType)	--服务器排好序
	self.timeSecond = show_time		--显示时间
	self:StartTimer_Dis()
	Trace("---------special_card_show------"..GetTblData(cards))
	self.my_cards = cards
	self:LoadUserInfo(viewSeat)
	self.cardGrid.gameObject:SetActive(true)
	self:LoadAllCard(cards)
	self:SetSpecialAnimationPlay(nSpecialType)
end

function special_card_show:OnRefreshDepth()
  if self.effect and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(self.effect.gameObject, topLayerIndex)
  end
end

function special_card_show:OnClose()
	self:StopTime_Dis()
	if table.nums(self.cardTranTbl) ~= 0 then
		for i, v in pairs(self.cardTranTbl) do
			if v ~= nil then
				v.gameObject.transform.parent = nil
				v.gameObject:SetActive(false)
				GameObject.Destroy(v.gameObject)
			end
		end
		self.grid:Reposition()
		self.cardGrid.gameObject:SetActive(false)
		self.cardTranTbl = {}
	end
	self.effect = nil
end

function special_card_show:initinfor()
	self.animalPar = child(self.transform, "animalPar")
	self.tex_photo= componentGet(child(self.transform, "head/headPic"), "UITexture")
	self.NameLbl = componentGet(child(self.transform,"head/Label"), "UILabel")
	self.cardGrid = child(self.transform, "cardGrid")
	self.grid =  componentGet(self.cardGrid,"UIGrid")
end

function special_card_show:LoadAllCard(cards)
	if self.cardGrid == nil then
		Trace("cardGrid == nil")
		return
	end
	for i, v in pairs(cards) do
		local cardObj = poker2d_factory.GetPoker(tostring(v))
		cardObj.transform:SetParent(self.cardGrid,false)
		self.cardTranTbl[i] = cardObj
		componentGet(child(self.cardTranTbl[i].transform, "bg"),"UISprite").depth = i * 2 + 3
		componentGet(child(self.cardTranTbl[i].transform, "num"),"UISprite").depth = i * 2 + 5
		componentGet(child(self.cardTranTbl[i].transform, "color1"),"UISprite").depth = i * 2 + 5
		componentGet(child(self.cardTranTbl[i].transform, "color2"),"UISprite").depth = i * 2 + 5
		if roomdata_center.gamesetting["nBuyCode"] > 0 and v == card_define.GetCodeCard() then
			child(self.cardTranTbl[i].transform,"ma").gameObject:SetActive(true)
			componentGet(child(self.cardTranTbl[i].transform, "ma"),"UISprite").depth = i * 2 + 4
		end
	end
	self.grid:Reposition()
end

function special_card_show:SetSpecialAnimationPlay(nSpecialType)
	local gid = player_data.GetGameId()
	local sex = 0	---男女声待添加
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/cardtpye_girl/specialtype/"..card_define.GetSpecialTypeMusicConfig(nSpecialType,gid,sex))
	--animations_sys.PlayAnimation(self.animalPar,data_center.GetResRootPath().."/effects/special_card_type",card_define.GetSpecialAnimalName(nSpecialType,gid),100,100,false, callback)
	self.effect =  EffectMgr.PlayEffect(data_center.GetResRootPath().."/effects/Effect_shisanshuipaixing",1,1)
	subComponentGet(self.effect.transform,"donghua/qimage6/qimage6","UISprite").spriteName = tostring(nSpecialType)
	self.effect.transform:SetParent(self.animalPar,false)
end

function special_card_show:StartTimer_Dis()	
	self.disTimer_Elapse = Timer.New(slot(self.OnTimer_Proc_Dis,self),0.1,self.timeSecond)
	self.disTimer_Elapse:Start()
end

function special_card_show:OnTimer_Proc_Dis()
	self.timeSecond = self.timeSecond -0.1;
	if self.timeSecond <= 0 then
		UI_Manager:Instance():CloseUiForms("special_card_show")
		self:StopTime_Dis()
	end
end

function special_card_show:StopTime_Dis()
	if self.disTimer_Elapse ~= nil then
		self.disTimer_Elapse:Stop()
		Trace("重连解散定时器关")
		self.disTimer_Elapse = nil
	end
end

function special_card_show:LoadUserInfo(viewSeat)
	local userData = room_usersdata_center.GetUserByViewSeat(viewSeat)
	self.NameLbl.text = userData.name
	HeadImageHelper.SetImage(self.tex_photo,2,userData.headurl)
end

function special_card_show:PlayOpenAmination()
	--打开动画重写
end

return special_card_show

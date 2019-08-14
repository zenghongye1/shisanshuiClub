--[[--
 * @Description: 发牌下来时判断特殊牌型
 * @Author:      zhy
 * @FileName:    prepare_special.lua
 * @DateTime:    2017-07-05
 ]]

local base = require("logic.framework.ui.uibase.ui_window")
local common_card = class("common_card",base)
local timer_Show = nil

function common_card:ctor()
	base.ctor(self)
	--最大等待时间
	self.timeSecond = 3
	--所有牌
	self.my_cards = {}

	self.cardTranTbl = {}
	--特殊牌型
	self. card_type = nil

	self.card_type_bg = nil
end 

function common_card:OnInit()
   self:initinfor()
end

function common_card:OnOpen( ... )
	self:OnClose()
	if self.args ~= nil and table.nums(self.args) == 5 then
		local cards = self.args[1]
		local nType = self.args[2]
		local pos = self.args[3]
		local localSecond = self.args[4]
		local index = self.args[5]
		self:Show(cards, nType, pos, localSecond,index)
		self:SetShowTimer()
	end
end

function common_card:initinfor()
	self.card_type_bg = componentGet(child(self.transform,"bg"),"UISprite")
end

function common_card:Show(cards, nType, pos, localSecond,index)
	Trace("common_card显示普通牌型---------------"..tostring(nType))
	if not isEmpty(self.cardTranTbl)then
		for i, v in pairs(self.cardTranTbl) do
			if v ~= nil then
				v.gameObject.transform.parent = nil
				v.gameObject:SetActive(false)
				GameObject.Destroy(v.gameObject)
			end
		end
		self.cardTranTbl = {}
	end
	self.transform.localPosition = pos
	if localSecond ~= nil then
		self.timeSecond =0.65
	else
		self.timeSecond =0.65
	end
	self:LoadAllCard(cards,nType)
	self:SetCardTypeShow(cards,nType,index)
	self.transform.localScale = Vector3.New(1, 1, 1)
	self.transform:DOScale(Vector3(1.1, 1.1, 1.1), 0.2):SetEase(DG.Tweening.Ease.Linear):OnComplete(function ()
			self.transform:DOScale(Vector3(1,1,1), 0.2):SetEase(DG.Tweening.Ease.Linear)
		end)
end

function common_card:SetCardTypeShow(cards,nType,index)
	local gid = player_data.GetGameId()
	
	if tonumber(nType) == 4 or tonumber(nType) == 6 or tonumber(nType) == 7 then 
		if index == 1 then
			--平潭十三水三条在首墩叫冲三
			nType = 104
		end
	elseif tonumber(nType) == 11 then
		if index == 2 then
			--葫芦在中墩叫中墩葫芦
			nType = 111
		end
	end

	local sex = 0	---男女声待添加
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/cardtpye_girl/normaltype/"..card_define.GetNormalTypeMusicConfig(nType,gid,sex))
	self.card_type_bg.spriteName = card_define.GetNormalTypeSpriteName(nType,gid)
end

function common_card:LoadAllCard(cards,nType)
	local min = 1
	local max = 5
	if #cards == 3 then
		min = 2
		max = 4
	end
	for i = 1, #cards do
		local cardParent = child(self.transform, "cardGrid/"..tostring(min))
		min = min + 1
		if cardParent == nil then
			print("cardGrid == nil")
			return
		end
		local cardObj = poker2d_factory.GetPoker(tostring(cards[i]))
		cardObj.transform:SetParent(cardParent,false)
		self.cardTranTbl[i] = cardObj
		cardObj.transform.localRotation = Quaternion.identity
		componentGet(child(self.cardTranTbl[i].transform, "bg"),"UISprite").depth = i * 2 + 3
		componentGet(child(self.cardTranTbl[i].transform, "num"),"UISprite").depth = i * 2 + 5
		componentGet(child(self.cardTranTbl[i].transform, "color1"),"UISprite").depth = i * 2 + 5
		componentGet(child(self.cardTranTbl[i].transform, "color2"),"UISprite").depth = i * 2 + 5
		if roomdata_center.gamesetting["nBuyCode"] > 0 and cards[i] == card_define.GetCodeCard() then
			child(self.cardTranTbl[i].transform,"ma").gameObject:SetActive(true)
			componentGet(child(self.cardTranTbl[i].transform,"ma"),"UISprite").depth = i * 2 + 4
		end
	end	
end

function common_card:SetShowTimer()
	if timer_Show == nil then
		local timeDelt = 0.1
		timer_Show = Timer.New(function()
				self.timeSecond =  self.timeSecond - timeDelt
				if self.timeSecond <= 0 then
					UI_Manager:Instance():CloseUiForms("common_card")
				end
			end,timeDelt,self.timeSecond)
		timer_Show:Start()
	end
end

function common_card:PlayOpenAmination()
	--打开动画重写
end

function common_card:OnClose()
	if timer_Show ~= nil then
		timer_Show:Stop()
		timer_Show = nil
	end
end

--[[function common_card:Update()
	if self.timeSecond <= 0 then
	--	this.gameObject:SetActive(false)
		UI_Manager:Instance():CloseUiForms("common_card")
		return
	end
	local timeDelt = Time.deltaTime
	self.timeSecond =  self.timeSecond - timeDelt
	if math.floor(self.timeSecond) < 0 then
		self.timeSecond = 0
	end
end--]]

return common_card

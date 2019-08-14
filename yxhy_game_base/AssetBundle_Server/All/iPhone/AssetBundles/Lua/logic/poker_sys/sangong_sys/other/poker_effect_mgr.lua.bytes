require "logic.poker_sys.sangong_sys.other.sangong_rule_define"
local poker_effect_mgr = class("poker_effect_mgr")
function poker_effect_mgr:ctor()
	self.effectTable = {}
end

function poker_effect_mgr:playSanGongEffect(parent,data,scale)
	local cardType = data.nCardType
	local beishui = data.nBeishu
	local nCardType = sangong_rule_define.PT_SANGONG_CardType[cardType]
	local BGAnim = nCardType.bgAnim
	local CardTypeImage = nCardType.nCardType
	local BeiShuImage = nCardType["nBeishu_"..tostring(beishui)]
	local bgImage = nCardType.bgImage
	
	local effectCardType = EffectMgr.PlayEffect(data_center.GetResRootPath().."/effects/"..nCardType.nCardTypeAnim,1,-1)
	table.insert(self.effectTable,effectCardType)
	effectCardType.transform:SetParent(parent,false)
	effectCardType.transform.localScale = Vector3(scale,scale,scale)
	if BGAnim ~= nil then
		local effectBG = EffectMgr.PlayEffect(data_center.GetResRootPath().."/effects/"..tostring(BGAnim),1,-1)
		table.insert(self.effectTable,effectBG)
		effectBG.transform:SetParent(parent,false)
		effectBG.transform.localScale = Vector3(scale,scale,scale)
	end
	local ziImageSprite = componentGet(child(effectCardType.transform,"donghua/Zhi"),"UISprite")
	local beishuImageSprite = componentGet(child(effectCardType.transform,"donghua/beishou"),"UISprite")
	local bgImageSprite = componentGet(child(effectCardType.transform,"dicheng"),"UISprite")
	ziImageSprite.spriteName = CardTypeImage
	if beishuImageSprite ~= nil then
		if BeiShuImage == nil then
			beishuImageSprite.transform.gameObject:SetActive(false)
		else
			beishuImageSprite.transform.gameObject:SetActive(true)
			beishuImageSprite.spriteName = BeiShuImage
		end
		beishuImageSprite:MakePixelPerfect()
	end
	bgImageSprite.spriteName = bgImage
	ziImageSprite:MakePixelPerfect()
	bgImageSprite:MakePixelPerfect()
end

function poker_effect_mgr:playNiuNiuEffect(parent,data,scale)
	
end

function poker_effect_mgr:stopEffects()
	for i,v in ipairs(self.effectTable) do
		EffectMgr.StopEffect(v)
	end
	self.effectTable = {}
end

return poker_effect_mgr
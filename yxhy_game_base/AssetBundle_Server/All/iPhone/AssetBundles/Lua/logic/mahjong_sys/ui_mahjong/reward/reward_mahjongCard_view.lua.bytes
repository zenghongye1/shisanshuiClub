local base = require "logic/framework/ui/uibase/ui_view_base"
local reward_mahjongCard_view = class("reward_mahjongCard_view", base)

function reward_mahjongCard_view:InitView()
	self.opercardList = {}
	self.handcard = nil
end

function reward_mahjongCard_view:SetMahjongList(info,isWin,specialCardValues,specialCardType,pool_ui)
	local distance = 151
	for i=1,#self.opercardList do
		pool_ui:RecycleOperCard(self.opercardList[i])
	end
	self.opercardList = {}
	for i=1,#info.valueList do
		local operItem = pool_ui:GetOperCard()
		operItem:SetActive(true)
		operItem.transform.parent = self.transform
		operItem.transform.localPosition = Vector3((i-1)*distance,0,0)
		operItem.transform.localScale = Vector3.one
		operItem:SetInfo(info.valueList[i],specialCardValues,specialCardType) -- 金的值，待优化
		table.insert(self.opercardList,operItem)
	end
	if self.handcard==nil or IsNil(self.handcard.gameObject) then
		self.handcard = pool_ui:GetHandCard()
		self.handcard:SetActive(true)
	end
	self.handcard.transform.parent = self.transform
	self.handcard.transform.localPosition = Vector3((#info.valueList)*distance,0,0)
	self.handcard.transform.localScale = Vector3.one
	self.handcard:SetInfo(info.handCards,isWin,specialCardValues,specialCardType) -- 金的值，待优化
end

return reward_mahjongCard_view
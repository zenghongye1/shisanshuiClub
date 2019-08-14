local base = require "logic/framework/ui/uibase/ui_view_base"
local mahjong_opercard_view = class("mahjong_opercard_view", base)
local mjItem_view = require "logic/mahjong_sys/ui_mahjong/reward/reward_mjItem_view"

function mahjong_opercard_view:InitView()
	self.itemList = {}
	for i = 1, 4 do
		local item = mjItem_view:create(self:GetGameObject("item" .. i))
		table.insert(self.itemList, item)
	end
	--杠牌
	self.itemList[4]:SetActive(false)
end

function mahjong_opercard_view:SetInfo(valueList,specialCardValue,specialCardType)
	for i=1,#valueList do
		self.itemList[i]:SetActive(true)
		self.itemList[i]:SetValue(valueList[i])
		self.itemList[i]:SetSpecialCard(false)
		for _,v in ipairs(specialCardValue or {}) do
			if v == valueList[i] then
				self.itemList[i]:SetSpecialCard(true,specialCardType)
				break
			end
		end
	end
	if 3 == #valueList then
		self.itemList[4]:SetActive(false)
	end
end

return mahjong_opercard_view
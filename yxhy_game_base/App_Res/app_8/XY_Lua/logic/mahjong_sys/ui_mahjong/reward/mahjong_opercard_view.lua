local base = require "logic/mahjong_sys/ui_mahjong/reward/ui_view_base"
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

function mahjong_opercard_view:SetInfo(operData,specialCardValue)
	local valueList = {}
	if operData.ucFlag == 16 then
		table.insert(valueList,operData.card)
        table.insert(valueList,operData.card+1)
        table.insert(valueList,operData.card+2)
	elseif operData.ucFlag == 17 then
		table.insert(valueList,operData.card)
        table.insert(valueList,operData.card)
        table.insert(valueList,operData.card)
	elseif operData.ucFlag == 18 then
		table.insert(valueList,operData.card)
        table.insert(valueList,operData.card)
        table.insert(valueList,operData.card)
        table.insert(valueList,operData.card)
	elseif operData.ucFlag == 19 then
		table.insert(valueList,0)
        table.insert(valueList,0)
        table.insert(valueList,0)
        table.insert(valueList,operData.card)
	elseif operData.ucFlag == 20 then
		table.insert(valueList,operData.card)
        table.insert(valueList,operData.card)
        table.insert(valueList,operData.card)
        table.insert(valueList,operData.card)
	end

	for i=1,#valueList do
		self.itemList[i]:SetActive(true)
		self.itemList[i]:SetValue(valueList[i])
		if specialCardValue and specialCardValue == valueList[i] then
			self.itemList[i]:SetSpecialCard(true)
		else
			self.itemList[i]:SetSpecialCard(false)
		end
	end
	if 3 == #valueList then
		self.itemList[4]:SetActive(false)
	end
end

return mahjong_opercard_view
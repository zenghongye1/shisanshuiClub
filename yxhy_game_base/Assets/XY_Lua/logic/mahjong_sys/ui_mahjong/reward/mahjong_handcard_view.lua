local base = require "logic/framework/ui/uibase/ui_view_base"
local mahjong_handcard_view = class("mahjong_handcard_view", base)
local mjItem_view = require "logic/mahjong_sys/ui_mahjong/reward/reward_mjItem_view"

function mahjong_handcard_view:InitView()
	self.itemList = {}
	self.item_EX = child(self.transform, "item").gameObject
	--table.insert(self.itemList, item)
	self.item_EX.gameObject:SetActive(false)
end

function mahjong_handcard_view:SetInfo(handData,isWin,specialCardValue,specialCardType)
	local distance = 46

	local itemIndex = 1
	for i=1,#handData do
		local item
		if i <= #self.itemList then
			item = self.itemList[itemIndex]
			itemIndex = itemIndex + 1
		else
			local go = newobject(self.item_EX)
			item = mjItem_view:create(go)
			table.insert(self.itemList,item)
		end
		item:SetActive(true)
		item.transform.parent = self.transform
		item.transform.localPosition = Vector3((i-1)*distance,0,0)
		item.transform.localScale = Vector3.one
		item:SetValue(handData[i])

		item:SetSpecialCard(false)
		for _,v in ipairs(specialCardValue or {}) do
			if v == handData[i] then
				item:SetSpecialCard(true,specialCardType)
				break
			end
		end

		if isWin and (#handData == i) then
			item.transform.localPosition = item.transform.localPosition + Vector3(18,0,0)
			item:SetWin(true)
		else
			item:SetWin(false)
		end

	end

	for i = #handData + 1,#self.itemList do
		self.itemList[i]:SetActive(false)
	end
end

return mahjong_handcard_view
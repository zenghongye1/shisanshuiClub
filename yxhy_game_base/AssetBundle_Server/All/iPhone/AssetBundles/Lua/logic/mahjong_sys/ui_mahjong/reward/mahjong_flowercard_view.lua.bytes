local base = require "logic/framework/ui/uibase/ui_view_base"
local mahjong_flowercard_view = class("mahjong_flowercard_view", base)
local mjItem_view = require "logic/mahjong_sys/ui_mahjong/reward/reward_mjItem_view"

function mahjong_flowercard_view:InitView()
	self.itemList = {}
	self.item_EX = child(self.transform, "item").gameObject
	--table.insert(self.itemList, item)
	self.item_EX.gameObject:SetActive(false)
	self.scrollView = self:GetComponent("Scroll View", typeof(UIScrollView)) 
	self.flowerItemsGrid = self:GetComponent("Scroll View/Grid", typeof(UIGrid)) 
	self.flowerItemRecycleList = {}
	self.scrollView.onDragStarted = function ()
		self.isScroll = false
	end
	self.count = 0
end

function mahjong_flowercard_view:SetInfo(handData)
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
		--item:SetActive(true)
		item.transform.parent = self.flowerItemsGrid.transform
		item.transform.localPosition = Vector3((i-1)*distance,0,0)
		item.transform.localScale = Vector3.one
		item:SetValue(handData[i])
	end

	for i = #handData + 1,#self.itemList do
		self.itemList[i]:SetActive(false)
	end

	self.flowerItemsGrid:Reposition()
	self.scrollView:ResetPosition()

	local co = coroutine.start(function ()
		coroutine.step()
		for i=1,#handData do
			local item = self.itemList[i]
			item:SetActive(true)
		end
	end)
	self.flowerItemsGrid.transform.localPosition = Vector3(-67.6,0,0)

	self.count = #handData
	if #handData > 3 then
		self:StartScroll()
	else
		self.isScroll = false
	end
end

function mahjong_flowercard_view:StartScroll()
	self.isScroll = true
    if self.cor==nil then
	    self.cor=coroutine.create(function ()
		    while true do   
		        self:MoveGrid()
		        coroutine.wait(0.01)   
	            if self.isScroll == false then 
	                coroutine.yield() 
	            end 
		    end
	    end)
    end
    coroutine.resume(self.cor) 
end

function mahjong_flowercard_view:MoveGrid()
	local tr = self.flowerItemsGrid.transform
	local x_offset = tr.localPosition.x - 2
	if x_offset < (-67.6 - self.count*39) then
		x_offset = 70
	end
	LuaHelper.SetTransformLocalX(tr, x_offset)
end

function mahjong_flowercard_view:Clear()
	self.isScroll = false
    coroutine.stop(self.cor)
    self.cor=nil 
end

return mahjong_flowercard_view
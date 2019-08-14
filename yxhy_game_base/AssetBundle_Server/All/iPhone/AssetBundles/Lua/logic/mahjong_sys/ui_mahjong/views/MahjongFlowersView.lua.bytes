local base = require "logic/framework/ui/uibase/ui_view_base"
local MahjongFlowersView = class("MahjongFlowersView", base)

local MahjongFlowersItemView = class("MahjongFlowersView", base)
MahjongFlowersView.itemPool = {}
MahjongFlowersView.hasInitPos = false
MahjongFlowersView.Seat4ScreenPosList = {}
MahjongFlowersView.Seat2ScreenPosList = {}

function MahjongFlowersItemView:InitView()
	self.iconSp = self:GetComponent("icon", typeof(UISprite))
	self.numGo = self:GetGameObject("numGo")
	self.numGo:SetActive(false)
	self.numLabel = self:GetComponent("numGo/Label", typeof(UILabel))
end

function MahjongFlowersItemView:SetInfo(num, count,isSp)
	local spriteName = tostring(num)
	if isSp then
		spriteName = spriteName.."_y"
	end
	self.iconSp.spriteName = spriteName
	self.iconSp:MakePixelPerfect()
	self.numGo:SetActive(count > 1)
	self.numLabel.text = tostring(count)
end


function MahjongFlowersView.InitPool(itemGo)
	itemGo:SetActive(false)
	MahjongFlowersView.itemGo = itemGo
end


function MahjongFlowersView:ctor(go, index)
	self.itemList = {}
	self.flowerCardList = {}
	self.flowerCardCountMap = {}
	self.index = index
	base.ctor(self, go)
end

function MahjongFlowersView:SetFlowers(flowercards,specialFlowers)
	if MahjongFlowersView.hasInitPos == false then
		return
	end
	self.flowerCardList = {}
	self.flowerCardCountMap = {}
	for i = 1, #self.itemList do
		MahjongFlowersView.RecycleItem(self.itemList[i], true)
	end
	self.itemList = {}

	if flowercards == nil or #flowercards == 0 then
		return
	end
	for i = 1, #flowercards do
		if self.flowerCardCountMap[flowercards[i]] ~= nil then
			self.flowerCardCountMap[flowercards[i]] = self.flowerCardCountMap[flowercards[i]] + 1
		else
			self.flowerCardCountMap[flowercards[i]] = 1
			table.insert(self.flowerCardList, flowercards[i])
		end
	end

	-- table.sort(self.flowerCardList, MahjongFlowersView.CardSortFunc)
	for i = 1, #self.flowerCardList do
		local item = MahjongFlowersView.GetItem()
		item.transform:SetParent(self.transform, false)
		self:SetItemPos(item, i)
		item:SetInfo(self.flowerCardList[i], self.flowerCardCountMap[self.flowerCardList[i]],IsTblIncludeValue(self.flowerCardList[i],specialFlowers or {}))
		self.itemList[i] = item
	end
end

function MahjongFlowersView:SetItemPos(item , index)
	local startPos = Vector3.zero
	if self.index == 1 then
		startPos.x = (index - 1) * 36
	elseif self.index == 3 then
		startPos.x = - (index - 1) * 36
	elseif self.index == 4  then
		startPos = self:Set24Pos(MahjongFlowersView.Seat4ScreenPosList,index, true)
		--local pos = self.transform:InverseTransformPoint(MahjongFlowersView.Seat4ScreenPosList[index] or Vector3.zero)
		-- local pos = MahjongFlowersView.Seat4ScreenPosList[index]
		-- startPos.x = MahjongFlowersView.Seat4ScreenPosList[1].x + (pos.x - MahjongFlowersView.Seat4ScreenPosList[1].x) * ((index - 1) * 40 / ()
		-- startPos.y = MahjongFlowersView.Seat4ScreenPosList[1].y - (index - 1) * 40
	elseif self.index == 2 then
		startPos = self:Set24Pos(MahjongFlowersView.Seat2ScreenPosList, index, false)
		-- local pos = MahjongFlowersView.Seat2ScreenPosList[index]  
		-- startPos.x = pos.x
		-- startPos.y = MahjongFlowersView.Seat2ScreenPosList[1].y + (index - 1) * 40
	end
	item.transform.localPosition = startPos
end

function MahjongFlowersView:Set24Pos(posList, index, minus)
	if index == 1 then
		return posList[1]
	end
	local pos1 = posList[1]
	local posNow = posList[index]
	local h = posNow.y - pos1.y
	local H = (index - 1) * 36
	local w = posNow.x - pos1.x 
	local startPos = Vector3.zero
	startPos.x = pos1.x + w * H / h * (minus and -1 or 1)
	startPos.y =  pos1.y + H * (minus and -1 or 1)
	return startPos
end

function MahjongFlowersView:Clear()
	for i = 1, #self.itemList do
		MahjongFlowersView.RecycleItem(self.itemList[i], true)
	end
	self.itemList = {}
end


function MahjongFlowersView.CardSortFunc(a, b)
	if a == 37 then
		return false
	end
	if b == 37 then
		return true
	end

	if a == b then
		return false
	end

	return a > b
end

function MahjongFlowersView.GetItem()
	local item
	if #MahjongFlowersView.itemPool > 0 then
		item = MahjongFlowersView.itemPool[#MahjongFlowersView.itemPool]
		table.remove(MahjongFlowersView.itemPool, #MahjongFlowersView.itemPool)
	else
		item = MahjongFlowersItemView:create(newobject(MahjongFlowersView.itemGo))
	end
	item:SetActive(true)
	return item
end


function MahjongFlowersView.RecycleItem(item, hide)
	if hide then
		item:SetActive(false)
	end
	table.insert(MahjongFlowersView.itemPool, item)
end


return MahjongFlowersView

vote_quit_view = {}


local LuaHelper = LuaHelper
local NGUITools = NGUITools


vote_quit_view.__index = vote_quit_view

function vote_quit_view.New()
    local self = {}
    setmetatable(self, vote_quit_view)
    return self
end


function  vote_quit_view:SetTransform( tr )
	self.transform = tr;
	self.go = tr.gameObject
	self:InitView()
	-- self.currnetNum = 0
end



function vote_quit_view:Hide()
	for i = 1, #self.itemList do
		self.itemList[i]:SetActive(false)
	end
	self.itemLeftGo:SetActive(false)
	self.itemRightGo:SetActive(false)
	self.go:SetActive(false)
end

function vote_quit_view:Show(playerNum)
	self.go:SetActive(true)
	self:SetPlayerCount(playerNum)
end

function vote_quit_view:AddVote(value, viewSeat)
	
	if self.playerNum == nil or viewSeat > self.playerNum then
		return
	end
	-- if self.currnetNum == nil then
	-- 	self.currnetNum = 0
	-- end
	-- self.currnetNum = self.currnetNum + 1
	-- if self.currnetNum > self.playerNum then
	-- 	return
	-- end
	if viewSeat == 1 then
		self:SetSpecialItemState(self.itemLeftGo, value, true)
	elseif viewSeat == self.playerNum then
		self:SetSpecialItemState(self.itemRightGo, value, false)
	else
		self:SetItemState(self.itemList[viewSeat - 1], value)
		LuaHelper.SetTransformLocalXY(self.itemList[viewSeat - 1].transform ,self.startX + self.itemWidth * (viewSeat - 1), self.itemGo.transform.localPosition.y)
	end
end




function vote_quit_view:SetPlayerCount(playerCount)
	self.playerNum = playerCount
	-- 当前有几个人投票
	-- self.currnetNum = 0
	-- 除去头和尾
	self:UpdateChildList(self.itemList, playerCount - 2, self.go, self.itemGo)
	self.itemLeftGo:SetActive(false)
	self.itemRightGo:SetActive(false)

	self.itemWidth = self.totalWidth / playerCount
	self:UpdateItemWidth(self.itemLeftGo, self.itemWidth)
	self:UpdateItemWidth(self.itemRightGo, self.itemWidth, true)
	for i = 1, #self.itemList do
		self:UpdateItemWidth(self.itemList[i], self.itemWidth)
	end
end


----- 内部方法  ------------------


function vote_quit_view:InitView()
	self.itemList = {}
	self.itemLeftGo = child(self.transform, "itemleft").gameObject
	self.itemRightGo = child(self.transform, "itemright").gameObject
	self.itemGo = child(self.transform, "item").gameObject

	self.totalWidth = subComponentGet(self.transform, "bg", typeof(UISprite)).width -8
	self.startX = self.itemLeftGo.transform.localPosition.x
	table.insert(self.itemList, self.itemGo)
end


function vote_quit_view:UpdateChildList(itemList, count, parent, template)
	if count == 0 then
		for i = 1, #itemList do
			itemList[i]:SetActive(false)
		end
		return
	end
	local itemCount = #itemList
	if count > itemCount then
		for i = 1, count - itemCount do
			local go = NGUITools.AddChild(parent, template)
			table.insert(itemList, go)
		end
	elseif count < itemCount then
		for i = count, itemCount do
			itemList[i]:SetActive(false)
		end
	end
	for i = 1, count do
		itemList[i]:SetActive(false)
	end
end

-- 第一个和最后一个
function vote_quit_view:SetSpecialItemState(go, value, isLeft)
	go:SetActive(true)
	local bgSp = go:GetComponent(typeof(UISprite))
	local iconSp = subComponentGet(go.transform, "icon", typeof(UISprite))

	if isLeft then
		bgSp.spriteName = (value and "q12") or "q16"
	else
		bgSp.spriteName = (value and "q17") or "q18"
	end
	iconSp.spriteName = (value and "q10") or "q9"
end

function vote_quit_view:SetItemState(go, value)
	go:SetActive(true)
	local bgSp = go:GetComponent(typeof(UISprite))
	local iconSp = subComponentGet(go.transform, "icon", typeof(UISprite))

	bgSp.spriteName = (value and "q15") or "q14"
	iconSp.spriteName = (value and "q10") or "q9"
end

-- 背景图片 左对齐
function vote_quit_view:UpdateItemWidth(go, width, isRight)
	local symbol = 1
	if isRight then
		symbol = -1
	end
	local bgSp = go:GetComponent(typeof(UISprite))
	bgSp.width = width
	local iconTr = child(go.transform, "icon")
	LuaHelper.SetTransformLocalX(iconTr, width / 2 * symbol)
end




local base = require "logic/framework/ui/uibase/ui_view_base"
local HallClubSelectView = class("HallClubSelectView", base)
local ui_wrap = require "logic/framework/ui/uibase/ui_wrap"
local addClickCallbackSelf = addClickCallbackSelf
local LuaHelper = LuaHelper

local HallClubItem = class("HallClubItem", base)
function HallClubItem:InitView()
	self.icon = self:GetComponent("icon", typeof(UISprite))
	self.nameLabel = self:GetComponent("name", typeof(UILabel))
	self.mineGo = self:GetGameObject("owner")
	addClickCallbackSelf(self.icon.gameObject, self.OnItemClick, self)
end

function HallClubItem:SetCallback(callback, target)
	self.callback = callback
	self.target = target
end

function HallClubItem:SetInfo(clubInfo)
	self.info = clubInfo
	self.nameLabel.text = clubInfo.cname
	self.icon.spriteName = ClubUtil.GetClubIconName(clubInfo.icon)
	self.mineGo:SetActive(model_manager:GetModel("ClubModel"):IsClubCreater(clubInfo.cid))
end

function HallClubItem:OnItemClick()
	if self.callback ~= nil then
		self.callback(self.target, self)
	end
end

local posMap = {}
-- bgHeight, firstPosY
posMap[1] = {170, -250}
posMap[2] = {300, -125}
posMap[3] = {420, 0}


function HallClubSelectView:InitView()
	self.itemList = {}
	self.model = model_manager:GetModel("ClubModel")
	self.bgSp = self:GetComponent("bg",typeof(UISprite))
	self.maskGo = self:GetGameObject("mask")
	self.scroll = self:GetComponent("container/scrollview", typeof(UIScrollView))
	self.scroll.enabled = false

	self:InitItems()

	self.wrap = ui_wrap:create(self:GetGameObject("container"))
	self.wrap:InitUI(125)
	self.wrap.wrap.enabled = false

	self.wrap.OnUpdateItemInfo = function(go, rindex, index)self:OnItemUpdate(go, index, rindex) end

	addClickCallbackSelf(self.maskGo, function() self:SetActive(false) end, self)
end

function HallClubSelectView:SetCallback(callback, target)
	self.callback = callback 
	self.target = target
end


function HallClubSelectView:InitItems()
	for i = 1, 4 do
		local go = self:GetGameObject("container/scrollview/ui_wrapcontent/item" .. i)
		local item = HallClubItem:create(go)
		item:SetCallback(self.OnItemClick, self)
		item:SetActive(false)
		self.itemList[i] = item
	end
end

function HallClubSelectView:Show()
	if not self.model:HasClub() then
		return
	end
	self:SetActive(true)
	self:UpdateViewByCount(#self.model.clubList)
end

function HallClubSelectView:OnShow()
	if self.callback ~= nil then
		self.callback(self.target, true)
	end
end

function HallClubSelectView:OnHide(  )
	if self.callback ~= nil then
		self.callback(self.target, false)
	end
	self:HideAllItem()
end

function HallClubSelectView:UpdateViewByCount(count)
	self:HideAllItem()
	if count > 3 then
		self.bgSp.height = posMap[3][1]
		self.scroll.enabled = true
		self.wrap:InitWrap(#self.model.clubList)
	else
		self.scroll.transform.localPosition = Vector3.zero
		self.wrap.wrap.enabled = false
		self.scroll.enabled = false
		self.bgSp.height = posMap[count][1]
		local startY = posMap[count][2]
		for i = 1, count do
			LuaHelper.SetTransformLocalY(self.itemList[i].transform, startY)
			startY = startY - 125
			self.itemList[i]:SetInfo(self.model.clubList[i])
			self.itemList[i]:SetActive(true) 
		end
	end
end


function HallClubSelectView:HideAllItem()
	for i = 1, #self.itemList do
		self.itemList[i]:SetActive(false)
	end
end

function HallClubSelectView:OnItemClick(item)
	self.model:SetCurrentClubInfo(item.info, true)
	self:SetActive(false)
end

function HallClubSelectView:OnItemUpdate(go, index, rindex)
	if self.itemList[index] ~= nil then
		self.itemList[index]:SetInfo(self.model.clubList[rindex])
		self.itemList[index]:SetActive(true)
	end
end

return HallClubSelectView
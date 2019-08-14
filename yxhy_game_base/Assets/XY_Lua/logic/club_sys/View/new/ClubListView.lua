local base = require "logic/framework/ui/uibase/ui_view_base"
local addClickCallbackSelf = addClickCallbackSelf
local ui_wrap = require "logic/framework/ui/uibase/ui_wrap"
local ClubListView = class("ClubListView", base)
local ClubItem = require "logic/club_sys/View/new/ClubSelfItemView"

function ClubListView:InitView()
	self.model = model_manager:GetModel("ClubModel")

	self.itemList = {}
	self:InitItems()

	self.wrap = ui_wrap:create(self:GetGameObject("container"))
	self.wrap:InitUI(95)
	self.wrap.OnUpdateItemInfo = function(go, rindex, index)self:OnItemUpdate(go, index, rindex) end
	self.wrap:InitWrap(0)

	self.currentItem = nil
	self.curCid = 0
end


function ClubListView:InitItems()
	local itemGo = self:GetGameObject("container/scrollview/ui_wrapcontent/item")
	local item = ClubItem:create(itemGo)
	self.itemList[1] = item
	self.itemList[1]:SetCallback(self.OnItemClick, self)
	local warpTr = self:GetGameObject("container/scrollview/ui_wrapcontent").transform
	for i = 2, 5 do 
		local go = newobject(itemGo)
		go.transform:SetParent(warpTr, false)
		local item = ClubItem:create(go)
		item:SetActive(false)
		self.itemList[i] = item
		self.itemList[i]:SetCallback(self.OnItemClick, self)
	end
end

function ClubListView:UpdateList(force)
	local lastCount = 0
	if self.clubList ~= nil then
		lastCount = #self.clubList
	end
	self.clubList = self.model.unofficalClubList 
	local count = 0
	if self.clubList ~= nil then
		count = #self.clubList 
	end

	if count == 0 then
		if self.currentItem then
			self.currentItem:SetSelected(false)
		end
		self.currentItem = nil
		self.curCid = 0
	end

	if lastCount == count and not force then
		if self.model.currentClubInfo ~= nil then
			self.curCid = self.model.currentClubInfo.cid
		end
		self:RefreshCurrentItems()
		return
	end

	if self.clubList == nil or #self.clubList == 0 or self.model.currentClubInfo == nil then
		self.wrap:InitWrap(count)
		return
	end

	if self.model.currentClubInfo ~= nil then
		self.curCid = self.model.currentClubInfo.cid
	end
	self.wrap:InitWrap(count)	
	self.wrap:ScrollToTarget(self:GetCurIndex())
end

function ClubListView:GetCurIndex()
	if self.model.currentClubInfo == nil then
		return
	end
	for i = 1, #self.clubList do
		if self.clubList[i].cid == self.model.currentClubInfo.cid then
			return i - 1
		end
	end
	return 1
end


function ClubListView:OnClose()
	self.currentItem:SetSelected(false)
	self.currentItem = nil
	self.curCid = 0
end


function ClubListView:OnItemClick(item)
	ui_sound_mgr.PlayButtonClick()
	if item.clubInfo.cid == self.curCid then
		return
	end
	self:Select(item)
	self.model:SetCurrentClubInfo(item.clubInfo, true)
end

function ClubListView:Select(item)
	if self.currentItem ~= nil then
		self.currentItem:SetSelected(false)
	end
	self.currentItem = item
	self.currentItem:SetSelected(true)
	self.curCid = item.clubInfo.cid
end


function ClubListView:OnItemUpdate(go, index, rindex) 
	if self.itemList[index] ~= nil then
		self.itemList[index]:SetActive(true)
		self.itemList[index]:SetInfo(self.clubList[rindex])
		if self.itemList[index].clubInfo.cid == self.curCid then
			self.itemList[index]:SetSelected(true)
			if self.currentItem == nil then
				self.currentItem = self.itemList[index]
			end
		else
			self.itemList[index]:SetSelected(false)
		end
	end
end

function ClubListView:RefreshCurrentItems()
	if self.currentItem ~= nil then
		self.currentItem:SetSelected(false)
		self.currentItem = nil
	end
	for i = 1, #self.itemList do
		if self.itemList[i].clubInfo ~= nil then
			self.itemList[i]:SetInfo(self.itemList[i].clubInfo)
			if self.itemList[i].clubInfo.cid == self.curCid then
				self.itemList[i]:SetSelected(true)
				if self.currentItem == nil then
					self.currentItem = self.itemList[i]
				end
			else
				self.itemList[i]:SetSelected(false)
			end

		end
	end
end

return ClubListView
local base = require "logic/framework/ui/uibase/ui_view_base"
local ClubListViewWithGrid = class("ClubListViewWithGrid", base)
local ClubItem = require "logic/club_sys/View/new/ClubSelfItemView"
local addClickCallbackSelf = addClickCallbackSelf

function ClubListViewWithGrid:InitView()
	self.model = model_manager:GetModel("ClubModel")
	self.itemGo = self:GetGameObject("container/scrollview/ui_wrapcontent/item")
	self.scroll = self:GetComponent("container/scrollview", typeof(UIScrollView))
	self.itemList = {}
	local item = ClubItem:create(self.itemGo)
	self.itemList[1] = item
	self.itemList[1]:SetCallback(self.OnItemClick, self)

	self.grid = self:GetComponent("container/scrollview/ui_wrapcontent", typeof(UIGrid))
end



function ClubListViewWithGrid:UpdateList(force)
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
		self:OnClose()
	end
	self:RefreshItemCount(self.clubList)

	local index = self:GetCurIndex()
	if self.itemList[index] == nil then
		index = 1
	end

	self:Select(self.itemList[index])

	if not force and (lastCount == #self.clubList or count == 0 )then
		return
	end

	self.scroll:ResetPosition()

	if count <= 4 then
		return
	end

	if index + 4 > count then
		index = count - 4 + 1
	end

	self.scroll:MoveRelative(Vector3(0, 95 * (index - 1), 0))
end


function ClubListViewWithGrid:GetCurIndex()
	if self.model.currentClubInfo == nil then
		return 1
	end
	for i = 1, #self.clubList do
		if self.clubList[i].cid == self.model.currentClubInfo.cid then
			return i 
		end
	end
	return 1
end


function ClubListViewWithGrid:RefreshItemCount(dataList)
	local count = 0
	if dataList == nil then
		count = 0
	else
		count = #dataList
	end

	if #self.itemList < count then
		for i = #self.itemList + 1, count do
			local go = newobject(self.itemGo)
			local item = ClubItem:create(go)
			go.transform:SetParent(self.itemGo.transform.parent, false)
			item:SetCallback(self.OnItemClick, self)
			table.insert(self.itemList, item)
		end
	end

	for i = 1, count do
		self.itemList[i]:SetActive(true)
		self.itemList[i]:SetInfo(dataList[i])
	end

	if #self.itemList > count then
		for i = count + 1, #self.itemList do
			self.itemList[i]:SetActive(false)
		end
	end

	self.grid:Reposition()
end



function ClubListViewWithGrid:OnItemClick(item)
	ui_sound_mgr.PlayButtonClick()
	if item.clubInfo.cid == self.curCid then
		return
	end
	self:Select(item)
	self.model:SetCurrentClubInfo(item.clubInfo, true)
end

function ClubListViewWithGrid:Select(item)
	if item == self.currentItem then
		return
	end
	if self.currentItem ~= nil then
		self.currentItem:SetSelected(false)
		self.currentItem = nil
	end
	self.currentItem = item
	self.currentItem:SetSelected(true)
end



function ClubListViewWithGrid:OnClose()
	if self.currentItem ~= nil then
		self.currentItem:SetSelected(false)
		self.currentItem = nil
	end
end


return ClubListViewWithGrid
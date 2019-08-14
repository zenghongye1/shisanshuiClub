local baseview = require "logic/framework/ui/uibase/ui_view_base"
local TableItem = class('TableItem', baseview)

function TableItem:InitView()
	self.bgSp = self:GetComponent("", typeof(UISprite))
	self.nameLabel = self:GetComponent("name", typeof(UILabel))
	addClickCallbackSelf(self.gameObject, self.OnClick, self)
	self:InitBgAndFormat()
	self:SetSelect(false, true)
end

function TableItem:InitBgAndFormat()
	self.selectBg = "choice_03"
	self.deselectBg = "choice_02"
	self.selectFormat = UILabelFormat.F1
	self.deselectFromat = UILabelFormat.F69
end


function TableItem:OnClick()
	if self.callback ~= nil then
		self.callback(self.target, self)
	end
end

function TableItem:SetInfo(tab)
	self.id = tab[1]
	self.nameLabel.text = tab[2]
end

function TableItem:SetCallback(callback, target)
	self.callback = callback
	self.target = target
end

function TableItem:SetSelect(value, force)
	if self.isSelect == value and not force then
		return
	end
	self.isSelect = value
	if self.isSelect then
		self.bgSp.spriteName = self.selectBg
		self.nameLabel:SetLabelFormat(self.selectFormat)
	else
		self.bgSp.spriteName = self.deselectBg 
		self.nameLabel:SetLabelFormat(self.deselectFromat)
	end
end


local LocationItem = class('LocationItem', TableItem)

function LocationItem:InitBgAndFormat()
	self.selectBg = "region_02"
	self.deselectBg = "region_03"
	self.selectFormat = UILabelFormat.F1
	self.deselectFromat = UILabelFormat.F70
end






local base = require("logic.framework.ui.uibase.ui_window")
local ClubLocationChooseUI = class("ClubLocationChooseUI", base)
local defaultProvince = 110000


function ClubLocationChooseUI:OnInit()
	self.destroyType = UIDestroyType.Immediately
	self.closeBtnGo = self:GetGameObject("backBtn")
	addClickCallbackSelf(self.closeBtnGo, self.OnBtnCloseClick, self)

	self.tabItemGo = self:GetGameObject("tabContainer/scrollview/ui_wrapcontent/item")
	self.tabItemGo:SetActive(false)
	self.locationItemGo = self:GetGameObject("gameScroll/grid/item")
	self.locationItemGo:SetActive(false)

	self.tabGrid = self:GetComponent("tabContainer/scrollview/ui_wrapcontent", typeof(UIGrid))
	self.locationGrid = self:GetComponent("gameScroll/grid", typeof(UIGrid))

	self.tabScroll = self:GetComponent("tabContainer/scrollview", typeof(UIScrollView))
	self.locationScroll = self:GetComponent("gameScroll", typeof(UIScrollView))

	self.selectIconTr = self:GetGameObject("tabContainer/scrollview/selectIcon").transform
	self.selectIconTr.gameObject:SetActive(false)

	self.tabList = {}
	self.itemList = {}
	self.currentTabItem = nil
	self.currentItem = nil

	self.currentLocationId = 0

	self:InitTabs()
end

function ClubLocationChooseUI:OnOpen(positionId, callback, target)
	self.currentLocationId = positionId or 0
	self.closeCallback = callback
	self.target = target

	local provinceId = 0
	if positionId == nil then
		provinceId = defaultProvince
	else
		provinceId = ClubUtil.GetProvinceId(positionId)
	end

	local index = 1
	local tabItem = self.tabList[1]
	for i = 1, #self.tabList do
		if self.tabList[i].id == provinceId then
			index = i
			tabItem = self.tabList[i]
			break
		end
	end



	local count = #self.tabList 
	if index> count/2 then
		self.tabScroll:SetDragAmount(0, index/count, false)
	else
		self.tabScroll:SetDragAmount(0, (index-1)/count, false)
	end

	if tabItem ~= nil then
		self:OnTabItemClick(tabItem)
	end

end


function ClubLocationChooseUI:OnClose()
	if self.closeCallback ~= nil then
		self.closeCallback(self.target, self.currentLocationId)
		self.closeCallback = nil
	end
end


function ClubLocationChooseUI:InitTabs()
	for i = 1, #ClubUtil.provinceIdList do
		local go = GameObject.Instantiate(self.tabItemGo)
		go.transform:SetParent(self.tabItemGo.transform.parent, false)
		local item = TableItem:create(go)
		item:SetActive(true)
		item:SetCallback(self.OnTabItemClick, self)
		item:SetInfo(ClubUtil.provinceIdList[i])
		table.insert(self.tabList, item)
	end
	self.tabGrid:Reposition()
end


function ClubLocationChooseUI:OnTabItemClick(item)
	if self.currentTabItem == item then
		return
	end

	if self.currentTabItem ~= nil then
		self.currentTabItem:SetSelect(false)
	end
	self.currentTabItem = item
	self.currentTabItem:SetSelect(true)
	if self.selectIconTr.gameObject.activeSelf == false then
		self.selectIconTr.gameObject:SetActive(true)
	end
	self.selectIconTr.position = self.currentTabItem.transform.position

	if self.currentItem ~= nil then
		self.currentItem:SetSelect(false)
		self.currentItem = nil
	end
	self:UpdateLocationItems(self.currentTabItem.id)
end

function ClubLocationChooseUI:OnLocationItemClick(item)
	if self.currentItem ~= nil then
		self.currentItem:SetSelect(false)
	end
	self.currentItem = item
	self.currentItem:SetSelect(true)
	self.currentLocationId = item.id
end


function ClubLocationChooseUI:UpdateLocationItems(id)
	self.locationScroll:ResetPosition()
	local list = ClubUtil.GetProvinceCitys(id)
	local count = #list

	if count < #self.itemList then
		for i = count + 1, #self.itemList do
			self.itemList[i]:SetActive(false)
		end
	end

	local item
	for i = 1, count do
		if self.itemList[i] ~= nil then
			item = self.itemList[i]
		else
			local go = newobject(self.locationItemGo)
			go.transform:SetParent(self.locationGrid.transform, false)
			item = self:CreateLocationItem(go)
			table.insert(self.itemList, item)
		end
		item:SetInfo(list[i])
		if list[i][1] == self.currentLocationId then
			self.currentItem = item
			item:SetSelect(true)
		else
			item:SetSelect(false)
		end
		item:SetActive(true)
	end

	self.locationGrid:Reposition()
end



function ClubLocationChooseUI:CreateLocationItem(go)
	local item = LocationItem:create(go)
	item:SetCallback(self.OnLocationItemClick, self)
	item:SetActive(false)
	return item
end





function ClubLocationChooseUI:OnBtnCloseClick()
	ui_sound_mgr.PlayCloseClick()
	UI_Manager:Instance():CloseUiForms("ClubLocationChooseUI")
end

function ClubLocationChooseUI:OnRefreshDepth()
  local uiEffect = child(self.gameObject.transform, "bg/top/tittle/Effect_youxifenxiang")
  if uiEffect and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
  end
end

function ClubLocationChooseUI:PlayOpenAmination()

end


return ClubLocationChooseUI
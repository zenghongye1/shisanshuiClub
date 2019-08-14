local base = require "logic/framework/ui/uibase/ui_view_base"
local ClubChooseTabItem = class("ClubChooseTabItem", base)
local ColorD = Color(25 / 255, 49 / 255, 129 / 255)
local ColorJ = Color(137 /255, 54 / 255, 9 / 255)


function ClubChooseTabItem:InitView()
	self.destroyType = UIDestroyType.ChangeScene
	self.bgSp = self:GetComponent("", typeof(UISprite))
	self.nameLabel = self:GetComponent("name", typeof(UILabel))
	self.selectIconGo = self:GetGameObject("selectIcon")
	self.selectIconGo:SetActive(false)
	self.specialGo = self:GetGameObject("specialGo")
	self.isSelect = false
	self.isSpecial = false
	self.info =nil

	self.callback = nil
	self.target = nil

	addClickCallbackSelf(self.gameObject, self.OnClick, self)
end

function ClubChooseTabItem:SetInfo(info)
	self.info = info 
	self.isSpecial = info.isSpecial
	self.specialGo:SetActive(self.isSpecial)

	if self.isSpecial then
		self.nameLabel.text = "已选择"
	else
		self.nameLabel.text = info.name
	end
end

function ClubChooseTabItem:SetCallback(callback, target)
	self.callback = callback
	self.target = target
end


function ClubChooseTabItem:SetSelect(value)
	self.isSelect = value
	self:UpdateView()
end

function ClubChooseTabItem:UpdateView()
	local color, bg
	if self.isSelect == true then
		color = ColorJ
		bg = "choice_03"
	else
		if self.isSpecial then
			color = ColorJ
			bg = "choice_01"
		else
			color = ColorD
			bg = "choice_02"
		end
	end

	self.nameLabel.color = color
	self.bgSp.spriteName = bg
	self.selectIconGo:SetActive(self.isSelect)
end

function ClubChooseTabItem:OnClick()
	ui_sound_mgr.PlayButtonClick()
	if self.callback ~= nil then
		self.callback(self.target, self)
	end
end



local ui_wrap = require "logic/framework/ui/uibase/ui_wrap"
local base = require("logic.framework.ui.uibase.ui_window")
local ClubGameChooseUI = class("ClubGameChooseUI", base)
local ClubChooseItem = require ("logic/club_sys/View/ClubChooseItem")

function ClubGameChooseUI:OnInit()
	self.model = model_manager:GetModel("ClubModel")
	self.closeBtnGo = self:GetGameObject("backBtn")
	self.selectGameNumLabel = self:GetComponent("selectGameNum", typeof(UILabel))
	addClickCallbackSelf(self.closeBtnGo, self.OnBtnCloseClick, self)
	self.tabItemList = {}

	self.tipLabelGo = self:GetGameObject("tipLabel")

	self:InitTabItems()

	self.wrap = ui_wrap:create(self:GetGameObject("tabContainer"))
	self.wrap:InitUI(74)
	self.wrap.OnUpdateItemInfo = function(go, rindex, index)  self:OnTabItemUpdate(go, index, rindex)  end
	self.wrap:InitWrap(0)

	self.tabInfoList = {}

	self.curTabItem = nil
	self.curTabInfo = nil


	-- game相关
	self.gameItemGo = self:GetGameObject("gameScroll/grid/item")
	self.gridGo = self:GetGameObject("gameScroll/grid")
	self.grid = self:GetComponent("gameScroll/grid", typeof(UIGrid))
	self.scroll = self:GetComponent("gameScroll", typeof(UIScrollView))
	self.gameItemList = {}

	local item = self:CreateGameItem(self.gameItemGo)
	self.gameItemList[1] = item

	self.maxCount = 2
end

function ClubGameChooseUI:OnOpen(selectedUids,callback, target)
	self.selectedUids = {}
	ClubUtil.CopyClubInfo(self.selectedUids , selectedUids)
	self.callback = callback
	self.target = target

	local gids = self:GetGameList()

	if self.model:IsAgent() then
		self.maxCount = ClubUtil.AgentGameSelectCount
	else
		self.maxCount  = ClubUtil.NormalGameSelectCount
	end

	self:UpdateGameCount()

	self.typeList, self.typeToGidMap = ClubUtil.GetGameTypeListAndTypeToGidMapByGidList(gids, true)
	-- 已选择标签页
	table.insert(self.typeList, 1, {isSpecial = true, name = "已选择"})

	self:UpdateTabs()

	self:OnTabClick(self.tabItemList[1])

end




function ClubGameChooseUI:GetGameList()
	local gids = nil
	if self.model:IsAgent() then
		gids = ClubUtil.GetOpenClubGids(self.model.agentInfo.gids)
	else
		gids = model_manager:GetModel("GameModel"):GetOpenGidList()
	end

	return gids
end


function ClubGameChooseUI:OnBtnCloseClick()
	ui_sound_mgr.PlayCloseClick()
	UI_Manager:Instance():CloseUiForms("ClubGameChooseUI")
end


function ClubGameChooseUI:OnClose()
	self.curTabInfo = nil
	if self.curTabItem ~= nil then
		self.curTabItem:SetSelect(false)
		self.curTabItem = nil
	end
	for i = 1, #self.tabItemList do
		self.tabItemList[i]:SetActive(false)
	end
	self.wrap:ResetPosition()

	if self.callback ~= nil then
		self.callback(self.target, self.selectedUids)
		self.callback = nil
		self.target = nil
	end

end

function ClubGameChooseUI:PlayOpenAmination()

end

--------------------- tab 相关逻辑 ------------------


function ClubGameChooseUI:InitTabItems()
	for i = 1, 9 do
		local go = self:GetGameObject("tabContainer/scrollview/ui_wrapcontent/item" .. i)
		local item = ClubChooseTabItem:create(go)
		item:SetCallback(self.OnTabClick, self)
		item:SetActive(false)
		self.tabItemList[i] = item
	end
end

function ClubGameChooseUI:OnTabItemUpdate(go, index, rindex)
	if self.tabItemList[index] ~= nil then
		self.tabItemList[index]:SetInfo(self.typeList[rindex])
		self.tabItemList[index]:SetActive(true)
	end
end


function ClubGameChooseUI:UpdateTabs()
	local count = 0
	if self.typeList ~= nil then
		count = #self.typeList
	end
	self.wrap:InitWrap(count)
end


function ClubGameChooseUI:OnTabClick(tabItem)
	if self.curTabInfo == tabItem.info then
		return
	end
	if self.curTabInfo ~= nil and self.curTabItem ~= nil then
		self.curTabItem:SetSelect(false)
	end
	self.curTabInfo = tabItem.info
	self.curTabItem = tabItem
	self.curTabItem:SetSelect(true)

	local gids 
	if self.curTabInfo.isSpecial then
		gids = self.selectedUids
	else
		gids = self.typeToGidMap[self.curTabInfo.key]
	end

	-- if not self.curTabInfo.isSpecial then
	Utils.sort(gids, ClubGameChooseUI.SortGids)
	-- end
	self:UpdateItems(gids)
end


function ClubGameChooseUI.SortGids( left, right )
	if left == right then
		return false
	end
	if left == nil then
		return false
	end
	if right == nil then
		return false
	end

	local leftSelect = UI_Manager:Instance():GetUiFormsInShowList("ClubGameChooseUI"):CheckGameHasSelected(left)
	local rightSelect = UI_Manager:Instance():GetUiFormsInShowList("ClubGameChooseUI"):CheckGameHasSelected(right)

	if leftSelect and not rightSelect then
		return false
	end

	if not leftSelect and rightSelect then
		return true
	end

	local cfgL = config_mgr.getConfig("cfg_game", left)
	local cfgR = config_mgr.getConfig("cfg_game", right)
	if cfgL == nil or cfgR == nil then
		return false
	end
	return cfgL.showOrder >= cfgR.showOrder
end

----------------------------------------------------

function ClubGameChooseUI:CheckGameHasSelected(gid)
	if self.selectedUids == nil then
		return false
	end
	for i = 1, #self.selectedUids do
		if self.selectedUids[i] == gid then
			return true
		end
	end
	return false
end

function ClubGameChooseUI:AddGid(gid)
	table.insert(self.selectedUids, gid)
	self:UpdateGameCount()
end

function ClubGameChooseUI:RemoveGid(gid)
	for i = 1, #self.selectedUids do
		if self.selectedUids[i] == gid then
			table.remove(self.selectedUids, i)
			self:UpdateGameCount();
			return
		end
	end
end


function ClubGameChooseUI:CreateGameItem(go)
	local item = ClubChooseItem:create(go)
	item:SetCallback(self.OnGameItemClick, self)
	item:SetActive(false)
	return item
end

function ClubGameChooseUI:UpdateItems(gids)
	self.scroll:ResetPosition()
	local count = 0
	if gids ~= nil then
		count = #gids
	end
	if count < #self.gameItemList then
		for i = count + 1, #self.gameItemList do
			self.gameItemList[i]:SetActive(false)
		end
	end

	local item
	for i = 1, count do
		if self.gameItemList[i] ~= nil then
			item = self.gameItemList[i]
		else
			local go = newobject(self.gameItemGo)
			go.transform:SetParent(self.gridGo.transform, false)
			item = self:CreateGameItem(go)
			table.insert(self.gameItemList, item)
		end

		item:SetInfo(gids[i])
		item:SetSelected(self:CheckGameHasSelected(gids[i]))
		item:SetState(false)
		item:SetActive(true)
	end

	if self.curTabInfo.isSpecial and (gids == nil or #gids == 0) then
		self.tipLabelGo:SetActive(true)
	else
		self.tipLabelGo:SetActive(false)
	end

	self.grid:Reposition()
end


function ClubGameChooseUI:OnGameItemClick(item)
	if item.isSelected then
		item:SetSelected(false)
		self:RemoveGid(item.gid)
		if self.curTabInfo.isSpecial then
			item:SetState(true)
		end
	else
		if #self.selectedUids >= self.maxCount then
			UIManager:FastTip(LanguageMgr.GetWord(10006))
			return
		end
		item:SetSelected(true)
		self:AddGid(item.gid)
		if self.curTabInfo.isSpecial then
			item:SetState(false)
		end
	end
end

function ClubGameChooseUI:UpdateGameCount()
	local count = 0
	if self.selectedUids ~= nil then
		count = #self.selectedUids
	end
	self.selectGameNumLabel.text = string.format("可选游戏数量:%s/%s", count, self.maxCount)
end



function ClubGameChooseUI:OnRefreshDepth()
  local uiEffect = child(self.gameObject.transform, "bg/top/tittle/Effect_youxifenxiang")
  if uiEffect and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
  end
end


return ClubGameChooseUI
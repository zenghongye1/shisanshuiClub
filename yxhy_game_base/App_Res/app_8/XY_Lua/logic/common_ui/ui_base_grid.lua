--[[--
 * @Description:	便捷刷新包含列表的数据
 * @Author:			shine
 * @Path:			logic/common_ui/ui_base_grid
 * @DateTime:		2016-09-03 10:57:29
]]

ui_base_grid = ui_base.New()
ui_base_grid.__index = ui_base_grid

function  ui_base_grid.New()
	local result = {
		tableGrid = nil,
		defultParentPath = nil,
	}
	setmetatable(result,ui_base_grid)
	return result
end

--[[--
 * 	@Description: 刷新列表数据(UIGrid)
 * 	listDataUnit  需要填充的table数据
 * 	initUnitFuncation  将列表数据填充到unit中  param1:unit数据对象  param2:unit的transform param3:unit的index 
 * 	parentPath  ScrollView所在的路径
 * 	isScrollStart  是否滚动到开始的位置
]]
function ui_base_grid:FreshGridUnit(listDataUnit,initUnitFuncation,parentPath,isScrollStart)
	self.defultParentPath = parentPath
	--初始化
	self.tableGrid = self.tableGrid or {}
	if self.tableGrid[parentPath] == nil then
		self.tableGrid[parentPath] = {}
		self.tableGrid[parentPath].tableTransUnit = {}

		self.tableGrid[parentPath].girdObject = subComponentGet(self.transform,parentPath.."/grid",typeof(UIGrid))
		self.tableGrid[parentPath].transUnitObject = child(self.transform,parentPath.."/grid/unit")
		self.tableGrid[parentPath].transGridOjbect = child(self.transform,parentPath.."/grid")

		self.tableGrid[parentPath].scrollViewObject = subComponentGet(self.transform,parentPath,typeof(UIScrollView))
		self.tableGrid[parentPath].panelScrollView = subComponentGet(self.transform,parentPath,typeof(UIPanel))
		self.tableGrid[parentPath].originalScrollViewVec3 =  self.tableGrid[parentPath].scrollViewObject.transform.localPosition
		self.tableGrid[parentPath].originalScrollViewOffsetVec2 = self.tableGrid[parentPath].panelScrollView.clipOffset
	end

	--刷新数据
	listDataUnit = listDataUnit or {}
	self.tableGrid[parentPath].listData = listDataUnit
	for i=1,#listDataUnit do
		local v = listDataUnit[i]
		if self.tableGrid[parentPath].tableTransUnit[i] == nil then
			local transItem = newobject(self.tableGrid[parentPath].transUnitObject).transform
			transItem.gameObject.name = "unit"..i
			transItem.parent = self.tableGrid[parentPath].transGridOjbect
			transItem.localScale = Vector3.one
			self.tableGrid[parentPath].tableTransUnit[i] = transItem
		end
		self.tableGrid[parentPath].tableTransUnit[i].gameObject:SetActive(true)

		initUnitFuncation(v,self.tableGrid[parentPath].tableTransUnit[i],i)
	end

	self.tableGrid[parentPath].girdObject.repositionNow = true
	self.tableGrid[parentPath].girdObject:Reposition()
	if isScrollStart == nil or isScrollStart then
		self.tableGrid[parentPath].scrollViewObject:ResetPosition()
	end
	local numberListData = #listDataUnit
	local numberTableTrans = #self.tableGrid[parentPath].tableTransUnit
	if numberListData < numberTableTrans then
		for i=numberListData+1,numberTableTrans do
			self.tableGrid[parentPath].tableTransUnit[i].gameObject:SetActive(false)
		end
	end
end

--[[--
 * 	@Description: 刷新列表数据(UIWrapContent)
 * 	listDataUnit  需要填充的table数据
 * 	initUnitFuncation  将列表数据填充到unit中  param1:unit数据对象  param2:unit的transform param3:unit的index 
 * 	parentPath  ScrollView所在的路径
]]
function ui_base_grid:FreshWrapContentUnit(listDataUnit,initUnitFuncation,parentPath,isScrollStart)
	self.defultParentPath = parentPath
	--初始化
	self.tableGrid = self.tableGrid or {}
	if self.tableGrid[parentPath] == nil then
		self.tableGrid[parentPath] = {}

		self.tableGrid[parentPath].wrapContent = subComponentGet(self.transform,parentPath.."/grid",typeof(UIWrapContent))
		self.tableGrid[parentPath].transGridOjbect = child(self.transform,parentPath.."/grid")

		self.tableGrid[parentPath].scrollViewObject = subComponentGet(self.transform,parentPath,typeof(UIScrollView))
		self.tableGrid[parentPath].panelScrollView = subComponentGet(self.transform,parentPath,typeof(UIPanel))
		self.tableGrid[parentPath].originalScrollViewVec3 =  self.tableGrid[parentPath].scrollViewObject.transform.localPosition
		self.tableGrid[parentPath].originalScrollViewOffsetVec2 = self.tableGrid[parentPath].panelScrollView.clipOffset
	end

	self:ReDataToItems(listDataUnit,initUnitFuncation,parentPath,isScrollStart)
	if isScrollStart == nil or isScrollStart then
		self.tableGrid[parentPath].scrollViewObject:ResetPosition()
	end
end

--[[--
 * @Description: 重映射数据到每个item上(UIWrapContent)  
 ]]
function ui_base_grid:ReDataToItems(listDataUnit,initUnitFuncation,parentPath,isScrollStart)
	parentPath = parentPath or self.defultParentPath
	if parentPath == nil then
		--Trace("Parent is nil")
		return
	end
	listDataUnit = listDataUnit or {}
	self.tableGrid[parentPath].listData = listDataUnit

	local transGrid = self.tableGrid[parentPath].transGridOjbect
	local wrapContent = self.tableGrid[parentPath].wrapContent
	for i=1,transGrid.childCount do
		transGrid:GetChild(i-1).gameObject:SetActive(false)
	end

	if wrapContent ~= nil then
		wrapContent:ClearChildrenLst()
		wrapContent.minIndex = 1-#listDataUnit
		wrapContent.maxIndex = 0
		for i=1,#listDataUnit do
			if i <= transGrid.childCount then
				local item = transGrid:GetChild(i-1)
				item.gameObject:SetActive(true)
				wrapContent:AddChildTran(item)
			else
				break
			end
		end
		wrapContent.onInitializeItem = function (go, index, realIndex)
			if listDataUnit[1-realIndex] ~= nil then
				initUnitFuncation(listDataUnit[1-realIndex],go.transform,1-realIndex)
			end
		end

		if isScrollStart == nil or isScrollStart then
			wrapContent:SortBasedOnScrollMovement()
			wrapContent:ResetPosition()
		end
		wrapContent:UpdateChildren()
	end
end

--[[--
 * @Description: 局部刷新显示数据(UIWrapContent)
]]
function ui_base_grid:UpdateChildrenMessage(listDataUnit,parentPath)
	parentPath = parentPath or self.defultParentPath
	if listDataUnit ~= nil then
		self.tableGrid[parentPath].listData = listDataUnit
	end
	if self.tableGrid ~= nil and self.tableGrid[parentPath] ~=nil and self.tableGrid[parentPath].wrapContent ~= nil then
		self.tableGrid[parentPath].wrapContent:UpdateChildren()
	end
end

--[[--
 * @Description: 移动Scrollerview step(正负表示上下)的长度（UIGrid、UIWrapcontent）
]]
function ui_base_grid:UpStepScrollView(step,parentPath)
	parentPath = parentPath or self.defultParentPath
	local stepLength = 0
	if self.tableGrid[parentPath].wrapContent ~= nil then
		stepLength = self.tableGrid[parentPath].wrapContent.itemSize*step
	else
		stepLength = self.tableGrid[parentPath].girdObject.cellHeight
	end
	local transScrollView = self.tableGrid[parentPath].scrollViewObject.transform
	transScrollView.localPosition = Vector3.New(transScrollView.localPosition.x,transScrollView.localPosition.y+stepLength,transScrollView.localPosition.z)
	self.tableGrid[parentPath].panelScrollView.clipOffset = Vector2.New(self.tableGrid[parentPath].panelScrollView.clipOffset.x,self.tableGrid[parentPath].panelScrollView.clipOffset.y-stepLength)
end

--[[--
 * @Description: 自动移动到顶部或底部（UIGrid、UIWrapcontent）
]]
function ui_base_grid:UpOrDownDragScrollView(isUp,parentPath)
	parentPath = parentPath or self.defultParentPath
	local stepLength = 0
	local transScrollView = self.tableGrid[parentPath].scrollViewObject.transform
	local panel = self.tableGrid[parentPath].scrollViewObject.panel
	local sizePanel = self.tableGrid[parentPath].scrollViewObject.panel:GetViewSize()

	--是否是Wrapcontent
	local isWrapContent = false
	if self.tableGrid[parentPath].wrapContent ~= nil then
		isWrapContent = true
	end

	if not isUp then
		if isWrapContent then
			stepLength = self.tableGrid[parentPath].wrapContent.itemSize*(#self.tableGrid[parentPath].listData)
		else
			stepLength = self.tableGrid[parentPath].girdObject.cellHeight*(#self.tableGrid[parentPath].listData)
		end
	end

	if stepLength > sizePanel.y then
		stepLength = stepLength - sizePanel.y + 8
	else
		stepLength = 0
	end

	local originalSVPosition = self.tableGrid[parentPath].originalScrollViewVec3
	local originalScrollViewOffsetVec2 = self.tableGrid[parentPath].originalScrollViewOffsetVec2
	transScrollView.localPosition = Vector3.New(originalSVPosition.x,originalSVPosition.y+stepLength,originalSVPosition.z)
	panel.clipOffset = Vector2.New(originalScrollViewOffsetVec2.x,originalScrollViewOffsetVec2.y-stepLength)
	
	local originLocalPositionY = transScrollView.localPosition.y
	--如果是wrapcontent移动scrollview后刷新显示
	if isWrapContent then
		self:UpdateChildrenMessage()
	end

	if originLocalPositionY ~= transScrollView.localPosition.y and isUp then
		self:UpStepScrollView(-1)
	end
end

--[[--
 * @Description: gameObject销毁时清空数据(如果没有清理，跳转场景会出错)
]]
function ui_base_grid:ClearGridTableMessage()
	if self.tableGrid ~= nil then
		self.tableGrid = nil
	end
end
--[[--
 * @Description: 俱乐部页签
 * @Author:      ShushingWong
 * @FileName:    openroom_clubTab.lua
 * @DateTime:    2017-12-12 14:58:10
 ]]

local clubTabItem = require "logic/hall_sys/openroom/comp/openroom_clubTabItem"

local base = require "logic/framework/ui/uibase/ui_view_base"
local openroom_clubTab = class("openroom_clubTab",base)

function openroom_clubTab:InitView()
	self.clubData = nil

	self.tabList = {}

	for i=1,4 do
		local go = self:GetGameObject("tab/"..i)
		local item = clubTabItem:create(go)
		addClickCallbackSelf(go,function ()
			self:OnTabClick(i)
		end,self)
		table.insert(self.tabList,item)
	end

	self.rightBtn = self:GetGameObject("rightBtn")
	self.leftBtn = self:GetGameObject("leftBtn")

	addClickCallbackSelf(self.rightBtn,self.OnRightBtnClick,self)
	addClickCallbackSelf(self.leftBtn,self.OnLeftBtnClick,self)

	self.curTabIndex = 4
	self.endDataIndex = 4
end

function openroom_clubTab:SetData(data,callback,curClubInfo)
	self.clubData = data
	self.callback = callback

	self:SetCurClub(curClubInfo)

	-- FrameTimer.New(
	-- 	function()
	-- 		self:ReflashPanel()
	-- 	end,1,1):Start()
	self:ReflashPanel()
end

function openroom_clubTab:SetCurClub(curClubInfo)
	for i,v in ipairs(self.clubData) do
		if curClubInfo.cid == v.cid then
			if #self.clubData >= 4 then
				if i <= 4 then
					self.endDataIndex = 4
					self.curTabIndex = 5-i
				else
					self.endDataIndex = i
					self.curTabIndex = 1
				end
			else
				self.curTabIndex = #self.clubData + 1 - i
			end
		end
	end
end

function openroom_clubTab:ReflashPanel()
	local count = #self.clubData
	if count < self.endDataIndex or count <=4 then
		self.endDataIndex = count
	end
	self:TabShow()
	self.rightBtn:SetActive(self.endDataIndex < count)
	self.leftBtn:SetActive(self.endDataIndex > 4)
	self:OnTabClick(self.curTabIndex,true)
end

function openroom_clubTab:TabShow()
	local index = self.endDataIndex
	for i=1,4 do
		if index > 0 then
			local clubIndo = self.clubData[index]
			self.tabList[i].clubInfo = clubIndo
			self.tabList[i]:SetLabel(clubIndo.cname)
			self.tabList[i]:SetActive(true)
		else
			self.tabList[i]:SetActive(false)
		end
		index = index - 1
	end
end

function openroom_clubTab:SetTab()
	for i=1,4 do
		self.tabList[i]:SetValue(i == self.curTabIndex)
	end
end

function openroom_clubTab:OnClose()
	-- body
end

function openroom_clubTab:OnRightBtnClick()
	self.endDataIndex = self.endDataIndex + 1
	self:ReflashPanel()
end

function openroom_clubTab:OnLeftBtnClick()
	self.endDataIndex = self.endDataIndex - 1
	self:ReflashPanel()
end

function openroom_clubTab:OnTabClick(index,force)
	if self.curTabIndex == index and not force then
		return
	end
	while self.tabList[index] and not self.tabList[index].isActive do
		if index > 0 then
			index = index - 1
		else
			break
		end
	end
	self.curTabIndex = index
	-- if self.tabList[index].isActive then
	-- 	self.curTabIndex = index
	-- else
	-- 	self.curTabIndex = 5 - #self.clubData
	-- 	if self.curTabIndex <= 0 then
	-- 		self.curTabIndex = 1
	-- 	end
	-- end
	self:SetTab()
	if self.callback then
		self.callback(self.tabList[self.curTabIndex].clubInfo)
	end
end

return openroom_clubTab
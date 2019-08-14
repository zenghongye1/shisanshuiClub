local base = require("logic.framework.ui.uibase.ui_childwindow")
local ui_tab = class("ui_tab",base)

--传入一个tab按钮的根结点 
function ui_tab:ctor(tabBtnRootName,tabWindowRootName,defautTabName,enableIcon,disableIcon, selectTitleKey, normalTitleKey)
--	base.ctor(self)
	self.tabWindow = {}
	self.enableIcon = "Set_12"
	self.disableIcon = "Set_12"
	self.onSwitchCallBack = nil -- 切页后的回调
	self.tabBtnRoot = nil		-- 切页按钮的父结点
	self.tabWindowRoot = nil	-- 切页界面的父结点
	self.tabWindowList = {}     -- 切页界面的缓存列表
	self.currentTab = nil		-- 当前显示的切页界面
	self.defautTabName = defautTabName	-- 默认显示的切页界面的名字
	self.tabBtnRootName = tabBtnRootName
	self.tabWindowRootName = tabWindowRootName
	if enableIcon ~= nil then
		self.enableIcon = enableIcon
	end
	if disableIcon ~= nil then
		self.disableIcon = disableIcon
	end

	-- Tab文字样式变化
	self.selectTitleKey = selectTitleKey
	self.normalTitleKey = normalTitleKey or "UILabel"
end

function ui_tab:OnInit()
	base.OnInit(self)
	
	if self.tabWindowList ~= nil and #self.tabWindowList > 0 then return end
	if self.tabWindowRoot == nil then 	
		self.tabWindowRoot = self.gameObject.transform:FindChild(self.tabWindowRootName)
	end

	if self.tabBtnRoot == nil then
		self.tabBtnRoot = self.gameObject.transform:FindChild(self.tabBtnRootName)
		local tabBtns = self.tabBtnRoot:GetComponentsInChildren(typeof(UnityEngine.BoxCollider))
		if tabBtns ~= nil then
			for i = 0,tabBtns.Length - 1,1 do
				local btn = tabBtns[i]
			--	Trace("tabBtn Name:"..btn.name)
				local tabWindow = self.tabWindowRoot:FindChild(btn.name)
				
				if tabWindow ~= nil then
			--		Trace("tabWindow Name:"..tabWindow.name)
					local luaFile = ui_script_enum["ui_script_"..btn.name]
					local luaFileObj = require(luaFile):create()
					luaFileObj.gameObject = tabWindow.gameObject
					local tabWindowObj = {}
					tabWindowObj.btn = btn
					tabWindowObj.luaFileObj = luaFileObj
					
					table.insert(self.tabWindowList,tabWindowObj)
					addClickCallbackSelf(btn.gameObject,function()
						if self.currentTab == nil or self.currentTab.btn.name ~= btn.name then
							self:SwitchToByName(btn.name)
						end
					end,self)
					if tabWindowObj.btn.name == self.defautTabName then
						self.currentTab = tabWindowObj
					end
				end
			end
		end
	else
		logError("没有找到tab 按钮，请检查tabBtnRootName下是否有tab按钮")
	end
end



function ui_tab:SwitchToByName(tabWindowName)
	ui_sound_mgr.PlayButtonClick()
	if tabWindowName == nil then
		self.currentTab = null
		return
	end
	local tabWindow = self:GetTabWindowFormCacheByName(tabWindowName)
	if tabWindow == nil then
		--这里设置默认的tab选项
		if self.defautTabName ~= nil then
			tabWindow = self:GetTabWindowFormCacheByName(self.defautTabName)
			if tabWindow == nil then
				logError("default tab "..self.defautTabName.." is invlaid")
				return
			end
		end
	end
	self.currentTab = tabWindow
	self:SwitchToCurrentTab()
end

function ui_tab:SwitchToCurrentTab()
	if self.currentTab == nil then return end
	if self.tabWindowList ~= nil and #self.tabWindowList > 0 then
		for i,v in ipairs(self.tabWindowList) do
			if v.btn.name ~= self.currentTab.btn.name then
				v.luaFileObj:Close()
			--	v.luaFileObj.gameObject:SetActive(false)
				if self.disableIcon ~= nil then
					local disableSprite = v.btn.transform:GetComponentInChildren(typeof(UISprite))
					disableSprite.spriteName = self.disableIcon
				--	Trace(v.btn.name.." disableSprite:"..disableSprite.spriteName)

					--show normal title
					if self.selectTitleKey then
						local btnObj = v.btn
						local UILabel_Select = child(btnObj.transform, self.selectTitleKey)
						if UILabel_Select then
							UILabel_Select.gameObject:SetActive(false)

							local UILabel = child(btnObj.transform, self.normalTitleKey)
							if UILabel then
								UILabel.gameObject:SetActive(true)
							end
						end
					end
				end
			end
		end
	end
	self.currentTab.luaFileObj:Open()
	if self.enableIcon ~= nil then
		local enableSprite = self.currentTab.btn.transform:GetComponentInChildren(typeof(UISprite))
		enableSprite.spriteName = self.enableIcon
	--	Trace(self.currentTab.btn.name.." enableSprite:"..enableSprite.spriteName)

		--show select title
		if self.selectTitleKey then
			local btnObj = self.currentTab.btn
			local UILabel_Select = child(btnObj.transform, self.selectTitleKey)
			if UILabel_Select then
				UILabel_Select.gameObject:SetActive(true)

				local UILabel = child(btnObj.transform, self.normalTitleKey)
				if UILabel then
					UILabel.gameObject:SetActive(false)
				end
			end
		end
	end
	--页面切换完成后的回调
	if self.onSwitchCallBack ~= nil then
		self.onSwitchCallBack(self.currentTab.btn.name)
	end
end

function ui_tab:GetTabWindowFormCacheByName(tabWindowName)
	local tabWindow = nil
	if self.tabWindowList ~= nil and #self.tabWindowList > 0 then
		for i,v in ipairs(self.tabWindowList) do
			if v.btn.name == tabWindowName then
				tabWindow = v
				break
			end
		end
	end
	return tabWindow
end

function ui_tab:OnOpen()
	base.OnOpen(self)
--	Trace("Tab ======== OnOpen")
	self:SwitchToCurrentTab()
end



return ui_tab
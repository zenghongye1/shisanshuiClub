local base = require("logic.framework.ui.uibase.ui_window")
local ClubIconSelectUI = class("ClubIconSelectUI", base)
local ToggleView = require("logic/club_sys/View/GameToggleView")
local UIManager = UI_Manager:Instance()
function ClubIconSelectUI:OnInit()
	self.toggleList = {}
	self:InitToggle()
	self.currentItem = nil
	self.closeBtnGo = self:GetGameObject("panel/closeBtn")
	addClickCallbackSelf(self.closeBtnGo, self.OnCloseClick, self)
end

function ClubIconSelectUI:OnOpen(iconId, callback, target)
	iconId = iconId or 1
	self.callback = callback
	self.target = target
	if self.toggleList[iconId] ~= nil then
		self:OnToggleClick(self.toggleList[iconId])
	else
		logError(iconId)
		self:OnToggleClick(self.toggleList[1])
	end
end

function ClubIconSelectUI:OnClose()
	if self.callback ~= nil then
		self.callback(self.target, self.currentItem.data)
	end
	self.callback = nil
	self.target = nil
	self.currentItem:SetSelect(false)
	self.currentItem = nil
end

function ClubIconSelectUI:InitToggle()
	for i = 1, 3 do
		local go = self:GetGameObject("panel/toggle" .. i)
		local toggle = ToggleView:create(go)
		toggle:Init()
		toggle.data = i
		toggle:SetCallback(self.OnToggleClick,self)
		toggle:SetSelect(false)
		self.toggleList[i] = toggle
	end
end

function ClubIconSelectUI:OnCloseClick()
	ui_sound_mgr.PlayCloseClick()
	UIManager:CloseUiForms("ClubIconSelectUI")
end

function ClubIconSelectUI:OnToggleClick(item)
	if self.currentItem == item then
		return
	end
	if self.currentItem ~= nil then
		self.currentItem:SetSelect(false)
	end
	self.currentItem = item
	self.currentItem:SetSelect(true)
end

return ClubIconSelectUI
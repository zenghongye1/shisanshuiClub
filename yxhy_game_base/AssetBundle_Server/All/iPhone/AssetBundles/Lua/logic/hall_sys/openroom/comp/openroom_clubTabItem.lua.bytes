
local base = require "logic/framework/ui/uibase/ui_view_base"
local openroom_clubTabItem = class("openroom_clubTabItem",base)

function openroom_clubTabItem:InitView()
	self.selectBg = self:GetGameObject("bg2")
	self.noSelectBg = self:GetGameObject("bg1")
	self.selectLabel = self:GetComponent("selectLabel", "UILabel")
	self.noSelectLabel = self:GetComponent("noSelectLabel", "UILabel")
end

function openroom_clubTabItem:SetLabel(str)
	self.selectLabel.text = str
	self.noSelectLabel.text = str
end

function openroom_clubTabItem:SetValue(value)
	if value then
		self.selectBg:SetActive(true)
		self.noSelectBg:SetActive(false)
		self.selectLabel.gameObject:SetActive(true)
		self.noSelectLabel.gameObject:SetActive(false)
	else
		self.selectBg:SetActive(false)
		self.noSelectBg:SetActive(true)
		self.selectLabel.gameObject:SetActive(false)
		self.noSelectLabel.gameObject:SetActive(true)
	end
end

function openroom_clubTabItem:SetCallback(callback)
	
end

return openroom_clubTabItem
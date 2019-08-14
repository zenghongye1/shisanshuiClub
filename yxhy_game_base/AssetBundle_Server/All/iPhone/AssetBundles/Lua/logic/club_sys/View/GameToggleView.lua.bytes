local base = require "logic/framework/ui/uibase/ui_view_base"
local GameToggleView = class("GameToggleView", base)

function GameToggleView:ctor(go)
	self.isSelect = false
	self.isDisable = false
	self.text = ""
	base.ctor(self, go)
end

function GameToggleView:Init(iconName, labelName)
	self.iconName = iconName or "icon"
	self.labelName = labelName or "Label"
	self:RefreshUI()
end

--[[--
 * @Description: toggleType 0多选 1单选 nil不变  
 ]]
function GameToggleView:SetToggleType(toggleType)
	self.toggleType = toggleType
	if self.toggleType then
		if self.toggleType == 0 then
			self:GetComponent(self.iconName,"UISprite").spriteName = "icon_01"
			self:GetComponent("bg","UISprite").spriteName = "common_15"
		elseif self.toggleType == 1 then
			self:GetComponent(self.iconName,"UISprite").spriteName = "common_17"
			self:GetComponent("bg","UISprite").spriteName = "common_16"
		end
	end
end

function GameToggleView:SetCallback(callback, target)
	self.callback = callback 
	self.target = target
end

function GameToggleView:RefreshUI()
	self.iconGo = self:GetGameObject(self.iconName)
	self.label = self:GetComponent(self.labelName, typeof(UILabel))
	self.iconGo:SetActive(false)
	self.bgGo = self:GetGameObject("bg")
	addClickCallbackSelf(self.bgGo, self.OnClick, self)
	if self.label ~= nil then
		addClickCallbackSelf(self.label.gameObject, self.OnClick, self)
	end
end

function GameToggleView:SetText(text)
	self.text = text
	self.label.text = text
end


function GameToggleView:SetSelect(value)
	if self.isSelect == value then
		return
	end
	self.isSelect = value
	self.iconGo:SetActive(value)
end

function GameToggleView:OnClick()
	if self.isDisable then
		return
	end
	-- 由外部控制是否为选中  
	if self.callback ~= nil then
		self.callback(self.target, self)
	end
end

return GameToggleView
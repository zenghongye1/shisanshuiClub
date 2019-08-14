local base = require "logic/framework/ui/uibase/ui_view_base"
local ToggleView = class("ToggleView", base)

function ToggleView:SetCallback(changeCallback, target)
	self.changeCallback = changeCallback
	self.target = target
end

function ToggleView:InitToggle( data, normalSpName, selectSpName, normalColor, selectColor)
	self.data = data
	self.normalSpName = normalSpName
	self.selectSpName = selectSpName
	self.normalColor = normalColor
	self.selectColor = selectColor

	self.isSelect = false
	self:UpdateView()
end

function ToggleView:InitView()
	self.bgSp = self:GetComponent("", typeof(UISprite))
	self.label = self:GetComponent("Label", typeof(UILabel))

	addClickCallbackSelf(self.gameObject, self.OnClick, self)
end

function ToggleView:SetText(text)
	self.label.text = text
end

function ToggleView:UpdateView()
	if not self.isSelect then
		self.bgSp.spriteName = self.normalSpName
		if self.normalColor ~= nil then
			self.label.color = self.normalColor
		end
	else
		self.bgSp.spriteName = self.selectSpName
		if self.selectColor ~= nil then
			self.label.color = self.selectColor
		end
	end
end

function ToggleView:SetSelect(value, force)
	if self.isSelect == value and not force then
		return
	end
	self.isSelect = value
	self:UpdateView()
end

function ToggleView:OnClick()
	self:SetSelect(true)
	if self.changeCallback ~= nil then
		self.changeCallback(self.target, self)
	end
end

return ToggleView
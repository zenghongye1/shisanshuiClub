--[[--
 * @Description: 下拉组件
 * @Author:      ShushingWong
 * @FileName:    poplist_button.lua
 * @DateTime:    2017-12-12 14:59:58
 ]]
local openRoomBaseComp = require"logic/hall_sys/openroom/comp/openRoomBaseComp"
local poplist_button = class("poplist_button",openRoomBaseComp)

function poplist_button:InitView()
	openRoomBaseComp.InitView(self)
	self.main_label = self:GetComponent("Label","UILabel")
	self.button_go = self:GetGameObject("poplist_button")
	self.bg_sp = self:GetComponent("poplist_button","UISprite")

	self.eventFunc = nil
	addClickCallbackSelf(self.button_go,function ()
		self:OnBtnClick()
	end,self)
end

function poplist_button:SetText(text)
	self.main_label.text = text
end

function poplist_button:GetValue()
	return self.curValue
end

function poplist_button:SetValue(value)
	if self.curValue == value then
		return
	end
	self.curValue = value
	self:SetText(self.toggleData.text[value])
	self:OnValueChange(value)
end

function poplist_button:Show()
	if self.bg_sp and self.toggleData.itemWidth then
		self.bg_sp.width = self.toggleData.itemWidth
	end
end

function poplist_button:OnBtnClick()
	local callback = function (value)
		self:SetValue(value)
	end

	self.eventFunc(self.toggleData,self.curValue,callback)
end

function poplist_button:SetEventFunc(func)
	self.eventFunc = func
end

return poplist_button
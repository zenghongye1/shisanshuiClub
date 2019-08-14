--[[--
 * @Description: 多选组件
 * @Author:      ShushingWong
 * @FileName:    multi_toggle.lua
 * @DateTime:    2017-12-12 14:59:58
 ]]
local openRoomBaseComp = require"logic/hall_sys/openroom/comp/openRoomBaseComp"
local multi_toggle = class("multi_toggle",openRoomBaseComp)

local darkColor = Color(133/255, 133/255, 133/255)
local normalColor = Color(143/255, 74/255, 18/255)

function multi_toggle:InitView()
	openRoomBaseComp.InitView(self)
	self.self_toggle = componentGet(self.transform,"UIToggle")
	self.self_toggle.value = false
	self.Checkmark_sprite = self:GetComponent("Checkmark","UISprite")
	self.Checkmark_sprite.color.a = 0
	self.select_label = self:GetComponent("lab_select","UILabel")
	self.select_label.gameObject:SetActive(false)
	self.noselect_label = self:GetComponent("lab_noselect","UILabel")
	self.noselect_label.gameObject:SetActive(true)
	self.noselect_label.color = normalColor

	addClickCallbackSelf(self.gameObject,function ()
		if self.curValue == true then
			self.curValue = false
		else
			self.curValue = true
		end
		self:OnValueChange(self.curValue)
	end,self)
end

function multi_toggle:Init()
	self.self_toggle.value = false
	self.Checkmark_go:SetActive(false)
	self.select_label.gameObject:SetActive(false)
	self.noselect_label.gameObject:SetActive(true)
	self.noselect_label.color = normalColor
end

function multi_toggle:SetText(text)
	self.select_label.text = text
	self.noselect_label.text = text
end

function multi_toggle:SetAble(value)
	openRoomBaseComp.SetAble(self,value)
	if value == false then
		self.curValue = false
		self.self_toggle.value = false
		self:OnValueChange(false)
	end
	-- if value and self.self_toggle.value then
	-- 	self.Checkmark_go:SetActive(true)
	-- else
	-- 	self.Checkmark_go:SetActive(false)
	-- end
	if value then
		self.noselect_label.color = normalColor
	else
		self.noselect_label.color = darkColor
	end
	self.select_label.gameObject:SetActive(self.curValue)
	self.noselect_label.gameObject:SetActive(not self.curValue)
end

function multi_toggle:GetValue()
	local value = nil
	if self.self_button.isEnabled then
		value = self.self_toggle.value
	end
	return value
end

function multi_toggle:SetValue(value)
	if self.curValue == value then
		return
	end
	self.curValue = value
	self.self_toggle.value = value
	self:OnValueChange(value)
end

function multi_toggle:OnValueChange(value)
	openRoomBaseComp.OnValueChange(self,value)
	if value then
		self.Checkmark_sprite.color.a = 255
	else
		self.Checkmark_sprite.color.a = 0
	end
	self.select_label.gameObject:SetActive(value)
	self.noselect_label.gameObject:SetActive(not value)
end

function multi_toggle:Show()
    if LuaHelper.isAppleVerify ~= nil and 
    	LuaHelper.isAppleVerify and 
    	self.toggleData.iosdata~=nil and 
    	type(self.toggleData.iosdata)~=type(table)  then    
         self:SetText(self.toggleData.iosdata)
    else 
        self:SetText(self.toggleData.text)
    end
    self.self_toggle.group=self.toggleData.Group
	self.tips_view:SetTipsEnable(self.toggleData["tipsEnable"])
end

return multi_toggle
--[[--
 * @Description: 开房游戏列表toggle组件
 * @Author:      ShushingWong
 * @FileName:    openroom_gameItemBtn.lua
 * @DateTime:    2017-12-12 14:55:04
 ]]
local base = require "logic/framework/ui/uibase/ui_view_base"
local openroom_gameItemBtn = class("openroom_gameItemBtn",base)

function openroom_gameItemBtn:InitView()
	self.gid = 0
	self.self_toggle = componentGet(self.transform,"UIToggle")
	self.Background = self:GetGameObject("Background")
	self.Checkmark = self:GetGameObject("Checkmark")
	self.select_label = self:GetComponent("label_select","UILabel")
	self.noselect_label = self:GetComponent("label_noselect","UILabel")

	self.callback = nil
	addClickCallbackSelf(self.gameObject,self.OnBtnClick,self)
end

function openroom_gameItemBtn:SetCallback(func)
	self.callback = func
end

function openroom_gameItemBtn:OnBtnClick(obj)
	ui_sound_mgr.PlayButtonClick()
	if self.callback then
		self.callback(obj or self.gameObject)
	end
end

function openroom_gameItemBtn:SetText(text)
	self.select_label.text = text
	self.noselect_label.text = text
end

function openroom_gameItemBtn:SetName(gid)
	self.gid = gid
	self.gameObject.name = tostring(gid)
end

function openroom_gameItemBtn:SetValue(value)
	if value then
		self.Background:SetActive(false)
		self.Checkmark:SetActive(true)
		self.select_label.gameObject:SetActive(true)
		self.noselect_label.gameObject:SetActive(false)
	else
		self.Background:SetActive(true)
		self.Checkmark:SetActive(false)
		self.select_label.gameObject:SetActive(false)
		self.noselect_label.gameObject:SetActive(true)
	end
end

return openroom_gameItemBtn
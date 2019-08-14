--[[--
 * @Description: 游戏类型选择组件
 * @Author:      ShushingWong
 * @FileName:    openroom_poplist.lua
 * @DateTime:    2017-12-12 14:58:10
 ]]
local base = require "logic/framework/ui/uibase/ui_view_base"
local openroom_poplist = class("openroom_poplist",base)

function openroom_poplist:InitView()
	self.isMenuOpen = false
	self.toggleClickCB = nil
	self.toggleList = {}

	self.menuBtn_tr  = child(self.transform,"Sprite_menu/Sprite")
	addClickCallbackSelf(self.menuBtn_tr.gameObject,self.OnMenuBtnClick,self)
	self.menu_label = subComponentGet(self.transform,"Sprite_menu/Label","UILabel")
	self.menuGrid_tr = child(self.transform,"Grid")
	self.menuGrid_tr.gameObject:SetActive(false)
	self.menuBg_sprite = subComponentGet(self.transform,"Sprite_gridBg","UISprite")
	self.gridBoxCollider = componentGet(self.menuBg_sprite.transform, "BoxCollider")
	self.gridBoxCollider.enabled = self.isMenuOpen
	addClickCallbackSelf(self.menuBg_sprite.gameObject,self.OnMenuBgBtnClick,self)

	self:InitPopListToggle()
end

function openroom_poplist:InitPopListToggle()
	for i=1,3 do
		local Sprite_item = child(self.menuGrid_tr,"Sprite_m"..i)
		if Sprite_item then
			table.insert(self.toggleList,Sprite_item)
			Sprite_item.name = tostring(i-1)
			addClickCallbackSelf(Sprite_item.gameObject, function(_obj, _obj2)
				ui_sound_mgr.PlayButtonClick()
              self:OnMenuBgBtnClick()

              local listMenuLabel = componentGet(child(_obj2.transform, "Label"), "UILabel")
              if listMenuLabel then
                self:SetMenuLabel(listMenuLabel.text)
              end

              local iIndex = tonumber(_obj2.name) or 0
              self.toggleClickCB(iIndex)

            end,self)
		end
	end
end

function openroom_poplist:SetMenuLabel(text)
	self.menu_label.text = text or "全部"
end

function openroom_poplist:SetToggleCallback(callback)
	self.toggleClickCB = callback
end

function openroom_poplist:OnMenuBtnClick()
	ui_sound_mgr.PlayButtonClick()
	if self.isMenuOpen == true then
		self:OnMenuBgBtnClick()
	else
		self.isMenuOpen = true
		self.menuGrid_tr.gameObject:SetActive(true)
		self.menuBg_sprite.height = 289
        self.gridBoxCollider.enabled = self.isMenuOpen
	end
end

function openroom_poplist:OnMenuBgBtnClick()
	if self.isMenuOpen == false then
		return
	end
	self.isMenuOpen = false
	self.menuGrid_tr.gameObject:SetActive(false)
	self.menuBg_sprite.height = 74
	self.gridBoxCollider.enabled = self.isMenuOpen
end

return openroom_poplist
local base = require "logic/framework/ui/uibase/ui_view_base"
local reward_mjItem_view = class("reward_mjItem_view",base)

function reward_mjItem_view:InitView()
	base.InitView(self)
	self.icon = self:GetComponent("icon", typeof(UISprite))
	self.bgIcon = self:GetComponent("", typeof(UISprite))
	self.winIconGo = self:GetGameObject("winIcon")
	-- 如果需要  图片可以配置
	self.specialCardIconGo = self:GetGameObject("jinIcon")
	self.specialCardIconSp = self:GetComponent("jinIcon", typeof(UISprite))
	self.isSpecialCard = false
	self.specialCardIconGo:SetActive(false)
	self.isWin = false
	if self.winIconGo ~= nil then
		self.winIconGo:SetActive(false)
	end
	self.spriteName = "jin_1"
end

function reward_mjItem_view:SetValue(value)
	if value ~= 0 then
		self.icon.spriteName = value .. "_hand"
		self.icon.gameObject:SetActive(true)
		self.bgIcon.spriteName = "xjs_21"
	else
		self.bgIcon.spriteName = "xjs_32"
		self.icon.gameObject:SetActive(false)
		self:SetSpecialCard(false)
	end
end

function reward_mjItem_view:SetSpecialCard(value,spriteName)
	if spriteName and spriteName ~= self.spriteName then
		self.spriteName = spriteName
		self.specialCardIconSp.spriteName = spriteName
	end
	if value == self.isSpecialCard then
		return
	end
	self.isSpecialCard = value
	self.specialCardIconGo:SetActive(value)
end

function reward_mjItem_view:SetWin(value)
	if self.isWin == value then
		return
	end
	self.isWin = value
	if self.winIconGo ~= nil then
		self.winIconGo:SetActive(self.isWin)
	end
end

return reward_mjItem_view
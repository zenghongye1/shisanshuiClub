local base = require "logic/mahjong_sys/ui_mahjong/reward/ui_view_base"
local reward_title_view = class("reward_title_view", base)


local resultToIconNameMap = 
{
	[1] = "xjs_30",
	[2] = "xjs_29",
	[3] = "xjs_31",
}


function reward_title_view:InitView()
	base.InitView(self)
	self.titleWinBgGo = self:GetGameObject("titleWinBg")
	self.titleLoseBgGo = self:GetGameObject("titleLoseBg")
	self.titleIcon = self:GetComponent("titleIcon", typeof(UISprite))
end

-- res 1 胡 2 失败 3  荒庄  ...
function reward_title_view:SetResult(res)
	local iconName = resultToIconNameMap[res]
	if self.titleIcon ~= nil and iconName ~= nil then
		self.titleIcon.spriteName = iconName
	end
	self.titleWinBgGo:SetActive(res == 1)
	self.titleLoseBgGo:SetActive(res ~= 1)
end

return reward_title_view
local base = require "logic/framework/ui/uibase/ui_view_base"
local reward_head_view = class("reward_head_view", base)


-- huicon 不需要处理
function reward_head_view:InitView()
	base.InitView(self)
	self.headIconTex = self:GetComponent("headIcon", typeof(UITexture))
	self.nameLabel = self:GetComponent("name", typeof(UILabel))
	self.zhuangIconGo = self:GetGameObject("zhuangIcon")
	self.winIconGo = self:GetGameObject("huIcon")
	self.diLabel = self:GetComponent("di",typeof(UILabel))
	self.diLabel.gameObject:SetActive(false)
	self.zhuangIconGo:SetActive(false)
end

function reward_head_view:SetInfo(name, url, isBanker, imgType)
	self.nameLabel.text = name
	self.zhuangIconGo:SetActive(isBanker)
	HeadImageHelper.SetImage(self.headIconTex,imgType,url)
end

function reward_head_view:ShowWinIcon(value)
	if self.winIconGo ~= nil then
		self.winIconGo:SetActive(value)
	end
end

function reward_head_view:SetDi(num)
	if self.diLabel~=nil then
		self.diLabel.text = tostring(num)
		self.diLabel.gameObject:SetActive(true)
	end
end


return reward_head_view
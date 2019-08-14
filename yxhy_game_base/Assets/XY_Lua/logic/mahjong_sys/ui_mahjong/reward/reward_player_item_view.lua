local base = require "logic/framework/ui/uibase/ui_view_base"
local reward_player_item_view = class("reward_player_item_view", base)
local reward_head_view = require "logic/mahjong_sys/ui_mahjong/reward/reward_head_view"
local reward_info_view = require "logic/mahjong_sys/ui_mahjong/reward/reward_info_view"

function reward_player_item_view:InitView()
	base.InitView(self)
	self.headView = reward_head_view:create(self:GetGameObject("headView"))
	self.infoView = reward_info_view:create(self:GetGameObject("infoView"))
end

function reward_player_item_view:SetInfo(info,isWin, viewSeat,specialCardValues,specialCardType,ui)
	self:SetActive(true)
	self.headView:SetInfo(info.nickname, info.headUrl, info.isBanker, 2)
	self.infoView:SetInfo(info,info.isWin or isWin, viewSeat,specialCardValues,specialCardType,ui)

	--发发才有
	if info.difen then
		self.headView:SetDi(info.difen)
	else
		self.headView:SetDi("")
	end
	if info.pan then
		self.infoView:SetPan(info.pan)
	else
		self.infoView:SetPan("")
	end
end

function reward_player_item_view:ShowWin(value)
	self.headView:ShowWinIcon(value)
end

function reward_player_item_view:Clear()
	if self.infoView then
		self.infoView:Clear()
	end
end

return reward_player_item_view
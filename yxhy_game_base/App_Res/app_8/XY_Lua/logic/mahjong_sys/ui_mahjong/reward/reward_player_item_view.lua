local base = require "logic/mahjong_sys/ui_mahjong/reward/ui_view_base"
local reward_player_item_view = class("reward_player_item_view", base)
local reward_head_view = require "logic/mahjong_sys/ui_mahjong/reward/reward_head_view"
local reward_info_view = require "logic/mahjong_sys/ui_mahjong/reward/reward_info_view"

function reward_player_item_view:InitView()
	base.InitView(self)
	self.headView = reward_head_view:create(self:GetGameObject("headView"))
	self.infoView = reward_info_view:create(self:GetGameObject("infoView"))
end

function reward_player_item_view:SetInfo(info,isWin, viewSeat)
	self:SetActive(true)
	self.headView:SetInfo(info.name, info.url, info.isBanker, 2)
	self.infoView:SetInfo(info,isWin, viewSeat)
end

function reward_player_item_view:ShowWin(value)
	self.headView:ShowWinIcon(value)
end

return reward_player_item_view
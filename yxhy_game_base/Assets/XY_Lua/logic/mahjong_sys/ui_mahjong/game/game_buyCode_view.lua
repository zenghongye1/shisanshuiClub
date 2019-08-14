--[[--
 * @Description: 通用（特效+牌）展示模板（原来是结算买马）
 * @Author:      ShushingWong
 * @FileName:    game_buyCode_view.lua
 * @DateTime:    2018-04-09 18:52:22
 ]]
local base = require "logic/framework/ui/uibase/ui_load_view_base"
local game_buyCode_view = class("game_buyCode_view", base)

function game_buyCode_view:InitPrefabPath()
	self.prefabPath = data_center.GetResMJCommPath().."/ui/game/buyCodeView"
end

function game_buyCode_view:InitView()
	self.EffectPos_tr = self:GetGameObject("EffectPos").transform
	self.cardBg_go = self:GetGameObject("card_bg")
	self.cardBg_sp = self:GetComponent("card_bg", typeof(UISprite))
	self.card_sp = self:GetComponent("card_bg/card", typeof(UISprite))
end

function game_buyCode_view:OnLoaded()
	mahjong_ui:SetChild(self.transform, nil, nil, Vector3(0, 0, 0))
end

function game_buyCode_view:Refresh(effectID,value,callback)
	self:SetValue(effectID,value,callback)
end

function game_buyCode_view:SetValue(effectID,value,callback)
	if value then
		if value == 0 then
			self.cardBg_sp.spriteName = "wall_mine"
			self.card_sp.spriteName = ""
		else
			self.cardBg_sp.spriteName = "hand_mine"
			self.card_sp.spriteName = value.."_hand"
		end
		self.cardBg_go:SetActive(true)
	else
		self.cardBg_go:SetActive(false)
	end
	if effectID then
		mahjong_effectMgr:PlayUIEffectById(effectID,self.EffectPos_tr)
	end
	if callback then
		coroutine.start(function ()
		 	coroutine.wait(1)
		 	self:Hide()
		 	callback()
		end)
	end
end

return game_buyCode_view
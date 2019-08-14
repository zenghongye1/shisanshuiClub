local base = require "logic/framework/ui/uibase/ui_load_view_base"
local game_buySelfdraw_view = class("game_buySelfdraw_view", base)

function game_buySelfdraw_view:InitPrefabPath()
	self.prefabPath = data_center.GetResMJCommPath().."/ui/game/buySelfdrawView"
end

function game_buySelfdraw_view:InitView()
	self.buyTgle = self:GetGameObject("bg/buy")
	self.buyTgleSign = self:GetGameObject("bg/buy/Sprite")
	self.notBuyTgle = self:GetGameObject("bg/notBuy")
	self.notbuyTgleSign = self:GetGameObject("bg/notBuy/Sprite")
	addClickCallbackSelf(self.buyTgle,self.OnToggleChange,self)
	addClickCallbackSelf(self.notBuyTgle,self.OnToggleChange,self)

	self.btn = self:GetGameObject("Btn")
	addClickCallbackSelf(self.btn,self.OnBtnClick,self)
end

function game_buySelfdraw_view:OnToggleChange(obj)
	local objName = obj.name
	if objName == "buy" then
		self:SetValue(true)
	else
		self:SetValue(false)
	end
end

function game_buySelfdraw_view:OnLoaded()
	mahjong_ui:SetChild(self.transform, nil, nil, Vector3(-24, - 24, 0))
end

function game_buySelfdraw_view:OnBtnClick()
	mahjong_play_sys.BuySelfdrawReq(self.isBuy and 1 or 0)
end

function game_buySelfdraw_view:Refresh()
	self:SetValue(true)
end

function game_buySelfdraw_view:SetValue(isBuy)
	self.isBuy = isBuy
	self.buyTgleSign:SetActive(isBuy)
	self.notbuyTgleSign:SetActive(not isBuy)
end

return game_buySelfdraw_view
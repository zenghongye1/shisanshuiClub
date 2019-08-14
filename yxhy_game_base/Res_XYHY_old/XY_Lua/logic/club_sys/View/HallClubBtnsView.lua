local base = require "logic/framework/ui/uibase/ui_view_base"
local HallClubBtnsView = class("HallClubBtnsView", base)
local UIManager = UI_Manager:Instance() 

function HallClubBtnsView:InitView()
	self.model = model_manager:GetModel("ClubModel")
	self.recommendBtnGo = self:GetGameObject("Grid/Sprite_recommend")
	self.createBtnGo = self:GetGameObject("Grid/Sprite_create")
	self.joinBtnGo = self:GetGameObject("Grid/Sprite_join")
	addClickCallbackSelf(self.joinBtnGo, self.OnJoinBtnClick, self)
	addClickCallbackSelf(self.createBtnGo, self.OnCreateBtnClick, self)
	addClickCallbackSelf(self.recommendBtnGo, self.OnRecommendClick, self)
end

function HallClubBtnsView:OnRecommendClick()
	ui_sound_mgr.PlayButtonClick()
	--UIManager:ShowUiForms("ClubSelectUI")
	
	----点击推荐俱乐部直接加入列表第一个俱乐部
	self.model:ReqSearchClubListWithCallback(nil,nil,function(msg)
		Trace("ReqSearchClubListWithCallback----------"..GetTblData(msg))
		if msg["clublist"] ~= nil and #msg["clublist"] > 0 then
			self.model:ReqApplyClub(msg["clublist"][1]["shid"],msg["clublist"][1]["ctype"])
		end
	end)
end

function HallClubBtnsView:OnCreateBtnClick()
	ui_sound_mgr.PlayButtonClick()
	if model_manager:GetModel("ClubModel"):CanCreateClub() then
		UIManager:ShowUiForms("ClubCreateUI")
	else
		UIManager:ShowUiForms("ClubInputUI", nil, nil, ClubInputUIEnum.InputCode)
	end
end

function HallClubBtnsView:OnJoinBtnClick()
	ui_sound_mgr.PlayButtonClick()
	UIManager:ShowUiForms("ClubInputUI", nil, nil, ClubInputUIEnum.InputClubID)
end


return HallClubBtnsView
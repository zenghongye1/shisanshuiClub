local base = require("logic.framework.ui.uibase.ui_window")
local ClubCreateOrJoinUI = class("ClubCreateOrJoinUI", base)
local addClickCallbackSelf = addClickCallbackSelf
local UIManager = UI_Manager:Instance() 

function ClubCreateOrJoinUI:OnInit()
	self.model = model_manager:GetModel("ClubModel")
	self.returnBtnGo = self:GetGameObject("returnBtn")
	addClickCallbackSelf(self.returnBtnGo, self.OnCloseBtnClick, self)
	self.createBtnGo = self:GetGameObject("createBtn")
	addClickCallbackSelf(self.createBtnGo, self.OnCreateBtnClick, self)
	self.joinBtnGo = self:GetGameObject("joinBtn")
	addClickCallbackSelf(self.joinBtnGo, self.OnJoinBtnClick, self)
end


function ClubCreateOrJoinUI:OnCloseBtnClick()
	ui_sound_mgr.PlayCloseClick()
	UIManager:CloseUiForms("ClubCreateOrJoinUI")
end

function ClubCreateOrJoinUI:OnCreateBtnClick()
	ui_sound_mgr.PlayButtonClick()
	if self.model:CanCreateClub() then
		ClubUtil.OpenCreateClub()
	else
		UIManager:ShowUiForms("ClubInputUI", nil, nil, ClubInputUIEnum.InputCode)
	end
end

function ClubCreateOrJoinUI:OnJoinBtnClick()
	ui_sound_mgr.PlayButtonClick()
	UIManager:ShowUiForms("ClubInputUI", nil, nil, ClubInputUIEnum.InputClubID)
end

function ClubCreateOrJoinUI:PlayOpenAmination()

end


function ClubCreateOrJoinUI:OnRefreshDepth()

  local uiEffect = child(self.gameObject.transform, "createBtn/Effect_chuangjianjulebu")
  local uiEffect2 = child(self.gameObject.transform, "joinBtn/Effect_jiarujulebu")
  if uiEffect and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
    Utils.SetEffectSortLayer(uiEffect2.gameObject, topLayerIndex)
  end
end

return ClubCreateOrJoinUI
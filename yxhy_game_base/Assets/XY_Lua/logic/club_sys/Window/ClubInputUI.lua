local base = require("logic.framework.ui.uibase.ui_window")
local inputClass = require("logic/hall_sys/CommonInput/CommonInput")
local helpViewClass = require("logic/club_sys/View/HelpView")
local ClubInputUI = class("ClubInputUI", base)
local addClickCallbackSelf = addClickCallbackSelf
local ClubInputUIEnum = ClubInputUIEnum
local UIManager = UI_Manager:Instance() 

local TitleNameMap = 
{
	[1] = "Title_19",
	[2] = "Title_18",
}

local BtnNameMap = 
{
	[1] = "申请加入",
	[2] = "确 定",
}

local HelpContentMap = 
{
	[1] = {"", "前往加入"},
	[2] = {"申请获得代理商邀请码", "咨询"},
	[3] = {"钻石\n创建俱乐部", "前往"}
}

function ClubInputUI:ctor()
	base.ctor(self)
	HelpContentMap[1][1] = LanguageMgr.GetWord(10080)
	self.inputView = nil
	self.helpView = nil
	self.titleSp = nil
	self.model = model_manager:GetModel("ClubModel")
	self.type = ClubInputUIEnum.InputClubID
	self.destroyType = UIDestroyType.ChangeScene
end

function ClubInputUI:OnInit()
	self.closeBtnGo = self:GetGameObject("panel/Panel_Top/btn_close")
	addClickCallbackSelf(self.closeBtnGo, self.OnBtnCloseClick, self)

	self.titleSp = self:GetComponent("panel/Panel_Top/Title", typeof(UISprite))

	local numberGridGo = self:GetGameObject("panel/Panel_Middle/gird_number")
	local inputGridGo = self:GetGameObject("panel/Panel_Middle/grid_input")
	self.inputView = inputClass:create(inputGridGo, numberGridGo, slot(self.OnSureBtnClick, self), slot(self.CheckReq, self))
	self.inputView:InitView()

	local helpGo = self:GetGameObject("panel/helpView")
	self.helpView = helpViewClass:create(helpGo)
	self.helpView:SetActive(false)

	self.helpView2 = helpViewClass:create(self:GetGameObject("panel/helpView2"))
	self.helpView2:SetActive(false)

	self.costLabel = self:GetComponent("panel/Panel_Middle/costLabel", typeof(UILabel))
	self.goLabelGo = self:GetGameObject("panel/Panel_Middle/goLabel")
	addClickCallbackSelf(self.goLabelGo, self.CreateClubCallback, self)

	self.sureBtnLabel = self:GetComponent("panel/Panel_Middle/grid_input/11/Label", typeof(UILabel))
end

function ClubInputUI:OnClose()
	self.inputView:ClearNumList()
end

function ClubInputUI:OnOpen(uitype)
	self.type = uitype
	self:RefreshUI()
end

function ClubInputUI:OnRefreshDepth()
  local uiEffect = child(self.gameObject.transform, "panel/Panel_Top/Title/Effect_youxifenxiang")
  if uiEffect and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
  end
end

function ClubInputUI:OnBtnCloseClick()
	ui_sound_mgr.PlayCloseClick()
	UIManager:CloseUiForms("ClubInputUI")
end

function ClubInputUI:CheckReq()
	local count = #self.inputView:GetNumList()
	if count == 6 then
		self:OnInputCode()
	end
end


function ClubInputUI:OnSureBtnClick()
	ui_sound_mgr.PlayButtonClick()
	if not self:CheckCodeValide() then
		return 
	end
	if self.type == ClubInputUIEnum.InputClubID then
		self:OnInputID()
	else
		self:OnInputCode()
	end
	-- UIManager:CloseUiForms("ClubInputUI")
end

function ClubInputUI:RefreshUI()
	self.titleSp.spriteName = TitleNameMap[self.type]
	self.titleSp:MakePixelPerfect()
	self.sureBtnLabel.text = BtnNameMap[self.type]

	self.costLabel.text = tonumber(self.model:GetCreateClubCost()) .. "钻石创建个人俱乐部"
	-- self.helpView:SetActive(self.type == ClubInputUIEnum.InputClubID)
	-- self.helpView2:SetActive(self.type ~= ClubInputUIEnum.InputClubID)
	-- if self.type == ClubInputUIEnum.InputClubID then
	-- 	self.helpView:SetInfo(HelpContentMap[self.type][1], HelpContentMap[self.type][2], self.IDHelpCallback, self)
	-- else
	-- 	self.helpView2:SetInfo(self.model.noagentclubcost .. HelpContentMap[3][1], HelpContentMap[3][2], self.CreateClubCallback, self)
	-- 	self.helpView2:SetInfo2(HelpContentMap[self.type][1], HelpContentMap[self.type][2], self.CodeHelpCallback, self)
	-- end
end


function ClubInputUI:CheckCodeValide()
	local count = #self.inputView:GetNumList()
	if count < 6 then
		if self.type == ClubInputUIEnum.InputClubID then
			UIManager:FastTip(LanguageMgr.GetWord(10041))
		else
			UIManager:FastTip(LanguageMgr.GetWord(10031))
		end
		return false
	end
	return true
end

-- 点击回调
function ClubInputUI:OnInputID()
	local shid = table.concat(self.inputView:GetNumList())
	self.model:ReqApplyClub(shid)
end

function ClubInputUI:OnInputCode()
	local id = table.concat(self.inputView:GetNumList())
	self.model:ReqBindAgent(id)
end

function ClubInputUI:IDHelpCallback()
	UIManager:CloseUiForms("ClubInputUI")
--	UIManager:ShowUiForms("ClubSelectUI")
end

function ClubInputUI:CodeHelpCallback()
	UIManager:CloseUiForms("ClubInputUI")
	UIManager:ShowUiForms("ClubAgentGetUI")
end

function ClubInputUI:CreateClubCallback()
	UIManager:CloseUiForms("ClubInputUI")
	--UIManager:ShowUiForms("ClubCreateUI")
	ClubUtil.OpenCreateClub()
end

function ClubInputUI:OnRefreshDepth()

  local uiEffect = child(self.gameObject.transform, "panel/Panel_Top/Title/Effect_youxifenxiang")
  if uiEffect and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
  end
end

return ClubInputUI
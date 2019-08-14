local base = require("logic.framework.ui.uibase.ui_window")
local ClubKickUI = class("ClubKickUI", base)
local UIManager = UI_Manager:Instance() 

function ClubKickUI:ctor()
	base.ctor(self)
	self.toggleList = {}
	self.reasonConfig = {}
	self.reasonType = 4
end

function ClubKickUI:OnInit()
	self.model = model_manager:GetModel("ClubModel")
	self.reasonConfig = global_define.ClubKickReasonConfig
	self:InitView()
end

function ClubKickUI:OnOpen(cid,info)
	self.cid = cid
	self.info = info
	self:UpdateView()
end

function ClubKickUI:OnClose()
	self.reasonType = 4
	componentGet(self.toggleList[4].transform,"UIToggle").value = true
end

function ClubKickUI:PlayOpenAmination()
	--重写
end

function ClubKickUI:InitView()
	self.lbl_title = componentGet(self:GetGameObject("bg/sv_gold/lab_title"),"UILabel")
	for i=1,4 do
		self.toggleList[i] = self:GetGameObject("bg/sv_gold/toggle_grid/"..i)
		addClickCallbackSelf(self.toggleList[i],self.ToggleSelect,self)
		componentGet(child(self.toggleList[i].transform,"Lbl"),"UILabel").text = self.reasonConfig[i]
		componentGet(child(self.toggleList[i].transform,"checkLbl"),"UILabel").text = self.reasonConfig[i]
	end
	local btn_certain = self:GetGameObject("bg/sv_gold/btn_grid/btn_02")
	addClickCallbackSelf(btn_certain,self.CertainClick,self)
	local btn_cancel = self:GetGameObject("bg/sv_gold/btn_grid/btn_01")
	addClickCallbackSelf(btn_cancel,self.CancelClick,self)
	local btn_close = self:GetGameObject("bg/sv_gold/btn_close")
	addClickCallbackSelf(btn_close,self.CancelClick,self)
end

function ClubKickUI:UpdateView()
	self.lbl_title.text = LanguageMgr.GetWord(10048,self.info.nickname)
	self.lbl_title.color = Color.New(1,1,1,1)
end

function ClubKickUI:ToggleSelect(obj)
	local index = tonumber(obj.name)
	self.reasonType = index
end

function ClubKickUI:CertainClick()
	if self.cid ~= nil and self.info ~= nil and self.reasonType ~= 0 then
		self.model:ReqKickClubUser(self.cid,self.info.uid,self.reasonType)
		UIManager:CloseUiForms("ClubKickUI")
	end
end

function ClubKickUI:CancelClick()
	UIManager:CloseUiForms("ClubKickUI")
end

return ClubKickUI
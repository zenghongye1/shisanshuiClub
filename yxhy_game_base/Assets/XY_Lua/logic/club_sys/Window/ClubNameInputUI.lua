local base = require("logic.framework.ui.uibase.ui_window")
local ClubNameInputUI = class("ClubNameInputUI", base)
local addClickCallbackSelf = addClickCallbackSelf
local UIManager = UI_Manager:Instance() 

local bgNormalHeight = 58
local bgContentHeight = 116

local typeLabel = 
{
	type_name = "type_name",
	type_intro = "type_intro",
	type_connection = "type_connection"
}

function ClubNameInputUI:OnInit()
	self.destroyType = UIDestroyType.ChangeScene
	self.titleLabel = self:GetComponent("panel/titleLabel", typeof(UILabel))
	self.yesBtnGo = self:GetGameObject("panel/buttonY")
	addClickCallbackSelf(self.yesBtnGo, self.OnBtnYesClick, self)
	self.noBtnGo = self:GetGameObject("panel/buttonN")
	addClickCallbackSelf(self.noBtnGo, self.OnBtnCloseClick, self)
	self.closeBtnGo = self:GetGameObject("panel/closeBtn")
	addClickCallbackSelf(self.closeBtnGo, self.OnBtnCloseClick, self)
	self.yesBtnLabel = self:GetComponent("panel/buttonY/Label", typeof(UILabel))

	self.inputBg = self:GetComponent("panel/Panel_Top/bg4", typeof(UISprite))

	self.maxChar = 0

	self.LabelLst = {}
	for _,v in pairs(typeLabel) do
		local temp = {}
		temp.obj = self:GetGameObject("panel/"..v)
		temp.inputLabel = self:GetComponent("panel/"..v.."/Label", typeof(UIInput))
		EventDelegate.Add(temp.inputLabel.onSubmit, EventDelegate.Callback(function() self:OnDeclarationEdit() end))
		self.LabelLst[v] = temp
	end
	
	-- self.inputLabel = self:GetComponent("panel/Label", typeof(UIInput))
	-- EventDelegate.Add(self.inputLabel.onSubmit, EventDelegate.Callback(function() self:OnDeclarationEdit() end))
	
	self.curInputLabel = nil
end

function ClubNameInputUI:OnOpen(type, value, callback, target,maxChar)
	self.type = type

	local typeStr = ""
	if self.type == 1 or self.type == 2 then
		typeStr = typeLabel.type_name
	elseif self.type == 3 then
		typeStr = typeLabel.type_intro
	elseif self.type == 4 then
		typeStr = typeLabel.type_connection
	else
		logError(self.type)
		return
	end

	for _,v in pairs(typeLabel) do
		if v == typeStr then
			self.LabelLst[v].obj:SetActive(true)
		else
			self.LabelLst[v].obj:SetActive(false)
		end
	end
	self.curInputLabel = self.LabelLst[typeStr].inputLabel

	if value ~= "" and value ~= "请输入简介" and value ~= "请输入俱乐部名称" then
		self.curInputLabel.value = value
		self.curInputLabel.label.text = value
	else
		self.curInputLabel.value = ""
		self:UpdateInputLabel()
	end
	self.maxChar = maxChar or 7


	self.curInputLabel.characterLimit = self.maxChar

	self.callback = callback
	self.target = target
	self:UpdateType()
end

function ClubNameInputUI:OnClose()
	self.curInputLabel.value = ""
	self.curInputLabel.label.text = ''
	self.curInputLabel = nil
	self.callback = nil
	self.target = nil
end


function ClubNameInputUI:UpdateInputLabel()
	if self.type == 1 then
		self.curInputLabel.label.text = "输入俱乐部名称"
	elseif self.type == 2 then
		self.curInputLabel.label.text = "输入俱乐部名称"
	elseif self.type == 3 then
		self.curInputLabel.label.text = "输入俱乐部简介"
	elseif self.type == 4 then
		self.curInputLabel.label.text = "输入联系方式"
	end
end

function ClubNameInputUI:UpdateType()
	if self.type == 1 then
		self.titleLabel.text = "设置俱乐部名称"
		self.yesBtnLabel.text = "确定"
	elseif self.type == 2 then
		self.titleLabel.text = "更改俱乐部名称"
		self.yesBtnLabel.text = "更改"
	elseif self.type == 3 then
		self.titleLabel.text = "设置俱乐部简介"
		self.yesBtnLabel.text = "确定"
	elseif self.type == 4 then
		self.titleLabel.text = "设置联系方式"
		self.yesBtnLabel.text = "确定"
	end

	if self.type ~= 3 then
		self.inputBg.height = bgNormalHeight
	else
		self.inputBg.height = bgContentHeight
	end

end

function ClubNameInputUI:OnBtnYesClick()
	ui_sound_mgr.PlayButtonClick()
	if self.callback ~= nil then
		local value = self.curInputLabel.value 
		if self.type < 3 then
			value = Utils.subUtf8(value, 7)
		end
		self.callback(self.target, value)
	end
	UIManager:CloseUiForms("ClubNameInputUI")
end

function ClubNameInputUI:OnBtnCloseClick()
	ui_sound_mgr.PlayCloseClick()
	UIManager:CloseUiForms("ClubNameInputUI")
end


function ClubNameInputUI:OnDeclarationEdit()
	self.curInputLabel.value = string.gsub(self.curInputLabel.value, "\n", "")
end



return ClubNameInputUI
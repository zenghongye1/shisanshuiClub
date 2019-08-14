local base = require("logic.framework.ui.uibase.ui_window")
local MessageBox = class("MessageBox", base)
local BtnView = require("logic/common_ui/BtnView")
local UI_Manager = UI_Manager:Instance()
local LuaHelper = LuaHelper
local addClickCallbackSelf = addClickCallbackSelf
local BtnInfo = require("logic/club_sys/Data/ButtonInfo")

function MessageBox:OnInit()
	self.autoClose = true
	self.m_UiLayer = UILayerEnum.UILayerEnum_Top
	self.contentLabel = self:GetComponent("bg/sv_gold/lab_content", typeof(UILabel))
	self.closeBtnGo = self:GetGameObject("bg/sv_gold/btn_close")
	addClickCallbackSelf(self.closeBtnGo, self.OnCloseBtnClick, self)

	self.btnList = {}
	for i = 1, 2 do
		local go = self:GetGameObject("bg/sv_gold/btn_grid/btn_0" .. i)
		local btn = BtnView:create(go, "Background")
		btn:SetActive(false)
		self.btnList[i] = btn
	end

end

function MessageBox:OnOpen(content, btnInfoList, closeCallback, autoClose)
	if autoClose ~= false then
		autoClose = true
	end
	UI_Manager:CloseUiForms("activity_ui")
	-- self.contentLabel.text = content
	--支持subTitle
	if type(content) =="table" then
		self.contentLabel.gameObject:SetActive(false)
		local comContent = self:GetGameObject("bg/sv_gold/com_content")
		if comContent then
			comContent:SetActive(true)
		end
		local title = self:GetComponent("bg/sv_gold/com_content/title", typeof(UILabel))
		if title then
			title.text = content[1]
		end
		local subTitle = self:GetComponent("bg/sv_gold/com_content/subTitle", typeof(UILabel))
		if subTitle then
			subTitle.text = content[2]
		end
		local contentLabel = self:GetComponent("bg/sv_gold/com_content/content", typeof(UILabel))
		if contentLabel then
			contentLabel.text = content[3]
		end
	else
		self.contentLabel.gameObject:SetActive(true)
		local comContent = self:GetGameObject("bg/sv_gold/com_content")
		if comContent then
			comContent:SetActive(false)
		end
		self.contentLabel.text = content

		--contentLabel重置初始颜色
		if self.contentLabelColor then
			self.contentLabel.color = self.contentLabelColor
			self.contentLabelColor = nil
		end
	end

	self.closeCallback = closeCallback
	self.autoClose = autoClose
	self:HideAllBtns()
	local count = #btnInfoList
	if count > 2 then
		count = 2
	end
	for i = 1, count do
		self.btnList[i]:SetInfo(btnInfoList[i], self.OnBtnClick, self)
		self.btnList[i]:SetActive(true)
	end
	self:UpdateBtnPos(count)
end

function MessageBox:PlayOpenAmination()

end

function MessageBox:OnRefreshDepth()
	local uiEffect = child(self.gameObject.transform, "bg/Panel_Top/Title/Effect_youxifenxiang")
	if uiEffect and self.sortingOrder then
		local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
		Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
	end
end

function MessageBox:UpdateBtnPos( count )
	if count == 1 then
		LuaHelper.SetTransformLocalX(self.btnList[1].transform, 0)
	else
		LuaHelper.SetTransformLocalX(self.btnList[1].transform, 150)
		LuaHelper.SetTransformLocalX(self.btnList[2].transform, -150)
	end

end

function MessageBox:HideAllBtns()
	for i = 1, 2 do
		self.btnList[i]:SetActive(false)
	end
end

function MessageBox:EnableContentBBCode()
    --强制白色
    if self.contentLabel then
        self.contentLabelColor = self.contentLabel.color
        self.contentLabel.color = Color.New(1,1,1, 1)
    end
end

function MessageBox:OnBtnClick(item)
	ui_sound_mgr.PlayButtonClick()
	if item.info ~= nil then
		item.info:Call()
	end
	if self.autoClose then
		self:Hide()
	end
end

function MessageBox:OnCloseBtnClick()
	ui_sound_mgr.PlayCloseClick()
	if self.closeCallback ~= nil then
		self.closeCallback()
		self.closeCallback = nil
	end
	self:Hide()
end

function MessageBox:Hide()
	UI_Manager:CloseUiForms("MessageBox")
end


function MessageBox.ShowSingleBox(content, callback, text, closeCallback, autoClose)
	local tab = {}
	tab[1] = MessageBox.YesBtnInfo
	MessageBox.YesBtnInfo.callback = callback
	MessageBox.YesBtnInfo.text = text or "确 定"		
	return MessageBox.Show(content, tab, closeCallback, autoClose)
end

function MessageBox.ShowMultiBox(content, callbackY, textY, callbackN, textN,  closeCallback, autoClose)
	MessageBox.YesBtnInfo.callback = callbackY
	MessageBox.YesBtnInfo.text = textY or "确 定"
	MessageBox.YesBtnInfo.bgSp = "button_03"
	MessageBox.NoBtnInfo.callback = callbackN
	MessageBox.NoBtnInfo.text = textN or "取 消"
	MessageBox.NoBtnInfo.bgSp = "button_05"
	local tab = {}
	tab[1] = MessageBox.YesBtnInfo
	tab[2] = MessageBox.NoBtnInfo
	return MessageBox.Show(content, tab, closeCallback, autoClose)
end

function MessageBox.ShowYesNoBox(content, callbackY, callbackN, closeCallback, autoClose)
	return MessageBox.ShowMultiBox(content, callbackY, nil, callbackN, nil,  closeCallback, autoClose)
end

function MessageBox.Show(content, buttonInfos, closeCallback, autoClose)
	return UI_Manager:ShowUiForms("MessageBox", nil,nil, content, buttonInfos, closeCallback, autoClose)
end


function MessageBox.InitData()
	local YesBtnInfo = BtnInfo:create()
	YesBtnInfo.text = "确 定"
	YesBtnInfo.bgSp = "button_03"
	MessageBox.YesBtnInfo = YesBtnInfo

	local NoBtnInfo = BtnInfo:create()
	NoBtnInfo.text = "取 消"
	NoBtnInfo.bgSp = "button_05"
	MessageBox.NoBtnInfo = NoBtnInfo
end

function MessageBox.GetBtnInfo(text, bgSp, callback, target)
	local info = BtnInfo:create()
	info.text = text or "确 定"
	info.bgSp = bgSp or "button_03"
	info.callback = callback
	info.target = target
	return info
end

function MessageBox.HideBox()
	UI_Manager:CloseUiForms("MessageBox")
end

MessageBox.InitData()

return MessageBox
local base = require "logic/framework/ui/uibase/ui_view_base"
local ClubBtnsView = class("ClubBtnsView", base)
local BtnView = require("logic/common_ui/BtnView")
local LuaHelper = LuaHelper


local btnHeight = 80
local startPosY = 75
local bgHeightOffset = 50
local width = 220

function ClubBtnsView:InitView()
	self.btSp = self:GetComponent("btnsView", typeof(UISprite))
	self.btnViewTr = self:GetGameObject('btnsView').transform
	self.btnItemGo = self:GetGameObject("btnsView/btn1")
	self.maskGo = self:GetGameObject("btnsView/mask")
	self.btnList = {}
	local btn = BtnView:create(self.btnItemGo)
	self.btnList[1] = btn
	addClickCallbackSelf(self.maskGo, self.OnMaskClick, self)
end

function ClubBtnsView:SetLimit(left, right, top, bottom)
	local height = Screen.height
	local width = Screen.width
	self.limitLeft = left or - width / 2
	self.limitRight = right or width / 2
	self.limitTop = top or height /2
	self.limitBottom = bottom or - height / 2
end

function ClubBtnsView:Show(buttonInfoList)
	self:SetActive(true)
	self.btnInfoList = buttonInfoList
	self:UpdateView()
	self:UpdatePosition()
end


function ClubBtnsView:UpdateView()
	self.height = bgHeightOffset + btnHeight * #self.btnInfoList
	self.btSp.height = self.height
	local offsetY = startPosY
	for i = 1, #self.btnInfoList do
		local btn = self:GetItem(i)
		btn:SetInfo(self.btnInfoList[i], self.OnItemClick, self)
		btn:SetActive(true)
		LuaHelper.SetTransformLocalY(btn.transform, offsetY)
		offsetY = offsetY + btnHeight
	end
	self:HideOthers()
end

function ClubBtnsView:UpdatePosition()
	local mousePos = Input.mousePosition
	local worldPos = UICamera.currentCamera:ScreenToWorldPoint(mousePos)
	local localPos = self.transform:InverseTransformPoint(worldPos)
	self:FormatPos(localPos)
	self.btnViewTr.localPosition = localPos
end

function ClubBtnsView:HideOthers()
	for i = #self.btnInfoList + 1, #self.btnList do
		self.btnList[i]:SetActive(false)
	end
end

function ClubBtnsView:FormatPos(pos)
	if self.limitBottom > pos.y then
		pos.y = self.limitBottom
	end
	if self.limitTop < pos.y + self.height then 
		pos.y = self.limitTop - self.height
	end
	if self.limitLeft > pos.x then
		pos.x = self.limitLeft
	end
	if self.limitRight < pos.x + width then
		pos.x = self.limitRight - width
	end
end


function ClubBtnsView:OnItemClick(item)
	if item.info ~= nil then
		item.info:Call()
	end
	self:Hide()
end

function ClubBtnsView:OnMaskClick()
	self:Hide()
end

function ClubBtnsView:Hide()
	self:SetActive(false)
end


function ClubBtnsView:GetItem(i)
	if self.btnList[i] ~= nil then
		return self.btnList[i]
	end
	local go = newobject(self.btnItemGo)
	local btn = BtnView:create(go)
	go.transform:SetParent(self.btnViewTr, false)
	table.insert(self.btnList, btn)
	return btn
end


return ClubBtnsView
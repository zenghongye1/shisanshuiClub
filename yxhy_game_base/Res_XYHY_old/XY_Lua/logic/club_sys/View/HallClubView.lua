local base = require "logic/framework/ui/uibase/ui_view_base"
local HallClubView = class("HallClubView", base)
local ui_wrap = require "logic/framework/ui/uibase/ui_wrap"
local ClubInfoItem = require "logic/club_sys/View/HallClubInfoItem"
local ColorJ = Color.New(168 / 255, 88 / 255, 27 / 255)
local ColorB = Color.New(1, 229 / 255, 180 / 255)
local UIManager = UI_Manager:Instance() 
local HallClubViewEnum = HallClubViewEnum
local hidePosX = -281
local showPosX = 170
function HallClubView:InitView()
	self.isShow = false
	self.isMoving = false
	self.tween = nil
	self.model = model_manager:GetModel("ClubModel")
	self.itemList = {}
	self.currentClubList = {}
	self.type = HallClubViewEnum.created
	self.toggleLabel1 = self:GetComponent("toggleLabel1", typeof(UILabel))
	self.toggleLabel2 = self:GetComponent("toggleLabel2", typeof(UILabel))
	self.tipsLabel = self:GetComponent("tips", typeof(UILabel))
	-- self.btnSp = self:GetComponent("button/Sprite", typeof(UISprite))
	self.selectIconTr = self:GetGameObject("selectIcon").transform
	self:InitItems()

	self.checkList = {self:GetComponent("bg", typeof(UISprite)), self:GetComponent("hideBtn", typeof(UISprite))}

	self.hideBtnGo = self:GetGameObject("hideBtn")
	addClickCallbackSelf(self.hideBtnGo, function() ui_sound_mgr.PlayButtonClick() self:Hide() end, self)

	-- self.createBtnGo = self:GetGameObject("button")
	-- addClickCallbackSelf(self.createBtnGo, self.OnCreateBtnClick, self)

	addClickCallbackSelf(self.toggleLabel1.gameObject, self.OnToggle1Click, self)
	addClickCallbackSelf(self.toggleLabel2.gameObject, self.OnToggle2Click, self)

	self.wrap = ui_wrap:create(self:GetGameObject("container"))
	self.wrap:InitUI(100)
	self.wrap.OnUpdateItemInfo = function(go, rindex, index)self:OnItemUpdate(go, index, rindex) end
	self.wrap:InitWrap(0)
	self:SetType(HallClubView.created)
end

function HallClubView:SetCallback(moveCallback, target)
	self.moveCallback = moveCallback
	self.target = target
end


function HallClubView:InitItems()
	for i = 1, 5 do
		local go = self:GetGameObject("container/scrollview/ui_wrapcontent/item" .. i)
		local item = ClubInfoItem:create(go)
		item:SetCallback(self.OnItemClick, self)
		item:SetActive(false)
		self.itemList[i] = item
	end
end

function HallClubView:OnShow()
	if self.model.currentClubInfo == nil then
		return
	end
	if self.model:IsClubCreater(self.model.currentClubInfo.cid) then
		self:SetType(HallClubViewEnum.created)
	else
		self:SetType(HallClubViewEnum.joined)
	end
	self:UpdateDatas()
end


function HallClubView:UpdateType()
	if self.type == HallClubViewEnum.created then
		self.toggleLabel1.color = ColorB
		self.toggleLabel2.color = ColorJ
		LuaHelper.SetTransformLocalY(self.toggleLabel1.transform, 233)
		LuaHelper.SetTransformLocalY(self.toggleLabel2.transform, 238)
		LuaHelper.SetTransformLocalX(self.selectIconTr, 148)
		-- self.btnSp.spriteName = "club_60"
	else
		self.toggleLabel1.color = ColorJ
		self.toggleLabel2.color = ColorB
		LuaHelper.SetTransformLocalY(self.toggleLabel1.transform, 238)
		LuaHelper.SetTransformLocalY(self.toggleLabel2.transform, 233)
		LuaHelper.SetTransformLocalX(self.selectIconTr, -12)
		-- self.btnSp.spriteName = "club_61"
	end
	self:UpdateDatas()
end

function HallClubView:UpdateDatas()
	if not self.model:HasClub() then
		return
	end
	if self.type == HallClubViewEnum.created then
		self.currentClubList = self.model:GetClubListByType(ClubMemberState.agent)
	else
		self.currentClubList = self.model:GetClubListByType(ClubMemberState.member)
	end
	if self.currentClubList == nil then
		self.wrap:InitWrap(0)
	else
		self.wrap:InitWrap(#self.currentClubList)
	end
	if self.currentClubList ~= nil and #self.currentClubList > 0 then
		self.tipsLabel.gameObject:SetActive(false)
	else
		self.tipsLabel.gameObject:SetActive(true)
		if self.type == HallClubViewEnum.created then
			self.tipsLabel.text = "你还没创建俱乐部"
		else
			self.tipsLabel.text = "你还没加入俱乐部"
		end
	end
end


function HallClubView:SetType(type)
	self.type = type
	self:UpdateType()
end

function HallClubView:OnCreateBtnClick()
	ui_sound_mgr.PlayButtonClick()
	if self.type == HallClubViewEnum.created then
		if self.model:CanCreateClub() then
			UIManager:ShowUiForms("ClubCreateUI")
		else
			UIManager:ShowUiForms("ClubInputUI", nil, nil, ClubInputUIEnum.InputCode)
		end
	else
		UIManager:ShowUiForms("ClubInputUI", nil, nil, ClubInputUIEnum.InputClubID)
	end
	-- self:Hide()
end

function HallClubView:OnItemUpdate(go, index, rindex)
	if self.itemList[index] ~= nil then
		self.itemList[index]:SetInfo(self.currentClubList[rindex])
	end
end

function HallClubView:OnToggle1Click()
	ui_sound_mgr.PlayButtonClick()
	if self.type == HallClubViewEnum.joined then
		return
	end
	self:SetType(HallClubViewEnum.joined)
end

function HallClubView:OnToggle2Click()
	ui_sound_mgr.PlayButtonClick()
	if self.type == HallClubViewEnum.created then
		return
	end
	self:SetType(HallClubViewEnum.created)
end

function HallClubView:OnItemClick(item)
	if item.clubInfo ~= nil then
		ui_sound_mgr.PlayButtonClick()
		model_manager:GetModel("ClubModel"):SetCurrentClubInfo(item.clubInfo, true)
		UIManager:GetUiFormsInShowList("hall_ui"):ShowClub()
	end
end

function HallClubView:OnMouseBtnDown(pos)
	if self.isShow == false then
		return
	end
	-- if not Utils.CheckPointInUIs(self.checkList, pos) then
	-- 	--self:Hide()
	-- end
end

function HallClubView:Show()
	if self.isMoving then
		return
	end
	self.isShow = true
	self:DoMove(showPosX)
end

function HallClubView:Hide(now)
	if self.isMoving and not now then
		return
	end
	self.isShow = false
	self:DoMove(hidePosX, now)
end

function HallClubView:DoMove(posX, now)
	self.isMoving = true
	local time = 0.2
	if now then
		time = 0
	end
	self.transform:DOLocalMoveX(posX, time, false):OnComplete(
	function()
		self.isMoving = false
		if self.moveCallback ~= nil then
			self.moveCallback(self.target)
		end
	end)
end


return HallClubView
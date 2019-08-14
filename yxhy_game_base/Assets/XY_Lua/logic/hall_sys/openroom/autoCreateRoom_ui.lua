local clubModel = model_manager:GetModel("ClubModel")
local AutoOpenRoomItem = require("logic/club_sys/View/new/AutoOpenRoomItem")
local base = require("logic.framework.ui.uibase.ui_window")
local autoCreateRoom_ui = class("autoCreateRoom_ui",base)
local ui_wrap = require "logic/framework/ui/uibase/ui_wrap"
local UIManager = UI_Manager:Instance() 
local addClickCallbackSelf = addClickCallbackSelf

local isOpen = false

function autoCreateRoom_ui:OnInit()
	self.model = model_manager:GetModel("ClubModel")
	self.notAutoClose = false
	self.itemList = {}
	
	self.closeBtn = self:GetGameObject("panel/Panel_Top/btn_close")
	addClickCallbackSelf(self.closeBtn.gameObject, self.OnBtnClose, self)
	self:InitItem()
	self.tipGo = self:GetGameObject("panel/tips")
	self.wrap = ui_wrap:create(self:GetGameObject("panel/container"))
	self.wrap:InitUI(106)
	self.wrap.OnUpdateItemInfo = function(go, rindex, index)  self:OnItemUpdate(go, index, rindex)  end
	self.wrap:InitWrap(0)
end

function autoCreateRoom_ui:OnOpen(cid,autoClose)
	self.wrap:ResetPosition()
	isOpen = true
	self.cid = cid
	self.notAutoClose = autoClose
	Notifier.regist(GameEvent.OnPushMsg, self.OnAutoOpenRoomUpdate, self)
end

function autoCreateRoom_ui:OnClose()
	isOpen = false
	self.notAutoClose = false
	Notifier.remove(GameEvent.OnPushMsg, self.OnAutoOpenRoomUpdate, self)
	if self.itemList == nil then return end
	for i = 1, #self.itemList do
		self.itemList[i]:SetActive(false)
	end
end

function autoCreateRoom_ui:SetInfo()
	self:UpdateView()
end

function autoCreateRoom_ui:OnAutoOpenRoomUpdate()
	self:UpdateView()
end

function autoCreateRoom_ui:UpdateView()
	if not self.model:HasClub() then
		return
	end
	if self.model.currentClubInfo == nil then
		return
	end
	
	if self.dataList == nil or #self.dataList == 0 then
		self.wrap:InitWrap(0)
	else
		self.wrap:InitWrap(#self.dataList)
	end

	if self.dataList == nil or #self.dataList == 0 then
		self.tipGo.gameObject:SetActive(true)
	else
		self.tipGo.gameObject:SetActive(false)
	end
end

function autoCreateRoom_ui:GetAutoCreateRoomList(cid,force,callback)
	self.model:ReqGetAutoCreateRoomList(cid,force,function(msgTab)
		if msgTab == nil then
			msgTab.auto_info = {}
		end
		self.dataList = msgTab.auto_info 
		self:UpdateView()		
	end)
end

function autoCreateRoom_ui:PlayOpenAnimationFinishCallBack()
	self:GetAutoCreateRoomList(self.cid,true,function()
		if isOpen then
			self:UpdateView()
		end
	end)
end


function autoCreateRoom_ui:OnBtnClose()
	ui_sound_mgr.PlayButtonClick()
	UIManager:CloseUiForms("autoCreateRoom_ui")
end

function autoCreateRoom_ui:InitItem()
		
	for i = 1, 7 do
		local go = self:GetGameObject("panel/container/scrollview/ui_wrapcontent/item" .. i)
		local item = AutoOpenRoomItem:create(go)
		item:SetActive(false)
		table.insert(self.itemList, item)
		item:SetCallback(self.OnItemClick, self)
	end
end

function autoCreateRoom_ui:OnItemUpdate(go, index, rindex)
	if self.itemList[index] ~= nil then
		self.itemList[index]:SetActive(true)
		self.itemList[index].gameObject.name = rindex
		self.itemList[index]:SetInfo(self.dataList[rindex])
	end
end


--跑马灯
function autoCreateRoom_ui:OnRefreshDepth()
	local uiEffect = child(self.gameObject.transform, "panel/Panel_Top/Title/Effect_youxifenxiang")
	if uiEffect and self.sortingOrder then
		local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
		Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
	end
end
--回调刷新自动开房列表
function autoCreateRoom_ui:OnItemClick(item)
	if self.dataList ~= nil then
		table.remove(self.dataList,item.gameObject.name)
		self:UpdateView()
	end
end

return autoCreateRoom_ui
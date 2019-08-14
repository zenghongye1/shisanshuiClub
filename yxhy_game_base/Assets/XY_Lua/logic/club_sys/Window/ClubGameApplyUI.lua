local base = require "logic/framework/ui/uibase/ui_view_base"
local UIManager = UI_Manager:Instance()

local ClubGameApplyItem = class("ClubGameApplyItem", base)

function ClubGameApplyItem:InitView()
	self.nameLabel = self:GetComponent("name", typeof(UILabel))
	self.numLabel = self:GetComponent("num", typeof(UILabel))
	addClickCallbackSelf(self.gameObject, self.OnItemClick, self)
end

function ClubGameApplyItem:SetInfo(clubInfo)
	if clubInfo == nil then
		return
	end
	self.clubInfo = clubInfo
	self.nameLabel.text = clubInfo.cname
	self.numLabel.text = clubInfo.applyNum .. "个新的申请"
end

function ClubGameApplyItem:OnItemClick()
	if self.clubInfo == nil then
		return
	end
	UIManager:ShowUiForms("ClubApplyUI", nil,nil, self.clubInfo.cid)
end

local ui_wrap = require "logic/framework/ui/uibase/ui_wrap"
local base = require("logic.framework.ui.uibase.ui_window")
local ClubGameApplyUI = class("ClubGameApplyUI", base)



function ClubGameApplyUI:OnInit()
	-- self.m_UiLayer = UILayerEnum.UILayerEnum_Top
	self.model = model_manager:GetModel("ClubModel")
	self.itemList = {}
	self.clubList = {}
	self.closeBtnGo = self:GetGameObject("btn_close")
	addClickCallbackSelf(self.closeBtnGo, self.OnCloseClick, self)

	self:InitItem()

	self.wrap = ui_wrap:create(self:GetGameObject("container"))
	self.wrap:InitUI(106)
	self.wrap.OnUpdateItemInfo = function(go, rindex, index)  self:OnItemUpdate(go, index, rindex)  end
	self.wrap:InitWrap(0)

end

function ClubGameApplyUI:InitItem()
	for i = 1, 5 do
		local go = self:GetGameObject("container/scrollview/ui_wrapcontent/item" .. i)
		local item = ClubGameApplyItem:create(go)
		item:SetActive(false)
		table.insert(self.itemList, item)
	end
end


function ClubGameApplyUI:OnOpen()
	Notifier.regist(GameEvent.OnPlayerApplyClubChange, self.UpdateView, self)
	self:UpdateView(true)
end

function ClubGameApplyUI:UpdateView(notCheck)
	self.clubList = self.model:GetHasApplyMemeberList()
	if not notCheck and self.clubList == nil or #self.clubList == 0 then
		UIManager:CloseUiForms("ClubGameApplyUI")
		return
	end
	self.wrap:InitWrap(#self.clubList)
end

function ClubGameApplyUI:OnClose()
	Notifier.remove(GameEvent.OnPlayerApplyClubChange, self.UpdateView, self)
end



function ClubGameApplyUI:OnCloseClick()
	ui_sound_mgr.PlayCloseClick()
	UIManager:CloseUiForms("ClubGameApplyUI")
end

function ClubGameApplyUI:OnItemUpdate(go, index, rindex)
	if self.itemList[index] ~= nil then
		self.itemList[index]:SetInfo(self.clubList[rindex])
	end
end

return ClubGameApplyUI
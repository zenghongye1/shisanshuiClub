local base = require("logic.framework.ui.uibase.ui_window")
local ClubApplyUI = class("ClubApplyUI", base)
local UIManager = UI_Manager:Instance() 
local addClickCallbackSelf = addClickCallbackSelf
local ClubMemberEnum = ClubMemberEnum
local ClubMemberItem = require("logic/club_sys/View/new/ClubMemberItem")
local ui_wrap = require "logic/framework/ui/uibase/ui_wrap"

function ClubApplyUI:OnInit()
	self.model = model_manager:GetModel("ClubModel")
	self.type = ClubMemberEnum.apply
	self.notAutoClose = false

	self.itemList = {}
	self.top_Bg = self:GetGameObject("panel/Panel_Top/bg")
	self.closeBtn = self:GetGameObject("panel/Panel_Top/btn_close")
	addClickCallbackSelf(self.closeBtn, self.OnBtnClose, self)
	self.noApplyTip = self:GetGameObject("panel/NoApplytips")
	self:InitItem()

	self.clubNameLabel = self:GetComponent("panel/clubName", typeof(UILabel))
	self.clubIDLabel = self:GetComponent("panel/ID", typeof(UILabel))

	self.wrap = ui_wrap:create(self:GetGameObject("panel/container"))
	self.wrap:InitUI(106)
	self.wrap.OnUpdateItemInfo = function(go, rindex, index)  self:OnItemUpdate(go, index, rindex)  end
	self.wrap:InitWrap(0)
	self:UpdateView(true)
end


function ClubApplyUI:OnOpen(cid, autoClose)
	self.cid = cid
	self.notAutoClose = autoClose
	self.model:RemovePlayerApply(self.cid)
	local clubInfo = self.model.clubMap[self.cid]
	if clubInfo == nil then
		self.clubNameLabel.text = ""
		self.clubIDLabel.text = ""
	else
		self.clubNameLabel.text = clubInfo.cname
		self.clubIDLabel.text = "ID:" .. clubInfo.shid
	end
	Notifier.regist(GameEvent.OnClubApplyMemberUpdate, self.OnApplyMemberUpdate, self)
	Notifier.regist(GameEvent.OnPlayerApplyClubChange, self.OnPlayerApplyClubChange, self)
end

function ClubApplyUI:OnClose()
	self.notAutoClose = false
	self.memberList = {}
	self.model.currentApplyMemberList = nil
	Notifier.remove(GameEvent.OnClubApplyMemberUpdate, self.OnApplyMemberUpdate, self)
	Notifier.remove(GameEvent.OnPlayerApplyClubChange, self.OnPlayerApplyClubChange, self)
	for i = 1, #self.itemList do
		self.itemList[i]:SetActive(false)
	end
end

function ClubApplyUI:OnPlayerApplyClubChange(cid)
	if cid == self.cid then
		self.model:ReqGetClubApplyList(self.cid)
	end
end


function ClubApplyUI:OnBtnClose()
	UIManager:CloseUiForms("ClubApplyUI")
end

function ClubApplyUI:UpdateView(checkClose)
	self.noApplyTip.gameObject:SetActive(false)

	self.memberList = self.model:GetMemberListByType(self.type)
	local count = 0
	if self.memberList ~= nil then
		count = #self.memberList 
	end

	local clubInfo = self.model.clubMap[self.cid] or self.model.currentClubInfo
	if clubInfo.applyNum == nil or clubInfo.applyNum == 0 then
		self.noApplyTip.gameObject:SetActive(true)
		self.wrap:InitWrap(0)
		self.top_Bg.gameObject:SetActive(false)
		return
	end
	self.top_Bg.gameObject:SetActive(true)
	self.wrap:InitWrap(count)

end


function ClubApplyUI:PlayOpenAnimationFinishCallBack()
	self.model:ReqGetClubApplyList(self.cid)
	self:UpdateView()
end

function ClubApplyUI:OnApplyMemberUpdate()
	self:UpdateView(true)
end


function ClubApplyUI:InitItem()
		
	for i = 1, 6 do
		local go = self:GetGameObject("panel/container/scrollview/ui_wrapcontent/item" .. i)
		local item = ClubMemberItem:create(go)
		item:SetCallback(self.OnItemClick, self)
		item:SetActive(false)
		table.insert(self.itemList, item)
	end
end



function ClubApplyUI:OnRefreshDepth()
	local uiEffect = child(self.gameObject.transform, "panel/Panel_Top/Title/Effect_youxifenxiang")
	if uiEffect and self.sortingOrder then
		local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
		Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
	end
end


function ClubApplyUI:OnItemUpdate(go, index, rindex)	
	if self.itemList[index] ~= nil then
		self.itemList[index]:SetActive(true)
		self.itemList[index]:SetInfo(self.memberList[rindex])
		self.itemList[index]:SetTipBtnCallback(self.memberList[rindex]["is_misdeed"],function()
			self:ShowMisDeedHis(self.memberList[rindex]["uid"])
		end)
	end
end

function ClubApplyUI:ShowMisDeedHis(uid)
	UIManager:ShowUiForms("ClubMisdeedUI",nil,nil,self.cid,uid)
end

return ClubApplyUI
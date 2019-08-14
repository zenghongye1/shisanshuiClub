local base = require "logic/framework/ui/uibase/ui_view_base"
local ClubMembersView = class("ClubMembersView", base)
local ui_wrap = require "logic/framework/ui/uibase/ui_wrap"
local ButtonInfo = require("logic/club_sys/Data/ButtonInfo")
local ClubMemberItem = require("logic/club_sys/View/ClubMemberItem")
local UIManager = UI_Manager:Instance() 

function ClubMembersView:InitView()
	self.type = ClubMemberEnum.member
	self.model = model_manager:GetModel("ClubModel")
	self.itemList = {}

	self:InitItem()

	self.btnsView = require ("logic/club_sys/View/ClubBtnsView"):create(self:GetGameObject("btnsPanel"))
	self.btnsView:SetLimit(-208, 600, 330, -330)
	self.btnsView:SetActive(false)


	self.wrap = ui_wrap:create(self:GetGameObject(""))
	self.wrap:InitUI(106)
	self.wrap.OnUpdateItemInfo = function(go, rindex, index)  self:OnItemUpdate(go, index, rindex)  end
	self.wrap:InitWrap(0)
end

function ClubMembersView:InitItem()
	for i = 1, 6 do
		local go = self:GetGameObject("scrollview/ui_wrapcontent/item" .. i)
		local item = ClubMemberItem:create(go)
		item:SetCallback(self.OnItemClick, self)
		item:SetActive(false)
		table.insert(self.itemList, item)
	end
end

function ClubMembersView:SetInfo(cid)
	self.cid = cid
	self:UpdateView()
end

function ClubMembersView:UpdateView()
	self.memberList = self.model:GetMemberListByType(self.type)
	local count = 0
	if self.memberList ~= nil then
		count = #self.memberList 
	end
	self.wrap:InitWrap(count)
end


function ClubMembersView:OnItemUpdate(go, index, rindex)
	if self.itemList[index] ~= nil then
		self.itemList[index]:SetInfo(self.type, self.memberList[rindex])
	end
end


function ClubMembersView:OnItemClick(item)
	local info = item.info
	-- 非管理员
	if not self.model:CheckCanSeeApplyList(self.cid) then
		self:PlayerInfoAction(info)
		return
	end
	local buttonInfoTab = {}

	if self.model:IsClubCreater(self.cid) then
		buttonInfoTab = self:GetCreaterBtnInfos(info)
	else
		buttonInfoTab = self:GetManagerBtnInfo(info)
	end
	self.btnsView:Show(buttonInfoTab)
end


-- 代理商按钮列表
function ClubMembersView:GetCreaterBtnInfos(info)
	local tab = {}
	tab[1] = self:GetPlayerBtnInfo(info)
	if info.uid == self.model.selfPlayerId then
		return tab
	end
	local btnInfo = nil
	if self.model:IsClubManager(self.cid, info.uid) then
		btnInfo = self:GetRemoveManagerBtnInfo(info)
	else
		btnInfo = self:GetSetManagerBtnInfo(info)
	end
	table.insert(tab, 1, btnInfo)
	btnInfo = self:GetQuitClubBtnInfo(info)
	table.insert(tab, 1, btnInfo)
	return tab
end

function ClubMembersView:GetManagerBtnInfo(info)
	local tab = {}
	tab[1] = self:GetPlayerBtnInfo(info)
	if not self.model:CheckCanSeeApplyList(self.cid, info.uid) then
		table.insert(tab, 1,self:GetQuitClubBtnInfo(info))
	end
	return tab
end

function ClubMembersView:GetPlayerBtnInfo(info)
	if self.playerBtnInfo == nil then
		self.playerBtnInfo = ButtonInfo:create()
		self.playerBtnInfo.text = "查看"
		self.playerBtnInfo.bgSp = "button_03"
		self.playerBtnInfo.callback = self.PlayerInfoAction
		self.playerBtnInfo.target = self
	end
	self.playerBtnInfo.data = info
	return self.playerBtnInfo
end

function ClubMembersView:GetSetManagerBtnInfo(info)
	if self.setManagerBtnInfo == nil then
		self.setManagerBtnInfo = ButtonInfo:create()
		self.setManagerBtnInfo.text = "设为管理员"
		self.setManagerBtnInfo.bgSp = "button_03"
		self.setManagerBtnInfo.callback = self.SetManagerAction
		self.setManagerBtnInfo.target = self
	end
	self.setManagerBtnInfo.data = info
	return self.setManagerBtnInfo
end

function ClubMembersView:GetRemoveManagerBtnInfo(info)
	if self.removeManagerBtnInfo == nil then
		self.removeManagerBtnInfo = ButtonInfo:create()
		self.removeManagerBtnInfo.text = "取消管理员"
		self.removeManagerBtnInfo.bgSp = "button_05"
		self.removeManagerBtnInfo.callback = self.RemoveManagerAction
		self.removeManagerBtnInfo.target = self
	end
	self.removeManagerBtnInfo.data = info
	return self.removeManagerBtnInfo
end

function ClubMembersView:GetQuitClubBtnInfo(info)
	if self.quitClubBtnInfo == nil then
		self.quitClubBtnInfo = ButtonInfo:create()
		self.quitClubBtnInfo.text = "踢出俱乐部"
		self.quitClubBtnInfo.bgSp = "button_05"
		self.quitClubBtnInfo.callback = self.QuitClubAction
		self.quitClubBtnInfo.target = self
	end
	self.quitClubBtnInfo.data = info
	return self.quitClubBtnInfo
end


function ClubMembersView:PlayerInfoAction(info)
	ui_sound_mgr.PlayButtonClick()
	UIManager:ShowUiForms("personInfo_ui", nil, nil, info.uid)
end

function ClubMembersView:SetManagerAction(info)
	ui_sound_mgr.PlayButtonClick()
	MessageBox.ShowYesNoBox(LanguageMgr.GetWord(10046, info.nickname),
	function()
		self.model:ReqSetManager(self.cid, info.uid, 0)
	end)
end

function ClubMembersView:RemoveManagerAction(info)
	ui_sound_mgr.PlayButtonClick()
	MessageBox.ShowYesNoBox(LanguageMgr.GetWord(10047, info.nickname),
	function()
		self.model:ReqSetManager(self.cid, info.uid, 1)
	end)
end

function ClubMembersView:QuitClubAction(info)
	ui_sound_mgr.PlayButtonClick()
	if info == nil then
		return
	end
	UIManager:ShowUiForms("ClubKickUI",nil,nil,self.cid,info)
	--[[MessageBox.ShowYesNoBox(LanguageMgr.GetWord(10048, info.nickname),
	function()
		self.model:ReqKickClubUser(self.cid, info.uid)
	end)--]]
end


return ClubMembersView
local base = require "logic/framework/ui/uibase/ui_view_base"
local ClubApplyView = class("ClubApplyView", base)
local ui_wrap = require "logic/framework/ui/uibase/ui_wrap"
local ButtonInfo = require("logic/club_sys/Data/ButtonInfo")
local ClubApplyItem = require("logic/club_sys/View/new/ClubApplyItem")
local UIManager = UI_Manager:Instance() 

function ClubApplyView:InitView()
	self.model = model_manager:GetModel("ClubModel")
	self.itemList = {}

	self:InitItem()

	-- self.btnsView = require ("logic/club_sys/View/ClubBtnsView"):create(self:GetGameObject("container/btnsPanel"))
	-- self.btnsView:SetLimit(-208, 600, 330, -330)
	-- self.btnsView:SetActive(false)

	self.wrap = ui_wrap:create(self:GetGameObject("container"))
	self.wrap:InitUI(106)
	self.wrap.OnUpdateItemInfo = function(go, rindex, index)  self:OnItemUpdate(go, index, rindex)  end
	self.wrap:InitWrap(0)
end

function ClubApplyView:RegistEvent()
	Notifier.regist(GameEvent.OnClubApplyMemberUpdate, self.OnApplyMemberUpdate, self)
	Notifier.regist(GameEvent.OnPlayerApplyClubChange, self.OnPlayerApplyClubChange, self)
end

function ClubApplyView:RemoveEvent()
	Notifier.remove(GameEvent.OnClubApplyMemberUpdate, self.OnApplyMemberUpdate, self)
	Notifier.remove(GameEvent.OnPlayerApplyClubChange, self.OnPlayerApplyClubChange, self)
end

function ClubApplyView:OnClose()
end


function ClubApplyView:OnOpen()
	if self.isManager then
		self.model:ReqGetClubApplyList(self.cid)
	end
end

function ClubApplyView:InitItem()
	local go_pre = self:GetGameObject("container/scrollview/ui_wrapcontent/item")
	local parent = self:GetGameObject("container/scrollview/ui_wrapcontent")
	if go_pre == nil or parent == nil then
		return
	end
	for i = 1, 5 do
		local go
		if i == 1 then
			go = go_pre
		else
			go = newobject(go_pre)
			go.transform:SetParent(parent.transform,false)
		end
		local item = ClubApplyItem:create(go)
		-- item:SetCallback(self.OnItemClick, self)
		item:SetActive(false)
		table.insert(self.itemList, item)
	end
end

function ClubApplyView:SetInfo(clubInfo)
	self.isNeedReq = true

	self.clubInfo = clubInfo
	self.cid = clubInfo.cid

	self.isManager = self.model:CheckCanSeeApplyList(self.cid)

end

function ClubApplyView:CallUpdateView()
	local time = FrameTimer.New(
		function() 
			self:UpdateView()
		end,1,1)
	time:Start()
end

function ClubApplyView:OnApplyMemberUpdate()
	if not self.isManager then
		return
	end
	self:CallUpdateView()
end

function ClubApplyView:OnPlayerApplyClubChange(cid)
	if cid == self.cid and self.model:CheckCanSeeApplyList(self.cid) and self.isActive == true then
		self.model:ReqGetClubApplyList(self.cid)
	end
end

function ClubApplyView:UpdateView()
	self.memberList = self.model:GetMemberListByType(ClubMemberEnum.apply)
	local count = 0
	if self.memberList ~= nil then
		count = #self.memberList 
	end
	self.wrap:InitWrap(count)
end


function ClubApplyView:OnItemUpdate(go, index, rindex)
	if self.itemList[index] ~= nil then
		self.itemList[index]:SetInfo(self.memberList[rindex])
		self.itemList[index]:SetTipBtnCallback(self.memberList[rindex]["is_misdeed"],function()
			self:ShowMisDeedHis(self.memberList[rindex]["uid"])
		end)
	end
end

function ClubApplyView:ShowMisDeedHis(uid)
	UIManager:ShowUiForms("ClubMisdeedUI",nil,nil,self.cid,uid)
end


-- function ClubApplyView:OnItemClick(item)
-- 	local info = item.info
-- 	-- 非管理员
-- 	if not self.model:CheckCanSeeApplyList(self.cid) then
-- 		self:PlayerInfoAction(info)
-- 		return
-- 	end
-- 	local buttonInfoTab = {}

-- 	if self.model:IsClubCreater(self.cid) then
-- 		buttonInfoTab = self:GetCreaterBtnInfos(info)
-- 	else
-- 		buttonInfoTab = self:GetManagerBtnInfo(info)
-- 	end
-- 	self.btnsView:Show(buttonInfoTab)
-- end


-- -- 代理商按钮列表
-- function ClubApplyView:GetCreaterBtnInfos(info)
-- 	local tab = {}
-- 	tab[1] = self:GetPlayerBtnInfo(info)
-- 	if info.uid == self.model.selfPlayerId then
-- 		return tab
-- 	end
-- 	local btnInfo = nil
-- 	if self.model:IsClubManager(self.cid, info.uid) then
-- 		btnInfo = self:GetRemoveManagerBtnInfo(info)
-- 	else
-- 		btnInfo = self:GetSetManagerBtnInfo(info)
-- 	end
-- 	table.insert(tab, 1, btnInfo)
-- 	btnInfo = self:GetQuitClubBtnInfo(info)
-- 	table.insert(tab, 1, btnInfo)
-- 	return tab
-- end

-- function ClubApplyView:GetManagerBtnInfo(info)
-- 	local tab = {}
-- 	tab[1] = self:GetPlayerBtnInfo(info)
-- 	if not self.model:CheckCanSeeApplyList(self.cid, info.uid) then
-- 		table.insert(tab, 1,self:GetQuitClubBtnInfo(info))
-- 	end
-- 	return tab
-- end

-- function ClubApplyView:GetPlayerBtnInfo(info)
-- 	if self.playerBtnInfo == nil then
-- 		self.playerBtnInfo = ButtonInfo:create()
-- 		self.playerBtnInfo.text = "查看"
-- 		self.playerBtnInfo.bgSp = "button_03"
-- 		self.playerBtnInfo.callback = self.PlayerInfoAction
-- 		self.playerBtnInfo.target = self
-- 	end
-- 	self.playerBtnInfo.data = info
-- 	return self.playerBtnInfo
-- end

-- function ClubApplyView:GetSetManagerBtnInfo(info)
-- 	if self.setManagerBtnInfo == nil then
-- 		self.setManagerBtnInfo = ButtonInfo:create()
-- 		self.setManagerBtnInfo.text = "设为管理员"
-- 		self.setManagerBtnInfo.bgSp = "button_03"
-- 		self.setManagerBtnInfo.callback = self.SetManagerAction
-- 		self.setManagerBtnInfo.target = self
-- 	end
-- 	self.setManagerBtnInfo.data = info
-- 	return self.setManagerBtnInfo
-- end

-- function ClubApplyView:GetRemoveManagerBtnInfo(info)
-- 	if self.removeManagerBtnInfo == nil then
-- 		self.removeManagerBtnInfo = ButtonInfo:create()
-- 		self.removeManagerBtnInfo.text = "取消管理员"
-- 		self.removeManagerBtnInfo.bgSp = "button_05"
-- 		self.removeManagerBtnInfo.callback = self.RemoveManagerAction
-- 		self.removeManagerBtnInfo.target = self
-- 	end
-- 	self.removeManagerBtnInfo.data = info
-- 	return self.removeManagerBtnInfo
-- end

-- function ClubApplyView:GetQuitClubBtnInfo(info)
-- 	if self.quitClubBtnInfo == nil then
-- 		self.quitClubBtnInfo = ButtonInfo:create()
-- 		self.quitClubBtnInfo.text = "踢出俱乐部"
-- 		self.quitClubBtnInfo.bgSp = "button_05"
-- 		self.quitClubBtnInfo.callback = self.QuitClubAction
-- 		self.quitClubBtnInfo.target = self
-- 	end
-- 	self.quitClubBtnInfo.data = info
-- 	return self.quitClubBtnInfo
-- end


-- function ClubApplyView:PlayerInfoAction(info)
-- 	ui_sound_mgr.PlayButtonClick()
-- 	UIManager:ShowUiForms("personInfo_ui", nil, nil, info.uid)
-- end

-- function ClubApplyView:SetManagerAction(info)
-- 	ui_sound_mgr.PlayButtonClick()
-- 	MessageBox.ShowYesNoBox(LanguageMgr.GetWord(10046, info.nickname),
-- 	function()
-- 		self.model:ReqSetManager(self.cid, info.uid, 0)
-- 	end)
-- end

-- function ClubApplyView:RemoveManagerAction(info)
-- 	ui_sound_mgr.PlayButtonClick()
-- 	MessageBox.ShowYesNoBox(LanguageMgr.GetWord(10047, info.nickname),
-- 	function()
-- 		self.model:ReqSetManager(self.cid, info.uid, 1)
-- 	end)
-- end

-- function ClubApplyView:QuitClubAction(info)
-- 	ui_sound_mgr.PlayButtonClick()
-- 	if info == nil then
-- 		return
-- 	end
-- 	UIManager:ShowUiForms("ClubKickUI",nil,nil,self.cid,info)
-- end


return ClubApplyView
local base = require "logic/framework/ui/uibase/ui_view_base"
local HallClubRoomsView = class("HallClubRoomsView", base)
local ui_wrap = require "logic/framework/ui/uibase/ui_wrap"
local ClubEnterRoomItem = require "logic/club_sys/View/ClubEnterRoomItem"
local UIManager = UI_Manager:Instance() 

function HallClubRoomsView:InitView()
	self.infoClickCount = 0
	self.model = model_manager:GetModel("ClubModel")
	self.itemList = {}
	self.clubName = self:GetComponent("topPanel/clubName", typeof(UILabel))
	addClickCallbackSelf(self.clubName.gameObject, self.OnClubNameClick, self)
	self.btnGo = self:GetGameObject("button")
	addClickCallbackSelf(self.btnGo, self.OnBtnClick, self)

	self.hintGo = self:GetGameObject("topPanel/Sprite_hintInfo")
	addClickCallbackSelf(self.hintGo, self.OnHintClick, self)

	self.tipsGo = self:GetGameObject("tips")
	self.tipsLabel = self:GetComponent("tips", typeof(UILabel))
	self.tipsLabel.text = LanguageMgr.GetWord(10083)

	self:InitItems()

	self.wrap = ui_wrap:create(self:GetGameObject("container"))
	self.wrap:InitUI(96)
	self.wrap.OnUpdateItemInfo = function(go, rindex, index)self:OnItemUpdate(go, index, rindex) end
	self.wrap:InitWrap(0)

	self.hintGo = self:GetGameObject("topPanel/Sprite_hintInfo")
	self.hintLabel = self:GetComponent("topPanel/Sprite_hintInfo/Label", typeof(UILabel))
end

function HallClubRoomsView:InitItems()
	for i = 1, 5 do
		local go = self:GetGameObject("container/scrollview/ui_wrapcontent/item" .. i)
		local item = ClubEnterRoomItem:create(go)
		item:SetCallback(self.OnItemClick, self)
		item:SetActive(false)
		self.itemList[i] = item
	end
end

function HallClubRoomsView:UpdateDatas()
	logError(1)
	if not self.model:HasClub() then
		self.tipsGo:SetActive(true)
		return
	end
	if self.model.currentClubInfo == nil then
		return
	end
	self:UpdateHintInfo()
	self.dataList = self.model.currentClubRoomInfos
	self.tipsGo:SetActive(self.dataList == nil or #self.dataList == 0 )
	self.clubName.text = self.model.currentClubInfo.cname
	if self.dataList == nil then
		self.wrap:InitWrap(0)
	else
		self.wrap:InitWrap(#self.dataList)
	end
end

function HallClubRoomsView:OnHintClick()
	 if self.model:CheckShowApplyHint() then
	 	UIManager:ShowUiForms("ClubApplyUI", nil, nil, self.model.currentClubInfo.cid)
	 end
end

function HallClubRoomsView:OnShow()
	self.model:ReqGetRoomList()
	self:UpdateDatas()
end


function HallClubRoomsView:OnClubNameClick()
	ui_sound_mgr.PlayButtonClick()
	if not self.model:HasClub() then
		return
	end
	UIManager:ShowUiForms("ClubInfoUI", nil, nil, self.model.currentClubInfo)
	self.infoClickCount = self.infoClickCount + 1
	self:UpdateHintInfo()
end


function HallClubRoomsView:OnBtnClick()
	ui_sound_mgr.PlayButtonClick()
	UIManager:ShowUiForms("openroom_ui", nil, nil, self.model.currentClubInfo.cid, self.model.currentClubInfo.gids, self.model.currentClubInfo.ctype)
end

function HallClubRoomsView:OnItemClick(item)
	ui_sound_mgr.PlayButtonClick()
	-- local content = LanguageMgr.GetWord(10049, GameUtil.GetGameName(item.info.gid))
	-- content = content.."\n"..ShareStrUtil.GetRoomShareStr(item.info.gid, item.info, true)
	-- MessageBox.ShowYesNoBox(content,
	-- function()
	-- 	join_room_ctrl.JoinRoomByRno(item.info.rno)
	-- end)
	local title = LanguageMgr.GetWord(10049, GameUtil.GetGameName(item.info.gid))
	local content, contentTbl = ShareStrUtil.GetRoomShareStr(item.info.gid, item.info, true)
	if contentTbl then
		local subTitle = string.format("付费方式: %s   ", string.gsub(contentTbl[1], "、", ""))
		contentTbl[1] = ""
		local contentStr = table.concat(contentTbl)
		contentTbl = {title,subTitle,contentStr}
	end
	MessageBox.ShowYesNoBox(contentTbl,
	function()
		join_room_ctrl.JoinRoomByRno(item.info.rno)
	end)
end

function HallClubRoomsView:OnItemUpdate(go, index, rindex)
	if self.itemList[index] ~= nil then
		self.itemList[index]:SetInfo(self.dataList[rindex])
	end
end

function HallClubRoomsView:UpdateHintInfo()
	if self.model:CheckShowApplyHint() then
		self.hintGo:SetActive(true)
		if self.model.currentClubInfo.applyNum ~= nil then
			self.hintLabel.text = self.model.currentClubInfo.applyNum .. "个新的申请"
		end
	elseif self.infoClickCount <= 3 then
		self.hintGo:SetActive(true)
		self.hintLabel.text = "点击查看俱乐部信息哦~"
	else
		self.hintGo:SetActive(false)
	end

end

return HallClubRoomsView

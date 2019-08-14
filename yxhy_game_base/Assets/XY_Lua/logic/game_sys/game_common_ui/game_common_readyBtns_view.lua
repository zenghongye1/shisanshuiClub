--[[--
 * @Description: 游戏通用准备按钮
 * @Author:      ShushingWong
 * @FileName:    game_common_readyBtns_view.lua
 * @DateTime:    2018-04-10 11:07:05
 ]]
local base = require "logic/framework/ui/uibase/ui_load_view_base"
local baseClass = class("game_common_readyBtns_view", base)

function baseClass:InitPrefabPath()
	self.prefabPath = data_center.GetAppPath().."/ui/game_common_ui/gameCommonBtns"
end

function baseClass:Init(parentTr,isMahjong,localPos)
	self.parentTr = parentTr
	self.isMahjong = isMahjong
	self.localPos = localPos
	if not self.isMahjong then
		if IsNil(self.gameObject) then
			self:Load()
		end
		self:SetActive(true)
	end
end

function baseClass:OnLoaded()
	self:SetParent(self.parentTr)
	self.transform.localPosition = self.localPos or Vector3.zero
end

function baseClass:InitView()
	self.gridComp = self:GetComponent("Grid", "UIGrid")

	self.readyBtnGo = self:GetGameObject("ready")
	addClickCallbackSelf(self.readyBtnGo, self.Onbtn_readyClick, self)

	self.applyPlayBtnGo = self:GetGameObject("applyPlay")
	addClickCallbackSelf(self.applyPlayBtnGo, self.Onbtn_applyPlayClick, self)

	self.inviteBtnGo = self:GetGameObject("Grid/invideFriend")
	addClickCallbackSelf(self.inviteBtnGo, self.Onbtn_inviteClick, self)

	self.closeRoomBtnGo = self:GetGameObject("Grid/closeRoom")
	addClickCallbackSelf(self.closeRoomBtnGo, self.Onbtn_closeRoomClick, self)

	self.copyBtnGo = self:GetGameObject("Grid/copyNumber")
	addClickCallbackSelf(self.copyBtnGo, self.Onbtn_CopyRoomNum, self)
	
	self.cutCardBtnGo = self:GetGameObject("cutCardBtn")
	addClickCallbackSelf(self.cutCardBtnGo, self.Onbtn_CutCard, self)

	self.readyBtnGo:SetActive(false)
	self.applyPlayBtnGo:SetActive(false)
	self.inviteBtnGo:SetActive(false)
	self.copyBtnGo:SetActive(false)
	self.closeRoomBtnGo:SetActive(false)
	self.cutCardBtnGo:SetActive(false)

	if G_isAppleVerifyInvite then
		self.inviteBtnGo = nil
	end
end

function baseClass:Refresh(isReady,isRoomOwner,isFirstJu,canApplyPlay)
	self.isReady = isReady
	self.isRoomOwner = isRoomOwner or false
	self.isFirstJu = isFirstJu or false
	self.canApplyPlay = canApplyPlay or false

	self.readyBtnGo:SetActive(self.isReady)
	self.applyPlayBtnGo:SetActive(not self.isReady and self.isFirstJu and self.canApplyPlay)
	if self.inviteBtnGo then
		self.inviteBtnGo:SetActive(self.isFirstJu)
	end
	self.copyBtnGo:SetActive(self.isFirstJu)
	self.closeRoomBtnGo:SetActive(self.isRoomOwner and self.isFirstJu)

	self.gridComp:Reposition()
end

-- 打开准备相关按钮
function baseClass:ShowReadyBtns()
	self:SetReadyBtnVisible(true)
	self:SetApplyPlayBtnVisible(false)
	self:SetInviteBtnVisible(self.isFirstJu)
	--self:SetCopyRnoVisible(self.isFirstJu)
	self:SetCloseBtnVisible(self.isRoomOwner and self.isFirstJu)

	-- if self.isRoomOwner then
	-- 	if self.inviteBtnGo then
	-- 		LuaHelper.SetTransformLocalX(self.inviteBtnGo.transform, 193)
	-- 		if self.isFirstJu then
	-- 			LuaHelper.SetTransformLocalX(self.copyBtnGo.transform, 0)
	-- 			LuaHelper.SetTransformLocalX(self.closeRoomBtnGo.transform, -193)
	-- 		else
	-- 			LuaHelper.SetTransformLocalX(self.closeRoomBtnGo.transform, 0)
	-- 		end
	-- 	else
	-- 		if self.isFirstJu then
	-- 			LuaHelper.SetTransformLocalX(self.copyBtnGo.transform, 133)
	-- 			LuaHelper.SetTransformLocalX(self.closeRoomBtnGo.transform, -133)
	-- 		else
	-- 			LuaHelper.SetTransformLocalX(self.closeRoomBtnGo.transform, 0)
	-- 		end
	-- 	end
	-- else
	-- 	if self.inviteBtnGo then
	-- 		LuaHelper.SetTransformLocalX(self.copyBtnGo.transform, -133)
	-- 		LuaHelper.SetTransformLocalX(self.inviteBtnGo.transform, 133)
	-- 	else
	-- 		LuaHelper.SetTransformLocalX(self.copyBtnGo.transform, 0)
	-- 	end
	-- end
	self.gridComp:Reposition()
end

--显示准备按钮
function baseClass:SetReadyBtnVisible(value)
	if self.readyBtnGo then
		self.readyBtnGo:SetActive(value)
		if value then
			self:SetApplyPlayBtnVisible(false)
		end
	else
		self:Show(value)
	end
end

--显示请求开始按钮
function baseClass:SetApplyPlayBtnVisible(value)
	self.applyPlayBtnGo:SetActive(value)
	if value then
		self:SetReadyBtnVisible(false)
	end
end

--邀请好友
function baseClass:SetInviteBtnVisible(value)
	if self.inviteBtnGo then
		self.inviteBtnGo:SetActive(value)
	end
	self.copyBtnGo:SetActive(value)
	self.gridComp:Reposition()
end

--复制房号按钮
-- function baseClass:SetCopyRnoVisible(value)
-- 	self.copyBtnGo:SetActive(value)
-- 	self.gridComp:Reposition()
-- end

function baseClass:SetCloseBtnVisible(value)
	self.closeRoomBtnGo:SetActive(value)
	self.gridComp:Reposition()
end

-- 准备按钮
function baseClass:Onbtn_readyClick()	
	ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_ready")
	if self.isMahjong then
		mahjong_play_sys.ReadyGameReq()
	else
		pokerPlaySysHelper.GetCurPlaySys().ReadyGameReq()
	end
end

-- 请求开始按钮
function baseClass:Onbtn_applyPlayClick()	
	ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_ready")
	local curNum = room_usersdata_center.GetRoomPlayerCount()
	local maxNum = roomdata_center.MaxPlayer()
  	MessageBox.ShowYesNoBox("当前房间未达到预定人数[a06e0e]("..curNum.."/"..maxNum..")[-]\n确定现在就要开始游戏吗？", 
  		function()
			if self.isMahjong then
				mahjong_play_sys.ApplyForReq(1)
			else
				pokerPlaySysHelper.GetCurPlaySys().ApplyForReq(1)
			end
  		end)
end

function baseClass:Onbtn_inviteClick()
	local name, des = ShareStrUtil.GetShareStr()
	invite_sys.inviteToRoom(roomdata_center.roomnumber,name,des,roomdata_center.roomCid)
	report_sys.EventUpload(29,player_data.GetGameId())
end

-- 解散房间
function baseClass:Onbtn_closeRoomClick()
	report_sys.EventUpload(30,player_data.GetGameId())
  	MessageBox.ShowYesNoBox(LanguageMgr.GetWord(6031),function()
		if self.isMahjong then
			mahjong_play_sys.DissolutionRoom()
		else
			pokerPlaySysHelper.GetCurPlaySys().DissolutionRoom()
		end
	end)
end

--复制房号点击事件
function baseClass:Onbtn_CopyRoomNum()
	ui_sound_mgr.PlayButtonClick()
	local name, des = ShareStrUtil.GetShareStr(nil, true, true)
	local title =  string.format(global_define.gameShareTitle, name,roomdata_center.roomnumber)
	local content = table.concat({title, des, "（复制此消息打开游戏可直接进入该房间）"}, "\n")
	YX_APIManage.Instance:onCopy(content,function()UI_Manager:Instance():FastTip(LanguageMgr.GetWord(6043))end)
end

function baseClass:Onbtn_CutCard()
	require("logic.poker_sys.other.CutCardSys"):create():CutCardAction()
end

return baseClass
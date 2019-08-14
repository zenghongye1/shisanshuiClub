require "logic/mahjong_sys/_model/room_usersdata_center"
require "logic/mahjong_sys/_model/room_usersdata"
require "logic/mahjong_sys/_model/operatorcachedata"
require "logic/mahjong_sys/_model/operatordata"
require "logic/mahjong_sys/ui_mahjong/mahjong_ui_sys"
require "logic/animations_sys/animations_sys"
require "logic/invite_sys/invite_sys"
require "logic/gvoice_sys/gvoice_sys"

local interactView = require("logic/interaction/InteractView")
local MahjongFlowersView = require ("logic/mahjong_sys/ui_mahjong/views/MahjongFlowersView")

local player_view =require "logic/mahjong_sys/ui_mahjong/views/mahjong_player_view"

local addClickCallbackSelf = addClickCallbackSelf
local addPressedCallbackSelf = addPressedCallbackSelf

local base = require("logic.framework.ui.uibase.ui_window")
local mahjong_ui = class("mahjong_ui", base)

local instance = nil

function mahjong_ui:ctor()
	base.ctor(self)
	self.zhuangTimer = nil
	self.getDateTimer = nil
	self.specialCardList = {}
	self.gvoice_engin = nil
	instance = self
	self.destroyType = UIDestroyType.Immediately
end

function mahjong_ui:OnInit()

	self:InitView()
	self.chatTextTab = {"赶紧出，你在孵蛋啊！","快点吧，我等的花都谢了","催催催~急着送钱啊？","还让不让我摸牌了！",
	"这什么牌呐，摸什么打什么","辛辛苦苦很多年，一把回到解放前","你家里是开银行的吧","来呀~互相伤害呀",
	"你这样以后没朋友的","你能胡个大点的牌不？","我有大把银子，有本事来就来拿"}
	-- self.chatImgTab = {"1","2","3","4","5","6","7","8","9","10","11","12"}
	self.chatImgTab = {
	"1","2","3","4","5",
	"6","7","8","9","10",
	"11","12","13","14","15",
	"16","17","18","19","20",
	"21","22","23","24","25",
	"26",
	}
end

function mahjong_ui:OnOpen()
	UpdateBeat:Add(slot(self.Update, self))
	self:InitLogic()
	self:InitPlayers()
	self:StartGetDataTimer()
	self:InitFlowersView()
	self:InitInteractView()
	self:SetGameInfoVisible(false)
    self:SetAllHuaPointVisible(false)
    self.cardShowView:Hide()
    for i=1, 4 do
      self:ShowTing(i,false)
      self:ShowYingKou(i,false)
    end
--	chat_ui:InitUI(chatTextTab,chatImgTab)

	self.gvoice_engin = gvoice_sys.GetEngine()
	ui_sound_mgr.PlayBgSound("mahjong_bgm")	
end

function mahjong_ui:ShowGangLock()
    local bganglock=self:GetGameObject("Panel/Anchor_Center/ganglock")
    logError(bganglock.name)
    local c=coroutine.start(function ()
        bganglock.gameObject:SetActive(true)
        coroutine.wait(2)
        bganglock.gameObject:SetActive(false)
    end) 
end
function mahjong_ui:InitFlowersView()
	MahjongFlowersView.InitPool(self.flowerItemGo)
end

function mahjong_ui:InitInteractView()
	self.interactView = interactView:create()
	self.interactView:Show()
	self.interactView.transform.localPosition = Vector3(999,999,999)
	self.interactView:SetParent(self.transform)
	self.interactView:SetActive(false)
	self:RefreshDepth()
end


function mahjong_ui:ShowTing(viewSeat,value)  
   if self.playerList[viewSeat]~=nil then
       self.playerList[viewSeat]:ShowTing(value) 
   end
end

function mahjong_ui:ShowYingKou(viewSeat,value) 
    if self.playerList[viewSeat]~=nil then
    	if value then
       		self.playerList[viewSeat]:SetYoustatus(20020)
       	else
       		self.playerList[viewSeat]:ShowYingKou(value) 
       	end
   end
end

function mahjong_ui:OnClose()
	gps_data.ResetGpsData()
	UpdateBeat:Remove(slot(self.Update, self))
	self:UnInit()
	gvoice_sys.Uinit()
	self.gvoice_engin = nil
	if self.applyTimer ~= nil then
		self.applyTimer:Stop()
		self.applyTimer = nil
	end
end

function mahjong_ui:PlayOpenAmination()
end
function mahjong_ui:OnRefreshDepth()
	if self.playerList then
		for k,v in pairs(self.playerList) do
			local playerComponent = v
			--表情层设定
			if playerComponent then
				playerComponent.sortingOrder = self.sortingOrder
				playerComponent.m_subPanelCount = self.m_subPanelCount
			end

		end
	end
	if self.operTipsView then
		self.operTipsView.sortingOrder = self.sortingOrder
		self.operTipsView.m_subPanelCount = self.m_subPanelCount
	end
end

function mahjong_ui:InitView()
	self.panelTr = self:GetTransform("Panel")

	self.exitBtnGo = self:GetGameObject("Panel/Anchor_TopLeft/exit")
	addClickCallbackSelf(self.exitBtnGo, self.Onbtn_exitClick, self)

	self.moreBtnGo = self:GetGameObject("Panel/Anchor_TopRight/morePanel/more")
	self.moreBtnGo:SetActive(true)
	addClickCallbackSelf(self.moreBtnGo, self.Onbtn_moreClick, self)

	self.anchor_center_tr = self:GetTransform("Panel/Anchor_Center")
	self.readyBtnsView = require( "logic/game_sys/game_common_ui/game_common_readyBtns_view"):create()
	self.readyBtnsView:Init(self.anchor_center_tr,true,Vector3(0,-96,0))

	self.voiceBtnGo = self:GetGameObject("Panel/Anchor_Right/voice")
	addClickCallbackSelf(self.voiceBtnGo, self.Onbtn_voiceClick, self)
	addPressedCallbackSelf(self.voiceBtnGo.transform, "", self.Onbtn_voicePressed, self)
	self:AddSoundDragEventListener(self.voiceBtnGo)

	self.chatBtnGo = self:GetGameObject("Panel/Anchor_Right/chat")
	addClickCallbackSelf(self.chatBtnGo, self.Onbtn_chatClick, self)

	self.powerSp = self:GetComponent("Panel/Anchor_TopLeft/phoneInfo/power/slider", typeof(UISprite))
	self.timeLabel = self:GetComponent("Panel/Anchor_TopLeft/phoneInfo/timeLbl", typeof(UILabel))

	self.leftCardLabel = self:GetComponent("Panel/Anchor_TopLeft/leftCardInfo/leftCard", typeof(UILabel))
	self.leftCardGo = self:GetGameObject("Panel/Anchor_TopLeft/leftCardInfo")

	self.roundNumLabel = self:GetComponent("Panel/Anchor_TopRight/roundInfo/round", typeof(UILabel))
	self.roundNumGo = self:GetGameObject("Panel/Anchor_TopRight/roundInfo")

	self.zhuangTipsGo = self:GetGameObject("Panel/Anchor_Center/zhuanTips")
	self.zhuangTipsGo:SetActive(false)

	self.flowerItemGo = self:GetGameObject('Panel/Anchor_Center/Players/item')

	-- self:InitPlayers()

	self.specialCardGo = self:GetGameObject("Panel/Anchor_TopLeft/specialCard/card_bg")
	self.specialCardGo:SetActive(false)
	self.specialCardList = {}
	self.specialCardList[1] = self.specialCardGo

	-- 荒庄
	self.huangGo = self:GetGameObject("Panel/Anchor_Center/huang")
	self.huangGo:SetActive(false)
	self.huangSpTr = self:GetTransform("Panel/Anchor_Center/huang/Sprite")

	    -- 进入包次阶段提示
    self.baociTips = self:GetTransform("Panel/Anchor_Center/baociTips")
    if self.baociTips then
    	self.baociTips.gameObject:SetActive(false)
    end

    -- 定次牌
    self.ci_card = self:GetTransform("Panel/Anchor_Center/ci_card")
    if self.ci_card ~= nil then
    	self.ci_card.gameObject:SetActive(false)
    end

	-- 跟庄
	self.genZhuang = self:GetTransform("Panel/Anchor_Center/gongzhuang")
	if self.genZhuang then
		self.genZhuang.gameObject:SetActive(false)
	end

	self.tingBackGo = self:GetGameObject("Panel/Anchor_Center/tingGuo")
	self.tingBackGo:SetActive(false)
	addClickCallbackSelf(self.tingBackGo, self.Onbtn_TingBack, self)

	self:AdjustPosOnIPhone()

	self:InitCardShowView()
    self:InitVoteView()
    self:InitOperTipsView()
    self:InitMoreBtnsView()
    self:InitSoundView()

    -- this.SetAllScoreVisible(false)
    self:HideAllReadyBtns()
    self:InitXiaPaoView()
    self:InitBuySelfdrawView()
    self.kouView = require( "logic/mahjong_sys/ui_mahjong/game/game_kou_view"):create()
    self.buyCodeView = require( "logic/mahjong_sys/ui_mahjong/game/game_buyCode_view"):create()

end

function mahjong_ui:AdjustPosOnIPhone()
	-- if data_center.GetCurPlatform() ~= "IPhonePlayer" or not YX_APIManage.Instance:isIphoneX() then
	-- 	return
	-- end

	-- --iPhoneX适配
	-- local delayTimer = Timer.New(function()
	-- 	local widgetPanel = child(self.transform, "Panel")
	-- 	if widgetPanel then
	-- 		local Anchor_TopRight = child(widgetPanel, "Anchor_TopRight")
	-- 		if Anchor_TopRight then
	-- 		  local localPos = Anchor_TopRight.gameObject.transform.localPosition
	-- 		  Anchor_TopRight.gameObject.transform.localPosition = Vector3(localPos.x -60, localPos.y, localPos.z)
	-- 		end
	-- 		local Anchor_Right = child(widgetPanel, "Anchor_Right")
	-- 		if Anchor_Right then
	-- 		  local localPos = Anchor_Right.gameObject.transform.localPosition
	-- 		  Anchor_Right.gameObject.transform.localPosition = Vector3(localPos.x -60, localPos.y, localPos.z)
	-- 		end

	-- 		--copyBtn
	-- 		local btn_copy = child(widgetPanel, "Anchor_TopLeft/btn_copy")
	-- 		if btn_copy then
	-- 		  local localPos = btn_copy.gameObject.transform.localPosition
	-- 		  btn_copy.gameObject.transform.localPosition = Vector3(localPos.x +60, localPos.y, localPos.z)
	-- 		end
	-- 	end
	-- end, 0.1, 1)
	-- delayTimer:Start()
end




function mahjong_ui:Onbtn_exitClick()
	report_sys.EventUpload(31,player_data.GetGameId())
	if roomdata_center.isStart or roomdata_center.isRoundStart then
		MessageBox.ShowYesNoBox(LanguageMgr.GetWord(6030), function() mahjong_play_sys.VoteDrawReq(true) end)
		return
	end

	ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_close_dialog")
	MessageBox.ShowYesNoBox(LanguageMgr.GetWord(5001), function() mahjong_play_sys.LeaveReq() end)
end

-- 更多按钮
function mahjong_ui:Onbtn_moreClick()
	ui_sound_mgr.PlayButtonClick()
	self:SetMorePanel()
end

-- 语音按钮
function mahjong_ui:Onbtn_voiceClick()
	report_sys.EventUpload(32,player_data.GetGameId())
end

-- 聊天按钮
function mahjong_ui:Onbtn_chatClick()
	ui_sound_mgr.PlayButtonClick()
	report_sys.EventUpload(33,player_data.GetGameId())
	--chat_ui:SetChatPanle()
	UI_Manager:Instance():ShowUiForms("chat_ui",UiCloseType.UiCloseType_CloseNothing,nil,self.chatTextTab,self.chatImgTab)
end

function mahjong_ui:Onbtn_voicePressed(go, isPress)
	self.recordView:Press(go, isPress)
end

function mahjong_ui:Onbtn_TingBack()
	Notifier.dispatchCmd(cmdName.MAHJONG_TING_CARD)
end

-- todo  整理
function mahjong_ui:AddSoundDragEventListener(obj)
  if not IsNil(obj) then
    addDragCallbackSelf(obj, function (go, delta)
      self.recordView:Drag(go, delta)
    end)
  end
end

function mahjong_ui:InitPlayers()
	self.playerList = {}
    for i=1,4 do
    	local playerTrans = child(self.panelTr, "Anchor_Center/Players/Player"..i)
    	if playerTrans ~= nil then
    		local playerComponent = player_view:create(playerTrans.gameObject)
    		playerComponent:SetCallback(self.OnPlayerItemClick, self)
	        if roomdata_center.MaxPlayer() == 2 and (i ~= 2 and i ~= 4 ) then
	    		  table.insert(self.playerList, playerComponent)
	    		  gps_data.SetTotalPlayer({1,3})
	        elseif roomdata_center.MaxPlayer() == 3 then
	          local myLogicSeat = player_seat_mgr.GetMyLogicSeat()
	          if myLogicSeat == 1 then
	            if i ~= 4 then
	              table.insert(self.playerList, playerComponent)
	              gps_data.SetTotalPlayer({1,2,3})
	            end
	          elseif myLogicSeat == 2 then
	            if i ~= 3 then
	              table.insert(self.playerList, playerComponent)
	              gps_data.SetTotalPlayer({1,2,4})
	            end
	          elseif myLogicSeat == 3 then
	            if i ~= 2 then
	              table.insert(self.playerList, playerComponent)
	              gps_data.SetTotalPlayer({1,3,4})
	            end
	          end
	        elseif roomdata_center.MaxPlayer() == 4 then
	          table.insert(self.playerList, playerComponent)
	          gps_data.SetTotalPlayer({1,2,3,4})
	        end
    		playerTrans.gameObject:SetActive(false)
    	end
    end
end

function mahjong_ui:OnPlayerItemClick(item)
	if item.viewSeat == 1 then
		return
	end
	self.interactView:Show(item.logicSeat)
	self.interactView:SetParent(item.headTr)
	self.interactView.transform.localPosition = config_mgr.getConfig("cfg_interactpos", 1).pos[item.index]
end



-- 吃杠选择界面
function mahjong_ui:InitCardShowView()
	self.cardShowView = require "logic/mahjong_sys/ui_mahjong/mahjong_show_card_ui"
	self.cardShowView:SetTransform(child(self.panelTr, "Anchor_Center/cardShowView"))
end

function mahjong_ui:InitVoteView()
	local go = newNormalObjSync(data_center.GetAppPath().."/ui/common/voteView", typeof(GameObject))
    go = newobject(go)
    go.transform:SetParent(child(self.panelTr, "Anchor_TopRight/votePanel"), false)
	self.voteView = require("logic/voteQuit/vote_view"):create(go.gameObject)
	self.voteView:Hide()
end

function mahjong_ui:InitOperTipsView()
  local class = require "logic/mahjong_sys/ui_mahjong/views/OperTipsView"
  self.operTipsView = class:create(child(self.panelTr, "Anchor_Center/opertips").gameObject)
  self.operTipsView:Hide()
end

-- 更多面板
function mahjong_ui:InitMoreBtnsView()
  self.moreBtnsView = require "logic/mahjong_sys/ui_mahjong/views/MoreBtnsView":
  create(nil, self.moreContainerClickAnimation, subComponentGet(self.panelTr, "Anchor_TopRight/morePanel/more/Sprite", typeof(UIRect)))
  local go = newNormalObjSync(data_center.GetAppPath().."/ui/common/gameBtnsView", typeof(GameObject))
  go = newobject(go)
  go.transform:SetParent(child(self.panelTr, "Anchor_TopRight/morePanel"), false)
  self.moreBtnsView:SetGo(go)
  self.moreBtnsView:SetActive(false)

  self.newApplyGo = self:GetGameObject("Panel/Anchor_TopRight/morePanel/newApply")
  addClickCallbackSelf(self.newApplyGo, self.OnNewApplyClick, self)
  self.newApplyGo:SetActive(false)
  self.applyTimer = nil
end
-- 录音界面
function mahjong_ui:InitSoundView()
  local class = require "logic/mahjong_sys/ui_mahjong/views/RecordSoundView"
  self.recordView = class:create(child(self.panelTr, "Anchor_Center/sound").gameObject)
  self.recordView:SetActive(false)
end
-- 下注界面
function mahjong_ui:InitXiaPaoView()
  self.xiaPaoView = require( "logic/mahjong_sys/ui_mahjong/game/game_buyHourse_view"):create()
end
-- 买自摸界面
function mahjong_ui:InitBuySelfdrawView()
  self.buySelfdrawView = require( "logic/mahjong_sys/ui_mahjong/game/game_buySelfdraw_view"):create()
end


function mahjong_ui:StartGetDataTimer()
	self.timeLabel.text = tostring(os.date("%H:%M"))
	self.getDateTimer = Timer.New(
		function()
			self.timeLabel.text = tostring(os.date("%H:%M"))
		end
		,30,-1)
	self.getDateTimer:Start()
end

function mahjong_ui:RegistEvent()
	Notifier.regist(cmdName.MSG_VOICE_INFO, slot(self.OnMsgVoiceInfoHandler, self))
  	Notifier.regist(cmdName.MSG_VOICE_PLAY_BEGIN, slot(self.OnMsgVoicePlayBegin, self))
  	Notifier.regist(cmdName.MSG_VOICE_PLAY_END, slot(self.OnMsgVoicePlayEnd, self))

  	Notifier.regist(cmdName.MSG_CHAT_TEXT, slot(self.OnMsgChatText, self))
  	Notifier.regist(cmdName.MSG_CHAT_IMAGA, slot(self.OnMsgChatImaga, self))
  	Notifier.regist(cmdName.MSG_CHAT_INTERACTIN, slot(self.OnMsgChatInteractin, self))
  	Notifier.regist(GameEvent.OnMahjongSceneLoaded, self.OnMahjongSceneLoaded, self)

  	Notifier.regist(GameEvent.OnPlayerApplyClubChange, self.OnPlayerApplyClubChange, self)
end

function mahjong_ui:UnregistEvent()
	Notifier.remove(cmdName.MSG_VOICE_INFO, slot(self.OnMsgVoiceInfoHandler, self))
  	Notifier.remove(cmdName.MSG_VOICE_PLAY_BEGIN, slot(self.OnMsgVoicePlayBegin, self))
  	Notifier.remove(cmdName.MSG_VOICE_PLAY_END, slot(self.OnMsgVoicePlayEnd, self))

  	Notifier.remove(cmdName.MSG_CHAT_TEXT, slot(self.OnMsgChatText, self))
  	Notifier.remove(cmdName.MSG_CHAT_IMAGA, slot(self.OnMsgChatImaga, self))
  	Notifier.remove(cmdName.MSG_CHAT_INTERACTIN, slot(self.OnMsgChatInteractin, self))
  	Notifier.remove(GameEvent.OnMahjongSceneLoaded, self.OnMahjongSceneLoaded, self)
  	Notifier.remove(GameEvent.OnPlayerApplyClubChange, self.OnPlayerApplyClubChange, self)
end

function mahjong_ui:OnNewApplyClick( )
	local list = model_manager:GetModel("ClubModel"):GetHasApplyMemeberList()
	if #list == 0 then
		return
	end
	if #list == 1 then
		UI_Manager:Instance():ShowUiForms("ClubApplyUI", nil, nil, list[1].cid)
	else
		UI_Manager:Instance():ShowUiForms("ClubGameApplyUI")
	end
end

function mahjong_ui:OnPlayerApplyClubChange()
	if self.applyTimer ~= nil then
		self.applyTimer:Stop()
		self.applyTimer = nil
	end
	local list = model_manager:GetModel("ClubModel"):GetHasApplyMemeberList()
	if list == nil or #list == 0 then
		self.newApplyGo:SetActive(false)
	else
		self.newApplyGo:SetActive(true)
		self.applyTimer = Timer.New(function()
			if not IsNil(self.newApplyGo) then
		 		self.newApplyGo:SetActive(false)
		 	end
		 	self.applyTimer = nil
		 end, 4, false)
		self.applyTimer:Start()
	end
end

function mahjong_ui:OnMahjongSceneLoaded()
	local basePos = Vector3(-3.13, 0.64, 2.17)
	local basePosSeat2 = Vector3(3.07, 0.64, -2.36)
	local posList = {}
	local posListSeat2 = {}
	local sceneCamera = Camera.main
	if sceneCamera == nil then
		sceneCamera = mode_manager.GetCurrentMode():GetComponent("comp_mjScene").mainCamera
	end
	local uiCamera = UICamera.currentCamera 
	if uiCamera == nil then
        uiCamera = GameObject.Find("uiroot_xy/Camera"):GetComponent(typeof(Camera))
    end
	for i = 1, 15 do
		local worldPos = basePos
		local viewPos = sceneCamera:WorldToViewportPoint(worldPos)
		local screenPos = uiCamera:ViewportToScreenPoint(viewPos)
		screenPos.z = 0
		table.insert(posList, Utils.ScreenPosToUIPos(screenPos))
		basePos.z = basePos.z - 0.5

		local worldPos = basePosSeat2
		local viewPos = sceneCamera:WorldToViewportPoint(worldPos)
		local screenPos = uiCamera:ViewportToScreenPoint(viewPos)
		screenPos.z = 0
		table.insert(posListSeat2, Utils.ScreenPosToUIPos(screenPos))
		basePosSeat2.z = basePosSeat2.z + 0.5
	end
	MahjongFlowersView.Seat4ScreenPosList = posList
	MahjongFlowersView.Seat2ScreenPosList = posListSeat2
	MahjongFlowersView.hasInitPos = true
	for i = 1, #self.playerList do
		self.playerList[i]:ShowFlowersView()
	end
end


function mahjong_ui:OnMsgVoiceInfoHandler(fileID)
  mahjong_play_sys.ChatReq(3, tostring(fileID), nil)
end

function mahjong_ui:OnMsgVoicePlayEnd(viewSeat)
  self.playerList[viewSeat]:SetSoundTextureState(false)
end

function mahjong_ui:OnMsgVoicePlayBegin(viewSeat)
  self.playerList[viewSeat]:SetSoundTextureState(true)
end

function mahjong_ui:OnMsgChatText(para)
  viewSeat = para["viewSeat"]
  contentType = para["contentType"]
  content = para["content"]
  givewho = para["givewho"]
  self.playerList[viewSeat]:SetChatText(content)
end

function mahjong_ui:OnMsgChatImaga(para)
  viewSeat = para["viewSeat"]
  contentType = para["contentType"]
  content = para["content"]
  givewho = para["givewho"]
  self.playerList[viewSeat]:SetChatImg(content)
end

function mahjong_ui:OnMsgChatInteractin(para)
  viewSeat = para["viewSeat"]
  contentType = para["contentType"]
  content = para["content"]
  givewho = para["givewho"]
  self.playerList[givewho]:ShowInteractinAnimation(viewSeat,content)
end

function mahjong_ui:GetTransformPanel()
	return self.panelTr
end

--显示准备按钮
function mahjong_ui:SetReadyBtnVisible(value)
	self.readyBtnsView:SetReadyBtnVisible(value)
end

function mahjong_ui:ChangeGuobtn(spritename)
    local guo= subComponentGet(self.operTipsView.transform, "Grid/guo","UISprite")
    --local guobtn=subComponentGet(self.operTipsView.transform, "Grid/guo","UIButton")
    if guo~=nil then 
        guo.spriteName=spritename 
        --guobtn.normalSprite=spritename
        guo:MakePixelPerfect()
    end
end

-- 打开准备相关按钮
function mahjong_ui:ShowReadyBtns()
	local isRoomOwner = player_seat_mgr.GetMyLogicSeat() == roomdata_center.ownerLogicSeat
	local isFirstJu = not roomdata_center.isRoundStart
	local canApplyPlay = false
	self.readyBtnsView:Show(true,isRoomOwner,isFirstJu,canApplyPlay)
end

function mahjong_ui:HideAllReadyBtns()
	self.readyBtnsView:Hide()
end

function mahjong_ui:ShowHeadEffect(viewSeat)
	if self.headEffect then
		EffectMgr.StopEffect(self.headEffect)
	end
	for i=1,#self.playerList do 
		if i==viewSeat then
    		self.headEffect = self.playerList[i]:SetHeadEffect(i==viewSeat)
    	end
  	end
end

function mahjong_ui:SetGameInfoVisible(value)
  value = value or false
  self.leftCardGo:SetActive(value)
  self.roundNumGo:SetActive(true)
end

function mahjong_ui:GetPlayerHuaPointPos(viewSeat)
	local player = self.playerList[viewSeat]
	if player == nil then
		return nil
	else
		return player:GetHuaPointPos()
	end
end

-- function mahjong_ui:ShowUIAnimation(effectName,time)
-- 	return mahjong_effectMgr:PlayUIEffectByName(effectName,self.panelTr,time)
-- end

function mahjong_ui:ShowUIAnimationById(effectId,time)
	return mahjong_effectMgr:PlayUIEffectById(effectId,self.panelTr,time)
end

-- 更新玩家花牌数量
function mahjong_ui:SetFlowerCardNum(viewSeat, count)
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetRoomCardNum(count)
	end
end

function mahjong_ui:SetMorePanel()
  self.moreBtnsView:SetActive(not self.moreBtnsView.isActive)
end

function mahjong_ui:moreContainerClickAnimation()
  instance.moreBtnGo:SendMessage("OnClick")
end

function mahjong_ui:SetPowerState(value)
	--[[local spName = ""
	if value > 0.8 then
		spName = "dc_1"
	elseif value >0.6 then
		spName = "dc_2"
	elseif value >0.4 then
		spName = "dc_3"
	elseif value >0.2 then
		spName = "dc_4"
	else 
		spName = "dc_5"
	end
	self.powerSp.spriteName = spName--]]
	local sp_width = 29
	self.powerSp.width = sp_width * value
end

-- 剩余牌数
function mahjong_ui:SetLeftCard( num )
	self.leftCardLabel.text = num
end

function mahjong_ui:CallPlayer(funcName, viewSeat, ...)
	if self.playerList[viewSeat] == nil then
		return
	end
	self.playerList[viewSeat][funcName](self.playerList[viewSeat], ...)
end

--设置玩家信息
function mahjong_ui:SetPlayerInfo( viewSeat, usersdata)
	if game_scene.getCurSceneType() == scene_type.HALL or game_scene.getCurSceneType() == scene_type.LOGIN then
		return
	end
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:Show(usersdata, viewSeat)
	end
end

function mahjong_ui:SetAllHuaPointVisible(value)
  if mode_manager.GetCurrentMode() ~= nil then
    local cfg = mode_manager.GetCurrentMode().cfg
    if cfg.flowerOnTable  then
      value = false
    end
  end
	for i = 1, #self.playerList do
		self.playerList[i]:SetHuaPointVisible(value)
	end
end

function mahjong_ui:SetAllScoreVisible(value)
	for i = 1, #self.playerList do
		self.playerList[i]:SetScoreVisible(value)
	end
end

--隐藏玩家信息
function mahjong_ui:HidePlayer(viewSeat)
	self:CallPlayer("Hide", viewSeat)
	-- if self.playerList[viewSeat] ~= nil then
	-- 	self.playerList[viewSeat].Hide()
	-- end
end

--设置托管状态
function mahjong_ui:SetPlayerMachine(viewSeat, isMachine )
	if self.playerList[viewSeat] ~= nil then
		-- self.playerList[viewSeat]:SetMachine(isMachine)
	end
end

--更新玩家金币

function mahjong_ui:SetPlayerCoin( viewSeat,value)
	if self.playerList[viewSeat] ~= nil then
		--this.playerList[viewSeat].SetScore(value)
	end
end


--设置玩家在线状态
function mahjong_ui:SetPlayerLineState(viewSeat, isOnLine )
	-- if self.playerList[viewSeat] ~= nil then
	-- 	self.playerList[viewSeat].SetOffline(not isOnLine)
	-- end
	self:CallPlayer("SetOffline", viewSeat, not isOnLine)
end

--更新玩家分数
function mahjong_ui:SetPlayerScore( viewSeat,value)
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetScore(value)
	end
end

--设置玩家准备状态
function mahjong_ui:SetPlayerReady( viewSeat,isReady )
	--Trace("viewSeat-------------------------------------"..tostring(viewSeat))
	-- if self.playerList[viewSeat] ~= nil then
	-- 	self.playerList[viewSeat].SetReady(isReady)
	-- end
	self:CallPlayer("SetReady", viewSeat, isReady)
end

function mahjong_ui:SetBanker( viewSeat )
	-- if self.playerList[viewSeat] ~= nil then
	-- 	self.playerList[viewSeat].SetBanker(true)
	-- end
	self:CallPlayer("SetBanker", viewSeat, true)
end

--设置连庄数
function mahjong_ui:SetLianZhuang(viewSeat,lianZhuang)
  if self.playerList[viewSeat] ~= nil then
    self.playerList[viewSeat]:SetLianZhuang(lianZhuang)
  end
end

function mahjong_ui:SetRoundInfo(cur, total)
	total = total or 4
  if roomdata_center.bSupportKe then
    self.roundNumLabel.text = "局数:" .. cur
  else
	 self.roundNumLabel.text = "局数:" .. cur .. "/" .. total 
  end
end

function mahjong_ui:ShowPlayerTotalPoints(viewSeat,totalPoint)
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetTotalPoints(totalPoint)
	end
end

function  mahjong_ui:SetHideTotaPoints()
	for i,v in ipairs(self.playerList) do
		v:HideTotalPoints()
	end
end

--显示下跑按钮
function mahjong_ui:ShowXiaPao(list,cfg)
  self.xiaPaoView:Show(list,cfg)
end

--显示下跑按钮
function mahjong_ui:HideXiaPao()
  self.xiaPaoView:Hide()
	--compTbl.xiapao.gameObject:SetActive(false)
end

--显示买自摸
function mahjong_ui:ShowBuySelfdrawView()
  self.buySelfdrawView:Show()
end

--隐藏买自摸
function mahjong_ui:HideBuySelfdrawView()
  self.buySelfdrawView:Hide()
end

function mahjong_ui:SetXiaoPao( viewSeat,str )
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetPao(str)
	end
end

function mahjong_ui:HideAllPaoState()
  for i = 1, #self.playerList do
    self.playerList[i]:UpdateXiaPaoState(1)
  end
end

function mahjong_ui:UpdateXiaPaoState(viewSeat, state,cfg)
  if self.playerList[viewSeat] ~= nil then
    self.playerList[viewSeat]:UpdateXiaPaoState(state,cfg)
  end
end

--隐藏所有吓跑
function mahjong_ui:HideAllXiaPao()
	for i=1,#self.playerList do
		self.playerList[i]:HidePao()
	end
end

function mahjong_ui:ShowSpecialCard(value,index,spriteName)
	--local s_type = _type or 1
	local index = index or 1
	local obj = self.specialCardList[index]
	if obj == nil then
		obj = self:CreateSpecialCardUI( index )
		self.specialCardList[index] = obj
	end
	local bg_comp = obj.transform:GetComponent(typeof(UISprite))
	local value_comp = child(obj.transform,"card").gameObject:GetComponent(typeof(UISprite))

    local laiziCard_comp = subComponentGet(obj.transform,"card/icon","UISprite")

	laiziCard_comp.spriteName = spriteName

	if value == 0 then
		bg_comp.spriteName = "wall_mine"
		value_comp.spriteName = ""
	else
		bg_comp.spriteName = "hand_mine"
		value_comp.spriteName = value.."_hand"
	end
	obj.gameObject:SetActive(true)
end

function mahjong_ui:CreateSpecialCardUI( index )
	local obj = newobject(self.specialCardList[1])
	local pos = self.specialCardList[1].transform.localPosition
	obj.transform:SetParent(self.specialCardList[1].transform.parent, false)
	if index == 2 then
		obj.transform.localPosition = Vector3(pos.x + 70,pos.y,pos.z)
	elseif index == 3 then
		obj.transform.localPosition = Vector3(pos.x ,pos.y + 30,pos.z)
	elseif index == 4 then
		obj.transform.localPosition = Vector3(pos.x + 70,pos.y + 30,pos.z)
	end
	return obj
end

function mahjong_ui:GetSpeciaCardPos(index)
	local index = index or 1
	return self.specialCardList[index].position
end

function mahjong_ui:HideSpecialCard()
  if self.specialCardList ~= nil then
    for _,v in ipairs(self.specialCardList) do
      if not IsNil(v.gameObject) then
        v.gameObject:SetActive(false)
      end
    end
  end
end

--显示操作提示
function mahjong_ui:ShowOperTips()
	self.operTipsView:Show()
end

function mahjong_ui:GetOperTipShowState()
	return self.operTipsView.isActive
end

--隐藏操作提示
function mahjong_ui:HideOperTips(isNotHideShowCard)
	self.operTipsView:Hide()
	self.cardShowView:HideIfChi()
end

function mahjong_ui:HideCardShowView()
	self.cardShowView:Hide()
end

--游戏结束
function mahjong_ui:GameEnd()
	self:HideSpecialCard()
	self.cardShowView:Hide()
	self.cardShowView:ShowHuBtn(false)
	self:SetAllHuaPointVisible(false)
	for i = 1, #self.playerList do
		self.playerList[i]:SetBanker(false)
	end
	self:ShowHeadEffect(0)
	for i=1, 4 do
      self:ShowTing(i,false)
      self:ShowYingKou(i,false)
    end
end

--重置所有状态，用于游戏结束后
function mahjong_ui:ResetAll()
	for i=1,#self.playerList do
		self.playerList[i]:SetBanker(false)
		self.playerList[i]:SetRoomCardNum(0)
	end
	--self.HideAllXiaPao()
	self:HideRewards()
	--self.HideHunPai()
	self:SetGameInfoVisible(false)
	self.cardShowView:Hide()
	self.cardShowView:ShowHuBtn(false)
	self:ShowHeadEffect(0)
	self:HideAllXiaPao()
	self:SetHideTotaPoints()
	self:HideAllPaoState()
	for i=1, 4 do
      self:ShowTing(i,false)
      self:ShowYingKou(i,false)
    end
	-- self.HideAllReadyBtns()
end

function mahjong_ui:ShowZhuanTips()
	if self.zhuangTimer ~= nil then
		self.zhuangTimer:Stop()
	end
	if self.zhuanTipsGo ~= nil then
		self.zhuanTipsGo:SetActive(true)
		self.zhuangTimer = Timer.New(function ()
			if self.zhuanTipsGo  ~= nil then
				self.zhuanTipsGo :SetActive(false)
			end
			self.zhuangTimer = nil
			-- body
		end, 2)
		self.zhuangTimer:Start()
	end
end

-- 显示进入包次阶段 1秒隐藏
function mahjong_ui:ShowBaociTips() 
	if self.baociTips ~= nil then
		self.baociTips.gameObject:SetActive(true)
		local zhuanTimer = Timer.New(function ()
			if self.baociTips ~= nil then
				self.baociTips.gameObject:SetActive(false)
			end
			zhuanTimer = nil
			-- body
		end, 1)
		zhuanTimer:Start()
	end
end

-- 中间位置显示UI次牌 配合定次效果
function mahjong_ui:ShowCiCard(value)
	if self.ci_card ~= nil then
		self.ci_card.gameObject:SetActive(true)
		subComponentGet(self.ci_card.transform,"card_bg/card","UISprite").spriteName = value
	end
	return self.ci_card.transform
end
function mahjong_ui:HideCiCard()
	if self.ci_card ~= nil then
		self.ci_card.gameObject:SetActive(false)
	end
end

function mahjong_ui:SetPlayerZhama(viewSeat, state, num)
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:SetZhama(state, num)
	end
end

function mahjong_ui:ShowGenZhuang(count)
	if count > 0 then
		self.genZhuang.gameObject:SetActive(true)
		componentGet(self.genZhuang.gameObject,"UILabel").text = tonumber(count)
		coroutine.start(function()
            coroutine.wait(2)
            self.genZhuang.gameObject:SetActive(false)
        end)
	end
end

function mahjong_ui:ShowBZZ(viewSeat, value, Bzz)
	logError("showbzz")
end


function mahjong_ui:HideRewards()
	UI_Manager:Instance():CloseUiForms("mahjong_small_reward_ui")
end


function mahjong_ui:ShowHuang(callback)
	self.huangSpTr.localPosition = Vector3(0,500,0)
	self.huangSpTr:DOLocalMove(Vector3(0,100,0),1,false):SetEase(DG.Tweening.Ease.OutBounce):OnComplete(function()
		callback()
		self.huangGo:SetActive(false)
	end)
	self.huangGo:SetActive(true)
end


--双游 三游状态
function mahjong_ui:SetYoustatus(viewSeat,aniId)
	self.playerList[viewSeat]:SetYoustatus(aniId)
end

function mahjong_ui:SetChild(trans,posName,scale,pos)
	local posName = posName or "Anchor_Center"
	local posTrans = child(self.panelTr, posName)
	trans:SetParent(posTrans)
	trans.localScale = scale or Vector3.one
	trans.localPosition = pos or Vector3.zero
end

function mahjong_ui:ShowTingBackBtn()
    self.tingBackGo:SetActive(true)
end

function mahjong_ui:HideTingBackBtn()
    self.tingBackGo:SetActive(false)
end


function mahjong_ui:InitLogic()
	self:InitBatteryAndSignal()
	self:RegistEvent()
end

function mahjong_ui:UnInit()
	self:UnInitBatteryAndSignal()
	self:UnregistEvent()

	if self.getDateTimer ~= nil then
		self.getDateTimer:Stop()
		self.getDateTimer = nil
	end

	if self.zhuangTimer ~= nil then
		self.zhuangTimer:Stop()
		self.zhuangTimer = nil
	end

	for i = 1, #self.playerList do
		self.playerList[i]:OnDestroy()
	end
	MahjongFlowersView.hasInitPos = false

	UI_Manager:Instance():CloseUiForms("chat_ui")

	self.moreBtnsView:SetActive(false)
	self.recordView:Hide()
	self:HideOperTips()
	self:HideSpecialCard()
	self.voteView:Hide()
	self.xiaPaoView:Hide()
	self:SetHideTotaPoints()
	self.buySelfdrawView:Hide()
	self.kouView:Hide()
	self.buyCodeView:Hide()
	self:ShowHeadEffect(0)
	self.interactView:Hide()
end

function mahjong_ui:GetHunHidePos()
	if self.specialCardGo == nil then
		return nil
	end
	return self.specialCardGo.transform.position
end

function mahjong_ui:Update()
	if self.gvoice_engin ~= nil then
		self.gvoice_engin:Poll()
	end
end


function mahjong_ui:InitBatteryAndSignal()
	--监听电量及网络信号强度
    YX_APIManage.Instance:setBatteryCallback(function(msg)
      local msgTable = ParseJsonStr(msg)
      local precent = tonumber(msgTable.percent)  or 0
      self:SetPowerState(precent/100.0)
    end)
end

function mahjong_ui:UnInitBatteryAndSignal()
	YX_APIManage.Instance.batteryCallBack = nil
	YX_APIManage.Instance.signalCallBack = nil
end

function mahjong_ui:ShowWarning()
	if mahjong_warning == nil then
		require ("logic/mahjong_sys/ui_mahjong/mahjong_warning")
	end
    local content="这张是混牌，不可以被打出"
    if player_data.GetGameId()==ENUM_GAME_TYPE.TYPE_LUOYANGGANGCI_MJ then
       content="这张是次牌，不可以被打出"
    end
    if player_data.GetGameId()==ENUM_GAME_TYPE.TYPE_ANYANG_MJ then
       content="这张是赖子牌，不可以被打出"
    end
	mahjong_warning.Show(content, 1)
end

function mahjong_ui:SetGuoBtnActive(value)
    self.operTipsView:SetGuoBtnActive(value)
end

function mahjong_ui:ShowKouOperTips()
	self.kouView:Show()
end

function mahjong_ui:HideKouOperTips()
	self.kouView:Hide()
end

function mahjong_ui:GetKouCardList()
	return self.cardShowView:GetKouCardList()
end

function mahjong_ui:HideAndKou()
	self.cardShowView:HideAndKou()
	self:HideKouOperTips()
end

--[[--
 * @Description: 显示特效和牌  
 ]]
function mahjong_ui:ShowEffectAndCard(effectID,value,callback)
	self.buyCodeView:Show(effectID,value,callback)
end

return mahjong_ui

--[[--
 * @Description: 扑克通用UI基类
 * @Author:      ZWX
 * @FileName:    poker_ui_base.lua
 * @DateTime:    20180404
 ]]

require "logic/animations_sys/animations_sys"
local base = require("logic.framework.ui.uibase.ui_window")
local poker_ui_base = class("poker_ui_base",base)

local interactView = require("logic/interaction/InteractView")
function poker_ui_base:ctor()
	base.ctor(self)
	self.mostPlayerList = {}
	self.gvoice_engine = nil
	self.getDateTimer = nil    ---获取系统时间定时器
	self.chatTextTab = {
		"慢死了，虾米都煮成稀饭了",
		"快点呀！我等得花都又开了",
		"哎！牌这么差，这下要掉粉了",
		"辛辛苦苦很多年，一把回到解放前",
		"搏一搏，单车变摩托",
		"押得多赢得多，娶个媳妇回家暖被窝~",
		"有运气还要什么技术啊"
	}
	self.chatImgTab = {
	"1","2","3","4","5",
	"6","7","8","9","10",
	"11","12","13","14","15",
	"16","17","18","19","20",
	"21","22","23","24","25",
	"26",
	}
end

function poker_ui_base:OnInit()
	---未准备解散倒计时
	self.timeTipObj = self:GetGameObject("Panel/Anchor_Center/readyBtns/timeTip")
	self:InitDisMissCountDown()
	self:InitInteractView()
	
	--时间状态
	self.lbl_time = self:GetComponent("Panel/Anchor_TopLeft/phoneInfo/timeLbl","UILabel")
	--电池状态
    self.sprite_power = self:GetComponent("Panel/Anchor_TopLeft/phoneInfo/power/slider","UISprite")
	--wifi状态
    self.sprite_network = self:GetComponent("Panel/Anchor_TopLeft/phoneInfo/network","UISprite")
	
	--返回大厅按钮
	self.btn_exit = self:GetGameObject("Panel/Anchor_TopLeft/exit")
	addClickCallbackSelf(self.btn_exit.gameObject,self.Onbtn_exitClick,self)
	
	---更多按钮
	self.moreBtnGo = self:GetGameObject("Panel/Anchor_TopRight/morePanel/more")
	addClickCallbackSelf(self.moreBtnGo,self.Onbtn_moreClick, self)
	self:InitMoreBtnsView()
	
	---语音按钮
	self.btn_voice = self:GetGameObject("Panel/Anchor_Right/voice")
	addClickCallbackSelf(self.btn_voice.gameObject,self.Onbtn_voiceClick,self)
	addPressedCallbackSelf(self.btn_voice.transform,"", self.Onbtn_voicePressed,self)
	self:AddSoundDragEventListener(self.btn_voice.gameObject)
    self:InitSoundView()
	self:InitVoteView()
	
	---聊天按钮
	self.btn_chat = self:GetGameObject("Panel/Anchor_Right/chat")
	addClickCallbackSelf(self.btn_chat.gameObject,self.Onbtn_chatClick,self)
	
	---局数信息
    self.gameNum = self:GetComponent("Panel/Anchor_TopRight/gameCount","UILabel")

	self.anchor_center_tr = self:GetTransform("Panel/Anchor_Center")
	self.readyBtnsView = require( "logic/game_sys/game_common_ui/game_common_readyBtns_view"):create()
	self.readyBtnsView:Init(self.anchor_center_tr,false)

	-- 倒计时
	self.countDownSlider = require( "logic/game_sys/game_common_ui/game_common_countDown_view"):create()
	self.countDownSlider:Init(self.anchor_center_tr)

end

function poker_ui_base:OnOpen()
	self:RegisterEvent()
	self.gvoice_engine = gvoice_sys.GetEngine()
	UpdateBeat:Add(slot(self.Update, self))
	self:StartGetDateTimer()
	self:InitBatteryAndSignal()
	self:InitSettingBgm()
end

function poker_ui_base:PlayOpenAmination()
	---打开动画重写
end

function poker_ui_base:OnRefreshDepth()
	if self.mostPlayerList then
		for _,v in pairs(self.mostPlayerList) do
			local playerComponent = v
			--表情层设定
			if playerComponent then
				playerComponent.sortingOrder = self.sortingOrder
				playerComponent.m_subPanelCount = self.m_subPanelCount
			end
		end
	end
end

function poker_ui_base:ResetAll()
	self.countDownSlider:Hide()
end


function poker_ui_base:OnClose()
	self:HideDisMissCountDown()
	gvoice_sys.Uinit()
	self.gvoice_engine = nil
	if self.getDateTimer ~= nil then
		self.getDateTimer:Stop()
		self.getDateTimer = nil
	end
	self.interactView:Hide()
	self:UnInitBatteryAndSignal()
	self.recordView:Hide()
	self.voteView:Hide()
	self.countDownSlider:Hide()
	UpdateBeat:Remove(slot(self.Update, self))
	UI_Manager:Instance():CloseUiForms("chat_ui")
	if self.applyTimer ~= nil then
		self.applyTimer:Stop()
		self.applyTimer = nil
	end
	self:UnRegisterEvent()
end

function poker_ui_base:RegisterEvent()
	Notifier.regist(cmdName.MSG_VOICE_INFO,slot(self.OnMsgVoiceInfoHandler,self))
	Notifier.regist(cmdName.MSG_VOICE_PLAY_BEGIN,slot(self.OnMsgVoicePlayBegin,self))
	Notifier.regist(cmdName.MSG_VOICE_PLAY_END,slot(self.OnMsgVoicePlayEnd,self))
	Notifier.regist(cmdName.MSG_CHAT_TEXT,slot(self.OnMsgChatText,self))
  	Notifier.regist(cmdName.MSG_CHAT_IMAGA,slot(self.OnMsgChatImaga,self))
  	Notifier.regist(cmdName.MSG_CHAT_INTERACTIN,slot(self.OnMsgChatInteractin,self))
	Notifier.regist(GameEvent.OnPlayerApplyClubChange,self.OnPlayerApplyClubChange,self)
	
	Notifier.regist(cmd_poker.gratuity,slot(self.OnMsgGratuity,self))
end

function poker_ui_base:UnRegisterEvent()
	Notifier.remove(cmdName.MSG_VOICE_INFO,slot(self.OnMsgVoiceInfoHandler,self))
	Notifier.remove(cmdName.MSG_VOICE_PLAY_BEGIN,slot(self.OnMsgVoicePlayBegin,self))
	Notifier.remove(cmdName.MSG_VOICE_PLAY_END,slot(self.OnMsgVoicePlayEnd,self))
	Notifier.remove(cmdName.MSG_CHAT_TEXT,slot(self.OnMsgChatText,self))
  	Notifier.remove(cmdName.MSG_CHAT_IMAGA,slot(self.OnMsgChatImaga,self))
  	Notifier.remove(cmdName.MSG_CHAT_INTERACTIN,slot(self.OnMsgChatInteractin,self))
	Notifier.remove(GameEvent.OnPlayerApplyClubChange,self.OnPlayerApplyClubChange,self)
	
	Notifier.remove(cmd_poker.gratuity,slot(self.OnMsgGratuity,self))
end

function poker_ui_base:Update()
    if(self.gvoice_engine ~= nil) then
		self.gvoice_engine:Poll()
	end
end

function poker_ui_base:InitSettingBgm()
	ui_sound_mgr.SceneLoadFinish() 
    ui_sound_mgr.PlayBgSound("hall_bgm")
end

---创建用户列表 mostPnum:ui支持的最大人数，playerClass：player_ui
function poker_ui_base:CreatePlayerList(mostPnum,playerClass)
	if isEmpty(self.mostPlayerList)then
		for i = 1,mostPnum do
			local playerTrans = child(self.widgetTbl.panel, "Anchor_Center/Players/Player"..i)
			playerTrans.gameObject:SetActive(false)
			local playerComponent = playerClass:create(playerTrans,self)
			playerComponent:SetCallback(self.OnPlayerItemClick,self)
			playerComponent.position_index = i
			table.insert(self.mostPlayerList,playerComponent)
		end
	end
end

function poker_ui_base:SetCurPlayerList(vs)
	local peopleNum = roomdata_center.maxplayernum
	
	self.currentTable = poker_table_coordinate.poker_table[peopleNum]
	gps_data.SetTotalPlayer(self.currentTable)	---待验证是否需要处理
	
	for viewSeat,index in ipairs(self.currentTable) do
	   	if vs == viewSeat then
			self.playerList[viewSeat] = self.mostPlayerList[index]
			self.playerList[viewSeat].viewSeat = viewSeat
	   	end
	end
end

function poker_ui_base:RemoveCurPlayerList(vs)
	if self.playerList[vs] then
		self.playerList[vs] = nil
	end
end

function poker_ui_base:CallPlayer(viewSeat, funcName, param1, param2, param3)
	logError(viewSeat, self.playerList[viewSeat])
	if self.playerList[viewSeat] ~= nil and self.playerList[viewSeat][funcName] then
		self.playerList[viewSeat][funcName](self.playerList[viewSeat], param1, param2, param3)
	end
end

function poker_ui_base:SetMidJoinState()
	for viewSeat,player in pairs(self.playerList)do
		if roomdata_center.midJoinData:CheckPlayerIsMidJoin(viewSeat) then
			self:CallPlayer(viewSeat,"ShowHeadMask")
		else
			self:CallPlayer(viewSeat,"HideHeadMask")
		end
	end
end

--占坑并设置用户信息
function poker_ui_base:SetPlayerInfo(viewSeat, usersdata)
	if not self.playerList[viewSeat] then
		self:SetCurPlayerList(viewSeat)
	end
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:Show(usersdata,viewSeat)
	end
end

---隐藏用户并 离坑
function poker_ui_base:HidePlayer(viewSeat)
	if self.playerList[viewSeat] ~= nil then
		self.playerList[viewSeat]:Hide()
		self:RemoveCurPlayerList(viewSeat)
	end
end

function poker_ui_base:ShowMidJoinTip(content)
	if self.midJoinTipLabel == nil then
		local go = newNormalObjSync(data_center.GetAppPath().."/ui/common/midJoinTips", typeof(GameObject))
		go = newobject(go)
		local centerParent = self:GetGameObject("Panel/Anchor_Center").transform
		go.transform:SetParent(centerParent, false)
		self.midJoinTipLabel = go:GetComponent(typeof(UILabel))
	end
	self.midJoinTipLabel.gameObject:SetActive(true)
	self.midJoinTipLabel.text = content

end

function poker_ui_base:HideMidJoinTip()
	if self.midJoinTipLabel == nil or not self.playerList[1]["midJoin"] then
		return
	end
	self.midJoinTipLabel.gameObject:SetActive(false)
end


--定时器每分钟刷新系统时间
function poker_ui_base:StartGetDateTimer()
	self.lbl_time.text = tostring(os.date("%H:%M"))
	if not self.getDateTimer then
		self.getDateTimer = Timer.New(slot(self.OnGetDateTimer_Proc,self),30,-1)
		self.getDateTimer:Start()
	end
end

function poker_ui_base:OnGetDateTimer_Proc()
	self.lbl_time.text = tostring(os.date("%H:%M"))
end

--自己重连未准备倒计时文本
function poker_ui_base:InitDisMissCountDown()
	self.disMissCountdownView = require("logic/poker_sys/common/ready_dis_countdown"):create(self.timeTipObj)
	self.disMissCountdownView.afterStr = "s后解散牌局"
	self.disMissCountdownView.isSign = 30
	self.disMissCountdownView:HideCountDownView()
	self.disMissCountdownView:SetCallback(slot(self.DisMissCountDownProc,self))
end

function poker_ui_base:SetDisMissCountDown(time)
	self.disMissCountdownView:ShowCountDownView(time)
end

function poker_ui_base:HideDisMissCountDown()
	self.disMissCountdownView:HideCountDownView()
end

function poker_ui_base:HideReadyDisCountDowm()
	self.countDownSlider:Hide()
end

function poker_ui_base:DisMissCountDownProc(leftTime,isSign)
	if isSign then
		Notifier.dispatchCmd(cmdName.MSG_SHAKE,{})
	end
end

function poker_ui_base:InitInteractView()
	self.interactView = interactView:create()
	self.interactView:Show()
	self.interactView.transform.localPosition = Vector3(999,999,999)
	self.interactView:SetParent(self.transform)
	self.interactView:SetActive(false)
	self:RefreshDepth()
end


function poker_ui_base:OnPlayerItemClick(item)
	if item.viewSeat == 1 then
		return
	end
	self.interactView:Show(item.logicSeat)
	self.interactView:SetParent(item.head)
	self.interactView.transform.localPosition = config_mgr.getConfig("cfg_interactpos", 2).pos[item.position_index]
end

---震动定时器
local shakeTimer = nil
function poker_ui_base:SetShakeTimer(interval)
	local interval = interval or 30
	if not shakeTimer then
		shakeTimer = Timer.New(function()
			Notifier.dispatchCmd(cmdName.MSG_SHAKE,{})
		end,interval,-1)
		shakeTimer:Start()
	end
end

function poker_ui_base:StopShakeTimer()
	if shakeTimer then
		shakeTimer:Stop()
		shakeTimer = nil
	end
end

---监听电量及网络信号强度
function poker_ui_base:InitBatteryAndSignal()
    YX_APIManage.Instance:setBatteryCallback(function(msg)
		local msgTable = ParseJsonStr(msg)
		local precent = tonumber(msgTable.percent)  or 0
		self:SetPowerState(precent/100.0)
    end)
	
	--[[YX_APIManage.Instance.signalCallBack = function(msg)
    	local msgTable = ParseJsonStr(msg)
    	local precent = tonumber(msgTable.percent)	
    	Trace("signal:"..precent)		
		self:SetNetworkState(precent)
    end--]]

    local strBattery = YX_APIManage.Instance:GetPhoneBattery()
    if strBattery and string.len(strBattery) >0 then
		local msgTable = ParseJsonStr(strBattery)
		local precent = tonumber(msgTable.percent)  or 0
		self:SetPowerState(precent/100.0)
    end
end

function poker_ui_base:SetPowerState(value)
	local sp_width = 29
	self.sprite_power.width = sp_width * value
end

--[[function poker_ui_base:SetNetworkState(value)
	local spName = ""
	if value > 0.75 then
		spName = "paiju_13"
	elseif value >0.5 then
		spName = "paiju_14"
	elseif value >0.25 then
		spName = "paiju_15"
	else 
		spName = "paiju_16"
	end
	self.sprite_network.spriteName = spName
end--]]

function poker_ui_base:UnInitBatteryAndSignal()
	YX_APIManage.Instance.batteryCallBack = nil
	--YX_APIManage.Instance.signalCallBack = nil
end

--设置局数
function  poker_ui_base:SetGameNum(subround)
	local subround = subround or roomdata_center.nCurrJu  or 1
	self.gameNum.text = "局数:"..tostring(subround).."/"..tostring(roomdata_center.nJuNum)
end

----------------通用按钮点击事件--------------------

function poker_ui_base:Onbtn_exitClick()
	report_sys.EventUpload(31,player_data.GetGameId())
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
	if roomdata_center.isStart then
		MessageBox.ShowYesNoBox(LanguageMgr.GetWord(6030), function() 
			pokerPlaySysHelper.GetCurPlaySys().VoteDrawReq(true)
		end)
	else	
		--某些特殊玩法，游戏开始之前不能退出
		if self.exitCallBack then
			self.exitCallBack()
		else
			MessageBox.ShowYesNoBox(LanguageMgr.GetWord(5001), function()
				pokerPlaySysHelper.GetCurPlaySys().LeaveReq() 
			end)
		end
	end
end

function poker_ui_base:Onbtn_moreClick()
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
	self:SetMorePanel()
end

function poker_ui_base:Onbtn_voiceClick()
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
	report_sys.EventUpload(32,player_data.GetGameId())
end

function poker_ui_base:Onbtn_chatClick()
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
	report_sys.EventUpload(33,player_data.GetGameId())
	UI_Manager:Instance():ShowUiForms("chat_ui",UiCloseType.UiCloseType_CloseNothing,nil,self.chatTextTab,self.chatImgTab)
end
-----------------------end----------------------------

function poker_ui_base:SetExitBtnCallback(callback)
	self.exitCallBack = callback
end

--更多面板
function poker_ui_base:InitMoreBtnsView()
	self.moreBtnsView = require "logic/mahjong_sys/ui_mahjong/views/MoreBtnsView":create(nil, 
		slot(self.moreContainerClickAnimation,self),self:GetComponent("Panel/Anchor_TopRight/morePanel/more/Sprite","UIRect"))
	local go = newNormalObjSync(data_center.GetAppPath().."/ui/common/gameBtnsView", typeof(GameObject))
	go = newobject(go)
	go.transform:SetParent(self:GetGameObject("Panel/Anchor_TopRight/morePanel").transform,false)
	self.moreBtnsView:SetGo(go)
	self.moreBtnsView:SetActive(false)

	self.newApplyGo = self:GetGameObject("Panel/Anchor_TopRight/morePanel/newApply")
	self.newApplyGo:SetActive(false)
	addClickCallbackSelf(self.newApplyGo, self.OnNewApplyClick, self)
	self.applyTimer = nil
end

function poker_ui_base:moreContainerClickAnimation()
	self.moreBtnGo:SendMessage("OnClick")
end

function poker_ui_base:OnNewApplyClick( )
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

---显示更多面板
function poker_ui_base:SetMorePanel()
	self.moreBtnsView:SetActive(not self.moreBtnsView.isActive)
end

---录音界面
function poker_ui_base:InitSoundView()
	self.recordView = require "logic/mahjong_sys/ui_mahjong/views/RecordSoundView":create(self:GetGameObject("Panel/Anchor_Center/sound"))
	self.recordView:SetActive(false)
end

function poker_ui_base:AddSoundDragEventListener(obj)
	if not IsNil(obj) then
		addDragCallbackSelf(obj, function (go, delta)
			self.recordView:Drag(go, delta)
		end)
	end
end

function poker_ui_base:Onbtn_voicePressed(go, isPress)
	self.recordView:Press(go,isPress)
end

---投票界面
function poker_ui_base:InitVoteView()
	local go = newNormalObjSync(data_center.GetAppPath().."/ui/common/voteView", typeof(GameObject))
    go = newobject(go)
    go.transform:SetParent(self:GetGameObject("Panel/Anchor_TopRight/votePanel").transform, false)
	self.voteView = require("logic/voteQuit/vote_view"):create(go.gameObject)
	self.voteView:Hide()
end

function poker_ui_base:OnMsgVoiceInfoHandler(fileID)
	pokerPlaySysHelper.GetCurPlaySys().ChatReq(3,tostring(fileID),nil)
end

function poker_ui_base:OnMsgVoicePlayEnd(viewSeat)
 	self.playerList[viewSeat]:SetSoundTextureState(false)
end

function poker_ui_base:OnMsgVoicePlayBegin(viewSeat)
	self.playerList[viewSeat]:SetSoundTextureState(true)
end

function poker_ui_base:OnMsgChatText(para)
	viewSeat = para["viewSeat"]
	contentType = para["contentType"]
	content = para["content"]
	givewho = para["givewho"]
	self.playerList[viewSeat]:SetChatText(content)
end

function poker_ui_base:OnMsgChatImaga(para)
	viewSeat = para["viewSeat"]
	contentType = para["contentType"]
	content = para["content"]
	givewho = para["givewho"]
	self.playerList[viewSeat]:SetChatImg(content)
end

function poker_ui_base:OnMsgChatInteractin(para)
	viewSeat = para["viewSeat"]
	contentType = para["contentType"]
	content = para["content"]
	givewho = para["givewho"]
	self.playerList[givewho]:ShowInteractinAnimation(viewSeat,content)
end

function poker_ui_base:OnPlayerApplyClubChange()
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

function poker_ui_base:OnMsgGratuity(para)
	viewSeat = para["viewSeat"]
	contentType = para["contentType"]
	content = para["content"]
	givewho = para["givewho"]
	self.playerList[viewSeat]:SetGratuityPlay(content)
end


return poker_ui_base
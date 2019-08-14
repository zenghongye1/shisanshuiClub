--[[--
 * @Description: mahjong game ui component
 * @Author:      ShushingWong
 * @FileName:    mahjong_ui.lua
 * @DateTime:    2017-06-19 14:30:45
 ]]

require "logic/mahjong_sys/_model/room_usersdata_center"
require "logic/mahjong_sys/_model/room_usersdata"
require "logic/mahjong_sys/_model/operatorcachedata"
require "logic/mahjong_sys/_model/operatordata"
require "logic/mahjong_sys/ui_mahjong/mahjong_ui_sys"
require "logic/mahjong_sys/ui_mahjong/mahjong_player_ui"
require "logic/animations_sys/animations_sys"
require("logic/voteQuit/vote_quit_view")
require "logic/invite_sys/invite_sys"
require "logic/gvoice_sys/gvoice_sys"
require "logic/common_ui/rules_ui"

--房间内显示玩法待合并
--require "logic/hall_sys/chooseroom_ui/rules_ui"
--require "logic/setting/setting_ui"


mahjong_ui = ui_base.New()
local this = mahjong_ui

local transform = this.transform


local gvoice_engin = nil

-- 退出按钮
local function Onbtn_exitClick()
  report_sys.EventUpload(31,player_data.GetGameId())
  if roomdata_center.isStart or roomdata_center.isRoundStart then
  	UI_Manager:Instance():ShowGoldBox(GetDictString(6030), {function() UI_Manager:Instance():CloseUiForms("message_box") end,
  		function ()  		
  		mahjong_play_sys.VoteDrawReq(true)
  		UI_Manager:Instance():CloseUiForms("message_box")
  	end}, {"quxiao","fonts_01"}, {"button_03", "button_02"}, MessageBoxType.vote)
  	
  	return
  end

  ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_close_dialog")
  local t= GetDictString(5001)
  UI_Manager:Instance():ShowGoldBox(GetDictString(5001),{ function() UI_Manager:Instance():CloseUiForms("message_box") end, 
  	function ()  		
  		mahjong_play_sys.LeaveReq()
  		UI_Manager:Instance():CloseUiForms("message_box")
  	end}, {"quxiao","fonts_01"}, {"button_03","button_02"})
end


-- 更多按钮
local function Onbtn_moreClick()
	Trace("Onbtn_moreClick")
	--report_sys.EventUpload(32,player_data.GetGameId())
	this.SetMorePanel()
end


-- 准备按钮
local function Onbtn_readyClick()	
	ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_ready")
	mahjong_play_sys.ReadyGameReq()
  --this.HideRewards()
  --this.ShowReadyBtns()
end

-- 邀请好友
local function Onbtn_inviteClick()
	local loginType = data_center.GetPlatform()
	local name, des = ShareStrUtil.GetShareStr()
	invite_sys.inviteFriend(loginType,roomdata_center.roomnumber,name, des)
	report_sys.EventUpload(29,player_data.GetGameId())
	--invite_sys.inviteFriend(roomdata_center.roomnumber,"泉州麻将",roomdata_center.gameRuleStr)
end

-- 解散房间
local function Onbtn_closeRoomClick()
	report_sys.EventUpload(30,player_data.GetGameId())
	 UI_Manager:Instance():ShowGoldBox(GetDictString(6031), {function() UI_Manager:Instance():CloseUiForms("message_box") end, function ()  		
  		mahjong_play_sys.DissolutionRoom()
  		UI_Manager:Instance():CloseUiForms("message_box")
  	end}, {"quxiao","fonts_01"}, {"button_03","button_02"})
end


-- 语音按钮
local function Onbtn_voiceClick()
	Trace("Onbtn_voiceClick")
	report_sys.EventUpload(32,player_data.GetGameId())
end

-- 聊天按钮
local function Onbtn_chatClick()
	Trace("Onbtn_chatClick")
	report_sys.EventUpload(33,player_data.GetGameId())
	chat_ui.SetChatPanle()
end

--复制房号点击事件
local function Onbtn_CopyRoomNum(obj1,obj1)
	local str = roomdata_center.roomnumber
	Trace("Onbtn_CopyRoomNum:"..tostring(str))
	YX_APIManage.Instance:onCopy(str,function()fast_tip.Show(GetDictString(6043))end)
end


local widgetTbl = {}
local compTbl = {}
local zhuanTimer = nil
local getDateTimer = nil

function this.InitCardShowView()
	this.cardShowView = require "logic/mahjong_sys/ui_mahjong/mahjong_show_card_ui"
	this.cardShowView:SetTransform(child(widgetTbl.panel, "Anchor_Center/cardShowView"))
	--this.cardShowView:ShowHu({0, {{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3}}})
	-- this.cardShowView:ShowHua(Vector3(-371.2, -217.3, 0),{1,3,4,6,7, 1,3,4,5,1,34,5,2,23,4,25,234,2345,2345,1,12,3,4,5,34,23,134,4,13}, 1)
	-- this.cardShowView:ShowHua(Vector3(-600, -30, 0),{1,3,4,6,7}, 4)
	--this.cardShowView:ShowHua(Vector3(589, -23, 0),{1,3,4,6,7}, 2)
	--this.cardShowView:ShowHua(Vector3(-279, 267, 0),{1,3,4,6,7}, 3)
end

function this.InitVoteView()
	this.voteView = vote_quit_view.New()
	this.voteView:SetTransform(child(widgetTbl.panel, "Anchor_TopRight/voteView"))
	this.voteView:Hide()
end

function this.InitOperTipsView()
  local class = require "logic/mahjong_sys/ui_mahjong/views/OperTipsView"
  this.operTipsView = class:create(child(widgetTbl.panel, "Anchor_Center/opertips").gameObject)
  this.operTipsView:Hide()
end

function this.InitMoreBtnsView()
  this.moreBtnsView = require "logic/mahjong_sys/ui_mahjong/views/MoreBtnsView":
  create(nil, this.moreContainerClickAnimation, subComponentGet(widgetTbl.panel, "Anchor_TopRight/more/Sprite", typeof(UIRect)))
  this.moreBtnsView:SetGo(child(widgetTbl.panel, "Anchor_TopRight/morePanel/bg").gameObject)
  this.moreBtnsView:SetActive(false)
end

function this.InitSoundView()
  local class = require "logic/mahjong_sys/ui_mahjong/views/RecordSoundView"
  this.recordView = class:create(child(widgetTbl.panel, "Anchor_Center/sound").gameObject)
  this.recordView:SetActive(false)
end

function this.InitXiaPaoView( ... )
  this.xiaPaoView = require( "logic/mahjong_sys/ui_mahjong/game/game_buyHourse_view"):create()
end

--[[--
 * @Description: 获取各节点对象  
 ]]
local function InitWidgets()
	
	widgetTbl.panel = child(this.transform, "Panel")
	--返回大厅按钮
	widgetTbl.btn_exit = child(widgetTbl.panel, "Anchor_TopLeft/exit")
	if widgetTbl.btn_exit~=nil then
       addClickCallbackSelf(widgetTbl.btn_exit.gameObject,Onbtn_exitClick,this)
    end
    --更多按钮
	widgetTbl.btn_more = child(widgetTbl.panel, "Anchor_TopRight/more")
	if widgetTbl.btn_more~=nil then

       addClickCallbackSelf(widgetTbl.btn_more.gameObject,Onbtn_moreClick,this)
       widgetTbl.btn_more.gameObject:SetActive(true)
    end

    --准备按钮
	widgetTbl.btn_ready = child(widgetTbl.panel, "Anchor_Center/readyBtns/ready")
	if widgetTbl.btn_ready~=nil then
       addClickCallbackSelf(widgetTbl.btn_ready.gameObject,Onbtn_readyClick,this)
    end

    -- 邀请按钮
    widgetTbl.btn_invite = child(widgetTbl.panel, "Anchor_Center/readyBtns/invideFriend")
    if widgetTbl.btn_invite ~= nil then
    	addClickCallbackSelf(widgetTbl.btn_invite.gameObject, Onbtn_inviteClick)
    end

    -- 解散房间按钮
    widgetTbl.btn_closeRoom = child(widgetTbl.panel, "Anchor_Center/readyBtns/closeRoom")
    if widgetTbl.btn_closeRoom ~= nil then
    	addClickCallbackSelf(widgetTbl.btn_closeRoom.gameObject, Onbtn_closeRoomClick)
    end

    --语音按钮
	widgetTbl.btn_voice = child(widgetTbl.panel, "Anchor_Right/voice")
	if widgetTbl.btn_voice~=nil then
       addClickCallbackSelf(widgetTbl.btn_voice.gameObject,Onbtn_voiceClick,this)
       widgetTbl.btn_voice.gameObject:SetActive(true)

       addPressedCallbackSelf(widgetTbl.btn_voice,"", this.Onbtn_voicePressed, this)

       this.AddSoundDragEventListener(widgetTbl.btn_voice.gameObject)
    end
    --聊天按钮
	widgetTbl.btn_chat = child(widgetTbl.panel, "Anchor_Right/chat")
	if widgetTbl.btn_chat~=nil then
       addClickCallbackSelf(widgetTbl.btn_chat.gameObject,Onbtn_chatClick,this)
       widgetTbl.btn_chat.gameObject:SetActive(true)

       local chatTextTab = {"赶紧出，你在孵蛋啊！","快点吧，我等的花都谢了","催催催~急着送钱啊？","还让不让我摸牌了！",
       "这什么牌呐，摸什么打什么","辛辛苦苦很多年，一把回到解放前","你家里是开银行的吧","来呀~互相伤害呀",
       "你这样以后没朋友的","你能胡个大点的牌不？","我有大把银子，有本事来就来拿"}
       local chatImgTab = {"1","2","3","4","5","6","7","8","9","10","11","12"}
       chat_ui.Init(chatTextTab,chatImgTab)
    end

    -- --房间规则
    -- widgetTbl.btn_rules=child(widgetTbl.panel,"Anchor_TopRight/rules")
    -- Trace(widgetTbl.btn_rules.name)
    -- if widgetTbl.btn_rules~=nil then 
    --     addClickCallbackSelf(widgetTbl.btn_rules.gameObject,Onbtn_rulesClick,this) 
    -- end

	--复制按钮
	widgetTbl.btn_copy = child(widgetTbl.panel,"Anchor_TopLeft/btn_copy")
	if widgetTbl.btn_copy~=nil then
		addClickCallbackSelf(widgetTbl.btn_copy.gameObject,Onbtn_CopyRoomNum,this)
	end
    --wifi状态
    widgetTbl.sprite_network = componentGet(child(widgetTbl.panel,"Anchor_TopLeft/phoneInfo/network"),"UISprite")
    --电池状态
    widgetTbl.sprite_power = componentGet(child(widgetTbl.panel,"Anchor_TopLeft/phoneInfo/power"),"UISprite")
	--时间状态
	widgetTbl.lbl_time = componentGet(child(widgetTbl.panel,"Anchor_TopLeft/phoneInfo/timeLbl"),"UILabel")

    --初始化语音信息
    -- this.InitChatSound()

    --剩余牌数
    widgetTbl.leftCard = child(widgetTbl.panel,"Anchor_TopLeft/leftCardInfo/leftCard")
    widgetTbl.leftCardGo = child(widgetTbl.panel,"Anchor_TopLeft/leftCardInfo").gameObject
    --局数
    widgetTbl.roundNum = child(widgetTbl.panel, "Anchor_TopRight/roundInfo/round")
    widgetTbl.roundNumGo = child(widgetTbl.panel, "Anchor_TopRight/roundInfo").gameObject
  

    widgetTbl.zhuanTips = child(widgetTbl.panel, "Anchor_Center/zhuanTips")
    widgetTbl.zhuanTips.gameObject:SetActive(false)

    --玩家信息
    this.playerList = {}
    for i=1,4 do
    	local playerTrans = child(widgetTbl.panel, "Anchor_Center/Players/Player"..i)
    	if playerTrans ~= nil then
    		local playerComponent = mahjong_player_ui.New(playerTrans)
        if roomdata_center.MaxPlayer() == 2 and (i ~= 2 and i ~= 4 ) then
    		  table.insert(this.playerList, playerComponent)
        elseif roomdata_center.MaxPlayer() == 3 then
          local myLogicSeat = player_seat_mgr.GetMyLogicSeat()
          if myLogicSeat == 1 then
            if i ~= 4 then
              table.insert(this.playerList, playerComponent)
            end
          elseif myLogicSeat == 2 then
            if i ~= 3 then
              table.insert(this.playerList, playerComponent)
            end
          elseif myLogicSeat == 3 then
            if i ~= 2 then
              table.insert(this.playerList, playerComponent)
            end
          end
        elseif roomdata_center.MaxPlayer() == 4 then
          table.insert(this.playerList, playerComponent)
        end
    		playerTrans.gameObject:SetActive(false)
    	end
    end

	----设置互动表情位置
	local maxPeopleNum = 4
	local posTbl = config_mgr.getConfig("cfg_mahjongpos",maxPeopleNum)
	for i=1,maxPeopleNum do
		local playerTrans = child(widgetTbl.panel, "Anchor_Center/Players/Player"..i)
		this.InitInteractionView(playerTrans.gameObject,posTbl["pos"][i])
	end


 --    --下跑
 --    compTbl.xiapao = child(widgetTbl.panel, "Anchor_Center/xiapao")
	-- if compTbl.xiapao~=nil then
	-- 	for i=0,3 do
	-- 		local btn_xiapao = child(compTbl.xiapao, "pao"..i)
	-- 		addClickCallbackSelf(btn_xiapao.gameObject,

	-- 		function ()
	-- 			mahjong_play_sys.XiaPaoReq(i,player_seat_mgr.GetMyLogicSeat())
	-- 		end,
	-- 		this)
	-- 	end
 --       compTbl.xiapao.gameObject:SetActive(false)
 --    end
 	-- compTbl.gameInfos = child(widgetTbl.panel, "Anchor_Center/gameInfo")


 	-- compTbl.readyBtns = child(widgetTbl.panel, "Anchor_Center/readyBtns")
 	-- if compTbl.readyBtns ~= nil then
 	-- 	compTbl.readyBtns.gameObject:SetActive(true)
 	-- end


  compTbl.specialCard = child(widgetTbl.panel, "Anchor_TopLeft/specialCard")
  if compTbl.specialCard ~= nil then
      compTbl.specialCard.gameObject:SetActive(false)
  end
  compTbl.specialCardList = {}
  table.insert(compTbl.specialCardList,compTbl.specialCard)

    --荒庄
    compTbl.huang = child(widgetTbl.panel, "Anchor_Center/huang")
    if compTbl.huang~=nil then
    	compTbl.huangSpriteTrans = child(compTbl.huang, "Sprite")
    	compTbl.huang.gameObject:SetActive(false)
    end

    compTbl.tingBack = child(widgetTbl.panel, "Anchor_Center/tingGuo")
    if compTbl.tingBack~=nil then
      compTbl.tingBack.gameObject:SetActive(false)
      addClickCallbackSelf(compTbl.tingBack.gameObject,this.OnTingBackBtnClick,this)
    end

    this.InitCardShowView()
    this.InitVoteView()
    this.InitOperTipsView()
    this.InitMoreBtnsView()
    this.InitSoundView()
    this.SetGameInfoVisible(false)
    this.SetAllHuaPointVisible(false)
    -- this.SetAllScoreVisible(false)
    this.HideAllReadyBtns()
    this.InitXiaPaoView()


    --iPhoneX适配
    local delayTimer = Timer.New(function()
      local widgetPanel = child(this.transform, "Panel")
      if widgetPanel and data_center.GetCurPlatform() == "IPhonePlayer" and YX_APIManage.Instance:isIphoneX() then

        local Anchor_TopRight = child(widgetPanel, "Anchor_TopRight")
        if Anchor_TopRight then
          local localPos = Anchor_TopRight.gameObject.transform.localPosition
          Anchor_TopRight.gameObject.transform.localPosition = Vector3(localPos.x -60, localPos.y, localPos.z)
        end
        local Anchor_Right = child(widgetPanel, "Anchor_Right")
        if Anchor_Right then
          local localPos = Anchor_Right.gameObject.transform.localPosition
          Anchor_Right.gameObject.transform.localPosition = Vector3(localPos.x -60, localPos.y, localPos.z)
        end
        
        --copyBtn
        local btn_copy = child(widgetPanel, "Anchor_TopLeft/btn_copy")
        if btn_copy then
          local localPos = btn_copy.gameObject.transform.localPosition
          btn_copy.gameObject.transform.localPosition = Vector3(localPos.x +60, localPos.y, localPos.z)
        end
      end
    end, 0.1, 1)
    delayTimer:Start()

end


function this.GetTransform()
	return widgetTbl.panel
end



-- function this.EnableOperTipBtns(value)
--   for k, v in pairs(compTbl.opertips.operBtnsList) do
--     v.gameObject:GetComponent(typeof(UIButton)).isEnabled = value
--   end
-- end

function this.Awake()

	InitWidgets()
	this:InitPanelRenderQueue()
	msg_dispatch_mgr.SetIsEnterState(true)
	this.StartGetDateTimer()

  Notifier.regist(cmdName.MSG_VOICE_INFO, this.OnMsgVoiceInfoHandler)
  Notifier.regist(cmdName.MSG_VOICE_PLAY_BEGIN, this.OnMsgVoicePlayBegin)
  Notifier.regist(cmdName.MSG_VOICE_PLAY_END, this.OnMsgVoicePlayEnd)

  Notifier.regist(cmdName.MSG_CHAT_TEXT, this.OnMsgChatText)
  Notifier.regist(cmdName.MSG_CHAT_IMAGA, this.OnMsgChatImaga)
  Notifier.regist(cmdName.MSG_CHAT_INTERACTIN, this.OnMsgChatInteractin)
end

function this.Start()
	this.InitBatteryAndSignal()
  gvoice_engin = gvoice_sys.GetEngine()

end

--[[
语音回调检测
]]
function this.Update()
  if(gvoice_engin ~= nil) then
    gvoice_engin:Poll()
  end
end

function this.OnDestroy()
	if zhuanTimer ~= nil then
		zhuanTimer:Stop()
		zhuanTimer = nil
	end
	if getDateTimer ~= nil then
		getDateTimer:Stop()
		getDateTimer = nil
	end
	for i = 1, #this.playerList do
		this.playerList[i].OnDestroy()
	end
	this.playerList = {}
	widgetTbl = {}
	compTbl = {}	
	-- mahjong_ui_sys.UInit()

	this.UnInitBatteryAndSignal()

  gvoice_sys.Uinit()
  Notifier.remove(cmdName.MSG_VOICE_INFO, this.OnMsgVoiceInfoHandler)
  Notifier.remove(cmdName.MSG_VOICE_PLAY_BEGIN, this.OnMsgVoicePlayBegin)
  Notifier.remove(cmdName.MSG_VOICE_PLAY_END, this.OnMsgVoicePlayEnd)

  Notifier.remove(cmdName.MSG_CHAT_TEXT, this.OnMsgChatText)
  Notifier.remove(cmdName.MSG_CHAT_IMAGA, this.OnMsgChatImaga)
  Notifier.remove(cmdName.MSG_CHAT_INTERACTIN, this.OnMsgChatInteractin)

  -- 防止事件没有处理
  this.moreBtnsView:SetActive(false)
  this.recordView:Hide()
  chat_ui.Clear()
end

--定时器每分钟刷新系统时间
function this.StartGetDateTimer()
	widgetTbl.lbl_time.text = tostring(os.date("%H:%M"))
	getDateTimer = Timer.New(this.OnGetDateTimer_Proc,30,-1)
	getDateTimer:Start()
end

function this.OnGetDateTimer_Proc()
	widgetTbl.lbl_time.text = tostring(os.date("%H:%M"))
end

--显示准备按钮
function this.SetReadyBtnVisible(value)
	widgetTbl.btn_ready.gameObject:SetActive(value)
end

--邀请好友
function this.SetInviteBtnVisible(value)
	widgetTbl.btn_invite.gameObject:SetActive(value)
end


function this.SetCloseBtnVisible(value)
	widgetTbl.btn_closeRoom.gameObject:SetActive(value)
end

--复制房号按钮
function this.SetCopyRnoVisible(value)
	widgetTbl.btn_copy.gameObject:SetActive(value)
end


-- 打开准备相关按钮
function this.ShowReadyBtns()
	local isFirstJu = not roomdata_center.isRoundStart
	this.SetReadyBtnVisible(true)
	this.SetInviteBtnVisible(isFirstJu)
	this.SetCopyRnoVisible(isFirstJu)
	local isRoomOwner = player_seat_mgr.GetMyLogicSeat() == roomdata_center.ownerLogicSeat
	this.SetCloseBtnVisible(isRoomOwner and isFirstJu)
	if isRoomOwner then
		LuaHelper.SetTransformLocalX(widgetTbl.btn_invite, 103)
		if isFirstJu then
			LuaHelper.SetTransformLocalX(widgetTbl.btn_closeRoom, -103)
		else
			LuaHelper.SetTransformLocalX(widgetTbl.btn_closeRoom, 0)
		end
	else
		LuaHelper.SetTransformLocalX(widgetTbl.btn_invite, 0)
	end
end

function this.HideAllReadyBtns()
	this.SetReadyBtnVisible(false)
	this.SetInviteBtnVisible(false)
	this.SetCloseBtnVisible(false)
	this.SetCopyRnoVisible(false)
end


function this.ShowHeadEffect(viewSeat)
	--this.headEff = animations_sys.PlayLoopAnimation(this.playerList[viewSeat].head, data_center.GetAppConfDataTble().appPath.."/effects/anim_head_eff", "touxiangquang", 100, 100, 3007)
	for i=1,#this.playerList do 
    	this.playerList[i].SetHeadEffect(i==viewSeat)
  end
end


function this.SetGameInfoVisible(value)
  value = value or false
  widgetTbl.leftCardGo:SetActive(value)
  widgetTbl.roundNumGo:SetActive(true)
  	-- if compTbl.gameInfos ~= nil then
  	-- 	compTbl.gameInfos.gameObject:SetActive(value or false)
  	-- end
end

function this.GetPlayerHuaPointPos(viewSeat)
	local player = this.playerList[viewSeat]
	if player == nil then
		return nil
	else
		return player.GetHuaPointPos()
	end
end

function this.ShowUIAnimation(animationPrefab, animationName)
	animations_sys.PlayAnimation(widgetTbl.panel,animationPrefab,animationName,100,100,false,function(  ) end, 3010)
end

--[[--
 * @Description: 设置玩法、房号  
 * @param:       wanfaStr 玩法  RoomNum 房号
 * @return:      nil
 ]]


-- 更新玩家花牌数量
function this.SetFlowerCardNum(viewSeat, count)
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].SetRoomCardNum(count)
	end

end

function this.SetMorePanel()
  this.moreBtnsView:SetActive(not this.moreBtnsView.isActive)
end

function this.moreContainerClickAnimation()
  widgetTbl.btn_more.gameObject:SendMessage("OnClick")
end

function this.InitBatteryAndSignal()
	--监听电量及网络信号强度
    -- YX_APIManage.Instance.batteryCallBack = 
    YX_APIManage.Instance:setBatteryCallback(function(msg)
      local msgTable = ParseJsonStr(msg)
      local precent = tonumber(msgTable.percent)  or 0
      this.SetPowerState(precent/100.0)
    end)

  --   YX_APIManage.Instance.signalCallBack = function(msg)
  --   	local msgTable = ParseJsonStr(msg)
  --   	local precent = tonumber(msgTable.percent)	
  --   	Trace("signal:"..precent)		
		-- this.SetNetworkState(precent)
  --   end

    -- local signalType = YX_APIManage.Instance:GetNetworkReachability()
    -- this.ChangeNetworkState(signalType)

    -- local battery = YX_APIManage.Instance:GetPhoneBattery() or 100
    -- this.SetPowerState(tonumber(battery)/100.0)

    local strBattery = YX_APIManage.Instance:GetPhoneBattery()
    if strBattery and string.len(strBattery) >0 then
      local msgTable = ParseJsonStr(strBattery)
      local precent = tonumber(msgTable.percent)  or 0
      this.SetPowerState(precent/100.0)
    end

end

function this.UnInitBatteryAndSignal()
	YX_APIManage.Instance.batteryCallBack = nil
	YX_APIManage.Instance.signalCallBack = nil
end

-- function this.SetNetworkState(value)
-- 	local spName = ""
-- 	if value > 0.75 then
-- 		spName = "paiju_13"
-- 	elseif value >0.5 then
-- 		spName = "paiju_14"
-- 	elseif value >0.25 then
-- 		spName = "paiju_15"
-- 	else 
-- 		spName = "paiju_16"
-- 	end
-- 	widgetTbl.sprite_network.spriteName = spName
-- end

-- local wifiSpNames = 
-- {
--   "paiju_13",
--   "paiju_14",
--   "paiju_15",
--   "paiju_16",
-- }

-- local areaNetwordSpNames = 
-- {
--   "xinhao_1",
--   "xinhao_2",
--   "xinhao_3",
--   "xinhao_4",
--   "xinhao_5",
-- }

-- function this.ChangeNetworkState(netState)
--   local bg = child(widgetTbl.sprite_network.transform, "bg")
--   local bg_Sp = componentGet(bg,"UISprite")
--   if netState == 2 then
--     curNetSpNameTbl = wifiSpNames
--     bg_Sp.spriteName = curNetSpNameTbl[1]
--   else
--     curNetSpNameTbl = areaNetwordSpNames
--     bg_Sp.spriteName = curNetSpNameTbl[1]
--   end
--   this.SetNetworkState(signalValue)
-- end

function this.SetPowerState(value)
	local spName = ""
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
	widgetTbl.sprite_power.spriteName = spName
end

local autoPlay = false
function this.SetAutoPlayInfo()
	if autoPlay == false then
		autoPlay = true
	else
		autoPlay = false
	end
	mahjong_play_sys.AutoPlayReq(autoPlay)
end

-- 剩余牌数
function this.SetLeftCard( num )
	if widgetTbl.leftCard_comp == nil then
		widgetTbl.leftCard_comp = widgetTbl.leftCard.gameObject:GetComponent(typeof(UILabel))
	end

	widgetTbl.leftCard_comp.text = num
end

--设置玩家信息
function this.SetPlayerInfo( viewSeat, usersdata)
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].Show(usersdata, viewSeat)
	end
end

function this.SetAllHuaPointVisible(value)
  if mode_manager.GetCurrentMode() ~= nil then
    local cfg = mode_manager.GetCurrentMode().config
    if cfg.gameCfg.flowerOnTable  then
      value = false
    end
  end
	for i = 1, #this.playerList do
		this.playerList[i].SetHuaPointVisible(value)
	end
end

function this.SetAllScoreVisible(value)
	for i = 1, #this.playerList do
		this.playerList[i].SetScoreVisible(value)
	end
end

--隐藏玩家信息
function this.HidePlayer(viewSeat)
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].Hide()
	end
end

--设置托管状态
function this.SetPlayerMachine(viewSeat, isMachine )
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].SetMachine(isMachine)
	end
end

--设置玩家在线状态
function this.SetPlayerLineState(viewSeat, isOnLine )
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].SetOffline(not isOnLine)
	end
end

--更新玩家金币

function this.SetPlayerCoin( viewSeat,value)
	if this.playerList[viewSeat] ~= nil then
		--this.playerList[viewSeat].SetScore(value)
	end
end


--更新玩家分数
function this.SetPlayerScore( viewSeat,value)
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].SetScore(value)
	end
end


--设置玩家准备状态
function this.SetPlayerReady( viewSeat,isReady )
	--Trace("viewSeat-------------------------------------"..tostring(viewSeat))
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].SetReady(isReady)
	end
end

function this.SetShoot()
	if this.playerList[viewSeat] ~= nil then
		return this.playerList[viewSeat].ShootTran
	end
end

--[[--
 * @Description: 定庄  
 * @param:       viewSeat 视图座位号 
 * @return:      nil
 ]]
function this.SetBanker( viewSeat )
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].SetBanker(true)
	end
end

--设置连庄数
function this.SetLianZhuang(viewSeat,lianZhuang)
  if this.playerList[viewSeat] ~= nil then
    this.playerList[viewSeat].SetLianZhuang(lianZhuang)
  end
end

function this.SetRoundInfo(cur, total)
	total = total or 4
	if widgetTbl.roundNum_comp == nil then
		widgetTbl.roundNum_comp = widgetTbl.roundNum.gameObject:GetComponent(typeof(UILabel))
	end
  if roomdata_center.bSupportKe then
    widgetTbl.roundNum_comp.text = "局数:[FFEAAFFF]" .. cur
  else
	  widgetTbl.roundNum_comp.text = "局数:[FFEAAFFF]" .. cur .. "/" .. total .. "[-]"
  end
end


--显示下跑按钮
function this.ShowXiaPao(list)
  this.xiaPaoView:Show(list)
end

--显示下跑按钮
function this.HideXiaPao()
  this.xiaPaoView:Hide()
	--compTbl.xiapao.gameObject:SetActive(false)
end

--[[--
 * @Description: 设置所有玩家下跑倍数  
 * @param:       viewSeat 视图座位号 beishu 倍数
 * @return:      nil
 ]]
function this.SetXiaoPao( viewSeat,beishu )
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].SetPao(beishu)
	end
end

function this.HideAllPaoState()
  for i = 1, #this.playerList do
    this.playerList[i].UpdateXiaPaoState(1)
  end
end

function this.UpdateXiaPaoState(viewSeat, state)
  if this.playerList[viewSeat] ~= nil then
    this.playerList[viewSeat].UpdateXiaPaoState(state)
  end
end

--隐藏所有吓跑
function this:HideAllXiaPao()
	for i=1,#this.playerList do
		this.playerList[i].HidePao()
	end
end

--显示混牌
function this.ShowHunPai( value )
  this.ShowSpecialCard(value)
end

function this.ShowSpecialCard(value,index)
  local index = index or 1
  local obj = compTbl.specialCardList[index]
  if obj == nil then
    obj = this.CreateSpecialCardUI( index )
    compTbl.specialCardList[index] = obj
  end
  local comp = child(obj.transform,"card_bg/card").gameObject:GetComponent(typeof(UISprite))
  comp.spriteName = value.."_hand"
  obj.gameObject:SetActive(true)
end

function this.CreateSpecialCardUI( index )
  local obj = newobject(compTbl.specialCardList[1])
  local pos = compTbl.specialCardList[1].transform.localPosition
  obj:SetParent(compTbl.specialCardList[1].transform.parent, false)
  if index == 2 then
    obj.transform.localPosition = Vector3(pos.x + 70,pos.y,pos.z)
  elseif index == 3 then
    obj.transform.localPosition = Vector3(pos.x ,pos.y + 30,pos.z)
  elseif index == 4 then
    obj.transform.localPosition = Vector3(pos.x + 70,pos.y + 30,pos.z)
  end
  return obj
end

function this.GetSpeciaCardPos(index)
  local index = index or 1
  return compTbl.specialCardList[index].position
end

function this.HideSpecialCard()
  if compTbl.specialCardList ~= nil then
    for _,v in ipairs(compTbl.specialCardList) do
      if not IsNil(v.gameObject) then
        v.gameObject:SetActive(false)
      end
    end
  end
  -- if compTbl.specialCard ~= nil then
  --   compTbl.specialCard.gameObject:SetActive(false)
  -- end
end

--隐藏混牌
function this.HideHunPai()
  this.HideSpecialCard()
	--compTbl.laizi.gameObject:SetActive(false)
end


--显示操作提示
function this.ShowOperTips()
  this.operTipsView:Show()
end

function this.GetOperTipShowState()
  return this.operTipsView.isActive
end

--隐藏操作提示
function this.HideOperTips(isNotHideShowCard)
  this.operTipsView:Hide()
  this.cardShowView:HideIfChi()
end

--游戏结束
function this.GameEnd()
  this.HideSpecialCard()
	this.cardShowView:Hide()
	this.cardShowView:ShowHuBtn(false)
	this.SetAllHuaPointVisible(false)
	-- this.SetAllScoreVisible(false)
  for i = 1, #this.playerList do
    this.playerList[i].SetBanker(false)
  end
  this.ShowHeadEffect(0)
end

--重置所有状态，用于游戏结束后
function this.ResetAll()
	for i=1,#this.playerList do
		this.playerList[i].SetBanker(false)
		this.playerList[i].SetRoomCardNum(0)
	end
	--this.HideAllXiaPao()
	this.HideRewards()
	--this.HideHunPai()
	this.SetGameInfoVisible(false)
	this.cardShowView:Hide()
	this.cardShowView:ShowHuBtn(false)
  this.ShowHeadEffect(0)
  this.HideAllXiaPao()
  this.HideAllPaoState()
	-- this.HideAllReadyBtns()
end

function this.ShowZhuanTips()
	if zhuanTimer ~= nil then
		zhuanTimer:Stop()
	end
	if widgetTbl.zhuanTips ~= nil then
		widgetTbl.zhuanTips.gameObject:SetActive(true)
		zhuanTimer = Timer.New(function ()
			if widgetTbl.zhuanTips ~= nil then
				widgetTbl.zhuanTips.gameObject:SetActive(false)
			end
			zhuanTimer = nil
			-- body
		end, 2)
		zhuanTimer:Start()
	end
end



function this.HideRewards()
  if mahjong_small_reward_ui ~= nil then
    mahjong_small_reward_ui.Hide()
  end
end


function this.ShowHuang(callback)
	compTbl.huangSpriteTrans.localPosition = Vector3(0,500,0)
	compTbl.huangSpriteTrans:DOLocalMove(Vector3(0,100,0),1,false):SetEase(DG.Tweening.Ease.OutBounce):OnComplete(function()
		callback()
		compTbl.huang.gameObject:SetActive(false)
	end)
	compTbl.huang.gameObject:SetActive(true)
end



--[[
语音按钮长按
]]
function this.Onbtn_voicePressed(self, go, isPress)
  this.recordView:Press(go, isPress)
  
end

-- this.isDrag = false
function this.AddSoundDragEventListener(trans)
  if not IsNil(trans) then
    addDragCallbackSelf(trans, function (go, delta)
      this.recordView:Drag(go, delta)
    end)

    addDragEndCallbackSelf(trans, function (go)
    end)
  end
end

function this.OnMsgVoiceInfoHandler(fileID)
  mahjong_play_sys.ChatReq(3, tostring(fileID), nil)
end

function this.OnMsgVoicePlayEnd(viewSeat)
  this.playerList[viewSeat].SetSoundTextureState(false)
end

function this.OnMsgVoicePlayBegin(viewSeat)
  this.playerList[viewSeat].SetSoundTextureState(true)
end



function this.OnMsgChatText(para)
  viewSeat = para["viewSeat"]
  contentType = para["contentType"]
  content = para["content"]
  givewho = para["givewho"]
  this.playerList[viewSeat].SetChatText(content)
end

function this.OnMsgChatImaga(para)
  viewSeat = para["viewSeat"]
  contentType = para["contentType"]
  content = para["content"]
  givewho = para["givewho"]
  this.playerList[viewSeat].SetChatImg(content)
end

function this.OnMsgChatInteractin(para)
  viewSeat = para["viewSeat"]
  contentType = para["contentType"]
  content = para["content"]
  givewho = para["givewho"]
  this.playerList[givewho].ShowInteractinAnimation(viewSeat,content)
end

--双游 三游状态
function this.SetYoustatus(viewSeat,status)
  this.playerList[viewSeat].SetYoustatus(status)
end

function this.SetChild(trans,posName,scale,pos)
  local posName = posName or "Anchor_Center"
  local posTrans = child(widgetTbl.panel, posName)
  trans:SetParent(posTrans)
  trans.localScale = scale or Vector3.one
  trans.localPosition = pos or Vector3.zero
end

function this.ShowTingBackBtn()
  if compTbl.tingBack~=nil then
    compTbl.tingBack.gameObject:SetActive(true)
  end
end

function this.HideTingBackBtn()
  if compTbl.tingBack~=nil then
    compTbl.tingBack.gameObject:SetActive(false)
  end
end

function this.OnTingBackBtnClick()
  Notifier.dispatchCmd(cmdName.MAHJONG_TING_CARD)
end

--设置互动表情面板位置
function this.InitInteractionView(go,tbl)
  this.InteractionView = require "logic/interaction/InteractionView":
  create(go,nil,tbl)
end
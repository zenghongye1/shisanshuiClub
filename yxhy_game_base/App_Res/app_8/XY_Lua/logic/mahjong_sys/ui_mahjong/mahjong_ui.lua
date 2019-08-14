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

local operTipEX = nil

local gvoice_engin = nil

-- 退出按钮
local function Onbtn_exitClick()


  if roomdata_center.isStart or roomdata_center.isRoundStart then
  	message_box.ShowGoldBox(GetDictString(6030), {function() message_box.Close() end,
  		function ()  		
  		mahjong_play_sys.VoteDrawReq(true)
  		message_box.Close()
  	end}, {"quxiao","fonts_01"}, {"button_03", "button_02"}, MessageBoxType.vote)
  	
  	return
  end

  ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_close_dialog")
  local t= GetDictString(5001)
  message_box.ShowGoldBox(GetDictString(5001),{ function() message_box.Close() end, 
  	function ()  		
  		mahjong_play_sys.LeaveReq()
  		message_box.Close()
  	end}, {"quxiao","fonts_01"}, {"button_03","button_02"})
end


-- 更多按钮
local function Onbtn_moreClick()
	Trace("Onbtn_moreClick")
	this.SetMorePanle()
end





-- 准备按钮
local function Onbtn_readyClick()	
	ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_ready")
	mahjong_play_sys.ReadyGameReq()
  --this.HideRewards()
  --this.ShowReadyBtns()
end

-- 邀请微信好友
local function Onbtn_inviteClick()
	invite_sys.inviteFriend(roomdata_center.roomnumber,"福州麻将",roomdata_center.gameRuleStr)
end

-- 解散房间
local function Onbtn_closeRoomClick()
	 message_box.ShowGoldBox(GetDictString(6031), {function() message_box.Close() end, function ()  		
  		mahjong_play_sys.DissolutionRoom()
  		message_box.Close()
  	end}, {"quxiao","fonts_01"}, {"button_03","button_02"})
end


-- 语音按钮
local function Onbtn_voiceClick()
	Trace("Onbtn_voiceClick")
end

-- 聊天按钮
local function Onbtn_chatClick()
	Trace("Onbtn_chatClick")
  chat_ui.SetChatPanle()
end

local function Onbtn_rulesClick() 
   rules_ui.Show() 
end
--玩法
local function Onbtn_gameplayClick()
	Trace("Onbtn_gameplayClick")
	local tRuleName = "zhengzhoumj"
	local tType = player_data.GetGameId()
	if tType == 1 then
		tRuleName = "zhengzhoumj"
	elseif tType == 2 then
		tRuleName = "luoyangmj"
	elseif tType == 3 then
		tRuleName = "zhumadianmj"
	end
	--fast_tip.Show(GetDictString(6014))
  help_ui.Show()
	--TODO
	--rules_ui.Show(tRuleName)
end

--设置
local function Onbtn_settingClick()
	Trace("Onbtn_settingClick")
	setting_ui.Show()
end

--战绩
local function Onbtn_resultClick()	
	local tShow = false
	if tShow== false then
		http_request_interface.getRoomByRid(roomdata_center.rid,1,function (str)
           local s=string.gsub(str,"\\/","/")  
           local t=ParseJsonStr(s)
           Trace("Onbtn_resultClick()--------"..str)
           recorddetails_ui.Show(t)   
       end)
		return
	end
	Trace("Onbtn_resultClick")
end

--托管
local function Onbtn_machineClick()
	Trace("Onbtn_machineClick")
	this.SetAutoPlayInfo()
end

--更多蒙板
 local function Onbtn_moreContainerClick()
	--this.SetMorePanle()
  this.moreContainerClickAnimation()
end

--胡牌点击事件
local function Onbtn_huClick()
	Trace("Onbtn_huClick")
	local tbl = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.Hu)
	Trace("Onbtn_huClick-------"..tostring(tbl))
	mahjong_play_sys.HuPaiReq(tbl.nCard)
end

--听牌点击事件
local function Onbtn_tingClick()
	Trace("Onbtn_tingClick")
	mahjong_play_sys.TingReq()
end

--杠牌点击事件
local function Onbtn_gangClick()
	Trace("Onbtn_gangClick")
	mahjong_play_sys.QuadrupletReq()
end

--碰牌点击事件
local function Onbtn_pengClick()
	Trace("Onbtn_pengClick")
	mahjong_play_sys.TripletReq()
end

-- 抢点击事件
local function Onbtn_qiangClick()
	Trace("Onbtn_qiangClick")
	local tbl = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.Qiang)
	mahjong_play_sys.HuPaiReq(tbl.nCard)
end

--吃牌点击事件
local function Onbtn_chiClick()
	Trace("Onbtn_chiClick")


	local cardCanCollect = operatorcachedata.GetOpTipsTblByType(MahjongOperTipsEnum.Collect)
	if #cardCanCollect == 1 then
		mahjong_play_sys.CollectReq(cardCanCollect[1])
	else
		this.cardShowView:ShowChi(cardCanCollect)
		mahjong_ui.HideOperTips()
	end
end

--过牌点击事件
local function Onbtn_guoClick()
	Trace("Onbtn_guoClick")
	mahjong_play_sys.GiveUp()
  Notifier.dispatchCmd(cmdName.MSG_ON_GUO_CLICK, nil)
	mahjong_ui.HideOperTips()
end

local function Onbtn_cancelMachineClick()
	mahjong_play_sys.AutoPlayReq(false)
end

local operNameTable = {
	[1] = "hu",
	[2] = "ting",
	[3] = "gang",
	[4] = "peng",
	[5] = "chi",
	[6] = "guo",
	[7] = "qiang"
}

local operEventTable = {
	[1] = Onbtn_huClick,
	[2] = Onbtn_tingClick,
	[3] = Onbtn_gangClick,
	[4] = Onbtn_pengClick,
	[5] = Onbtn_chiClick,
	[6] = Onbtn_guoClick,
	[7] = Onbtn_qiangClick
}


local widgetTbl = {}
local compTbl = {}
local zhuanTimer = nil

local function InitCardShowView()
	this.cardShowView = require "logic/mahjong_sys/ui_mahjong/mahjong_show_card_ui"
	this.cardShowView:SetTransform(child(widgetTbl.panel, "Anchor_Center/cardShowView"))
	--this.cardShowView:ShowHu({0, {{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3},{nCard = 21, nFan = 10, nLeft = 3}}})
	-- this.cardShowView:ShowHua(Vector3(-371.2, -217.3, 0),{1,3,4,6,7, 1,3,4,5,1,34,5,2,23,4,25,234,2345,2345,1,12,3,4,5,34,23,134,4,13}, 1)
	-- this.cardShowView:ShowHua(Vector3(-600, -30, 0),{1,3,4,6,7}, 4)
	--this.cardShowView:ShowHua(Vector3(589, -23, 0),{1,3,4,6,7}, 2)
	--this.cardShowView:ShowHua(Vector3(-279, 267, 0),{1,3,4,6,7}, 3)
end

local function InitVoteView()
	this.voteView = vote_quit_view.New()
	this.voteView:SetTransform(child(widgetTbl.panel, "Anchor_TopRight/voteView"))
	this.voteView:Hide()
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
    --更多面板
    widgetTbl.panel_more = child(widgetTbl.panel, "Anchor_TopRight/morePanel/bg")
    if widgetTbl.panel_more~=nil then
       widgetTbl.panel_more.gameObject:SetActive(false)
    end
    --更多面板蒙板
    widgetTbl.panel_moreContainer = child(widgetTbl.panel, "Anchor_TopRight/morePanel/bg/Container")
    if widgetTbl.panel_moreContainer~=nil then
       addClickCallbackSelf(widgetTbl.panel_moreContainer.gameObject,Onbtn_moreContainerClick,this)
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

       local chatTextTab = {"快点了！时间很宝贵的","一路屁胡！走向胜利","上碰下自摸！大家要小心咯","好汉不胡头三把","先胡不算胡，后胡金满桌","呀！打错了怎么办","卡卡卡！卡的人火大啊","很高兴能和大家一起打牌哦"}
       local chatImgTab = {"1","2","3","4","5","6","7","8","9","10","11","12"}
       chat_ui.Init(chatTextTab,chatImgTab)
    end
    --玩法按钮
	widgetTbl.btn_gameplay = child(widgetTbl.panel, "Anchor_TopRight/morePanel/bg/gameplay")
	if widgetTbl.btn_gameplay~=nil then
       addClickCallbackSelf(widgetTbl.btn_gameplay.gameObject,Onbtn_gameplayClick,this)
       widgetTbl.btn_gameplay.gameObject:SetActive(true)
    end
    --房间规则
    widgetTbl.btn_rules=child(widgetTbl.panel,"Anchor_TopRight/rules")
    Trace(widgetTbl.btn_rules.name)
    if widgetTbl.btn_rules~=nil then 
        addClickCallbackSelf(widgetTbl.btn_rules.gameObject,Onbtn_rulesClick,this) 
    end
    --设置按钮
	widgetTbl.btn_setting = child(widgetTbl.panel, "Anchor_TopRight/morePanel/bg/setting")
	if widgetTbl.btn_setting~=nil then
       addClickCallbackSelf(widgetTbl.btn_setting.gameObject,Onbtn_settingClick,this)
       widgetTbl.btn_setting.gameObject:SetActive(true)
    end
    --战绩按钮
	widgetTbl.btn_result = child(widgetTbl.panel, "Anchor_TopRight/morePanel/bg/result")
	if widgetTbl.btn_result~=nil then
       addClickCallbackSelf(widgetTbl.btn_result.gameObject,Onbtn_resultClick,this)
       widgetTbl.btn_result.gameObject:SetActive(true)
    end
    --托管按钮
	widgetTbl.btn_machine = child(widgetTbl.panel, "Anchor_TopRight/morePanel/bg/machine")
	if widgetTbl.btn_machine~=nil then
       addClickCallbackSelf(widgetTbl.btn_machine.gameObject,Onbtn_machineClick,this)
       --widgetTbl.btn_machine.gameObject:SetActive(true)
    end
    --托管面板
    widgetTbl.panel_machine = child(widgetTbl.panel, "Anchor_Bottom/machine")
	if widgetTbl.panel_machine~=nil then
		widgetTbl.panel_machine_btn = child(widgetTbl.panel, "Anchor_Bottom/machine/btn")
       addClickCallbackSelf(widgetTbl.panel_machine_btn.gameObject,Onbtn_cancelMachineClick,this)
       widgetTbl.panel_machine.gameObject:SetActive(false)
    end
    --房间号
    widgetTbl.roomNumLabel = subComponentGet(widgetTbl.panel, "Anchor_TopLeft/roomNum", typeof(UILabel))
    --玩法房号
    Trace("----------------------------------------------------label_gameinfo")
	widgetTbl.label_gameinfo = child(widgetTbl.panel, "Anchor_Bottom/gameInfo")
	if widgetTbl.label_gameinfo~=nil then
       widgetTbl.label_gameinfo.gameObject:SetActive(false)
    end

    --wifi状态
    widgetTbl.sprite_network = componentGet(child(widgetTbl.panel,"Anchor_TopLeft/phoneInfo/network"),"UISprite")
    --电池状态
    widgetTbl.sprite_power = componentGet(child(widgetTbl.panel,"Anchor_TopLeft/phoneInfo/power"),"UISprite")   

    --初始化语音信息
    this.InitChatSound()

    --剩余牌数
    widgetTbl.leftCard = child(widgetTbl.panel,"Anchor_Center/gameInfo/leftCardInfo/leftCard")
    --局数
    widgetTbl.roundNum = child(widgetTbl.panel, "Anchor_Center/gameInfo/roundInfo/round")
    --结算面板
    -- widgetTbl.rewards_panel = child(widgetTbl.panel,"Anchor_Center/rewards")
    -- if widgetTbl.rewards_panel~=nil then
    -- 	this.FindChild_Rewards()
    --     widgetTbl.rewards_panel.gameObject:SetActive(false)
    -- end

    widgetTbl.zhuanTips = child(widgetTbl.panel, "Anchor_Center/zhuanTips")
    widgetTbl.zhuanTips.gameObject:SetActive(false)

    --玩家信息
    this.playerList = {}
    for i=1,4 do
    	local playerTrans = child(widgetTbl.panel, "Anchor_Center/Players/Player"..i)
    	if playerTrans ~= nil then
    		local playerComponent = mahjong_player_ui.New(playerTrans)
        if roomdata_center.MaxPlayer() == 2 and (i == 2 or i == 4 ) then
    		  
        else
          table.insert(this.playerList, playerComponent)
        end
    		playerTrans.gameObject:SetActive(false)
    	end
    end



    --下跑
    compTbl.xiapao = child(widgetTbl.panel, "Anchor_Center/xiapao")
	if compTbl.xiapao~=nil then
		for i=0,3 do
			local btn_xiapao = child(compTbl.xiapao, "pao"..i)
			addClickCallbackSelf(btn_xiapao.gameObject,

			function ()
				mahjong_play_sys.XiaPaoReq(i,player_seat_mgr.GetMyLogicSeat())
			end,
			this)
		end
       compTbl.xiapao.gameObject:SetActive(false)
    end
 	compTbl.gameInfos = child(widgetTbl.panel, "Anchor_Center/gameInfo")
 	if compTbl.gameInfos ~= nil then
 		--compTbl.gameInfos.localPosition = Utils.WorldPosToScreenPos(Vector3(0, 0.64, 0))
 		-- compTbl.gameInfos.gameObject:SetActive(false)
 	end

 	compTbl.readyBtns = child(widgetTbl.panel, "Anchor_Center/readyBtns")
 	if compTbl.readyBtns ~= nil then
 		compTbl.readyBtns.gameObject:SetActive(true)
 	end


    --吃碰杠胡提示
    compTbl.opertips = child(widgetTbl.panel, "Anchor_Center/opertips")
	if compTbl.opertips~=nil then
		compTbl.opertips.operBtnsList = {}
		for i=1,#operNameTable do
			local btn_oper = child(compTbl.opertips, "Grid/"..operNameTable[i])
			addClickCallbackSelf(btn_oper.gameObject,

			function ()
				operEventTable[i]()
        this.EnableOperTipBtns(false)
			end,
			this)

			compTbl.opertips.operBtnsList[operNameTable[i]] = btn_oper
		end

       compTbl.opertips.gameObject:SetActive(false)
    end
    
 --    --癞子
	-- compTbl.laizi = child(widgetTbl.panel, "Anchor_TopLeft/lai")
	-- if compTbl.laizi~=nil then
 --       compTbl.laizi.gameObject:SetActive(false)
 --  end

  compTbl.specialCard = child(widgetTbl.panel, "Anchor_TopRight/specialCard")
  if compTbl.specialCard ~= nil then
      compTbl.specialCard.gameObject:SetActive(false)
  end

    --荒庄
    compTbl.huang = child(widgetTbl.panel, "Anchor_Center/huang")
    if compTbl.huang~=nil then
    	compTbl.huangSpriteTrans = child(compTbl.huang, "Sprite")
    	compTbl.huang.gameObject:SetActive(false)
    end

    InitCardShowView()
    InitVoteView()
    this.SetGameInfoVisible(false)
    this.SetAllHuaPointVisible(false)
    this.SetAllScoreVisible(false)
    this.HideAllReadyBtns()
end


function this.GetTransform()
	return widgetTbl.panel
end



function this.EnableOperTipBtns(value)
  for k, v in pairs(compTbl.opertips.operBtnsList) do
    v.gameObject:GetComponent(typeof(UIButton)).isEnabled = value
  end
end

function this.Awake()
	InitWidgets()
	mahjong_ui_sys.Init()
	this:InitPanelRenderQueue()
	msg_dispatch_mgr.SetIsEnterState(true)	

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
	for i = 1, #this.playerList do
		this.playerList[i].OnDestroy()
	end
	this.playerList = {}
	widgetTbl = {}
	compTbl = {}	
	mahjong_ui_sys.UInit()

	this.UnInitBatteryAndSignal()

  this.LimitRecodeSoundHide()
  gvoice_sys.Uinit()
  Notifier.remove(cmdName.MSG_VOICE_INFO, this.OnMsgVoiceInfoHandler)
  Notifier.remove(cmdName.MSG_VOICE_PLAY_BEGIN, this.OnMsgVoicePlayBegin)
  Notifier.remove(cmdName.MSG_VOICE_PLAY_END, this.OnMsgVoicePlayEnd)

  Notifier.remove(cmdName.MSG_CHAT_TEXT, this.OnMsgChatText)
  Notifier.remove(cmdName.MSG_CHAT_IMAGA, this.OnMsgChatImaga)
  Notifier.remove(cmdName.MSG_CHAT_INTERACTIN, this.OnMsgChatInteractin)

  chat_ui.Clear()
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


-- 打开准备相关按钮
function this.ShowReadyBtns()
	local isFirstJu = not roomdata_center.isRoundStart
	this.SetReadyBtnVisible(true)
	this.SetInviteBtnVisible(isFirstJu)
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
end


function this.ShowHeadEffect(viewSeat)
	return animations_sys.PlayLoopAnimation(this.playerList[viewSeat].head, "app_8/effects/anim_head_eff", "touxiangquang", 100, 100, 3007)
end



-- function  this.ShowReadyBtn(isRoomOwner)
-- 	-- widgetTbl.btn_ready.gameObject:SetActive(true)
-- 	isRoomOwner = player_seat_mgr.GetMyLogicSeat() == 1
-- 	compTbl.readyBtns.gameObject:SetActive(true)
-- 	widgetTbl.btn_ready.gameObject:SetActive(true)
-- 	widgetTbl.btn_closeRoom.gameObject:SetActive(isRoomOwner or false)
-- end

-- --隐藏准备按钮
-- function  this.HideReadyBtn()



-- 	-- widgetTbl.btn_ready.gameObject:SetActive(false)
-- 	-- compTbl.readyBtns.gameObject:SetActive(false)
-- 	widgetTbl.btn_ready:SetActive(false)
-- end

function this.SetGameInfoVisible(value)
	if compTbl.gameInfos ~= nil then
		compTbl.gameInfos.gameObject:SetActive(value or false)
	end
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



function  this.SetGameInfo(RoomNum)
	-- local str = wanfaStr.." | "..RoomNum
	-- if widgetTbl.label_gameinfo_comp == nil then
	-- 	widgetTbl.label_gameinfo_comp = widgetTbl.label_gameinfo.gameObject:GetComponent(typeof(UILabel))
	-- end
	-- widgetTbl.label_gameinfo_comp.text = str
	-- widgetTbl.label_gameinfo.gameObject:SetActive(true)
	widgetTbl.roomNumLabel.text = "房号:" .. RoomNum
end

-- 更新玩家花牌数量
function this.SetFlowerCardNum(viewSeat, count)
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].SetRoomCardNum(count)
	end

end

function this.SetMorePanle()
	if widgetTbl.panel_more.gameObject.activeSelf == true then
		widgetTbl.panel_more.gameObject:SetActive(false)
	else
		widgetTbl.panel_more.gameObject:SetActive(true)
	end
end

function this.moreContainerClickAnimation()
  widgetTbl.btn_more.gameObject:SendMessage("OnClick")
end

function this.SetChatPanle()
	if widgetTbl.panel_chatPanel.gameObject.activeSelf == true then
		widgetTbl.panel_chatPanel.gameObject:SetActive(false)
	else
		widgetTbl.panel_chatPanel.gameObject:SetActive(true)
	end
end

function this.HideChatPanel()
	widgetTbl.panel_chatPanel.gameObject:SetActive(false)
end

function this.InitBatteryAndSignal()
	--监听电量及网络信号强度
    YX_APIManage.Instance.batteryCallBack = function(msg)
    	local msgTable = ParseJsonStr(msg)
    	local precent = tonumber(msgTable.percent)	
    	Trace("battery:"..precent)	
		this.SetPowerState(precent)
    end

    YX_APIManage.Instance.signalCallBack = function(msg)
    	local msgTable = ParseJsonStr(msg)
    	local precent = tonumber(msgTable.percent)	
    	Trace("signal:"..precent)		
		this.SetNetworkState(precent)
    end
end

function this.UnInitBatteryAndSignal()
	YX_APIManage.Instance.batteryCallBack = nil
	YX_APIManage.Instance.signalCallBack = nil
end

function this.SetNetworkState(value)
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
	widgetTbl.sprite_network.spriteName = spName
end

function this.SetPowerState(value)
	local spName = ""
	if value > 0.8 then
		spName = "paiju_17"
	elseif value >0.6 then
		spName = "paiju_18"
	elseif value >0.4 then
		spName = "paiju_19"
	elseif value >0.2 then
		spName = "paiju_20"
	else 
		spName = "paiju_21"
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


function this.SetRoundInfo(cur, total)
	total = total or 4
	if widgetTbl.roundNum_comp == nil then
		widgetTbl.roundNum_comp = widgetTbl.roundNum.gameObject:GetComponent(typeof(UILabel))
	end
	widgetTbl.roundNum_comp.text = "局数:[FFEAAFFF]" .. cur .. "/" .. total .. "[-]"
end


--显示下跑按钮
function this.ShowXiaPaoBtn()
	compTbl.xiapao.gameObject:SetActive(true)
end

--显示下跑按钮
function this.HideXiaPaoBtn()
	compTbl.xiapao.gameObject:SetActive(false)
end

--[[--
 * @Description: 设置所有玩家下跑倍数  
 * @param:       viewSeat 视图座位号 beishu 倍数
 * @return:      nil
 ]]
function this.SetXiaoPao( viewSeat,beishu )
	--for i=1,#this.playerList do
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].SetPao(beishu)
	end
	--end
end

--隐藏所有吓跑
function this:HideAllXiaPao()
	for i=1,#this.playerList do
		this.playerList[i].HidePao()
	end
end

--显示混牌
function this.ShowHunPai( value )
	-- if compTbl.laizi_comp == nil then
	-- 	compTbl.laizi_comp = child(compTbl.laizi,"card_bg/card").gameObject:GetComponent(typeof(UISprite))
	-- end
	-- compTbl.laizi_comp.spriteName = value.."_hand"
	-- compTbl.laizi.gameObject:SetActive(true)
  this.ShowSpecialCard(value)
end

function this.ShowSpecialCard(value)
  if compTbl.specialCard_comp == nil then
    compTbl.specialCard_comp = child(compTbl.specialCard,"card_bg/card").gameObject:GetComponent(typeof(UISprite))
  end
  compTbl.specialCard_comp.spriteName = value.."_hand"
  compTbl.specialCard.gameObject:SetActive(true)
end

function this.GetSpeciaCardPos()
  return compTbl.specialCard.position
end

function this.HideSpecialCard()
  if compTbl.specialCard ~= nil then
    compTbl.specialCard.gameObject:SetActive(false)
  end
end

--隐藏混牌
function this.HideHunPai()
  this.HideSpecialCard()
	--compTbl.laizi.gameObject:SetActive(false)
end

--[[--
 * @Description: 
 * MahjongOperTipsEnum = {
    None                = 0x0001,
    GiveUp              = 0x0002,--过,
    Collect             = 0x0003,--吃,
    Triplet             = 0x0004,--碰,
    Quadruplet          = 0x0005,--杠,
    Ting                = 0x0006,--听,
    Hu                  = 0x0007,--胡,
}

local operNameTable = {
	[1] = "hu",
	[2] = "ting",
	[3] = "gang",
	[4] = "peng",
	[5] = "chi",
	[6] = "guo",
}
  
 ]]
--显示操作提示
function this.ShowOperTips()
  this.EnableOperTipBtns(true)
	if operTipEX~=nil then
		animations_sys.StopPlayAnimationToCache(operTipEX, "circle")
	end

	local ol = operatorcachedata.GetOperTipsList()
	local ShowList = {}

	for i,v in pairs(compTbl.opertips.operBtnsList) do
		v.gameObject:SetActive(false)
	end

  local isHu = false

	for i,v in ipairs(ol) do
		repeat
	    if v.operType == MahjongOperTipsEnum.GiveUp then
				compTbl.opertips.operBtnsList["guo"].gameObject:SetActive(true)
				table.insert(ShowList,compTbl.opertips.operBtnsList["guo"])
				break
			end
			if v.operType == MahjongOperTipsEnum.Collect then
				compTbl.opertips.operBtnsList["chi"].gameObject:SetActive(true)
				table.insert(ShowList,compTbl.opertips.operBtnsList["chi"])
				break
			end
			if v.operType == MahjongOperTipsEnum.Triplet then
				compTbl.opertips.operBtnsList["peng"].gameObject:SetActive(true)
				table.insert(ShowList,compTbl.opertips.operBtnsList["peng"])
				break
			end
			if v.operType == MahjongOperTipsEnum.Quadruplet then
				compTbl.opertips.operBtnsList["gang"].gameObject:SetActive(true)
				table.insert(ShowList,compTbl.opertips.operBtnsList["gang"])
				break
			end
			if v.operType == MahjongOperTipsEnum.Ting then
				compTbl.opertips.operBtnsList["ting"].gameObject:SetActive(true)
				table.insert(ShowList,compTbl.opertips.operBtnsList["ting"])
				break
			end
			if v.operType == MahjongOperTipsEnum.Hu then
        isHu = true
				compTbl.opertips.operBtnsList["hu"].gameObject:SetActive(true)
				table.insert(ShowList,compTbl.opertips.operBtnsList["hu"])
				break
			end
			if v.operType == MahjongOperTipsEnum.Qiang then
				compTbl.opertips.operBtnsList["qiang"].gameObject:SetActive(true)
				table.insert(ShowList,compTbl.opertips.operBtnsList["qiang"])
				break
			end
			break
    	until true
	end

	for i=1,#ShowList do
		ShowList[i].localPosition = Vector3(-130*(#ShowList-i),0,0)
	end

  local exName = "chi"
  if isHu then
    exName = "hu"
  end
	operTipEX = animations_sys.PlayLoopAnimation(ShowList[1],"app_8/effects/circle",exName,100,100,3007)

	compTbl.opertips.gameObject:SetActive(true)
end

function this.GetOperTipShowState()
  if IsNil(compTbl.opertips) then
    return false;
  end
  return compTbl.opertips.gameObject.activeSelf
end

--隐藏操作提示
function this.HideOperTips()
  if compTbl.opertips ~= nil and compTbl.opertips.gameObject ~= nil then
	  compTbl.opertips.gameObject:SetActive(false)
  end
end

--游戏结束
function this.GameEnd()
  this.HideSpecialCard()
	this.cardShowView:Hide()
	this.cardShowView:ShowHuBtn(false)
	this.SetAllHuaPointVisible(false)
	this.SetAllScoreVisible(false)
  for i = 1, #this.playerList do
    this.playerList[i].SetBanker(false)
  end
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
  -- if widgetTbl.rewards_panel ~= nil and widgetTbl.rewards_panel.gameObject ~= nil then
	 --   widgetTbl.rewards_panel.gameObject:SetActive(false)
  -- end
  -- mahjong_rewards_ui.Hide()
  mahjong_small_reward_ui.Hide()
end


function this.ShowHuang(callback)
	compTbl.huangSpriteTrans.localPosition = Vector3(0,500,0)
	compTbl.huangSpriteTrans:DOLocalMove(Vector3(0,100,0),1,false):SetEase(DG.Tweening.Ease.OutBounce):OnComplete(function()
		callback()
		compTbl.huang.gameObject:SetActive(false)
	end)
	compTbl.huang.gameObject:SetActive(true)
end


--语音聊天模块
function this.InitChatSound()
  widgetTbl.SoundPanel = child(widgetTbl.panel, "Anchor_Center/sound")
  if widgetTbl.SoundPanel~=nil then
    widgetTbl.SoundPanel.gameObject:SetActive(false)
  end
  widgetTbl.SoundSendPanel = child(widgetTbl.SoundPanel,"send")
  if widgetTbl.SoundSendPanel~=nil then
    widgetTbl.SoundSendPanel.gameObject:SetActive(true)
  end
  widgetTbl.SoundSendQuan = child(widgetTbl.SoundSendPanel,"quan")
  if widgetTbl.SoundSendQuan~=nil then
    widgetTbl.SoundSendQuan.gameObject:SetActive(false)   
    widgetTbl.spriteQuan = componentGet(widgetTbl.SoundSendQuan.transform,"UISprite")
  end

  widgetTbl.SoundCancelSendPanel = child(widgetTbl.SoundPanel,"cancelSend")
  if widgetTbl.SoundCancelSendPanel~=nil then
    widgetTbl.SoundCancelSendPanel.gameObject:SetActive(false)
  end
end
function this.SetSoundPanel(state)
  widgetTbl.SoundPanel.gameObject:SetActive(state)
end
function this.SetSoundSendPanel(state)
  widgetTbl.SoundSendPanel.gameObject:SetActive(state)
end
function this.SetSoundCancelSendPanel(state)
  widgetTbl.SoundCancelSendPanel.gameObject:SetActive(state)
end

function this.SetSoundSendQuanAnimation(time,callback)
  coroutine.start(function()
      if widgetTbl.spriteQuan~=nil then
        widgetTbl.spriteQuan.fillAmount = 1
      end      
      if callback ~= nil then
        callback()
        callback = nil
      end
    end)
end

  local fillInternalTime = 0.3
  local timerSoundSend_Elapse = nil --消息时间间隔  
  local fillSize = 0
  function this.LimitRecodeSoundShow()
    this.LimitRecodeSoundHide()
    
    this.SetSoundPanel(true)
    this.SetSoundSendPanel(true)
    this.SetSoundCancelSendPanel(false)
    widgetTbl.SoundSendQuan.gameObject:SetActive(true)
    widgetTbl.spriteQuan.fillAmount=0
    fillSize = 0

    timerSoundSend_Elapse = Timer.New(this.OnTimerSoundSend_Proc , fillInternalTime, -1)
    timerSoundSend_Elapse:Start()
  end
  
  function this.LimitRecodeSoundHide()
    if timerSoundSend_Elapse ~= nil then
        timerSoundSend_Elapse:Stop()  
        timerSoundSend_Elapse = nil     
    end
  end

  function this.OnTimerSoundSend_Proc()
    fillSize = fillSize + fillInternalTime/gvoice_sys.GetMaxRecordTime()
    if fillSize < 1 then
      if widgetTbl.spriteQuan~=nil then
        widgetTbl.spriteQuan.fillAmount=fillSize
      end
    else
      this.isMaxTimeSend = true
      this.RecodeSoundEnd()
    end
  end

  --录音结束
  function this.RecodeSoundEnd()
    this.LimitRecodeSoundHide()
    this.SetSoundPanel(false)
    Trace("录音结束，执行后续逻辑-------------------------------")

    gvoice_sys.StopRecording()   -- 结束录音
    gvoice_sys.AddRecordedFileLst()   -- 上传文件
  end

  --开始录音
  function this.RecodeSoundStart()
    Trace("录音开始,执行开始录音逻辑-------------------------------")
    local ret = gvoice_sys.StartRecording()   --开始录音

    Trace("ret ----------------------"..tostring(ret))
    if ret then
      this.LimitRecodeSoundShow()     
    end
    return ret
  end

  --取消录音
  function this.RecodeSoundCancel()
    this.LimitRecodeSoundHide()
    this.SetSoundPanel(false)
    Trace("录音取消,执行取消录音逻辑-------------------------------")
    gvoice_sys.StopRecording()   -- 结束录音
  end

this.isCancel = false
this.isMaxTimeSend = false
local isStart = false
--[[
语音按钮长按
]]
function this.Onbtn_voicePressed(self, go, isPress)
  --Trace("isPress:"..tostring(isPress))
  if isPress and (not isStart) then
    isStart = true
    this.isCancel = false
    this.isMaxTimeSend = false
    this.RecodeSoundStart()
  else
    if this.isCancel == false and this.isMaxTimeSend == false then
      if fillSize*gvoice_sys.GetMaxRecordTime()<gvoice_sys.GetMinRecordTime() then
        fast_tip.Show("说话时间过短，请重新说话")
        this.RecodeSoundCancel()
      else
        this.RecodeSoundEnd()
      end
    end
    isStart = false
  end
end

this.isDrag = false
function this.AddSoundDragEventListener(trans)
  if not IsNil(trans) then
    addDragCallbackSelf(trans, function (go, delta)
      if not this.isDrag then
        if delta.y > 3 then 
          this.isDrag = true
          --Trace("is Drag")
        end
      else
        if widgetTbl.SoundSendPanel.gameObject.activeSelf == true then
          widgetTbl.SoundSendPanel.gameObject:SetActive(false)
        end
        if widgetTbl.SoundCancelSendPanel.gameObject.activeSelf == false then
          widgetTbl.SoundCancelSendPanel.gameObject:SetActive(true)
        end
      end
    end)

    addDragEndCallbackSelf(trans, function (go)
        --Trace("Input.mousePosition-----------"..tostring(Input.mousePosition))
        if this.isDrag then
          if Input.mousePosition.y > 3*Screen.height/5 then           
            this.isCancel = true
            if this.isMaxTimeSend ==false then
              this.RecodeSoundCancel()
            end
          end
          this.isDrag = false
        end
        --Trace("DragEnd")
    end)
  end
end

function this.OnMsgVoiceInfoHandler(fileID)
  --local voiceStr = CombinJsonStr(voiceTbl)
  Trace("fileID---------------------"..tostring(fileID))

  mahjong_play_sys.ChatReq(3, tostring(fileID), nil)
end

function this.OnMsgVoicePlayEnd(viewSeat)
  Trace("viewSeat--------------------"..tostring(viewSeat))
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
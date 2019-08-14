require "logic/mahjong_sys/_model/room_usersdata_center"
require "logic/mahjong_sys/_model/room_usersdata"
require "logic/mahjong_sys/_model/operatorcachedata"
require "logic/mahjong_sys/_model/operatordata"
require "logic/hall_sys/openroom/room_data"

--require "logic/mahjong_sys/ui_mahjong/mahjong_player_ui"
require "logic/animations_sys/animations_sys"
--require "logic/shisangshui_sys/ui_shisangshui/shisangshui_ui_sys"
require "logic/shisangshui_sys/shisangshui_play_sys"
require "logic/shisangshui_sys/ui_shisangshui/shisanshui_player_ui"
--require "logic/common_ui/chat_ui"
require "logic/hall_sys/setting_ui/setting_ui"
require "logic/hall_sys/record_ui/recorddetails_ui"
require "logic/gvoice_sys/gvoice_sys"

shisangshui_ui = ui_base.New()
local this = shisangshui_ui

local transform = this.transform

local operTipEX = nil

this.timerAlarm = nil
this.animationTabel = {}

local gvoice_engine = nil 

local disTimer_Elapse = nil  --重连解散定时器
local getDateTimer = nil	--获取系统时间定时器
local leftTime = nil
local widgetTbl = {}
local compTbl = {}

local scoreTran ={}	--比分

local special_card_type = {}
local read_card_player = {}

local gameDataInfo = {}

local chatTextTab = {"快点快点，这把我要全垒打","慢死了，虾米都煮成稀饭了","快点呀！我等得花都又开了","辛辛苦苦很多年，一把回到解放前","哎呀~为什么中枪的总是我？","搏一搏，单车变摩托","押得多赢得多，娶个媳妇回家暖被窝~","有运气还要什么技术啊","哈哈，你们赶快穿上防弹衣吧！"}
-- local chatImgTab = {"1","2","3","4","5","6","7","8","9"}
local chatImgTab = {
	"1","2","3","4","5",
	"6","7","8","9","10",
	"11","12","13","14","15",
	"16","17","18","19","20",
	"21","22","23","24","25",
	"26",
}


local function Onbtn_exitClick()
	report_sys.EventUpload(31,player_data.GetGameId())
  if roomdata_center.isStart then
	Trace("+++++++++投票，投票+++++++++++++")
	
	
	UI_Manager:Instance():ShowGoldBox(GetDictString(6030), {function() UI_Manager:Instance():CloseUiForms("message_box") end,
  		function ()  		
  		shisangshui_play_sys.VoteDrawReq(true)
  		UI_Manager:Instance():CloseUiForms("message_box")
  	end}, {"quxiao","fonts_01"}, {"button_03", "button_02"}, MessageBoxType.vote)
  	return
  end

	--如果是水庄玩法，并且是庄家，游戏开始之前不能退出
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
	--ui_sound_mgr.PlaySoundClip("common/audio_close_dialog")
	local roomInfo = room_data.GetSssRoomDataInfo()
	if roomInfo.isZhuang == true then
		local isOwner = room_data.IsOwner()
		if isOwner == true then
			UI_Manager:Instance():ShowGoldBox(GetDictString(6047),{function()
				UI_Manager:Instance():CloseUiForms("message_box")
			end},{"fonts_01"})
		else
			Trace("++++++++++离开，离开++++++++++")
			local t= GetDictString(5001)
			UI_Manager:Instance():ShowGoldBox(t,{function ()  		
			shisangshui_play_sys.LeaveReq()
			UI_Manager:Instance():CloseUiForms("message_box")
			end}, {"fonts_01"}, {"button_02"})
				
		end
	else
		Trace("++++++++++离开，离开++++++++++")
		local t= GetDictString(5001)
		UI_Manager:Instance():ShowGoldBox(t,{function ()  		
  		shisangshui_play_sys.LeaveReq()
  		UI_Manager:Instance():CloseUiForms("message_box")
		end}, {"fonts_01"}, {"button_02"})
	end
		
	
 
end

local function Onbtn_moreClick()
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
	Trace("Onbtn_moreClick")
	--this.SetMorePanle()
	this.SetMorePanel()
end

local function OnBtn_WarningClick()
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
	report_sys.EventUpload(35,player_data.GetGameId())
	help_ui.Show(ENUM_GAME_TYPE.TYPE_SHISHANSHUI)
	local luaBaseComp = componentGet(help_ui.transform,typeof(LogicBaseLua))
	if luaBaseComp ~= nil then
		luaBaseComp.beKeepDepthValue = false
	end
end

local function Onbtn_readyClick()	
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
	Trace("Onbtn_readyClick")
	
	if(disTimer_Elapse ~= nil) then
		this.StopTime_Dis()  ----重连解散定时器关
	end
	shisangshui_play_sys.ReadyGameReq()
end

function this.ShowDisTimerLab(state)
	if(disTimer_Elapse ~= nil) then
		this.StopTime_Dis()  ----重连解散定时器关
	end
	if(widgetTbl.dismiss_timePanel ~= nil) then
		widgetTbl.dismiss_timePanel.gameObject:SetActive(state)
	end
end

local isClick=true
local function Onbtn_voiceClick()
	Trace("Onbtn_voiceClick")
	report_sys.EventUpload(32,player_data.GetGameId())
end

local function Onbtn_inviteFriend()	--邀请好友
	Trace("Onbtn_inviteFriend")
	report_sys.EventUpload(29,player_data.GetGameId())
	local loginType = data_center.GetPlatform()
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
	invite_sys.inviteFriend(loginType,room_data.GetSssRoomDataInfo().rno,"十三水",tostring(room_data.GetSSSShareString()))
end

local function Onbtn_dimissRoom()	--解散房间
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
	report_sys.EventUpload(30,player_data.GetGameId())
	 UI_Manager:Instance():ShowGoldBox(GetDictString(6031), {function() UI_Manager:Instance():CloseUiForms("message_box") end, function ()  		
  		shisangshui_play_sys.DissolutionRoom()
  		UI_Manager:Instance():CloseUiForms("message_box")
  	end}, {"quxiao","fonts_01"}, {"button_03","button_02"})
end

local function Onbtn_chatClick()
	Trace("Onbtn_chatClick")
	report_sys.EventUpload(33,player_data.GetGameId())
	chat_ui.Init(chatTextTab,chatImgTab)
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
	chat_ui.SetChatPanle()
end

function OnBtn_SettingOnClick()
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
	Trace("++++++++SettingOnClick")
	report_sys.EventUpload(36,player_data.GetGameId())
	setting_ui.Show()
	  local luaBaseComp = componentGet(setting_ui.transform,typeof(LogicBaseLua))
	  if luaBaseComp ~= nil then
		luaBaseComp.beKeepDepthValue = false
	  end
	
end

--更多蒙板
local function Onbtn_moreContainerClick()
	--this.SetMorePanle()
	this.moreContainerClickAnimation()
end

--战绩UI
function OnBtn_AchievementOnClick()
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
	report_sys.EventUpload(37,player_data.GetGameId())
	http_request_interface.getRoomByRid(roomdata_center.rid,1,function (str)
           local s=string.gsub(str,"\\/","/")  
           local t=ParseJsonStr(s)
           Trace(str)
		 recorddetails_ui.Show(t) 
		   local luaBaseComp = componentGet(recorddetails_ui.transform,typeof(LogicBaseLua))
			if luaBaseComp ~= nil then
				luaBaseComp.beKeepDepthValue = false
			end
            
       end)
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
	
	widgetTbl.bottom = child(widgetTbl.panel,"Anchor_Bottom")
	
	--找到三个动画结点
	for i = 1,3 do
		local animObj = child(widgetTbl.panel, "Anchor_Amination/shisanshui_shoot_"..tostring(i))
		if animObj ~= nil then
			table.insert(this.animationTabel, animObj)
			animObj.gameObject:SetActive(false)
		end
	end
	
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
	--[[--提示按钮
    widgetTbl.btn_waring = child(widgetTbl.panel, "Anchor_TopRight/morePanel/bg/gameplay/")
	if widgetTbl.btn_waring~=nil then
       addClickCallbackSelf(widgetTbl.btn_waring.gameObject,OnBtn_WarningClick,this)
       widgetTbl.btn_waring.gameObject:SetActive(true)
    end--]]
    --更多面板
   --[[ widgetTbl.panel_more = child(widgetTbl.panel, "Anchor_TopRight/morePanel")
    if widgetTbl.panel_more~=nil then
       widgetTbl.panel_more.gameObject:SetActive(false)
    end--]]
    --更多面板蒙板
   --[[ widgetTbl.panel_moreContainer = child(widgetTbl.panel, "Anchor_TopRight/morePanel/bg/Container")
    if widgetTbl.panel_moreContainer~=nil then
       addClickCallbackSelf(widgetTbl.panel_moreContainer.gameObject,Onbtn_moreContainerClick,this)
   	end--]]

    --[[--设置按钮
     widgetTbl.setting = child(widgetTbl.panel, "Anchor_TopRight/morePanel/bg/setting")
    if widgetTbl.setting~=nil then
    	addClickCallbackSelf(widgetTbl.setting.gameObject,OnBtn_SettingOnClick,this)
       widgetTbl.setting.gameObject:SetActive(true)
    end
    --战绩按钮
      widgetTbl.result = child(widgetTbl.panel, "Anchor_TopRight/morePanel/bg/result")
    if widgetTbl.result~=nil then
    	addClickCallbackSelf(widgetTbl.result.gameObject,OnBtn_AchievementOnClick,this)
       widgetTbl.result.gameObject:SetActive(true)
    end--]]
    --准备按钮
	widgetTbl.btn_ready = child(widgetTbl.panel, "Anchor_Center/readyBtns/ready")
	if widgetTbl.btn_ready~=nil then
       addClickCallbackSelf(widgetTbl.btn_ready.gameObject,Onbtn_readyClick,this)
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
       chat_ui.Init(chatTextTab,chatImgTab)
    end
	
	--邀请按钮
	widgetTbl.btn_invite = child(widgetTbl.panel, "Anchor_Center/readyBtns/invite")
	if widgetTbl.btn_invite~=nil then
	   addClickCallbackSelf(widgetTbl.btn_invite.gameObject,Onbtn_inviteFriend,this)
	   widgetTbl.btn_invite.gameObject:SetActive(true)
	end	
	
	--解散按钮
	widgetTbl.btn_dismiss = child(widgetTbl.panel, "Anchor_Center/readyBtns/dismiss")
	if widgetTbl.btn_dismiss~=nil then
	   addClickCallbackSelf(widgetTbl.btn_dismiss.gameObject,Onbtn_dimissRoom,this)
	   widgetTbl.btn_dismiss.gameObject:SetActive(true)
	end	
	
	--复制按钮
	widgetTbl.btn_copy = child(widgetTbl.panel, "Anchor_TopLeft/gameCount/btn_Copy")
	if widgetTbl.btn_copy ~= nil then
		addClickCallbackSelf(widgetTbl.btn_copy.gameObject,this.Onbtn_CopyRoomNum,this)
	end	
	
	--wifi状态
    widgetTbl.sprite_network = componentGet(child(widgetTbl.panel,"Anchor_TopLeft/phoneInfo/network"),"UISprite")
    --电池状态
    widgetTbl.sprite_power = componentGet(child(widgetTbl.panel,"Anchor_TopLeft/phoneInfo/power"),"UISprite")
	--时间状态
	widgetTbl.lbl_time = componentGet(child(widgetTbl.panel,"Anchor_TopLeft/phoneInfo/timeLbl"),"UILabel")


    --房号
	widgetTbl.label_gameinfo = child(widgetTbl.panel, "Anchor_Bottom/gameInfo")
	if widgetTbl.label_gameinfo~=nil then
       widgetTbl.label_gameinfo.gameObject:SetActive(false)
    end
	
	--剩余牌提示
	widgetTbl.lbl_leftCard = child(widgetTbl.panel,"Anchor_TopRight/leftCardNum")
	if widgetTbl.lbl_leftCard ~= nil then
		widgetTbl.lbl_leftCard.gameObject:SetActive(false)
	end
	widgetTbl.leftCardNums = componentGet(widgetTbl.lbl_leftCard,"UILabel")

	--初始化语音信息
   	this.InitChatSound()
	
    widgetTbl.label_roomId = child(widgetTbl.panel, "Anchor_TopLeft/gameCount/roomId")
	if widgetTbl.label_roomId~=nil then
       widgetTbl.label_roomId.gameObject:SetActive(true)
    end
    --牌局信息
    widgetTbl.gameCount = child(widgetTbl.panel,"Anchor_TopLeft/gameCount/num")

   --[[ widgetTbl.rewards_panel = child(widgetTbl.panel,"Anchor_Center/rewards")
    if widgetTbl.rewards_panel~=nil then
    	this.FindChild_Rewards()
        widgetTbl.rewards_panel.gameObject:SetActive(false)
    end--]]

    widgetTbl.firstGroupScore = child(widgetTbl.panel,"Anchor_Bottom/firstScore")
    if widgetTbl.firstGroupScore ~= nil then
    	 widgetTbl.firstGroupScore.gameObject:SetActive(false)
    end
    widgetTbl.secondGroupScore = child(widgetTbl.panel,"Anchor_Bottom/secondScore")
    if widgetTbl.secondGroupScore ~= nil then
    	 widgetTbl.secondGroupScore.gameObject:SetActive(false)
    end
    widgetTbl.threeGroupScore = child(widgetTbl.panel,"Anchor_Bottom/threeScore")
    if widgetTbl.threeGroupScore ~= nil then
    	widgetTbl.threeGroupScore.gameObject:SetActive(false)
    end
     widgetTbl.allScore = child(widgetTbl.panel,"Anchor_Bottom/allScore")
    if widgetTbl.allScore ~= nil then
    	widgetTbl.allScore.gameObject:SetActive(false)
    end
	-----比分变动lbl
	widgetTbl.firstScoreChange = child(widgetTbl.panel,"Anchor_Bottom/firstScore/socreChange")
	widgetTbl.secondScoreChange = child(widgetTbl.panel,"Anchor_Bottom/secondScore/socreChange")
	widgetTbl.thirdScoreChange = child(widgetTbl.panel,"Anchor_Bottom/threeScore/socreChange")

	--特殊牌型图标
	widgetTbl.group = child(widgetTbl.panel,"Anchor_Center/special_card_type_group")
	if widgetTbl.group ~= nil then
		for i =1, 6 do
			local special_card_icon = child(widgetTbl.group,"special_card_type_"..i)
			special_card_type["special_card_type_"..tostring(i)] = special_card_icon
			special_card_type["special_card_type_"..tostring(i)].gameObject:SetActive(false)
			
		end
	end
	
	--自己的特殊牌型展示
	widgetTbl.special = child(widgetTbl.panel,"Anchor_Center/self_specialShow")
	if widgetTbl.special ~= nil then
		widgetTbl.special.specialType = child(widgetTbl.special,"specialCard")
		widgetTbl.special.gameObject:SetActive(false)
	end

	--理牌提示
	widgetTbl.readCardGroup = child(widgetTbl.panel,"Anchor_Center/read_card_group")
	if widgetTbl.readCardGroup~=nil then
		widgetTbl.readCardGroup.gameObject:SetActive(true)
		for i=1,6 do
			local tReadCard = child(widgetTbl.readCardGroup,"read_card"..i)
			read_card_player[tostring(i)] = tReadCard
			read_card_player["time"..tostring(i)]=nil
			tReadCard.gameObject:SetActive(false)
		end
	end

	--水庄倒计时
	widgetTbl.xiaopao_timePanel = child(widgetTbl.panel,"Anchor_Center/xiaopao_time")
	if widgetTbl.xiaopao_timePanel~=nil then
		widgetTbl.xiaopao_timePanel.gameObject:SetActive(false)
	end
	widgetTbl.xiaopao_time= componentGet(child(widgetTbl.xiaopao_timePanel,"time"),"UILabel")

	widgetTbl.ruleInfoPanel = child(widgetTbl.panel,"Anchor_RightBottom/roomInfo")
	if widgetTbl.ruleInfoPanel~=nil then
		widgetTbl.ruleInfoPanel.gameObject:SetActive(false)
	end


    --创建用户列表
    this.playerList = {}
	local roomData = room_data.GetSssRoomDataInfo()
	local peopleNum = roomData.people_num
	Trace("PeopleNum:"..tostring(peopleNum))

	--初始化聊天坐标信息
	local chatConfigString = "{\"2\":[{\"index\":1,\"x\":180,\"y\":160,\"z\":0},{\"index\":3,\"x\":110,\"y\":-150,\"z\":0}],\"3\":[{\"index\":1,\"x\":180,\"y\":160,\"z\":0},{\"index\":2,\"x\":-230,\"y\":0,\"z\":0},{\"index\":4,\"x\":245,\"y\":0,\"z\":0}],\"4\":[{\"index\":1,\"x\":180,\"y\":160,\"z\":0},{\"index\":2,\"x\":-230,\"y\":0,\"z\":0},{\"index\":2,\"x\":-220,\"y\":-95,\"z\":0},{\"index\":3,\"x\":160,\"y\":-145,\"z\":0}],\"5\":[{\"index\":1,\"x\":180,\"y\":160,\"z\":0},{\"index\":2,\"x\":-230,\"y\":0,\"z\":0},{\"index\":2,\"x\":-225,\"y\":-85,\"z\":0},{\"index\":3,\"x\":120,\"y\":-153,\"z\":0},{\"index\":3,\"x\":110,\"y\":-150,\"z\":0}],\"6\":[{\"index\":1,\"x\":180,\"y\":160,\"z\":0},{\"index\":2,\"x\":-230,\"y\":0,\"z\":0},{\"index\":2,\"x\":-230,\"y\":0,\"z\":0},{\"index\":3,\"x\":90,\"y\":-155,\"z\":0},{\"index\":3,\"x\":105,\"y\":-150,\"z\":0},{\"index\":4,\"x\":220,\"y\":-20,\"z\":0}]}"
	local chatSoundConfigString = "{\"2\":[{\"index\":1,\"x\":221.4,\"y\":175.8,\"z\":0},{\"index\":4,\"x\":152,\"y\":-90.1,\"z\":0}],\"3\":[{\"index\":1,\"x\":221.4,\"y\":175.8,\"z\":0},{\"index\":2,\"x\":35,\"y\":53,\"z\":0},{\"index\":3,\"x\":275,\"y\":53,\"z\":0}],\"4\":[{\"index\":1,\"x\":221.4,\"y\":175.8,\"z\":0},{\"index\":2,\"x\":31,\"y\":52,\"z\":0},{\"index\":2,\"x\":40,\"y\":-44,\"z\":0},{\"index\":4,\"x\":200,\"y\":-84,\"z\":0}],\"5\":[{\"index\":1,\"x\":221.4,\"y\":175.8,\"z\":0},{\"index\":2,\"x\":31,\"y\":53,\"z\":0},{\"index\":2,\"x\":39,\"y\":-30,\"z\":0},{\"index\":4,\"x\":-372,\"y\":-60,\"z\":0},{\"index\":4,\"x\":152,\"y\":-90.1,\"z\":0}],\"6\":[{\"index\":1,\"x\":221.4,\"y\":175.8,\"z\":0},{\"index\":2,\"x\":32,\"y\":55,\"z\":0},{\"index\":2,\"x\":32,\"y\":52,\"z\":0},{\"index\":4,\"x\":132,\"y\":-90.1,\"z\":0},{\"index\":4,\"x\":146,\"y\":-90.1,\"z\":0},{\"index\":3,\"x\":-401,\"y\":-296,\"z\":0}]}"
	local chatJson = ParseJsonStr(chatConfigString)
	local chatJsonItem = chatJson[tostring(peopleNum)]

	local chatSoundJson = ParseJsonStr(chatSoundConfigString)
	local chatSoundJsonItem = chatSoundJson[tostring(peopleNum)]

    for i=1,6 do
    	local playerTrans = child(widgetTbl.panel, "Anchor_Center/Players/Player"..i)
    	if playerTrans ~= nil then
			if i < tonumber(peopleNum) or i == tonumber(peopleNum) then
			local viewSeateConfig = config_data_center.getConfigDataByID("dataconfig_shisanshuitableconfig","id",tonumber(peopleNum))
			local position = viewSeateConfig["pos"..tostring(i)]
			local posjson = string.gsub(position,"\\/","/")  
			local seateJson = ParseJsonStr(posjson)
			Trace("LocalPosition frome configTable:"..tostring(seateJson))
			
			local x = seateJson["x"]
			local y = seateJson["y"]
			local z = 0
			
			local prepare_x = seateJson["prepare_x"]
			local prepare_y = seateJson["prepare_y"]
			
			
			playerTrans.localPosition = Vector3(x,y,z)
			local playerComponent = shisanshui_player_ui.New(playerTrans)
			playerComponent.SetReadyLocalPosition(prepare_x,prepare_y)

			--设置聊天坐标信息
			local chatJsonItemLast = chatJsonItem[i]
			local tChatIndex = chatJsonItemLast.index
			local tChatPosX = chatJsonItemLast.x
			local tChatPosY = chatJsonItemLast.y
			playerComponent.SetChatTextLocalPosition(tChatIndex,tChatPosX,tChatPosY)

			--设置语音聊天坐标信息
			local chatSoundJsonItemLast = chatSoundJsonItem[i]
			local tChatSoundIndex = chatSoundJsonItemLast.index
			local tChatSoundPosX = chatSoundJsonItemLast.x
			local tChatSoundPosY = chatSoundJsonItemLast.y
			playerComponent.SetChatSoundLocalPosition(tChatSoundIndex,tChatSoundPosX,tChatSoundPosY)
    		table.insert(this.playerList, playerComponent)
		end
    		playerTrans.gameObject:SetActive(false)
    	end
    end
	
	----设置互动表情位置
	local posTbl = config_mgr.getConfig("cfg_ssspos",peopleNum)
	for i=1,peopleNum do
		local playerTrans = child(widgetTbl.panel, "Anchor_Center/Players/Player"..i)
		--this.SetInteractionPos(i,posTbl["pos"][i])
		this.InitInteractionView(playerTrans.gameObject,posTbl["pos"][i])
	end
    
    --赖子
	compTbl.laizi = child(widgetTbl.panel, "Anchor_TopLeft/lai")
	if compTbl.laizi~=nil then
       compTbl.laizi.gameObject:SetActive(false)
    end
		
		
	    --倍数
    compTbl.xiapao = child(widgetTbl.panel, "Anchor_Center/xiapao")
	if compTbl.xiapao~=nil then
		for i=1,5 do
			local btn_xiapao = child(compTbl.xiapao, "pao"..i)
			addClickCallbackSelf(btn_xiapao.gameObject,

			function ()
				ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/anjianxuanze")  ---按键声音
				shisangshui_play_sys.beishu(i)
				shisangshui_ui.SetXiaoPao(0)
				this.IsShowBeiShuiBtn(false)
			end,
			this)
			
		end
       compTbl.xiapao.gameObject:SetActive(false)
    end
	
	--重连未准备解散倒计时
	widgetTbl.dismiss_timePanel = child(widgetTbl.panel,"Anchor_Center/readyBtns/timeleftlbl")
	if widgetTbl.dismiss_timePanel ~= nil then
		widgetTbl.dismiss_timePanel.gameObject:SetActive(false)
	end
	widgetTbl.dismiss_timelbl = componentGet(widgetTbl.dismiss_timePanel,"UILabel")

	this.InitMoreBtnsView()


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
	end
	end, 0.1, 1)
	delayTimer:Start()

end
	

local function Onbtn_rewardsBackClick()
	this.HideRewards()
	this.ShowReadyBtn()
end


--[[function this.FindChild_Rewards()
	widgetTbl.rewards_back = child(widgetTbl.rewards_panel,"back")
	if widgetTbl.rewards_back~=nil then
       addClickCallbackSelf(widgetTbl.rewards_back.gameObject, Onbtn_rewardsBackClick, this)
    end
	--准备
	widgetTbl.rewards_ready = child(widgetTbl.rewards_panel,"ready")
	if widgetTbl.rewards_ready~=nil then
       addClickCallbackSelf(widgetTbl.rewards_ready.gameObject, Onbtn_readyClick, this)
    end
    widgetTbl.rewards_splayers = {}
    for i=1,4 do
    	local p = {}
    	p.rewards_player = child(widgetTbl.rewards_panel,"small/player"..i)
    	p.rewards_player_name = child(p.rewards_player,"name")
    	p.rewards_player_point = child(p.rewards_player,"point")
    	p.rewards_player_head = child(p.rewards_player,"head_bg/head_bg2/head")
    	p.rewards_player_vip = child(p.rewards_player_head,"vip")
    	p.rewards_player_vip.gameObject:SetActive(false)
    	p.rewards_player_zhuang = child(p.rewards_player_head,"zhuang")
    	p.rewards_player_zhuang.gameObject:SetActive(false)
    	table.insert(widgetTbl.rewards_splayers,p)
    end


    widgetTbl.rewards_bplayers = {}
    for i=1,1 do
    	local p = {}
    	p.rewards_player = child(widgetTbl.rewards_panel,"big/player"..i)
    	p.rewards_player_name = child(p.rewards_player,"name")
    	p.rewards_player_point = child(p.rewards_player,"point")
    	p.rewards_player_head = child(p.rewards_player,"head_bg/head_bg2/head")
    	p.rewards_player_vip = child(p.rewards_player_head,"vip")
    	p.rewards_player_vip.gameObject:SetActive(false)
    	p.rewards_player_zhuang = child(p.rewards_player_head,"zhuang")
    	p.rewards_player_zhuang.gameObject:SetActive(false)
    	p.rewards_player_itemEx = child(p.rewards_player,"itemEx")
    	p.rewards_player_itemEx.gameObject:SetActive(false)
    	p.rewards_player_scrollView = child(p.rewards_player,"Scroll View")
    	p.rewards_player_grid = child(p.rewards_player,"Grid")
    	table.insert(widgetTbl.rewards_bplayers,p)
    end
end--]]

--复制房号点击事件
function this.Onbtn_CopyRoomNum(obj1,obj1)
	str = this.rno
	Trace("Onbtn_CopyRoomNum:"..tostring(str))
	YX_APIManage.Instance:onCopy(str,function()UI_Manager:Instance():FastTip(GetDictString(6043))end)
end

--设置剩余牌数量
function this.SetLeftCardNums(num)
	if num ~= nil then
		widgetTbl.lbl_leftCard.gameObject:SetActive(true)
		widgetTbl.leftCardNums.text = "剩余牌数："..tostring(num)
	else
		widgetTbl.lbl_leftCard.gameObject:SetActive(false)
	end
end

--监听电量及网络信号强度
-- function this.InitBatteryAndSignal()	
--     YX_APIManage.Instance.batteryCallBack = function(msg)
--     	local msgTable = ParseJsonStr(msg)
--     	local precent = tonumber(msgTable.percent)	
--     	Trace("battery:"..precent)	
-- 		this.SetPowerState(precent)
--     end

--     YX_APIManage.Instance.signalCallBack = function(msg)
--     	local msgTable = ParseJsonStr(msg)
--     	local precent = tonumber(msgTable.percent)	
--     	Trace("signal:"..precent)		
-- 		this.SetNetworkState(precent)
--     end

--     local battery = YX_APIManage.Instance:GetPhoneBattery() or 100
--     this.SetPowerState(tonumber(battery)/100)
-- end
function this.InitBatteryAndSignal()
	--监听电量及网络信号强度
    -- YX_APIManage.Instance.batteryCallBack = 
    YX_APIManage.Instance:setBatteryCallback(function(msg)
      local msgTable = ParseJsonStr(msg)
      local precent = tonumber(msgTable.percent)  or 0
      this.SetPowerState(precent/100.0)
    end)

    YX_APIManage.Instance.signalCallBack = function(msg)
    	local msgTable = ParseJsonStr(msg)
    	local precent = tonumber(msgTable.percent)	
    	Trace("signal:"..precent)		
		this.SetNetworkState(precent)
    end

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

--定时器每分钟刷新系统时间
function this.StartGetDateTimer()
	widgetTbl.lbl_time.text = tostring(os.date("%H:%M"))
	getDateTimer = Timer.New(this.OnGetDateTimer_Proc,60,-1)
	getDateTimer:Start()
end

function this.OnGetDateTimer_Proc()
	widgetTbl.lbl_time.text = tostring(os.date("%H:%M"))
end

--------重连未准备解散倒计时------------

function this.dismissLeftime(time)
	if(disTimer_Elapse == nil) then
		this.StartTimer_Dis(time)
	end
end

function this.StartTimer_Dis(time)
	Trace("未准备解散定时器")	
	if(time <= 0) then
		widgetTbl.dismiss_timePanel.gameObject:SetActive(false)
		return
	end
	widgetTbl.dismiss_timePanel.gameObject:SetActive(true)
	widgetTbl.dismiss_timelbl.text = (math.floor(time).."s后解散牌局")
	leftTime = time		
	disTimer_Elapse = Timer.New(this.OnTimer_Proc_Dis,1,time)
	disTimer_Elapse:Start()
end

function this.OnTimer_Proc_Dis()
	if(leftTime >= 1) then
		leftTime = leftTime -1;
	end
	widgetTbl.dismiss_timelbl.text = (math.floor(leftTime).."s后解散牌局")
	if leftTime <= 0 then
		widgetTbl.dismiss_timePanel.gameObject:SetActive(false)
		this.StopTime_Dis()
		return
	end
end

function this.StopTime_Dis()
	if disTimer_Elapse ~= nil then
		disTimer_Elapse:Stop()
		Trace("重连解散定时器关")
		disTimer_Elapse = nil
	end
	if(widgetTbl.dismiss_timePanel ~= nil) then
		widgetTbl.dismiss_timePanel.gameObject:SetActive(false)
	end
end


-------------------------------------


--[[--
 * @Description: 更多界面  
 ]]
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

function this.RegisterEvent()
	Notifier.regist(cmdName.MSG_VOICE_INFO, this.OnMsgVoiceInfoHandler)
	Notifier.regist(cmdName.MSG_VOICE_PLAY_BEGIN, this.OnMsgVoicePlayBegin)
	Notifier.regist(cmdName.MSG_VOICE_PLAY_END, this.OnMsgVoicePlayEnd)

	Notifier.regist(cmdName.MSG_CHAT_TEXT, this.OnMsgChatText)
  	Notifier.regist(cmdName.MSG_CHAT_IMAGA, this.OnMsgChatImaga)
  	Notifier.regist(cmdName.MSG_CHAT_INTERACTIN, this.OnMsgChatInteractin)
end
function this.UnRegisterEvent()
	Notifier.remove(cmdName.MSG_VOICE_INFO, this.OnMsgVoiceInfoHandler)
	Notifier.remove(cmdName.MSG_VOICE_PLAY_BEGIN, this.OnMsgVoicePlayBegin)
	Notifier.remove(cmdName.MSG_VOICE_PLAY_END, this.OnMsgVoicePlayEnd)

	Notifier.remove(cmdName.MSG_CHAT_TEXT, this.OnMsgChatText)
  	Notifier.remove(cmdName.MSG_CHAT_IMAGA, this.OnMsgChatImaga)
  	Notifier.remove(cmdName.MSG_CHAT_INTERACTIN, this.OnMsgChatInteractin)
end

function this.Awake()
	this.RegisterEvent()
	this:RegistUSRelation()
	InitWidgets()
	InitVoteView()
	this.InitSettingBgm()
	this.StartGetDateTimer()
--	shisangshui_ui_sys.Init()
	msg_dispatch_mgr.SetIsEnterState(true)	
end

function this.Start()
	this.InitBatteryAndSignal()
	gameDataInfo = room_data.GetSssRoomDataInfo()
	if gameDataInfo.isChip then
		child(this.transform, "Panel/Anchor_TopRight/mapai").gameObject:SetActive(true)
	else
		child(this.transform, "Panel/Anchor_TopRight/mapai").gameObject:SetActive(false)
	end

	if(not gvoice_sys.GetIsInit()) then
		Trace("Init Again--------------------------")
		--gvoice_sys.GVoiceInit()   --语音服务初始化		
	end
	gvoice_engine = gvoice_sys.GetEngine()
end

--[[
语音回调检测
]]
function this.Update()
    if(gvoice_engine ~= nil) then
		gvoice_engine:Poll()
	end
end

function this.OnDestroy()
	this.UnInitBatteryAndSignal()
	this.playerList = {}
	widgetTbl = {}
	compTbl = {}	
	special_card_type = {}
--	shisangshui_ui_sys.UInit()
	this.animationTabel = {}

	this.LimitRecodeSoundHide()
	this.UnRegisterEvent()
	gvoice_sys.Uinit()
	chat_ui.Clear()
	if(disTimer_Elapse ~= nil) then
		this.StopTime_Dis()  ----重连解散定时器关
	end
	if getDateTimer ~= nil then
		getDateTimer:Stop()
		getDateTimer = nil
	end
end

--æ˜¾ç¤ºå‡†å¤‡æŒ‰é’®
function  this.ShowReadyBtn()
	widgetTbl.btn_ready.gameObject:SetActive(true)
end

--éšè—å‡†å¤‡æŒ‰é’®
function  this.HideReadyBtn()
	widgetTbl.btn_ready.gameObject:SetActive(false)
end

--[[--
 * @Description: è®¾ç½®çŽ©æ³•ã€æˆ¿å·  
 * @param:       wanfaStr çŽ©æ³•  RoomNum æˆ¿å·
 * @return:      nil
 ]]
function  this.SetGameInfo(wanfaStr,RoomNum)
	local str = wanfaStr..RoomNum
	this.rno = RoomNum
	local configStr = {}
	local configData = room_data.GetSssRoomDataInfo()
	--Trace(tostring(configData.add_ghost))
	--Trace(tostring(json.encode(t)))
	if configData.isZhuang  == true or configData.isZhuang == 1 then
		if tonumber(configData.add_card) == 1 then
			table.insert(configStr,"加一色坐庄")
		end
	else
		-- if tonumber(configData.add_card) == 0 then
		-- 	table.insert(configStr,"不加色")
		-- elseif tonumber(configData.add_card) == 1 then
		-- 	table.insert(configStr,"加一色")
		-- elseif tonumber(configData.add_card) == 2 then
		-- 	table.insert(configStr,"加二色")
		-- end
	end
--	    0x4F,   --小鬼  79
--    0x5F,   --大鬼	95
	if configData.add_ghost == 0 then
		
	elseif configData.add_ghost == 1 then
		table.insert(configStr,"大小鬼")
	end
	
	if configData.isChip == true or configData.isChip == 1 then
		table.insert(configStr,"有马牌")
	else
		table.insert(configStr,"无马牌")
	end
		
	if configData.isZhuang == true or configData.isZhuang == 1 then
		--table.insert(configStr,"闲家倍数:"..tostring(configData.max_multiple))
	end
	this.SetRoomInfo(configStr)
	
	local label_roomId_comp = widgetTbl.label_roomId.gameObject:GetComponent(typeof(UILabel))
	label_roomId_comp.text = str
end

function this.SetGameCount()
	if widgetTbl.gameCount_comp == nil then
		widgetTbl.gameCount_comp = widgetTbl.gameCount.gameObject:GetComponent(typeof(UILabel))
	end

	widgetTbl.gameCount_comp.text = "局数: "..tostring(room_data.GetSssRoomDataInfo().cur_playNum).."/"..tostring(room_data.GetSssRoomDataInfo().play_num)
	Trace("当前局数:"..tostring(room_data.GetSssRoomDataInfo().cur_playNum))
end

--设置用户信息
function this.SetPlayerInfo(viewSeat, usersdata)
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].Show(usersdata,viewSeat)
	end
end

--[[
隐藏语音消息显示
]]
function this.HideVoiceLogo()
	
end

local _xiaopaoTime = 0
local xiaopaoTimer_Elapse = nil
local xiaopaoCallBack = nil
--设置水庄倒计时
function this.SetXiaoPao(time,callback)
	if time==nil or time<=0 then
		this.ShowXiaoPaoPanel(false)
	elseif (xiaopaoTimer_Elapse == nil) then
		this.StartXiaoPaoTimer(time)
		xiaopaoCallBack = callback
	end
end

function this.StartXiaoPaoTimer(time)
	this.ShowXiaoPaoPanel(true)
	_xiaopaoTime =math.floor(time)	
	this.SetXiaoPaoLabel(_xiaopaoTime)	
	xiaopaoTimer_Elapse = Timer.New(this.OnXiaopaoTimer_Proc,1,time)
	xiaopaoTimer_Elapse:Start()
end

function this.OnXiaopaoTimer_Proc()
	_xiaopaoTime = _xiaopaoTime -1;
	this.SetXiaoPaoLabel(_xiaopaoTime)
	if _xiaopaoTime <= 0 then
		this.StopXiaopaoTimer()
		this.ShowXiaoPaoPanel(false)
		--时间到了处理逻辑
		if xiaopaoCallBack ~=nil then
			xiaopaoCallBack()
		end
	end
end

function this.StopXiaopaoTimer()
	if xiaopaoTimer_Elapse ~= nil then
		xiaopaoTimer_Elapse:Stop()
		xiaopaoTimer_Elapse = nil
	end
end

function this.SetXiaoPaoLabel(time)
	if  widgetTbl.xiaopao_time ~= nil then 
		widgetTbl.xiaopao_time.text = "等待闲家选择倍数：" .. tostring(time) .."s"
	else
		Trace("widgetTbl.xiaopao_time = nil")
		this.StopXiaopaoTimer()
	end
end

function this.ShowXiaoPaoPanel(state)
	widgetTbl.xiaopao_timePanel.gameObject:SetActive(state)
end

--设置左上角游戏信息规则
function this.SetRoomInfoState(state)
	widgetTbl.ruleInfoPanel.gameObject:SetActive(state)
end

function this.SetRoomInfo(tbl)
	if tbl == nil then
		this.SetRoomInfoState(false)
	else
		this.SetRoomInfoState(true)
		for i=1,3 do
			local tra = child(widgetTbl.ruleInfoPanel,tostring(i))
			if i <= (#tbl) then
				tra.gameObject:SetActive(true)
				local infoTra = child(tra,"info")
				infoTra.gameObject:SetActive(false)
				componentGet(infoTra,"UILabel").text = tbl[i]
				infoTra.gameObject:SetActive(true)
			else
				tra.gameObject:SetActive(false)
			end
		end
		--componentGet(widgetTbl.ruleInfoPanel,"UITable"):Reposition()
		componentGet(widgetTbl.ruleInfoPanel,"UITable").repositionNow = true
	end	
end

--éšè—çŽ©å®¶ä¿¡æ¯
function this.HidePlayer(viewSeat)
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].Hide()
	end
end

function this.ShowPlayerTotalPoints(viewSeat,totalPoint)
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].SetTotalPoints(totalPoint)
	end
end

function this.IsShowBeiShuiBtn(isShow)
	compTbl.xiapao.gameObject:SetActive(isShow)
end

function this.ShowInviteBtn(isShow)
	if widgetTbl.btn_invite ~= nil then
		widgetTbl.btn_invite.gameObject:SetActive(isShow)
	end
end

function this.ShowDissolveRoom(isShow)
	widgetTbl.btn_dismiss.gameObject:SetActive(isShow)
end

--复制房号按钮
function this.SetCopyRnoVisible(isShow)
	widgetTbl.btn_copy.gameObject:SetActive(isShow)
end

--è®¾ç½®æ‰˜ç®¡çŠ¶æ€
function this.SetPlayerMachine(viewSeat, isMachine )
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].SetMachine(isMachine)
	end
end

--è®¾ç½®çŽ©å®¶åœ¨çº¿çŠ¶æ€
function this.SetPlayerLineState(viewSeat, isOnLine )
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].SetOffline(not isOnLine)
	end
end

function this.SetHideTotaPoints()
	for i,v in ipairs(this.playerList) do
		v.HideTotalPoints()
	end
end

--æ›´æ–°çŽ©å®¶é‡‘å¸
function this.SetPlayerScore(viewSeat,value)
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].SetScore(value)
	end
end

function this.AddPlayerScore(viewSeat,value)
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].AddScore(value)
	end
end



--è®¾ç½®çŽ©å®¶å‡†å¤‡çŠ¶æ€
function this.SetPlayerReady( viewSeat,isReady )
	Trace("viewSeat-------------------------------------"..tostring(viewSeat))
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].SetReady(isReady)
	end
end

function this.SetAllPlayerReady(isReady)
	for i,v in ipairs(this.playerList) do
		v.SetReady(isReady)
	end
end


--设置头像的光圈
this.lightFrameObj = nil
function this.SetPlayerLightFrame(viewSeat)
	if this.lightFrameObj ~= nil then
		animations_sys.StopPlayAnimation(this.lightFrameObj)
	end
	local Player = this.playerList[viewSeat]
	if Player ~= nil then
		if this.playerList[viewSeat].transform == nil then 
			Trace("+++++++++AnimationError!!!!!!!")
		end
		Trace("当前桌面对应的座位号"..tostring(Player.viewSeat).."transformName"..tostring(Player.transform.name))
		this.lightFrameObj = animations_sys.PlayAnimationWithLoop(child(Player.transform,"winFrame"),data_center.GetResRootPath().."/effects/shisanshui_icon_frame","flame",112,75)
		componentGet(this.lightFrameObj.gameObject,"SkeletonAnimation"):ChangeQueue(3001)
	end
end

function this.DisablePlayerLightFrame()
	if this.lightFrameObj ~= nil then
		animations_sys.StopPlayAnimation(this.lightFrameObj)
	end
end

--[[比分变动lbl
	widgetTbl.firstScoreChange = child(widgetTbl.panel,"Anchor_Bottom/firstScore/socreChange")
	widgetTbl.secondScoreChange = child(widgetTbl.panel,"Anchor_Bottom/secondScore/socreChange")
	widgetTbl.thirdScoreChange = child(widgetTbl.panel,"Anchor_Bottom/threeScore/socreChange")
]]
------比牌各墩分数

function this.SetGruopScord(index, score ,scoreExt, scoreChange,allScore)
	local  str = ""
	scoreTran.labelWidget1  = child(widgetTbl.firstGroupScore,"Label")
	scoreTran.neglabelWidget1  = child(widgetTbl.firstGroupScore,"negLabel")
	
	scoreTran.labelWidget2  = child(widgetTbl.secondGroupScore,"Label")
	scoreTran.neglabelWidget2  = child(widgetTbl.secondGroupScore,"negLabel")
	
	scoreTran.labelWidget3  = child(widgetTbl.threeGroupScore,"Label")
	scoreTran.neglabelWidget3  = child(widgetTbl.threeGroupScore,"negLabel")
	
	--scoreTran.labelWidget4  = child(widgetTbl.allScore,"Label")
	--scoreTran.neglabelWidget4  = child(widgetTbl.allScore,"negLabel")
	--比分变动
	scoreTran.firstAddLbl = child(widgetTbl.firstScoreChange,"lblAdd")
	scoreTran.firstReduceLbl = child(widgetTbl.firstScoreChange,"lblReduce")
	
	scoreTran.secondAddLbl = child(widgetTbl.secondScoreChange,"lblAdd")
	scoreTran.secondReduceLbl = child(widgetTbl.secondScoreChange,"lblReduce")
	
	scoreTran.thirdAddLbl = child(widgetTbl.thirdScoreChange,"lblAdd")
	scoreTran.thirdReduceLbl = child(widgetTbl.thirdScoreChange,"lblReduce")
	

	if tonumber(index) == 1 then	
		----头墩分数
		if(score+scoreExt <= 0)	then
			str = tostring(score+scoreExt)
			scoreTran.neglabelWidget1.gameObject:SetActive(true)
			scoreTran.labelWidget1.gameObject:SetActive(false)
			local label = componentGet(scoreTran.neglabelWidget1,"UILabel")
			label.text = str
			widgetTbl.firstGroupScore.gameObject:SetActive(true)
		else
			str = "+"..tostring(score+scoreExt)
			scoreTran.labelWidget1.gameObject:SetActive(true)
			scoreTran.neglabelWidget1.gameObject:SetActive(false)
			local label = componentGet(scoreTran.labelWidget1,"UILabel")
			label.text = str
			widgetTbl.firstGroupScore.gameObject:SetActive(true)
		end
		if scoreChange~=nil then
			if  scoreChange <= 0 then
				scoreTran.firstAddLbl.gameObject:SetActive(false)
				scoreTran.firstReduceLbl.gameObject:SetActive(true)
				componentGet(scoreTran.firstReduceLbl,"UILabel").text = tostring(scoreChange)	
				componentGet(scoreTran.firstReduceLbl,"TweenPosition"):ResetToBeginning ()
				componentGet(scoreTran.firstReduceLbl,"TweenPosition").enabled =true
				componentGet(scoreTran.firstReduceLbl,"TweenAlpha"):ResetToBeginning ()
				componentGet(scoreTran.firstReduceLbl,"TweenAlpha").enabled =true
				addTweenFinishedCallback(scoreTran.firstReduceLbl, "", function ()
					scoreTran.firstReduceLbl.gameObject:SetActive(false)
				end ,self)
			else
				scoreTran.firstAddLbl.gameObject:SetActive(true)
				scoreTran.firstReduceLbl.gameObject:SetActive(false)
				componentGet(scoreTran.firstAddLbl,"UILabel").text = "+"..tostring(scoreChange)		
				componentGet(scoreTran.firstAddLbl,"TweenPosition"):ResetToBeginning ()
				componentGet(scoreTran.firstAddLbl,"TweenPosition").enabled =true
				componentGet(scoreTran.firstAddLbl,"TweenAlpha"):ResetToBeginning ()
				componentGet(scoreTran.firstAddLbl,"TweenAlpha").enabled =true
				addTweenFinishedCallback(scoreTran.firstAddLbl, "", function ()
					scoreTran.firstAddLbl.gameObject:SetActive(false)
				end ,self)
			end
		end
		
	elseif tonumber(index) == 2 then
		----中墩分数
		if(score+scoreExt <= 0)	then
			str = tostring(score+scoreExt)
			scoreTran.neglabelWidget2.gameObject:SetActive(true)
			scoreTran.labelWidget2.gameObject:SetActive(false)
			local label = componentGet(scoreTran.neglabelWidget2,"UILabel")
			label.text = str
			widgetTbl.secondGroupScore.gameObject:SetActive(true)
		else
			str = "+"..tostring(score+scoreExt)
			scoreTran.labelWidget2.gameObject:SetActive(true)
			scoreTran.neglabelWidget2.gameObject:SetActive(false)
			local label = componentGet(scoreTran.labelWidget2,"UILabel")
			label.text = str
			widgetTbl.secondGroupScore.gameObject:SetActive(true)
		end	
		if scoreChange~=nil then
			if  scoreChange <= 0 then
				scoreTran.secondAddLbl.gameObject:SetActive(false)
				scoreTran.secondReduceLbl.gameObject:SetActive(true)
				componentGet(scoreTran.secondReduceLbl,"UILabel").text = tostring(scoreChange)
				componentGet(scoreTran.secondReduceLbl,"TweenPosition"):ResetToBeginning ()
				componentGet(scoreTran.secondReduceLbl,"TweenPosition").enabled =true
				componentGet(scoreTran.secondReduceLbl,"TweenAlpha"):ResetToBeginning ()
				componentGet(scoreTran.secondReduceLbl,"TweenAlpha").enabled =true
				addTweenFinishedCallback(scoreTran.secondReduceLbl, "", function ()
					scoreTran.secondReduceLbl.gameObject:SetActive(false)
				end ,self)
			else
				scoreTran.secondAddLbl.gameObject:SetActive(true)
				scoreTran.secondReduceLbl.gameObject:SetActive(false)
				componentGet(scoreTran.secondAddLbl,"UILabel").text = "+"..tostring(scoreChange)
				componentGet(scoreTran.secondAddLbl,"TweenPosition"):ResetToBeginning ()
				componentGet(scoreTran.secondAddLbl,"TweenPosition").enabled =true
				componentGet(scoreTran.secondAddLbl,"TweenAlpha"):ResetToBeginning ()
				componentGet(scoreTran.secondAddLbl,"TweenAlpha").enabled =true
				addTweenFinishedCallback(scoreTran.secondAddLbl, "", function ()
					scoreTran.secondAddLbl.gameObject:SetActive(false)
				end ,self)
			end
		end
	
	elseif tonumber(index) == 3 then
		----尾墩分数
		if(score+scoreExt <= 0)	then
			str = tostring(score+scoreExt)
			scoreTran.neglabelWidget3.gameObject:SetActive(true)
			scoreTran.labelWidget3.gameObject:SetActive(false)
			local label = componentGet(scoreTran.neglabelWidget3,"UILabel")
			label.text = str
			widgetTbl.threeGroupScore.gameObject:SetActive(true)
		else
			str = "+"..tostring(score+scoreExt)
			scoreTran.labelWidget3.gameObject:SetActive(true)
			scoreTran.neglabelWidget3.gameObject:SetActive(false)
			local label = componentGet(scoreTran.labelWidget3,"UILabel")
			label.text = str
			widgetTbl.threeGroupScore.gameObject:SetActive(true)
		end
		if scoreChange~=nil then
			if scoreChange <= 0 then
				scoreTran.thirdAddLbl.gameObject:SetActive(false)
				scoreTran.thirdReduceLbl.gameObject:SetActive(true)
				componentGet(scoreTran.thirdReduceLbl,"UILabel").text = tostring(scoreChange)
				componentGet(scoreTran.thirdReduceLbl,"TweenPosition"):ResetToBeginning ()
				componentGet(scoreTran.thirdReduceLbl,"TweenPosition").enabled =true
				componentGet(scoreTran.thirdReduceLbl,"TweenAlpha"):ResetToBeginning ()
				componentGet(scoreTran.thirdReduceLbl,"TweenAlpha").enabled =true
				addTweenFinishedCallback(scoreTran.thirdReduceLbl, "", function ()
					scoreTran.thirdReduceLbl.gameObject:SetActive(false)
				end ,self)
			else
				scoreTran.thirdAddLbl.gameObject:SetActive(true)
				scoreTran.thirdReduceLbl.gameObject:SetActive(false)
				componentGet(scoreTran.thirdAddLbl,"UILabel").text = "+"..tostring(scoreChange)	
				componentGet(scoreTran.thirdAddLbl,"TweenPosition"):ResetToBeginning ()
				componentGet(scoreTran.thirdAddLbl,"TweenPosition").enabled =true
				componentGet(scoreTran.thirdAddLbl,"TweenAlpha"):ResetToBeginning ()
				componentGet(scoreTran.thirdAddLbl,"TweenAlpha").enabled =true
				addTweenFinishedCallback(scoreTran.thirdAddLbl, "", function ()
					scoreTran.thirdAddLbl.gameObject:SetActive(false)
				end ,self)
			end
		end
		
	--[[elseif tonumber(index) == 4 then
		----总分
		if(allScore <= 0)	then
			str = tostring(allScore)
			neglabelWidget4.gameObject:SetActive(true)
			labelWidget4.gameObject:SetActive(false)
			local label = componentGet(neglabelWidget4,"UILabel")
			label.text = str
			widgetTbl.allScore.gameObject:SetActive(true)
		else
			str = "+"..tostring(allScore)
			labelWidget4.gameObject:SetActive(true)
			neglabelWidget4.gameObject:SetActive(false)
			local label = componentGet(labelWidget4,"UILabel")
			label.text = str
			widgetTbl.allScore.gameObject:SetActive(true)
		end--]]
		
	elseif tonumber(index) == 0 then		--设置初始零分
		scoreTran.neglabelWidget1.gameObject:SetActive(true)
		scoreTran.labelWidget1.gameObject:SetActive(false)
		scoreTran.neglabelWidget2.gameObject:SetActive(true)
		scoreTran.labelWidget2.gameObject:SetActive(false)
		scoreTran.neglabelWidget3.gameObject:SetActive(true)
		scoreTran.labelWidget3.gameObject:SetActive(false)
		componentGet(scoreTran.neglabelWidget1,"UILabel").text = tostring(0)
		componentGet(scoreTran.neglabelWidget2,"UILabel").text = tostring(0)
		componentGet(scoreTran.neglabelWidget3,"UILabel").text = tostring(0)
		widgetTbl.firstGroupScore.gameObject:SetActive(true)
		widgetTbl.secondGroupScore.gameObject:SetActive(true)
		widgetTbl.threeGroupScore.gameObject:SetActive(true)
	end
end

--设置三墩比分lbl位置以适配不同机型
function this.SetScoreAdaptPos(tbl)
	--logError(GetTblData(tbl))
	
	local offsetPos = widgetTbl.bottom.localPosition
	if(widgetTbl.firstGroupScore ~= nil)then
		widgetTbl.firstGroupScore.localPosition = Vector3(tbl[1].x-offsetPos.x+180,tbl[1].y-offsetPos.y,0)
	end
	if(widgetTbl.secondGroupScore ~= nil)then
		widgetTbl.secondGroupScore.localPosition = Vector3(tbl[2].x-offsetPos.x+180,tbl[2].y-offsetPos.y,0)
	end
	if(widgetTbl.threeGroupScore ~= nil)then
		widgetTbl.threeGroupScore.localPosition = Vector3(tbl[3].x-offsetPos.x+180,tbl[3].y-offsetPos.y,0)
	end
end

function this.SetShootScoreChange(tbl)
	local  str = ""
	scoreTran.labelWidget1  = child(widgetTbl.firstGroupScore,"Label")
	scoreTran.neglabelWidget1  = child(widgetTbl.firstGroupScore,"negLabel")
	
	scoreTran.labelWidget2  = child(widgetTbl.secondGroupScore,"Label")
	scoreTran.neglabelWidget2  = child(widgetTbl.secondGroupScore,"negLabel")
	
	scoreTran.labelWidget3  = child(widgetTbl.threeGroupScore,"Label")
	scoreTran.neglabelWidget3  = child(widgetTbl.threeGroupScore,"negLabel")
	
	--scoreTran.labelWidget4  = child(widgetTbl.allScore,"Label")
	--scoreTran.neglabelWidget4  = child(widgetTbl.allScore,"negLabel")
	--比分变动
	scoreTran.firstAddLbl = child(widgetTbl.firstScoreChange,"lblAdd")
	scoreTran.firstReduceLbl = child(widgetTbl.firstScoreChange,"lblReduce")
	
	scoreTran.secondAddLbl = child(widgetTbl.secondScoreChange,"lblAdd")
	scoreTran.secondReduceLbl = child(widgetTbl.secondScoreChange,"lblReduce")
	
	scoreTran.thirdAddLbl = child(widgetTbl.thirdScoreChange,"lblAdd")
	scoreTran.thirdReduceLbl = child(widgetTbl.thirdScoreChange,"lblReduce")
	
	local score = {}
	score[1] = tbl.firstSoreChange
	score[2] = tbl.secondSoreChange
	score[3] = tbl.thirdSoreChange
	this.firstGroupScore = tbl.firstGroupScore
	this.secondGroupScore = tbl.secondGroupScore
	this.threeGroupScore = tbl.threeGroupScore

	----头墩分数
	if score[1]~=nil then
		if  score[1] <= 0 then
			scoreTran.firstAddLbl.gameObject:SetActive(false)
			scoreTran.firstReduceLbl.gameObject:SetActive(true)
			componentGet(scoreTran.firstReduceLbl,"UILabel").text = tostring(score[1])	
			componentGet(scoreTran.firstReduceLbl,"TweenPosition"):ResetToBeginning ()
			componentGet(scoreTran.firstReduceLbl,"TweenPosition").enabled =true
			componentGet(scoreTran.firstReduceLbl,"TweenAlpha"):ResetToBeginning ()
			componentGet(scoreTran.firstReduceLbl,"TweenAlpha").enabled =true
			addTweenFinishedCallback(scoreTran.firstReduceLbl, "", function ()
				scoreTran.firstReduceLbl.gameObject:SetActive(false)
			end ,self)
		else
			scoreTran.firstAddLbl.gameObject:SetActive(true)
			scoreTran.firstReduceLbl.gameObject:SetActive(false)
			componentGet(scoreTran.firstAddLbl,"UILabel").text = "+"..tostring(score[1])		
			componentGet(scoreTran.firstAddLbl,"TweenPosition"):ResetToBeginning ()
			componentGet(scoreTran.firstAddLbl,"TweenPosition").enabled =true
			componentGet(scoreTran.firstAddLbl,"TweenAlpha"):ResetToBeginning ()
			componentGet(scoreTran.firstAddLbl,"TweenAlpha").enabled =true
			addTweenFinishedCallback(scoreTran.firstAddLbl, "", function ()
				scoreTran.firstAddLbl.gameObject:SetActive(false)
			end ,self)
		end
	end
	if(this.firstGroupScore <= 0)	then
		str = tostring(this.firstGroupScore)
		scoreTran.neglabelWidget1.gameObject:SetActive(true)
		scoreTran.labelWidget1.gameObject:SetActive(false)
		local label = componentGet(scoreTran.neglabelWidget1,"UILabel")
		label.text = str
		widgetTbl.firstGroupScore.gameObject:SetActive(true)
	else
		str = "+"..tostring(this.firstGroupScore)
		scoreTran.labelWidget1.gameObject:SetActive(true)
		scoreTran.neglabelWidget1.gameObject:SetActive(false)
		local label = componentGet(scoreTran.labelWidget1,"UILabel")
		label.text = str
		widgetTbl.firstGroupScore.gameObject:SetActive(true)
	end
	
	----中墩分数
	if score[2]~=nil then
		if  score[2] <= 0 then
			scoreTran.secondAddLbl.gameObject:SetActive(false)
			scoreTran.secondReduceLbl.gameObject:SetActive(true)
			componentGet(scoreTran.secondReduceLbl,"UILabel").text = tostring(score[2])
			componentGet(scoreTran.secondReduceLbl,"TweenPosition"):ResetToBeginning ()
			componentGet(scoreTran.secondReduceLbl,"TweenPosition").enabled =true
			componentGet(scoreTran.secondReduceLbl,"TweenAlpha"):ResetToBeginning ()
			componentGet(scoreTran.secondReduceLbl,"TweenAlpha").enabled =true
			addTweenFinishedCallback(scoreTran.secondReduceLbl, "", function ()
				scoreTran.secondReduceLbl.gameObject:SetActive(false)
			end ,self)
		else
			scoreTran.secondAddLbl.gameObject:SetActive(true)
			scoreTran.secondReduceLbl.gameObject:SetActive(false)
			componentGet(scoreTran.secondAddLbl,"UILabel").text = "+"..tostring(score[2])
			componentGet(scoreTran.secondAddLbl,"TweenPosition"):ResetToBeginning ()
			componentGet(scoreTran.secondAddLbl,"TweenPosition").enabled =true
			componentGet(scoreTran.secondAddLbl,"TweenAlpha"):ResetToBeginning ()
			componentGet(scoreTran.secondAddLbl,"TweenAlpha").enabled =true
			addTweenFinishedCallback(scoreTran.secondAddLbl, "", function ()
				scoreTran.secondAddLbl.gameObject:SetActive(false)
			end ,self)
		end
	end
	if(this.secondGroupScore <= 0)	then
		str = tostring(this.secondGroupScore)
		scoreTran.neglabelWidget2.gameObject:SetActive(true)
		scoreTran.labelWidget2.gameObject:SetActive(false)
		local label = componentGet(scoreTran.neglabelWidget2,"UILabel")
		label.text = str
		widgetTbl.secondGroupScore.gameObject:SetActive(true)
	else
		str = "+"..tostring(this.secondGroupScore)
		scoreTran.labelWidget2.gameObject:SetActive(true)
		scoreTran.neglabelWidget2.gameObject:SetActive(false)
		local label = componentGet(scoreTran.labelWidget2,"UILabel")
		label.text = str
		widgetTbl.secondGroupScore.gameObject:SetActive(true)
	end	

	----尾墩分数
	if score[3]~=nil then
		if score[3] <= 0 then
			scoreTran.thirdAddLbl.gameObject:SetActive(false)
			scoreTran.thirdReduceLbl.gameObject:SetActive(true)
			componentGet(scoreTran.thirdReduceLbl,"UILabel").text = tostring(score[3])
			componentGet(scoreTran.thirdReduceLbl,"TweenPosition"):ResetToBeginning ()
			componentGet(scoreTran.thirdReduceLbl,"TweenPosition").enabled =true
			componentGet(scoreTran.thirdReduceLbl,"TweenAlpha"):ResetToBeginning ()
			componentGet(scoreTran.thirdReduceLbl,"TweenAlpha").enabled =true
			addTweenFinishedCallback(scoreTran.thirdReduceLbl, "", function ()
				scoreTran.thirdReduceLbl.gameObject:SetActive(false)
			end ,self)
		else
			scoreTran.thirdAddLbl.gameObject:SetActive(true)
			scoreTran.thirdReduceLbl.gameObject:SetActive(false)
			componentGet(scoreTran.thirdAddLbl,"UILabel").text = "+"..tostring(score[3])	
			componentGet(scoreTran.thirdAddLbl,"TweenPosition"):ResetToBeginning ()
			componentGet(scoreTran.thirdAddLbl,"TweenPosition").enabled =true
			componentGet(scoreTran.thirdAddLbl,"TweenAlpha"):ResetToBeginning ()
			componentGet(scoreTran.thirdAddLbl,"TweenAlpha").enabled =true
			addTweenFinishedCallback(scoreTran.thirdAddLbl, "", function ()
				scoreTran.thirdAddLbl.gameObject:SetActive(false)
			end ,self)
		end
	end
	if(this.threeGroupScore <= 0)	then
		str = tostring(this.threeGroupScore)
		scoreTran.neglabelWidget3.gameObject:SetActive(true)
		scoreTran.labelWidget3.gameObject:SetActive(false)
		local label = componentGet(scoreTran.neglabelWidget3,"UILabel")
		label.text = str
		widgetTbl.threeGroupScore.gameObject:SetActive(true)
	else
		str = "+"..tostring(this.threeGroupScore)
		scoreTran.labelWidget3.gameObject:SetActive(true)
		scoreTran.neglabelWidget3.gameObject:SetActive(false)
		local label = componentGet(scoreTran.labelWidget3,"UILabel")
		label.text = str
		widgetTbl.threeGroupScore.gameObject:SetActive(true)
	end
end

--播放开始比牌的动画效果
function this.PlayerStartGameAnimation()
	animations_sys.PlayAnimation(this.gameObject.transform,data_center.GetResRootPath().."/effects/shisanshui_kaishibipai","kaishibipai",100,100,false,nil,1401)
	ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/dub/kaishibipai_nv")
end

--[[--
 * @Description: å®šåº„  
 * @param:       viewSeat è§†å›¾åº§ä½å· 
 * @return:      nil
 ]]
function this.SetBanker( viewSeat )
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].SetBanker(true)
	end
end

--é‡ç½®æ‰€æœ‰çŠ¶æ€ï¼Œç”¨äºŽæ¸¸æˆç»“æŸåŽ
function this.ResetAll()
	for i=1,#this.playerList do
		this.playerList[i].HideTotalPoints()
		if room_data.GetSssRoomDataInfo().isZhuang == false then
			this.playerList[i].SetBanker(false)
		end
		this.playerList[i].HideBeiShu()
	end
	this.ReSetReadCard(false)
	this.HideReadyBtn()
	this.HideScoreGroup()
	--this.HideRewards()
	this.HideSpecialCardIcon()
	this.HideSelfChooseSpecial()
	--this.voteView:Hide()
end

  function this.HideScoreGroup()
    	widgetTbl.firstGroupScore.gameObject:SetActive(false)
    	widgetTbl.secondGroupScore.gameObject:SetActive(false)
    	widgetTbl.threeGroupScore.gameObject:SetActive(false)
		widgetTbl.allScore.gameObject:SetActive(false)
   end

--设置互动表情面板位置
function this.InitInteractionView(go,tbl)
  this.InteractionView = require "logic/interaction/InteractionView":
  create(go,nil,tbl)
end

--更多面板
function this.InitMoreBtnsView()
  this.moreBtnsView = require "logic/mahjong_sys/ui_mahjong/views/MoreBtnsView":
  create(nil, this.moreContainerClickAnimation, subComponentGet(widgetTbl.panel, "Anchor_TopRight/more/Sprite", typeof(UIRect)))
  this.moreBtnsView:SetGo(child(widgetTbl.panel, "Anchor_TopRight/morePanel/bg").gameObject)
  this.moreBtnsView:SetActive(false)
end

--显示更多面板
function this.SetMorePanel()
  this.moreBtnsView:SetActive(not this.moreBtnsView.isActive)
end

function this.SetInteractionPos(index,tbl)
	local playerTrans = child(widgetTbl.panel, "Anchor_Center/Players/Player"..index)
	if playerTrans ~= nil then
		local actionTran = child(playerTrans,"bg/head/personalInfo")
		actionTran.localPosition = Vector3(tbl.x,tbl.y,tbl.z)
	end
end

--[[function this.HideRewards()
	widgetTbl.rewards_panel.gameObject:SetActive(false)
end--]]

--´òÇ¹
function this.GetShootTran( viewSeat )
	Trace("Shoot-------------------------------------"..tostring(viewSeat))
	if this.playerList[viewSeat] ~= nil then
		return this.playerList[viewSeat].ShootTran()
	end
end

function this.GetShootHoleTran(viewSeat, index)
	Trace("Shoot-------------------------------------"..tostring(viewSeat))
	if this.playerList[viewSeat] ~= nil then
		return this.playerList[viewSeat].ShootHoleTran(index)
	end
end


function this.InitSettingBgm()
	ui_sound_mgr.SceneLoadFinish() 
    ui_sound_mgr.PlayBgSound("hall_bgm")	
   -- ui_sound_mgr.controlValue(0.5)
   -- ui_sound_mgr.ControlCommonAudioValue(0.5)
end

--显示特殊牌型的图标
function this.ShowSpecialCardIcon(tbl)
	local iconImage = special_card_type["special_card_type_"..tbl.viewSeat]
	iconImage.gameObject.transform.localPosition = tbl.position
	iconImage.gameObject:SetActive(true)	
end

function this.HideSpecialCardIcon()
	for i =1 , 6 do
		special_card_type["special_card_type_"..i].gameObject:SetActive(false)
	end
end

--显示自己特殊牌型
function this.SetSelfChooseSpecial(tbl)
	widgetTbl.special.localPosition = Vector3(tbl.position.x,tbl.position.y - 100,tbl.position.z)
	if widgetTbl.special.specialType ~= nil then
		local SpeSprite = componentGet(widgetTbl.special.specialType, "UISprite")
		SpeSprite.spriteName = tbl["SpecialType"]
		widgetTbl.special.gameObject:SetActive(true)
	end
end

function this.HideSelfChooseSpecial()
	widgetTbl.special.gameObject:SetActive(false)
end

--设置理牌提示
function this.SetReadCardState(tbl)
	local viewSeat = tbl.viewSeat
	local state = tbl.state
	local postion = tbl.position
	if state == true then
		read_card_player[tostring(viewSeat)].transform.localPosition = postion
		read_card_player[tostring(viewSeat)].gameObject:SetActive(true)
		this.ReadCardStartTimer(state,viewSeat)
	else
		read_card_player[tostring(viewSeat)].gameObject:SetActive(false)
		this.ReadCardStartTimer(state,viewSeat)
	end
end

function this.SetReadCardByState(viewSeat,state,postion)
	if state == true then
		read_card_player[tostring(viewSeat)].transform.localPosition = postion
		read_card_player[tostring(viewSeat)].gameObject:SetActive(true)
		this.ReadCardStartTimer(state,viewSeat)
	else
		read_card_player[tostring(viewSeat)].gameObject:SetActive(false)
		this.ReadCardStartTimer(state,viewSeat)
	end
end

function this.ReSetReadCard(state)
	for i,v in pairs(read_card_player) do
		v.gameObject:SetActive(state)
	end
end


function this.ReadCardStartTimer(state,viewSeat)	
	ReadCardStopTimer()
	local index = 0
	if state == true then
		read_card_player["time"..tostring(viewSeat)].timer_Elapse = Timer.New(function()
			local dotTran = child(read_card_player[tostring(viewSeat)].transform,"dot")
			local dotSpr =componentGet(dotTran.transform,"UISprite")
			if index == 0 then
				dotTran.gameObject:SetActive(false)
			else
				dotTran.gameObject:SetActive(true)
				dotSpr.spriteName = "liapi0"..tostring(index)
				dotSpr:MakePixelPerfect()
			end	
			index=index+1
			index=index%4
		end,0.5,-1)
		timer_Elapse:Start()
	end
	local function ReadCardStopTimer()
		if read_card_player["time"..tostring(viewSeat)].timer_Elapse ~= nil then
			read_card_player["time"..tostring(viewSeat)].timer_Elapse:Stop()
			read_card_player["time"..tostring(viewSeat)].timer_Elapse = nil
			index = 0
		end
	end
end


function this.SetBeiShuBtnCount()
	local roomData = room_data.GetSssRoomDataInfo()
	for i = 1,5 do
		local child =  child( compTbl.xiapao,"pao"..tostring(i))
		if child ~= nil then
			if tonumber(i) <= tonumber(roomData.max_multiple) then
				child.gameObject:SetActive(true)
			else
				child.gameObject:SetActive(false)
			end
		end
	end
	local gridComp =  compTbl.xiapao.gameObject:GetComponent(typeof(UIGrid))
	if gridComp ~= nil then
		gridComp:Reposition()
	else
		Trace("===选择倍数UIGrid为空！===")
	end
end

--显示闲家倍数
function this.SetBeiShu(viewSeat, beishu)
	if this.playerList[viewSeat] ~= nil then
		this.playerList[viewSeat].SetBeiShu(beishu)
	end 
end

--获取玩家头像坐标
function this.GetAllShootPos(viewSeat)
	if this.playerList[viewSeat] ~= nil then
		local shooterPos = child(widgetTbl.panel,"Anchor_Center/Players/Player"..tostring(viewSeat))
		return shooterPos.localPosition
	end
end

--播放打枪动画
function this.PlayAnimationWithIndex(index,offsetx,offsety,animationName,width,height,PlayerCallBack,renderQueue)	
	if this.animationTabel == nil or #this.animationTabel == 0 then
		--widgetTbl.panel = child(this.transform, "Panel")
		return 	
	end
	
	if tonumber(index) <= #this.animationTabel then
		local animObj  = this.animationTabel[index]
		if not IsNil(animObj) then
			animations_sys.PlayAnimationByObj(animObj, offsetx, offsety, animationName, width, height, PlayerCallBack, renderQueue)
		end
	end
end

function this.HideAnimationObject()
	for i,v in ipairs(this.animationTabel) do
		if v ~= nil then
			v.gameObject:SetActive(false)
		end
	end
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

    gvoice_sys.StopRecording()        -- 结束录音
    gvoice_sys.AddRecordedFileLst()   -- 上传文件
  end

  --开始录音
  function this.RecodeSoundStart()
  	Trace("录音开始,执行开始录音逻辑-------------------------------")
  	local ret = gvoice_sys.StartRecording(global_define.recordFilePath)   --开始录音

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
  if isPress and (not isStart)then
  	isStart = true
    this.isCancel = false
    this.isMaxTimeSend = false
    this.RecodeSoundStart()
  else
    if this.isCancel == false and this.isMaxTimeSend == false then
      if fillSize*gvoice_sys.GetMaxRecordTime() < gvoice_sys.GetMinRecordTime() then
        UI_Manager:Instance():FastTip("说话时间过短，请重新说话")
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
        if this.isDrag then
          if Input.mousePosition.y > 2*Screen.height/5 then           
            this.isCancel = true
            if this.isMaxTimeSend ==false then
              this.RecodeSoundCancel()
            end
          end
          this.isDrag = false
        end
    end)
  end
end

function this.OnMsgVoiceInfoHandler(fileID)
  Trace("fileID---------------------"..tostring(fileID))
  shisangshui_play_sys.ChatReq(3, tostring(fileID), nil)
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
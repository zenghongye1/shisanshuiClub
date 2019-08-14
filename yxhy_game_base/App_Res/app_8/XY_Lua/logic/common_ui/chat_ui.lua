--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--endregion

chat_ui = ui_base.New()
local this = chat_ui

local chatTextTab 
local chatImgTab

function this.Init(_chatTextTab,_chatImgTab) 
	if  IsNil(this.gameObject) then
		--require ("logic/common_ui/chat_ui") 
		this.gameObject=newNormalUI("app_8/ui/common/chatPanel")
		chatTextTab = _chatTextTab
		chatImgTab = _chatImgTab
		this.addlistener() 
	end    
	this.gameObject:SetActive(false) 
end


function this.addlistener() 
    this.SetChatTextInfo()
    this.SetChatImgInfo()
    local bg =child(this.transform,"panel/bg_collider")
    if bg~=nil then
        addClickCallbackSelf(bg.gameObject,this.HideChatPanel,this)
    end
end

function this.HideChatPanel()
	this.gameObject:SetActive(false)
end

function this.Clear()
	destroy(this.gameObject)
end

function this.SetChatPanle()
	if this.gameObject.activeSelf == true then
		this.gameObject:SetActive(false)
	else
		this.gameObject:SetActive(true)
	end
end


local limitchatText = false
function this.SetChatTextInfo()
	for i=1,table.getCount(chatTextTab),1 do       
       local good = child(this.transform,"panel/ScrollView/grid_text/item"..tostring(i))     
	   if good==nil then 
		    local o_good = child(this.transform,"panel/ScrollView/grid_text/item"..tostring(i-1)) 
		    good = GameObject.Instantiate(o_good.gameObject)
		    good.transform.parent=o_good.transform.parent 
            good.name="item"..tostring(i)
            good.transform.localScale={x=1,y=1,z=1}    
            local grid=child(this.transform,"panel/ScrollView/grid_text")
            componentGet(grid,"UIGrid"):Reposition()  
	   end  
	   addClickCallbackSelf(good.gameObject,this.Onbtn_chatTextClick,this)    
	   good.gameObject:SetActive(true)
	   local lab_msg=child(good.transform,"msg") 
	   componentGet(lab_msg,"UILabel").text=chatTextTab[i]		
    end 
end

function this.SetChatImgInfo()
	for i=1,table.getCount(chatImgTab),1 do       
       local good = child(this.transform,"panel/ScrollView/grid_img/item"..tostring(i))     
	   if good==nil then 
		    local o_good = child(this.transform,"panel/ScrollView/grid_img/item"..tostring(i-1)) 
		    good = GameObject.Instantiate(o_good.gameObject)
		    good.transform.parent=o_good.transform.parent 
            good.name="item"..tostring(i)
            good.transform.localScale={x=1,y=1,z=1}    
            local grid=child(this.transform,"panel/ScrollView/grid_img")
            componentGet(grid,"UIGrid"):Reposition()   
	   end    
	   addClickCallbackSelf(good.gameObject,this.Onbtn_chatImgClick,this)  
	   good.gameObject:SetActive(true)

	   local tImg="img_mj"
	    if roomdata_center.gid == ENUM_GAME_TYPE.TYPE_FUZHOU_MJ then
	   		tImg="img_mj"
	   	elseif roomdata_center.gid == ENUM_GAME_TYPE.TYPE_SHISHANSHUI then
	   		tImg="img_sss"
	   	end
	   	local sprite_msg=child(good.transform,tImg) 
	   	sprite_msg.gameObject:SetActive(true)
	   	componentGet(sprite_msg,"UISprite").spriteName=chatImgTab[i]
    end 
end

function this.Onbtn_chatTextClick(self, obj)

  if limitchatText == true then
    fast_tip.Show("喝杯茶休息一下再发")
    return
  else
    this.LimitChatTextShow()
  end
	local tItemName = obj.gameObject.name
	tItemName = string.sub(tItemName,string.len("item")+1)
	local tIndex = tonumber(tItemName)
	Trace(chatTextTab[tIndex])
	Trace("-----------------------------------:"..tostring(roomdata_center.gid))
	if roomdata_center.gid == ENUM_GAME_TYPE.TYPE_FUZHOU_MJ then
		mahjong_play_sys.ChatReq(1,chatTextTab[tIndex],nil)
	elseif roomdata_center.gid == ENUM_GAME_TYPE.TYPE_SHISHANSHUI then
		shisangshui_play_sys.ChatReq(1,chatTextTab[tIndex],nil)
	end
end

function this.Onbtn_chatImgClick(self, obj)
	local tItemName = obj.gameObject.name
	tItemName = string.sub(tItemName,string.len("item")+1)
	local tIndex = tonumber(tItemName)
	Trace("Image name:"..chatImgTab[tIndex])

	if roomdata_center.gid == ENUM_GAME_TYPE.TYPE_FUZHOU_MJ then
		mahjong_play_sys.ChatReq(2,chatImgTab[tIndex],nil)
	elseif roomdata_center.gid == ENUM_GAME_TYPE.TYPE_SHISHANSHUI then
		shisangshui_play_sys.ChatReq(2,chatImgTab[tIndex],nil)
	end
end

function this.DealChat(viewSeat,contentType,content,givewho)
	local para = {}
		para["viewSeat"]=viewSeat
		para["contentType"]=contentType
		para["content"]=content
		para["givewho"]=givewho

	if contentType == 1 then
		--文字聊天
		Notifier.dispatchCmd(cmdName.MSG_CHAT_TEXT, para)
    if viewSeat == 1 then
		  this.HideChatPanel()
    end
	elseif contentType ==2 then
		--表情聊天
		Notifier.dispatchCmd(cmdName.MSG_CHAT_IMAGA, para)
    if viewSeat ==  1 then
		  this.HideChatPanel()
    end
	elseif contentType == 3 then
		--语音聊天
    Trace("------recive voice msg---------------")  
    --if viewSeat~=1 then
      local voiceInfoTbl = {}
      voiceInfoTbl.fileID = content
      voiceInfoTbl.viewSeat = viewSeat
      voiceInfoTbl.flag = 2
      gvoice_sys.AddDownloadFile(voiceInfoTbl)
    --end
	elseif contentType == 4 then
		--玩家互动
		Notifier.dispatchCmd(cmdName.MSG_CHAT_INTERACTIN, para)
	end
end

function this.GetChatIndexByContent(content)
  local tIndex = nil
  for k, value in pairs(chatTextTab) do
    if value == content then
      tIndex = k
      break
    end
  end
  return tIndex
end

--文字聊天限制
local chatText_timer_Elapse = nil
function this.LimitChatTextShow()
  if chatText_timer_Elapse == nil then
    chatText_timer_Elapse = Timer.New(this.OnChatTextTimer_Proc , global_define.chatTextIntervalTime, 1)
    chatText_timer_Elapse:Start()
    limitchatText = true
  end
end
function this.LimitChatTextHide()
  if chatText_timer_Elapse ~= nil then
      chatText_timer_Elapse:Stop()
      chatText_timer_Elapse = nil
  end
end
function this.OnChatTextTimer_Proc()
  limitchatText = false
  chatText_timer_Elapse:Stop()
  chatText_timer_Elapse = nil
end

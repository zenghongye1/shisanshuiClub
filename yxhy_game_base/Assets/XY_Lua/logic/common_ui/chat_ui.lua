--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--endregion

local base = require("logic.framework.ui.uibase.ui_window")
local chat_ui = class("chat_ui",base)


--非法字符处理 
local illegalityWordTbl = require("logic/common/illegality_words") or {} 
 function chat_ui:copyFun(_tbl)
	local newTbl = {}
	for k,v in pairs(_tbl or {}) do
		newTbl[k] = v
	end
	return newTbl
end
--非法字符表情过滤
function chat_ui:filter_spec_chars(s)  
    local ss = {}  
    for k = 1, #s do 
        local c = string.byte(s,k)  
        if not c then break end  
        if (c>=48 and c<=57) or (c>= 65 and c<=90) or (c>=97 and c<=122) then  
            table.insert(ss, string.char(c))  
        elseif c>=228 and c<=233 then  
            local c1 = string.byte(s,k+1)  
            local c2 = string.byte(s,k+2)  
            if c1 and c2 then  
                local a1,a2,a3,a4 = 128,191,128,191 
                if c == 228 then a1 = 184 
                elseif c == 233 then a2,a4 = 190,c1 ~= 190 and 191 or 165 
                end  
                if c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4 then  
                    k = k + 2 
                    table.insert(ss, string.char(c,c1,c2))  
                end  
            end  
        end  
    end  
    return table.concat(ss)  
end 

function chat_ui:ctor()
	base.ctor(self)

	self.defaultTxtCount = 999 --默认语录条数 
end

function chat_ui:OnInit()
	self.chatModel = model_manager:GetModel("ChatModel")
	self.mInput = componentGet(child(self.gameObject.transform,"panel/Input"),"UIInput")
	self.mSendBtn = componentGet(child(self.gameObject.transform,"panel/sendBtn"),"UIButton")
	addClickCallbackSelf(self.mSendBtn.gameObject,self.Onbtn_sendClick,self)
	self:addlistener() 
end

function chat_ui:OnOpen( ... )
	if self.args ~= nil and #self.args == 2 then
		local chatTextTab = self.args[1]
		local chatImgTab = self.args[2]
		self:InitUI(chatTextTab,chatImgTab)
	end
	self:SetChatTextInfo()
end

function chat_ui:PlayOpenAmination()
end

function chat_ui:InitUI(_chatTextTab,_chatImgTab) 
	if self.gameObject then
		self.chatModel.chatTextTab = self:copyFun(_chatTextTab)
		self.chatModel.chatImgTab = self:copyFun(_chatImgTab)
		--文本输入
		defaultTxtCount = table.getCount(self.chatModel.chatTextTab)
		self:InitRecordTxt()

		--iphoneX
		-- if data_center.GetCurPlatform() == "IPhonePlayer" and YX_APIManage.Instance:isIphoneX() then
		-- 	local panel = child(self.gameObject.transform,"panel")
		--     if panel then
		--     	local localPos = panel.gameObject.transform.localPosition
		--     	panel.gameObject.transform.localPosition = Vector3(localPos.x -60, localPos.y, localPos.z)
		--     end
		-- end
		self:SetChatTextInfo()
		self:SetChatImgInfo()
	end
end

function chat_ui:DestroyChatPanel()
	self:HideChatPanel()
end

function chat_ui:addlistener() 
  
    local bg =child(self.transform,"panel/bg_collider")
    if bg~=nil then
        addClickCallbackSelf(bg.gameObject,self.HideChatPanel,self)
    end
end

function chat_ui:HideChatPanel()
	UI_Manager:Instance():CloseUiForms("chat_ui")
end

function chat_ui:OnClose()
	self:Clear()
end

function chat_ui:Clear()
	-- destroy(self.gameObject)

	local grid_text = child(self.transform,"panel/ScrollView_txt/grid_text")
	if grid_text then
		for i = (grid_text.transform.childCount -1),1,-1 do
			GameObject.Destroy(grid_text.transform:GetChild(i).gameObject)
		end
	end
	local grid_img = child(self.transform,"panel/ScrollView_img/grid_img")
	if grid_img then
		for i = (grid_img.transform.childCount -1),1,-1 do
			GameObject.Destroy(grid_img.transform:GetChild(i).gameObject)
		end

		-- 隐藏模版子类
		local item = child(grid_img.transform,"item1")
		if item then
			for i = (item.transform.childCount -1),0,-1 do
				local item2 = item.transform:GetChild(i)
				if item2 then
					item2.gameObject:SetActive(false)
				end
			end
		end
	end

end

local limitchatText = false
function chat_ui:SetChatTextInfo()
	local firstTxtlColor = nil
	for i=1,table.getCount(self.chatModel.chatTextTab),1 do       
       local good = child(self.transform,"panel/ScrollView_txt/grid_text/item"..tostring(i))     
	   if good==nil then 
		    local o_good = child(self.transform,"panel/ScrollView_txt/grid_text/item"..tostring(i-1)) 
		    good = GameObject.Instantiate(o_good.gameObject)
		    good.transform.parent=o_good.transform.parent 
            good.name="item"..tostring(i)
            good.transform.localScale={x=1,y=1,z=1}    
            local grid=child(self.transform,"panel/ScrollView_txt/grid_text")
            componentGet(grid,"UIGrid"):Reposition()  
	   end  
	   addClickCallbackSelf(good.gameObject,self.Onbtn_chatTextClick,self)    
	   good.gameObject:SetActive(true)
	   local lab_msg=child(good.transform,"msg") 
	   componentGet(lab_msg,"UILabel").text=self.chatModel.chatTextTab[i]

		--历史记录处理
		if i >defaultTxtCount then
	   		componentGet(lab_msg,"UILabel").color = Color.New(0.8,0.8,0.6, 1)
	   	else
	   		-- 同步第一条颜色
	   		if not firstTxtlColor then
	   			firstTxtlColor = componentGet(lab_msg,"UILabel").color
	   		else
	   			componentGet(lab_msg,"UILabel").color = firstTxtlColor
	   		end
		end

        --双行隐藏
        local isShow = (i%2 ==1)
        if good then
        	local bgSprite = child(good.transform,"Sprite_bg")
        	if bgSprite then
        		bgSprite.gameObject:SetActive(isShow)
        	end
        end
    end

	local ScrollView_txt = child(self.transform, "panel/ScrollView_txt")
	if ScrollView_txt then
		componentGet(ScrollView_txt,"UIScrollView"):ResetPosition()
	end
end

function chat_ui:SetChatImgInfo()

	for i=1,table.getCount(self.chatModel.chatImgTab),1 do       
       local good = child(self.transform,"panel/ScrollView_img/grid_img/item"..tostring(i))     
	   if good==nil then 
		    local o_good = child(self.transform,"panel/ScrollView_img/grid_img/item"..tostring(i-1)) 
		    good = GameObject.Instantiate(o_good.gameObject)
		    good.transform.parent=o_good.transform.parent 
            good.name="item"..tostring(i)
            good.transform.localScale={x=1,y=1,z=1}    
            local grid=child(self.transform,"panel/ScrollView_img/grid_img")
            componentGet(grid,"UIGrid"):Reposition()   
	   end    
	   addClickCallbackSelf(good.gameObject,self.Onbtn_chatImgClick,self)  
	   good.gameObject:SetActive(true)

	   	local tImg="img_normall"
	   	local sprite_msg=child(good.transform,tImg) 
	   	sprite_msg.gameObject:SetActive(true)
	   	componentGet(sprite_msg,"UISprite").spriteName=self.chatModel.chatImgTab[i]
    end
    
	local ScrollView_img = child(self.transform, "panel/ScrollView_img")
	if ScrollView_img then
		componentGet(ScrollView_img,"UIScrollView"):ResetPosition()
	end
end

function chat_ui:Onbtn_sendClick(_obj)
	-- Trace("this.Onbtn_sendClick")
	ui_sound_mgr.PlayButtonClick()
	if limitchatText == true then
		UI_Manager:Instance():FastTip("喝杯茶休息一下再发")
		return
	else
		self:LimitChatTextShow()
	end

	if self.mInput then
		local inputText = self:filter_spec_chars(self.mInput.value or "")
		if string.len(inputText) >0 then

			--非法字符处理
			for i,v in ipairs(illegalityWordTbl) do
				inputText = string.gsub(inputText, v, "*")
			end

			-- send msg
			if GameUtil.CheckGameIdIsMahjong(roomdata_center.gid) then
				mahjong_play_sys.ChatReq(1, inputText, nil)
			else
				pokerPlaySysHelper.GetCurPlaySys().ChatReq(1, inputText, nil)
			end

			--历史记录
			self:RecordTxt(inputText)

			-- clear
			self.mInput.value = ""
			self:HideChatPanel()
		else
			UI_Manager:Instance():FastTip("请输入文字")
		end
	end
end

--历史记录
function chat_ui:RecordTxt(_value)
	if not _value then
		return
	end
	table.insert(self.chatModel.chatTextTab, defaultTxtCount+1, _value)
	--移除旧记录
	local maxCount = defaultTxtCount +6
	local txt = self.chatModel.chatTextTab[maxCount]
	while txt do
		table.remove(self.chatModel.chatTextTab, maxCount)
		txt = self.chatModel.chatTextTab[maxCount]
	end
	--保存本地
	for i=1,5 do
		local txtValue = self.chatModel.chatTextTab[defaultTxtCount+i]
		if txtValue and string.len(txtValue) >0 then
			local chatKey = "chatTxt_"..i
			PlayerPrefs.SetString(chatKey, txtValue)
		else
			break
		end
	end
end
--取出历史记录
function chat_ui:InitRecordTxt()
	for i=1,5 do
		local chatKey = "chatTxt_"..i
		local txtValue = PlayerPrefs.GetString(chatKey)
		if txtValue and string.len(txtValue) >0 then
			self.chatModel.chatTextTab[defaultTxtCount +i] = txtValue
		else
			break
		end
	end
end

--------- @TODO  整理

function chat_ui:Onbtn_chatTextClick(obj)

  if limitchatText == true then
    UI_Manager:Instance():FastTip("喝杯茶休息一下再发")
    return
  else
    self:LimitChatTextShow()
  end
	local tItemName = obj.gameObject.name
	tItemName = string.sub(tItemName,string.len("item")+1)
	local tIndex = tonumber(tItemName)
	Trace(self.chatModel.chatTextTab[tIndex])
	Trace("-----------------------------------:"..tostring(roomdata_center.gid))
	if GameUtil.CheckGameIdIsMahjong(roomdata_center.gid) then
		mahjong_play_sys.ChatReq(1,self.chatModel.chatTextTab[tIndex],nil)
	else
		pokerPlaySysHelper.GetCurPlaySys().ChatReq(1,self.chatModel.chatTextTab[tIndex],nil)
	end
end

function chat_ui:Onbtn_chatImgClick(obj)
	local tItemName = obj.gameObject.name
	tItemName = string.sub(tItemName,string.len("item")+1)
	local tIndex = tonumber(tItemName)
	Trace("Image name:"..self.chatModel.chatImgTab[tIndex])

	if GameUtil.CheckGameIdIsMahjong(roomdata_center.gid) then
		mahjong_play_sys.ChatReq(2,self.chatModel.chatImgTab[tIndex],nil)
	else
		pokerPlaySysHelper.GetCurPlaySys().ChatReq(2,self.chatModel.chatImgTab[tIndex],nil)
	end
end

--文字聊天限制
local chatText_timer_Elapse = nil
function chat_ui:LimitChatTextShow()
  if chatText_timer_Elapse == nil then
    chatText_timer_Elapse = Timer.New(self.OnChatTextTimer_Proc , global_define.chatTextIntervalTime, 1)
    chatText_timer_Elapse:Start()
    limitchatText = true
  end
end
function chat_ui:LimitChatTextHide()
  if chatText_timer_Elapse ~= nil then
      chatText_timer_Elapse:Stop()
      chatText_timer_Elapse = nil
  end
end
function chat_ui:OnChatTextTimer_Proc()
  limitchatText = false
  chatText_timer_Elapse:Stop()
  chatText_timer_Elapse = nil
end

return chat_ui

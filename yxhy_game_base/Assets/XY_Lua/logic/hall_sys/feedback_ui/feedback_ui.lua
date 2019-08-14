--用户反馈界面
require "logic/hall_sys/feedback_ui/feedback_data"
require "logic/hall_sys/hall_data"

local base = require("logic.framework.ui.uibase.ui_window")
local feedback_ui = class("feedback_ui",base)

function feedback_ui:ctor()
	base.ctor(self)
	self.destroyType = UIDestroyType.Immediately
	self.msgPosY = 0
	self.count = 0
	self.maxStrNum = 80
	self.feedback_data = nil
end

local timer_Elapse = nil 			--提示消息时间间隔
local timerMsgSend_Elapse = nil 	--发反馈消息时间间隔
local itemSpace = 130  		--item之间的距离

function feedback_ui:OnInit()
	self:InitView()
	self.IsAutoReply = true		--是否可以自动回复
	self.IsCanSendMsg = true	--是否可以发送消息
	self.mLeftMsgNum = 0
	self.mRightMsgNum = 0
end

 function feedback_ui:OnOpen()
	hall_ui:ShowFeedBackRedPoint(false)----大厅反馈红点消除
	self:InitFeedbackData()
	if self.feedback_data ~= nil then
		self.feedback_data:Init()
		self.feedback_data:getFeedBack(function()
			UI_Manager:Instance():CloseUiForms("waiting_ui")
			self:ReflushUI()	
		end)
	end
 end

function feedback_ui:PlayOpenAmination()
	--打开动画重写
end
function feedback_ui:OnRefreshDepth()

  local Effect_shaangcheng = child(self.gameObject.transform, "feedback_panel/Panel_Top/bg/topBg/Title/Effect_youxifenxiang")
  if Effect_shaangcheng and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(Effect_shaangcheng.gameObject, topLayerIndex)
  end
end

function feedback_ui:InitFeedbackData()
	self.feedback_data = require ("logic/hall_sys/feedback_ui/feedback_data"):create(self)
end

 function feedback_ui:InitView()
	self.tran_noMsg = child(self.gameObject.transform, "feedback_panel/Panel_Top/tips/lblNoMsg")
	self.qqLabel = self:GetComponent("feedback_panel/Panel_Top/tips/Label1", typeof(UILabel))
	self.weixinLabel = self:GetComponent("feedback_panel/Panel_Top/tips/Label2", typeof(UILabel))
	self.qqLabel.text = "QQ客服号：" .. global_define.qq
 	self.weixinLabel.text = "微信客服号：" .. global_define.winXin
	
	self.gridTran_msg = child(self.gameObject.transform, "feedback_panel/Panel_Middle/ScrollView/MsgRoot")
 	self.tran_rightItem = child(self.gridTran_msg, "right_grid")
 	self.tran_leftItem = child(self.gridTran_msg, "left_grid")
	
 	self.scrollview_msg = componentGet(child(self.gameObject.transform, "feedback_panel/Panel_Middle/ScrollView"),"UIScrollView")
	self.panel_scroll = componentGet(child(self.gameObject.transform, "feedback_panel/Panel_Middle/ScrollView"),"UIPanel")

 	self.lbl_input = componentGet(child(self.gameObject.transform,"feedback_panel/Panel_Bottom/input_msg/value"),"UILabel")
 	self.input_msg = componentGet(child(self.gameObject.transform,"feedback_panel/Panel_Bottom/input_msg"),"UIInput")
	
 	EventDelegate.Add(self.input_msg.onChange, EventDelegate.Callback(function() self:OnInputChange() end))
	
	local btnClose = child(self.gameObject.transform, "feedback_panel/Panel_Top/backBtn")
 	if btnClose ~= nil then 
 		addClickCallbackSelf(btnClose.gameObject,self.CloseWin,self)
 	end

 	local btnSend = child(self.gameObject.transform, "feedback_panel/Panel_Bottom/btn_send")
 	if btnSend ~= nil then
		addClickCallbackSelf(btnSend.gameObject,self.OnBtnSendClick,self)
	end
	
	local copyQQBtnGo = self:GetGameObject("feedback_panel/Panel_Top/tips/copy1")
	local copyWeixinBtnGo = self:GetGameObject("feedback_panel/Panel_Top/tips/copy2")	
	addClickCallbackSelf(copyQQBtnGo,self.CopyQQ, self)
	addClickCallbackSelf(copyWeixinBtnGo,self.CopyWeiXin, self)
 end

function feedback_ui:UpdateView()
	if self.scrollview_msg ~= nil then
		self.scrollview_msg:ResetPosition()		
		if self.count < 4 then
			self.scrollview_msg:SetDragAmount(0,0,false)
		else
			self.scrollview_msg:SetDragAmount(0,1,false)
		end
		self.panel_scroll:Refresh()
	end
end

function feedback_ui:OnBtnSendClick()
	local timePrefix = os.date("%Y/%m/%d %H:%M",os.time())
	local msgType = 0
	local msgStr = self.input_msg.value
	local tMsgStrNum = self:CalStrNum(msgStr)
	if  tMsgStrNum == 0 then
		UI_Manager:Instance():FastTip("请输入反馈信息")
		elseif tMsgStrNum <= self.maxStrNum then
			if self.IsCanSendMsg == false then
				UI_Manager:Instance():FastTip("发言过于频繁，请稍后再试")
			else
				self:LimitSendMsgTime()
				self.feedback_data:AddMsg(timePrefix,msgType,msgStr,function()
					if self.IsAutoReply == true and msgType == 0 then
						self.IsAutoReply = false
						table.insert(self.feedback_data:getTipList(),self.mRightMsgNum + self.mLeftMsgNum + 1)
						if self.msgPosY > -160 then
							self.scrollview_msg:SetDragAmount(0,0,false)
						else
							self.scrollview_msg:SetDragAmount(0,1,false)
						end
					end
					self:ReflushUI()
				end)
			self.input_msg.value = ""
		end			
	else
		UI_Manager:Instance():FastTip("最多输入40字")
	end
end

function feedback_ui:OnInputChange()
	if self.lbl_input.supportEncoding == true then
		self.lbl_input.supportEncoding = false
	end
	--输入时弹提示字符超了
	local msgStr = self.input_msg.value
	local lastStr = ""

	local num = 0
	local f = '[%z\1-\127\194-\244][\128-\191]*';	
	for v in msgStr:gfind(f) do
		if #v ~= 1 then
			num = num + 2
		else
			num = num + 1
		end
		if num <= self.maxStrNum then
			lastStr = lastStr .. v
		else
			UI_Manager:Instance():FastTip("只可输入40字")
		end
	end
	--新加一个Label显示“草稿”
	self:SetDraft(lastStr,self.input_msg.transform)
	self.input_msg.value = lastStr
end

--输入时显示草稿
function feedback_ui:SetDraft(strMsg,inputTran)
	local tDraftLab = componentGet(child(inputTran,"draft"),"UILabel")
	local tPos = self.lbl_input.transform.localPosition
	local lblInputWidget = componentGet(child(self.gameObject.transform,"feedback_panel/Panel_Bottom/input_msg/value"),"UIWidget")
	local inputTrans = child(self.gameObject.transform,"feedback_panel/Panel_Bottom/input_msg")
	if strMsg == "" then
		tDraftLab.gameObject:SetActive(false)		
		lblInputWidget.leftAnchor.target = inputTrans
		lblInputWidget.leftAnchor.absolute = 3
	else
		tDraftLab.gameObject:SetActive(true)
		lblInputWidget.leftAnchor.target = inputTrans
		lblInputWidget.leftAnchor.absolute = 70
	end
end

function feedback_ui:CloseWin()
	ui_sound_mgr.PlayCloseClick()
	UI_Manager:Instance():CloseUiForms("feedback_ui")
end

function feedback_ui:ReflushUI()
	local feedbackMsgList = self.feedback_data:getMsgList()
	Trace("feedbackMsgList---------"..GetTblData(feedbackMsgList))	
	
	self.count = table.getn(feedbackMsgList)
	self:ShowNoMsgTip(self.count == 0)

	self:HideChildTrans(self.gridTran_msg)

	self.mRightMsgNum = 0
	self.mLeftMsgNum = 0
	local isRight = true
	for i=1,self.count do
		--Trace("正在处理第几条反馈消息----------------"..i)
		local feedback_msg = feedbackMsgList[i]
		if feedback_msg ~= nil then
			
			local templateTran = nil
			local tPos = nil
			local tIndex = nil
			if feedback_msg.type == 0 then
				templateTran = self.tran_rightItem
				isRight = true
				self.mRightMsgNum = self.mRightMsgNum + 1
				tIndex = self.mRightMsgNum
			else
				templateTran = self.tran_leftItem
				isRight = false
				self.mLeftMsgNum = self.mLeftMsgNum + 1
				tIndex = self.mLeftMsgNum
			end

			if i == 1 then
				self.msgPosY = templateTran.transform.parent.localPosition.y
			end  
			local good = nil
			if isRight == true then
				good = child(self.gridTran_msg,"right_grid"..feedback_msg.type.."_"..tostring(tIndex))		
				if good == nil then
					good = GameObject.Instantiate(templateTran.gameObject)
					good.transform.parent = templateTran.transform.parent
					good.name="right_grid"..feedback_msg.type.."_"..tostring(tIndex)
					good.transform.localScale = {x=1,y=1,z=1}            	
				end
				tPos = templateTran.transform.parent.localPosition;
				good.transform.localPosition = Vector3.New(tPos.x,self.msgPosY,tPos.z)
			end
			if isRight == false then
				good = child(self.gridTran_msg,"left_grid"..feedback_msg.type.."_"..tostring(tIndex))		
				if good == nil then
					good = GameObject.Instantiate(templateTran.gameObject)
					good.transform.parent = templateTran.transform.parent
					good.name = "left_grid"..feedback_msg.type.."_"..tostring(tIndex)
					good.transform.localScale = {x=1,y=1,z=1}            	
				end
				tPos = templateTran.transform.parent.localPosition
				good.transform.localPosition = Vector3.New(tPos.x,self.msgPosY,tPos.z)
			end
			
			if good ~= nil then
				local label_msg = componentGet(child(good.transform,"item/chatLbl"),"UILabel")
				label_msg.text = feedback_msg.msg
				label_msg:ProcessText()
				local sp_bg = componentGet(child(good.transform,"item/bg"),"UISprite")
				self:AdjustMsgUI(label_msg,sp_bg)
				self.msgPosY = self.msgPosY - itemSpace - sp_bg.height + 51
				good.gameObject:SetActive(true)

				local lb_time = child(good.transform,"item/timeLbl")
				componentGet(lb_time,"UILabel").text = feedback_msg.time

				local tex_icon = componentGet(child(good.transform,"item/texHead"),"UITexture")
				if feedback_msg.type == 0 then
					local selfId = data_center.GetLoginUserInfo().uid
					if(not isEmpty(hall_data.texList)) and hall_data.texList[tostring(selfId)] ~= nil then
						tex_icon.mainTexture = hall_data.texList[tostring(selfId)]
					else
						HeadImageHelper.SetImage(tex_icon,nil,nil,selfId)
					end
				end
				
				self.obj_autoReply = child(good.transform,"item/lblAutoReply")
				if (self.obj_autoReply ~= nil) then
					self:SetAutoReplay(self.obj_autoReply,false)
					if table.contains(self.feedback_data:getTipList(),i) then
						self:SetAutoReplay(self.obj_autoReply,true)
					end
				end			
				--调整自己文字对齐方式
				local msgLbl = child(good.transform,"item/chatLbl")
				if feedback_msg.type == 0 then
					if label_msg.height < 38 then
						label_msg:SetAlignment(3)				
						label_msg:ProcessText()
						msgLbl.localPosition = Vector3(-89,-5,0)
					else
						label_msg:SetAlignment(1)
						label_msg:ProcessText()				
						msgLbl.localPosition = Vector3(-89,-5,0)
					end
				end
			end
			if feedback_msg.type == 0 then
				if feedback_msg.sendState == 0 then
					if good ~= nil then
						local gantan = child(good.transform,"item/sendWarn")
						if gantan ~= nil then 
							gantan.gameObject:SetActive(false)
						end
						local chatBg = child(good.transform,"item/bg")
						gantan.gameObject:SetActive(true)
						addClickCallbackSelf(gantan.gameObject,self.ShowMessageBox,self)
					end
				else
					isReSend = false
				end
			end
		end
	end
	self:UpdateView()
end

function feedback_ui:ShowNoMsgTip(state)
	self.tran_noMsg.gameObject:SetActive(state)
end

function feedback_ui:ShowMessageBox(go)
	MessageBox.ShowYesNoBox("是否重发该消息？", function()
		self:ReSend(go)	
	end)
	 -- UI_Manager:Instance():ShowGoldBox("是否重发该消息？",
		-- {function() UI_Manager:Instance():CloseUiForms("message_box")  end,
		-- function ()  
		-- 	UI_Manager:Instance():CloseUiForms("message_box")
		-- 	self:ReSend(go)			
		-- end}, {"quxiao", "queding"}, {"button_03","button_02"})
end

function feedback_ui:ReSend(go)
	local index = string.sub(go.transform.parent.parent.gameObject.name,13,string.len(go.transform.parent.parent.gameObject.name))
	Trace("ReSend index --------------:"..index)
	local msgStr = subComponentGet(go.transform.parent,"chatLbl","UILabel").text
	local timePrefix = os.date("%Y/%m/%d %H:%M",os.time())
	self.feedback_data:ReAddMsg(timePrefix,0,msgStr,function()
			if go ~= nil then 
				go.gameObject:SetActive(false)
			end
			self:ReflushUI()
		end,index)
end

function feedback_ui:SetAutoReplay(go,state)
	if go ~= nil then
		go.gameObject:SetActive(state)
	end
end

function feedback_ui:HideChildTrans(parent)
	if parent ~= nil then
		local tNum = parent.childCount
		for i = tNum-1,0,-1 do
			local child = parent:GetChild(i)
			if child ~= nil then 
				child.gameObject:SetActive(false)
			end
		end
	end
end

function feedback_ui:AdjustMsgUI(lb_msg,sp_bg)		--聊天文字适配聊天框
	lb_msg:ProcessText()
	local tWidth = 0
	lb_msg.overflowMethod = UILabel.Overflow.ResizeFreely
	lb_msg:ProcessText()
	if lb_msg.width < 540 then
		tWidth = lb_msg.width	
	else
		tWidth = 540
	end
	lb_msg.overflowMethod=UILabel.Overflow.ResizeHeight
	lb_msg.width = 540
	sp_bg.width = tWidth + 50
	sp_bg.height = lb_msg.printedSize.y + 15
end

function feedback_ui:LimitSendMsgTime()
	self.IsCanSendMsg = false
	if timerMsgSend_Elapse == nil then
		timerMsgSend_Elapse = Timer.New(slot(self.OnTimerSendMsg_Proc,self),5,1)
	end
	timerMsgSend_Elapse:Reset(slot(self.OnTimerSendMsg_Proc,self),5,1)
	timerMsgSend_Elapse:Stop()
	timerMsgSend_Elapse:Start()
end

function feedback_ui:OnTimerSendMsg_Proc()
	self.IsCanSendMsg = true
end

function feedback_ui:CalStrNum(str)
	local num = 0
	local f = '[%z\1-\127\194-\244][\128-\191]*';	
	for v in str:gfind(f) do
		if #v ~= 1 then
			num = num + 2
		else
			num = num + 1
		end
	end
	Trace("输入字符个数："..tostring(num))
	return num
end

function feedback_ui:CopyWeiXin()
	local str = global_define.winXin
	YX_APIManage.Instance:onCopy(str,function() UI_Manager:Instance() :FastTip(LanguageMgr.GetWord(6043))end)
end

function feedback_ui:CopyQQ()
	local str = tostring(global_define.qq)
	YX_APIManage.Instance:onCopy(str,function() UI_Manager:Instance():FastTip(LanguageMgr.GetWord(6043))end)
end

function feedback_ui:OnClose()
	self.IsAutoReply = true
end

return feedback_ui
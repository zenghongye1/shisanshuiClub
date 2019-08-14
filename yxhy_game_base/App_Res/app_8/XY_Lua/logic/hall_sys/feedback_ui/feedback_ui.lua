--用户反馈界面
 require "logic/hall_sys/feedback_ui/feedback_data"
 require "logic/network/http_request_interface"
 require "logic/hall_sys/hall_data"
 

feedback_ui = ui_base.New()
local this = feedback_ui

local timer_Elapse = nil --提示消息时间间隔

local timerMsgSend_Elapse = nil --发反馈消息时间间隔

local msgHead = ""--"[ff0000][草稿][-]"
local msgGMChar = "#" --GM首字符
local IsAutoReply = true --是否可以自动回复
local IsCanSendMsg = true --是否可以发送消息

local mLeftMsgNum = 0
local mRightMsgNum = 0

local obj_noMsg
local obj_autoReply
local scrollview_msg
local obj_rightItem
local obj_leftItem
local obj_limitTips
local obj_reSendTips
local lb_input

local input_msg

function this.Show()
	Trace("feedback.show-------------------------------------2")
	if this.gameObject==nil then
		require ("logic/hall_sys/feedback_ui/feedback_ui")
		this.gameObject = newNormalUI("Prefabs/UI/Feedback/feedback_ui")
	else
		this.gameObject:SetActive(true)
	end
	this.IsAutoReply = true
	this.IsCanSendMsg = true
end

function this.InitData()
	Trace("feedback_ui.InitData-------------------------------------2")
	this.ReflushUI()
end

function this.Hide()
 	this.gameObject:SetActive(false)
 	this.IsAutoReply = true
end

function this.Awake( )
 	-- body
 end

function this.Start()
	Trace("Start-------------------------------------3")
	this:RegistUSRelation()
	this.Init()
	this.RegisterEvents1()	
	feedback_data.Init()
	this.InitData()

	feedback_data.getFeedBack(function() this.ReflushUI() end)
end

function this.Init()
	Trace("Init----------------------")
	obj_noMsg = child(this.transform, "lb_noMsg")
	obj_autoReply = child(this.transform, "autoReply")
	scrollview_msg = componentGet(child(this.transform, "ScrollView"),"UIScrollView")
	obj_rightItem = child(this.transform, "ScrollView/MsgRoot/right_grid/sp_good")
	obj_leftItem = child(this.transform, "ScrollView/MsgRoot/left_grid/sp_good")
	obj_limitTips = child(this.transform, "Tips/LimitTips")
	obj_reSendTips = child(this.transform, "Tips/ReSendTips")

	lb_input = componentGet(child(this.transform,"input_msg/value"),"UILabel")
	input_msg = componentGet(child(this.transform,"input_msg"),"UIInput")
	EventDelegate.Add(input_msg.onChange, EventDelegate.Callback(function() this.OnInputChange(this) end))
end

function this.OnDestroy()
	this:UnRegistUSRelation()
end

 
function this.RegisterEvents1()
	local btnClose = child(this.transform, "btn_cancel")
	if btnClose ~=nil then 
	   addClickCallbackSelf(btnClose.gameObject, this.OnBtnCloseClick, this)
	end

	local btnSend = child(this.transform, "btn_send")
	if btnSend ~= nil then
		addClickCallbackSelf(btnSend.gameObject, this.OnBtnSendClick, this)
	end

	local btnReSendEnter = child(this.transform, "Tips/ReSendTips/btn_enter")
	if btnReSendEnter ~= nil then
		addClickCallbackSelf(btnReSendEnter.gameObject, this.OnBtnReSendEnterClick, this)
	end

	local btnReSendCancel = child(this.transform, "Tips/ReSendTips/btn_cancel")
	if btnReSendCancel ~= nil then
		addClickCallbackSelf(btnReSendCancel.gameObject, this.OnBtnReSendCancelClick, this)
	end
end

function this.OnBtnCloseClick()
	Trace("OnBtnCloseClick-------------------------------------6")
	this.Hide()
end

function this.OnBtnSendClick()
	Trace("OnBtnSendClick--------------------------------------")

	local timePrefix = os.date("%Y/%m/%d %H:%M",os.time())
	local msgType = 0
	local msgStr = input_msg.value
	msgStr = string.sub(msgStr,string.len(msgHead)+1)
	--string.find(str,msgGMChar) == 1
	if string.sub(msgStr,1,1) == msgGMChar then
		msgStr = string.sub(msgStr,2)
		if msgStr == "" then
			msgStr = msgGMChar
			msgType = 0
		else
			msgType = 1
		end
	end

	local tMsgStrNum = this.calStrNum(msgStr)
	if  tMsgStrNum== 0 then
		fast_tip.Show(GetDictString(6010))
	elseif tMsgStrNum<=80 then
		msgStr = CheckAndReplaceForBadWords(msgStr)
		
		if this.IsCanSendMsg == false then
			fast_tip.Show(GetDictString(6011))
		else
			this.LimitSendMsgTime()
			feedback_data.AddMsg(timePrefix,msgType,msgStr,function()
			this.ReflushUI()
			if this.IsAutoReply ==true and msgType ==0 then
				this.IsAutoReply = false
				this.SetAutoReplay()
				table.insert(feedback_data.getTipList(),this.mRightMsgNum+this.mLeftMsgNum)

				scrollview_msg:ResetPosition()
				if msgPosY > -160 then
					scrollview_msg:SetDragAmount(0,0,false)
				else
					scrollview_msg:SetDragAmount(0,1,false)
				end
			end
			end)
			input_msg.value = ""
		end			
	else
		fast_tip.Show(GetDictString(6012))
	end
end

function this.SetAutoReplay()
	local good = GameObject.Instantiate(obj_autoReply.gameObject)
	good.transform.parent=obj_leftItem.transform.parent.parent	
	good.transform.localScale={x=1,y=1,z=1}
	local tPos= obj_autoReply.transform.localPosition	
	good.transform.localPosition = Vector3.New(tPos.x,msgPosY,tPos.z)
	good.name = "good_tip"
	good.gameObject:SetActive(true)
	msgPosY = msgPosY -60
end

function this.OnInputChange(self)
	if lb_input.supportEncoding == false then
		lb_input.supportEncoding = true
	end
	local tMsg = input_msg.value
	if tMsg ~= "" then
		if string.sub(tMsg,1,string.len(msgHead)) == msgHead  then
			if string.sub(tMsg,string.len(msgHead)+1) == "" then
				input_msg.value = ""
			else
				input_msg.value = tMsg
			end
		else
			input_msg.value = msgHead..input_msg.value
		end
	end	

	--输入时弹提示字符超了
	local msgStr = input_msg.value
	local preStr = ""
	local lastStr = ""
	msgStr = string.sub(msgStr,string.len(msgHead)+1)
	if msgStr~="" then
		preStr = msgHead
	end
	if string.sub(msgStr,1,1) == msgGMChar then
		msgStr = string.sub(msgStr,2)
		if msgStr == "" then
			msgStr = msgGMChar
		else
			preStr = preStr..msgGMChar
		end
	end

	local num = 0
	local f = '[%z\1-\127\194-\244][\128-\191]*';	
	for v in msgStr:gfind(f) do
		if #v~=1 then
			num = num + 2
		else
			num = num + 1
		end
		if num <=80 then
			lastStr = lastStr .. v
		else
			fast_tip.Show(GetDictString(6012))
		end
	end

	--新加一个Label显示“草稿”
	this.SetDraft(lastStr,input_msg.transform)

	lastStr = preStr..lastStr
	input_msg.value = lastStr
end

--输入时显示草稿
function this.SetDraft(strMsg,inputTran)
	local tDraftLab = componentGet(child(inputTran,"draft"),"UILabel")
	local tPos = lb_input.transform.localPosition
	if strMsg =="" then
		tDraftLab.gameObject:SetActive(false)		
		lb_input.transform.localPosition = Vector3.New(tDraftLab.transform.localPosition.x,tPos.y,tPos.z)
	else
		tDraftLab.gameObject:SetActive(true)
		lb_input.transform.localPosition = Vector3.New(tDraftLab.transform.localPosition.x + tDraftLab.width,tPos.y,tPos.z)
	end
end

function this.OnBtnReSendEnterClick()
	Trace("OnBtnReSendEnterClick--------------------------------------")
	this.ReflushUI()
end

function this.OnBtnReSendCancelClick()
	Trace("OnBtnReSendCancelClick--------------------------------------")

end

this.msgPosY=0
function this.ReflushUI()

	local feedbackMsgList = feedback_data.getMsgList()
	local len = table.getn(feedbackMsgList)
	if len == 0 then
		obj_noMsg.gameObject:SetActive(true)
	else
		obj_noMsg.gameObject:SetActive(false)
	end

	this.HideChildTrans(child(this.transform, "ScrollView/MsgRoot"))

	this.mRightMsgNum = 0
	this.mLeftMsgNum = 0
	for i=1,len do
		local feedback_msg = feedbackMsgList[i]
		if feedback_msg ~= nil then

			local templateObj = nil
			local tPos = nil
			local tIndex = nil
			if feedback_msg.type == 0 then
				templateObj = obj_rightItem
				this.mRightMsgNum = this.mRightMsgNum + 1
				--tPos = Vector3.New(270,140,0)
				tIndex = this.mRightMsgNum
			else
				templateObj = obj_leftItem
				this.mLeftMsgNum = this.mLeftMsgNum + 1
				--tPos = Vector3.New(-220,140)
				tIndex = this.mLeftMsgNum
			end

			if i==1 then
        		msgPosY = templateObj.transform.parent.localPosition.y;
        	end  

			local good = child(this.transform,"ScrollView/MsgRoot/good_"..feedback_msg.type.."_"..tostring(tIndex))		
			if good == nil then
				good = GameObject.Instantiate(templateObj.gameObject)
		    	good.transform.parent=templateObj.transform.parent.parent
            	good.name="good_"..feedback_msg.type.."_"..tostring(tIndex)
            	good.transform.localScale={x=1,y=1,z=1}            	
			end
			tPos = templateObj.transform.parent.localPosition;
			--good.transform.localPosition = Vector3.New(tPos.x,tPos.y-80*(i-1),tPos.z)
        	good.transform.localPosition = Vector3.New(tPos.x,msgPosY,tPos.z)
        	local tLbMsg = componentGet(child(good.transform,"msg"),"UILabel")
			tLbMsg.text = feedback_msg.msg
        	tLbMsg:ProcessText()
        	local tHei= tLbMsg.height
        	msgPosY = msgPosY - tHei - 60
        	good.gameObject:SetActive(true)


			local lb_time = child(good.transform,"time")
			componentGet(lb_time,"UILabel").text = feedback_msg.time
			local tex_icon = child(good.transform,"icon") --后续赋值
			local lb_msg = child(good.transform,"msg")
			componentGet(lb_msg,"UILabel").text = feedback_msg.msg	
			local lb_name = child(good.transform,"name")
			if feedback_msg.type ==0 then
				componentGet(lb_name,"UILabel").text=tostring(hall_data.username)
			else
				componentGet(lb_name,"UILabel").text="客服 柔柔"
			end
			this.AdjustTimeUI(componentGet(lb_time,"UILabel"),componentGet(lb_name,"UILabel"),feedback_msg.type)

			local sp_bg = componentGet(child(good.transform,"bg"),"UISprite")
			this.AdjustMsgUI(componentGet(lb_msg,"UILabel"),sp_bg)	

			if table.contains(feedback_data.getTipList(),i) then
				this.SetAutoReplay()
			end
		end
	end

	scrollview_msg:ResetPosition()
	if len < 5 then
		scrollview_msg:SetDragAmount(0,0,false)
	else
		scrollview_msg:SetDragAmount(0,1,false)
	end
end

function this.HideChildTrans(parent)
	if parent ~= nil then
		local tNum = parent.childCount
		for i = tNum-1,0,-1 do
			local child = parent:GetChild(i)
			if child~=nil then 
				child.gameObject:SetActive(false)
				if child.name == "good_tip" then
					GameObject.Destroy(child.gameObject)
				end
			end
		end
	end
end

function this.AdjustTimeUI(lbTime,lbName,pType)
	local  tPos = lbTime.transform.localPosition
	local tWidth = 0
	if pType==0 then
	  	tWidth = lbName.transform.localPosition.x-lbName.width-100
	else 
		tWidth = lbName.transform.localPosition.x+lbName.width+100
	end
	lbTime.transform.localPosition = Vector3.New(tWidth,tPos.y,tPos.z)
end

function this.AdjustMsgUI(lb_msg,sp_bg)
	lb_msg:ProcessText()
	sp_bg.height = lb_msg.height+10
	local tWidth = 0
	lb_msg.overflowMethod = UILabel.Overflow.ResizeFreely;
	lb_msg:ProcessText()
	lb_msg.width=lb_msg.width
	if lb_msg.width<=520 then
		tWidth=lb_msg.width
	else
		tWidth=520
	end
	lb_msg.overflowMethod=UILabel.Overflow.ResizeHeight
	lb_msg.width=520
	sp_bg.width=tWidth+23
end

function this.LimitTipsShow(str)
	local tContent=child(obj_limitTips,"content")
	componentGet(tContent,"UILabel").text = str
	obj_limitTips.gameObject:SetActive(true)
	if timer_Elapse == nil then
		timer_Elapse = Timer.New(this.OnTimer_Proc , 2, 1)
	end
	timer_Elapse:Reset(this.OnTimer_Proc , 2, 1)
	timer_Elapse:Stop()
	timer_Elapse:Start()
end
function this.LimitTipsHide()
	if timer_Elapse ~= nil then
	    timer_Elapse:Stop()
	end
end
function this.OnTimer_Proc()
	obj_limitTips.gameObject:SetActive(false)
end

function this.LimitSendMsgTime()
	this.IsCanSendMsg = false
	if timerMsgSend_Elapse == nil then
		timerMsgSend_Elapse = Timer.New(this.OnTimerSendMsg_Proc , 5, 1)
	end
	timerMsgSend_Elapse:Reset(this.OnTimerSendMsg_Proc , 5, 1)
	timerMsgSend_Elapse:Stop()
	timerMsgSend_Elapse:Start()
end
function this.LimitSendMsgHide()
	if timerMsgSend_Elapse ~= nil then
	    timerMsgSend_Elapse:Stop()
	end
end
function this.OnTimerSendMsg_Proc()
	this.IsCanSendMsg = true
end

function this.calStrNum(str)
	local num = 0
	local f = '[%z\1-\127\194-\244][\128-\191]*';	
	for v in str:gfind(f) do
		if #v~=1 then
			num = num + 2
		else
			num = num + 1
		end
		--Trace(v.."	"..tostring(num))
	end
	Trace("输入字符个数："..tostring(num))
	return num;
end

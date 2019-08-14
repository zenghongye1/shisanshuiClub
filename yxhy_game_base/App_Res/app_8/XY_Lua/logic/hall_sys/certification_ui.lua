
certification_ui = ui_base.New()
local this = certification_ui
 
this.gameObject=nil

local timer_Elapse = nil --提示消息时间间隔
local obj_limitTips

local obj_limitTips
local mNameInput
local mIdentity

local mRootObj
local mSuccesObj
local mReqOkObj

function this.Show()
	if this.gameObject==nil then
		require ("logic/hall_sys/certification_ui")
		this.gameObject = newNormalUI("app_8/ui/certification_ui/certification_ui")
	else
		this.gameObject:SetActive(true) 
	end
end

function this.Hide()
    if this.gameObject==nil then
		return
	else
		GameObject.Destroy(this.gameObject)
        this.gameObject=nil
	end
end

function this.Start() 
	--this:RegistUSRelation()
	this.Init()
	this.RegisterEvents1()	 
end

function this.OnDestroy()
	this:UnRegistUSRelation()
end

function this.Init() 
	this.mNameInput = componentGet(child(this.transform,"certification_panel/Panel_Middle/lab_1/Input"),"UIInput") 
	this.mIdentity = componentGet(child(this.transform,"certification_panel/Panel_Middle/lab_2/Input"),"UIInput")
	--EventDelegate.Add(mIdentity.onChange, EventDelegate.Callback(function() this.OnInputChange(this) end))
	 
end

function this.RegisterEvents1()
	local btnClose = child(this.transform, "certification_panel/btn_close")
	if btnClose ~=nil then 
	   addClickCallbackSelf(btnClose.gameObject, this.OnBtnCloseClick, this)
	end

	local btnSend = child(this.transform, "certification_panel/Panel_Middle/submit")
	if btnSend ~= nil then
		addClickCallbackSelf(btnSend.gameObject, this.OnBtnSendClick, this)
	end
end

function this.OnBtnCloseClick()
	Trace("OnBtnCloseClick-------------------------------------6")
	this.Hide()
end

function this.OnBtnSendClick()
	Trace("OnBtnSendClick--------------------------------------")
	
	local tName = this.mNameInput.value
	local tIdentity = this.mIdentity.value
	local tIdentityCount = string.len(tIdentity)
	 
	if tName == "" then
		fast_tip.Show(GetDictString(6005))
	elseif tIdentity == "" then
		fast_tip.Show(GetDictString(6006))
	elseif tIdentityCount~=15 and tIdentityCount~=18 then
		fast_tip.Show(GetDictString(6007))
	else	
		http_request_interface.idCardVerify(tName,tIdentity,function (str) 
			local s=string.gsub(str,"\\/","/")
			local t=ParseJsonStr(s)
					
			--判断实名认证是否成功		
			local ret=t.ret;				
			local tState = false
			if ret == 0 then
				tState = true
			end		
			if tState ==false then 
				fast_tip.Show(GetDictString(6008))
			else 
				fast_tip.Show(GetDictString(6009))
                this.Hide()
                hall_ui.Getuitable().btn_renzheng.gameObject:SetActive(false)
			end
		end)
	end
	
end

 
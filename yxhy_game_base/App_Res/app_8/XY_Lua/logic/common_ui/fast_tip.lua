--[[--
 * @Description: 弹出框，持续一段时间后自动关闭
 * @Author:      shine
 * @FileName:    fast_tip.lua
 * @DateTime:    2015-07-08
 ]]

fast_tip = ui_base.New()
local this = fast_tip

local timer_Elapse = nil -- timer
local nLeftTime = nil -- 持续时间

local lb_text = nil
local lb_nobbcode_text = nil

local msg = nil
local outlineColor = nil

local Init = nil
local StartTimer = nil
local StopTimer = nil
local OnTimer_Proc = nil
local supportEncoding = true


local function StopTimer()
	if timer_Elapse ~= nil then
		timer_Elapse:Stop()
		timer_Elapse = nil
	end
end

local function OnTimer_Proc()
	this.Hide()
end

local function StartTimer()
	StopTimer()
	timer_Elapse = Timer.New(OnTimer_Proc, nLeftTime, 1)
	timer_Elapse:Start()
end


--[[--
 * @Description: 逻辑入口  
 参数：encoding -是否支持bbcode默认支持
 ]]
function this.Show(text, time, pos, encoding, outlineColorValue)
	--Trace("this is a test----------------------2")

	if pos == nil then
		pos = Vector3.New(0, 0, -1000)  --处理角色页面层级问题
	end
	supportEncoding = encoding
	outlineColor = outlineColorValue
	if time == nil then
		time = 2
	elseif time == -1 then
		time = 100
	end
	this.ShowByTime(text, pos, time)
end

--[[--
 * @Description: 逻辑入口  
 ]]
function this.ShowByTime(text, pos, last_time)
	msg = text

	if last_time == 0.0 then
		nLeftTime = 3
	else
		nLeftTime = last_time
	end
	
	-- init	
	if not IsNil(this.gameObject) then
		--快速显示
		--this:FastShow()
		this:RefreshPanelDepth()
		this:RegistUSRelation()

		this.Init()
		this.transform.localPosition = pos
	else
		local fastTip = newNormalUI("app_8/ui/common/fast_tip")
		if fastTip ~= nil then
			fastTip.transform.localPosition = pos
		end
	end
end

function this.ResetFastTip()
	outlineColor = nil 
end


function this.FakeDestroy()
	--this:FastHide()
	--this:UnRegistDialogueEvent()
	this:UnRegistUSRelation()
    GameObject.Destroy(this.gameObject)
    this.gameObject=nil
end

--[[--
 * @Description: 逻辑入口  
 ]]
function this.Hide()
	if not IsNil(this.gameObject) then		
		this.FakeDestroy()
	end
	StopTimer()

	local fastTipObj = find("fast_tip(Clone)")
	if not IsNil(fastTipObj) then
		destroy(fastTipObj)
	end	
end

function this.Start()
	this.Init()
end

function this.OnDestroy()
	StopTimer()

	lb_text = nil
	lb_nobbcode_text = nil
	this.gameObject = nil

	--this:UnRegistDialogueEvent()
	this:UnRegistUSRelation()
end

function this.Init()	
	lb_text = subComponentGet(this.transform, "Label", "UILabel")
	lb_nobbcode_text = subComponentGet(this.transform, "Label_noBBcode","UILabel")
	
	if lb_text ~= nil then
		local bEncode = not(supportEncoding == false)
		lb_text.transform.gameObject:SetActive(bEncode)
		lb_nobbcode_text.transform.gameObject:SetActive(not bEncode)
		lb_text.text = msg
		lb_nobbcode_text.text = msg

		if (outlineColor ~= nil) then
			lb_text.effectStyle = UILabel.Effect.Outline
			lb_text.effectColor = outlineColor
		end
	end	
	StartTimer()
end


function this.DeTectTipIsShow()
	if not IsNil(this.gameObject) then
		return true 
	end
	return false
end
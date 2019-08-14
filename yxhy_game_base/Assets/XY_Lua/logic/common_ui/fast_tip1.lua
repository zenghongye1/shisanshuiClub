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

local dotCount = 0

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

local function OnTimer_ContentRefresh()
	dotCount = dotCount + 1
	if dotCount > 6 then
		dotCount = 1
	end
	local dotMsg = {}
	for i=1,dotCount do
		dotMsg[i] = "."		
	end
	lb_text.text = msg..table.concat(dotMsg, "")
end

local function StartTimer()
	if nLeftTime == -1 then
		StopTimer()
		timer_Elapse = Timer.New(OnTimer_ContentRefresh, 1, -1)
		timer_Elapse:Start()
	else
		StopTimer()
		timer_Elapse = Timer.New(OnTimer_Proc, nLeftTime, 1)
		timer_Elapse:Start()
	end
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
		if nLeftTime ~= -1 then
			--快速显示
			this:RefreshPanelDepth()
			this:RegistUSRelation()

			this.gameObject:SetActive(true)
			this.Init()
			this.transform.localPosition = pos
		end
	else
		local fastTip = newNormalUI(data_center.GetAppConfDataTble().appPath.."/ui/common/fast_tip")
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
		this.gameObject:SetActive(false)
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
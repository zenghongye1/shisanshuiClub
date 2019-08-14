--[[--
 * @Description: 协议等待框，一小段时间后触发
 * @Author:      shine
 * @FileName:    waiting_ui.lua
 * @DateTime:    2017-05-16
 ]]

local base = require("logic.framework.ui.uibase.ui_window")
local BaseClass = class("waiting_ui",base)

-- waiting_ui = {} 
-- local this = waiting_ui

local timer_Elapse = nil -- timer
local flower = nil
local m_bCreated = false
local curWaitingCount = 0

local isNotTipTxt = nil --不提示文字


function BaseClass:OnInit()
	self.m_UiLayer = UILayerEnum.UILayerEnum_Top
end

--[[--
 * @Description: 逻辑入口  
 ]]
function BaseClass:Show(_isNotTipTxt)
	if not m_bCreated then
		newResidentMemoryUI(data_center.GetAppConfDataTble().appPath.."/ui/common/waiting_ui")
		m_bCreated = true
	end
	curWaitingCount = curWaitingCount + 1
	self:InitUI()

	isNotTipTxt = _isNotTipTxt
end

--[[--
 * @Description: 逻辑入口  
 ]]
function BaseClass:Hide()
	curWaitingCount = curWaitingCount - 1
	if m_bCreated and curWaitingCount <= 0 then
		self:Uninit()
		curWaitingCount = 0
	end
end

function BaseClass:InitUI()	
	self.gameObject:SetActive(true)
	--flower = child(this.transform, "sp_waiting").gameObject
	--flower:SetActive(false)
	
	if timer_Elapse == nil then
		timer_Elapse = Timer.New(self.OnTimer_Proc, 30, 1)
	end
	timer_Elapse:Reset(self.OnTimer_Proc, 30, 1)
	timer_Elapse:Stop()
	timer_Elapse:Start()	
end

function BaseClass:Uninit()
	--Trace("waiting uninit")
	if not IsNil(self.gameObject) then
		self.gameObject:SetActive(false)
	end
	if timer_Elapse ~= nil then
	    timer_Elapse:Stop()
	end
end

function BaseClass:OnTimer_Proc()
	--[[if flower ~= nil then
	    flower:SetActive(true)
	end]]
	--if curWaitingCount > 0 then
		self:Uninit()
		curWaitingCount = 0	
		-- UI_Manager:Instance():FastTip(GetDictString(6003))

		if not isNotTipTxt then
			UI_Manager:Instance():FastTip(LanguageMgr.GetWord(6003))
		end
	--end
end

return BaseClass

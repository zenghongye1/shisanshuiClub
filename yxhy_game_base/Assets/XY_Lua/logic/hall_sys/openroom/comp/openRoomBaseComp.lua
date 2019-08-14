local base = require "logic/framework/ui/uibase/ui_view_base"
local openRoomBaseComp = class("openRoomBaseComp",base)
local tips_view = require "logic/hall_sys/openroom/comp/tips_view"

function openRoomBaseComp:InitView()
	self.self_button = componentGet(self.transform,"UIButton")
	if self.self_button then
		self.self_button.isEnabled = true
	end

	self.tips_view = tips_view:create(self:GetGameObject("itemTipsBtn"))	--tips提示
	self.tips_view:SetActive(false)
	
	self.toggleData = nil -- 按键数据
	self.curValue = nil -- 当前值，根据按键类型不同，值可能为bool或者int
end

function openRoomBaseComp:OnValueChange(value)
	if self.OnValueChangeCallBack ~= nil then
		self.OnValueChangeCallBack(value)
	end
end

function openRoomBaseComp:SetChangeCallBack(func)
	self.OnValueChangeCallBack = func
end

--[[--
 * @Description: 设置启用禁用状态  
 ]]
function openRoomBaseComp:SetAble(value)
	-- if value == false then
	-- 	logError(self.toggleData.selectIndex,self.toggleData.exData)
	-- end
	if self.self_button then 
		self.self_button.isEnabled = value
	end
end

function openRoomBaseComp:IsEnabled()
	if self.self_button then
		return self.self_button.isEnabled
	end
end

--[[--
 * @Description: 获取当前的值，被禁用时为空  
 ]]
function openRoomBaseComp:GetValue()
end

function openRoomBaseComp:SetToggleData(toggleData)
	self.toggleData = toggleData
end

function openRoomBaseComp:Show()
end

return openRoomBaseComp
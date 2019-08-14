--[[--
 * @Description: 模式组件基类
 * @Author:      shine
 * @FileName:    mode_comp_base.lua
 * @DateTime:    2017-06-13 10:44:03
 ]]
local mode_comp_base = class("mode_comp_base")

function mode_comp_base:ctor()
    self.mode = nil
    self.enable = false
end

function mode_comp_base:Initialize()
end

function mode_comp_base:Start()
    self.enable = true
end

function mode_comp_base:Uninitialize(... )
    self.enable = false
    -- body
end

function mode_comp_base:Update()
end

function mode_comp_base:AnimSpd()
	if self.mode and self.mode.GetAnimSpeed then
		return self.mode.GetAnimSpeed()
	end
end

return mode_comp_base
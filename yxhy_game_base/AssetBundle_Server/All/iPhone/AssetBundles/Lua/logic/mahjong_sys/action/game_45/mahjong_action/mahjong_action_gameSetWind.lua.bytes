-- 定风
local base = require "logic.mahjong_sys.action.common.mahjong_action_base"
local mahjong_action_gameSetWind = class("mahjong_action_gameSetWind", base)

function mahjong_action_gameSetWind:Execute(index)
	local number = index
	if index == 2 then
		number = 4
	elseif index == 4 then
		number = 2
	end
	self.compTable:SetDirection(number)
end

return mahjong_action_gameSetWind
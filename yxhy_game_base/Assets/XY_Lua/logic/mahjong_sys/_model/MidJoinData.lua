local MidJoinData = class("MidJoinData")

function MidJoinData:ctor()
	-- 自己的中途加入状态
	self.midJoinState = false
	self.midJoinViewSeatMap = {}
end

function MidJoinData:CreateViewSeatJoinMap(ststPlayerMidJoin)
	self.midJoinViewSeatMap = {}
	if ststPlayerMidJoin then
		for _,v in ipairs(ststPlayerMidJoin) do
			local viewSeat = player_seat_mgr.GetViewSeatByLogicSeatNum(v)
			self.midJoinViewSeatMap[viewSeat] = 1
		end
	end
end

--[[function MidJoinData:AddMidJoin(viewSeat)
	self.midJoinViewSeatMap[viewSeat] = 1
end--]]

-- 检测viewseat  是否为中途加入
function MidJoinData:CheckPlayerIsMidJoin(viewSeat)
	return self.midJoinViewSeatMap[viewSeat] == 1
end


function MidJoinData:Clear()
	self.midJoinState = false
	self.midJoinViewSeatMap = {}
end

return MidJoinData
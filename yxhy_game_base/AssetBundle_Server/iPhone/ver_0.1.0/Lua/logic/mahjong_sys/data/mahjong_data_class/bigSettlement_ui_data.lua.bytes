local bigSettlement_ui_data = class("bigSettlement_ui_data")

function bigSettlement_ui_data:ctor()
	self.gameName = ""
	self.endTime = ""
	self.roomNum = ""
	self.players = {}

	local player = {
		userData = {
			name = "",
			uid = "",
			headurl = "",
			imagetype = 0,
		},
		all_score = 0, -- 总分
		tList = {}, -- {{name = "自摸:",num = "1次",...}
		isWin = false, -- 大赢家
		isRich = false, -- 大输家
		isRoomOwner = false, -- 房主
	}
end

function bigSettlement_ui_data:ProcessData(...)
	--重写
end

return bigSettlement_ui_data
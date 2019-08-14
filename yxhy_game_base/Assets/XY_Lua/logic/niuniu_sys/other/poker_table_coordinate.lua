poker_table_coordinate = {}
local this = poker_table_coordinate

---座位表 [viewSeat] = positionIndex

this.table_two = {
	[1] = 1,
	[2] = 4,
}

this.table_three = {
	[1] = 1,
	[2] = 3,
	[3] = 5,
}

this.table_four = {
	[1] = 1,
	[2] = 2,
	[3] = 4,
	[4] = 5,
}

this.table_five = {
	[1] = 1,
	[2] = 2,
	[3] = 4,
	[4] = 5,
	[5] = 6,
}

this.table_six = {
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 4,
	[5] = 5,
	[6] = 6,
}

this.table_seven = {
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 4,
	[5] = 5,
	[6] = 6,
	[7] = 7,
}

this.table_eight = {
	[1] = 1,
	[2] = 8,
	[3] = 2,
	[4] = 3,
	[5] = 4,
	[6] = 5,
	[7] = 6,
	[8] = 7,
}

this.poker_table = {
	[2] = this.table_two,
	[3] = this.table_three,
	[4] = this.table_four,
	[5] = this.table_five,
	[6] = this.table_six,
	[7] = this.table_seven,
	[8] = this.table_eight,
}

function this.GetChairIndex(pNum,viewseat)
	if pNum <= 1 or pNum > 8 then
		logError("扑克玩家人数错误")
		return
	end
	return this.poker_table[pNum][viewseat]
end
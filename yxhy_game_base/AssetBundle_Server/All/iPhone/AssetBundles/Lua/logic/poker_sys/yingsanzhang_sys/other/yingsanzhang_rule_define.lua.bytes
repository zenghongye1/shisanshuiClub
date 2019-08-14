yingsanzhang_rule_define = {}
local this = yingsanzhang_rule_define

local PT_YINGSANZHANG = {
	PT_SINGLE = 1,          --高牌    
	PT_ONE_PAIR = 5,        --对子
	PT_STRAIGHT = 10,        --顺子
	PT_FLUSH = 15,           --金花
	PT_STRAIGHT_FLUSH = 20,  --顺金
	PT_LEOPARD = 25,         --豹子
}

this.PT_YINGSANZHANG_CardText = 
{
	[PT_YINGSANZHANG.PT_SINGLE] = "高牌",
	[PT_YINGSANZHANG.PT_ONE_PAIR] = "对子",
	[PT_YINGSANZHANG.PT_STRAIGHT] = "顺子",
	[PT_YINGSANZHANG.PT_FLUSH] = "金花",
	[PT_YINGSANZHANG.PT_STRAIGHT_FLUSH] = "顺金",
	[PT_YINGSANZHANG.PT_LEOPARD] = "豹子",
}

this.PT_YINGSANZHANG_CardSonud = {
	[PT_YINGSANZHANG.PT_SINGLE] = "gaopai",
	[PT_YINGSANZHANG.PT_ONE_PAIR] = "duizi",
	[PT_YINGSANZHANG.PT_STRAIGHT] = "shunzi",
	[PT_YINGSANZHANG.PT_FLUSH] = "jinhua",
	[PT_YINGSANZHANG.PT_STRAIGHT_FLUSH] = "shunjin",
	[PT_YINGSANZHANG.PT_LEOPARD] = "baozi",	
}

--玩法模式
local PT_YINGSANZHANG_PlaysMode = {
	PT_TRADITIONAL = 1, 	--传统玩法
	PT_PASSION = 2, 		--激情玩法
}

this.PT_YINGSANZHANG_PlaysModeDeskIcon = {
	[PT_YINGSANZHANG_PlaysMode.PT_TRADITIONAL] = "sy_yszctwf",
	[PT_YINGSANZHANG_PlaysMode.PT_PASSION] = "sy_yszjqwf",
}

--坐庄模式
local PT_YINGSANZHANG_BlindTurn = {
	PT_BLINDTURN_ZERO = 0, 		--不闷牌
	PT_BLINDTURN_ONE = 1, 		--闷一轮
	PT_BLINDTURN_TWO = 2, 		--闷两轮
	PT_BLINDTURN_THREE = 3, 	--闷三轮
}

this.PT_YINGSANZHANG_BlindTurnIcon = {
	[PT_YINGSANZHANG_BlindTurn.PT_BLINDTURN_ZERO] = "sy_yszwmp",
	[PT_YINGSANZHANG_BlindTurn.PT_BLINDTURN_ONE] = "sy_yszmyl",
	[PT_YINGSANZHANG_BlindTurn.PT_BLINDTURN_TWO] = "sy_yszmll",
	[PT_YINGSANZHANG_BlindTurn.PT_BLINDTURN_THREE] = "sy_yszmsl",
}

this.PT_YINGSANZHANG_State = 
{
	PT_YINGSANZHANG_YIZHUNBEI = "room_27" ,--已准备
}
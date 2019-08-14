--[[--
 * @Description: 当前局数据  
 ]]
 local gameRound_data = {
	zhuang_viewSeat = 0, -- 庄家本地座位号
	leftCard = 144, -- 剩余牌数
	isStart = false, -- 游戏开始
	beginSendCard = false, -- 是否已经开始出牌
	playerFlowerCards = {}, -- 花牌
	hintInfoMap = nil, -- 出哪张排后可以听
	currentTingInfo = nil, -- 听牌 和 胡的番数
	isTing = false, -- 是否是听得状态
	selfOutCard = 0, -- 自己上一次出的牌 用于自动出牌的交验
	supportClientTing = false, -- 是否支持客户端计算听
	currentPlayViewSeat = 0, -- 当前出牌玩家
	mjMap = {}, -- 所有在显示的牌
	tingVersion = 0, -- 听版本
}

function gameRound_data:New(o)
	local o = o or {}
	setmetatable(o,{__index = self})
	return o
end

-- function gameRound_data:Clear()
-- 	self.zhuang_viewSeat = 0 -- 庄家本地座位号
-- 	self.leftCard = 144 -- 剩余牌数
-- 	self.isStart = false -- 游戏开始
-- 	self.beginSendCard = false -- 是否已经开始出牌
-- 	self.playerFlowerCards = {} -- 花牌
-- 	self.hintInfoMap = nil -- 出哪张排后可以听
-- 	self.currentTingInfo = nil -- 听牌 和 胡的番数
-- 	self.isTing = false -- 是否是听得状态
-- 	self.selfOutCard = 0 -- 自己上一次出的牌 用于自动出牌的交验
-- 	self.supportClientTing = false -- 是否支持客户端计算听
-- 	self.currentPlayViewSeat = 0 -- 当前出牌玩家
-- 	self.mjMap = {} -- 所有在显示的牌
-- 	self.tingVersion = 0 -- 听版本
-- end

return gameRound_data
-- --[[--
--  * @Description: 结算玩家牌信息类
--  ]]
-- local mahjong_small_reward_player_card_data = class("mahjong_small_reward_player_card_data")
-- function mahjong_small_reward_player_card_data:ctor()
-- 	self.combineTile = {} -- {{1,2,3},{4,4,4,4}}
-- 	self.handCards = {} -- {4,15,7,2,31,22}
-- 	self.winCard = 0
-- end



--[[--
 * @Description: 结算信息类
 ]]
local mahjong_small_reward_data = class("mahjong_small_reward_data")
function mahjong_small_reward_data:ctor()
	self.titleIndex = 10001
	self.isWinBG = false
	self.number = 0
	self.isHuang = false
	self.winViewSeat = 0
	self.playersInfo = {} -- mahjong_small_reward_player_data:create()
	self.specialCardType = "" -- "hun"\"jin"
	self.specialCardValues = {}
	self.type = 1 -- 默认为1
end

return mahjong_small_reward_data
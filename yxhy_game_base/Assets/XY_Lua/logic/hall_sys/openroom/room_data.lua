--[[--
 * @Description: 房间数据
 * @Author:      zhy, shine走读代码
 * @FileName:    room_data.lua
 * @DateTime:    2017-06-30
 ]]

require "logic/network/shisanshui_request_interface"
require "logic/niuniu_sys/network/niuniu_request_interface"
require "logic/poker_sys/sangong_sys/network/sangong_request_interface"
require "logic/poker_sys/yingsanzhang_sys/network/yingsanzhang_request_interface"
require "logic/poker_sys/common/network/poker_request_interface"
require "logic/network/messagedefine"
require "logic/shisangshui_sys/card_data_manage"


room_data = {}
local this = room_data 


local recommond_cards
--十三水房间配置数据
local sssroomDataInfo = 
{
	--加一色做庄
	leadership=false,
	--买码
	buyhorse=false,
	--总局数
	rounds = 8,
	--当前局
	cur_playNum = 10,
	-- 人数
	pnum = 2,
	-- 加色
	addColor= 0,
	-- 大小鬼
	joker = 0,
	-- 闲家最大倍数
	maxfan = 1,
	gid =11,
	rno = nil,
	owner_uid = nil, --房主的uid不是自已的uid
	mySelf_uid = nil, --自已的uid
	rid = nil,
	defaut = {},
	
	ready_time = 0,
	place_card_time = 0,--截止时间
	placeCardTime = 300
} 

--////////////////////////////////////////外部调用接口start//////////////////////////////////


function this.SetPlaceCardTime(placeCardEndTime)
	sssroomDataInfo.place_card_time = placeCardEndTime + os.time()
end

function this.SetPlaceCardSerTime(timeo)
	if timeo ~= nil then
		sssroomDataInfo.place_card_time = timeo + os.time()
	end
end

-- function this.GetReadyTime()
-- 	if sssroomDataInfo.ready_time == nil then
-- 		sssroomDataInfo.ready_time = 0
-- 	end
-- 	return sssroomDataInfo.ready_time
-- end

function this.GetPlaceCardTime()
	if sssroomDataInfo.place_card_time == nil then
		sssroomDataInfo.place_card_time = 0
	end
	return sssroomDataInfo.place_card_time
end

function this.GetRecommondCard()
	return recommond_cards
end

function this.SetRecommondCard(cards)
	recommond_cards = cards
	local place_cardUi =  UI_Manager:Instance():GetUiFormsInShowList("place_card")
	if place_cardUi ~= nil and cards ~= nil then
		place_cardUi:SetRecommondCard(recommendCards)
	end
end

 

--////////////////////////////////////////外部调用接口end////////////////////////////////////


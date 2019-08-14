--[[--
 * @Description: 牛牛消息的数据中心
 * @Author:      xuemin.lin
 * @FileName:    niuniu_ui_controller.lua
 * @DateTime:    2017-10-12
 ]]
require "logic/niuniu_sys/other/niuniu_rule_define"
sangong_data_manage_Instance = nil
local sangong_data_manage = class("sangong_data_manage")

function sangong_data_manage:ctor()
	self.phpData = {}
	self.roomInfo = {}	
	------------------协议数据-----------------------------
	self.EnterData = nil -- Enter数据
	self.AskChooseBankerData = nil --选庄(固定庄家)数据
	self.BankerData = nil	--定庄数据
	self.ReadyData = nil --准备数据
	self.AskReadyData = nil --提示准备
	self.offlineData = nil --离线
	self.ReadyData = nil --准备
	self.AskRobbankerData = nil -- 提示抢庄
	self.GameStartData = nil --游戏开始
	self.OnAskMultData = nil --提示选择倍数
	self.OnMultData = nil --选择倍数通知
	self.OnRobbankerData = nil --抢庄倍数通知
	self.OnAskOpenCardData = nil--提示亮牌
	self.OnOpenCardData = nil --某人已经亮牌
	self.DealData = nil --发牌
	self.CompareResultData = nil --比牌结果
	self.OnSyncTableData = nil --断线重连
	self.SmallRewardData = nil --小结算数据
	------------------------------
	
	--------------------
    self.IsOpenCuoPaiUI = false
	
end 

function sangong_data_manage:GetInstance()
	
    if sangong_data_manage_Instance == nil  then
		Trace("Error !! niuniu_msg_manage no create")
		sangong_data_manage_Instance = require ("logic.poker_sys.sangong_sys.cmd_manage.sangong_data_manage"):create()
    end
    return sangong_data_manage_Instance

end

function sangong_data_manage:DestoryInstance()
	sangong_data_manage_Instance = nil
end

function sangong_data_manage:SetRoomInfo(tbl)
	self.roomInfo = tbl._para
	self:SetRoomCfgInfoToRoomDataCenter()
end

function sangong_data_manage:GetRoomInfo()
	return self.roomInfo
end

--[[
	现在房间配置信息跟roomdata_center抽离，但为了兼容以前的部份设计。
	给roomdata_center设值
  ]]
function sangong_data_manage:SetRoomCfgInfoToRoomDataCenter()
	if self.roomInfo ~= nil then
		roomdata_center.maxplayernum = self.roomInfo.nPlayerNum
	end
end

--判断我自己是不是房主
function sangong_data_manage:IsOwner()
	local isOwner = false
	local mySelfUid =  data_center.GetLoginUserInfo().uid
	if tonumber(self.roomInfo.owner_uid) == tonumber(mySelfUid) then
		isOwner = true
	end
	return isOwner
end

--判断我自己是不是庄家
function sangong_data_manage:IsBanker()
	local isBanker = false
	local myChairId = player_data.GetUserLogicSeat()
	if self.BankerData ~= nil then
		local bankerChairId = self.BankerData._para.banker
		if tonumber(myChairId) == tonumber(bankerChairId) then
			isBanker = true
			Trace("我是庄家")
		end
	end
	return isBanker
end

--判断是不是固定庄这家模式
function sangong_data_manage:IsFixedBankerMode()
	local value = false
	local model = niuniu_rule_define.SUB_BULL_BANKER.SUB_BULL_BANKER_FIXED
	if self.roomInfo.GameSetting.takeTurnsMode == model then
		value = true
	end
	return value
end

return sangong_data_manage




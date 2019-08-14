require "logic/shisangshui_sys/cmd_manage/play_mode_shisanshui"
shisanshui_msg_manage_instance = nil

local base = require("logic.poker_sys.common.poker_msg_manage_base")
local shisanshui_msg_manage = class("shisanshui_msg_manage",base)

function shisanshui_msg_manage:ctor()
	self.play_mode_shisanshui = require("logic.shisangshui_sys.cmd_manage.play_mode_shisanshui"):create()
	self.ui_controller = require("logic.shisangshui_sys.cmd_manage.shisanshui_ui_sys"):create()
--	self.play_mode_shisanshui:ConstructComponents()
	self:Initialize()
	Trace("=================shisanshui_msg_manage:ctor================")
end


function shisanshui_msg_manage:GetInstance()
    if shisanshui_msg_manage_instance == nil  then
		Trace("Error !! shisanshui_msg_manage no create")
		shisanshui_msg_manage_instance = require ("logic.shisangshui_sys.cmd_manage.shisanshui_msg_manage"):create()
    end
    return shisanshui_msg_manage_instance
end

function shisanshui_msg_manage:GetPlayModeShiSanShuiInstance()
	if self.play_mode_shisanshui == nil then
		Trace("+++++++Error!!!!!!!!+++++++++".."get play_mode_shisanshui instance error!!!!!")
	end
	return self.play_mode_shisanshui
end

function shisanshui_msg_manage:GetShiSanShuiUiSysInstance()
	if self.ui_controller == nil then
		Trace("+++++++Error!!!!!!!!+++++++++".."get ui_controller instance error!!!!!")
	end
	return self.ui_controller
end

function shisanshui_msg_manage:OnPlayerEnter(tbl)
	Trace("++++++++++++++OnPlayerEnter++++++++++++++="..tostring(tbl))
	slot(self.play_mode_shisanshui:OnPlayerEnter(tbl),self.play_mode_shisanshui)
	slot(self.ui_controller:OnPlayerEnter(tbl),self.ui_controller)
end

 function shisanshui_msg_manage:OnPlayerReady(tbl)
--	slot(self.play_mode_shisanshui:OnPlayerReady(tbl),self.play_mode_shisanshui)
	slot(self.ui_controller:OnPlayerReady(tbl),self.ui_controller)
end

 function shisanshui_msg_manage:OnGameStart(tbl)
 	base.OnGameStart(self,tbl)
	slot(self.play_mode_shisanshui:OnGameStart(tbl),self.play_mode_shisanshui)
end

 function shisanshui_msg_manage:OnGameDeal(tbl)
	slot(self.play_mode_shisanshui:OnGameDeal(tbl),self.play_mode_shisanshui)
	slot(self.ui_controller:OnGameDeal(tbl),self.ui_controller)
end

 function shisanshui_msg_manage:OnAskChoose(tbl)
	slot(self.play_mode_shisanshui:OnAskChoose(tbl),self.play_mode_shisanshui)
	
end

 function shisanshui_msg_manage:OnChooseOK(tbl)
	slot(self.play_mode_shisanshui:OnChooseOK(tbl),self.play_mode_shisanshui)
	
end

 function shisanshui_msg_manage:OnCompareStart(tbl)
	slot(self.play_mode_shisanshui:OnCompareStart(tbl),self.play_mode_shisanshui)
	slot(self.ui_controller:OnCompareStart(tbl),self.ui_controller)
end

 function shisanshui_msg_manage:OnCompareResult(tbl)
	slot(self.play_mode_shisanshui:OnCompareResult(tbl),self.play_mode_shisanshui)
end

 function shisanshui_msg_manage:OnCompareEnd(tbl)
	slot(self.play_mode_shisanshui:OnCompareEnd(tbl),self.play_mode_shisanshui)
	
end

 function shisanshui_msg_manage:OnGameRewards(tbl)
	
	slot(self.ui_controller:OnGameRewards(tbl),self.ui_controller)
end

 function shisanshui_msg_manage:OnGameEnd(tbl)
	slot(self.play_mode_shisanshui:OnGameEnd(tbl),self.play_mode_shisanshui)
end

 function shisanshui_msg_manage:OnSyncBegin(tbl)
	slot(self.play_mode_shisanshui:OnSyncBegin(tbl),self.play_mode_shisanshui)
	slot(self.ui_controller:OnSyncBegin(tbl),self.ui_controller)
end

 function shisanshui_msg_manage:OnSyncTable(tbl)
	slot(self.play_mode_shisanshui:OnSyncTable(tbl),self.play_mode_shisanshui)
	slot(self.ui_controller:OnSyncTable(tbl),self.ui_controller)
end

 function shisanshui_msg_manage:OnUserLeave(tbl)
 	base.OnUserLeave(self,tbl)
	slot(self.play_mode_shisanshui:OnUserLeave(tbl),self.play_mode_shisanshui)
end

 function shisanshui_msg_manage:OnAllMult(tbl)
	slot(self.play_mode_shisanshui:OnAllMult(tbl),self.play_mode_shisanshui)
	slot(self.ui_controller:OnAllMult(tbl),self.ui_controller)
end

 function shisanshui_msg_manage:OnPlayStart(tbl)
	slot(self.ui_controller:OnPlayStart(tbl),self.ui_controller)
end

--[[function shisanshui_msg_manage:OnGameBigRewards(tbl)
	
	slot(self.ui_controller:OnGameBigRewards(tbl),self.ui_controller)
end--]]

 function shisanshui_msg_manage:OnPointsRefresh(tbl)
	
	slot(self.ui_controller:OnPointsRefresh(tbl),self.ui_controller)
end

 function shisanshui_msg_manage:OnAskReady(tbl)
	
	slot(self.ui_controller:OnAskReady(tbl),self.ui_controller)
end

 function shisanshui_msg_manage:OnSyncEnd(tbl)
	
	slot(self.ui_controller:OnSyncEnd(tbl),self.ui_controller)
end

 function shisanshui_msg_manage:OnPlayerOffline(tbl)
	
	slot(self.ui_controller:OnPlayerOffline(tbl),self.ui_controller)
end

 function shisanshui_msg_manage:OnGroupCompareResult(tbl)
	
	slot(self.ui_controller:OnGroupCompareResult(tbl),self.ui_controller)
end

 function shisanshui_msg_manage:OnShowPokerCard(tbl)
	
	slot(self.ui_controller:OnShowPokerCard(tbl),self.ui_controller)
end
 
function shisanshui_msg_manage:OnSpecialCardType(tbl)
	
	
	slot(self.ui_controller:OnSpecialCardType(tbl),self.ui_controller)
end

 function shisanshui_msg_manage:OnReadCard(tbl)

	slot(self.ui_controller:OnReadCard(tbl),self.ui_controller)
end

 function shisanshui_msg_manage:OnAskMult(tbl)
--	slot(self.play_mode_shisanshui:OnAskMult(tbl),self.play_mode_shisanshui)
	slot(self.ui_controller:OnAskMult(tbl),self.ui_controller)
end

 function shisanshui_msg_manage:OnMult(tbl)
	slot(self.ui_controller:OnMult(tbl),self.ui_controller)
end

 function shisanshui_msg_manage:RecommondCard(tbl)
	slot(self.ui_controller:RecommondCard(tbl),self.ui_controller)
end

function shisanshui_msg_manage:EarlySettlement(tbl)
	slot(self.ui_controller:EarlySettlement(tbl),self.ui_controller)
end
	
function shisanshui_msg_manage:FreezeUser(tbl)
	slot(self.ui_controller:FreezeUser(tbl),self.ui_controller)
end
	
function shisanshui_msg_manage:FreezeOwner(tbl)
	slot(self.ui_controller:FreezeOwner(tbl),self.ui_controller)
end

function shisanshui_msg_manage:SetInitialScore(tbl)
	slot(self.ui_controller:SetInitialScore(tbl),self.ui_controller)
end

function shisanshui_msg_manage:SetShootScore(tbl)
	slot(self.ui_controller:SetShootScore(tbl),self.ui_controller)
end

function shisanshui_msg_manage:SetAllShootScore(tbl)
	slot(self.ui_controller:SetAllShootScore(tbl),self.ui_controller)
end

function shisanshui_msg_manage:SetCodeScore(tbl)
	slot(self.ui_controller:SetCodeScore(tbl),self.ui_controller)
end

function shisanshui_msg_manage:ShowSpecial(tbl)
	slot(self.ui_controller:ShowSpecial(tbl),self.ui_controller)
end

function shisanshui_msg_manage:ShowLargeResult(tbl)
	slot(self.ui_controller:ShowLargeResult(tbl),self.ui_controller)
end

function shisanshui_msg_manage:PlaceCardCountDown(time)
	slot(self.ui_controller:PlaceCardCountDown(time),self.ui_controller)
end

function shisanshui_msg_manage:OnAskChooseBanker(tbl)
	slot(self.ui_controller:OnAskChooseBanker(tbl),self.ui_controller)
end

function shisanshui_msg_manage:OnBanker(tbl)
	slot(self.ui_controller:OnBanker(tbl),self.ui_controller)
end

--[[--
 * @Description: 更换桌布  
 ]]
function shisanshui_msg_manage:OnChangeDesk(tbl)
    self.play_mode_shisanshui:ChangeDeskCloth()
end

function shisanshui_msg_manage:IsShowSelfSpecial(state)
	slot(self.ui_controller:IsShowSelfSpecial(state),self.ui_controller)
end

function shisanshui_msg_manage:OpenSelfCard(state)
	slot(self.play_mode_shisanshui:TouchShowCards(state),self.play_mode_shisanshui)
end

function shisanshui_msg_manage:MouseBinDown(position)
	slot(self.play_mode_shisanshui:MouseBinDown(position),self.play_mode_shisanshui)
end

function shisanshui_msg_manage:ReadyDisCountDowm(time)
	slot(self.ui_controller:ReadyDisCountDowm(time),self.ui_controller)
end

function shisanshui_msg_manage:Initialize()
	base.Initialize(self)
	Notifier.regist(cmdName.GAME_SOCKET_ENTER, slot(self.OnPlayerEnter,self))--玩家进入
	Notifier.regist(cmdName.GAME_SOCKET_ASK_READY, slot(self.OnAskReady,self))--请求准备
	Notifier.regist(cmdName.GAME_SOCKET_READY, slot(self.OnPlayerReady,self))--玩家准备
	Notifier.regist(cmdName.GAME_SOCKET_GAME_DEAL, slot(self.OnGameDeal,self))--发牌
	Notifier.regist(cmd_shisanshui.ASK_CHOOSE,  slot(self.OnAskChoose,self)) --摆牌
	Notifier.regist(cmd_shisanshui.CHOOSE_OK, slot(self.OnChooseOK,self))
	Notifier.regist(cmd_shisanshui.COMPARE_START, slot(self.OnCompareStart,self))  --比牌开始
	Notifier.regist(cmd_shisanshui.COMPARE_RESULT, slot(self.OnCompareResult,self)) --比牌结果
	Notifier.regist(cmd_shisanshui.COMPARE_END, slot(self.OnCompareEnd,self)) -- 比牌结束
	Notifier.regist(cmdName.GAME_SOCKET_SMALL_SETTLEMENT, slot(self.OnGameRewards,self))--结算
	Notifier.regist(cmdName.GAME_SOCKET_GAMEEND, slot(self.OnGameEnd,self))--游戏结束
	Notifier.regist(cmdName.GAME_SOCKET_SYNC_BEGIN, slot(self.OnSyncBegin,self))--重连同步开始
	Notifier.regist(cmdName.GAME_SOCKET_SYNC_TABLE, slot(self.OnSyncTable,self))--重连同步表
	Notifier.regist(cmdName.GAME_SOCKET_SYNC_END, slot(self.OnSyncEnd,self))--重连同步结束
	
	Notifier.regist(cmd_shisanshui.FuZhouSSS_ALLMULT,  slot(self.OnAllMult,self))  --选择倍数通知(所有人的选择倍数)
	Notifier.regist(cmdName.MAHJONG_PLAY_CARDSTART, slot(self.OnPlayStart,self))--打牌开始
--	Notifier.regist(cmdName.GAME_SOCKET_LUMP_SUM, slot(self.OnGameBigRewards,self))--大结算
	Notifier.regist(cmdName.F1_POINTS_REFRESH, slot(self.OnPointsRefresh,self))--玩家金币更新
	Notifier.regist(cmdName.GAME_SOCKET_OFFLINE, slot(self.OnPlayerOffline,self))--用户掉线
	Notifier.regist(cmd_shisanshui.Group_Compare_result, slot(self.OnGroupCompareResult,self)) --第一组比牌完成通知
	Notifier.regist(cmd_shisanshui.ShowPokerCard, slot(self.OnShowPokerCard,self))
	Notifier.regist(cmd_niuniu.ASK_CHOOSEBANKER,slot(self.OnAskChooseBanker,self))	--选庄(固定庄家)
	Notifier.regist(cmdName.GAME_SOCKET_BANKER,slot(self.OnBanker,self)) 			--定庄

	Notifier.regist(cmd_shisanshui.SpecialCardType, slot(self.OnSpecialCardType,self)) -- 在特殊排型上显一个张特殊牌型的图标
	Notifier.regist(cmd_shisanshui.ReadCard, slot(self.OnReadCard,self)) -- 理牌
	Notifier.regist(cmd_shisanshui.FuZhouSSS_ASKMULT, slot(self.OnAskMult,self)) --等待闲家选择倍数 
	Notifier.regist(cmd_shisanshui.FuZhouSSS_MULT,  slot(self.OnMult,self))  -- 选择倍数通知(回复自己选择倍数)
	Notifier.regist(cmd_shisanshui.Card_RECOMMEND,  slot(self.RecommondCard,self))		--推荐牌
	
	Notifier.regist(cmdName.MSG_EARLY_SETTLEMENT,slot(self.EarlySettlement,self)) -- 管理员强制提前进行游戏结算
	Notifier.regist(cmdName.MSG_FREEZE_USER,slot(self.FreezeUser,self)) --冻结帐号
	Notifier.regist(cmdName.MSG_FREEZE_OWNER,slot(self.FreezeOwner,self)) --未开局管理员封房主号
	Notifier.regist(cmd_shisanshui.FuZhouSSS_SetScore,slot(self.SetInitialScore,self)) --通知ui比牌初始零分
	Notifier.regist(cmd_shisanshui.Shoot_Compare_result,slot(self.SetShootScore,self))	--通知UI更新打枪分数
	Notifier.regist(cmd_shisanshui.AllShoot_Compare_result,slot(self.SetAllShootScore,self))	--通知UI更新全垒打分数
	Notifier.regist(cmd_shisanshui.Code__Compare_result,slot(self.SetCodeScore,self))	--通知UI更新码牌分数
	Notifier.regist(cmd_shisanshui.SpecialChoose_Show,slot(self.ShowSpecial,self))	--通知UI显示自己特殊牌型
	
	Notifier.regist(cmdName.GAME_SOCKET_BIG_SETTLEMENT, slot(self.ShowLargeResult,self))	-- socket大结算
	Notifier.regist(cmd_shisanshui.PlaceCardCountDown,slot(self.PlaceCardCountDown,self)) --显示摆牌的倒计时时钟
	Notifier.regist(cmdName.MSG_CHANGE_DESK,slot(self.OnChangeDesk, self)) --更换桌布
	Notifier.regist(cmd_shisanshui.IsShowSelfSpecial,slot(self.IsShowSelfSpecial,self)) --显示隐藏自己的特殊牌型图标
	Notifier.regist(cmd_shisanshui.OpenSelfCard,slot(self.OpenSelfCard,self)) --打开自己摆牌
	Notifier.regist(cmdName.MSG_MOUSE_BTN_DOWN,slot(self.MouseBinDown,self))--鼠标事件

	Notifier.regist(cmdName.ReadyDisCountDowm,slot(self.ReadyDisCountDowm,self)) --未准备解散的倒计时时钟
end

function shisanshui_msg_manage:Uninitialize()
	base.Uninitialize(self)
	Notifier.remove(cmdName.GAME_SOCKET_ENTER,  slot(self.OnPlayerEnter,self))--玩家进入
	Notifier.remove(cmdName.GAME_SOCKET_READY, slot(self.OnPlayerReady,self))--玩家准备
	Notifier.remove(cmdName.GAME_SOCKET_GAME_DEAL, slot(self.OnGameDeal,self))--发牌
	Notifier.remove(cmd_shisanshui.ASK_CHOOSE,  slot(self.OnAskChoose,self)) --摆牌
	Notifier.remove(cmd_shisanshui.CHOOSE_OK, slot(self.OnChooseOK,self))
	Notifier.remove(cmd_shisanshui.COMPARE_START, slot(self.OnCompareStart,self))  --比牌开始
	Notifier.remove(cmd_shisanshui.COMPARE_RESULT, slot(self.OnCompareResult,self)) --比牌结果
	Notifier.remove(cmd_shisanshui.COMPARE_END, slot(self.OnCompareEnd,self)) -- 比牌结束
	Notifier.remove(cmdName.GAME_SOCKET_SMALL_SETTLEMENT, slot(self.OnGameRewards,self))--结算
	Notifier.remove(cmdName.GAME_SOCKET_GAMEEND, slot(self.OnGameEnd,self))--游戏结束
	Notifier.remove(cmdName.GAME_SOCKET_SYNC_BEGIN, slot(self.OnSyncBegin,self))--重连同步开始
	Notifier.remove(cmdName.GAME_SOCKET_SYNC_TABLE, slot(self.OnSyncTable,self))--重连同步表
	
	Notifier.remove(cmd_shisanshui.FuZhouSSS_ALLMULT,  slot(self.OnAllMult,self))  --选择倍数通知(所有人的选择倍数)
	Notifier.remove(cmdName.MAHJONG_PLAY_CARDSTART, slot(self.OnPlayStart,self))--打牌开始
	--Notifier.remove(cmdName.GAME_SOCKET_LUMP_SUM, slot(self.OnGameBigRewards,self))--大结算
	Notifier.remove(cmdName.GAME_SOCKET_ASK_READY, slot(self.OnAskReady,self))--请求准备
	Notifier.remove(cmdName.GAME_SOCKET_SYNC_END, slot(self.OnSyncEnd,self))--重连同步结束
	Notifier.remove(cmdName.GAME_SOCKET_OFFLINE, slot(self.OnPlayerOffline,self))--用户掉线
	Notifier.remove(cmd_shisanshui.Group_Compare_result, slot(self.OnGroupCompareResult,self)) --第一组比牌完成通知
	Notifier.remove(cmd_shisanshui.ShowPokerCard, slot(self.OnShowPokerCard,self))
	Notifier.remove(cmdName.F1_POINTS_REFRESH, slot(self.OnPointsRefresh,self))--玩家金币更新
	Notifier.remove(cmd_niuniu.ASK_CHOOSEBANKER,slot(self.OnAskChooseBanker,self))	--选庄(固定庄家)
	Notifier.remove(cmdName.GAME_SOCKET_BANKER,slot(self.OnBanker,self)) 			--定庄

	Notifier.remove(cmd_shisanshui.SpecialCardType, slot(self.OnSpecialCardType,self)) -- 在特殊排型上显一个张特殊牌型的图标
	Notifier.remove(cmd_shisanshui.ReadCard, slot(self.OnReadCar,self)) -- 理牌
	Notifier.remove(cmd_shisanshui.FuZhouSSS_ASKMULT, slot(self.OnAskMult,self)) --等待闲家选择倍数 
	Notifier.remove(cmd_shisanshui.FuZhouSSS_MULT,  slot(self.OnMult,self))  -- 选择倍数通知(回复自己选择倍数)
	Notifier.remove(cmd_shisanshui.Card_RECOMMEND,  slot(self.RecommondCard,self))		--推荐牌
	Notifier.remove(cmdName.MSG_EARLY_SETTLEMENT,slot(self.EarlySettlement,self)) -- 管理员强制提前进行游戏结算
	Notifier.remove(cmdName.MSG_FREEZE_USER,slot(self.FreezeUser,self)) --冻结帐号
	Notifier.remove(cmdName.MSG_FREEZE_OWNER,slot(self.FreezeOwner,self)) --未开局管理员封房主号
	Notifier.remove(cmd_shisanshui.FuZhouSSS_SetScore,slot(self.SetInitialScore,self)) --通知ui比牌初始零分
	Notifier.remove(cmd_shisanshui.Shoot_Compare_result,slot(self.SetShootScore,self))	--通知UI更新打枪分数
	Notifier.remove(cmd_shisanshui.AllShoot_Compare_result,slot(self.SetAllShootScore,self))	--通知UI更新全垒打分数
	Notifier.remove(cmd_shisanshui.Code__Compare_result,slot(self.SetCodeScore,self))	--通知UI更新码牌分数
	Notifier.remove(cmd_shisanshui.SpecialChoose_Show,slot(self.ShowSpecial,self))	--通知UI显示自己特殊牌型
	
	Notifier.remove(cmdName.GAME_SOCKET_BIG_SETTLEMENT, slot(self.ShowLargeResult,self))	-- socket大结算
	Notifier.remove(cmd_shisanshui.PlaceCardCountDown,slot(self.PlaceCardCountDown,self)) --显示摆牌的倒计时时钟
	Notifier.remove(cmdName.MSG_CHANGE_DESK,slot(self.OnChangeDesk, self)) --更换桌布
	Notifier.remove(cmd_shisanshui.IsShowSelfSpecial,slot(self.IsShowSelfSpecial,self)) --显示隐藏自己的特殊牌型图标
	Notifier.remove(cmd_shisanshui.OpenSelfCard,slot(self.OpenSelfCard,self)) --打开自己摆牌
	Notifier.remove(cmdName.MSG_MOUSE_BTN_DOWN,slot(self.MouseBinDown,self))--鼠标事件
	
	Notifier.remove(cmdName.ReadyDisCountDowm,slot(self.ReadyDisCountDowm,self)) --未准备解散的倒计时时钟
    
	
	room_usersdata_center.RemoveAll()
	UI_Manager:Instance():CloseUiForms("poker_largeResult_ui",true)
	UI_Manager:Instance():CloseUiForms("place_card",true)
	UI_Manager:Instance():CloseUiForms("shisanshui_smallResult_ui")
	UI_Manager:Instance():CloseUiForms("common_card")
	UI_Manager:Instance():CloseUiForms("prepare_special")
	shisanshui_msg_manage_instance = nil
end

return shisanshui_msg_manage

niuniu_msg_manage_instance = nil

local base = require("logic.poker_sys.common.poker_msg_manage_base")
local niuniu_msg_manage = class("niuniu_msg_manage",base)

function niuniu_msg_manage:ctor()
	self.ui_controller = require("logic.niuniu_sys.ui.niuniu_ui_controller"):create()
	self.scene_controller = require("logic.niuniu_sys.scene.niuniu_scene_controller"):create()
	self.data_manage = require("logic.niuniu_sys.cmd_manage.niuniu_data_manage"):GetInstance()
	
	self:Initialize()
	Trace("=================niuniu_msg_manage:ctor================")
end

function niuniu_msg_manage:GetInstance()
    if niuniu_msg_manage_instance == nil  then
		niuniu_msg_manage_instance = require ("logic.niuniu_sys.cmd_manage.niuniu_msg_manage"):create()
    end
    return niuniu_msg_manage_instance
end

function niuniu_msg_manage:GetNiuNiuSceneControllerInstance()
	if self.scene_controller == nil then
		logError("+++++++Error!!!!!!!!+++++++++".."get scene_controller instance error!!!!!")
	end
	return self.scene_controller
end

function niuniu_msg_manage:OnPlayerEnter(tbl)
	Trace("++++++++++++++OnPlayerEnter++++++++++++++="..tostring(tbl))
	self.data_manage.EnterData = tbl
	slot(self.ui_controller:OnPlayerEnter(tbl),self.ui_controller)
	slot(self.scene_controller:OnPlayerEnter(tbl),self.scene_controller)
end

function niuniu_msg_manage:OnAskChooseBanker(tbl)
	self.data_manage.AskChooseBankerData = tbl
	slot(self.ui_controller:OnAskChooseBanker(),self.ui_controller)
end

function niuniu_msg_manage:OnBanker(tbl)
	self.data_manage.BankerData = tbl
	slot(self.ui_controller:OnBanker(),self.ui_controller)
end

 function niuniu_msg_manage:OnAskReady(tbl)
	self.data_manage.AskReadyData = tbl
	slot(self.ui_controller:OnAskReady(),self.ui_controller)
end

 function niuniu_msg_manage:OnPlayerReady(tbl)
	
	self.data_manage.ReadyData = tbl
	slot(self.ui_controller:OnPlayerReady(),self.ui_controller)
	slot(self.scene_controller:OnPlayerReady(),self.scene_controller)
end

 function niuniu_msg_manage:OnAskMult(tbl)
 	self.data_manage.OnAskMultData = tbl
	slot(self.ui_controller:OnAskMult(),self.ui_controller)
end

 function niuniu_msg_manage:OnMult(tbl)
 	self.data_manage.OnMultData = tbl
	slot(self.ui_controller:OnMult(),self.ui_controller)
end

 function niuniu_msg_manage:OnAllMult(tbl)
	self.data_manage.OnAllMultData = tbl
	slot(self.ui_controller:OnAllMult(),self.ui_controller)
end

--提示抢庄
function niuniu_msg_manage:OnAskRobbanker(tbl)
	self.data_manage.AskRobbankerData = tbl
	slot(self.ui_controller:OnAskRobbanker(),self.ui_controller)
end

--抢庄倍数通知
function niuniu_msg_manage:OnRobbanker(tbl)
	self.data_manage.OnRobbankerData = tbl
	slot(self.ui_controller:OnRobbanker(),self.ui_controller)
end

 function niuniu_msg_manage:OnGameDeal(tbl)
 	self.data_manage.DealData = tbl
	slot(self.ui_controller:OnGameDeal(tbl),self.ui_controller)
	slot(self.scene_controller:OnGameDeal(tbl),self.scene_controller)
end


--提示亮牌
function niuniu_msg_manage:OnAskOpenCard(tbl)
	self.data_manage.OnAskOpenCardData = tbl
	slot(self.ui_controller:OnAskOpenCard(),self.ui_controller)
	slot(self.scene_controller:OnAskOpenCard(),self.scene_controller)
end

--某人已经亮牌
function niuniu_msg_manage:OnOpenCard(tbl)
	self.data_manage.OnOpenCardData = tbl
	slot(self.ui_controller:OnOpenCard(),self.ui_controller)
	slot(self.scene_controller:OnOpenCard(),self.scene_controller)
end

 function niuniu_msg_manage:OnCompareResult(tbl)
	self.data_manage.CompareResultData = tbl
	slot(self.ui_controller:OnCompareResult(),self.ui_controller)
	slot(self.scene_controller:OnCompareResult(tbl),self.scene_controller)
end

function niuniu_msg_manage:OnGameRewards(tbl)	
	self.data_manage.SmallRewardData = tbl
	slot(self.ui_controller:OnGameRewards(tbl),self.ui_controller)
end

 function niuniu_msg_manage:OnGameEnd(tbl)
	self.data_manage.GameEndData = tbl
	slot(self.ui_controller:OnGameEnd(),self.ui_controller)
	slot(self.scene_controller:OnGameEnd(),self.scene_controller)
end

 function niuniu_msg_manage:OnSyncBegin(tbl)
	slot(self.ui_controller:OnSyncBegin(tbl),self.ui_controller)
end

 function niuniu_msg_manage:OnSyncTable(tbl)
	self.data_manage.OnSyncTableData = tbl
	slot(self.ui_controller:OnSyncTable(),self.ui_controller)
	slot(self.scene_controller:OnSyncTable(),self.scene_controller)

end

function niuniu_msg_manage:OnSyncEnd(tbl)
	slot(self.ui_controller:OnSyncEnd(tbl),self.ui_controller)
end

 function niuniu_msg_manage:OnPointsRefresh(tbl)
	slot(self.ui_controller:OnPointsRefresh(tbl),self.ui_controller)
end



 function niuniu_msg_manage:OnPlayerOffline(tbl)
	self.data_manage.offlineData = tbl
	slot(self.ui_controller:OnPlayerOffline(),self.ui_controller)
end
 
 function niuniu_msg_manage:OnSpecialCardType(tbl)
	slot(self.ui_controller:OnSpecialCardType(tbl),self.ui_controller)
end

 function niuniu_msg_manage:OnReadCard(tbl)

	slot(self.ui_controller:ShowSpecialCardAnimation(tbl),self.ui_controller)
end

 function niuniu_msg_manage:RecommondCard(tbl)
	slot(self.ui_controller:RecommondCard(tbl),self.ui_controller)
end

function niuniu_msg_manage:EarlySettlement(tbl)
	slot(self.ui_controller:EarlySettlement(tbl),self.ui_controller)
end
	
function niuniu_msg_manage:FreezeUser(tbl)
	slot(self.ui_controller:FreezeUser(tbl),self.ui_controller)
end
	
function niuniu_msg_manage:FreezeOwner(tbl)
	slot(self.ui_controller:FreezeOwner(tbl),self.ui_controller)
end

function niuniu_msg_manage:MouseBinDown(position)
		slot(self.scene_controller:MouseBinDown(position),self.scene_controller)
end

function niuniu_msg_manage:ShowLargeResult(tbl)
	slot(self.ui_controller:ShowLargeResult(tbl),self.ui_controller)
end

function niuniu_msg_manage:OnDragAction(tbl)
	slot(self.scene_controller:OnDragAction(tbl),self.scene_controller)
end

function niuniu_msg_manage:OnGetLastCardPosition(position)
	slot(self.ui_controller:OnGetLastCardPosition(position),self.ui_controller)
end

function niuniu_msg_manage:SetFinishState(tbl)
	slot(self.ui_controller:SetFinishState(tbl),self.ui_controller)
end

function niuniu_msg_manage:OnMidJoin(tbl)
	self.ui_controller:OnMidJoin(tbl)
end

--[[--
 * @Description: 更换桌布  
 ]]
function niuniu_msg_manage:OnChangeDesk(tbl)
    self.scene_controller:ChangeDeskCloth()
end

--手指离开桌面
function niuniu_msg_manage:OnFingerUpAction(tbl)
	slot(self.scene_controller:OnFingerUpAction(tbl),self.scene_controller)
end

function niuniu_msg_manage:Initialize()
	base.Initialize(self)
	Notifier.regist(cmdName.GAME_SOCKET_ENTER, slot(self.OnPlayerEnter,self))--玩家进入
	Notifier.regist(cmd_niuniu.ASK_CHOOSEBANKER,slot(self.OnAskChooseBanker,self))--选庄(固定庄家)
	Notifier.regist(cmdName.GAME_SOCKET_BANKER,slot(self.OnBanker,self)) --定庄
	Notifier.regist(cmd_niuniu.ASK_ROBBANKER,slot(self.OnAskRobbanker,self))--提示抢庄
	Notifier.regist(cmd_niuniu.ROBBANKER,slot(self.OnRobbanker,self)) --抢庄倍数通知
	Notifier.regist(cmdName.GAME_SOCKET_ASK_READY, slot(self.OnAskReady,self))--请求准备
	Notifier.regist(cmdName.GAME_SOCKET_READY, slot(self.OnPlayerReady,self))--玩家准备
	Notifier.regist(cmd_niuniu.ASK_OPENCARD,slot(self.OnAskOpenCard,self)) 	--提示亮牌
	Notifier.regist(cmd_niuniu.OPENCARD,slot(self.OnOpenCard,self)) --某人已经亮牌
	Notifier.regist(cmdName.GAME_SOCKET_GAME_DEAL, slot(self.OnGameDeal,self))--发牌

	Notifier.regist(cmd_shisanshui.COMPARE_START, slot(self.OnCompareStart,self))  --比牌开始
	Notifier.regist(cmd_shisanshui.COMPARE_RESULT, slot(self.OnCompareResult,self)) --比牌结果
	Notifier.regist(cmd_shisanshui.COMPARE_END, slot(self.OnCompareEnd,self)) -- 比牌结束
	Notifier.regist(cmdName.GAME_SOCKET_SMALL_SETTLEMENT, slot(self.OnGameRewards,self))--结算
	Notifier.regist(cmdName.GAME_SOCKET_GAMEEND, slot(self.OnGameEnd,self))--游戏结束
	Notifier.regist(cmdName.GAME_SOCKET_SYNC_BEGIN, slot(self.OnSyncBegin,self))--重连同步开始
	Notifier.regist(cmdName.GAME_SOCKET_SYNC_TABLE, slot(self.OnSyncTable,self))--重连同步表
	Notifier.regist(cmdName.GAME_SOCKET_SYNC_END, slot(self.OnSyncEnd,self))--重连同步结束
	Notifier.regist(cmd_shisanshui.FuZhouSSS_ALLMULT,  slot(self.OnAllMult,self))  --选择倍数通知(所有人的选择倍数)
	Notifier.regist(cmdName.F1_POINTS_REFRESH, slot(self.OnPointsRefresh,self))--玩家金币更新
	Notifier.regist(cmdName.GAME_SOCKET_OFFLINE, slot(self.OnPlayerOffline,self))--用户掉线

	Notifier.regist(cmd_shisanshui.SpecialCardType, slot(self.OnSpecialCardType,self)) -- 在特殊排型上显一个张特殊牌型的图标
	Notifier.regist(cmd_shisanshui.ReadCard, slot(self.OnReadCard,self)) -- 理牌
	Notifier.regist(cmd_shisanshui.FuZhouSSS_ASKMULT, slot(self.OnAskMult,self)) --等待闲家选择倍数 
	Notifier.regist(cmd_shisanshui.FuZhouSSS_MULT,  slot(self.OnMult,self))  -- 选择倍数通知(回复自己选择倍数)
	Notifier.regist(cmd_shisanshui.Card_RECOMMEND,  slot(self.RecommondCard,self))		--推荐牌
	
	Notifier.regist(cmdName.MSG_EARLY_SETTLEMENT,slot(self.EarlySettlement,self)) -- 管理员强制提前进行游戏结算
	Notifier.regist(cmdName.MSG_FREEZE_USER,slot(self.FreezeUser,self)) --冻结帐号
	Notifier.regist(cmdName.MSG_FREEZE_OWNER,slot(self.FreezeOwner,self)) --未开局管理员封房主号
	Notifier.regist(cmd_poker.MID_JOIN, slot(self.OnMidJoin, self))			-- 中途加入
	
	InputManager.AddLock()
	Notifier.regist(cmdName.MSG_MOUSE_BTN_DOWN,slot(self.MouseBinDown,self))--鼠标事件
	Notifier.regist(cmdName.GAME_SOCKET_BIG_SETTLEMENT, slot(self.ShowLargeResult,self))	-- socket大结算
	
	Notifier.regist(cmd_niuniu.ONDRAGACTION,slot(self.OnDragAction,self)) --拖动效果
	Notifier.regist(cmd_niuniu.FingerUP, slot(self.OnFingerUpAction),self) --手指离开屏幕
	Notifier.regist(cmd_niuniu.GETLASTCARDPOSITION,slot(self.OnGetLastCardPosition,self)) --获取最后一张牌的坐标
	Notifier.regist(cmd_niuniu.SetFinishState,slot(self.SetFinishState,self)) --庄家开牌后显示开牌标志
	Notifier.regist(cmdName.MSG_CHANGE_DESK,slot(self.OnChangeDesk, self)) --更换桌布
	
end

function niuniu_msg_manage:Uninitialize()
	base.Uninitialize(self)
	Notifier.remove(cmdName.GAME_SOCKET_ENTER,  slot(self.OnPlayerEnter,self))--玩家进入
	Notifier.remove(cmd_niuniu.ASK_CHOOSEBANKER,slot(self.OnAskChooseBanker,self))--选庄(固定庄家)
	Notifier.remove(cmdName.GAME_SOCKET_BANKER,slot(self.OnBanker,self)) --定庄
	Notifier.remove(cmd_niuniu.ASK_ROBBANKER,slot(self.OnAskRobbanker,self))--提示抢庄
	Notifier.remove(cmd_niuniu.ROBBANKER,slot(self.OnRobbanker,self)) --抢庄倍数通知
	Notifier.remove(cmdName.GAME_SOCKET_READY, slot(self.OnPlayerReady,self))--玩家准备
	Notifier.remove(cmd_niuniu.ASK_OPENCARD,slot(self.OnAskOpenCard,self)) 	--提示亮牌
	Notifier.remove(cmd_niuniu.OPENCARD,slot(self.OnOpenCard,self)) --某人已经亮牌
	Notifier.remove(cmdName.GAME_SOCKET_GAME_DEAL, slot(self.OnGameDeal,self))--发牌
	Notifier.remove(cmd_shisanshui.COMPARE_START, slot(self.OnCompareStart,self))  --比牌开始
	Notifier.remove(cmd_shisanshui.COMPARE_RESULT, slot(self.OnCompareResult,self)) --比牌结果
	Notifier.remove(cmd_shisanshui.COMPARE_END, slot(self.OnCompareEnd,self)) -- 比牌结束
	Notifier.remove(cmdName.GAME_SOCKET_SMALL_SETTLEMENT, slot(self.OnGameRewards,self))--结算
	Notifier.remove(cmdName.GAME_SOCKET_GAMEEND, slot(self.OnGameEnd,self))--游戏结束
	Notifier.remove(cmdName.GAME_SOCKET_SYNC_BEGIN, slot(self.OnSyncBegin,self))--重连同步开始
	Notifier.remove(cmdName.GAME_SOCKET_SYNC_TABLE, slot(self.OnSyncTable,self))--重连同步表
	Notifier.remove(cmd_shisanshui.FuZhouSSS_ALLMULT,  slot(self.OnAllMult,self))  --选择倍数通知(所有人的选择倍数)
	Notifier.remove(cmdName.GAME_SOCKET_ASK_READY, slot(self.OnAskReady,self))--请求准备
	Notifier.remove(cmdName.GAME_SOCKET_SYNC_END, slot(self.OnSyncEnd,self))--重连同步结束
	Notifier.remove(cmdName.GAME_SOCKET_OFFLINE, slot(self.OnPlayerOffline,self))--用户掉线
	Notifier.remove(cmdName.F1_POINTS_REFRESH, slot(self.OnPointsRefresh,self))--玩家金币更新

	Notifier.remove(cmd_shisanshui.SpecialCardType, slot(self.OnSpecialCardType,self)) -- 在特殊排型上显一个张特殊牌型的图标
	Notifier.remove(cmd_shisanshui.ReadCard, slot(self.OnReadCard,self)) -- 理牌
	Notifier.remove(cmd_shisanshui.FuZhouSSS_ASKMULT, slot(self.OnAskMult,self)) --等待闲家选择倍数 
	Notifier.remove(cmd_shisanshui.FuZhouSSS_MULT,  slot(self.OnMult,self))  -- 选择倍数通知(回复自己选择倍数)
	Notifier.remove(cmd_shisanshui.Card_RECOMMEND,  slot(self.RecommondCard,self))		--推荐牌
	Notifier.remove(cmdName.MSG_EARLY_SETTLEMENT,slot(self.EarlySettlement,self)) -- 管理员强制提前进行游戏结算
	Notifier.remove(cmdName.MSG_FREEZE_USER,slot(self.FreezeUser,self)) --冻结帐号
	Notifier.remove(cmdName.MSG_FREEZE_OWNER,slot(self.FreezeOwner,self)) --未开局管理员封房主号

	Notifier.remove(cmd_poker.MID_JOIN, slot(self.OnMidJoin, self))			-- 中途加入
	
	InputManager.ReleaseLock()
	Notifier.remove(cmdName.MSG_MOUSE_BTN_DOWN,slot(self.MouseBinDown,self))--鼠标事件
	Notifier.remove(cmdName.GAME_SOCKET_BIG_SETTLEMENT, slot(self.ShowLargeResult,self))	-- socket大结算
	
	Notifier.remove(cmd_niuniu.ONDRAGACTION,slot(self.OnDragAction,self)) --拖动效果
	Notifier.remove(cmd_niuniu.FingerUP, slot(self.OnFingerUpAction),self) --手指离开屏幕
	Notifier.remove(cmd_niuniu.GETLASTCARDPOSITION,slot(self.OnGetLastCardPosition,self)) --获取最后一张牌的坐标
	Notifier.remove(cmd_niuniu.SetFinishState,slot(self.SetFinishState,self)) --庄家开牌后显示开牌标志
	Notifier.remove(cmdName.MSG_CHANGE_DESK,slot(self.OnChangeDesk, self)) --更换桌布
	
	self.ui_controller = nil
	self.scene_controller = nil
	
	
	room_usersdata_center.RemoveAll()
	UI_Manager:Instance():CloseUiForms("poker_largeResult_ui",true)
	self.data_manage:DestoryInstance()
	niuniu_msg_manage_instance = nil
end

return niuniu_msg_manage
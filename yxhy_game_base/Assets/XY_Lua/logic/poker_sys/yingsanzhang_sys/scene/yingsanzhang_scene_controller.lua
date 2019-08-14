local yingsanzhang_scene_controller = class("yingsanzhang_scene_controller")
function yingsanzhang_scene_controller:ctor()
	self.gvbl = player_seat_mgr.GetViewSeatByLogicSeat
	self.gvbln = player_seat_mgr.GetViewSeatByLogicSeatNum
	self.gmls = player_seat_mgr.GetMyLogicSeat
	self.Camera = Camera.main
	self.data_manage = require("logic.poker_sys.yingsanzhang_sys.cmd_manage.yingsanzhang_data_manage"):GetInstance()
	self.tableComponent = nil
	self:ConstructComponents()
	self.ui = UI_Manager:Instance():GetUiFormsInShowList("yingsanzhang_ui")
end

function yingsanzhang_scene_controller:OnPlayerEnter()
	local tbl = self.data_manage.EnterData
	local viewSeat = self.gvbl(tbl["_src"])
	self.tableComponent:SetCurPlayerList(viewSeat)
end

function yingsanzhang_scene_controller:OnPlayerReady()
	local tbl = self.data_manage.ReadyData
	local viewSeat = self.gvbl(tbl["_src"])
	if viewSeat == 1 then
		self.tableComponent:ReSetAll()
	else
		self.tableComponent:ReSetPlayerByViewSeat(viewSeat)
	end
end

function yingsanzhang_scene_controller:OnGameDeal()
	local dealData = self.data_manage.DealData
	self.tableComponent:WashCard(function()
		self:Deal(function()
			Notifier.dispatchCmd(cmd_93.DealBet,dealData)	---通知ui下底注
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmdName.GAME_SOCKET_GAME_DEAL)
		end)
	end)
end

function yingsanzhang_scene_controller:OnFold()
	self.tableComponent:OnFold()
end

---参数：tbl["nLooseChair"]
function yingsanzhang_scene_controller:SetPokerGray(tbl)
	self.tableComponent:OnCompare(tbl)
end

function yingsanzhang_scene_controller:OnGameRewards(tbl)
	self.tableComponent:OnGameRewards(function()
		
	end)
end

function yingsanzhang_scene_controller:OnOpenCard()
	self.tableComponent:OnOpenCard(function()
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmd_niuniu.OPENCARD)
	end)
	
end

function yingsanzhang_scene_controller:OnGameEnd()
--	self.tableComponent:ReSetAll()
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAMEEND)
	
end

function yingsanzhang_scene_controller:OnSyncTable()
	local currStage = {
		prepare = "prepare",	--开始准备
		banker = "banker",		--定庄
		deal = "deal",			--抓牌
		round = "round",		--游戏阶段(下注 跟注 看牌 比牌 弃牌等游戏操作)
		reward = "reward",		--结算
		gameend = "gameend"		--结束
	}
	local tbl  = self.data_manage.OnSyncTableData
	self.tableComponent:ReSetAll()
	
	local sCurrStage = tbl["_para"]["sCurrStage"]
	if sCurrStage == currStage.prepare or sCurrStage == currStage.banker or sCurrStage == currStage.reward  then
		
	elseif sCurrStage == currStage.round then
		self:Deal(function()
			if sCurrStage == currStage.round then
				local myLogicSeatNum = self.gmls()
				if tbl["_para"]["stPlayerOPen"][myLogicSeatNum] == 1 then
					self.data_manage.OnOpenCardData = tbl
					self.tableComponent:OnOpenCard(function()
						Notifier.dispatchCmd(cmd_93.SyncAfterDeal,tbl)
					end)
				else
					Notifier.dispatchCmd(cmd_93.SyncAfterDeal,tbl)
				end
			end
		end)
	else
		logError("重连阶段未处理------"..tostring(sCurrStage))
	end

	
	local stCompare = tbl["_para"]["stCompare"]
	if stCompare ~= nil then
		if self.data_manage.CompareResultData == nil then
			 self.data_manage.CompareResultData = {}
		end
		self.data_manage.CompareResultData._para = stCompare
		self.tableComponent:OnCompareResult()
	end
end

function yingsanzhang_scene_controller:OnAllCompare()
	local tbl  = self.data_manage.OnAllCompareData
	
end

function yingsanzhang_scene_controller:OnLeaveEnd(tbl)
	local viewSeat = self.gvbl(tbl._src)
	self.tableComponent:RemoveCurPlayerList(viewSeat)
end

function yingsanzhang_scene_controller:Deal(callback)
	self.tableComponent:DealCard(callback)
end

function yingsanzhang_scene_controller:ChangeDeskCloth()
	self.tableComponent:ChangeDeskCloth()
end

function yingsanzhang_scene_controller:LoadCardTable(args)
	local gameOjb =  GameObject.Find("MJScene")
	if gameOjb ~= nil then
		GameObject.Destroy(gameOjb)
	end	
	local sceneRoot = self:LoadPrefab(data_center.GetResPokerCommPath().."/poker_table/".."sceneroot")
	self:LoadPrefab(data_center.GetResRootPath().."/scene/".."cameras",sceneRoot.transform)
	self:LoadPrefab(data_center.GetResRootPath().."/scene/".."poker_players",sceneRoot.transform)
	self:LoadPrefab(data_center.GetResRootPath().."/scene/".."roominfos",sceneRoot.transform)
	
	
end

function yingsanzhang_scene_controller:LoadPrefab(path)
	local asset = newNormalObjSync(path,typeof(GameObject))
	local obj = newobject(asset)
	local s = string.gsub(obj.name,"%(Clone%)","")
	obj.name = s
	return obj
end
	
function yingsanzhang_scene_controller:OnDragAction(tbl)
--	self.tableComponent:OnDragAction(tbl)
end
 --[[--
 * @Description: 组装所需要的组件
 ]]
function yingsanzhang_scene_controller:ConstructComponents()
	-- 组装
	self:LoadCardTable()
	self.tableComponent = require("logic.poker_sys.yingsanzhang_sys.scene.yingsanzhang_table_component"):create()
	self.tableComponent:InitPlayerTransForm()
	Trace("++++++++++++++++++Create Component")
end

function yingsanzhang_scene_controller:MouseBinDown(position)
	self.tableComponent:MouseBinDown(position)
end

return yingsanzhang_scene_controller
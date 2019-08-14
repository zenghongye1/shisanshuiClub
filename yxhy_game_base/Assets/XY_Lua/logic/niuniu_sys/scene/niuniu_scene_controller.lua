local niuniu_scene_controller = class("niuniu_scene_controller")
function niuniu_scene_controller:ctor()
	self.gvbl = player_seat_mgr.GetViewSeatByLogicSeat
	self.gvbln = player_seat_mgr.GetViewSeatByLogicSeatNum
	self.gmls = player_seat_mgr.GetMyLogicSeat
	self.Camera = Camera.main
	self.niuniu_data_manage = require("logic.niuniu_sys.cmd_manage.niuniu_data_manage"):GetInstance()
	self.tableComponent = nil
	self:ConstructComponents()
	self.niuniu_ui = UI_Manager:Instance():GetUiFormsInShowList("niuniu_ui")
end

function niuniu_scene_controller:OnPlayerEnter()
	local tbl = self.niuniu_data_manage.EnterData
	local viewSeat = self.gvbl(tbl["_src"])
	self.tableComponent:SetCurPlayerList(viewSeat)
end

function niuniu_scene_controller:OnPlayerReady()
	local tbl = self.niuniu_data_manage.ReadyData
	local viewSeat = self.gvbl(tbl["_src"])	
	if viewSeat == 1 then
		self.tableComponent:ReSetAll()
	else
		self.tableComponent:ReSetPlayerByViewSeat(viewSeat)
	end
end

function niuniu_scene_controller:OnGameDeal()
	Trace("发牌，播放发牌动画")	
	local dealData = self.niuniu_data_manage.DealData
	local mode = self.niuniu_data_manage.roomInfo.GameSetting.takeTurnsMode
	if mode == niuniu_rule_define.SUB_BULL_BANKER.SUB_BULL_BANKER_ROB_LOOK then
		local stLastCards = dealData._para.stLastCards
		if stLastCards ~= nil and #stLastCards > 0 then
			for i,v in ipairs(stLastCards) do 
				table.insert(self.niuniu_data_manage.DealData._para.stCards,v)
			end
			self.niuniu_ui:SetTiposition(true)
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAME_DEAL)
		else
			self.tableComponent:WashCard(function()
			self:Deal(function()
			self.tableComponent:OnAskOpenCard()
			self.tableComponent.isOpenCard = true
			self.niuniu_ui:SetTiposition(false)
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAME_DEAL)
			end)
			end)
		end
	else
		self.tableComponent:WashCard(function()
		self:Deal(function()
		
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAME_DEAL)
			end)
			end)
	end
end

function niuniu_scene_controller:OnCompareResult()
	self.tableComponent:OnCompareResult(function()
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.COMPARE_RESULT)
	
 end)
	
end

function niuniu_scene_controller:OnAskOpenCard()
	self.tableComponent:OnAskOpenCard()
end
function niuniu_scene_controller:OnOpenCard()
	self.tableComponent:OnOpenCard(function()
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmd_niuniu.OPENCARD)
	end)
	
end

function niuniu_scene_controller:OnGameEnd()
--	self.tableComponent:ReSetAll()
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAMEEND)
	
end

function niuniu_scene_controller:OnSyncTable()
	local tbl  = self.niuniu_data_manage.OnSyncTableData
	self.tableComponent:ReSetAll()
	
	local sCurrStage = tbl._para.sCurrStage
	local mode = self.niuniu_data_manage.roomInfo.GameSetting.takeTurnsMode
		--如果不是明牌抢庄模式
	if mode ~= niuniu_rule_define.SUB_BULL_BANKER.SUB_BULL_BANKER_ROB_LOOK then
		if tostring(sCurrStage) == "prepare" or tostring(sCurrStage) == "choosebanker" or tostring(sCurrStage) == "robbanker" or tostring(sCurrStage) == "mult" then
			Trace("不显示手牌")
		else
		
			local stPlayerOpen = tbl._para.stPlayerOpen
			if stPlayerOpen ~= nil then
				self.tableComponent:Sync_OpenCard()
				
			end
			local isOpenCard = tbl._para.stPlayerBright
			if isOpenCard ~= nil then
				self.tableComponent:Sync_CheckCardStatus(isOpenCard)
			end
		end
	else
		if tostring(sCurrStage) == "prepare" or tostring(sCurrStage) == "choosebanker" then
			Trace("不显示手牌")
		else
		
			local stPlayerOpen = tbl._para.stPlayerOpen
			if stPlayerOpen ~= nil then
				self.tableComponent:Sync_OpenCard()
			end
			local isOpenCard = tbl._para.stPlayerBright
			if isOpenCard ~= nil then
				self.tableComponent:Sync_CheckCardStatus(isOpenCard)
			end
		end
	end
	
	
	
	local stCompare = tbl._para.stCompare
	if stCompare ~= nil then
		if self.niuniu_data_manage.CompareResultData == nil then
			 self.niuniu_data_manage.CompareResultData = {}
		end
		self.niuniu_data_manage.CompareResultData._para = stCompare
		self.tableComponent:OnCompareResult()
	end
end

function niuniu_scene_controller:OnLeaveEnd(tbl)
	local viewSeat = self.gvbl(tbl._src)
	self.tableComponent:RemoveCurPlayerList(viewSeat)
end


function niuniu_scene_controller:Deal(callback)
	self.tableComponent:DealCard(callback)
end

function niuniu_scene_controller:ChangeDeskCloth()
	self.tableComponent:ChangeDeskCloth()
end

function niuniu_scene_controller:LoadCardTable(args)
	local gameOjb =  GameObject.Find("MJScene")
	if gameOjb ~= nil then
		GameObject.Destroy(gameOjb)
	end
--	local nPlayerNum = self.niuniu_data_manage.roomInfo.nPlayerNum
--	local resCardTable = newNormalObjSync(data_center.GetResRootPath().."/scene/".."niuniusceneroot"..tostring(6),typeof(GameObject))
--	newobject(resCardTable)
	
	local sceneRoot = self:LoadPrefab(data_center.GetResPokerCommPath().."/poker_table/".."sceneroot")
	self:LoadPrefab(data_center.GetResRootPath().."/scene/".."cameras",sceneRoot.transform)
	self:LoadPrefab(data_center.GetResRootPath().."/scene/".."cuopaianchor",sceneRoot.transform)
	self:LoadPrefab(data_center.GetResRootPath().."/scene/".."poker_players",sceneRoot.transform)
	self:LoadPrefab(data_center.GetResRootPath().."/scene/".."roominfos",sceneRoot.transform)
end

function niuniu_scene_controller:LoadPrefab(path)
	local asset = newNormalObjSync(path,typeof(GameObject))
	local obj = newobject(asset)
	local s = string.gsub(obj.name,"%(Clone%)","")
	obj.name = s
	return obj
end

function niuniu_scene_controller:OnDragAction(tbl)
	self.tableComponent:OnDragAction(tbl)
end

function niuniu_scene_controller:OnFingerUpAction(tbl)
	self.tableComponent:OnFingerUpAction(tbl)
end
 --[[--
 * @Description: 组装所需要的组件
 ]]
function niuniu_scene_controller:ConstructComponents()
	-- 组装
	self:LoadCardTable()
	self.tableComponent = require("logic.niuniu_sys.scene.niuniu_table_component"):create()
	self.tableComponent:InitPlayerTransForm()
	Trace("++++++++++++++++++Create Component")
end

function niuniu_scene_controller:MouseBinDown(position)
		self.tableComponent:MouseBinDown(position)
end

return niuniu_scene_controller
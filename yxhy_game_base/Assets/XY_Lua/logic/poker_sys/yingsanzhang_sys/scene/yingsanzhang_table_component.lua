require "logic/niuniu_sys/ui/cuopai_ui"
require "logic/niuniu_sys/other/poker_table_coordinate"
local yingsanzhang_table_component = class("yingsanzhang_table_component")
function yingsanzhang_table_component:ctor()
	self.gvbl = player_seat_mgr.GetViewSeatByLogicSeat
	self.gvbln = player_seat_mgr.GetViewSeatByLogicSeatNum
	self.gmls = player_seat_mgr.GetMyLogicSeat
	self.mostPlayerList = {}
	self.playerList = {}
	self.tableCenter = nil
	self.cardTranPool = {}
	self.cardCount = 3
	self.cardLastCardValue = 0
	self.cuoPaiCard = {}
	self.Camera = Camera.main
	self.isOpenCard = true
	self.isFinshCuoPai = false
	self.data_manage = require("logic.poker_sys.yingsanzhang_sys.cmd_manage.yingsanzhang_data_manage"):GetInstance()
	self.offsetX = 10
	self.offsetY = 50
	self.cuoPaiAnchor = nil
	self.ui = UI_Manager:Instance():GetUiFormsInShowList("yingsanzhang_ui")
	self.pokerPool = require("logic.niuniu_sys.other.pokercard_pool"):create()
	
end

function yingsanzhang_table_component:InitPlayerTransForm()
	local nPlayerNum = self.data_manage.roomInfo.nPlayerNum
	self.currentTable = poker_table_coordinate.poker_table[nPlayerNum]
	self.tableCenter = GameObject.Find("tableCenter")
	if self.tableCenter == nil then
		logError("tableCenter is nil")
	end
	if #self.playerList > 0 then
		logError("===InitPlayerTransFormError"..tostring(#self.playerList))
		return
	end
	self:CreatePlayerList()
	self:HeGuan()
	self:SetRoomNum()
	self:ChangeDeskCloth()
end

function yingsanzhang_table_component:CreatePlayerList()
	if isEmpty(self.mostPlayerList)then
		for i = 1,7 do
			local playerGameObject = GameObject.Find("poker_players/Player_"..tostring(i))
			playerGameObject:SetActive(false)
			local player = require("logic.poker_sys.yingsanzhang_sys.scene.yingsanzhang_player_component"):create(playerGameObject)
			player.pokerPool = self.pokerPool
			player.position_index = i
			table.insert(self.mostPlayerList,player)
		end
	end
end

function yingsanzhang_table_component:SetCurPlayerList(vs)
	local peopleNum = roomdata_center.maxplayernum
	
	self.currentTable = poker_table_coordinate.poker_table[peopleNum]
	
	for viewSeat,index in pairs(self.currentTable) do
	   	if vs == viewSeat then
			self.playerList[viewSeat] = self.mostPlayerList[index]
			self.playerList[viewSeat]["viewSeat"] = viewSeat
	   	end
	end
end

function yingsanzhang_table_component:RemoveCurPlayerList(vs)
	for viewSeat,v in pairs(self.playerList) do
		if self.playerList[viewSeat] and vs == viewSeat then
			self.playerList[viewSeat] = nil
		end
	end
end

function yingsanzhang_table_component:SetRoomNum()
	local trans = GameObject.Find("roominfos/roomNum").transform
	self.roomNumComp = require("logic/mahjong_sys/components/base/comp_mjRoomNum"):create(trans)
	self.roomNumComp:SetRoomNum(self.data_manage:GetRoomInfo().rno,data_center.GetResMJCommPath())
	local playIconName = yingsanzhang_rule_define.PT_YINGSANZHANG_PlaysModeDeskIcon[self.data_manage.roomInfo.GameSetting.playsMode]
	local tip1 = GameObject.Find("roominfos/roomInfo/tip1").transform
	self.roomNumComp:SetSpImgByTransform(tip1,playIconName,data_center.GetResPokerCommPath(),280,84)
	
	local blindIconName = yingsanzhang_rule_define.PT_YINGSANZHANG_BlindTurnIcon[self.data_manage.roomInfo.GameSetting.blindTurn]
	local tip2 = GameObject.Find("roominfos/roomInfo/tip2").transform
	self.roomNumComp:SetSpImgByTransform(tip2,blindIconName,data_center.GetResPokerCommPath(),237,84)
end
--[[--
 * @Description: 洗牌
 ]]
function yingsanzhang_table_component:WashCard(callback)
	coroutine.start(function()
		ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/xipai")   --洗牌音效
		self.tableCenter:SetActive(true)
		self.heguan_manage:PlayHeGuanAnimationByClipName("xipai")
		coroutine.wait(1.5)
		self.tableCenter:SetActive(false)
		if callback ~= nil then
			callback()
			callback = nil
		end
	end)		
end

--[[--
 * @Description: 初始化牌形  
 ]]
function yingsanzhang_table_component:DealCard(callback)		
	self.tableCenter:SetActive(false)

	coroutine.start(function()
	if self.playerList ~= nil then	
		for i, player in pairs(self.playerList) do
			player:SetShufflePosition(self.tableCenter.transform)
			player.gameObject:SetActive(true)
		end
		self.heguan_manage:PlayHeGuanAnimationByClipName("daiji1")
		coroutine.wait(0.1)
		for i =1,self.cardCount  do
			for j, player in pairs(self.playerList) do
				player:shuffle(self.tableCenter.transform,i)
			end
			coroutine.wait(0.05)
			ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/fapai_feichu")  ----发牌音效
		end
	end
	coroutine.wait(0.2)
	self.heguan_manage:PlayHeGuanAnimationByClipName("daiji2")
		if callback ~= nil then
			callback()	
			callback = nil
			self.tableCenter:SetActive(false)
		end	
	end)			
end

function yingsanzhang_table_component:OnOpenCard(callback)
	local openCardsDatas = self.data_manage.OnOpenCardData
	local viewSeat = player_seat_mgr.GetViewSeatByLogicSeat(openCardsDatas._src)
	local stCards = openCardsDatas["_para"]["stCards"]
	local nCardType = openCardsDatas["_para"]["nCardType"]
	local tbl = {}
	tbl["viewSeat"] = viewSeat
	tbl["nCardType"] = nCardType
	coroutine.start(function()
		for i,v in ipairs(self.playerList) do
			if v.viewSeat == viewSeat then
				if v.viewSeat == 1 then
					v:SetCardMesh(stCards)
					v:ShowCard(function()
						if self.data_manage.isSelfFold or self.data_manage.isSelfLose then
							v:SetPokerGray(true,true)
						end
						Notifier.dispatchCmd(cmd_93.AfterOpenShowType,tbl)	--翻牌后通知ui显示牌型
					end)
				else
					Notifier.dispatchCmd(cmd_93.AfterOpenShowType,tbl)	--翻牌后通知ui显示牌型
				end
			end
		end
		if callback ~= nil then
			callback()
		end
	end)
end

function yingsanzhang_table_component:OnFold(callback)
	local OnFoldData = self.data_manage.OnFoldData
	local viewSeat = self.gvbl(OnFoldData["_src"])
	self.playerList[viewSeat]:SetPokerGray(true)
	
	if callback ~= nil then
		callback()
	end
end

function yingsanzhang_table_component:OnCompare(tbl,callback)
	local loseView = self.gvbln(tbl["nLooseChair"])
	self.playerList[loseView]:SetPokerGray(true)
	
	if callback ~= nil then
		callback()
	end
end

--断线重连显示牌型
function yingsanzhang_table_component:Sync_OpenCard()
	Trace("断线重连搓牌阶段")
	local SyncOpenCardsDatas = self.data_manage.OnSyncTableData._para.stPlayerOpen
	
	for i,v in ipairs(SyncOpenCardsDatas) do
		local viewSeat = self.gvbln(v.chairid)
		local stCards = v.stCards
		for j,k in ipairs(self.playerList) do
			if k.viewSeat == viewSeat then
				k:DisableDisplayCard()
				if stCards and not isEmpty(stCards) then
					k:SetCardMesh(stCards)
					k:SyncReset()
				end
			end	
		end
		--如果是自己的坐位号，填充自己的发牌数据
		if viewSeat == 1 and #v.stCards > 0 then
			if self.data_manage.DealData == nil then
				self.data_manage.DealData = {}
				self.data_manage.DealData._para = {}
			end
			self.data_manage.DealData._para.stCards = v.stCards
			self.data_manage.DealData._para.nBeishu = v.nBeishu
			self.data_manage.DealData._para.nCardType = v.nCardType
		end
	end
end

function yingsanzhang_table_component:OnGameRewards(callback)
	self.heguan_manage:PlayHeGuanAnimationByClipName("daiji3")
	local compareResultData = self.data_manage.SmallRewardData
	local logicSeatNum = player_seat_mgr.GetMyLogicSeat()
	if not compareResultData["_para"]["rewards"] then
		logError("reward 数据空了")
		return
	end
	local stAllCompareData = compareResultData["_para"]["rewards"][logicSeatNum]["stAllUserDatas"]
	if stAllCompareData and table.getn(stAllCompareData) > 0 then
		coroutine.start(function()
			for i,v in pairs(stAllCompareData) do
				local viewSeat = player_seat_mgr.GetViewSeatByLogicSeatNum(i)
				local stCards = v["stCards"]
				local nCardType = v["nCardType"]
				for _,k in ipairs(self.playerList) do
					if viewSeat == k.viewSeat and not isEmpty(stCards) then
						k:SetCardMesh(stCards)
						k:ShowCard(function()
							local tbl = {}
							tbl["viewSeat"] = viewSeat
							tbl["nCardType"] = nCardType
							Notifier.dispatchCmd(cmd_93.AfterOpenShowType,tbl)	--翻牌后通知ui显示牌型
						end)
					end
				end
			end
			if callback ~= nil then
				callback()
			end
		end)
	end
end

function yingsanzhang_table_component:MouseBinDown(position)	
	self.heguan_manage:MouseBinDown(position)
end

function yingsanzhang_table_component:HeGuan()
	if self.heguan_manage == nil then
		self.heguan_manage = require("logic/poker_sys/other/heguan_manage"):create()
	end
end

function yingsanzhang_table_component:ChangeDeskCloth()
	if self.poker_chaneg_desk == nil then
		local poker_table = GameObject.Find("poker_table/poker_table01")
		if poker_table ~= nil then
			self.poker_chaneg_desk = require("logic.poker_sys.other.poker_change_desk"):create(poker_table,self.roomNumComp)
		else
			logError("找不到poker_table")
		end
	end
	self.poker_chaneg_desk:ChangeDeskCloth()
end

--重置发牌动作
function yingsanzhang_table_component:ResetDeal()
	self.tableCenter:SetActive(true)
	for i = 1, #self.cardTranPool do
		self.cardTranPool[i].transform.parent = self.tableCenter.transform
		self.cardTranPool[i].transform.localPosition = Vector3(0,i/20,0)
		self.cardTranPool[i].transform.localEulerAngles = Vector3(0,0,180)
		self.cardTranPool[i].gameObject:SetActive(false)
	end
end

function yingsanzhang_table_component:ReSetAll()
	self.isOpenCard = true
	self:ResetPlayerList()
end

function yingsanzhang_table_component:ReSetPlayerByViewSeat(viewSeat)
	self.playerList[viewSeat]:PlayerReset()
end

--重置发牌动作
function yingsanzhang_table_component:ResetPlayerList()
	for i ,player in pairs(self.playerList) do
		player:PlayerReset()
	end
end

return yingsanzhang_table_component
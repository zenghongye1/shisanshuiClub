--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--endregion

local table_component = require ("logic.shisangshui_sys.table_component")
require "logic/shisangshui_sys/prepare_special/prepare_special"
require "logic/shisangshui_sys/resMgr_component"
require "logic/shisangshui_sys/mode_comp_base"
require "logic/shisangshui_sys/config/shisanshui_table_config"

local play_mode_shisanshui = class("play_mode_shisanshui")

function play_mode_shisanshui:ctor()
	Trace("初始化 play_mode_shisanshui")
	self.gvbl = player_seat_mgr.GetViewSeatByLogicSeat
	self.gvbln = player_seat_mgr.GetViewSeatByLogicSeatNum
	self.gmls = player_seat_mgr.GetMyLogicSeat
	self.ConstructComponents = nil
	self.tableComponent = nil
	self.resMgrComponet = nil
	self:ConstructComponents()
	self.shisanshui_ui = UI_Manager:Instance():GetUiFormsInShowList("shisanshui_ui")
end

 function play_mode_shisanshui:OnPlayerEnter(tbl)
	Trace("有玩家进来了"..tostring(tbl))
	self:ReSetAllStatus()
	local viewSeat = self.gvbl(tbl["_src"])
	self.tableComponent:SetCurPlayerList(viewSeat)
 end
	
function play_mode_shisanshui:OnPlayerReady(tbl)
	Trace("有人准备了")
	local viewSeat = self.gvbl(tbl["_src"])
	if viewSeat == 1 then
		self:ReSetAllStatus()
	end
end
	
function play_mode_shisanshui:OnGameStart(tbl)
	Trace("游戏开始")
	
	local roomInfo = roomdata_center.gamesetting
	if not roomInfo["bSupportWaterBanker"] then	
		self.tableComponent:WashCard(function()
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAMESTART)
		end)
	else
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAMESTART)
	end
end
	
function play_mode_shisanshui:OnAllMult(tbl)
	Trace("所有人的选择倍数")
	self.tableComponent:WashCard(function()
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.FuZhouSSS_ALLMULT)
	end)	
end
	
function play_mode_shisanshui:OnGameDeal(tbl)
	self.tableComponent:ClearnAllShoot()
	self:InitTable(function()
		--player_component.CardList = tbl["_para"]["stCards"]				
		--Trace("发牌的数据"..GetTblData(player_component.CardList))
	
		local isSpecial = tbl["_para"]["nSpecialType"]
		local nSpecialScore = tbl["_para"]["nSpecialScore"]
		local recommendCards = sss_recommendHelper.GetLibRecomand():SetRecommandLaizi(tbl["_para"]["stCards"])
		room_data.SetRecommondCard(recommendCards)		
		
		card_data_manage.prepare_special_CardList = {}
		card_data_manage.isSpecial = nil
		card_data_manage.nSpecialScore = nil
		card_data_manage.prepare_recommendCards = {}
		
		card_data_manage.prepare_special_CardList = tbl["_para"]["stCards"]
		card_data_manage.isSpecial = isSpecial
		card_data_manage.nSpecialScore = nSpecialScore
		card_data_manage.prepare_recommendCards = recommendCards

		--显示剩余牌背
		local LeftCardN = tbl._para.nLeftCardNums
		if LeftCardN == 2 then

			self.shisanshui_ui:SetLeftCardNums(LeftCardN)
			self.shisanshui_ui:SetLeftCardShow(true)
			self.shisanshui_ui:SetLeftCardBack(true)
		else
			self.shisanshui_ui:SetLeftCardShow(false)
			self.shisanshui_ui:SetLeftCardNums(LeftCardN)
		end
		
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAME_DEAL)	
	end)
end
	
function play_mode_shisanshui:OnAskChoose(tbl)
	Trace("摆牌"..GetTblData(tbl))
	local timeo = tbl["timeo"]
	room_data.SetPlaceCardTime(timeo)
	roomdata_center.timersetting["chooseCardTypeTimeOut"] = timeo
	
	coroutine.start(function()
		coroutine.wait(1)
		local strCards = card_data_manage.prepare_special_CardList
		local isSpecial = card_data_manage.isSpecial
		if isSpecial == 0 then
			UI_Manager:Instance():ShowUiForms("place_card",UiCloseType.UiCloseType_CloseNothing,nil,strCards)
		else
			local nSpecialScore = card_data_manage.nSpecialScore
			UI_Manager:Instance():ShowUiForms("prepare_special",UiCloseType.UiCloseType_CloseNothing,nil,strCards,isSpecial,nSpecialScore)
		end
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE,cmd_shisanshui.ASK_CHOOSE)
	end)
end
	
function play_mode_shisanshui:OnCompareStart(tbl)
	Trace("OnCompareStart--------"..GetTblData(tbl))
	self.shisanshui_ui:IsEnableTouch(false)
	local LeftCards = tbl._para.stLeftCards
	local LeftCardsNum = tbl._para.nLeftCardNums
	coroutine.start(function ()
		 --播放比牌动画
   		self.shisanshui_ui:PlayerStartCompareAnimation()
    	Trace("开始播放比牌动画")
    	coroutine.wait(0.8)
		if LeftCardsNum == 2 then		
			self.shisanshui_ui:SetLeftCard(LeftCards)
			self.shisanshui_ui:SetLeftCardBack(false)		
		else
			self.shisanshui_ui:SetLeftCardShow(false)
			Trace("OnCompareStart".."LeftCardsNum != 2")
		end
   		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.COMPARE_START)
	end)
end
	
function play_mode_shisanshui:OnCompareResult(tbl)
	Trace("比牌结果")
	
	local myLogicSeat = tbl["_src"]
	card_data_manage.compareResultPara = tbl["_para"]
	local allCompareData = tbl["_para"]["stAllCompareData"]
	card_data_manage.allShootChairId = tbl["_para"]["nAllShootChairID"] ----全垒打玩家椅子id, 0表示没有全垒打
	local myViewSeat = player_seat_mgr.GetViewSeatByLogicSeat(myLogicSeat)
	if allCompareData ~=nil then		
		for i,v in ipairs(allCompareData) do
			local charid = v["chairid"]
			local viewSeatId = player_seat_mgr.GetViewSeatByLogicSeatNum(charid) --查找当前座位号
			Trace("+++++++桌子的座位号+++++++++++"..tostring(viewSeatId))
			local Player = self.tableComponent:GetPlayer(viewSeatId)
			Player.viewSeat = viewSeatId
			Player.compareResult = v
		end
	else
		Trace("比牌数据错误")
	end
		local myPlayer = self.tableComponent:GetPlayer(myViewSeat)
		card_data_manage.stCompareScores = tbl["_para"]["stCompareScores"]
	
	self.tableComponent:CompareStart(function()
	  --Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.COMPARE_RESULT)
	end)	
end
	
function play_mode_shisanshui:OnCompareEnd(tbl)		
	Trace("比牌结束")
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.COMPARE_END)
end
		
function play_mode_shisanshui:OnGameRewards(tbl)
	--Trace("结算")
end

function play_mode_shisanshui:OnSyncBegin()
	if self.tableComponent.compareCoroutine ~= nil then
		coroutine.stop(self.tableComponent.compareCoroutine)
	end
	self:ReSetAllStatus()
end
	
function play_mode_shisanshui:OnSyncTable(tbl)
	Trace("重连同步表")

	local gameCurStage = tbl._para.sCurrStage
	local leftCardNum = tbl._para.nLeftCardNums			---重连剩余牌处理
	local LeftCards = tbl._para.stLeftCards
	if gameCurStage == "choose"  then
		if leftCardNum == 2 then
			
			self.shisanshui_ui:SetLeftCardNums(leftCardNum)
			self.shisanshui_ui:SetLeftCardShow(true)
			self.shisanshui_ui:SetLeftCardBack(true)
		else
			self.shisanshui_ui:SetLeftCardNums(leftCardNum)
			self.shisanshui_ui:SetLeftCardShow(false)
		end
	elseif gameCurStage == "compare" then
		if leftCardNum == 2 then
			self.shisanshui_ui:SetLeftCardBack(false)
			self.shisanshui_ui:SetLeftCard(LeftCards)
		end
		self.shisanshui_ui:SetLeftCardNums(leftCardNum)
	else
		self.shisanshui_ui:SetLeftCardShow(false)
		self.shisanshui_ui:ReSetLeftCard()
	end
end

function play_mode_shisanshui:OnChooseOK(tbl)
	Trace("摆牌完成"..GetTblData(tbl))
	--需要扣牌
	self.tableComponent:ChooseOKCard(tbl)
	local viewSeat = player_seat_mgr.GetViewSeatByLogicSeat(tbl._src)
	if viewSeat == 1 then
		self.shisanshui_ui:IsEnableTouch(true)
	end
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.CHOOSE_OK)
end

	
function play_mode_shisanshui:OnGameEnd(tbl)
	Trace("游戏结束")
	self:ReSetAllStatus()
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAMEEND)
end
	
function play_mode_shisanshui:OnUserLeave(tbl)
	local viewSeat = self.gvbl(tbl._src)
	self.shisanshui_ui:HidePlayer(viewSeat)
	self.tableComponent:RemoveCurPlayerList(viewSeat)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_PLAYER_LEAVE)
end

function play_mode_shisanshui:ChangeDeskCloth()
	self.tableComponent:ChangeDeskCloth()
end

function play_mode_shisanshui:MouseBinDown(position)
	self.tableComponent:MouseBinDown(position)
end

 function play_mode_shisanshui:Initialize()
     
 end

function play_mode_shisanshui:Uninitialize()
--	play_mode_shisanshui:base_uninit()

	instance = nil
	room_usersdata_center.RemoveAll()
	
	UI_Manager:Instance():CloseUiForms("poker_largeResult_ui",true)
	UI_Manager:Instance():CloseUiForms("place_card")
	UI_Manager:Instance():CloseUiForms("shisanshui_smallResult_ui")
	UI_Manager:Instance():CloseUiForms("common_card")
	UI_Manager:Instance():CloseUiForms("prepare_special")
		
end

function play_mode_shisanshui:InitTable(callback)	
	self.tableComponent:InitCard(callback)
end

function play_mode_shisanshui:LoadCardTable(args)
	local gameOjb =  GameObject.Find("MJScene")
	if gameOjb ~= nil then
		GameObject.Destroy(gameOjb)
	end
		
	local sceneRoot = self:LoadPrefab(data_center.GetResPokerCommPath().."/poker_table/".."sceneroot")
	self:LoadPrefab(data_center.GetResRootPath().."/scene/".."cameras",sceneRoot.transform)
	self:LoadPrefab(data_center.GetResRootPath().."/scene/".."gunanchor",sceneRoot.transform)
	self:LoadPrefab(data_center.GetResRootPath().."/scene/".."poker_players",sceneRoot.transform)
	self:LoadPrefab(data_center.GetResRootPath().."/scene/".."roominfos",sceneRoot.transform)
end

function play_mode_shisanshui:LoadPrefab(path)
	local asset = newNormalObjSync(path,typeof(GameObject))
	local obj = newobject(asset)
	local s = string.gsub(obj.name,"%(Clone%)","")
	obj.name = s
	return obj
end
	

function play_mode_shisanshui:TouchShowCards(state)
	self.tableComponent:OpenCard(state)
end

	
	 --[[--
     * @Description: 组装所需要的组件
     ]]
function play_mode_shisanshui:ConstructComponents()
	Trace("ConstructComponents---------------------------------------")
	-- 组装
	self:LoadCardTable()
	self.tableComponent = table_component:create()
	self.tableComponent:InitPlayerTransForm()
end

function play_mode_shisanshui:PreloadObjects()
    --预加载场景物体
end

function play_mode_shisanshui:ReSetAllStatus()
	Trace("重置游戏")
	self.tableComponent:ReSetAll()
end


    

function play_mode_shisanshui:GetTabComponent()
	return self.tableComponent
end

return play_mode_shisanshui






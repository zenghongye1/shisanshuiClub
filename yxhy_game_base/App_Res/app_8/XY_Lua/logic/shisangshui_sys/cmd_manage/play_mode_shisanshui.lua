--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--endregion

require "logic/shisangshui_sys/table_component"
require "logic/shisangshui_sys/player_component"
require "logic/shisangshui_sys/prepare_special/prepare_special"
require "logic/shisangshui_sys/place_card/place_card"
require "logic/shisangshui_sys/resMgr_component"
require "logic/mahjong_sys/mode_components/mode_comp_base"
require "logic/hall_sys/openroom/room_data"
require "logic/shisangshui_sys/config/shisanshui_table_config"

local play_mode_shisanshui = class(play_mode_shisanshui)

function play_mode_shisanshui:ctor()
	Trace("初始化 play_mode_shisanshui")
	self.gvbl = player_seat_mgr.GetViewSeatByLogicSeat
	self.gvbln = player_seat_mgr.GetViewSeatByLogicSeatNum
	self.gmls = player_seat_mgr.GetMyLogicSeat
	self.ConstructComponents = nil
	self.tableComponent = nil
	self.resMgrComponet = nil
	self:ConstructComponents()
end

 function play_mode_shisanshui:OnPlayerEnter(tbl)
	Trace("有玩家进来了"..tostring(tbl))
	self:ReSetAllStatus()
	local logicSeat = tbl["_src"]
	local viewSeat = self.gvbl(logicSeat)
	if viewSeat == 1 then
	end  	
 end
	
function play_mode_shisanshui:OnPlayerReady(tbl)
	Trace("有人准备了")
	self:ReSetAllStatus()
	local viewSeat = self.gvbl(tbl["_src"])
	if viewSeat == 1 then
	--	this:ReSetAllStatus()
	end
end
	
function play_mode_shisanshui:OnGameStart(tbl)
	Trace("游戏开始")	
	local roomInfo = room_data.GetSssRoomDataInfo()
	if not roomInfo.isZhuang then	
		self.tableComponent.WashCard(function()
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAMESTART)
		end)
	else
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAMESTART)
	end
end
	
function play_mode_shisanshui:OnAllMult(tbl)
	Trace("所有人的选择倍数")
	self.tableComponent.WashCard(function()
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.FuZhouSSS_ALLMULT)
	end)	
end
	
function play_mode_shisanshui:OnGameDeal(tbl)
	Trace("发牌")	
	self.tableComponent.ClearnAllShoot()
	self:InitTable(function()
		player_component.CardList = tbl["_para"]["stCards"]
		--recommendCards = tbl["_para"]["recommendCards"]
					
		Trace("牌的数据"..tostring(player_component.CardList))		
		local isSpecial = tbl["_para"]["nSpecialType"]

		local score = tbl["_para"]["nSpecialScore"]
		if isSpecial == 0 then
			Trace("显示摆牌")
			place_card.Show(player_component.CardList)--, recommendCards)
		else
			Trace("显示特殊牌型")
			prepare_special.Show(player_component.CardList, isSpecial, 3, recommendCards)
		end
		recommendCards = libRecomand:SetRecommandLaizi(tbl["_para"]["stCards"])
		room_data.SetRecommondCard(recommendCards)
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAME_DEAL)	
	end)
end
	
function play_mode_shisanshui:OnAskChoose(tbl)
	Trace("摆牌")
	local timeo = tbl["timeo"]
	local timeEnd = os.time() + timeo
	room_data.SetPlaceCardTime(timeEnd - tbl.time)
	room_data.GetSssRoomDataInfo().placeCardTime = timeo
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.ASK_CHOOSE)
end
	
function play_mode_shisanshui:OnCompareStart(tbl)
	Trace("比牌开始")
	place_card.Hide()
	prepare_special.Hide()
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
			local Player = self.tableComponent.GetPlayer(viewSeatId)
			Player.viewSeat = viewSeatId
			Player.compareResult = v

		end
	else
		Trace("比牌数据错误")
	end
		local myPlayer = self.tableComponent.GetPlayer(myViewSeat)
		card_data_manage.compareScores = tbl["_para"]["stCompareScores"]
	
	self.tableComponent.CompareStart(function()
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
end

function play_mode_shisanshui:OnChooseOK(tbl)
	Trace("摆牌完成")
	--需要扣牌
	self.tableComponent.ChooseOKCard(tbl)

	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.CHOOSE_OK)
end

	
function play_mode_shisanshui:OnGameEnd(tbl)
	Trace("游戏结束")
	self:ReSetAllStatus()
--	shisangshui_play_sys.ReadyGameReq()--发送准备好的状态进入下一局
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAMEEND)
end
	
function play_mode_shisanshui:OnUserLeave(tbl)
	local viewSeat = self.gvbl(tbl._src)
	shisangshui_ui.HidePlayer(viewSeat)
	Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_PLAYER_LEAVE)
end

 function play_mode_shisanshui:Initialize()
     
 end

function play_mode_shisanshui:Uninitialize()
--	play_mode_shisanshui:base_uninit()

	instance = nil
	room_usersdata_center.RemoveAll()
	
	large_result.Hide()
	place_card.Hide()
	small_result.Hide()
	common_card.Hide()
	prepare_special.Hide()
		
end

function play_mode_shisanshui:InitTable(callback)	
	self.tableComponent.InitCard(callback)
end

function play_mode_shisanshui:LoadCardTable(args)
	local gameOjb =  GameObject.Find("MJScene")
	if gameOjb ~= nil then
		GameObject.Destroy(gameOjb)
	end
	local roomData = room_data.GetSssRoomDataInfo()
	local peopleNum = roomData.people_num
	local sceneRoot = shisanshui_table_config.tableEnum[peopleNum]
	Trace("SceneRoot:"..tostring(sceneRoot).."peopleNum"..tostring(peopleNum))
	local resCardTable = newNormalObjSync("game_80011/scene/"..tostring(sceneRoot),typeof(GameObject))
	newobject(resCardTable)
end

	
	 --[[--
     * @Description: 组装所需要的组件
     ]]
function play_mode_shisanshui:ConstructComponents()
	Trace("ConstructComponents---------------------------------------")
	-- 组装
	self:LoadCardTable()

	self.tableComponent = table_component.create()
	self.tableComponent.InitPlayerTransForm()
	Trace("++++++++++++++++++Create Component")
end

function play_mode_shisanshui:PreloadObjects()
    --预加载场景物体
end

function play_mode_shisanshui:ReSetAllStatus()
	Trace("重置游戏")
	self.tableComponent.ReSetAll()
end


    

function play_mode_shisanshui:GetTabComponent()
	return self.tableComponent
end

return play_mode_shisanshui






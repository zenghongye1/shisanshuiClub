--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
require "logic/shisangshui_sys/table_component"
require "logic/shisangshui_sys/player_component"
require "logic/shisangshui_sys/prepare_special/prepare_special"
require "logic/shisangshui_sys/place_card/place_card"
require "logic/shisangshui_sys/resMgr_component"
require "logic/shisangshui_sys/mode_comp_base"
require "logic/hall_sys/openroom/room_data"
require "logic/shisangshui_sys/config/shisanshui_table_config"



play_mode_shisangshui = {}
local this = play_mode_shisangshui
this.cardData = nil
local instance = nil
--this.resCardTable = {}

function play_mode_shisangshui.GetInstance()
    if (instance == nil) then
        instance = play_mode_shisangshui.create()
    end

    return instance
end

function play_mode_shisangshui.create(levelID)
--	this.LoadCardTable()
    local this = mode_base.create(levelID)
    this.Class = play_mode_shisangshui
    this.name = "play_mode_shisangshui"
	
	local gvbl = player_seat_mgr.GetViewSeatByLogicSeat
    local gvbln = player_seat_mgr.GetViewSeatByLogicSeatNum
    local gmls = player_seat_mgr.GetMyLogicSeat

    local ConstructComponents = nil

    local tableComponent = nil
    local resMgrComponet = nil

	this.base_init = this.Initialize
	local function OnPlayerEnter(tbl)
		Trace("有玩家进来了"..tostring(tbl))
		this:ReSetAllStatus()
        local logicSeat = tbl["_src"]
        local viewSeat = gvbl(logicSeat)
        if viewSeat == 1 then
        end  
		
    end
	
	local function OnPlayerReady(tbl)
		Trace("有人准备了")
		this:ReSetAllStatus()
		local viewSeat = gvbl(tbl["_src"])
		if viewSeat == 1 then
		--	this:ReSetAllStatus()
		end
	end
	
	local function OnGameStart(tbl)
		Trace("游戏开始")	
		local roomInfo = room_data.GetSssRoomDataInfo()
		if not roomInfo.isZhuang then	
			tableComponent.WashCard(function()
				Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAMESTART)
			end)
		else
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAMESTART)
		end
	end
	
	local function OnAllMult(tbl)
		Trace("所有人的选择倍数")
		tableComponent.WashCard(function()
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.FuZhouSSS_ALLMULT)
		end)	
	end
	
	local function OnGameDeal(tbl)
		Trace("发牌")	
		tableComponent.ClearnAllShoot()
		this.InitTable(function()
			player_component.CardList = tbl["_para"]["stCards"]
			--recommendCards = tbl["_para"]["recommendCards"]
						
			Trace("牌的数据"..tostring(player_component.CardList))		
			local isSpecial = tbl["_para"]["nSpecialType"]

			local score = tbl["_para"]["nSpecialScore"]
			if isSpecial == 0 then
				--print("显示摆牌")
			--	place_card.Show(player_component.CardList)--, recommendCards)
				UI_Manager:Instance():ShowUiForms("place_card",UiCloseType.UiCloseType_CloseNothing,nil,player_component.CardList)
			else
				--print("显示特殊牌型")
			--	prepare_special.Show(player_component.CardList, isSpecial, 3, recommendCards)
				UI_Manager:Instance():ShowUiForms("prepare_special",UiCloseType.UiCloseType_CloseNothing,nil,player_component.CardList, isSpecial, 3, recommendCards)
			end

			local  nNeedRecommend = tbl["_para"]["nNeedRecommend"] ----是否有服务端下发推荐牌型,0不需要 1需要
			if tonumber(nNeedRecommend) == 0 then
				local recommendCards = libRecomand:SetRecommandLaizi(tbl["_para"]["stCards"])
				room_data.SetRecommondCard(recommendCards)
			else
				room_data.SetRecommondCard(tbl["_para"]["recommendCards"])
			end

		--	recommendCards = libRecomand:SetRecommandLaizi(tbl["_para"]["stCards"])
		--	room_data.SetRecommondCard(recommendCards)
			Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAME_DEAL)	
		end)
	end
	
	local function OnAskChoose(tbl)
        Trace("摆牌")
        local timeo = tbl["timeo"]
		local timeEnd = os.time() + timeo
        room_data.SetPlaceCardTime(timeEnd - tbl.time)
		room_data.GetSssRoomDataInfo().placeCardTime = timeo
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.ASK_CHOOSE)
	end
	
	local function OnCompareStart(tbl)
		Trace("比牌开始")
		UI_Manager:Instance():CloseUiForms("place_card")
		UI_Manager:Instance():CloseUiForms("prepare_special")
	end
	
	local function OnCompareResult(tbl)
		Trace("比牌结果")
		local myLogicSeat = tbl["_src"]
		local allCompareData = tbl["_para"]["stAllCompareData"]
		card_data_manage.allShootChairId = tbl["_para"]["nAllShootChairID"] ----全垒打玩家椅子id, 0表示没有全垒打
		
		
		local myViewSeat = player_seat_mgr.GetViewSeatByLogicSeat(myLogicSeat)
		if allCompareData ~=nil then		
			for i,v in ipairs(allCompareData) do
				local charid = v["chairid"]
				local viewSeatId = player_seat_mgr.GetViewSeatByLogicSeatNum(charid) --查找当前座位号
				Trace("+++++++桌子的座位号+++++++++++"..tostring(viewSeatId))
				local Player = tableComponent.GetPlayer(viewSeatId)
				Player.viewSeat = viewSeatId
				Player.compareResult = v

			end
		else
			Trace("比牌数据错误")
		end
			local myPlayer = tableComponent.GetPlayer(myViewSeat)
			card_data_manage.compareScores = tbl["_para"]["stCompareScores"]
		
		tableComponent.CompareStart(function()
		  --Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.COMPARE_RESULT)
		end)
	end
	
	local function OnCompareEnd(tbl)		
		Trace("比牌结束")
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.COMPARE_END)
	end
		
	local function OnGameRewards(tbl)
	--	Trace("结算")
--		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_SMALL_SETTLEMENT)
	end
	local function OnSyncBegin()
		
		if tableComponent.compareCoroutine ~= nil then
			coroutine.stop(tableComponent.compareCoroutine)
		end
		this:ReSetAllStatus()
	end
	local function OnSyncTable(tbl)
		Trace("重连同步表")
	end

	local function OnChooseOK(tbl)
		Trace("摆牌完成")
		--需要扣牌
		tableComponent.ChooseOKCard(tbl)

		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmd_shisanshui.CHOOSE_OK)
	end

	
	local function OnGameEnd(tbl)
		Trace("游戏结束")
		this:ReSetAllStatus()
	--	shisangshui_play_sys.ReadyGameReq()--发送准备好的状态进入下一局
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAMEEND)
	end
	
	local function OnUserLeave(tbl)
		local viewSeat = gvbl(tbl._src)
		shisangshui_ui.HidePlayer(viewSeat)
		Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_PLAYER_LEAVE)
	end

    function this:Initialize()
        this.base_init()
        Notifier.regist(cmdName.GAME_SOCKET_ENTER, OnPlayerEnter)--玩家进入
        Notifier.regist(cmdName.GAME_SOCKET_READY,OnPlayerReady)--玩家准备
        Notifier.regist(cmdName.GAME_SOCKET_GAMESTART,OnGameStart)--游戏开始
        Notifier.regist(cmdName.GAME_SOCKET_GAME_DEAL,OnGameDeal)--发牌
		Notifier.regist(cmd_shisanshui.ASK_CHOOSE, OnAskChoose) --摆牌
		Notifier.regist(cmd_shisanshui.CHOOSE_OK,OnChooseOK)
		Notifier.regist(cmd_shisanshui.COMPARE_START,OnCompareStart)  --比牌开始
		Notifier.regist(cmd_shisanshui.COMPARE_RESULT,OnCompareResult) --比牌结果
		Notifier.regist(cmd_shisanshui.COMPARE_END,OnCompareEnd) -- 比牌结束
        Notifier.regist(cmdName.GAME_SOCKET_SMALL_SETTLEMENT,OnGameRewards)--结算
        Notifier.regist(cmdName.GAME_SOCKET_GAMEEND,OnGameEnd)--游戏结束
		Notifier.regist(cmdName.GAME_SOCKET_SYNC_BEGIN,OnSyncBegin)--重连同步开始
        Notifier.regist(cmdName.GAME_SOCKET_SYNC_TABLE,OnSyncTable)--重连同步表
		Notifier.regist(cmdName.GAME_SOCKET_PLAYER_LEAVE,OnUserLeave)--游戏结束离开通知。
		Notifier.regist(cmd_shisanshui.FuZhouSSS_ALLMULT, OnAllMult)  --选择倍数通知(所有人的选择倍数)
	
    end

    this.base_uninit = this.Uninitialize

    function this:Uninitialize()
        this.base_uninit()

        Notifier.remove(cmdName.GAME_SOCKET_ENTER, OnPlayerEnter)--玩家进入
        Notifier.remove(cmdName.GAME_SOCKET_READY,OnPlayerReady)--玩家准备
        Notifier.remove(cmdName.GAME_SOCKET_GAMESTART,OnGameStart)--游戏开始
        Notifier.remove(cmdName.GAME_SOCKET_GAME_DEAL,OnGameDeal)--发牌
		Notifier.remove(cmd_shisanshui.ASK_CHOOSE,OnAskChoose) --摆牌
		Notifier.remove(cmd_shisanshui.COMPARE_START,OnCompareStart)  --比牌开始
		Notifier.remove(cmd_shisanshui.COMPARE_RESULT,OnCompareResult) --比牌结果
		Notifier.remove(cmd_shisanshui.COMPARE_END,OnCompareEnd) -- 游戏结束
		Notifier.remove(cmd_shisanshui.CHOOSE_OK,OnChooseOK)
        Notifier.remove(cmdName.GAME_SOCKET_SMALL_SETTLEMENT,OnGameRewards)--结算
        Notifier.remove(cmdName.GAME_SOCKET_GAMEEND,OnGameEnd)--游戏结束
		Notifier.remove(cmdName.GAME_SOCKET_SYNC_BEGIN,OnSyncBegin)--重连同步开始
        Notifier.remove(cmdName.GAME_SOCKET_SYNC_TABLE,OnSyncTable)--重连同步表
		Notifier.remove(cmdName.GAME_SOCKET_PLAYER_LEAVE,OnUserLeave)--游戏结束离开通知。
		Notifier.remove(cmd_shisanshui.FuZhouSSS_ALLMULT, OnAllMult)  --选择倍数通知(所有人的选择倍数)
        instance = nil
		room_usersdata_center.RemoveAll()
		
		UI_Manager:Instance:CloseUiForms("poker_largeResult_ui")
	    UI_Manager:Instance():CloseUiForms("place_card")
	    UI_Manager:Instance():CloseUiForms("shisanshui_smallResult_ui")
	    common_card.Hide()
		UI_Manager:Instance():CloseUiForms("prepare_special")
		
    end

	function this.InitTable(callback)	
		tableComponent.InitCard(callback)
	end

	function this.LoadCardTable(args)
		local gameOjb =  GameObject.Find("MJScene")
		if gameOjb ~= nil then
			GameObject.Destroy(gameOjb)
		end
		local roomData = room_data.GetSssRoomDataInfo()
		local peopleNum = roomData.people_num
		local sceneRoot = shisanshui_table_config.tableEnum[peopleNum]
		Trace("sceneRoot:"..tostring(sceneRoot).."peopleNum"..tostring(peopleNum))
		local resCardTable = newNormalObjSync(data_center.GetResRootPath().."/scene/".."sceneRoot6",typeof(GameObject))
   		newobject(resCardTable)
	end

	
	 --[[--
     * @Description: 组装所需要的组件
     ]]
    function ConstructComponents()
        Trace("ConstructComponents---------------------------------------")
        -- 组装
     	this.LoadCardTable()
     	tableComponent = this:AddComponent(table_component.create())
		tableComponent.InitPlayerTransForm()
		Trace("++++++++++++++++++Create Component")
    end

    function this:PreloadObjects()

        --预加载场景物体
    end

    function this:ReSetAllStatus()
    	Trace("重置游戏")
    	tableComponent.ReSetAll()
    end

    -- 执行下组装
    ConstructComponents()

	function this.GetTabComponent()
		return tableComponent
	end

    return this
end







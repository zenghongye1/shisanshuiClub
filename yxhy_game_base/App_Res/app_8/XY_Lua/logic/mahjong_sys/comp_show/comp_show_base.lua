--[[--
 * @Description: 组件表现基类
 * @Author:      shine
 * @FileName:    comp_show_base.lua
 * @DateTime:    2017-07-07 20:50:48
 ]]

require "logic/mahjong_sys/comp_show/mahjong_anim_state_control"

local mahjong_path_mgr = mahjong_path_mgr

comp_show_base = 
{
    isInit = false,
    compTable = nil,
    outCardEfObj = nil,
    compResMgr = nil,
    compMJItemMgr = nil,
    compPlayerMgr = nil,

    lightDirTbl = {},  --下标为本地视图下标
    gvblFun = nil,        --逻辑座位(带P)
    gvblnFun = nil,    --逻辑座位(不带P)
    gmlsFun = nil         --本地座位  
}

comp_show_base.game_state = {
    none         = "none",
    prepare      = "prepare",        --开始
    banker       = "banker",          --定庄
    deal         = "deal",               --抓牌
    round        = "round",        --游戏阶段
    reward       = "reward",       --结算
    gameend      = "gameend",       --结束
}

comp_show_base.__index = comp_show_base

function comp_show_base.New()
    local self = {}
    setmetatable(self, comp_show_base)
    return self
end


function comp_show_base:RegisterEvents()
    Notifier.regist(cmdName.MSG_CHANGE_DESK,slot(self.OnChangeDesk, self)) --更换桌布
    Notifier.regist(cmdName.GAME_SOCKET_ENTER, slot(self.OnPlayerEnter, self))  --玩家进入
    Notifier.regist(cmdName.GAME_SOCKET_READY, slot(self.OnPlayerReady, self))  --玩家准备    
    Notifier.regist(cmdName.GAME_SOCKET_GAMESTART, slot(self.OnGameStart, self))    --游戏开始
    Notifier.regist(cmdName.F1_GAME_BANKER,slot(self.OnGameBanker, self))   --定庄
    Notifier.regist(cmdName.GAME_SOCKET_GAME_DEAL, slot(self.OnGameDeal, self))      --发牌
    Notifier.regist(cmdName.F1_GAME_LAIZI, slot(self.OnGameLaiZi, self))    --定赖
    Notifier.regist(cmdName.MAHJONG_ASK_PLAY_CARD, slot(self.OnAskPlay, self))    --通知出牌
    Notifier.regist(cmdName.MAHJONG_PLAY_CARD, slot(self.OnPlayCard, self))      --出牌
    Notifier.regist(cmdName.MAHJONG_ASK_BLOCK,slot(self.OnGameAskBlock, self))                --提示吃碰杠胡操作
    Notifier.regist(cmdName.MAHJONG_GIVE_CARD, slot(self.OnGiveCard, self))  --摸牌
    Notifier.regist(cmdName.MAHJONG_TRIPLET_CARD, slot(self.OnTriplet, self))    --碰牌
    Notifier.regist(cmdName.MAHJONG_QUADRUPLET_CARD, slot(self.OnQuadruplet, self))  --杠牌
    Notifier.regist(cmdName.MAHJONG_HU_CARD,slot(self.OnGameWin, self))              --胡
    Notifier.regist(cmdName.GAME_SOCKET_SMALL_SETTLEMENT, slot(self.OnGameRewards, self))    --结算
    Notifier.regist(cmdName.GAME_SOCKET_SYNC_TABLE, slot(self.OnSyncTable, self))    --重连同步表

    Notifier.regist(cmdName.F3_START_FLAG, slot(self.OnStartFlag, self))     -- 游戏是否开始标记
end

function comp_show_base:UnRegisterEvents()
    Notifier.remove(cmdName.MSG_CHANGE_DESK,slot(self.OnChangeDesk, self)) --更换桌布
    Notifier.remove(cmdName.GAME_SOCKET_ENTER, slot(self.OnPlayerEnter, self))  --玩家进入
    Notifier.remove(cmdName.GAME_SOCKET_READY, slot(self.OnPlayerReady, self))  --玩家准备 
    Notifier.remove(cmdName.GAME_SOCKET_GAMESTART, slot(self.OnGameStart, self))    --游戏开始
    Notifier.remove(cmdName.F1_GAME_BANKER,slot(self.OnGameBanker, self))   --定庄
    Notifier.remove(cmdName.GAME_SOCKET_GAME_DEAL, slot(self.OnGameDeal, self))      --发牌
    Notifier.remove(cmdName.F1_GAME_LAIZI, slot(self.OnGameLaiZi, self))    --定赖
    Notifier.remove(cmdName.MAHJONG_ASK_PLAY_CARD, slot(self.OnAskPlay, self))    --通知出牌
    Notifier.remove(cmdName.MAHJONG_PLAY_CARD, slot(self.OnPlayCard, self))      --出牌
    Notifier.remove(cmdName.MAHJONG_GIVE_CARD, slot(self.OnGiveCard, self))  --摸牌
    Notifier.remove(cmdName.MAHJONG_ASK_BLOCK,slot(self.OnGameAskBlock, self))--提示吃碰杠胡操作
    Notifier.remove(cmdName.MAHJONG_TRIPLET_CARD, slot(self.OnTriplet, self))    --碰牌
    Notifier.remove(cmdName.MAHJONG_QUADRUPLET_CARD, slot(self.OnQuadruplet, self))  --杠牌
    Notifier.remove(cmdName.MAHJONG_HU_CARD,slot(self.OnGameWin, self))              --胡
    Notifier.remove(cmdName.GAME_SOCKET_SMALL_SETTLEMENT, slot(self.OnGameRewards, self))    --结算
    Notifier.remove(cmdName.GAME_SOCKET_SYNC_TABLE, slot(self.OnSyncTable, self))    --重连同步表 

    Notifier.remove(cmdName.F3_START_FLAG, slot(self.OnStartFlag, self))     -- 游戏是否开始标记
end

function comp_show_base:Init()



    self.compTable = mode_manager.GetCurrentMode():GetComponent("comp_mjTable")
    self.compResMgr = mode_manager.GetCurrentMode():GetComponent("comp_resMgr")
    self.compMJItemMgr = mode_manager.GetCurrentMode():GetComponent("comp_mjItemMgr")
    self.compPlayerMgr = mode_manager.GetCurrentMode():GetComponent("comp_playerMgr")
    self.compDice = mode_manager.GetCurrentMode():GetComponent("comp_dice")

    self.outCardEfObj = self.compResMgr:GetOutCardEfObj()

    self.gvblFun = player_seat_mgr.GetViewSeatByLogicSeat
    self.gvblnFun = player_seat_mgr.GetViewSeatByLogicSeatNum
    self.gmlsFun = player_seat_mgr.GetMyLogicSeat  

    self.config = self.compTable.mode.config
    self.curState = self.game_state.none

    self:RegisterEvents()
end

function comp_show_base:Uinit()
    self:UnRegisterEvents()
    mahjong_anim_state_control.Reset()
    self.isInit = false
    self.compTable = nil
    self.compResMgr = nil
    self.compMJItemMgr = nil
    self.compPlayerMgr = nil

    self.outCardEfObj = nil
    self.gvblFun = nil 
    self.gmlsFun = nil
    self.gvblnFun = nil
    self.lightDirTbl = {}

    self.curState = self.game_state.none

    roomdata_center.nCurrJu = 0
end

--[[--
 * @Description: 更换桌布  
 ]]
function comp_show_base:OnChangeDesk(tbl)
    self.compTable:ChangeDeskCloth()
end

--[[--
 * @Description: 玩家进入房间  
 ]]
function comp_show_base:OnPlayerEnter(tbl)
    local logicSeat = tbl["_src"]
    local viewSeat = self.gvblFun(logicSeat)
    if viewSeat == 1 then
        self.curState = self.game_state.prepare
        local logicSeat_number = player_seat_mgr.GetLogicSeatByStr(logicSeat)
        if roomdata_center.MaxPlayer() == 2 and logicSeat_number == 2 then 
            logicSeat_number = 3
        end
        local mjDirObj = self.compTable:GetMJDirObj()
        if mjDirObj ~= nil then
            local dirTran = child(mjDirObj.transform, "dark_dir/direction_0"..tostring(logicSeat_number))
            local dirLightTran = child(mjDirObj.transform, "light_dir/direction_"..tostring(logicSeat_number))
            if dirTran ~= nil then
                dirTran.gameObject:SetActive(true)
            end
            if dirLightTran ~= nil then
                dirLightTran.gameObject:SetActive(true)
                for i=1,4 do
                    local t = child(dirLightTran, "direction_0"..tostring(i))
                    if roomdata_center.MaxPlayer() == 2 and (i == 2 or i == 4 ) then
              
                    else
                      table.insert(self.lightDirTbl,t)
                    end
                    
                end
            end
        end
    end     
end

--[[--
 * @Description: 初始化准备  
 ]]
function comp_show_base:InitForReady()
    if self.compTable.Clear then
        self.compTable:Clear()
    end
    DG.Tweening.DOTween.KillAll(false)
    self.compTable:StopAllCoroutine()
    -- 停止所有动画
    self.compMJItemMgr:InitMJItems()
    self.compTable:InitWall()
    self.compDice:Init()
    self:SetOutCardEfObj(nil, true)        
    self.compPlayerMgr:ResetPlayer()
    Trace("#self.lightDirTbl------------------"..#self.lightDirTbl)
    for i,v in ipairs(self.lightDirTbl) do
        --Trace("#self.lightDirTsbl------------------")
        v.gameObject:SetActive(false)
    end
end

--[[--
 * @Description: 玩家准备游戏  
 ]]
function comp_show_base:OnPlayerReady(tbl)
    local logicSeat = tbl["_src"]
    local viewSeat = self.gvblFun(logicSeat)

    if viewSeat == 1 then
        self:InitForReady()
        self.isInit = true
    end
end

function comp_show_base:OnStartFlag(tbl)
    roomdata_center.isRoundStart = tbl._para.flag == 1
    roomdata_center.supportClientTing = tbl._para.bIsNeedTing == 0
    --Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F3_START_FLAG)
end
--[[--
 * @Description: 游戏开始  
 ]]
function comp_show_base:OnGameStart(tbl)
    local neetTing = tbl._para.bIsNeedTing
    roomdata_center.supportClientTing = neetTing == 0
    mahjong_anim_state_control.Reset()
    mahjong_anim_state_control.ShowAnimState(MahjongGameAnimState.start, function()
        if isInit == false then
            self:InitForReady()
            self.isInit = true
        end
         self.compTable:ShowWall(function()
            Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAMESTART)
        end)     
    end, true)
end

function comp_show_base:OnGameBanker( tbl )
    self.curState = self.game_state.banker
end

--[[--
 * @Description: 开始发牌  
 ]]
function comp_show_base:OnGameDeal(tbl)
    self.curState = self.game_state.deal

    local dice_big = tbl["_para"]["dice"][1]
    local dice_small = tbl["_para"]["dice"][2]

    if dice_big < dice_small then
        local temp = dice_big
        dice_big = dice_small
        dice_small = temp
    end

    Trace("Dice========="..dice_big.." "..dice_small)

    self.compDice:Play(tbl["_para"]["dice"][1], tbl["_para"]["dice"][2], function ()
        Trace("GetBankerViewSeat()----------------------"..roomdata_center.GetBankerViewSeat())
        local viewSeat = roomdata_center.GetBankerViewSeat() + dice_big + dice_small -1
        viewSeat = viewSeat % 4
        if viewSeat == 0 then
            viewSeat = 4
        end

        local cards = tbl["_para"]["cards"]
        for i = 1, #cards do
            roomdata_center.AddMj(cards[i])
        end
        self.compTable:SendAllHandCard(
            mode_manager.GetCurrentMode().config.MahjongDunCount-dice_small - dice_big,
            viewSeat, cards, 
            function ()
               self.compPlayerMgr:AllSortHandCard()
                Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAME_DEAL)
        end)
    end)
    ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_shaizi", true))
end

--[[--
 * @Description: 定癞  
 ]]
function comp_show_base:OnGameLaiZi(tbl)
    Trace(GetTblData(tbl))
    roomdata_center.SetSpecialCard(tbl["_para"]["laizi"][1])

    local cardValue = tbl._para.cards[1]
    local dun = tbl._para.sits[1]/2
    Trace("OnGameLaiZi !!!!!!!!!!!!! dun "..dun.." cardValue "..cardValue)
    self.compTable:ShowLai(dun, cardValue, true, function()
        self.compPlayerMgr:GetPlayer(1):ShowSpecialInHand()
        self.compPlayerMgr:AllSortHandCard()
    end )

    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F1_GAME_LAIZI)
end

--[[--
 * @Description: 请求出牌  
 ]]
function comp_show_base:OnAskPlay(tbl)
    local viewSeat = self.gvblFun(tbl._src)

    local time = roomdata_center.timersetting.giveTimeOut
    if viewSeat == 1 then
        self.compTable:SetTime(time,true,3)
    else
        self.compTable:SetTime(time)
    end

    roomdata_center.currentPlayViewSeat = viewSeat

    self.curState = self.game_state.round
    
    if viewSeat == 1 then
        local filterCards = tbl._para
        self.compPlayerMgr:GetPlayer(viewSeat):SetCanOut(true, filterCards)            
    end

    --展示东南西北
    for i,v in ipairs(self.lightDirTbl) do
        v.gameObject:SetActive(false)
    end
    self.lightDirTbl[viewSeat].gameObject:SetActive(true)

    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_ASK_PLAY_CARD)
end

--[[--
 * @Description: 出牌  
 ]]
function comp_show_base:OnPlayCard(tbl)
    Trace(GetTblData(tbl))
    local src = tbl["_src"]
    local viewSeat = player_seat_mgr.GetViewSeatByLogicSeat(src)

    -- if viewSeat == 1 then
    --     mahjong_ui.cardShowView:Hide()
    --    self.compPlayerMgr:GetPlayer(viewSeat):HideTingInHand()
    --    self.compPlayerMgr:GetPlayer(viewSeat):SetCanOut(false)
    --    self.compPlayerMgr:HideHighLight()
    -- end
    local value = tbl["_para"]["cards"][1]
    if viewSeat ~= 1 then
        
        --Trace("!!!!!!!!!!!!!!!viewSeat"..tostring(viewSeat))
        self.compPlayerMgr:GetPlayer(viewSeat):OutCard(value, function (pos)
           self.compResMgr:SetOutCardEfObj(pos)
        end)

        ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_card_out", true))
        ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjSoundPath(value))
    else
        -- 交验出牌是否正确，不正确立即重连
        if value ~= roomdata_center.selfOutCard then
            SocketManager:reconnect()
            roomdata_center.selfOutCard = 0
        end
        roomdata_center.selfOutCard = 0
    end

    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_PLAY_CARD)
end

function comp_show_base:OnGameWin(tbl)
    Trace(GetTblData(tbl))
    -- self.compPlayerMgr:GetPlayer(1):RemoveClickEvent()
    local winner = tbl._para.stWinList[1].winner
    local win_type = tbl._para.stWinList[1].winType
    local win_who = tbl._para.stWinList[1].winWho
    local win_viewSeat = self.gvblnFun(winner)
    local cards = tbl._para.cards
    local cardWin = tbl._para.stWinList[1].cardWin

    if cards == nil or #cards == 0 then
        Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_HU_CARD)
        return
    end
    if win_type == "huangpai" then
        Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_HU_CARD)
    else
        local mj
        local isGun = false
        if win_type == "gunwin" then  -- 点炮
            if win_who ~= nil then
                local winWhoViewSeat = self.gvblnFun(win_who)
                mj = self.compPlayerMgr:GetPlayer(winWhoViewSeat):GetLastOutCard()
                self.compResMgr:HideOutCardEfObj()
                isGun = true
            end
        elseif win_type == "robgangwin" then  -- 抢杠
            local winWhoViewSeat = self.gvblnFun(win_who)
            mj = self.compPlayerMgr:GetPlayer(winWhoViewSeat):GetAddBarCard(cardWin)
        elseif win_type == "selfdraw" then  -- 自摸效果   
            -- 胡的牌单独处理 移出手牌
            mj = self.compPlayerMgr:GetPlayer(win_viewSeat):GetAndRemoveLastHandCard()
            self:RemoveValueFromList(cards, cardWin)
        elseif win_type == "robgoldwin" then  -- 抢金   
            if self.compTable.mjJin ~= nil then
                mj = self.compTable.mjJin
                mj:HideAndReset()
                mj.mjObj:SetActive(true)
            end
        end
        if mj ~= nil then
            mj:SetMesh(cardWin)
        end
        -- if mj ~=nil then
        --     self.compPlayerMgr:GetPlayer(win_viewSeat):WinAnimation(mj)
        -- end
        self.compPlayerMgr:GetPlayer(win_viewSeat):ShowWin(mj, cards, isGun)
    coroutine.start(function () 
        coroutine.wait(2.5)
        Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_HU_CARD)
        end)
    end

    
end

function comp_show_base:RemoveValueFromList(list, value)
    for i = #list, 1, -1 do
        if list[i] == value then
            table.remove(list, i)
            break
        end
    end
end

--[[--
 * @Description: 弃牌处理
 ]]
function comp_show_base:OnGiveCard(tbl)
    Trace(GetTblData(tbl))
    local src = tbl["_src"]
    local viewSeat = player_seat_mgr.GetViewSeatByLogicSeat(src)

    local value = MahjongTools.GetRandomCard()
    if viewSeat == 1 then
        value = tbl["_para"]["cards"][1]
    end

    self.compTable:SendCard(viewSeat, value)
    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_GIVE_CARD)
end

function comp_show_base:OnGameAskBlock( tbl )
    local time = roomdata_center.timersetting.blockTimeOut - tbl.time
    self.compTable:SetTime(time,true,3)

    self.curState = self.game_state.round
end

--[[--
 * @Description: 碰牌处理  
 ]]
function comp_show_base:OnTriplet( tbl )
    Trace(GetTblData(tbl))
    local operPlayViewSeat = self.gvblFun(tbl._src)
    local lastPlayViewSeat = self.gvblnFun(tbl._para.tripletWho)
    local offset = lastPlayViewSeat - operPlayViewSeat 
    local mj = self.compPlayerMgr:GetPlayer(lastPlayViewSeat):GetLastOutCard()

    if offset<1 then
        offset = offset +roomdata_center.MaxPlayer()
    end

    local operType = nil
    -- 3：左 2：中 1：右
    if(offset == 3) then
        operType = MahjongOperAllEnum.TripletLeft
    end
    if(offset == 2) then
        operType = MahjongOperAllEnum.TripletCenter
    end
    if(offset == 1) then
        operType = MahjongOperAllEnum.TripletRight
    end
    local operData = operatordata:New(operType, tbl._para.cardTriplet.triplet, tbl._para.cardTriplet.useCards, 17, tbl._para.tripletWho)

    self:SetOutCardEfObj(nil, true)
    self.compPlayerMgr:GetPlayer(operPlayViewSeat):OperateCard(operData, mj)

    ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjSoundPath("peng"))
    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_TRIPLET_CARD)
    if operPlayViewSeat ~= 1 then
        roomdata_center.AddMj(tbl._para.cardTriplet.triplet, 2)
    else
        self.compPlayerMgr:GetPlayer(operPlayViewSeat):HideTingInHand()
    end
end



--[[--
 * @Description: 杠牌处理  
 ]]
function comp_show_base:OnQuadruplet( tbl )
    Trace(GetTblData(tbl))
    local quadrupletWho = tbl._para.quadrupletWho
    local operPlayViewSeat = self.gvblFun(tbl._src)
    local lastPlayViewSeat = self.gvblnFun(tbl._para.quadrupletWho)
    local offset = lastPlayViewSeat - operPlayViewSeat 
    local mj  = nil

    if offset<1 then
        offset = offset +roomdata_center.MaxPlayer()
    end

    local quadrupletType = tbl._para.quadrupletType

    local operType
    local operData
    -- 3：左 2：中 1：右
    if quadrupletType == 1 then     --明杠
        mj =self.compPlayerMgr:GetPlayer(lastPlayViewSeat):GetLastOutCard()
        if(offset == 3) then
            operType = MahjongOperAllEnum.BrightBarLeft
        end
        if(offset == 2) then
            operType = MahjongOperAllEnum.BrightBarCenter
        end
        if(offset == 1) then
            operType = MahjongOperAllEnum.BrightBarRight
        end
        operData = operatordata:New(operType,tbl._para.cardQuadruplet.quadruplet, tbl._para.cardQuadruplet.useCards, 18, quadrupletWho)
        self.compResMgr:HideOutCardEfObj()
    end

    if quadrupletType == 2 then
        self.compPlayerMgr:GetPlayer(1):SetCanOut(false)
        operType = MahjongOperAllEnum.AddBar
        operData = operatordata:New(operType,tbl._para.cardQuadruplet.useCards[1], nil, 20, quadrupletWho)
    end

    if quadrupletType == 3 then
        operType = MahjongOperAllEnum.DarkBar
        table.remove(tbl._para.cardQuadruplet.useCards)
        operData = operatordata:New(operType,tbl._para.cardQuadruplet.useCards[1], tbl._para.cardQuadruplet.useCards, 19, quadrupletWho)
    end

    ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjSoundPath("gang"))
    self.compPlayerMgr:GetPlayer(operPlayViewSeat):OperateCard(operData, mj)                
    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_QUADRUPLET_CARD)

    if operPlayViewSeat ~= 1 then
        local card = tbl._para.cardQuadruplet.useCards[1]
        if quadrupletType == 1 then  --明杠加3张
            roomdata_center.AddMj(card, 3)
        elseif quadrupletType == 2 then -- 补杠加一张
            roomdata_center.AddMj(card, 1)
        end
    end
end



--[[--
 * @Description: 结算处理  
 ]]
function comp_show_base:OnGameRewards(tbl)
    self.compTable:StopTime()
    isInit = false
    self.compPlayerMgr:GetPlayer(1):SetCanOut(false)

    local rewards = tbl._para.rewards
    local who_win = tbl._para.who_win[1]
    
    local hasShow = false
    for i = 1, roomdata_center.MaxPlayer() do
        if i ~= who_win then
            local viewSeat = self.gvblnFun(i)
            self.compPlayerMgr:GetPlayer(viewSeat):ShowWinCards(rewards[i].cards, 
                function() 
                    if hasShow == false then
                        hasShow = true
                        mahjong_ui_sys.OnGameRewards(tbl) 
                    end
                end, 1)
        end
    end

    --ui_sound_mgr.PlaySoundClip("woman/hu")

  
end




function comp_show_base:OnSyncTable(tbl)
    local gameState = self.game_state
    local ePara = tbl._para
    local game_state = ePara.game_state         -- 游戏阶段
    local dealer = ePara.dealer                 -- 庄家
    local dice = ePara.dice                     -- 骰子
    local laizi = ePara.laizi                   -- 癞子
    local player_state = ePara.player_state     -- 玩家状态
    local tileCount = ePara.tileCount           -- 各玩家手牌数
    local tileLeft = ePara.tileLeft             -- 剩余牌子
    local tileList = ePara.tileList             -- 玩家手牌值
    local combineTile = ePara.combineTile       -- 各玩家吃碰杠
    local xiapao = ePara.xiapao                 -- 下跑
    local winTile = ePara.winTile               -- 各家所赢
    local discardTile = ePara.discardTile       -- 各玩家出的牌
    local whoisOnTurn = ePara.whoisOnTurn       -- 谁的回合
    local flowerTile = ePara.flowerTile         -- 花
    local subRound = ePara.subRound             -- 当前局
    local goldCard = {
        nOpenGoldCard = ePara.nOpenGoldCard,     -- 开的金牌
        nGoldCardPos = ePara.nGoldCardPos,       -- 金牌在剩余牌堆tileLeft的位置
    }
    local nLastGiveChair = ePara.nLastGiveChair  -- 最后出牌的人
    local state = MahjongSyncGameState[game_state]
    if state == nil then
        logError("找不到state", game_state);
        state = 0
    end

    roomdata_center.mjMap = {}
    
    mahjong_anim_state_control.Reset()

    if state < 300 then
        mahjong_ui.HideSpecialCard()
    end
    if state >= 200 then   --准备
        self:InitForReady()
    end

    if state >= 300 then        -- xiapao
        self.compTable:ReShowWall()
    end

    if state >= 400 then    -- 发牌
        self.curState = gameState.deal
        mahjong_anim_state_control.SetState(2)

        self:OnResetDealer(dealer)
        if subRound ~= 0 and tileLeft ~= 0 then
            self:OnResetGameInfo(subRound, tileLeft)
        end
    end


    if state >= 500 then
        self:OnResetWall(dice)
        -- self:OnResetHandCard(tileCount, tileList)

        if state < 600 then
            --恢复玩家牌
            self:OnResetCard( discardTile ,combineTile,tileCount,tileList)
        end

        if state >= 510 then --补花
            mahjong_anim_state_control.SetState(3)
        end

        if state >= 520 then  -- 开金
             --恢复花
            if flowerTile~=nil then
                self:OnResetFlowerCards( flowerTile )
            end
        end
       
        
    end

    if state >= 600 then  -- 打牌阶段
         self.curState = gameState.round
        --恢复癞子
        if laizi~=nil then
            self:OnResetLai(laizi)
        end
          --恢复金
        if goldCard~=nil then
            self:OnResetGoldCard( goldCard.nOpenGoldCard )
        end

        --恢复玩家牌
        self:OnResetCard( discardTile ,combineTile,tileCount,tileList)
        
        -- 手牌依赖operate card
        -- self:OnResetOperateCard(combineTile)
        -- self:OnResetDiscardCard(discardTile)

          --是否玩家出牌
        -- if whoisOnTurn == self.gmlsFun() then
        --    self.compPlayerMgr:GetPlayer(1):SetCanOut(true)
        -- end  

        --展示东南西北
        for i,v in ipairs(self.lightDirTbl) do
            v.gameObject:SetActive(false)
        end
        self.lightDirTbl[self.gvblnFun(whoisOnTurn)].gameObject:SetActive(true)   

        if nLastGiveChair~=nil and nLastGiveChair~=0 then
            local viewSeat = self.gvblnFun(nLastGiveChair)
            local mj = self.compPlayerMgr:GetPlayer(viewSeat):GetLastOutCard(true)
            if mj ~=nil then
                self.compResMgr:SetOutCardEfObj(mj.transform.position + Vector3.New(0, 0.102, 0))
            end
        end
    end

    --local nleftTime = ePara.nleftTime             -- 
    --local cardLastDraw = ePara.cardLastDraw       -- 
    -- if game_state == "prepare" then         --准备阶段
    --     self:InitForReady()
    -- elseif game_state == "xiapao" then      --下跑阶段
    --     self:InitForReady()
    --     self.compTable:ReShowWall()
    -- elseif game_state == "deal" then        --发牌阶段
    --     self:InitForReady()
    --     self.curState = game_state.deal
    --     self.compTable:ReShowWall()
    --     mahjong_anim_state_control.SetState(2)
    -- elseif game_state == "laizi" then       --癞子阶段
    --     self:InitForReady()
    --     --恢复牌墙
    --     self:OnResetWall(dice)
    --     --恢复玩家牌
    --     self:OnResetCard( discardTile ,combineTile,tileCount,tileList)

    -- elseif game_state == "changeflower" then
    --       self:InitForReady()
    --     --恢复牌墙
    --     self:OnResetWall(dice)
    --     --恢复玩家牌
    --     self:OnResetCard( discardTile ,combineTile,tileCount,tileList)
    --     mahjong_anim_state_control.SetState(3)
    -- elseif game_state == "opengold" then
    --      mahjong_anim_state_control.SetState(3)
    --     self:InitForReady()
    --     --恢复牌墙
    --     self:OnResetWall(dice)
      
    --     --恢复花
    --     if flowerTile~=nil then
    --         self:OnResetFlowerCards( flowerTile )
    --     end

    --     if goldCard~=nil then
    --         self:OnResetGoldCard(goldCard.nOpenGoldCard)
    --     end

    --     --恢复玩家牌
    --     self:OnResetCard( discardTile ,combineTile,tileCount,tileList)

    -- elseif game_state == "round" then       --出牌阶段
    --      mahjong_anim_state_control.SetState(3)
    --     self:InitForReady()
    --     self.curState = game_state.round
    --     --恢复牌墙
    --     self:OnResetWall(dice)
    --     --恢复癞子
    --     if laizi~=nil then
    --         self:OnResetLai(laizi)
    --     end
       
    --     --恢复花
    --     if flowerTile~=nil then
    --         self:OnResetFlowerCards( flowerTile )
    --     end
    --     --恢复金
    --     if goldCard~=nil then
    --         self:OnResetGoldCard( goldCard.nOpenGoldCard )
    --     end

    --     --恢复玩家牌
    --     self:OnResetCard( discardTile ,combineTile,tileCount,tileList)

    --     --是否玩家出牌
    --     if whoisOnTurn == self.gmlsFun() then
    --        self.compPlayerMgr:GetPlayer(1):SetCanOut(true)
    --     end  

    --     --展示东南西北
    --     for i,v in ipairs(self.lightDirTbl) do
    --         v.gameObject:SetActive(false)
    --     end
    --     self.lightDirTbl[self.gvblnFun(whoisOnTurn)].gameObject:SetActive(true)   

    -- elseif game_state == "reward" then      --结算阶段
    --     --todo
    -- elseif game_state == "gameend" then     --结束阶段
    --     --todo
    -- end        


end







function comp_show_base:OnResetFlowerCards(flowerCardsList)
    roomdata_center.playerFlowerCards = {}
    for i = 1, roomdata_center.MaxPlayer() do
        local count = #flowerCardsList[i]
        local cards = self.compTable:GetResetCardsFromLast(count)
        local viewSeat = self.gvblnFun(i)
        roomdata_center.SetPlayerFlowersCards(viewSeat, flowerCardsList[i])
        for j = 1, #cards do
            cards[j]:HideAndReset()
        end
    end
end

function comp_show_base:OnResetDealer(dealer)
    local banker_viewSeat = self.gvblFun(dealer)
    roomdata_center.zhuang_viewSeat = banker_viewSeat
end


--恢复牌墙
function comp_show_base:OnResetWall(dice)
    roomdata_center.SetRoomLeftCard(mode_manager.GetCurrentMode().config.MahjongTotalCount)
    local dice_big = dice[1]
    local dice_small = dice[2]
    if dice_big < dice_small then
        local temp = dice_big
        dice_big = dice_small
        dice_small = temp
    end
    local viewSeat = roomdata_center.GetBankerViewSeat() + dice_big + dice_small -1
    viewSeat = viewSeat % 4
    if viewSeat == 0 then
        viewSeat = 4
    end
    self.compTable:ResetWall(mode_manager.GetCurrentMode().config.MahjongDunCount-dice_small - dice_big, viewSeat)
end

function comp_show_base:OnResetLai(laizi)
    if laizi.sit[1]~=nil and laizi.card[1]~=nil then
        roomdata_center.SetSpecialCard(laizi.laizi[1])
        self.compTable:ShowLai(laizi.laizi[1]/2, laizi.card[1])
    end
end


function comp_show_base:OnResetHandCard(tileCount, tileList)
     --手牌
    for i=1,roomdata_center.MaxPlayer() do
        local count = tileCount[i]
        local viewSeat = self.gvblnFun(i)
        local cardItems =self.compTable:GetResetCards(count)
        if viewSeat == 1 then
           self.compPlayerMgr:GetPlayer(viewSeat):ResetHandCard(cardItems, tileList)
        else
           self.compPlayerMgr:GetPlayer(viewSeat):ResetHandCard(cardItems)
        end
    end
    self.compPlayerMgr:GetPlayer(1):ShowSpecialInHand()
end

function comp_show_base:OnResetOperateCard(combineTile)
     --操作牌
    for i=1,roomdata_center.MaxPlayer() do
        local operData = combineTile[i]
        local viewSeat = self.gvblnFun(i)
        self.compPlayerMgr:GetPlayer(viewSeat):ResetOperCard(
            function(count)
                return self.compTable:GetResetCards(count)
            end,
        operData)        
    end
end

function comp_show_base:OnResetDiscardCard(discardTile)
     local hasoutCard = false
    --出牌
    for i=1,roomdata_center.MaxPlayer() do
        local count = #discardTile[i]
        local viewSeat = self.gvblnFun(i)
        local cardItems =self.compTable:GetResetCards(count)
        if not hasoutCard and count > 0 then
            hasoutCard = true
        end
        self.compPlayerMgr:GetPlayer(viewSeat):ResetOutCard(cardItems, discardTile[i])
    end
    if hasoutCard then
        roomdata_center.beginSendCard = true
    end
end


--恢复玩家牌
function comp_show_base:OnResetCard( discardTile, combineTile, tileCount, tileList)
    local hasoutCard = false
    --出牌
    for i=1,roomdata_center.MaxPlayer() do
        local count = #discardTile[i]
        local viewSeat = self.gvblnFun(i)
        local cardItems =self.compTable:GetResetCards(count)
        if not hasoutCard and count > 0 then
            hasoutCard = true
        end
        self.compPlayerMgr:GetPlayer(viewSeat):ResetOutCard(cardItems, discardTile[i])
    end
    if hasoutCard then
        roomdata_center.beginSendCard = true
    end

    --操作牌
    for i=1,roomdata_center.MaxPlayer() do
        local operData = combineTile[i]
        local viewSeat = self.gvblnFun(i)
        self.compPlayerMgr:GetPlayer(viewSeat):ResetOperCard(
            function(count)
                return self.compTable:GetResetCards(count)
            end,
        operData)        
    end

    --手牌
    for i=1,roomdata_center.MaxPlayer() do
        local count = tileCount[i]
        local viewSeat = self.gvblnFun(i)
        local cardItems =self.compTable:GetResetCards(count)
        if viewSeat == 1 then
           self.compPlayerMgr:GetPlayer(viewSeat):ResetHandCard(cardItems, tileList)
        else
           self.compPlayerMgr:GetPlayer(viewSeat):ResetHandCard(cardItems)
        end
    end
    self.compPlayerMgr:GetPlayer(1):ShowSpecialInHand()

end

function comp_show_base:OnResetGameInfo(subRound, leftCard)
    mahjong_ui.SetGameInfoVisible(true)
    roomdata_center.nCurrJu = subRound
    mahjong_ui.SetRoundInfo(subRound, roomdata_center.nJuNum)
    roomdata_center.SetRoomLeftCard(leftCard)
end


function comp_show_base:OnResetGoldCard( jin )
     if jin ~= nil then
        roomdata_center.SetSpecialCard(jin)
        self.compTable:ShowJin(jin, true)
        roomdata_center.AddMj(jin)
    end
end

--[[--
 * @Description: 设置出牌特效  
 ]]
function comp_show_base:SetOutCardEfObj(pos, isHide)
    if self.outCardEfObj ~= nil and (not IsNil(self.outCardEfObj)) then
        if isHide ~= nil and isHide then
            self.outCardEfObj.transform.position = self.outCardEfObj.transform.position + Vector3(0, -1, 0)
        else        
            if pos ~= nil then
                self.outCardEfObj.transform.position = pos
            end
        end
    end
end


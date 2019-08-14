--[[--
 * @Description: 组件表现基类
 * @Author:      shine
 * @FileName:    comp_show_base.lua
 * @DateTime:    2017-07-07 20:50:48
 ]]


local mahjong_path_mgr = mahjong_path_mgr

comp_show_base = 
{
    isInit = false,
    compTable = nil,
    outCardEfObj = nil,
    compResMgr = nil,
    compMjItemMgr = nil,
    compPlayerMgr = nil,

    gvblFun = nil,        --逻辑座位(带P)
    gvblnFun = nil,    --逻辑座位(不带P)
    gmlsFun = nil         --本地座位  
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
    Notifier.regist(cmdName.GAME_SOCKET_BANKER,slot(self.OnGameBanker, self))   --定庄
    Notifier.regist(cmdName.GAME_SOCKET_GAME_DEAL, slot(self.OnGameDeal, self))      --发牌
    Notifier.regist(cmdName.F1_GAME_LAIZI, slot(self.OnGameLaiZi, self))    --定赖
    Notifier.regist(cmdName.MAHJONG_CI, slot(self.OnGameCi, self))          --定次
    Notifier.regist(cmdName.MAHJONG_PLAY_CARDSTART,slot(self.OnPlayStart, self))--打牌开始
    Notifier.regist(cmdName.MAHJONG_ASK_PLAY_CARD, slot(self.OnAskPlay, self))    --通知出牌
    Notifier.regist(cmdName.MAHJONG_PLAY_CARD, slot(self.OnPlayCard, self))      --出牌
    Notifier.regist(cmdName.MAHJONG_ASK_BLOCK,slot(self.OnGameAskBlock, self))                --提示吃碰杠胡操作
    Notifier.regist(cmdName.MAHJONG_GIVE_CARD, slot(self.OnGiveCard, self))  --摸牌
    Notifier.regist(cmdName.MAHJONG_TRIPLET_CARD, slot(self.OnTriplet, self))    --碰牌
    Notifier.regist(cmdName.MAHJONG_QUADRUPLET_CARD, slot(self.OnQuadruplet, self))  --杠牌
    Notifier.regist(cmdName.MAHJONG_YINGKOU, slot(self.OnYingKou, self))  --硬扣 
    Notifier.regist(cmdName.MAHJONG_HU_CARD,slot(self.OnGameWin, self))              --胡
    Notifier.regist(cmdName.GAME_SOCKET_SMALL_SETTLEMENT, slot(self.OnGameRewards, self))    --结算
    Notifier.regist(cmdName.GAME_SOCKET_SYNC_TABLE, slot(self.OnSyncTable, self))    --重连同步表 
    Notifier.regist(cmdName.F3_START_FLAG, slot(self.OnStartFlag, self))     -- 游戏是否开始标记
    Notifier.regist(cmdName.GAME_TINGSTATE, slot(self.ResetTingState, self))     -- 重连听状态
    Notifier.regist(cmdName.MAHJONG_CHANGE_FLOWER, slot(self.OnChangeFlower, self)) -- 补花
    Notifier.regist(cmdName.MAHJONG_OPEN_GOLD, slot(self.OnGameOpenGlod, self))  -- 开金
    Notifier.regist(cmdName.MAHJONG_ROB_GOLD, slot(self.OnRobGold, self)) -- 抢金
    Notifier.regist(cmdName.MAHJONG_COLLECT_CARD, slot(self.OnGameCollect, self)) -- 吃 
    Notifier.regist(cmdName.MAHJONG_LIANGXIER_CARD, slot(self.OnGameLiangXiEr, self)) -- 亮喜儿
    Notifier.regist(cmdName.MAHJONG_QIANGTING, slot(self.OnGameQiangTing, self)) -- 抢听
    Notifier.regist(cmdName.MAHJONG_HU_TIPS_CARD, slot(self.OnTing, self))       --胡牌提示
    Notifier.regist(cmdName.MAHJONG_TINGINFO, slot(self.OnTingInfo, self))       --胡牌提示
    Notifier.regist(cmdName.MAHJONG_SHOWCARD,slot(self.ShowCard, self)) --显示手牌
    Notifier.regist(cmdName.MSG_ON_GUO_CLICK, slot(self.OnGuoClick, self))
    Notifier.regist(cmdName.GAME_CHANGE_TABLE, slot(self.OnChangeTable, self)) -- 换桌
    Notifier.regist(cmdName.F1_GAME_GOXIAPAO, slot(self.OnAskXiaPao, self))
    Notifier.regist(cmdName.F1_GAME_ALLXIAPAO, slot(self.OnAllXiaPao, self))

    Notifier.regist(cmdName.GAME_SOCKET_GAMEEND, slot(self.OnGameEnd, self))
end

function comp_show_base:UnRegisterEvents()
    Notifier.remove(cmdName.GAME_CHANGE_TABLE, slot(self.OnChangeTable, self)) -- 换桌
    Notifier.remove(cmdName.MSG_CHANGE_DESK,slot(self.OnChangeDesk, self)) --更换桌布
    Notifier.remove(cmdName.GAME_SOCKET_ENTER, slot(self.OnPlayerEnter, self))  --玩家进入
    Notifier.remove(cmdName.GAME_SOCKET_READY, slot(self.OnPlayerReady, self))  --玩家准备 
    Notifier.remove(cmdName.GAME_SOCKET_GAMESTART, slot(self.OnGameStart, self))    --游戏开始
    Notifier.remove(cmdName.GAME_SOCKET_BANKER,slot(self.OnGameBanker, self))   --定庄
    Notifier.remove(cmdName.GAME_SOCKET_GAME_DEAL, slot(self.OnGameDeal, self))      --发牌
    Notifier.remove(cmdName.F1_GAME_LAIZI, slot(self.OnGameLaiZi, self))    --定赖
    Notifier.remove(cmdName.MAHJONG_CI, slot(self.OnGameCi, self))          --定次
    Notifier.remove(cmdName.MAHJONG_PLAY_CARDSTART,slot(self.OnPlayStart, self))--打牌开始
    Notifier.remove(cmdName.MAHJONG_ASK_PLAY_CARD, slot(self.OnAskPlay, self))    --通知出牌
    Notifier.remove(cmdName.MAHJONG_PLAY_CARD, slot(self.OnPlayCard, self))      --出牌
    Notifier.remove(cmdName.MAHJONG_GIVE_CARD, slot(self.OnGiveCard, self))  --摸牌
    Notifier.remove(cmdName.MAHJONG_ASK_BLOCK,slot(self.OnGameAskBlock, self))--提示吃碰杠胡操作
    Notifier.remove(cmdName.MAHJONG_TRIPLET_CARD, slot(self.OnTriplet, self))    --碰牌
    Notifier.remove(cmdName.MAHJONG_QUADRUPLET_CARD, slot(self.OnQuadruplet, self))  --杠牌
    Notifier.remove(cmdName.MAHJONG_HU_CARD,slot(self.OnGameWin, self))              --胡
    Notifier.remove(cmdName.GAME_SOCKET_SMALL_SETTLEMENT, slot(self.OnGameRewards, self))    --结算
    Notifier.remove(cmdName.GAME_SOCKET_SYNC_TABLE, slot(self.OnSyncTable, self))    --重连同步表 
    Notifier.remove(cmdName.GAME_TINGSTATE, slot(self.ResetTingState, self))     -- 重连听状态
    Notifier.remove(cmdName.F3_START_FLAG, slot(self.OnStartFlag, self))     -- 游戏是否开始标记
    Notifier.remove(cmdName.MAHJONG_CHANGE_FLOWER, slot(self.OnChangeFlower, self)) -- 补花
    Notifier.remove(cmdName.MAHJONG_OPEN_GOLD, slot(self.OnGameOpenGlod, self))  -- 开金
    Notifier.remove(cmdName.MAHJONG_ROB_GOLD, slot(self.OnRobGold, self)) -- 抢金
    Notifier.remove(cmdName.MAHJONG_COLLECT_CARD, slot(self.OnGameCollect, self)) -- 吃 
    Notifier.remove(cmdName.MAHJONG_LIANGXIER_CARD, slot(self.OnGameLiangXiEr, self)) -- 亮喜儿
    Notifier.remove(cmdName.MAHJONG_QIANGTING, slot(self.OnGameQiangTing, self)) -- 抢听
    Notifier.remove(cmdName.MAHJONG_HU_TIPS_CARD, slot(self.OnTing, self))--胡牌提示
    
    Notifier.remove(cmdName.MAHJONG_TINGINFO, slot(self.OnTingInfo, self))       --胡牌提示
    Notifier.remove(cmdName.MSG_ON_GUO_CLICK, slot(self.OnGuoClick, self))

    Notifier.remove(cmdName.F1_GAME_GOXIAPAO, slot(self.OnAskXiaPao, self))
    Notifier.remove(cmdName.F1_GAME_ALLXIAPAO, slot(self.OnAllXiaPao, self))
    Notifier.remove(cmdName.GAME_SOCKET_GAMEEND, slot(self.OnGameEnd, self))
end


function comp_show_base:OnAskXiaPao(tbl)
    local time = tbl.timeo
    if time > 8 then
        time = 8
    end
    self.compTable:SetTime(time, true, 3,{3})
end

function comp_show_base:OnAllXiaPao()
    self.compTable:StopTime()
end


function comp_show_base:InitActionCtrl()
    local actionCtrlClass = require "logic/mahjong_sys/action/common/mahjong_action_ctrl"
    self.actionCtrl = actionCtrlClass.new()
    self.actionCtrl:Init(2)

    Trace("InitActionCtrl------------------------------2")
end

function comp_show_base:Init()
    self.compTable = mode_manager.GetCurrentMode():GetComponent("comp_mjTable")
    self.compResMgr = mode_manager.GetCurrentMode():GetComponent("comp_resMgr")
    self.compMjItemMgr = mode_manager.GetCurrentMode():GetComponent("comp_mjItemMgr")
    self.compPlayerMgr = mode_manager.GetCurrentMode():GetComponent("comp_playerMgr")
    self.compDice = mode_manager.GetCurrentMode():GetComponent("comp_dice")

    self.outCardEfObj = self.compResMgr:GetOutCardEfObj()

    self.gvblFun = player_seat_mgr.GetViewSeatByLogicSeat
    self.gvblnFun = player_seat_mgr.GetViewSeatByLogicSeatNum
    self.gmlsFun = player_seat_mgr.GetMyLogicSeat  

    self.config = self.compTable.mode.config
    self.cfg = self.compTable.mode.cfg
    self.curState = self.config.game_state.none

    self:InitActionCtrl()
    self:RegisterEvents()

    self:InitSpecialGameSetting()
end

function comp_show_base:OnGameEnd()
    self.compTable:SetCurLightDir(0)
    self.compPlayerMgr.selfPlayer:StopShakeTimer()
end

function comp_show_base:Uinit()   
    self.actionCtrl:UnInit()  
    self:UnRegisterEvents()  
    
    self.isInit = false
    self.compTable = nil
    self.compResMgr = nil
    self.compMjItemMgr = nil
    self.compPlayerMgr = nil

    self.outCardEfObj = nil
    self.gvblFun = nil 
    self.gmlsFun = nil
    self.gvblnFun = nil
     
    self.curState = self.config.game_state.none
end

function comp_show_base:InitSpecialGameSetting()
    local action = self.actionCtrl:GetAction("game_setting")
    if action ~= nil then
        action:Execute(tbl)
    end
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
        self.curState = self.config.game_state.prepare
        local logicSeat_number = player_seat_mgr.GetLogicSeatByStr(logicSeat)
        if roomdata_center.MaxPlayer() == 2 and logicSeat_number == 2 then 
            logicSeat_number = 3
        end

        self.compTable:SetDirection(logicSeat_number)
        
        self.compTable:SetRoomNum(roomdata_center.roomnumber)       
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
    co_mgr.stopAll()
    self.compTable:StopAllCoroutine()
    -- 停止所有动画
    self.compMjItemMgr:InitMJItems()
    self.compTable:InitWall()
    self.compDice:Init()
    self:SetOutCardEfObj(nil, true)        
    self.compPlayerMgr:ResetPlayer()
    -- roomdata_center.leftCard = roomdata_center.GetTotalCard() 
    -- mahjong_ui:SetLeftCard(roomdata_center.leftCard)    
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
    mahjong_client_ting_mgr:SetClientTing(tbl._para.bIsNeedTing == 0)
    --Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F3_START_FLAG)
end
--[[--
 * @Description: 游戏开始  
 ]]
function comp_show_base:OnGameStart(tbl)
    local action = self.actionCtrl:GetAction("game_start")
    if action ~= nil then
        action:Execute(tbl)
    end
end

function comp_show_base:OnGameBanker( tbl )
    self.curState = self.config.game_state.banker
end

--[[--
 * @Description: 开始发牌  
 ]]
function comp_show_base:OnGameDeal(tbl)
    self.curState = self.config.game_state.deal

    local dice_big = tbl["_para"]["dice"][1]
    local dice_small = tbl["_para"]["dice"][2]
    roomdata_center.dice = tbl["_para"]["dice"]
    if dice_big < dice_small then
        local temp = dice_big
        dice_big = dice_small
        dice_small = temp
    end 
    self.compDice:Init()
    self.compDice:Play(tbl["_para"]["dice"][1], tbl["_para"]["dice"][2], function ()        
        local viewSeat = roomdata_center.GetBankerViewSeat() + dice_big + dice_small -1
        viewSeat = viewSeat % 4
        if viewSeat == 0 then
            viewSeat = 4
        end

        local action = self.actionCtrl:GetAction("game_setWind")
        if action ~= nil then
            action:Execute(viewSeat)
        end

        local cards = tbl["_para"]["cards"]

        local wallCounts = mode_manager.GetCurrentMode().config.wallDunCountMap

        self.compTable:SendAllHandCard(
            wallCounts[viewSeat]-dice_small - dice_big,
            viewSeat, cards, 
            function ()
                self.compPlayerMgr:AllSortHandCard()
                Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_SOCKET_GAME_DEAL)
        end)
    end)
    ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_shaizi"))
end

--[[--
 * @Description: 定癞  
 ]]
function comp_show_base:OnGameLaiZi(tbl)
    Trace(GetTblData(tbl))
    local action = self.actionCtrl:GetAction("game_laiZi")
    if action ~= nil then
        action:Execute(tbl)
    else
        roomdata_center.SetSpecialCard(tbl["_para"]["laizi"][1])

        local cardValue = tbl._para.cards[1]
        local dun = tbl._para.sits[1]/2

        self.compTable:ShowLai(dun, cardValue, true, function()
            self.compPlayerMgr.selfPlayer:ShowSpecialInHand()
            self.compPlayerMgr:AllSortHandCard()
        end )
    end
	-- Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F1_GAME_LAIZI)
end

function comp_show_base:OnGameCi(tbl)
    local action = self.actionCtrl:GetAction("game_ci")
    if action ~= nil then
        action:Execute(tbl)
    end
   -- Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_CI)    
end

function comp_show_base:OnPlayStart(tbl)
    self.curState = self.config.game_state.round
    local action = self.actionCtrl:GetAction("game_playStart")
    if action ~= nil then
        action:Execute(tbl)
    end
end

--[[--
 * @Description: 请求出牌  
 ]]
function comp_show_base:OnAskPlay(tbl)
    local viewSeat = self.gvblFun(tbl._src)

    self.curState = self.config.game_state.round

    local action = self.actionCtrl:GetAction("game_askPlay")
    if action ~= nil then
        action:Execute(tbl)
    end

    if mahjong_gm_manager and mahjong_gm_manager.isOpenGMMode and viewSeat == 1 then
        mahjong_gm_manager:AskPlay()
    end

    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_ASK_PLAY_CARD)
end

--[[--
 * @Description: 出牌  
 ]]
function comp_show_base:OnPlayCard(tbl)
    --Trace(GetTblData(tbl))
    local src = tbl["_src"]
    local viewSeat = player_seat_mgr.GetViewSeatByLogicSeat(src)

    -- if viewSeat == 1 then
    --     mahjong_ui:cardShowView:Hide()
    --    self.compPlayerMgr:GetPlayer(viewSeat):HideTingInHand()
    --    self.compPlayerMgr:GetPlayer(viewSeat):SetCanOut(false)
    --    self.compPlayerMgr:HideHighLight()
    -- end
    local value = tbl["_para"]["cards"][1]
    local isShow=tbl["_para"]["bShowGive"]
    if viewSeat ~= 1 then        
        if isShow~=nil then 
            self.compPlayerMgr:GetPlayer(viewSeat):OutCard(value, function (pos)
               self.compResMgr:SetOutCardEfObj(pos)
               Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_PLAY_CARD)
            end,isShow)  
        else  
            self.compPlayerMgr:GetPlayer(viewSeat):OutCard(value, function (pos)
               self.compResMgr:SetOutCardEfObj(pos)
               Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_PLAY_CARD)
            end) 
        end
        roomdata_center.AddMj(value)
        ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_card_out"))
        ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjSoundPath(value))
    else         
        -- 交验出牌是否正确，不正确立即重连        
        if value ~= roomdata_center.selfOutCard and roomdata_center.tingType == 0 then
            SocketManager:reconnect()
            roomdata_center.selfOutCard = 0
        -- 听牌服务器出牌，无需校验
        elseif roomdata_center.selfOutCard == 0 and roomdata_center.tingType ~= 0 then
            self.compPlayerMgr:GetPlayer(viewSeat):OutCard(value, function (pos)
               self.compResMgr:SetOutCardEfObj(pos)
               Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_PLAY_CARD)
               self.compPlayerMgr:GetPlayer(1):HideTingInHand()
            end,isShow) 
            ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("audio_card_out"))
            ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjSoundPath(value))
        else
            Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_PLAY_CARD) 
        end
        self.compTable:StopShakeTime()
        self.compPlayerMgr.selfPlayer:StopShakeTimer()
        roomdata_center.selfOutCard = 0
        roomdata_center.tingVersion = roomdata_center.tingVersion + 1              
    end
    -- roomdata_center.selfOutCard = 0
    -- roomdata_center.tingVersion = roomdata_center.tingVersion + 1 
end

function comp_show_base:OnGameWin(tbl)
    Trace(GetTblData(tbl))
    local win_type = tbl._para.stWinList[1].winType
    -- local cards = tbl._para.cards

    -- if cards == nil or #cards == 0 then
    --     Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_HU_CARD)
    --     return
    -- end
    for i=1,roomdata_center.maxplayernum do
        local player=self.compPlayerMgr:GetPlayer(i)
        for k=1,#player.handCardList do
            local item=player.handCardList[k]
            item:SetParent(player.handCardPoint,false)
        end
    end
    if win_type == "huangpai" then
        Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_HU_CARD)
    else
        for i,v in ipairs(tbl._para.stWinList or {}) do
            local winner = v.winner
            local win_who = v.winWho
            local win_viewSeat = self.gvblnFun(winner)
            local cardWin = v.cardWin
            local handcards = v.cards
            local mj
            local isGun = false
            if handcards == nil or #handcards == 0 then
                Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_HU_CARD)
                return
            end
            if win_type == "gunwin" then  -- 点炮
                if win_who ~= nil then
                    local winWhoViewSeat = self.gvblnFun(win_who)
                    if i == 1 then
                        mj = self.compPlayerMgr:GetPlayer(winWhoViewSeat):GetLastOutCard()
                    else
                        -- TODO
                    end
                    self.compResMgr:HideOutCardEfObj()
                    isGun = true
                end
            elseif win_type == "robgangwin" then  -- 抢杠
                local winWhoViewSeat = self.gvblnFun(win_who)
                mj = self.compPlayerMgr:GetPlayer(winWhoViewSeat):GetAddBarCard(cardWin)
            elseif win_type == "selfdraw" then  -- 自摸效果   
                -- 胡的牌单独处理 移出手牌
                mj = self.compPlayerMgr:GetPlayer(win_viewSeat):GetAndRemoveLastHandCard()
                self:RemoveValueFromList(handcards, cardWin)
            elseif win_type == "robgoldwin" then  -- 抢金   
                if self.compTable.mjJin[1] ~= nil then
                    mj = self.compTable.mjJin[1]
                    mj:HideAndReset()
                    mj:SetActive(true)
                end
            end
            if mj ~= nil then
                mj:SetMesh(cardWin)
            end

            self.compPlayerMgr:GetPlayer(win_viewSeat):ShowWin(mj, handcards, isGun)
        end
        coroutine.start(function () 
            coroutine.wait(1.2)
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
 * @Description: 摸牌处理
 ]]
function comp_show_base:OnGiveCard(tbl) 
    local src = tbl["_src"]
    local viewSeat = player_seat_mgr.GetViewSeatByLogicSeat(src)

    local value = MahjongTools.GetRandomCard()
    if viewSeat == 1 then
        value = tbl["_para"]["cards"][1]
        self.cardLastDraw=value
    end

    if tbl["_para"].bLast and self.cfg.quadrupletSendLast then
        self.compTable:SendCardFromLast(viewSeat,value,false)
    else
        self.compTable:SendCard(viewSeat, value)
    end

    roomdata_center.SetRoomLeftCard(tbl._para.cardLeft)
    
    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_GIVE_CARD)
end

function comp_show_base:OnYingKou(tbl)
    --logError( json.encode(tbl))
    local viewSeat=self.gvblFun(tbl._src)
    if tbl._para.yingkou  then
        mahjong_ui:ShowYingKou(viewSeat)
    end
    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_YINGKOU) 
end

function comp_show_base:OnGameAskBlock( tbl )
    local time = roomdata_center.timersetting.blockTimeOut - tbl.time
    self.compTable:SetTime(time,true,3)

    self.curState = self.config.game_state.round

    if mahjong_anim_state_control.GetCurrentStateName() ~= MahjongGameAnimState.none then
        mahjong_anim_state_control.SetStateByName(MahjongGameAnimState.none)
    end 
end

function comp_show_base:ShowCard(tbl) 
    local num=self.gvblnFun(tonumber(tbl._para.nChair)) 
    if roomdata_center.tingType==0 then
        if #tbl._para.stCards>3 then
            self.compPlayerMgr:GetPlayer(num):ShowFourCard(tbl._para.stCards,false) 
        else 
            self.compPlayerMgr:GetPlayer(num):ShowFourCard(tbl._para.stCards,true) 
        end
    else
       
        if num~=1 then 
            self.compPlayerMgr:GetPlayer(num):ShowFourCard(tbl._para.stCards,true) 
        end
    end 
    self.compPlayerMgr:GetPlayer(num):SetFourCard(tbl._para.stCards)  
    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_SHOWCARD)
end
--[[--
 * @Description: 碰牌处理  
 ]]
function comp_show_base:OnTriplet( tbl )
    --Trace("OnTriplet() tbl = "..GetTblData(tbl))
    local operPlayViewSeat = self.gvblFun(tbl._src)
    local lastPlayViewSeat = self.gvblnFun(tbl._para.tripletWho)
    local offset = lastPlayViewSeat - operPlayViewSeat
    local mj  = nil

    if offset<1 then
        offset = offset +roomdata_center.MaxPlayer()
    end
    offset = player_seat_mgr.ViewSeatOffsetToIndexOffset(offset)
    local nbzz = tbl._para.nbzz--获取BZZ信息
    if nbzz and tonumber(nbzz) ~= 0 and lastPlayViewSeat == operPlayViewSeat then
        mj = nil
    else
        mj = self.compPlayerMgr:GetPlayer(lastPlayViewSeat):GetLastOutCard()
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

    if nbzz and tonumber(nbzz) ~= 0 and lastPlayViewSeat == operPlayViewSeat then
        table.insert(tbl._para.cardTriplet.useCards,tbl._para.cardTriplet.triplet)
        operType = MahjongOperAllEnum.NBZZ
    end

    local operData = operatordata:New(operType, tbl._para.cardTriplet.triplet, tbl._para.cardTriplet.useCards, 17, tbl._para.tripletWho)

    self:SetOutCardEfObj(nil, false)
    self.compPlayerMgr:GetPlayer(operPlayViewSeat):OperateCard(operData, mj)

    if not nbzz or nbzz == 0 or tonumber(nbzz) == 0 then
        ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjSoundPath("peng"))
    end   
    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_TRIPLET_CARD)
    if operPlayViewSeat ~= 1 then
        roomdata_center.AddMj(tbl._para.cardTriplet.triplet, 2)
    else
        self.compPlayerMgr:GetPlayer(operPlayViewSeat):HideTingInHand()
    end
end

function comp_show_base:ResetTingState(tbl)   
    local tingtype=tbl._para.tinType 
    self.compPlayerMgr.selfPlayer:SetDisableCardShow(self.cfg.showTingDisableCard) 
    if tingtype~=nil then
        for i=1,#tingtype do
            if tingtype[i]==1 then
                if i==1 then 
                    local handcard=self.compPlayerMgr.selfPlayer.handCardList
                    self.compPlayerMgr.selfPlayer:SetCanOut(false, handcard)         
                end
                mahjong_ui:SetYoustatus(i,20004)
            end
        end
    end
    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.GAME_TINGSTATE)
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
    
    -- 河北
    local cardSpecial = tbl._para.cardSpecial   --  区分特殊杠(1:风杠  2:(中中发白)乱杠  3:(中发发白)乱杠    4:(中发白白)乱杠)
    local specialcard = tbl._para.cardSpecial
    local nbzz = tbl._para.nbzz
    local mj  = nil
    
    local ganglock=tbl._para.bGangLock

    if ganglock ~=nil then
        if ganglock then
            mahjong_ui:ShowGangLock()
        end
    end
    if offset<1 then
        offset = offset +roomdata_center.MaxPlayer()
    end
    offset = player_seat_mgr.ViewSeatOffsetToIndexOffset(offset)

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
        -- self.compResMgr:HideOutCardEfObj()
    end

    if quadrupletType == 2 then
        self.compPlayerMgr.selfPlayer:SetCanOut(false)
        operType = MahjongOperAllEnum.AddBar
        operData = operatordata:New(operType,tbl._para.cardQuadruplet.useCards[1], nil, 20, quadrupletWho)
    end

    if quadrupletType == 3 then
        operType = MahjongOperAllEnum.DarkBar
        local gunCardValue = nil
        if cardSpecial and tonumber(cardSpecial) ~= 0 then
            if tonumber(cardSpecial) == 1 then --   风杠
                gunCardValue = table.remove(tbl._para.cardQuadruplet.useCards)
            elseif tonumber(cardSpecial) == 2 or tonumber(cardSpecial) == 3 or tonumber(cardSpecial) == 4 then  --  乱杠
                local secondRepeatCardIndex = -1
                for i=1, #tbl._para.cardQuadruplet.useCards do
                    if tbl._para.cardQuadruplet.useCards[i] == tbl._para.cardQuadruplet.useCards[1] and i ~= 1 then
                        secondRepeatCardIndex = i
                        break
                    end
                end
                gunCardValue = table.remove(tbl._para.cardQuadruplet.useCards,secondRepeatCardIndex)
            end
        else
            gunCardValue = table.remove(tbl._para.cardQuadruplet.useCards)
        end
        operData = operatordata:New(operType,gunCardValue, tbl._para.cardQuadruplet.useCards, 19, quadrupletWho)
        --table.remove(tbl._para.cardQuadruplet.useCards)
        --operData = operatordata:New(operType,tbl._para.cardQuadruplet.useCards[1], tbl._para.cardQuadruplet.useCards, 19, quadrupletWho)
    end

    if not nbzz or nbzz ~= 1 or tonumber(nbzz) ~= 1 then
        ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjSoundPath("gang"))
    end   
    self.compPlayerMgr:GetPlayer(operPlayViewSeat):OperateCard(operData, mj)                    

    if operPlayViewSeat ~= 1 then
        local card = tbl._para.cardQuadruplet.useCards[1]
        if quadrupletType == 1 then  --明杠加3张
            roomdata_center.AddMj(card, 3)
        elseif quadrupletType == 2 then -- 补杠加一张
            roomdata_center.AddMj(card, 1)
        end
    end
    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_QUADRUPLET_CARD)
end

--[[--
 * @Description: 吃  
 ]]
function comp_show_base:OnGameCollect(tbl)
    --Trace("comp_show_base:OnGameCollect() --- tbl = "..GetTblData(tbl))

    local operPlayViewSeat = self.gvblFun(tbl._src)
    local collectWho = tbl._para.collectWho
    local lastPlayViewSeat = operPlayViewSeat-1
    if lastPlayViewSeat<1 then
        lastPlayViewSeat = roomdata_center.MaxPlayer()
    end
    if collectWho then
        lastPlayViewSeat = self.gvblnFun(collectWho)
    end

    local mj = nil

    local nbzz = tbl._para.nbzz--获取BZZ信息
    --Trace("lastPlayViewSeat"..lastPlayViewSeat.."self.gvblFun(tbl._para.collectWho)"..self.gvblnFun(tbl._para.collectWho)) 

    if nbzz ~= nil then--使用if else后不会报Get  LastOutCardError 的错误。
        mj = nil
    else
        mj = self.compPlayerMgr:GetPlayer(lastPlayViewSeat):GetLastOutCard()
    end

    local operType = MahjongOperAllEnum.Collect
    
    if nbzz and tonumber(nbzz) ~= 0 then
        table.insert(tbl._para.cardCollect.useCards,tbl._para.cardCollect.collect)
        operType = MahjongOperAllEnum.NBZZ
    end

    local operData = operatordata:New(operType, tbl._para.cardCollect.collect, tbl._para.cardCollect.useCards, 16, tbl._para.collectWho)

    self:SetOutCardEfObj(nil, false)
    if mj ~= nil then
        mj:SetCollectHighLight(true)
    end
    self.compPlayerMgr:GetPlayer(operPlayViewSeat):OperateCard(operData, mj)

     if operPlayViewSeat ~= 1 then
        for i = 1, #tbl._para.cardCollect.useCards do
            roomdata_center.AddMj(tbl._para.cardCollect.useCards[i])
        end
    end
    if not nbzz or nbzz == 0 or tonumber(nbzz) == 0 then
        ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjSoundPath("chi"))
    end
    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_COLLECT_CARD)
end

--[[--
 * @Description: 亮喜儿
 ]]
function comp_show_base:OnGameLiangXiEr(tbl)
    --Trace("comp_show_base:OnGameCollect() --- tbl = "..GetTblData(tbl))
    local operPlayViewSeat = self.gvblnFun(tbl._para._chair)

    local operType = MahjongOperAllEnum.LiangXiEr
    
    local operData = operatordata:New(operType, nil, {35,36,37}, 9, tbl._para._chair)

    self.compPlayerMgr:GetPlayer(operPlayViewSeat):OperateCard(operData)

    if operPlayViewSeat ~= 1 then
        for i = 1,3 do
            roomdata_center.AddMj(34+i)
        end
    end

    if operPlayViewSeat == 1 then
        mahjong_ui:HideOperTips()
        roomdata_center.CheckTingWhenGiveCard(-1)
        mahjong_ui.cardShowView:ShowHuBtn(roomdata_center.isTing)
    end

    -- ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjSoundPath("liangxier"))
    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_LIANGXIER_CARD)
end

--[[--
 * @Description: 抢听
 ]]
function comp_show_base:OnGameQiangTing(tbl)
    --Trace("comp_show_base:OnGameCollect() --- tbl = "..GetTblData(tbl))
    local operPlayViewSeat = self.gvblnFun(tbl._para._chair)
    local qiangtingWho = tbl._para.qiangtingWho 
    local cardqiangting  = tbl._para.cardqiangting  
    
    local qiangtingWhoViewSeat = self.gvblFun(qiangtingWho)
    local operType = MahjongOperAllEnum.QiangTing
    
    local mj = self.compPlayerMgr:GetPlayer(qiangtingWhoViewSeat):GetLastOutCard()

    local operData = operatordata:New(operType, cardqiangting, nil, 0, qiangtingWho)
    self:SetOutCardEfObj(nil, false)
    self.compPlayerMgr:GetPlayer(operPlayViewSeat):OperateCard(operData,mj)

    if operPlayViewSeat == 1 then
        mahjong_ui:HideOperTips()
        roomdata_center.CheckTingWhenGiveCard(-1)
        mahjong_ui.cardShowView:ShowHuBtn(roomdata_center.isTing)
    end

    -- ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjSoundPath("qiangting"))
    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_QIANGTING)
end

--[[--
 * @Description: 补花  
 ]]
function comp_show_base:OnChangeFlower(tbl)
    local action = self.actionCtrl:GetAction("game_changeFlower")
    if action ~= nil then
        action:Execute(tbl)
    end
end

--[[--
 * @Description: 开金  
 ]]
function comp_show_base:OnGameOpenGlod(tbl)
    mahjong_ui:SetAllHuaPointVisible(self.cfg.isHasFlower and true)

    local action = self.actionCtrl:GetAction("game_openGlod")
    if action ~= nil then
        action:Execute(tbl)
    end
end

function comp_show_base:OnRobGold()
    mahjong_anim_state_control.ShowAnimState(MahjongGameAnimState.grabGold)
    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_ROB_GOLD)
end


--[[--
 * @Description: 胡牌提示
 ]]
 function comp_show_base:OnTing(tbl)
    roomdata_center.SetHintInfoMap(tbl)
    if not mahjong_ui:GetOperTipShowState() and roomdata_center.selfOutCard == 0 then
        self.compPlayerMgr.selfPlayer:ShowTingInHand()
    end
    if not mahjong_client_ting_mgr.supportClientTing then
        Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_HU_TIPS_CARD)
    end
end

function comp_show_base:OnTingInfo(tbl)
    roomdata_center.SetHintInfoMap(tbl)
    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_TINGINFO)
    --[[if not mahjong_client_ting_mgr.supportClientTing then
        Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_HU_TIPS_CARD)
    --end]]    --modify by cgg    
end

function comp_show_base:OnGuoClick()
    if roomdata_center.currentPlayViewSeat ~= 1 or roomdata_center.selfOutCard ~= 0 then
            return
    end
    self.compPlayerMgr.selfPlayer:ShowTingInHand()
end

function comp_show_base:OnChangeTable()
    self:InitForReady()
end

--[[--
 * @Description: 结算处理  
 ]]
function comp_show_base:OnGameRewards(tbl)
    self.compTable:StopTime()
    isInit = false
    self.compPlayerMgr.selfPlayer:SetCanOut(false)

    local rewards = tbl._para.rewards
    local who_win = tbl._para.who_win

    local hasShow = false
    for i = 1, roomdata_center.MaxPlayer() do
        if not IsTblIncludeValue(i, who_win) then
            local viewSeat = self.gvblnFun(i)
            if viewSeat ~= 1 then            
                self.compPlayerMgr:GetPlayer(viewSeat):ShownAnGangCards(rewards[i].combineTile)
            end
            self.compPlayerMgr:GetPlayer(viewSeat):ShowWinCards(rewards[i].cards, 
                function() 
                    if hasShow == false then
                        hasShow = true
                        mahjong_ui_sys.OnGameRewards(tbl) 
                    end
                end, 1)
        end
    end
 
	roomdata_center.isStart = false    --ui_sound_mgr.PlaySoundClip("woman/hu")
end




function comp_show_base:OnSyncTable(tbl)
    local gameState = self.config.game_state
    local ePara = tbl._para
    local game_state = ePara.game_state         -- 游戏阶段
    local dealer = ePara.dealer                 -- 庄家
    local dice = ePara.dice                     -- 骰子
    local laizi = ePara.laizi                   -- 癞子
    local ci = ePara.ci                         -- 次牌
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
    local nOpenGoldCard = ePara.nOpenGoldCard     -- 金牌
    local nGoldCardPos = ePara.nGoldCardPos       -- 金牌在剩余牌堆tileLeft的位置
    local GoldCard = ePara.GoldCard             -- 开出来的牌
    local bGoldIsBai = ePara.bGoldIsBai         -- --白板是否默认是金牌：false不默认，true默认
    local nLastGiveChair = ePara.nLastGiveChair  -- 最后出牌的人
    local xiapotable=ePara.xiapao
    local cardLastDraw=ePara.cardLastDraw
    if cardLastDraw~=nil then
        self.cardLastDraw=cardLastDraw
    end
    local state = self.config.mahjongSyncGameState[game_state]
    if state == nil then
        logError("找不到state", game_state);
        state = 0
    end 
    roomdata_center.OnSyncTable()
    
    mahjong_anim_state_control.Reset()

    if subRound ~= 0 then
        self:OnResetSubRound(subRound)
    end

    if state < 300 then
        mahjong_ui:HideSpecialCard()
    end
    if state >= 200 then   --准备
        self:InitForReady()
    end
    -- if state==300 then --下跑
    --     if xiapotable~=nil and #xiapotable>0 then 
    --       self:OnResetXiapao(xiapotable)
    --     end
    -- end
    if state >= 300 then        -- xiapao
        self.compTable:ReShowWall()
    end

    if state >= 400 then    -- 发牌
        self.curState = gameState.deal
        mahjong_anim_state_control.SetStateByName(MahjongGameAnimState.changeFlower)

        self:OnResetDealer(dealer)
        if tileLeft ~= 0 then
            self:OnResetLeftCard(tileLeft)
        end

        roomdata_center.dice = dice
        local dir = roomdata_center.GetBankerViewSeat() + dice[1] + dice[2] -1
        dir = dir % 4
        if dir == 0 then
            dir = 4
        end
        local action = self.actionCtrl:GetAction("game_setWind")
        if action ~= nil then
            action:Execute(dir)
        end
    end


    if state >= 500 then
        self:OnResetWall(dice)
        -- self:OnResetHandCard(tileCount, tileList)

        if state < 600 then
            --恢复玩家牌
            self:OnResetCard(discardTile, combineTile, tileCount, tileList)
        end

        if state >= 510 then --补花
            mahjong_anim_state_control.SetStateByName(MahjongGameAnimState.openGold)
        end

        if state >= 520 then  -- 开金
             --恢复花
            if flowerTile~=nil then
                self:OnResetFlowerCards( flowerTile ) 
            end
        end
    end

    if state >= 600 then  -- 打牌阶段
		mahjong_anim_state_control.SetStateByName(MahjongGameAnimState.grabGold)
         self.curState = gameState.round 
        --恢复癞子
        if laizi~=nil then
            self:OnResetLai(laizi)
		    if nOpenGoldCard and nOpenGoldCard ~= 0 then
                roomdata_center.SetSpecialCard(nOpenGoldCard)
            end          end

        --恢复次牌
        if ci and ci.cards~=0 then
            self:OnResetCi(ci)
        end

        if nOpenGoldCard and nOpenGoldCard ~= 0 then
            roomdata_center.SetSpecialCard(self.config.GetSpecialCardValue(nOpenGoldCard))
        end

        --恢复玩家牌
        self:OnResetCard( discardTile ,combineTile,tileCount,tileList)
        
        --恢复金
        if nOpenGoldCard and nOpenGoldCard ~= 0 then
            self:OnResetGoldCard(nOpenGoldCard ,nGoldCardPos,bGoldIsBai,GoldCard)
        end

        --  重连的时候是否轮到自己出牌
        local viewSeat = self.gvblnFun(whoisOnTurn)
        roomdata_center.currentPlayViewSeat = viewSeat

        self.compTable:SetCurLightDir(self.gvblnFun(whoisOnTurn))

        if nLastGiveChair~=nil and nLastGiveChair~=0 then
            local viewSeat = self.gvblnFun(nLastGiveChair)
            local mj = self.compPlayerMgr:GetPlayer(viewSeat):GetLastOutCard(true)
            if mj ~=nil then
                self.compResMgr:SetOutCardEfObj(mj.transform.position + Vector3.New(0, 0.102, 0))
            end
        end
    end

end


function comp_show_base:OnResetFlowerCards(flowerCardsList)
    local action = self.actionCtrl:GetAction("game_changeFlower")
    if action ~= nil then   
        action:OnSync(flowerCardsList)
    end
end

function comp_show_base:OnResetDealer(dealer)
    local banker_viewSeat = self.gvblFun(dealer)
    roomdata_center.zhuang_viewSeat = banker_viewSeat
end

function comp_show_base:OnResetXiapao(xiapotable) 
   mahjong_ui.isRetGame=true
   for i=1,#xiapotable do 
       local viewS=  self.gvblnFun(i)
       if xiapotable[i]>=0 then 
           mahjong_ui.playerList[viewS].SetXiaPaoStatus(true)
       else
          if viewS~=1 then
               mahjong_ui.playerList[viewS].ShowXiaoPaoing()
          end
       end
   end
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
    
    local wallCounts = mode_manager.GetCurrentMode().config.wallDunCountMap

    self.compTable:ResetWall(wallCounts[viewSeat]-dice_small - dice_big, viewSeat)
end

function comp_show_base:OnResetLai(laizi)
    if laizi.sit[1]~=nil and laizi.card[1]~=nil then
        roomdata_center.SetSpecialCard(laizi.laizi[1])
        local dun = math.ceil(laizi.sit[1]/2)
        self.compTable:ShowLai(dun, laizi.card[1])
    end
end

function comp_show_base:OnResetCi(ci)
    if ci.sits[1]~=nil and ci.cards ~=nil then
        roomdata_center.SetSpecialCard(ci.cards)
        self.compTable:ShowCi(math.ceil(ci.sits[1]/2), ci.cards)
    end
end


--[[function comp_show_base:OnResetHandCard(tileCount, tileList)
     --手牌
    for i=1,roomdata_center.MaxPlayer() do
        local count = tileCount[i]
        local viewSeat = self.gvblnFun(i)
        local cardItems =self.compTable:GetResetCards(count)
        if viewSeat == 1 then
           self.compPlayerMgr:GetPlayer(viewSeat):ResetHandCard(cardItems, tileList,self.cardLastDraw) 
        else
           self.compPlayerMgr:GetPlayer(viewSeat):ResetHandCard(cardItems) 
        end
    end
    self.compPlayerMgr.selfPlayer:ShowSpecialInHand()
end]]

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
            function(count,lastCount)
                if self.cfg.quadrupletSendLast then
                    return self.compTable:GetResetCards(count,lastCount)
                else
                    local lastCount = lastCount or 0
                    return self.compTable:GetResetCards(count+lastCount)
                end
            end,
        operData)        
    end

    --手牌
    for i=1,roomdata_center.MaxPlayer() do
        local count = tileCount[i]
        local viewSeat = self.gvblnFun(i)
        local cardItems =self.compTable:GetResetCards(count)
        if viewSeat == 1 then
           self.compPlayerMgr:GetPlayer(viewSeat):ResetHandCard(cardItems, tileList,self.cardLastDraw) 
        else
           self.compPlayerMgr:GetPlayer(viewSeat):ResetHandCard(cardItems) 
        end
    end
    self.compPlayerMgr.selfPlayer:ShowSpecialInHand()

end

function comp_show_base:OnResetSubRound(subRound)
    mahjong_ui:SetGameInfoVisible(false)
    roomdata_center.nCurrJu = subRound
    mahjong_ui:SetRoundInfo(subRound, roomdata_center.nJuNum)
end

function comp_show_base:OnResetLeftCard(leftCard)
    mahjong_ui:SetGameInfoVisible(true)
    roomdata_center.SetRoomLeftCard(leftCard)
end

function comp_show_base:OnResetGoldCard( jin,pos,isDontShowOnDesk,GoldCard )
    local action = self.actionCtrl:GetAction("game_openGlod")
    if action ~= nil then
        action:OnSync(jin,pos,isDontShowOnDesk,GoldCard)
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


--[[--
 * @Description: 福州麻将组件表现
 * @Author:      shine
 * @FileName:    fuzhou_comp_show.lua
 * @DateTime:    2017-07-08 14:41:48
 ]]
require "logic/mahjong_sys/comp_show/comp_show_base"

local player_seat_mgr = player_seat_mgr

local libFanClass = require ("logic.fanlib.lib_fan_counter")
fuzhou_comp_show = comp_show_base.New()
local this = fuzhou_comp_show
this.super = comp_show_base
this.libFan = nil

--/////////////////////////需要重写的表现在此下面重写即可start/////////////////////////////////////

--[[--
 * @Description: 游戏阶段  
 ]]
this.game_state = {
    none         = "none",
    prepare      = "prepare",        --开始
    banker       = "banker",          --定庄
    deal         = "deal",               --抓牌
    changeflower = "changeflower",      --补花
    opengold     = "opengold",         --开金
    round        = "round",        --游戏阶段
    reward       = "reward",       --结算
    gameend      = "gameend",       --结束
}

--[[--
 * @Description: 事件注册  
 ]]
function this:RegisterEvents()
    this.super.RegisterEvents(self)
    this.canCheckTing = false
    Notifier.regist(cmdName.F3_CHANGE_FLOWER, slot(self.OnChangeFlower, self)) -- 补花
    Notifier.regist(cmdName.F3_OPEN_GOLD, slot(self.OnGameOpenGlod, self))  -- 开金
    Notifier.regist(cmdName.F3_ROB_GOLD, slot(self.OnRobGold, self)) -- 抢金
	Notifier.regist(cmdName.MAHJONG_COLLECT_CARD, slot(self.OnGameCollect, self)) -- 吃
	Notifier.regist(cmdName.MAHJONG_TING_CARD, slot(self.OnTing, self))       --听牌
    Notifier.regist(cmdName.MSG_CLIENT_CHECKT_TING, slot(self.ClientCheckTing, self))
    Notifier.regist(cmdName.MSG_ON_GUO_CLICK, slot(self.OnGuoClick, self))
    UpdateBeat:Add(this.UpdateTing)
end

--[[--
 * @Description: 事件注销  
 ]]
function this:UnRegisterEvents()
    this.super.UnRegisterEvents(self)
	Notifier.remove(cmdName.F3_CHANGE_FLOWER, slot(self.OnChangeFlower, self)) -- 补花
    Notifier.remove(cmdName.F3_OPEN_GOLD, slot(self.OnGameOpenGlod, self))  -- 开金
    Notifier.remove(cmdName.F3_ROB_GOLD, slot(self.OnRobGold, self)) -- 抢金
	Notifier.remove(cmdName.MAHJONG_COLLECT_CARD, slot(self.OnGameCollect, self)) -- 吃
	Notifier.remove(cmdName.MAHJONG_TING_CARD, slot(self.OnTing, self))--听牌
    Notifier.remove(cmdName.MSG_CLIENT_CHECKT_TING, slot(self.ClientCheckTing, self))
    Notifier.remove(cmdName.MSG_ON_GUO_CLICK, slot(self.OnGuoClick, self))
    UpdateBeat:Remove(this.UpdateTing)
end

function this:OnGuoClick()
    if roomdata_center.currentPlayViewSeat ~= 1 or roomdata_center.selfOutCard ~= 0 then
            return
    end
    self.compPlayerMgr:GetPlayer(1):ShowTingInHand()
end

--[[--
 * @Description: 补花  
 ]]
function this:OnChangeFlower(tbl)
    local paramTbl = tbl._para
    local playerIndex = paramTbl["nFlowerWho"]      --谁补花
    local flowerCards = paramTbl["stFlowerCards"]       --花牌
    local newCards = paramTbl["stNewCards"]     --替换的花牌
    local totalCards = paramTbl["nTotalFlowerCard"]     --花牌总数量
    local leftCardNum = paramTbl["nCardLeft"]   --剩余牌数

    local viewSeat = self.gvblnFun(playerIndex)

    local isDeal = false
    if self.curState == self.game_state.deal then
        isDeal = true
    end

    if not isDeal then
        ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjSoundPath("buhua"))
    end

    mahjong_anim_state_control.ShowAnimState(MahjongGameAnimState.changeFlower, 
        function()
            roomdata_center.SetPlayerFlowersCards(viewSeat, flowerCards)
            if self.compTable ~= nil then
                self.compTable:ShowChangeFlowers(viewSeat, flowerCards, totalCards, newCards, function() 
                    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F3_CHANGE_FLOWER)
                end,isDeal)
            else
                Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F3_CHANGE_FLOWER)
            end
    end, true,true)

    if viewSeat ~= 1 then
        for i = 1, #flowerCards do
            roomdata_center.AddMj(flowerCards[i])
        end
    end
end

--[[--
 * @Description: 开金  
 ]]
function this:OnGameOpenGlod(tbl)
    Trace(GetTblData(tbl))
    local cardValue = tbl._para.nCard
    local isGold = tbl._para.bGold
    roomdata_center.AddMj(cardValue)
    self.curState = self.game_state.opengold
    roomdata_center.AddMj(cardValue)

    self.compTable:HideAllFlowerInTable(function ()
    if mahjong_anim_state_control.GetCurrentIndex() == 2 then
        mahjong_anim_state_control.SetState(3)
    end 
    mahjong_anim_state_control.ShowAnimState(MahjongGameAnimState.openGold, 
        function()
            if isGold then
                roomdata_center.SetSpecialCard(cardValue)
                mahjong_ui.SetAllScoreVisible(true)
            else
                roomdata_center.AddFlowerCardToZhuang(cardValue)
            end

            self.compTable:ShowJin(cardValue, isGold, true, function()
                self.compPlayerMgr:GetPlayer(1):ShowSpecialInHand()
                Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F3_OPEN_GOLD)
            end)
        
        end, true)
     
    end)
    ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjCommonSoundPath("kaijin", true))
end

--[[--
 * @Description: 抢金  
 ]]
function this:OnRobGold()
    mahjong_anim_state_control.ShowAnimState(MahjongGameAnimState.grabGold)
    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.F3_ROB_GOLD)
end

--[[--
 * @Description: 吃  
 ]]
function this:OnGameCollect(tbl)
    Trace(GetTblData(tbl))

    local operPlayViewSeat = self.gvblFun(tbl._src)
    local lastPlayViewSeat = operPlayViewSeat-1
    if lastPlayViewSeat<1 then
        lastPlayViewSeat = roomdata_center.MaxPlayer()
    end
    --Trace("lastPlayViewSeat"..lastPlayViewSeat.."self.gvblFun(tbl._para.collectWho)"..self.gvblnFun(tbl._para.collectWho)) 
    local mj = self.compPlayerMgr:GetPlayer(lastPlayViewSeat):GetLastOutCard()

    local operType = MahjongOperAllEnum.Collect
    
    local operData = operatordata:New(operType, tbl._para.cardCollect.collect, tbl._para.cardCollect.useCards, 16, tbl._para.collectWho)

    self:SetOutCardEfObj(nil, true)
    self.compPlayerMgr:GetPlayer(operPlayViewSeat):OperateCard(operData, mj)

     if operPlayViewSeat ~= 1 then
        for i = 1, #tbl._para.cardCollect.useCards do
            roomdata_center.AddMj(tbl._para.cardCollect.useCards[i])
        end
    end

    ui_sound_mgr.PlaySoundClip(mahjong_path_mgr.GetMjSoundPath("chi"))
    Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_COLLECT_CARD)
end

--[[--
 * @Description: 听  
 ]]
 function this:OnTing(tbl)
    roomdata_center.SetHintInfoMap(tbl)
    if not mahjong_ui.GetOperTipShowState() and roomdata_center.selfOutCard == 0 then
        self.compPlayerMgr:GetPlayer(1):ShowTingInHand()
    end
    if not roomdata_center.supportClientTing then
        Notifier.dispatchCmd(cmdName.MSG_HANDLE_DONE, cmdName.MAHJONG_TING_CARD)
    end
end

function this:OnPlayerEnter(tbl)
    this.super.OnPlayerEnter(this, tbl)
    local logicSeat = tbl["_src"]
    local viewSeat = self.gvblFun(logicSeat)
    if viewSeat == 1 and this.libFan == nil then
        local cfg = this:GetGameCfg()
        this.libFan = libFanClass:create(cfg)
    end
end

function this:OnPlayCard(tbl)
    this.super.OnPlayCard(this, tbl)
    local src = tbl["_src"]
    local viewSeat = self.gvblFun(src)
    if viewSeat ~= 1 then
        return
    end
    roomdata_center.tingVersion = roomdata_center.tingVersion + 1
end

function this:OnAskPlay(tbl)
    this.super.OnAskPlay(this, tbl)
    local viewSeat = self.gvblFun(tbl._src)
    if viewSeat ~= 1 then
        self.compPlayerMgr:GetPlayer(1):HideTingInHand()
    end
    if viewSeat ~= 1 or not roomdata_center.supportClientTing then
        return
    end
    this:ClientCheckTing()
end

function this:ClientCheckTing()
    if this.libFan == nil then
        local cfg = this:GetGameCfg()
        this.libFan = libFanClass:create(cfg)
    end

    this.check = false;
    -- if this.canCheckTing == false then
    local info = this:GetGameInfo()
    this.libFan:checkTing( info ,this.OnCheckTing, roomdata_center.tingVersion)
        -- this.canCheckTing = true
    -- end
end


function this.OnCheckTing(res, version)
    -- this.canCheckTing = false
    if res == 1 and version == roomdata_center.tingVersion then
        this.check = true
    else
        this.check = false
    end
end

function this.UpdateTing()
    if this.check then
        this.check = false;
        local tingInfo = this.libFan:getTingInfo()
        local tingTab = ParseJsonStr(tingInfo)
        --logError(GetTblData(tingTab))
        local tab = {}
        tab._para = {}
        tab._para.stTingCards = tingTab
        this:OnTing(tab)
    end
end

function this:GetGameCfg()
    local cfg = {}
    cfg.halfQYS = roomdata_center.gamesetting.bSupportHalfColor and 1 or 0
    cfg.allQYS = roomdata_center.gamesetting.bSupportOneColor and 1 or 0
    cfg.goldDragon = roomdata_center.gamesetting.bSupportGoldDragon and 1 or 0
    return cfg
end

function this:GetGameInfo()
    local tableInfo = {}
    tableInfo.chair = roomdata_center.chairid
    tableInfo.turn = roomdata_center.chairid
    -- 自己手牌
    tableInfo.tHand = this:GetSelfHandCards()
    -- 自己手牌数量
    tableInfo.byHandCount = 17

    tableInfo.laiziCard = roomdata_center.specialCard

    tableInfo.tSet = this.compPlayerMgr:GetPlayer(1):GetOperDatas()
    tableInfo.bySetCount = tableInfo.tSet and #tableInfo.tSet or 0
    local giveTab, countTab = this:GetAllGiveCards()
    tableInfo.tGive = giveTab
    tableInfo.byGiveCount = countTab
    tableInfo.byFlowerCount = roomdata_center.GetAllFlowerCardsCount()
    tableInfo.byTilesLeft = roomdata_center.leftCard
    tableInfo.byDoFirstGive = countTab
    tableInfo.laizi = this:GetJinCount(tableInfo.tHand)
    tableInfo.flower = #roomdata_center.GetFlowerCards(1)
    tableInfo.dealer = player_seat_mgr.GetLogicSeatNumByViewSeat(roomdata_center.zhuang_viewSeat)
    tableInfo.nNSNum = this:GetLeftCards(tableInfo.tGive)
    tableInfo.tLast = this.compPlayerMgr:GetPlayer(1):GetLastCard()
    return tableInfo
end

function this:GetJinCount(list)
    local count = 0
    for i = 1, #list do
        if list[i] == roomdata_center.specialCard then
            count = count + 1
        end
    end
    return count
end

function this:GetLeftCards(tGive    )
    local cardMap = {}
    for i = 1, 37 do
        cardMap[i] = 4
    end
    this:UpdateCardMap(cardMap, tGive)
    for i = 1, roomdata_center.MaxPlayer() do
        local set = this.compPlayerMgr:GetPlayer(i):GetOperDatas()
        this:UpdateCardMapBySet(cardMap, set)
    end
    return cardMap
end

function this:UpdateCardMapBySet(map, set)
    if set == nil then
        return
    end
    for i = 1, #set do
        local tab = set[i]
        if tab[1] == 16 then
            this:UpdateCardMapNum(map, tab[2], 1)
            this:UpdateCardMapNum(map, tab[2] + 1, 1)
            this:UpdateCardMapNum(map, tab[2] + 2, 1)
        elseif tab[1] == 17 then
            this:UpdateCardMapNum(map, tab[2], 3)
        elseif tab[1] == 18 or tab == 20 then
            this:UpdateCardMapNum(map, tab[2], 4)
        elseif tab[1] == 19 then
            this:UpdateCardMapNum(map, tab[2], 4)
        end
    end
end

function this:UpdateCardMapNum(map, value, count)
    if map[value] == nil or value == 0 then
        return
    end
    count = count or 1
    map[value] = map[value] - count
    if map[value] < 0 then
        logError("card < 0", value)
        map[value] = 0
    end
end

function this:UpdateCardMap(map, twoDTable)
    if twoDTable == nil then
        return
    end
    for i = 1, #twoDTable do
        if twoDTable[i] ~= nil then
            for j = 1, #twoDTable[i] do
                this:UpdateCardMapNum(map, twoDTable[i][j])
                -- logError(twoDTable[i][j], map[twoDTable[i][j]])
                -- map[twoDTable[i][j]] = map[twoDTable[i][j]] - 1
                -- if map[twoDTable[i][j]] < 0 then
                --     logError("card < 0", twoDTable[i][j])
                --     map[twoDTable[i][j]] = 0
                -- end
            end
        end
    end 
end

function this:GetSelfHandCards()
    local player = self.compPlayerMgr:GetPlayer(1)
    local cards = {}
    for i = 1, #player.handCardList do
        table.insert(cards, player.handCardList[i].paiValue)
    end
    return cards
end

function this:GetAllGiveCards()
    local giveCards = {}
    local giveCount = {}
    for i = 1,  roomdata_center.MaxPlayer() do
        local logicSeat = player_seat_mgr.GetLogicSeatNumByViewSeat(i)
        local outcards = self.compPlayerMgr:GetPlayer(i):GetOutCardNums()
        giveCards[logicSeat] = outcards
        giveCount[logicSeat] = #outcards
    end
    for i = roomdata_center.MaxPlayer() + 1, 4 do
        giveCards[i] = nil
        giveCount[i] = 0
    end
    return giveCards, giveCount
end

--/////////////////////////需要重写的表现在此下面重写即可end///////////////////////////////////////

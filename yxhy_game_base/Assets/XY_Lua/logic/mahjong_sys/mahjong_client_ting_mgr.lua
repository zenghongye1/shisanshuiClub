local mahjong_client_ting_mgr = class("mahjong_client_ting_mgr")
local libFanClass = require ("logic.fanlib.lib_fan_counter")

function mahjong_client_ting_mgr:ctor()
	self.libFan = nil
	self.compPlayerMgr = nil
	self.supportClientTing = false
	UpdateBeat:Add(slot(self.UpdateHuTips, self))
end

function mahjong_client_ting_mgr:GetPlayerMgr()
	if self.comp_playerMgr == nil then
		self.compPlayerMgr = mode_manager.GetCurrentMode():GetComponent("comp_playerMgr")
	end
	return self.compPlayerMgr
end

--[[--
 * @Description: 设置客户端胡牌提示检测开启标志
 * @param: (value)bool类型，检测开启标志
 ]]
function mahjong_client_ting_mgr:SetClientTing(value)
    LogW("mahjong_client_ting_mgr:SetClientTing() value = ", value)
    self.supportClientTing = value
    if self.libFan ~= nil then
        self.libFan = nil
    end

    if self.supportClientTing then
        self.libFan = libFanClass:create(self:GetGameCfg())
    end
end

function mahjong_client_ting_mgr:Dispose()
	UpdateBeat:Remove(slot(self.UpdateHuTips, self))
	self.libFan = nil
end

--[[--
 * @Description: 触发一次客户端胡牌提示检测
 ]]
function mahjong_client_ting_mgr:ClientCheckHuTips()
	if not self.supportClientTing  then
		return
	end
    self.check = false;
    local info = self:GetGameInfo()
    self.libFan:checkHuTips( info ,slot(self.OnCheckHuTips, self), roomdata_center.tingVersion)
end

--[[--
 * @Description: 每次客户端胡牌提示检测结束后的回调函数
 * @param:       res (胡牌提示检测结果, 1:代表有胡牌提示, 其他值代表没有胡牌提示)
 * @param:       version (客户端当前胡牌提示库的版本号)
 ]]
function mahjong_client_ting_mgr:OnCheckHuTips(res, version)
    LogW("OnCheckHuTips() res = " .. res .. ", version = "..version..", roomdata_center.tingVersion = "..roomdata_center.tingVersion);
    if res == 1 and version == roomdata_center.tingVersion then
        self.check = true
    else
        self.check = false
    end
end

--[[--
 * @Description:  刷新客户端胡牌提示信息
 ]]
function mahjong_client_ting_mgr:UpdateHuTips()
    if self.check then
        self.check = false;
        local tingInfo = self.libFan:getHuTipsInfo()
        local tingTab = ParseJsonStr(tingInfo)
        --logError(GetTblData(tingTab))
        local tab = {}
        tab._para = {}
        tab._para.stTingCards = tingTab
        Notifier.dispatchCmd(cmdName.MAHJONG_HU_TIPS_CARD, tab)
    end
end

--[[--
 * @Description:  获取游戏房间设置数据
 * @return:       房间设置数据
 ]]
function mahjong_client_ting_mgr:GetGameCfg()
    local cfg = {}
    cfg.halfQYS = roomdata_center.gamesetting.bSupportHalfColor and 1 or 0
    cfg.allQYS = roomdata_center.gamesetting.bSupportOneColor and 1 or 0
    cfg.goldDragon = roomdata_center.gamesetting.bSupportGoldDragon and 1 or 0
    return cfg
end

--[[--
 * @Description:  获取胡牌提示需要的当前牌局信息
 * @return:       牌局信息
 ]]
function mahjong_client_ting_mgr:GetGameInfo()
    local tableInfo = {}
    --检查谁的
    tableInfo.chair = roomdata_center.chairid
    tableInfo.turn = roomdata_center.chairid

    -- 自己手牌
    tableInfo.tHand = self:GetSelfHandCards()
    -- 自己手牌数量
    tableInfo.byHandCount = #tableInfo.tHand

    -- 癞子牌数组，暂定最大是4个,如果有多张相同的癞子牌要做去重操作
    local byLaiziCards = {}
    local specialCard={}
    for key,val in pairs(roomdata_center.specialCard) do
        specialCard[val]=true
    end
    for key,val in pairs(specialCard) do
        table.insert(byLaiziCards,key)
    end
    tableInfo.byLaiziCards = byLaiziCards

    --4手牌，flag、tile、chair
    tableInfo.tSet = self:GetPlayerMgr():GetPlayer(1):GetOperDatas()
    tableInfo.bySetCount = tableInfo.tSet and #tableInfo.tSet or 0

    --各家出过牌信息
    local giveTab, countTab = self:GetAllGiveCards()
    tableInfo.tGive = giveTab
    tableInfo.byGiveCount = countTab
    tableInfo.byDoFirstGive = countTab

    --还剩多少张牌
    tableInfo.byTilesLeft = roomdata_center.leftCard

    --赖子或者金的数量
    tableInfo.laizi = self:GetJinCount(tableInfo.tHand)

    tableInfo.byFlowerCount = roomdata_center.GetAllFlowerCardsCount()
    tableInfo.flower = #roomdata_center.GetFlowerCards(1)

    tableInfo.dealer = player_seat_mgr.GetLogicSeatNumByViewSeat(roomdata_center.zhuang_viewSeat)

    --获取剩余各个牌的数目
    tableInfo.nNSNum = self:GetLeftCards(tableInfo.tGive)

    tableInfo.tLast = self:GetPlayerMgr():GetPlayer(1):GetLastCard()
    tableInfo.byMaxHandCardLength = mode_manager.GetCurrentMode().cfg.MahjongHandCount

    --游戏类型
    tableInfo.gamestyle = player_data.GetGameId()

    --泉州和福鼎麻将里只有"春夏秋冬梅兰竹菊"这几张牌是花
    if tableInfo.gamestyle == ENUM_GAME_TYPE.TYPE_QUANZHOU_MJ or tableInfo.gamestyle == ENUM_GAME_TYPE.TYPE_FUDING_MJ then
        local flowerCount = 0;
        local flowerCards = roomdata_center.GetFlowerCards(1)
        for i=1, #flowerCards do
            if flowerCards[i] >= 41 and flowerCards[i] <=48 then
                flowerCount = flowerCount + 1
            end
        end
        tableInfo.flower = flowerCount
    end

    return tableInfo
end

--[[--
 * @Description:  获取手牌里赖子或者金的数量
 * @param:        手牌信息
 * @return:       赖子或者金的数量
 ]]
function mahjong_client_ting_mgr:GetJinCount(list)
    local count = 0
    for i = 1, #list do
        if list[i] == roomdata_center.specialCard[1] then
            count = count + 1
        end
    end
    return count
end

--[[--
 * @Description:  获取剩余各个牌的数目
 * @param:        (tGive)各家出过的牌
 * @return:       剩余各个牌的数目
 ]]
function mahjong_client_ting_mgr:GetLeftCards(tGive)
    local cardMap = {}
    for i = 1, 37 do
        cardMap[i] = 4
    end
    self:UpdateCardMap(cardMap, tGive)
    for i = 1, roomdata_center.MaxPlayer() do
        local set = self:GetPlayerMgr():GetPlayer(i):GetOperDatas()
        self:UpdateCardMapBySet(cardMap, set)
    end
    return cardMap
end

function mahjong_client_ting_mgr:UpdateCardMapBySet(map, set)
    if set == nil then
        return
    end
    for i = 1, #set do
        local tab = set[i]
        if tab[1] == 16 then
            self:UpdateCardMapNum(map, tab[2], 1)
            self:UpdateCardMapNum(map, tab[2] + 1, 1)
            self:UpdateCardMapNum(map, tab[2] + 2, 1)
        elseif tab[1] == 17 then
            self:UpdateCardMapNum(map, tab[2], 3)
        elseif tab[1] == 18 or tab == 20 then
            self:UpdateCardMapNum(map, tab[2], 4)
        elseif tab[1] == 19 then
            self:UpdateCardMapNum(map, tab[2], 4)
        end
    end
end

function mahjong_client_ting_mgr:UpdateCardMapNum(map, value, count)
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

function mahjong_client_ting_mgr:UpdateCardMap(map, twoDTable)
    if twoDTable == nil then
        return
    end
    for i = 1, #twoDTable do
        if twoDTable[i] ~= nil then
            for j = 1, #twoDTable[i] do
                self:UpdateCardMapNum(map, twoDTable[i][j])
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

--[[--
 * @Description:  获取自己当前的手牌
 * @return:       自己当前的手牌
 ]]
function mahjong_client_ting_mgr:GetSelfHandCards()
    local player = self:GetPlayerMgr():GetPlayer(1)
    local cards = {}
    for i = 1, #player.handCardList do
        table.insert(cards, player.handCardList[i].paiValue)
    end
    return cards
end

--[[--
 * @Description:  获取各家出过的牌
 * @return:       (giveCards)每家出过的每张牌
 * @return:       (giveCount)每家出过的每张牌的数量
 ]]
function mahjong_client_ting_mgr:GetAllGiveCards()
    local giveCards = {}
    local giveCount = {}
    for i = 1,  roomdata_center.MaxPlayer() do
        local logicSeat = player_seat_mgr.GetLogicSeatNumByViewSeat(i)
        local outcards = self:GetPlayerMgr():GetPlayer(i):GetOutCardNums()
        giveCards[logicSeat] = outcards
        giveCount[logicSeat] = #outcards
    end
    for i = roomdata_center.MaxPlayer() + 1, 4 do
        giveCards[i] = nil
        giveCount[i] = 0
    end
    return giveCards, giveCount
end

return mahjong_client_ting_mgr
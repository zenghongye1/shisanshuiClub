local stGameState = nil
local stRoundInfo = nil
local CURRENT_MODULE_NAME = ...

local env = require("logic.fanlib.environment")
local LibFanCounter = class("LibFanCounter")

function LibFanCounter:ctor( cfg )
    local byStyle = 0  --0: --普通模式, 1: --血战模式
    local bZiMoJiaDi = 0 --自摸加底标志, 0：否，1:是
    local bJiaJiaYou = 0 --家家有标志, 0:否， 1:是
    YX_APIManage.Instance:initHuTips(byStyle, bZiMoJiaDi, bJiaJiaYou)
    LogW("LibFanCounter:ctor() called!!!!")
    self.m_tableConf = cfg or {}
end

--[[--
 * @Description: 搜集胡牌提示相关牌局环境信息
 * @param:       tableInfo (当前牌局相关的配置信息)
 * @return:      当前牌局环境信息
 ]]
function LibFanCounter:CollectTingEnv(tableInfo )
    local env = clone(env) --import(".environment", CURRENT_MODULE_NAME)

    local nChair = tableInfo.chair or 1
    local nTurn = tableInfo.turn or 1
    local tHand = tableInfo.tHand
    local byHandCount = tableInfo.byHandCount
    local tSet = tableInfo.tSet
    local bySetCount = tableInfo.bySetCount

    local tGive = tableInfo.tGive
    local byGiveCount = tableInfo.byGiveCount
    local tLast = tableInfo.tLast or 0
    local byFlag = tableInfo.byFlag or env.byFlag

    local byRoundWind = tableInfo.byRoundWind or env.byRoundWind
    local byPlayerWind = tableInfo.byPlayerWind or env.byPlayerWind
    local byTilesLeft = tableInfo.byTilesLeft or env.byTilesLeft
    local byFlowerCount = tableInfo.byFlowerCount or env.byFlowerCount
    local byTing = tableInfo.byTing or env.byTing

    local byDoFirstGive = tableInfo.byDoFirstGive or env.byDoFirstGive
    local byRecv = tableInfo.byRecv or env.byRecv
    local byLaiziCards = tableInfo.byLaiziCards or env.byLaiziCards
    local nNSNum = tableInfo.nNSNum or env.nNSNum
    local byMaxHandCardLength = mode_manager.GetCurrentMode().cfg.MahjongHandCount + 1

    local byDoCheck = tableInfo.byDoCheck or env.byDoCheck
    local byEnvFan = tableInfo.byEnvFan or env.byEnvFan

    local checkWinParam = self:GetCheckWinParam(env.checkWinParam)
    checkWinParam.nNSNum = nNSNum  --checkWinParam.nNSNum暂时取environment.nNSNum里的值

    local byQYSNoWord = tableInfo.byQYSNoWord or env.byQYSNoWord
    local nMissHu = tableInfo.nMissHu or env.nMissHu
    local nMissWind = tableInfo.nMissWind or env.nMissWind
    local dealer = tableInfo.dealer or env.byDealer
    local gamestyle = tableInfo.gamestyle or env.gamestyle

    local laizi = tableInfo.laizi or env.laizi
    local flower = tableInfo.flower or env.flower
    local byGangTimes = tableInfo.byGangTimes or env.byGangTimes
    local byHaiDi = tableInfo.byHaiDi or env.byHaiDi

    local byGodTingFlag = tableInfo.byGodTingFlag or env.byGodTingFlag
    local byGroundTingFlag = tableInfo.byGroundTingFlag or env.byGroundTingFlag
    local byXiaoSaTingFlag = tableInfo.byXiaoSaTingFlag or env.byXiaoSaTingFlag
    --local bDanDiaoHu = tableInfo.bDanDiaoHu or env.bDanDiaoHu
    local byHunYouFlag = tableInfo.byHunYouFlag or env.byHunYouFlag

    local KeLimit = tableInfo.KeLimit or env.KeLimit
    local byHaveWinds = tableInfo.KeLimit or env.byHaveWinds
    --local bkaAdd = tableInfo.bkaAdd or env.bkaAdd
    --local n258Jiang = tableInfo.n258Jiang or env.n258Jiang

    env.byChair = nChair
    env.byTurn = nTurn
    if tHand then
        --table.sort( tHand )
        for i = 1,17 do
            if tHand[i] then
                env.tHand[nChair][i] = tHand[i]
            else
                env.tHand[nChair][i] = 0
            end

        end
        byHandCount = #tHand
    end

    env.byHandCount[nChair] = byHandCount--byHandCount or env.byHandCount[nChair]
    if tSet then
        for j = 1,4 do
            for k = 1,3 do
                if tSet[j] then
                    if tSet[j][k] then
                        env.tSet[nChair][j][k] = tSet[j][k]
                    else
                        env.tSet[nChair][j][k] = 0
                    end
                else
                    env.tSet[nChair][j][k] = 0
                end
            end
        end
    end

    env.bySetCount[nChair] = bySetCount or env.bySetCount[nChair]
    if tGive then
        for i = 1,4 do
            for k = 1,40 do
                if tGive[i] then
                    if  tGive[i][k] then
                        env.tGive[i][k] = tGive[i][k]
                    else
                        env.tGive[i][k] = 0
                    end
                else
                    env.tGive[i][k] = 0
                end
            end
        end
    end

    env.byGiveCount = byGiveCount
    env.tLast = tLast
    env.byFlag = byFlag
    env.byRoundWind = byRoundWind
    env.byPlayerWind = byPlayerWind
    env.byTilesLeft = byTilesLeft

    env.byFlowerCount = byFlowerCount
    env.byTing = byTing
    env.byDoFirstGive = byDoFirstGive
    env.byRecv = byRecv

    env.byLaiziCards = byLaiziCards
    env.nNSNum = nNSNum
    env.byMaxHandCardLength = byMaxHandCardLength

    env.byDoCheck = byDoCheck
    env.byEnvFan = byEnvFan
    env.checkWinParam = checkWinParam

    env.byQYSNoWord = byQYSNoWord
    env.nMissHu = nMissHu
    env.nMissWind = nMissWind
    env.byDealer = dealer
    env.gamestyle = gamestyle

    env.laizi = laizi
    env.flower = flower
    env.byGangTimes = byGangTimes
    env.byHaiDi = byHaiDi

    env.byGodTingFlag = byGodTingFlag
    env.byGroundTingFlag = byGroundTingFlag
    env.byXiaoSaTingFlag = byXiaoSaTingFlag
    --env.bDanDiaoHu = bDanDiaoHu
    env.byHunYouFlag = byHunYouFlag

    env.KeLimit = KeLimit
    env.byHaveWinds = byHaveWinds
    --env.bkaAdd = bkaAdd
    --env.n258Jiang = n258Jiang

    return env
end

--checkWin 一些附带参数
function LibFanCounter:GetCheckWinParam(winParam)
    winParam = winParam or {}
    local serverParam = roomdata_center.checkWinParam or {}

    --检查7小对：0不检查 1癞子做普通牌 2癞子可替任何牌
    local byCheck7pairs = serverParam.byCheck7pairs or winParam.byCheck7pairs or 0

    --检查8小对：0不检查 1癞子做普通牌 2癞子可替任何牌
    local byCheck8Pairs = serverParam.byCheck8Pairs or winParam.byCheck8Pairs or 0

    --13幺：0不检查 1癞子做普通牌 2癞子可替任何牌
    local byCheckShiSanYao = serverParam.byCheckShiSanYao or winParam.byCheckShiSanYao or 0

    --几张癞子牌可胡 0不检查 >0才检查胡
    local byLaiziWinNums = serverParam.byLaiziWinNums or winParam.byLaiziWinNums or 0

    --十三不靠: 0不检查 1检查
    local byShiSanBuKao = serverParam.byShiSanBuKao or winParam.byShiSanBuKao or 0

    --七星不靠: 0不检查 1检查
    local byQiXingBuKao = serverParam.byQiXingBuKao or winParam.byQiXingBuKao or 0

    --258将: 0不检查, 1癞子做普通牌 2癞子可替任何牌
    local by258Jiang = serverParam.by258Jiang or winParam.by258Jiang or 0

    --风扑: 0不检查
    local	byWindPu = serverParam.byWindPu or winParam.byWindPu or 0

    --将扑: 0不检查
    local	byJiangPu = serverParam.byJiangPu or winParam.byJiangPu or 0

    --幺九扑: 0不检查
    local	byYaoJiuPu = serverParam.byYaoJiuPu or winParam.byYaoJiuPu or 0

    --中发白当顺子，0不检查，1癞子做普通牌 2癞子可替任何牌
    local byShunZFB = serverParam.byShunZFB or winParam.byShunZFB or 0

    --[[--
    --东南西北是顺子: 0不检查 1任意三张组合成顺子(癞子不可替换),
    --2按顺序组合成顺子(癞子不可替换),
    --3任意三张组合成顺子(癞子可替换),
    --4按顺序组合成顺子(癞子可替换)
    ]]
    local byShunWind = serverParam.byShunWind or winParam.byShunWind or 0

    --胡牌必须是边卡吊:0不检查，1检查
    local byBKDHu = serverParam.byBKDHu or winParam.byBKDHu or 0

    --白板当金本身使用(白板充当做癞子的那张牌)
    local byBaiChangeGoldUse = serverParam.byBaiChangeGoldUse or winParam.byBaiChangeGoldUse or 0

    --手上最多可以有多少张牌
    local byMaxHandCardLength = serverParam.byMaxHandCardLength or (mode_manager.GetCurrentMode().cfg.MahjongHandCount + 1)

    --游戏类型
    local nGameStyle = serverParam.nGameStyle or player_data.GetGameId() or 0

    --八张花是否可胡牌,0:否，1是
    local nEightFlowerHu = serverParam.nEightFlowerHu or winParam.nEightFlowerHu or 0

    --开门限制，0没有，1没有吃碰杠不能胡
    local byKaiMenLimit = serverParam.byKaiMenLimit or winParam.byKaiMenLimit or 0

    --胡牌需要花色限制 0没有，3，3种花色齐全
    local byColorLimit = serverParam.byColorLimit or winParam.byColorLimit or 0

    --有花色限制时，是否可以胡清一色，0不可以，1可以
    local byQYSHu = serverParam.byQYSHu or winParam.byQYSHu or 0

    --幺九限制，0没有，1有
    local byYaoJiuLimit = serverParam.byYaoJiuLimit or winParam.byYaoJiuLimit or 0

    --手把一，单吊胡牌仅允许飘胡牌型，即有“吃”就不允许单吊胡牌，0无，1 有
    local byDanDiaoLimit = serverParam.byDanDiaoLimit or winParam.byDanDiaoLimit or 0

    --剩余各个牌的数目
    local nNSNum = serverParam.nNSNum or {}

    --单金不能点炮胡
    local byOneGoldLimit = serverParam.byOneGoldLimit or winParam.byOneGoldLimit or 0

    --双金以上必须游金胡
    local byTwoGoldLimit = serverParam.byTwoGoldLimit or winParam.byTwoGoldLimit or 0

    local t = {
        byCheck7pairs = byCheck7pairs,
        byCheck8Pairs = byCheck8Pairs,
        byCheckShiSanYao = byCheckShiSanYao,
        byLaiziWinNums = byLaiziWinNums,
        byShiSanBuKao = byShiSanBuKao,
        byQiXingBuKao = byQiXingBuKao,

        by258Jiang = by258Jiang,
        byWindPu = byWindPu,
        byJiangPu = byJiangPu,
        byYaoJiuPu = byYaoJiuPu,

        byShunZFB = byShunZFB,
        byShunWind = byShunWind,
        byBKDHu = byBKDHu,

        byBaiChangeGoldUse = byBaiChangeGoldUse,
        byMaxHandCardLength = byMaxHandCardLength,
        nGameStyle = nGameStyle;

        nEightFlowerHu = nEightFlowerHu,
        byKaiMenLimit = byKaiMenLimit,
        byColorLimit = byColorLimit,
        byQYSHu = byQYSHu,
        byYaoJiuLimit = byYaoJiuLimit,
        byDanDiaoLimit = byDanDiaoLimit,
        nNSNum = nNSNum,
        byOneGoldLimit = byOneGoldLimit,
        byTwoGoldLimit = byTwoGoldLimit,
    }
    --LogW("GetCheckWinParam() table = "..json.encode(t))
    return t
end

--[[--
 * @Description: 检测胡牌提示
 * @param:       tableInfo (当前牌局相关的配置信息)
 * @param:       callback (检测结果回调函数)
 * @param:       version ()
 ]]
function LibFanCounter:checkHuTips( tableInfo ,callback, version )
    tableInfo = tableInfo or {}
    local env = self:CollectTingEnv(tableInfo)
    local tenv = json.encode(env);
    LogW("LibFanCounter:checkHuTips() env = " ,tenv);
    YX_APIManage.Instance:checkHuTips(function ( ret , newVersion)
        if callback then
            LogW("LibFanCounter:checkHuTips() ret = ",ret);
            callback(ret, newVersion)
        end
    end, version, tenv)
end

--[[--
 * @Description: 获取胡牌提示检测结果信息
 * @return:      json字符串格式的胡牌提示信息
 ]]
function LibFanCounter:getHuTipsInfo()
     local tingInfo = YX_APIManage.Instance:getHuTipsInfo()
    if tingInfo then
        LogW("tingInfo ------------------",tingInfo)
        return tingInfo
    else
        LogW("tingInfo -------------------- nil")
    end
end

--function LibFanCounter:SetEnv(env)
--     local tEnv = json.encode(env)
--     LogW("SetEnv+++++",tEnv)
--     --YX_APIManage.Instance:setTingEnvironment(tEnv)
--     return tEnv
--end

--function LibFanCounter:CreateInit(strSlotName)
--    local stSlotFuncNames = {"Init", "SetEnv", "GetCount", "GetScore", "InitForNext", "GetTingInfo", "GetHuPaiInfo"}
--    self.m_slot  = self:LoadSlot(strSlotName, stSlotFuncNames)
--    if self.m_slot == nil then
--        return false
--    end
--
--    local nMinWin = GGameCfg.RoomSetting.nMinFan
--    local nBaseBet = GGameCfg.RoomSetting.nBaseBet
--    if self.m_slot.Init(nMinWin, nBaseBet) == false then
--        return false
--    end
--
--    return true
--end
--
--function LibFanCounter:OnGameStart()
--    self.m_slot.InitForNext()
--end
--
--function LibFanCounter:CollectEnv(nChair, nTurn, nFlag, nLast)
--    local stGameState = GGameState
--    local stRoundInfo = GRoundInfo
--    local env = import(".environment", CURRENT_MODULE_NAME)
--    if nChair > 4 or nChair < 1 then
--        LOG_ERROR("LibFanCounter:CollectEnv nChair:%d", nChair)
--        return nil
--    end
--    -- 还剩多少张牌，用来计算海底等
--    env.byTilesLeft = GDealer:GetDealerCardGroup():GetCurrentLength()
--    local stPlayer = stGameState:GetPlayerByChair(nChair)
--    if stPlayer == nil  then
--        LOG_ERROR("LibFanCounter:CollectEnv nChair:%d", nChair)
--        return nil
--    end
--    -- 圈风
--    env.byRoundWind = stRoundInfo:GetRoundWind()
--    -- 门风
--    env.byPlayerWind = stPlayer:GetSeatWind()
--    -- 检查谁的
--    env.byChair = nChair - 1
--    -- 轮到谁，如果是点炮，则是点炮的那个人
--    if nTurn ~= nil then
--        env.byTurn = nTurn  - 1
--    else
--        env.byTurn = stRoundInfo:GetWhoIsOnTurn()  - 1
--    end
--
--    for i=1,8 do
--        local byWho = stRoundInfo:GetFlower(i)
--        if byWho <= 4  and byWho > 0 then
--            env.byFlowerCount[byWho] = env.byFlowerCount[byWho] + 1
--        end
--    end
--
--    for i=1,PLAYER_NUMBER do
--        env.byTing[i] = stGameState:GetPlayerByChair(i):GetTing()
--    end
--
--    if nFlag  ~= nil  then
--        env.byFlag = nFlag
--        env.tLast = nLast
--    else
--        if nChair == stRoundInfo:GetWhoIsOnTurn() then
--            -- 自摸
--            if stRoundInfo:GetDrawStatus() == DRAW_STATUS_GANG then
--                env.byFlag = WIN_GANGDRAW
--            else
--                env.byFlag = WIN_SELFDRAW
--            end
--            env.tLast = stRoundInfo:GetLastDraw() -- 最后和的那张牌
--        else
--            -- LOG_DEBUG("LibFanCounter:CollectEnv...byFlag:%d, GIVE_STATUS_GANGGIVE:%d", stRoundInfo:GetGiveStatus(), GIVE_STATUS_GANGGIVE)
--            -- 和别人的
--            if stRoundInfo:GetGiveStatus() == GIVE_STATUS_GANGGIVE then
--                env.byFlag = WIN_GANGGIVE
--            else
--                env.byFlag = WIN_GUN
--            end
--            env.tLast = stRoundInfo:GetLastGive()  -- 最后和的那张牌
--        end
--    end
--
--    for i=1,PLAYER_NUMBER do
--        -- 手上的牌
--        local stPlayer = stGameState:GetPlayerByChair(i)
--        local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
--        local nHandCount = stPlayerCardGroup:GetCurrentLength()
--        env.byHandCount[i] = nHandCount
--        for j=1, nHandCount do
--            env.tHand[i][j] = stPlayerCardGroup:GetCardAt(j)
--        end
--        -- set有几手牌
--        local stPlayerCardSet = stPlayer:GetPlayerCardSet()
--        env.bySetCount[i] = stPlayerCardSet:GetCurrentLength()
--        LOG_DEBUG("=====COLLECT===env.bySetCount[i]============:%d",env.bySetCount[i])
--        local combineTile = stPlayer:GetPlayerCardSet():ToArray()
--        for j =1,#combineTile do
--            env.tSet[i][j][1] = combineTile[j].ucFlag
--            env.tSet[i][j][2] = combineTile[j].card
--            env.tSet[i][j][3] = combineTile[j].value
--            if env.tSet[i][j][3]  > 0 then
--                env.tSet[i][j][3] =env.tSet[i][j][3]  - 1
--            end
--        end
--
--        local length = #combineTile
--        LOG_DEBUG("COLLECT===length=%d, combineTile=:%s", length, vardump(combineTile))
--
--        local stPlayerGiveGroup = stPlayer:GetPlayerGiveGroup()
--        env.byGiveCount[i] = stPlayerGiveGroup:GetCurrentLength()
--    end
--
--    for i=1,PLAYER_NUMBER do
--        --出过牌（没被吃碰杠收集、或者出过牌）
--        local stPlayerOne = stGameState:GetPlayerByChair(i)
--        if  env.byGiveCount[i] > 0 or stPlayerOne:IsPlayCardsAlready() then
--            env.byDoFirstGive[i] = 1
--        else
--            env.byDoFirstGive[i] = 0
--        end
--    end
--    if env.byFlag ~= WIN_SELFDRAW and  env.byFlag ~= WIN_GANGDRAW then
--        env.tHand[nChair][env.byHandCount[nChair] + 1] = env.tLast
--        env.byHandCount[nChair] = env.byHandCount[nChair] + 1
--    end
--    env.byDealer = stRoundInfo:GetBanker() - 1
--
--    env.gamestyle = GGameCfg.RoomSetting.nGameStyle
--
--    local nLaiZiCount = stPlayer:GetGoldCardNums()
--    local nLaiziCards = LibLaiZi:GetLaiZi()
--    local nGangTimes = stPlayer:GetLianGangTimes()
--    env.byLaiziCards = nLaiziCards
--    env.laizi = nLaiZiCount
--    env.byGangTimes = nGangTimes
--
--
--    --需要计算的番型
--    env.tDoCheck = {}
--    env.tDoCheck = LibInterface.GetDoCheck(nChair)
--    --番型数据
--    local stFan, stMutex = LibInterface.GetDoEnvFan(nChair)
--    env.tEnvFan = {}
--    env.tEnvFan = stMutex
--    --check win 一些必须参数
--    env.tCheckWinParam = {}
--    env.tCheckWinParam = LibPublic.GetCheckWinParam()
--
--    env.nNSNum ={}
--    for i=1,37 do
--        env.nNSNum[i] = stRoundInfo:GetCardNotShowNum(i)
--    end
--
--    if env.byDoFirstGive[nChair] == 1 then
--        env.byGodTingFlag = 1
--    end
--
--    return env
--end
--function LibFanCounter:CalculateIsSet()
--    local bIsHaveSet =false
--    for i=1,PLAYER_NUMBER do
--        local stPlayer = GGameState:GetPlayerByChair(i)
--        local stCardSet = stPlayer:GetPlayerCardSet()
--        for n=1,stCardSet:GetCurrentLength() do
--            local sets = stCardSet:GetCardSetAt(n)
--            if sets.ucFlag == ACTION_QUADRUPLET or sets.ucFlag == ACTION_QUADRUPLET_REVEALED or sets.ucFlag == ACTION_TRIPLET or sets.ucFlag == ACTION_QUADRUPLET_CONCEALED then
--                bIsHaveSet = true
--                break
--            end
--        end
--    end
--    return bIsHaveSet
--end
--function LibFanCounter:SetEnv(env)
--    self.m_slot.SetEnv(env)
--end
--
--function LibFanCounter:GetCount()
--    return self.m_slot.GetCount()
--end
--
--function LibFanCounter:GetScore()
--    return self.m_slot.GetScore()
--end
--
--function LibFanCounter:CheckWin(arrPlayerCards,nlaizicount,laizicard,checkWinParam)
--    return self.m_slot.CheckWin(arrPlayerCards,nlaizicount,laizicard,checkWinParam)
--end
--
--function LibFanCounter:GetTingInfo()
--    return self.m_slot.GetTingInfo()
--end
--
--function LibFanCounter:GetHuPaiInfo()
--    return self.m_slot.GetHuPaiInfo()
--end

return LibFanCounter
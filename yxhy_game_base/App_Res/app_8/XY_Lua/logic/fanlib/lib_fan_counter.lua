local stGameState = nil
local stRoundInfo = nil
local CURRENT_MODULE_NAME = ...
local LibFanCounter = class("LibFanCounter")

local env = {
    byChair = 0, -- 检查谁的
    byTurn = 0, -- 轮到谁，如果是点炮，则是点炮的那个人
    tHand = {
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    }, -- 全部手牌
    byHandCount = {
         16,16,16,16
    }, -- 手牌数
    tSet = {
         {{0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}},
         {{0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}},
         {{0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}},
         {{0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}},
        -- [4] = {{0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}},

    }, -- 四家，4手牌？福州17张   轮到谁，如果是点炮，则是点炮的那个人      ucFlag,card,value
    bySetCount = {
        0,0,0,0
    }, -- set有几手牌
    tGive = {
        {
        0,0,0,0,0, 0,0,0,0,0,
        0,0,0,0,0, 0,0,0,0,0,
        0,0,0,0,0, 0,0,0,0,0,
        0,0,0,0,0, 0,0,0,0,0,
        },
        {
        0,0,0,0,0, 0,0,0,0,0,
        0,0,0,0,0, 0,0,0,0,0,
        0,0,0,0,0, 0,0,0,0,0,
        0,0,0,0,0, 0,0,0,0,0,
        },
        {
        0,0,0,0,0, 0,0,0,0,0,
        0,0,0,0,0, 0,0,0,0,0,
        0,0,0,0,0, 0,0,0,0,0,
        0,0,0,0,0, 0,0,0,0,0,
        },
        {
        0,0,0,0,0, 0,0,0,0,0,
        0,0,0,0,0, 0,0,0,0,0,
        0,0,0,0,0, 0,0,0,0,0,
        0,0,0,0,0, 0,0,0,0,0,
        },
    }, -- 四家出过的牌
    byGiveCount = {
        0,0,0,0
    }, -- 每人出了几张牌
    tLast = 0, --  最后和的那张牌
    byFlag = 0, -- 0自摸、1点炮、2杠上花、3抢杠
    byRoundWind = 0, -- 圈风
    byPlayerWind = 0, -- 门风
    byTilesLeft = 0; -- 还剩多少张牌，用来计算海底等
    byFlowerCount = {
        0,0,0,0
    }, -- 4家各有多少张花
    byTing = {
        0,0,0,0
    }, -- 听牌的玩家
    byDoFirstGive =  {
        0,0,0,0
    }, -- 4家是否出过牌(这个主要用来判断地胡)
    
    byRecv = {
        0,0,0,0,0,0
    }, -- 和牌前别人出过的牌
    gamestyle = 0, -- 游戏类型
    
    qianggang = 0, -- 抢杠
    menqing = 0, -- 门清
    bkd = 0, -- 边卡吊
    wukui = 0, -- 五魁
    byDealer = 0, -- 庄家
    qiangjin = 0, -- 是否是抢金胡：1是，0非
    laizi = 0, -- 癞子数量，或金数量
    flower = 0, -- 花数量
    byLaiziCards = {
        0,0,0,0
    }, -- 癞子牌数组，暂定最大是4个
    halfQYS = 0 ,  --是否支持在半清一色
    allQYS = 0, -- 是否支持全清一色
    goldDragon = 0, -- 是否支持金龙
    nNSNum = {
    0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0
    }, -- 剩余各个牌的数目
    bankerfirst = 0,

}

function LibFanCounter:ctor( cfg )
    YX_APIManage.Instance:initHuTips()
    self.m_tableConf = cfg or {}
end

--[[

]]
function LibFanCounter:CollectTingEnv(tableInfo )
    local env = clone(env) --import(".environment", CURRENT_MODULE_NAME)

    local nChair = tableInfo.chair or 1
    local nTurn = tableInfo.turn or 1

    local tHand = tableInfo.tHand 
    local byHandCount = 17--tableInfo.byHandCount or 0
    local laiziCard = tableInfo.laiziCard or 0

    local tSet = tableInfo.tSet
    local bySetCount = tableInfo.bySetCount or 0
    local tGive = tableInfo.tGive 
    local byGiveCount = tableInfo.byGiveCount
    local tLast = tableInfo.tLast or 0
    local byFlag = tableInfo.byFlag or 0
    local byRoundWind = tableInfo.byRoundWind or 0
    local byPlayerWind = tableInfo.byPlayerWind or 0
    local byTilesLeft = tableInfo.byTilesLeft or 0
    local byFlowerCount = tableInfo.byFlowerCount
    local byTing = tableInfo.byTing
    local byDoFirstGive = tableInfo.byDoFirstGive
    local byRecv = tableInfo.byRecv


    local qianggang = tableInfo.qianggang or 0
    local qiangjin = tableInfo.qiangjin or 0

    local dealer = tableInfo.dealer or 0
    local nNSNum = tableInfo.nNSNum

    local flower = tableInfo.flower or 0
    local laizi = tableInfo.laizi or 0

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
    -- env.tHand[nChair] = tHand or env.tHand[nChair]
    env.byHandCount[nChair] = byHandCount--byHandCount or env.byHandCount[nChair]
    env.byLaiziCards[1] = laiziCard
    -- env.tSet[nChair] = tSet or env.tSet[nChair]
    env.bySetCount[nChair] = bySetCount or env.bySetCount[nChair]
    if tSet then
        for j = 1,5 do
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
    
    -- env.tGive = tGive or env.tGive
    env.byGiveCount = byGiveCount or env.byGiveCount
    env.tLast = tLast
    env.byFlag = byFlag
    env.byRoundWind = byRoundWind
    env.byPlayerWind = byPlayerWind
    env.byTilesLeft = byTilesLeft
    env.byFlowerCount = byFlowerCount or env.byFlowerCount
    env.byTing = byTing or env.byTing
    env.byDoFirstGive = byDoFirstGive or env.byDoFirstGive
    env.byRecv = byRecv or env.byRecv
    env.byDealer = dealer
    env.flower = flower
    env.nNSNum = nNSNum or env.nNSNum
    env.laizi = laizi

    -- config
    env.qianggang = qianggang
    env.qiangjin = qiangjin

    env.menqing = self.m_tableConf.menqing or 0
    env.bkd = self.m_tableConf.bkd or 0
    env.wukui = self.m_tableConf.wukui or 0
    env.halfQYS = self.m_tableConf.halfQYS or 0
    env.allQYS = self.m_tableConf.allQYS or 0
    env.goldDragon = self.m_tableConf.goldDragon or 0

    return env
end

function LibFanCounter:SetEnv(env)
     local tEnv = json.encode(env)  
     LogW("SetEnv+++++",tEnv)
     --YX_APIManage.Instance:setTingEnvironment(tEnv)
     return tEnv
end

function LibFanCounter:checkTing( tableInfo ,callback, version )
    tableInfo = tableInfo or {}
    local env = self:CollectTingEnv(tableInfo)
    -- LogW("checkTing ---- " ,env);
    local tenv = self:SetEnv(env);
    YX_APIManage.Instance:checkTingCount(function ( ret , newVersion)
        if callback then
            -- LogW("checkTingCount --- ret = ",ret);
            callback(ret, newVersion)
        end    
    end, version, tenv)
    
end

function LibFanCounter:getTingInfo(  )
     local tingInfo = YX_APIManage.Instance:getTingInfo()
    if tingInfo then
        LogW("tingInfo ------------------",tingInfo)
        return tingInfo
    else
        LogW("tingInfo -------------------- nil")
    end
end

-- function LibFanCounter:CreateInit(strSlotName)
--     local stSlotFuncNames = {"Init", "SetEnv", "GetCount", "GetScore", "InitForNext","GetTingInfo"}
--     self.m_slot  = self:LoadSlot(strSlotName, stSlotFuncNames)
--     if self.m_slot == nil then
--         return false
--     end

--      local nMinWin =  1-- GGameCfg.RoomSetting.nMinFan
--      local nBaseBet = 20 --GGameCfg.RoomSetting.nBaseBet
--     if self.m_slot.Init(nMinWin, nBaseBet) == false then
--         return false
--     end


--     if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_CHENGDU  then
--         local nStyle = GGameCfg.RoomSetting.nSubGameStyle 
--         local bZiMoJiaDi = GGameCfg.RoomSetting.bZiMoJiaDi
--         local bJiaJiaYou = GGameCfg.RoomSetting.bJiaJiaYou
--         if self.m_slot.InitFanChengDuCounter(nStyle, bZiMoJiaDi, bJiaJiaYou) == false then
--             return false
--         end
--       end

--     return true
-- end
-- function LibFanCounter:OnGameStart()
--     -- self.m_slot.InitForNext()
--     for i=1,PLAYER_NUMBER do
--         self.handCache[i] = {}
--         self.tingCache[i] = {}
--     end
-- end

-- function LibFanCounter:CollectEnv(nChair, nTurn, nFlag, nLast)
--     local stGameState = GGameState
--     local stRoundInfo = GRoundInfo
--     local env = import(".environment", CURRENT_MODULE_NAME)
--     if nChair > 4 or nChair < 1 then
--         --LOG_ERROR("LibFanCounter:CollectEnv nChair:%d", nChair)
--         return nil
--     end    
--     --  还剩多少张牌，用来计算海底等
--     env.byTilesLeft = GDealer:GetDealerCardGroup():GetCurrentLength()
--     local stPlayer = stGameState:GetPlayerByChair(nChair)
--     if stPlayer == nil  then
--         --LOG_ERROR("LibFanCounter:CollectEnv nChair:%d", nChair)
--         return nil
--     end
--     --  圈风
--     env.byRoundWind = stRoundInfo:GetRoundWind()
--     -- 门风
--     env.byPlayerWind = stPlayer:GetSeatWind()
--     -- 检查谁的
--     env.byChair = nChair - 1
--     -- 轮到谁，如果是点炮，则是点炮的那个人
--     if nTurn ~= nil then
--         env.byTurn = nTurn  - 1
--     else
--          env.byTurn = stRoundInfo:GetWhoIsOnTurn()  - 1
--      end
   

--     for i=1,8 do
--         local byWho = stRoundInfo:GetFlower(i)
--         if byWho <= 4  and byWho > 0 then
--             env.byFlowerCount[byWho] = env.byFlowerCount[byWho] + 1
--         end
--     end

--     for i=1,PLAYER_NUMBER do
--         env.byTing[i] = stGameState:GetPlayerByChair(i):GetTing()
--     end

--     local nGoldCard = LibGoldCard:GetOpenGoldCard()

--     if nFlag  ~= nil  then
--          env.byFlag = nFlag
--          env.tLast = nLast
--     else
--         --抢金胡的话，设成自摸但是要把金牌加进牌堆
--         if GRoundInfo:IsRobGolgHu() then
--             env.byFlag = WIN_SELFDRAW
--             env.tLast = nGoldCard
--         else
--             if nChair == stRoundInfo:GetWhoIsOnTurn() then
--                 -- 自摸
--                  if stRoundInfo:GetDrawStatus() == DRAW_STATUS_GANG then
--                     env.byFlag = WIN_GANGDRAW
--                 else
--                     env.byFlag = WIN_SELFDRAW
--                 end
                
--                 env.tLast = stRoundInfo:GetLastDraw() -- 最后和的那张牌
--                -- LOG_DEBUG("111LibFanCounter:CollectEnv env.tLast:%d",env.tLast)

--             else
--                 -- 和别人的
--                 if stRoundInfo:GetGiveStatus() == GIVE_STATUS_GANGGIVE then
--                     env.byFlag = WIN_GANGGIVE
--                  else
--                     env.byFlag = WIN_GUN
--                 end
                
--                  env.tLast = stRoundInfo:GetLastGive()  -- 最后和的那张牌
--                  --LOG_DEBUG("222LibFanCounter:CollectEnv env.tLast:%d",env.tLast)
--             end
--         end
--     end
--     for i=1,PLAYER_NUMBER do
--         -- 手上的牌
--         local stPlayer = stGameState:GetPlayerByChair(i)
--         local stPlayerCardGroup = stPlayer:GetPlayerCardGroup()
--         local nHandCount = stPlayerCardGroup:GetCurrentLength()
--         env.byHandCount[i] = nHandCount
--         for j=1, nHandCount do
--              env.tHand[i][j] = stPlayerCardGroup:GetCardAt(j)
--         end
--         -- set有几手牌
--         local stPlayerCardSet = stPlayer:GetPlayerCardSet()
--         env.bySetCount[i] = stPlayerCardSet:GetCurrentLength()
--        -- LOG_DEBUG("=====COLLECT===env.bySetCount[i]============:%d",env.bySetCount[i])
--         local combineTile = stPlayer:GetPlayerCardSet():ToArray()
--         --LOG_DEBUG("xxxxxxxxxxxxxxxxxxxx = %s\n", vardump(env.tSet[i]))
--         for j =1,#combineTile do
--             --LOG_DEBUG("=====COLLECT===#j=======#combineTile =======:%d,%d",j,#combineTile )
--             --LOG_DEBUG("yyyyyyyyyyyyyyy = %s\n", vardump(env.tSet[i][j]))
--             --LOG_DEBUG("zzzzzzzzzzzzzzzz = %s\n", vardump(combineTile[j]))
--                 env.tSet[i][j][1] = combineTile[j].ucFlag
--                 env.tSet[i][j][2] = combineTile[j].card
--                 env.tSet[i][j][3] = combineTile[j].value
--                 if env.tSet[i][j][3]  > 0 then
--                     env.tSet[i][j][3] =env.tSet[i][j][3]  - 1
--                 end
--         end
--         local length = #combineTile
--        -- LOG_DEBUG("=====COLLECT===#combineTile============:%d",length)
--        -- LOG_DEBUG("=====COLLECT===combineTile============:%s",vardump(combineTile))
--         --[[for j=1,4 do
--             if j < env.bySetCount[i] then
--                 local sets = stPlayerCardSet:GetCardSetAt(j)
--                 env.tSet[i][j][1] = sets.ucFlag
--                 env.tSet[i][j][2] = sets.card
--                 env.tSet[i][j][3] = sets.value
--                 LOG_DEBUG("LibFanCounter:CollectEnv==i==%d===j %d",i,j);
--                 LOG_DEBUG("LibFanCounter:CollectEnv %d",env.tSet[i][j][1]);
--             end
--         end --]]
--         --// give
--         local stPlayerGiveGroup = stPlayer:GetPlayerGiveGroup()
--         env.byGiveCount[i] = stPlayerGiveGroup:GetCurrentLength()

--     end
--     for i=1,PLAYER_NUMBER do
--         --出过牌（没被吃碰杠收集、或者出过牌）
--         local stPlayerOne = stGameState:GetPlayerByChair(i)
--         if  env.byGiveCount[i] > 0 or stPlayerOne:IsPlayCardsAlready() then
--             env.byDoFirstGive[i] = 1
--         else
--              env.byDoFirstGive[i] = 0
--         end
--     end
--     if env.byFlag ~= WIN_SELFDRAW and  env.byFlag ~= WIN_GANGDRAW then
--         env.tHand[nChair][env.byHandCount[nChair] + 1] = env.tLast
--         env.byHandCount[nChair] = env.byHandCount[nChair] + 1
--     end
--     --抢金胡的话，设成自摸但是要把金牌加进牌堆
--     local nLaiZiCount = stPlayer:GetGoldCardNums()
--     LOG_DEBUG("=====COLLECT===#nLaiZiCount====111========:%d",nLaiZiCount)
--     if GRoundInfo:IsRobGolgHu() then
--         env.tHand[nChair][env.byHandCount[nChair] + 1] = env.tLast
--         env.byHandCount[nChair] = env.byHandCount[nChair] + 1
--         --fix bug 抢金时癞子数没更新
--         nLaiZiCount = nLaiZiCount +1
--     end

--     LOG_DEBUG("=====COLLECT===env.tHand============:%s",vardump(env.tHand))
--     env.byDealer = stRoundInfo:GetBanker() - 1

--     env.gamestyle = GGameCfg.RoomSetting.nGameStyle

    
--     --金牌、花数、是否枪金胡、癞子牌
--     --local nLaiZiCount = stPlayer:GetGoldCardNums()
--     local nFlowerCount =stPlayer:GetFlowerNums()
--     local nQiangjin = 0
--     LOG_DEBUG("===============...nHuWay:%d", stRoundInfo:GetHuWay())
--     if stRoundInfo:IsRobGolgHu() then
--         nQiangjin = 1
--     end
--     local nLaiziCards = LibGoldCard:GetGoldCards()
--     local nHalfQYS = 0
--     local nQYS = 0
--     local nGoldDragon = 0
--     if GGameCfg.GameSetting.bSupportHalfColor then
--         nHalfQYS = 1
--     end
--     if GGameCfg.GameSetting.bSupportOneColor then
--         nQYS = 1
--     end
--     if GGameCfg.GameSetting.bSupportGoldDragon then
--         nGoldDragon = 1
--     end

--     if GGameCfg.RoomSetting.nGameStyle == GAME_STYLE_FUZHOU then
--         env.laizi= nLaiZiCount
--         env.flower= nFlowerCount
--         env.qiangjin= nQiangjin
--         env.byLaiziCards =nLaiziCards
--         env.halfQYS = nHalfQYS
--         env.allQYS = nQYS
--         env.goldDragon = nGoldDragon
--     end
--     local nCardNums = 37
-- --    local nGameStyle = GGameCfg.RoomSetting.nGameStyle
-- --    if nGameStyle == GAME_STYLE_FUZHOU then
-- --            nCardNums = 30
--  --   end
--     env.nNSNum ={}
--     env.bankerfirst=0
--     for i=1,37 do
--         env.nNSNum[i] = stRoundInfo:GetCardNotShowNum(i)
--     end
--    -- LOG_DEBUG("=====COLLECT===#nFlowerCount============:%d",nFlowerCount)
--     LOG_DEBUG("=====COLLECT===#nLaiZiCount============:%d",nLaiZiCount)
--     LOG_DEBUG("=====COLLECT===#nQiangjin============:%d",nQiangjin)
--     -- end
--     return env
-- end




-- function LibFanCounter:GetCount()
--     return self.m_slot.GetCount()
-- end
-- function LibFanCounter:GetScore()
--     return self.m_slot.GetScore()
-- end
-- function LibFanCounter:CheckWin(arrPlayerCards,nlaizicount,laizicard,ngamestyle)
--     return self.m_slot.CheckWin(arrPlayerCards,nlaizicount,laizicard,ngamestyle)
-- end
-- function LibFanCounter:GetTingInfo()
--     return self.m_slot.GetTingInfo()
-- end

return LibFanCounter
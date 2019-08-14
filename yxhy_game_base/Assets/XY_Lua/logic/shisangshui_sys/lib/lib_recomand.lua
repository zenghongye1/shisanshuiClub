local LibBase = import(".lib_base")
local LibLaiZi = import(".lib_laizi"):create()
local LibNormalCardLogic = import(".lib_normal_card_logic")
local libRecomand = class("libRecomand", LibBase)

function libRecomand:ctor()
end

function libRecomand:CreateInit(strSlotName)
    return true
end

function libRecomand:OnGameStart()
end

--获取点数相同的所有数据
function libRecomand:Get_Same_Poker(cards, count)
    local hash = {}
    for i=1, 14 do
        hash[i] = {}
    end

    for i, v in ipairs(cards) do
        local nV = GetCardValue(v)
        table.insert(hash[nV], v)
    end

    local t = {}
    for i, v in ipairs(hash) do
        if #v == count then
            table.insert(t, v)
        end
    end

    if #t > 0 then
        return true, t
    else
        return false
    end
end

function libRecomand:Get_Same_Poker_Ext(cards, count)
    if count and count > 0 then
        local hash = {}
        for i=1, 14 do
            hash[i] = {}
        end

        for i, v in ipairs(cards) do
            local nV = GetCardValue(v)
            table.insert(hash[nV], v)
        end

        local t = {}
        for i, v in ipairs(hash) do
            if #v >= count then
                table.insert(t, v)
            end
        end

        if #t > 0 then
            return true, t
        else
            return false
        end
    end
    return false
end

--组合n个点数相同的牌
function libRecomand:Get_Same_nCard_Split(cards, n)
    local ret = false
    local result = {}
    if n and n > 0 then
        local bSuc, t = self:Get_Same_Poker_Ext(cards, n)
        if bSuc then
            for _, v in ipairs(t) do
                for i=1, #v-n+1 do
                    local stAdd = {}
                    for j=1, n do
                        local nCard = v[i+j-1]
                        table.insert(stAdd, nCard)
                    end
                    if #stAdd == n then
                        --去掉重复的
                        local bNotSame = true
                        if #v > n then
                            for _, res in ipairs(result) do
                                local arrCopy1 = Array.Clone(stAdd)
                                local arrCopy2 = Array.Clone(res)
                                Array.DelElements(arrCopy1, arrCopy2)
                                if #arrCopy1 == 0 then
                                    bNotSame = false
                                    break
                                end   
                            end
                        end
                        if bNotSame then
                            ret = true
                            table.insert(result, stAdd)
                        end
                    end
                end
            end
        end
    end
    return ret, result
end

--按值降序 14-2
function libRecomand:Sort(cards)
    -- --LOG_DEBUG("LibNormalCardLogic:Sort..before, cards: %s\n", TableToString(cards))
    if not cards.isSorted then
        table.sort(cards, function(a,b)
            local valueA,colorA = GetCardValue(a), GetCardColor(a)
            local valueB,colorB = GetCardValue(b), GetCardColor(b)
            if valueA == valueB then
                return colorA > colorB
            else
                return valueA > valueB
            end
        end)
        cards.isSorted = true
    end
    -- --LOG_DEBUG("LibNormalCardLogic:Sort..end, cards: %s\n", TableToString(cards))
end

--过滤 牌型相同且点数相同的牌  只要一副就行  返回false不过滤 true过滤
function libRecomand:DissSameCards(recommend, destTypes, destValues)
    for _, v in ipairs(recommend) do
        local tempTypes = v.Types
        -- local tempValues = v.Values
        --所有牌型一样  比较牌值
        if tempTypes[1] == destTypes[1] 
            and tempTypes[2] == destTypes[2]
            and tempTypes[3] == destTypes[3]
            --牌型一样就只要一副
            -- and Array.IsSubSet(destValues[1], tempValues[1]) == true
            -- and Array.IsSubSet(destValues[2], tempValues[2]) == true
            -- and Array.IsSubSet(destValues[3], tempValues[3]) == true
            then
                return true
        end
    end
    return false
end

--[[获取推荐牌型
SetRecommandLaizi(cards)函数说明：
参数cards: 为玩家手牌 共13张

格式：cards = {1,2,3,...}

返回值：recommend_cards = 
{
    {
        Cards={1,2,3,4,5,...},  --1-5是后墩 6-10是中墩 11-13是前墩
        Types={1,2,3},      --依次为尾中前牌型
        Values={
            {1,2,3,4,5},    --尾墩牌的点数
            {1,2,3,4,5},    --中墩牌的点数
            {1,2,3}         --前墩牌的点数
        }
    }, 
    ....
}
--]]
function libRecomand:SetRecommandLaizi(cards)
    --1.把癞子牌和普通牌分离
    local normalCards = {}
    local laiziCards = {}
    for _, v in ipairs(cards) do
        local nValue = GetCardValue(v)
        if LibLaiZi:IsLaiZi(nValue) then
            table.insert(laiziCards, v)
        else
            table.insert(normalCards, v)
        end
    end
    local nLaziCount = #laiziCards

    -- LOG_DEBUG("SetRecommandLaizi...#normalCards:%d, normalCards:%s\n", #normalCards, vardump(normalCards))
    -- LOG_DEBUG("SetRecommandLaizi...#laiziCards:%d,  laiziCards:%s\n", #laiziCards, vardump(laiziCards))
    local recommend_cards = {}
    local recommend_cards_first = {}
    local recommend_cards_second = {}

    ----1.尾墩
    local bthirdFind, thirdAllResult = self:Get_Five_Cards_Laizi(normalCards, nLaziCount, 3)
    -- LOG_DEBUG("SetRecommandLaizi.........bthirdFind:%s, thirdAllResult:%s\n", tostring(bthirdFind), vardump(thirdAllResult))

    ---可能组成尾墩的所有牌型 
    --thirdAllResult = {result, result, result...}
    --result = {{card={1,2,3..}, index={1,2} },....}
    for _, thirdResult in ipairs(thirdAllResult) do
        for _, thi in ipairs(thirdResult) do
            local stLaiziCards = Array.Clone(laiziCards)    --癞子牌初始数据
            local tempthirdCards = thi.card                 --组成牌型的牌
            local tempthirdIndex = thi.index                --癞子牌在thi.card中位置

            --剩余的癞子牌
            local nThirdUsedLaizi = 0
            for _, v in pairs(tempthirdIndex) do
                nThirdUsedLaizi = nThirdUsedLaizi + 1
            end
            local thirdLeftLaizi = nLaziCount - nThirdUsedLaizi

            --需要移除的牌, 把癞子牌剔除
            local stThirdDelCards = {}
            for k, v in ipairs(tempthirdCards) do
                if tempthirdIndex[k] == nil then
                    table.insert(stThirdDelCards, v)
                end
            end
            --去除尾墩后剩余的牌的数量
            local thirdLeftCards = Array.Clone(normalCards)
            -- LOG_DEBUG("=======================thirdLeftCards1111:%s", vardump(thirdLeftCards))
            Array.DelElements(thirdLeftCards, stThirdDelCards)

            ----2.中墩
            local bSecFind, secondAllResult = self:Get_Five_Cards_Laizi(thirdLeftCards, thirdLeftLaizi, 2)
            -- LOG_DEBUG("SetRecommandLaizi.........bSecFind:%s, secondAllResult:%s\n", tostring(bSecFind), vardump(secondAllResult))

            for _, secondResult in ipairs(secondAllResult) do
                for _, sec in ipairs(secondResult) do
                    local tempSecCards = sec.card
                    local tempSecIndex = sec.index

                    --剩余的癞子牌
                    local nSecUsedLaizi = 0
                    for _, v in pairs(tempSecIndex) do
                        nSecUsedLaizi = nSecUsedLaizi + 1
                    end
                    local secondLeftLaizi = thirdLeftLaizi - nSecUsedLaizi

                    --需要移除的牌, 把癞子牌剔除
                    local stSecDelCards = {}
                    for k, v in ipairs(tempSecCards) do
                        if tempSecIndex[k] == nil then
                            table.insert(stSecDelCards, v)
                        end
                    end
                    --去除中墩后剩余的牌的数量
                    local secondLeftCards = Array.Clone(thirdLeftCards)
                    Array.DelElements(secondLeftCards, stSecDelCards)

                    ----3.前墩
                    local bFirstFind, firstAllResult = self:Get_Three_Cards_Laizi(secondLeftCards, secondLeftLaizi, 1)
                    -- LOG_DEBUG("SetRecommandLaizi.........bFirstFind:%s, firstAllResult:%s\n", tostring(bFirstFind), vardump(firstAllResult))
                    for _, firstResult in ipairs(firstAllResult) do
                        for _, fir in ipairs(firstResult) do
                            local tempFirstCards = fir.card
                            local tempFirstIndex = fir.index

                            --需要移除的牌, 把癞子牌剔除
                            local stFirstDelCards = {}
                            for k, v in ipairs(tempFirstCards) do
                                if tempFirstIndex[k] == nil then
                                    table.insert(stFirstDelCards, v)
                                end
                            end
                            --去除前墩后剩余的牌的数量
                            local firstLeftCards = Array.Clone(secondLeftCards)
                            Array.DelElements(firstLeftCards, stFirstDelCards)

                            --组合成的牌型
                            local firstCards, secondCards, thirdCards = {}, {}, {}

                            --第三墩  把鬼牌换上
                            local stthirdLaiziCards = Array.Clone(stLaiziCards)
                            for k, v in ipairs(tempthirdCards) do
                                if tempthirdIndex[k] and #stthirdLaiziCards > 0 then
                                    local nLaiziCard = table.remove(stthirdLaiziCards)
                                    table.insert(thirdCards, nLaiziCard)
                                else
                                    table.insert(thirdCards, v)
                                end
                            end
                            --第二墩  把鬼牌换上
                            for k, v in ipairs(tempSecCards) do
                                if tempSecIndex[k] and #stthirdLaiziCards > 0 then
                                    local nLaiziCard = table.remove(stthirdLaiziCards)
                                    table.insert(secondCards, nLaiziCard)
                                else
                                    table.insert(secondCards, v)
                                end
                            end
                            --第一墩  把鬼牌换上
                            for k, v in ipairs(tempFirstCards) do
                                if tempFirstIndex[k] and #stthirdLaiziCards > 0 then
                                    local nLaiziCard = table.remove(stthirdLaiziCards)
                                    table.insert(firstCards, nLaiziCard)
                                else
                                    table.insert(firstCards, v)
                                end
                            end

                            --记得把剩余的鬼牌也加上 防止少牌
                            for _, v in pairs(stthirdLaiziCards) do
                                table.insert(firstLeftCards, v)
                            end

                            local bContinuCheck = true
                            ---补充牌 使其成牌
                            for i=1, 5-#tempthirdCards do
                                if #firstLeftCards > 0 then
                                    local nCard = table.remove(firstLeftCards)
                                    table.insert(thirdCards, nCard)
                                end
                            end
                            for i=1, 5-#tempSecCards do
                                if #firstLeftCards > 0 then 
                                    local nCard = table.remove(firstLeftCards)
                                    table.insert(secondCards, nCard)
                                end
                            end
                            for i=1, 3-#tempFirstCards do
                                if #firstLeftCards > 0 then
                                    local nCard = table.remove(firstLeftCards)
                                    table.insert(firstCards, nCard)
                                end
                            end
                            if #firstCards ~= 3 or #secondCards ~= 5 or #thirdCards ~= 5 then
                                bContinuCheck = false
                            end

                            if bContinuCheck then
                                --
                                local bSuc1, firstType, values1 = LibNormalCardLogic:GetCardTypeByLaizi(firstCards)
                                local bSuc2, secondType, values2 = LibNormalCardLogic:GetCardTypeByLaizi(secondCards)
                                local bSuc3, thirdType, values3 = LibNormalCardLogic:GetCardTypeByLaizi(thirdCards)
                                --判断相公  相公则交换牌
                                local nXianggongCount = 0
                                if LibNormalCardLogic:CompareCardsLaizi(firstType, secondType, values1, values2) > 0 then
                                    nXianggongCount = nXianggongCount + 1
                                    local temp1 = Array.Clone(firstCards)
                                    local temp2 = Array.Clone(secondCards)
                                    firstCards[1] = temp2[1]
                                    firstCards[2] = temp2[2]
                                    firstCards[3] = temp2[3]
                                    secondCards[1] = temp1[1]
                                    secondCards[2] = temp1[2]
                                    secondCards[3] = temp1[3]
                                end
                                if LibNormalCardLogic:CompareCardsLaizi(secondType, thirdType, values2, values3) > 0 then
                                    nXianggongCount = nXianggongCount + 1
                                    local temp2 = Array.Clone(secondCards)
                                    local temp3 = Array.Clone(thirdCards)
                                    secondCards[1] = temp3[1]
                                    secondCards[2] = temp3[2]
                                    secondCards[3] = temp3[3]
                                    secondCards[4] = temp3[4]
                                    secondCards[5] = temp3[5]
                                    thirdCards[1] = temp2[1]
                                    thirdCards[2] = temp2[2]
                                    thirdCards[3] = temp2[3]
                                    thirdCards[4] = temp2[4]
                                    thirdCards[5] = temp2[5]
                                end
                                if LibNormalCardLogic:CompareCardsLaizi(firstType, thirdType, values1, values3) > 0 then
                                    nXianggongCount = nXianggongCount + 1
                                    local temp1 = Array.Clone(firstCards)
                                    local temp3 = Array.Clone(thirdCards)
                                    firstCards[1] = temp3[1]
                                    firstCards[2] = temp3[2]
                                    firstCards[3] = temp3[3]
                                    thirdCards[1] = temp1[1]
                                    thirdCards[2] = temp1[2]
                                    thirdCards[3] = temp1[3]
                                end
                                --重新获取一遍
                                bSuc1, firstType, values1 = LibNormalCardLogic:GetCardTypeByLaizi(firstCards)
                                bSuc2, secondType, values2 = LibNormalCardLogic:GetCardTypeByLaizi(secondCards)
                                bSuc3, thirdType, values3 = LibNormalCardLogic:GetCardTypeByLaizi(thirdCards)

                                --需要重新再比一次  防止换牌后还有相公
                                local bXianggong = false
                                if nXianggongCount > 0 then
                                    if LibNormalCardLogic:CompareCardsLaizi(firstType, secondType, values1, values2) > 0 then
                                        bXianggong = true
                                    end
                                    if bXianggong == false and LibNormalCardLogic:CompareCardsLaizi(secondType, thirdType, values2, values3) > 0 then
                                        bXianggong = true
                                    end
                                    if bXianggong == false and LibNormalCardLogic:CompareCardsLaizi(firstType, thirdType, values1, values3) > 0 then
                                        bXianggong = true
                                    end
                                end

                                if bXianggong == false then
                                    --最后形成的推荐牌
                                    local stCards = {}
                                    for _, v in ipairs(thirdCards) do
                                        table.insert(stCards, v)
                                    end
                                    for _, v in ipairs(secondCards) do
                                        table.insert(stCards, v)
                                    end
                                    for _, v in ipairs(firstCards) do
                                        table.insert(stCards, v)
                                    end

                                    ---判断牌是否正确
                                    if #stCards ~= #cards or Array.IsSubSet(stCards, cards) == false then
                                        -- LOG_DEBUG("=============ERROR==========SrcCards:%s\n, DestCards:%s", vardump(cards), vardump(stCards))
                                    else
                                        local stTypes = {thirdType, secondType, firstType}
                                        local stValues = {values3, values2, values1}
                                        local stFinds = { Cards = stCards, Types = stTypes, Values = stValues }
                                        
                                        if firstType >= GStars_Normal_Type.PT_TWO_GHOST then
                                            --头墩冲三或以上
                                            table.insert(recommend_cards_first, stFinds)
                                        -- elseif secondType >= GStars_Normal_Type.PT_FOUR then
                                        --     --中墩铁枝或以上
                                        --     table.insert(recommend_cards_second, stFinds)
                                        else
                                            --普通
                                            table.insert(recommend_cards, stFinds)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- LOG_DEBUG("SetRecommandLaizi..........recommend_cards：%s", vardump(recommend_cards))
    -- LOG_DEBUG("libRecomand:SetRecommandLaizi.......#recommend_cards: %d", #recommend_cards)
    --先按牌型排序
    if #recommend_cards_first > 1 then
        table.sort(recommend_cards_first, function(a, b)
            --(尾墩/头墩/中墩 比较)
            if a.Types[3] == b.Types[3] then
                if a.Types[1] == b.Types[1] then
                    if a.Types[2] == b.Types[2] then
                        local bRet = LibNormalCardLogic:CompareCardsLaizi_other(a.Types[1], b.Types[1], a.Values[1], b.Values[1])
                        if bRet == 0 then
                            bRet = LibNormalCardLogic:CompareCardsLaizi_other(a.Types[2], b.Types[2], a.Values[2], b.Values[2])
                        end
                        if bRet == 0 then
                            bRet = LibNormalCardLogic:CompareCardsLaizi_other(a.Types[3], b.Types[3], a.Values[3], b.Values[3])
                        end
                        return bRet > 0
                    else
                        local comp1 = GetGStarsNormalCompare(a.Types[2])
                        local comp2 = GetGStarsNormalCompare(b.Types[2])
                        return comp1 > comp2
                    end 
                else
                    local comp1 = GetGStarsNormalCompare(a.Types[1])
                    local comp2 = GetGStarsNormalCompare(b.Types[1])
                    return comp1 > comp2
                end
            else
                local comp1 = GetGStarsNormalCompare(a.Types[3])
                local comp2 = GetGStarsNormalCompare(b.Types[3])
                return comp1 > comp2
            end
        end)
    end
    if #recommend_cards_second > 1 then
        table.sort(recommend_cards_second, function(a, b)
            --(中墩/头墩/尾墩 比较)
            if a.Types[2] == b.Types[2] then
                if a.Types[3] == b.Types[3] then
                    if a.Types[1] == b.Types[1] then
                        local bRet = LibNormalCardLogic:CompareCardsLaizi_other(a.Types[3], b.Types[3], a.Values[3], b.Values[3])
                        if bRet == 0 then
                            bRet = LibNormalCardLogic:CompareCardsLaizi_other(a.Types[1], b.Types[1], a.Values[1], b.Values[1])
                        end
                        if bRet == 0 then
                            bRet = LibNormalCardLogic:CompareCardsLaizi_other(a.Types[2], b.Types[2], a.Values[2], b.Values[2])
                        end
                        return bRet > 0
                    else
                        local comp1 = GetGStarsNormalCompare(a.Types[1])
                        local comp2 = GetGStarsNormalCompare(b.Types[1])
                        return comp1 > comp2
                    end 
                else
                    local comp1 = GetGStarsNormalCompare(a.Types[3])
                    local comp2 = GetGStarsNormalCompare(b.Types[3])
                    return comp1 > comp2
                end
            else
                local comp1 = GetGStarsNormalCompare(a.Types[2])
                local comp2 = GetGStarsNormalCompare(b.Types[2])
                return comp1 > comp2
            end
        end)
    end
    if #recommend_cards > 1 then
        table.sort(recommend_cards, function(a, b)
            --(尾墩/中墩/头墩 比较)
            if a.Types[1] == b.Types[1] then
                if a.Types[2] == b.Types[2] then
                    if a.Types[3] == b.Types[3] then
                        local bRet = 0
                        if a.Types[3] > GStars_Normal_Type.PT_SINGLE or b.Types[3] > GStars_Normal_Type.PT_SINGLE then
                            bRet = LibNormalCardLogic:CompareCardsLaizi_other(a.Types[3], b.Types[3], a.Values[3], b.Values[3])
                        end
                        if bRet == 0 then
                            bRet = LibNormalCardLogic:CompareCardsLaizi_other(a.Types[1], b.Types[1], a.Values[1], b.Values[1])
                        end
                        if bRet == 0 then
                            bRet = LibNormalCardLogic:CompareCardsLaizi_other(a.Types[2], b.Types[2], a.Values[2], b.Values[2])
                        end
                        return bRet > 0
                    else
                        local comp1 = GetGStarsNormalCompare(a.Types[3])
                        local comp2 = GetGStarsNormalCompare(b.Types[3])
                        return comp1 > comp2
                    end 
                else
                    local comp1 = GetGStarsNormalCompare(a.Types[2])
                    local comp2 = GetGStarsNormalCompare(b.Types[2])
                    return comp1 > comp2
                end
            else
                local comp1 = GetGStarsNormalCompare(a.Types[1])
                local comp2 = GetGStarsNormalCompare(b.Types[1])
                return comp1 > comp2
            end
        end)
    end

    --过滤掉重复的数据
    local stReturns = {}
    local stHave = {}
    local nFirstCount = 0
    for i=1, #recommend_cards_first do
        local stFinds = recommend_cards_first[i]
        local stTypes = stFinds.Types
        local stValues = stFinds.Values
        local stCards = stFinds.Cards
        
        --三墩牌数据一样
        local str  = "p" .. stTypes[1] .. "p" .. stTypes[2] .. "p" .. stTypes[3]
        if not stHave[str] then
            table.insert(stReturns, stFinds)
            stHave[str] = 1
            nFirstCount = nFirstCount + 1
        end
        if nFirstCount > 1 then
            break
        end
    end

    local nSecondCount = 0
    for i=1, #recommend_cards_second do
        local stFinds = recommend_cards_second[i]
        local stTypes = stFinds.Types
        local stValues = stFinds.Values
        local stCards = stFinds.Cards
        --三墩牌数据一样
        local str  = "p" .. stTypes[1] .. "p" .. stTypes[2] .. "p" .. stTypes[3]
        if not stHave[str] then
            table.insert(stReturns, stFinds)
            stHave[str] = 1
            nSecondCount = nSecondCount + 1
        end
        if nSecondCount >= 1 then
            break
        end
    end
    for i=1, #recommend_cards do
        local stFinds = recommend_cards[i]
        local stTypes = stFinds.Types
        local stValues = stFinds.Values
        local stCards = stFinds.Cards
        --三墩牌数据一样
        local str  = "p" .. stTypes[1] .. "p" .. stTypes[2] .. "p" .. stTypes[3]
        if not stHave[str] then
            table.insert(stReturns, stFinds)
            stHave[str] = 1
        end
        --最多显示5个就够了
        if #stReturns >= 5 then
            return stReturns
        end
    end

    return stReturns
end


--===============================================================
--下面是获取尾中前三墩牌的接口
--[[
接口的参数一样:function libRecomand:xxx(cards, nLaziCount)
参数说明：
cards：玩家手上除了癞子牌剩余的牌
nLaziCount：剩余的癞子数量

返回值说明：
bFind：是否找到相应的牌型 false没有 true有
stAllCardTypes：保存找到的牌型牌数据 格式如下
stAllCardTypes = 
{
    result,
    result,
    result,
    ...
}


result格式：
{
    {
        card = {1,2,3...}, --最多5张 最少2张
        index = {[2]=2, [4]=4 } --[位置]=位置 保存癞子牌在card的位置
    },
    ....
}
--]]
--===============================================================
--获取能组成5张牌的所有牌型 nWhat:3后墩 2中墩 1前墩
function libRecomand:Get_Five_Cards_Laizi(cards, nLaziCount, nWhat)
    local copyCards = Array.Clone(cards)
    LibNormalCardLogic:Sort(copyCards)

    local stOrders = {
        GStars_Normal_Type.PT_FIVE,
        GStars_Normal_Type.PT_STRAIGHT_FLUSH,
        GStars_Normal_Type.PT_FOUR,
        GStars_Normal_Type.PT_FULL_HOUSE,
        GStars_Normal_Type.PT_FLUSH,
        GStars_Normal_Type.PT_STRAIGHT,
        GStars_Normal_Type.PT_THREE,
        GStars_Normal_Type.PT_TWO_PAIR,
        GStars_Normal_Type.PT_ONE_PAIR,
    }
    --从大到小
    table.sort(stOrders, function(a, b)
        local comp1 = GetGStarsNormalCompare(a)
        local comp2 = GetGStarsNormalCompare(b)
        return comp1 > comp2       
    end)

    local stAllCardTypes = {}
    local nTotal = 0
    local nCheckMax = 4  --最多找N个推荐牌型，好处是减少计算量,不好的地方就是有可能不是最优的
    for _, nCardType in ipairs(stOrders) do
        local tempCards = Array.Clone(copyCards)
        local bFind = false
        local result = {}

        if nCardType == GStars_Normal_Type.PT_FIVE then
            bFind, result = self:Get_Pt_Five_Laizi(tempCards, nLaziCount, nWhat)

        elseif nCardType == GStars_Normal_Type.PT_STRAIGHT_FLUSH then
            bFind, result = self:Get_Pt_Straight_Flush_Laizi(tempCards, nLaziCount, nWhat)

        elseif nCardType == GStars_Normal_Type.PT_FOUR then
            bFind, result = self:Get_Pt_Four_Laizi(tempCards, nLaziCount, nWhat)

        elseif nCardType == GStars_Normal_Type.PT_FULL_HOUSE then
            bFind, result = self:Get_Pt_Full_Hosue_Laizi(tempCards, nLaziCount, nWhat)

        elseif nCardType == GStars_Normal_Type.PT_FLUSH then
            bFind, result = self:Get_Pt_Flush_Laizi(tempCards, nLaziCount, nWhat)

        elseif nCardType == GStars_Normal_Type.PT_STRAIGHT then
            bFind, result = self:Get_Pt_Straight_Laizi(tempCards, nLaziCount, nWhat)

        elseif nCardType == GStars_Normal_Type.PT_THREE then
            bFind, result = self:Get_Pt_Three_Laizi(tempCards, nLaziCount, nWhat)

        elseif nCardType == GStars_Normal_Type.PT_TWO_PAIR then
            bFind, result = self:Get_Pt_Two_Pair_Laizi(tempCards, nLaziCount, nWhat)

        elseif nCardType == GStars_Normal_Type.PT_ONE_PAIR then
            bFind, result = self:Get_Pt_One_Pair_Laizi(tempCards, nLaziCount, nWhat)
        end

        if bFind then
            table.insert(stAllCardTypes, result)
            nTotal = nTotal + #result
        end
        if nWhat > 1  and nTotal >= nCheckMax then
            return true, stAllCardTypes
        end
    end

    if #stAllCardTypes == 0 then
        local tempCards = Array.Clone(copyCards)
        --散牌5张
        local result = {}
        local temp = {}
        local index = {}

        if nLaziCount >= 5 then
            table.insert(temp, 0x5F)
            table.insert(temp, 0x5F)
            table.insert(temp, 0x5F)
            table.insert(temp, 0x5F)
            table.insert(temp, 0x5F)

            index[1] = 1
            index[2] = 2
            index[3] = 3
            index[4] = 4
            index[5] = 5
        elseif nLaziCount == 2 then
            table.insert(temp, tempCards[#tempCards])
            table.insert(temp, tempCards[#tempCards])
            table.insert(temp, tempCards[#tempCards])
            index[2] = 2
            index[3] = 3
        elseif nLaziCount == 1 then
            table.insert(temp, tempCards[#tempCards])
            table.insert(temp, tempCards[#tempCards])
            index[2] = 2
        else
            table.insert(temp, tempCards[#tempCards])
            table.insert(temp, tempCards[#tempCards-1])
            table.insert(temp, tempCards[#tempCards-2])
            table.insert(temp, tempCards[#tempCards-3])
            table.insert(temp, tempCards[#tempCards-4])
        end
        table.insert(result, { card = temp, index = index })

        table.insert(stAllCardTypes, result)
    end

    return true, stAllCardTypes
end

--获取能组成3张牌的所有牌型 nWhat:3后墩 2中墩 1前墩
function libRecomand:Get_Three_Cards_Laizi(cards, nLaziCount, nWhat)
    local copyCards = Array.Clone(cards)
    LibNormalCardLogic:Sort(copyCards)

    local tempCards = Array.Clone(copyCards)
    local stAllCardTypes = {}

    local bFind, result = self:Get_Pt_Three_Laizi(tempCards, nLaziCount, nWhat)
    if bFind then
        table.insert(stAllCardTypes, result)
    end

    tempCards = Array.Clone(copyCards)
    bFind, result = self:Get_Pt_One_Pair_Laizi(tempCards, nLaziCount, nWhat)
    if bFind then
        -- LOG_DEBUG("11111=======Get_Three_Cards_Laizi:%s", vardump(result))
        if nLaziCount >= 1 then
            table.insert(result[1].card, result[1].card[1])
            result[1].index[3] = 3
        end
        -- LOG_DEBUG("2222=======Get_Three_Cards_Laizi:%s", vardump(result.card))
        table.insert(stAllCardTypes, result)
    end

    if #stAllCardTypes == 0 then
        tempCards = Array.Clone(copyCards)
        --散牌
        local result = {}
        local temp = {}
        local index = {}

        if nLaziCount == 3 then
            table.insert(temp, 0x5F)
            table.insert(temp, 0x5F)
            table.insert(temp, 0x5F)

            index[1] = 1
            index[2] = 2
            index[3] = 3
        elseif nLaziCount == 2 then
            table.insert(temp, tempCards[#tempCards])
            table.insert(temp, tempCards[#tempCards])
            table.insert(temp, tempCards[#tempCards])
            index[2] = 2
            index[3] = 3
        elseif nLaziCount == 1 then
            table.insert(temp, tempCards[#tempCards])
            table.insert(temp, tempCards[#tempCards])
            index[2] = 2
        else
            table.insert(temp, tempCards[#tempCards])
            table.insert(temp, tempCards[#tempCards-1])
            table.insert(temp, tempCards[#tempCards-2])
        end
        table.insert(result, { card = temp, index = index })

        -- LOG_DEBUG("========#index:%d", #index)
        -- for k, v in pairs(index) do
        --     LOG_DEBUG("xxxxxxxxxxxxx%d---%d", k, v)
        -- end

        table.insert(stAllCardTypes, result)
    end


    return true, stAllCardTypes
end



--==============================================================
--下面是获取具体牌牌型算法
--[[
所有算法参数一样function libRecomand:xxx(cards, nLaziCount)
参数说明：
cards：玩家手上除了癞子牌剩余的牌
nLaziCount：剩余的癞子数量

返回值参数说明function libRecomand:xxx(cards, nLaziCount)  returne bFind, result  end
bFind：是否找到相应的牌型 false没有 true有
result：保存找到的牌型牌数据 格式如下
result = 
{
    {
        card = {1,2,3...}, --最多5张 最少2张
        index = {[2]=2, [4]=4 } --[位置]=位置 保存癞子牌在card的位置
    },
    ....
}
--]]
--==============================================================
--5同  +鬼牌把所有的能组成的5同都找出来了
function libRecomand:Get_Pt_Five_Laizi(cards, nLaziCount, nWhat)
    local result = {} ---result = {{card={1,2,3,4,5}, index={2,3}}, ...}
    local bFind = false
    if LibNormalCardLogic:IsSubport23Rule() then
        for i=5, 5-nLaziCount, -1 do
            if i <= 0 then
                break
            end
            local bSuc, t = self:Get_Same_Poker(cards, i)
            if bSuc then
                --取所有三条
                for j=#t, 1, -1 do
                    local tempCards = {}
                    local index = {}
                    local nV = 0

                    for _, v in ipairs(t[j]) do
                        nV = GetCardValue(v)
                        table.insert(tempCards, v)
                    end
                    --222 333
                    if LibNormalCardLogic:IsValue23Rule(nV) then
                        for k=1, 5-i do
                            table.insert(tempCards, tempCards[1])
                            index[#tempCards] = #tempCards
                        end
                        bFind = true
                        table.insert(result, { card = tempCards, index = index })
                    end
                end
                --找一次就行  不需要找全部
                if bFind then
                    break
                end            
            end
        end
    end

    for i=5, 5-nLaziCount, -1 do
        if i <= 0 then
            break
        end
        local bSuc, t = self:Get_Same_Poker(cards, i)
        if bSuc then
            for _, st in ipairs(t) do
                local tempCards = {}
                local index = {}
                local nV = 0
                for _, v in ipairs(st) do
                    nV = GetCardValue(v)
                    table.insert(tempCards, v)
                end
                --222333
                if not LibNormalCardLogic:IsValue23Rule(nV) then
                    for k=1, 5-i do
                        table.insert(tempCards, tempCards[1])
                        index[#tempCards] = #tempCards
                    end
                    bFind = true
                    table.insert(result, { card = tempCards, index = index })
                end
            end
            --找一次就行  不需要找全部
            if bFind then
                break
            end
        end
    end

    if bFind == false then
        --222 333
        if LibNormalCardLogic:IsSubport23Rule() then
            for i=4, 4-nLaziCount, -1 do
                if i <= 0 then
                    break
                end
                local bSuc, t = self:Get_Same_Poker(cards, i)
                if bSuc then
                    --取所有三条
                    for j=#t, 1, -1 do
                        local tempCards = {}
                        local index = {}
                        local nV = 0

                        for _, v in ipairs(t[j]) do
                            nV = GetCardValue(v)
                            table.insert(tempCards, v)
                        end
                        --222 333
                        if LibNormalCardLogic:IsValue23Rule(nV) then
                            for k=1, 4-i do
                                table.insert(tempCards, tempCards[1])
                                index[#tempCards] = #tempCards
                            end
                            bFind = true
                            table.insert(result, { card = tempCards, index = index })
                        end
                    end
                    --找一次就行  不需要找全部
                    if bFind then
                        break
                    end            
                end
            end
        end 
    end

    return bFind, result
end

--同花顺 +鬼牌把所有的能组成的同花顺都找出来了
function libRecomand:Get_Pt_Straight_Flush_Laizi(cards, nLaziCount, nWhat)
    local flush = {}
    --按花色分组:0-3
    LibNormalCardLogic:Sort_By_Color(cards)
    for _, v in ipairs(cards) do
        local color = GetCardColor(v)
        if not flush[color] then
            flush[color] = {}
        end
        table.insert(flush[color], v)
    end

    local result = {}
    local bFind = false
    for color, hash in pairs(flush) do
        if #hash > 0 then
            if #hash + nLaziCount >= 5 then
                local values = {}
                for i=1, 14 do
                    values[i] = 0
                end
                for _, v in ipairs(hash) do
                    local val = GetCardValue(v)
                    values[val] = values[val] + 1
                end
                values[1] = values[14]

                local stHave = {} --防止重复
                for i=1, 10 do
                    local values2 = Array.Clone(values)
                    local straight = true
                    local tempLaizi = nLaziCount

                    local tempCards = {}
                    local index = {}
                    for j=1, 5 do
                        if values2[i+j-1] == 0 then
                            if tempLaizi <= 0 then
                                straight = false
                                break
                            else
                                tempLaizi = tempLaizi -1
                                index[j] = j
                            end
                        end
                    end
                    --是顺子
                    if straight then
                        if not stHave[i] then
                            stHave[i] = i

                            for k=1, 5 do
                                --数量-1 防止重用
                                local nv = i+k-1
                                if nv == 1 then
                                    nv = 14
                                end
                                local nCard = GetCardByColorValue(color, nv)
                                table.insert(tempCards, nCard)
                            end

                            bFind = true
                            --最大的放前面
                            if i == 10 then
                                table.insert(result, 1, { card = tempCards, index = index })
                            else
                               table.insert(result, { card = tempCards, index = index }) 
                            end
                        end
                    end
                end
            end
        end
        --顺子太多会卡 只找一部分就行
        if #result >= 10 then
            break
        end
    end

    return bFind, result
end

--4条 +鬼牌把所有的能组成的4条都找出来了
function libRecomand:Get_Pt_Four_Laizi(cards, nLaziCount, nWhat)
    ---result = {{card={1,2,3,4,5}, index={2,3}}, ...}
    local result = {}
    local bFind = false
    for i=4, 4-nLaziCount, -1 do
        if i <= 0 then
            break
        end
        local bSuc, t = self:Get_Same_Poker(cards, i)
        if bSuc then
            for _, st in ipairs(t) do
                local tempCards = {}
                local index = {}
                local nV = 0
                --取最大一个
                for _, v in ipairs(st) do
                    nV = GetCardValue(v)
                    table.insert(tempCards, v)
                end
                --不用2222/3333
                -- if not LibNormalCardLogic:IsValue23Rule(nV) then
                    for k=1, 4-i do
                        table.insert(tempCards, tempCards[1])
                        index[#tempCards] = #tempCards
                    end
                    bFind = true
                    table.insert(result, { card = tempCards, index = index })
                -- end
            end
            --找一次就行  不需要找全部
            if bFind then
                break
            end
        end
    end

    if bFind == false then
        --222 333
        if LibNormalCardLogic:IsSubport23Rule() then
            for i=3, 3-nLaziCount, -1 do
                if i <= 0 then
                    break
                end
                local bSuc, t = self:Get_Same_Poker(cards, i)
                if bSuc then
                    --取所有三条
                    for j=#t, 1, -1 do
                        local tempCards = {}
                        local index = {}
                        local nV = 0

                        for _, v in ipairs(t[j]) do
                            nV = GetCardValue(v)
                            table.insert(tempCards, v)
                        end
                        --222 333
                        if LibNormalCardLogic:IsValue23Rule(nV) then
                            for k=1, 3-i do
                                table.insert(tempCards, tempCards[1])
                                index[#tempCards] = #tempCards
                            end
                            bFind = true
                            table.insert(result, { card = tempCards, index = index })
                        end
                    end
                    --找一次就行  不需要找全部
                    if bFind then
                        break
                    end            
                end
            end
        end        
    end

    return bFind, result
end

--葫芦 +鬼牌
function libRecomand:Get_Pt_Full_Hosue_Laizi(cards, nLaziCount, nWhat)
    local result = {}
    local bFind = false

    local bSuc3, t3 = self:Get_Same_Poker(cards, 3)
    if bSuc3 then
        local bSuc2, t2 = self:Get_Same_Poker(cards, 2)
        if bSuc2 then
            for _, v3 in ipairs(t3) do
                local tempCards = {}
                local nV = 0
                for _, nc in ipairs(v3) do
                    nV = GetCardValue(nc)
                    table.insert(tempCards, nc)
                end
                --222/333 不用搞葫芦  搞三条就可以了
                -- if not LibNormalCardLogic:IsValue23Rule(nV) then
                    for _, v2 in ipairs(t2) do
                        local copyCards = Array.Clone(tempCards)
                        for _, nc in ipairs(v2) do
                            table.insert(copyCards, nc)
                        end
                        table.insert(result, { card = copyCards, index = {} })
                    end
                    bFind = true
                -- end
            end
        end
    end

    --再用癞子找
    if bFind == false and nLaziCount > 0 then
        local bSuc, t = self:Get_Same_Poker(cards, 2)
        if bSuc and #t > 1 and nLaziCount > 0 then
            for i=#t, 2, -1 do
                local tempCards = {}
                local index = {}
                local nV = 0
                for _, v in ipairs(t[i]) do
                    nV = GetCardValue(v)
                    table.insert(tempCards, v)
                end
                --加一张鬼牌
                table.insert(tempCards, tempCards[1])
                index[#tempCards] = #tempCards
                --222/333 不用加对子
                -- if not LibNormalCardLogic:IsValue23Rule(nV) then
                    for j=1, i-1 do
                        local copyCards = Array.Clone(tempCards)
                        local nV2 = GetCardValue(t[j][1])
                        if nV2 ~= 2 and nV2 ~= 3 then
                            for _, v in ipairs(t[j]) do
                                table.insert(copyCards, v)
                            end
                            table.insert(result, { card = copyCards, index = index })
                            bFind = true
                        end 
                    end
                -- end
            end
        end
    end

    return bFind, result
end

--同花 +鬼牌把部分的能组成的同花都找出来了
function libRecomand:Get_Pt_Flush_Laizi(cards, nLaziCount, nWhat)
    local flush = {}
    --按花色分组:0-3
    LibNormalCardLogic:Sort_By_Color(cards)
    for k, v in ipairs(cards) do
        local color = GetCardColor(v)
        if not flush[color] then
            flush[color] = {}
        end
        table.insert(flush[color], v)
    end

    local result = {}
    local bFind = false
    for j, v in pairs(flush) do
        local tempLaizi = nLaziCount
        if #v > 0 then
            if #v >= 5 then
                for i=1, #v-4 do
                    local tempCards = {}
                    for k=1, 5 do
                        table.insert(tempCards, v[i+k-1])
                    end
                    local copyCards = Array.Clone(tempCards)
                    if LibNormalCardLogic:IsStraight(copyCards) == false then
                        bFind = true
                        table.insert(result, { card = tempCards, index = {} })
                    end 
                end
            elseif #v + tempLaizi >= 5 then
                --癞子补   对同花
                local tempCards = {}
                local index = {}
                local bSave = false

                for k=1, #v do
                    table.insert(tempCards, v[k])
                end

                local nUniq = LibNormalCardLogic:Uniqc(v)
                if nUniq == 3 then
                    if #v == 3 then
                        table.insert(tempCards, v[#v])
                        index[#tempCards] = #tempCards

                        table.insert(tempCards, v[#v-1])
                        index[#tempCards] = #tempCards
                        bSave = true
                    elseif #v == 4 then
                        --单牌最大的那个
                        local nc = 0
                        if v[3] == v[4] then
                            nc = v[2]
                        else
                            nc = v[4]
                        end
                        table.insert(tempCards, nc)
                        index[#tempCards] = #tempCards
                        bSave = true
                    end
                elseif nUniq == 4 then
                    table.insert(tempCards, v[#v])
                    index[#tempCards] = #tempCards
                    bSave = true
                end
                --因为有对同花在  所以分不清楚 谁大谁小
                if bSave then
                    bFind = true
                    table.insert(result, { card = tempCards, index = index })
                end
            end
        end
        --同花太多会卡 只找一部分就行
        if #result >= 10 then
            break
        end
    end

    return bFind, result
end

--顺子 +鬼牌把所有的能组成的顺子都找出来了
function libRecomand:Get_Pt_Straight_Laizi(cards, nLaziCount, nWhat)
    --设置各个牌值的数量
    local values = {}   --[牌值]=数量
    for i=1, 14 do
        values[i] = 0
    end

    local stColors = {}
    local nColor = 0
    for _, v in ipairs(cards) do
        local val = GetCardValue(v)
        nColor = GetCardColor(v)
        if stColors[val] == nil then
            stColors[val] = {}
        end
        table.insert(stColors[val], v)
        values[val] = values[val] + 1
    end
    values[1] = values[14]

    local result = {}
    local bFind = false

    for i=1, 10 do
        local values2 = Array.Clone(values)
        local stColors2 = clone(stColors)
        local straight = true
        local tempLaizi = nLaziCount

        local tempCards = {}
        local index = {}
        for j=1, 5 do
            if values2[i+j-1] == 0 then
                if tempLaizi <= 0 then
                    straight = false
                    break
                else
                    values2[i+j-1] = 1
                    tempLaizi = tempLaizi -1
                    index[j] = j
                end
            end
        end
        --是顺子
        if straight then
            for k=1, 5 do
                --数量-1 防止重用
                local nv = i+k-1
                values2[nv] = values2[nv] - 1
                if nv == 1 then
                    nv = 14
                end

                local nCard = GetCardByColorValue(nColor, nv)
                if stColors2[nv] then
                    nCard = table.remove(stColors2[nv])
                end
                table.insert(tempCards, nCard)
            end
            --不是同花顺
            if LibNormalCardLogic:IsFlush(tempCards) == false then
                bFind = true
                --最大的放前面
                if i == 10 then
                    table.insert(result, 1, { card = tempCards, index = index })
                else
                   table.insert(result, { card = tempCards, index = index }) 
                end
            end
        end
    end
    return bFind, result
end

--3条
function libRecomand:Get_Pt_Three_Laizi(cards, nLaziCount, nWhat)
    local result = {}
    local bFind = false

    for i=3, 3-nLaziCount, -1 do
        if i <= 0 then
            break
        end
        local bSuc, t = self:Get_Same_Poker(cards, i)
        if bSuc then
            --取所有三条
            for j=#t, 1, -1 do
                local tempCards = {}
                local index = {}
                for _, v in ipairs(t[j]) do
                    table.insert(tempCards, v)
                end
                for k=1, 3-i do
                    table.insert(tempCards, tempCards[1])
                    index[#tempCards] = #tempCards
                end
                bFind = true
                table.insert(result, { card = tempCards, index = index })
            end
            --找一次就行  不需要找全部
            if bFind then
                break
            end            
        end
    end

    --[[
    --正常3条
    local bSuc3, t3 = self:Get_Same_Poker(cards, 3)
    -- LOG_DEBUG("Get_Pt_Three_Laizi11111111111111...bSuc3:%s, t3:%s", tostring(bSuc3), vardump(t3))
    if bSuc3 then
        for _, v3 in ipairs(t3) do
            local tempCards = {}
            for _, nc in ipairs(v3) do
                table.insert(tempCards, nc)
            end
            bFind = true
            table.insert(result, { card = tempCards, index = {} })
        end
    end

    --癞子+对子组合
    if nLaziCount > 0 then
        local bSuc, t = self:Get_Same_Poker(cards, 2)
        -- LOG_DEBUG("Get_Pt_Three_Laizi222222222...bSuc:%s, t:%s", tostring(bSuc), vardump(t))
        if bSuc and #t > 0 and nLaziCount > 0 then
            for _, st in ipairs(t) do
                local tempCards = {}
                local index = {}
                --取最大一个
                for _, v in ipairs(st) do
                    table.insert(tempCards, v)
                end
                --加一张鬼牌
                table.insert(tempCards, tempCards[1])
                index[#tempCards] = #tempCards

                bFind = true
                table.insert(result, { card = tempCards, index = index })
            end
        end
    end
    --]]
    -- LOG_DEBUG("Get_Pt_Three_Laizi...bFind:%s, result:%s", tostring(bFind), vardump(result))
    return bFind, result
end

--2对
function libRecomand:Get_Pt_Two_Pair_Laizi(cards, nLaziCount, nWhat)
    --不考虑癞子  加癞子组成的牌型永远大于两对
    local result = {}
    local bFind = false

    local bSuc, t = self:Get_Same_Poker(cards, 2)
    if bSuc and #t > 1 then
        local bSuc2, t2 = self:Get_Same_Poker(cards, 3)
        if bSuc2 == false then
            --手牌4对时，要这样推荐，第2大的对子在头墩，最大的对子在中墩，剩余2个小对子放尾墩；（有且仅有4对，无其他牌型）
            --手牌5对时，要这样推荐，第1大的对子在头墩，第3、第4大的对子在中墩，第2、第5大的对子在尾墩；（有且仅有5对，无其他牌型）
            --特殊要求处理 后墩
            if nWhat == 3 then
                if #t >= 5 then
                    local tempCards = {}
                    local index = {}
                    --取第二大 + 最小
                    for _, v in ipairs(t[#t-1]) do
                        table.insert(tempCards, v)
                    end
                    for _, v in ipairs(t[1]) do
                        table.insert(tempCards, v)
                    end

                    bFind = true
                    table.insert(result, { card = tempCards, index = index })
                elseif #t >= 3 then
                    local tempCards = {}
                    local index = {}
                    --取第二小 + 最小
                    for _, v in ipairs(t[2]) do
                        table.insert(tempCards, v)
                    end
                    for _, v in ipairs(t[1]) do
                        table.insert(tempCards, v)
                    end

                    bFind = true
                    table.insert(result, { card = tempCards, index = index })
                end
            end
            --特殊要求处理 中墩
            if nWhat == 2 then
                if #t >= 3 then
                    local tempCards = {}
                    local index = {}
                    --取第二大 + 第三大
                    for _, v in ipairs(t[#t-1]) do
                        table.insert(tempCards, v)
                    end
                    for _, v in ipairs(t[#t-2]) do
                        table.insert(tempCards, v)
                    end

                    bFind = true
                    table.insert(result, { card = tempCards, index = index })
                elseif #t >= 2 then
                    local tempCards = {}
                    local index = {}
                    --取最大的对子在中墩
                    for _, v in ipairs(t[#t]) do
                        table.insert(tempCards, v)
                    end

                    bFind = true
                    table.insert(result, { card = tempCards, index = index })
                end
            end
        end

        --如果没有特殊处理, 就按正常流程处理
        if bFind == false then
            for k3, v3 in ipairs(t) do
                local tempCards = {}
                for _, nc in ipairs(v3) do
                    table.insert(tempCards, nc)
                end
                --
                for k2, v2 in ipairs(t) do
                    if k3 ~= k2 then
                        local copyCards = Array.Clone(tempCards)
                        for _, nc in ipairs(v2) do
                            table.insert(copyCards, nc)
                        end
                        table.insert(result, { card = copyCards, index = {} })
                        bFind = true
                    end
                end
            end
        end
    end

    return bFind, result
end

--1对
function libRecomand:Get_Pt_One_Pair_Laizi(cards, nLaziCount, nWhat)
    --不考虑癞子 加癞子组成的牌型永远大于1对
    local result ={}
    local bFind = false

    local bSuc, t = self:Get_Same_Poker(cards, 2)
    if bSuc and #t > 0 and #t <= 3 then
        for _, v in ipairs(t) do
            local tempCards = {}
            for _, nc in ipairs(v) do
                table.insert(tempCards, nc)
            end
            table.insert(result, { card = tempCards, index = {} })
            bFind = true 
        end
    end

    return bFind, result
end


--=============================================================
---------前段摆牌使用接口------------

--6同
function libRecomand:Get_Pt_Six_Laizi_second(cards, nLaziCount)
    local result = {} ---result = {{card={1,2,3,4,5}, index={2,3}}, ...}
    local bFind = false
    local copyCards = {}
    if LibNormalCardLogic:IsSubport23Rule() then
        for _, v in pairs(cards) do
            local nValue = GetCardValue(v)
            --222 333
            if LibNormalCardLogic:IsValue23Rule(nValue) then
                table.insert(copyCards, v)
            end
        end
        if #copyCards > 0 then
            LibNormalCardLogic:Sort(copyCards)
            for i=5, 5-nLaziCount, -1 do
                if i <= 0 then
                    break
                end
                local bSuc, t = self:Get_Same_nCard_Split(copyCards, i)
                if bSuc then
                    --取最大一个
                    for j=#t, 1, -1 do
                        local tempCards = {}
                        local index = {}
                        for _, v in ipairs(t[j]) do
                            table.insert(tempCards, v)
                        end
                        for k=1, 5-i do
                            table.insert(tempCards, 0)
                            index[#tempCards] = #tempCards
                        end
                        
                        bFind = true
                        table.insert(result, { card = tempCards, index = index })
                    end
                end
            end
        end

        --把全是癞子的牌也加上
        if nLaziCount >= 5 then
            bFind = true
            local tempCards = {0,0,0,0,0}
            local index = {1,2,3,4,5}
            table.insert(result, { card = tempCards, index = index })
        end
    end

    return bFind, result
end

--5同  +鬼牌把所有的能组成的5同都找出来了
function libRecomand:Get_Pt_Five_Laizi_second(cards, nLaziCount)
    local result = {} ---result = {{card={1,2,3,4,5}, index={2,3}}, ...}
    local bFind = false
    local copy23Cards = {}
    local copyCards = {}
    for _, v in pairs(cards) do
        local nValue = GetCardValue(v)
        --222 333
        if LibNormalCardLogic:IsValue23Rule(nValue) then
            table.insert(copy23Cards, v)
        else
            table.insert(copyCards, v)
        end
    end
    LibNormalCardLogic:Sort(copy23Cards)
    LibNormalCardLogic:Sort(copyCards)

    --2222/3333
    if #copy23Cards > 0 then
        for i=4, 4-nLaziCount, -1 do
            if i <= 0 then
                break
            end
            local bSuc, t = self:Get_Same_nCard_Split(copy23Cards, i)
            if bSuc then
               for j=#t, 1, -1 do
                    local tempCards = {}
                    local index = {}
                    for _, v in ipairs(t[j]) do
                        table.insert(tempCards, v)
                    end
                    for k=1, 4-i do
                        table.insert(tempCards, 0)
                        index[#tempCards] = #tempCards
                    end
                    
                    bFind = true
                    table.insert(result, { card = tempCards, index = index })
                end
            end 
        end
    end
    --xxxxx
    if #copyCards > 0 then
        for i=5, 5-nLaziCount, -1 do
            if i <= 0 then
                break
            end
            local bSuc, t = self:Get_Same_nCard_Split(copyCards, i)
            if bSuc then
                for j=#t, 1, -1 do
                    local tempCards = {}
                    local index = {}
                    for _, v in ipairs(t[j]) do
                        table.insert(tempCards, v)
                    end
                    for k=1, 5-i do
                        table.insert(tempCards, 0)
                        index[#tempCards] = #tempCards
                    end
                    
                    bFind = true
                    table.insert(result, { card = tempCards, index = index })
                end
            end
        end
    end

    --把全是癞子的牌也加上
    if LibNormalCardLogic:IsSubport23Rule() then
        if nLaziCount >= 4 then
            bFind = true
            local tempCards = {0,0,0,0}
            local index = {1,2,3,4}
            table.insert(result, { card = tempCards, index = index })
        end
    else
        if nLaziCount >= 5 then
            bFind = true
            local tempCards = {0,0,0,0,0}
            local index = {1,2,3,4,5}
            table.insert(result, { card = tempCards, index = index })
        end
    end

    return bFind, result
end

--同花顺 +鬼牌把所有的能组成的同花顺都找出来了
function libRecomand:Get_Pt_Straight_Flush_Laizi_second(cards, nLaziCount)
    local flush = {}
    --按花色分组:0-3
    LibNormalCardLogic:Sort_By_Color(cards)
    for _, v in ipairs(cards) do
        local color = GetCardColor(v)
        if not flush[color] then
            flush[color] = {}
        end
        table.insert(flush[color], v)
    end

    local result = {}
    local bFind = false
    for color, hash in pairs(flush) do
        if #hash > 0 and #hash + nLaziCount >= 5 then
            local values = {}
            for i=1, 14 do
                values[i] = 0
            end
            for _, v in ipairs(hash) do
                local val = GetCardValue(v)
                values[val] = values[val] + 1
            end
            values[1] = values[14]

            local stHaveFind = {}   --防止重复
            for i=1, 10 do
                local values2 = Array.Clone(values)
                local straight = true
                local tempLaizi = nLaziCount

                local tempCards = {}
                local index = {}
                local nUseLaziCount = 0
                local bHave23 = false
                for j=1, 5 do
                    local val = i+j-1
                    if LibNormalCardLogic:IsValue23Rule(val) then
                        bHave23 = true
                    end
                    if values2[val] == 0 then
                        if tempLaizi <= 0 then
                            straight = false
                            break
                        else
                            tempLaizi = tempLaizi -1
                            index[j] = j
                            nUseLaziCount = nUseLaziCount + 1
                        end
                    end
                end
                --是同花顺(4个癞子或以上组合 不会是同花顺)
                if straight and nUseLaziCount < 4 then
                    if bHave23 then
                        nUseLaziCount = nUseLaziCount + 1
                    end
                    if nUseLaziCount >= 4 then
                        break
                    end

                    local sTipsCard = ""    --记得呀 这是按顺子的
                    for k=1, 5 do
                        --数量-1 防止重用
                        local nv = i+k-1
                        if nv == 1 then
                            nv = 14
                        end

                        local nCard = 0
                        if not index[k] then
                            nCard = GetCardByColorValue(color, nv)
                        end
                        table.insert(tempCards, nCard)
                        if nCard > 0 then
                            sTipsCard = sTipsCard .. "p" .. nCard
                        end
                    end
                    if sTipsCard ~= "" and not stHaveFind[sTipsCard] then
                        bFind = true
                        table.insert(result, { card = tempCards, index = index })
                        stHaveFind[sTipsCard] = true
                    end
                end
            end
        end
    end

    return bFind, result
end

--4条 +鬼牌把所有的能组成的4条都找出来了
function libRecomand:Get_Pt_Four_Laizi_second(cards, nLaziCount)
    ---result = {{card={1,2,3,4,5}, index={2,3}}, ...}
    local result = {}
    local bFind = false
    local copy23Cards = {}
    local copyCards = {}
    for _, v in pairs(cards) do
        local nValue = GetCardValue(v)
        --222 333
        if LibNormalCardLogic:IsValue23Rule(nValue) then
            table.insert(copy23Cards, v)
        else
            table.insert(copyCards, v)
        end
    end
    LibNormalCardLogic:Sort(copy23Cards)
    LibNormalCardLogic:Sort(copyCards)

    --222/333
    if #copy23Cards > 0 then
        for i=3, 3-nLaziCount, -1 do
            if i <= 0 then
                break
            end
            local bSuc, t = self:Get_Same_nCard_Split(copy23Cards, i)
            if bSuc then
               for j=#t, 1, -1 do
                    local tempCards = {}
                    local index = {}
                    for _, v in ipairs(t[j]) do
                        table.insert(tempCards, v)
                    end
                    for k=1, 3-i do
                        table.insert(tempCards, 0)
                        index[#tempCards] = #tempCards
                    end
                    
                    bFind = true
                    table.insert(result, { card = tempCards, index = index })
                end
            end 
        end
    end
    --xxxx
    if #copyCards > 0 then
        for i=4, 4-nLaziCount, -1 do
            if i <= 0 then
                break
            end
            local bSuc, t = self:Get_Same_nCard_Split(copyCards, i)
            if bSuc then
               for j=#t, 1, -1 do
                    local tempCards = {}
                    local index = {}
                    for _, v in ipairs(t[j]) do
                        table.insert(tempCards, v)
                    end
                    for k=1, 4-i do
                        table.insert(tempCards, 0)
                        index[#tempCards] = #tempCards
                    end
                    
                    bFind = true
                    table.insert(result, { card = tempCards, index = index })
                end
            end 
        end
    end

    return bFind, result
end

--葫芦 +鬼牌 需要屏蔽222、333
function libRecomand:Get_Pt_Full_Hosue_Laizi_second(cards, nLaziCount)
    local result = {}
    local bFind = false
  
    local bSuc, t = self:Get_Pt_Three_Laizi_second(cards, nLaziCount)
    if bSuc then
        for _, v in ipairs(t) do
            --屏蔽222、333
            local nV = GetCardValue(v.card[1])
            if not LibNormalCardLogic:IsValue23Rule(nV) then
                local copyCards = {}
                local index = {}
                local nUseLaziCount = 0
                for k, nCard in ipairs(v.card) do
                    table.insert(copyCards, nCard)
                    if v.index[k] then
                        index[k] = v.index[k]
                        nUseLaziCount = nUseLaziCount + 1
                    end
                end

                --如果有两张或以上的癞子  就不会组合成葫芦
                if nUseLaziCount < 2 then
                    --对子不能有癞子
                    local bSuc2, t2 = self:Get_Same_nCard_Split(cards, 2)
                    if bSuc2 then
                        for _, v2 in ipairs(t2) do
                            local tempCards = Array.Clone(copyCards)
                            local nV2 = GetCardValue(v2[1])
                            if nV ~= nV2 then
                                local bSave = true
                                if nUseLaziCount > 0 then
                                    --如果三条有癞子，则对子不能有23
                                    if LibNormalCardLogic:IsValue23Rule(nV2) then
                                        bSave = false
                                    end
                                end
                                if bSave then
                                    bFind = true
                                    table.insert(tempCards, v2[1])
                                    table.insert(tempCards, v2[2])

                                    --去掉重复的
                                    local bNotSame = true
                                    for _, res in ipairs(result) do
                                        local arrCopy1 = Array.Clone(tempCards)
                                        local arrCopy2 = Array.Clone(res.card)
                                        Array.DelElements(arrCopy1, arrCopy2)
                                        if #arrCopy1 == 0 then
                                            bNotSame = false
                                            break
                                        end
                                    end
                                    if bNotSame then
                                        table.insert(result, { card = tempCards, index = index })
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return bFind, result
end

--同花 +鬼牌把所有的能组成的同花都找出来了 最多找20个
function libRecomand:Get_Pt_Flush_Laizi_second(cards, nLaziCount)
    local flush = {}
    --按花色分组:0-3
    LibNormalCardLogic:Sort_By_Color(cards)
    for k, v in ipairs(cards) do
        local color = GetCardColor(v)
        if not flush[color] then
            flush[color] = {}
        end
        table.insert(flush[color], v)
    end

    local result = {}
    local bFind = false
    for j, v in pairs(flush) do
        for i=1, nLaziCount do
            table.insert(v, 0)
        end
        --按值从大到小
        self:Sort(v)

        if #v >= 5 then
            for i=1, #v - 4 do
                for h=i+1, #v - 3 do
                    for k=h+1, #v - 2 do
                        for l=k+1, #v - 1 do
                            for m=l+1, #v do
                                local tempCards = {}
                                local index = {}
                                table.insert(tempCards, v[i])
                                table.insert(tempCards, v[h])
                                table.insert(tempCards, v[k])
                                table.insert(tempCards, v[l])
                                table.insert(tempCards, v[m])
                                --鬼牌位置
                                local stStraight = {}
                                local nLaiziCount = 0
                                local stHave23 = {}
                                for i=2, 14 do
                                    stHave23[i] = 0
                                end

                                for key, nCard in ipairs(tempCards) do
                                    if nCard == 0 then
                                        index[key] = key
                                        nLaiziCount = nLaiziCount + 1
                                    else
                                        table.insert(stStraight, nCard)
                                        local val = GetCardValue(nCard)
                                        --222 333
                                        if LibNormalCardLogic:IsValue23Rule(val) then
                                            stHave23[val] = stHave23[val] + 1
                                        end
                                    end
                                end
                                --三个以上鬼牌
                                if nLaiziCount >= 3 then
                                    break                                  
                                end
                                --222/333
                                if #stHave23 > 0 then
                                    local bHave23 = false
                                    for _, count in pairs(stHave23) do
                                        if count + nLaiziCount >= 3 then
                                            bHave23 = true
                                            break
                                        end
                                    end
                                    if bHave23 then
                                        break
                                    end
                                end
                                --同花顺
                                if LibNormalCardLogic:IsStraight_Laizi(stStraight, nLaiziCount) then
                                    break
                                end
                                --大于同花的牌型
                                local one,two,three,four,five = LibNormalCardLogic:GetLarge2SameCard(stStraight)
                                if two + nLaiziCount >= 3 then
                                    break
                                end
                                if three > 0 and nLaiziCount > 0 then
                                    break
                                end
                                if four > 0 or five > 0 then
                                    break
                                end

                                --过滤重复的同花
                                local bSave = true
                                for _, v1 in ipairs(result) do 
                                    local arrCopy = Array.Clone(v1.card)
                                    Array.DelElements(arrCopy, tempCards)
                                    if #arrCopy == 0 then
                                        bSave = false
                                        break
                                    end
                                end
                                if bSave then
                                    bFind = true
                                    table.insert(result, { card = tempCards, index = index })
                                end
                                if #result >= 20 then
                                    return bFind, result
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return bFind, result
end

--顺子 +鬼牌把所有的能组成的顺子都找出来了 最多找20个
function libRecomand:Get_Pt_Straight_Laizi_second(cards, nLaziCount)
    local result = {}
    local bFind = false

    local stColors = {} --[值]={nCard,...}
    for _, v in ipairs(cards) do
        local val = GetCardValue(v)
        if stColors[val] == nil then
            stColors[val] = {}
        end
        table.insert(stColors[val], v)
    end
    if stColors[14] then
        stColors[1] = stColors[14]
    end

    local stHaveFind = {}   --防止重复
    for i=1, 10 do
        local tempLaizi = nLaziCount
        local straight = true
        local index = {}
        local stColors2 = {}
        local nUseLaziCount = 0

        for j=1, 5 do
            local nV = i+j-1
            if stColors[nV] and #stColors[nV] > 0 then
                local temp = {}
                local stHave = {}
                for _, nCard in ipairs(stColors[nV]) do
                    if stHave[nCard] == nil then
                        stHave[nCard] = nCard
                        table.insert(temp, nCard)
                    end
                end
                table.insert(stColors2, temp)
            else
                if tempLaizi <= 0 then
                    straight = false
                    break
                else
                    tempLaizi = tempLaizi -1
                    index[j] = j
                    nUseLaziCount = nUseLaziCount + 1

                    local temp = {0,}
                    table.insert(stColors2, temp)  
                end
            end
        end
        --是顺子（3个或以上癞子组合不会是顺子）
        if straight and nUseLaziCount < 3 then
            for i=1, #stColors2[1] do
                for j=1, #stColors2[2] do
                    for k=1, #stColors2[3] do
                        for m=1, #stColors2[4] do
                            for n=1, #stColors2[5] do
                                --23规则
                                local nv1 = GetCardValue(stColors2[1][i])
                                local nv2 = GetCardValue(stColors2[2][j])
                                local nv3 = GetCardValue(stColors2[3][k])
                                local nv4 = GetCardValue(stColors2[4][m])
                                local nv5 = GetCardValue(stColors2[5][n])
                                if LibNormalCardLogic:IsValue23Rule(nv1)
                                    or LibNormalCardLogic:IsValue23Rule(nv1)
                                    or LibNormalCardLogic:IsValue23Rule(nv2)
                                    or LibNormalCardLogic:IsValue23Rule(nv3)
                                    or LibNormalCardLogic:IsValue23Rule(nv4) then
                                    nUseLaziCount = nUseLaziCount + 1
                                end 

                                if nUseLaziCount < 3 then 
                                    local tempCards = {}
                                    table.insert(tempCards, stColors2[1][i])
                                    table.insert(tempCards, stColors2[2][j])
                                    table.insert(tempCards, stColors2[3][k])
                                    table.insert(tempCards, stColors2[4][m])
                                    table.insert(tempCards, stColors2[5][n])

                                    local sTipsCard = ""
                                    for _, v in ipairs(tempCards) do
                                        if v > 0 then
                                            sTipsCard = sTipsCard .. "p" .. v
                                        end
                                    end

                                    --不是同花顺
                                    if not stHaveFind[sTipsCard] and LibNormalCardLogic:IsFlush(tempCards) == false then
                                        bFind = true
                                        table.insert(result, { card = tempCards, index = index })
                                        stHaveFind[sTipsCard] = true

                                        if #result >= 20 then
                                            return bFind, result
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end    
    end

    return bFind, result
end

--三条 +鬼牌把所有的能组成的三条都找出来
function libRecomand:Get_Pt_Three_Laizi_second(cards, nLaziCount)
    local result = {}
    local bFind = false
    local copyCards = cards
    LibNormalCardLogic:Sort(copyCards)

    for i=3, 3-nLaziCount, -1 do
        if i <= 0 then
            break
        end
        local bSuc, t = self:Get_Same_nCard_Split(copyCards, i)
        if bSuc then
            --取所有三条
            for j=#t, 1, -1 do
                local tempCards = {}
                local index = {}
                for _, v in ipairs(t[j]) do
                    table.insert(tempCards, v)
                end
                for k=1, 3-i do
                    table.insert(tempCards, 0)
                    index[#tempCards] = #tempCards
                end
                bFind = true
                table.insert(result, { card = tempCards, index = index })
            end 
        end
    end

    --把全是癞子的牌也加上
    if nLaziCount >= 3 then
        bFind = true
        local tempCards = {0,0,0}
        local index = {1,2,3}
        table.insert(result, { card = tempCards, index = index })
    end

    return bFind, result
end

--2对 把所有的能组成的2对都找出来且对子不能有鬼牌
function libRecomand:Get_Pt_Two_Pair_Laizi_second(cards, nLaziCount)
    local result = {}
    local bFind = false
    LibNormalCardLogic:Sort(cards)

    local bSuc, t = self:Get_Same_nCard_Split(cards, 2)
    if bSuc and #t > 1 then
        for k, v in ipairs(t) do
            local copyCards = {}
            local index = {}
            local nV = GetCardValue(v[1])
            for _, nCard in ipairs(v) do
                table.insert(copyCards, nCard)
            end

            for i=k+1, #t do
                local stCards = t[i]
                local nV2 = GetCardValue(stCards[1])
                --不能有铁枝
                if nV ~= nV2 then
                    local tempCards = Array.Clone(copyCards)
                    for _, nCard in ipairs(stCards) do
                        table.insert(tempCards, nCard)
                    end
                    bFind = true
                    table.insert(result, { card = tempCards, index = index })
                end
            end
        end
    end
    return bFind, result
end

--1对 +鬼牌把所有的能组成的1对都找出来
function libRecomand:Get_Pt_One_Pair_Laizi_second(cards, nLaziCount)
    local result = {}
    local bFind = false
    LibNormalCardLogic:Sort(cards)

    local bSuc, t = self:Get_Same_nCard_Split(cards, 2)
    if bSuc and #t > 0 then
        for _, v in ipairs(t) do
            local tempCards = {}
            local index = {}
            for _, nCard in ipairs(v) do
                table.insert(tempCards, nCard)
            end
            bFind = true
            table.insert(result, { card = tempCards, index = index })
        end
    end
    if nLaziCount > 0 then
        local stHave = {}
        for _, nCard in ipairs(cards) do
            if not stHave[nCard] then
                stHave[nCard] = nCard

                local tempCards = {}
                local index = {}
                table.insert(tempCards, nCard)
                table.insert(tempCards, 0)
                index[#tempCards] = #tempCards

                bFind = true
                table.insert(result, { card = tempCards, index = index })
            end
        end
    end

    return bFind, result
end

--把鬼牌换上
function libRecomand:Get_Rec_Cards_Laizi(result, stLaiziCards)
    --换上鬼牌
    local stRecLaiziCards = Array.Clone(stLaiziCards)
    local stResult = {}
    for _, v1 in ipairs(result) do
        local Card = v1.card
        if #Card ~= 0 then
            stRecLaiziCards =  Array.Clone(stLaiziCards)
            local Cards = v1.card
            local Index = v1.index
            local RecCards = {}
            for k, v2 in ipairs(Cards) do
                if Index[k] and #stRecLaiziCards > 0 then
                    local nLaiziCard = table.remove(stRecLaiziCards)
                    table.insert(RecCards, nLaiziCard)
                else
                    table.insert(RecCards, v2)
                end
            end
            table.insert(stResult, RecCards)
        end
    end
    return stResult
end





--=============================================================
--幸运推荐
function libRecomand:SetRecommandLuck(cards)
    --1.把癞子牌和普通牌分离
    local normalCards = {}
    local laiziCards = {}
    for _, v in ipairs(cards) do
        local nValue = GetCardValue(v)
        if LibLaiZi:IsLaiZi(nValue) then
            table.insert(laiziCards, v)
        else
            table.insert(normalCards, v)
        end
    end
    local nLaziCount = #laiziCards

    -- LOG_DEBUG("SetRecommandLaizi...#normalCards:%d, normalCards:%s\n", #normalCards, vardump(normalCards))
    -- LOG_DEBUG("SetRecommandLaizi...#laiziCards:%d,  laiziCards:%s\n", #laiziCards, vardump(laiziCards))
    local recommend_cards = {}
    local recommend_cards_first = {}
    local recommend_cards_second = {}

    ----1.尾墩
    local bthirdFind, thirdAllResult = self:Get_Five_Cards_Luck(normalCards, nLaziCount, 3)
    -- LOG_DEBUG("SetRecommandLaizi.........bthirdFind:%s, thirdAllResult:%s\n", tostring(bthirdFind), vardump(thirdAllResult))

    ---可能组成尾墩的所有牌型 
    --thirdAllResult = {result, result, result...}
    --result = {{card={1,2,3..}, index={1,2} },....}
    for _, thirdResult in ipairs(thirdAllResult) do
        for _, thi in ipairs(thirdResult) do
            local stLaiziCards = Array.Clone(laiziCards)    --癞子牌初始数据
            local tempthirdCards = thi.card                 --组成牌型的牌
            local tempthirdIndex = thi.index                --癞子牌在thi.card中位置

            --剩余的癞子牌
            local nThirdUsedLaizi = 0
            for _, v in pairs(tempthirdIndex) do
                nThirdUsedLaizi = nThirdUsedLaizi + 1
            end
            local thirdLeftLaizi = nLaziCount - nThirdUsedLaizi

            --需要移除的牌, 把癞子牌剔除
            local stThirdDelCards = {}
            for k, v in ipairs(tempthirdCards) do
                if tempthirdIndex[k] == nil then
                    table.insert(stThirdDelCards, v)
                end
            end
            --去除尾墩后剩余的牌的数量
            local thirdLeftCards = Array.Clone(normalCards)
            -- LOG_DEBUG("=======================thirdLeftCards1111:%s", vardump(thirdLeftCards))
            Array.DelElements(thirdLeftCards, stThirdDelCards)

            ----2.中墩
            local bSecFind, secondAllResult = self:Get_Five_Cards_Luck(thirdLeftCards, thirdLeftLaizi, 2)
            -- LOG_DEBUG("SetRecommandLaizi.........bSecFind:%s, secondAllResult:%s\n", tostring(bSecFind), vardump(secondAllResult))

            for _, secondResult in ipairs(secondAllResult) do
                for _, sec in ipairs(secondResult) do
                    local tempSecCards = sec.card
                    local tempSecIndex = sec.index

                    --剩余的癞子牌
                    local nSecUsedLaizi = 0
                    for _, v in pairs(tempSecIndex) do
                        nSecUsedLaizi = nSecUsedLaizi + 1
                    end
                    local secondLeftLaizi = thirdLeftLaizi - nSecUsedLaizi

                    --需要移除的牌, 把癞子牌剔除
                    local stSecDelCards = {}
                    for k, v in ipairs(tempSecCards) do
                        if tempSecIndex[k] == nil then
                            table.insert(stSecDelCards, v)
                        end
                    end
                    --去除中墩后剩余的牌的数量
                    local secondLeftCards = Array.Clone(thirdLeftCards)
                    Array.DelElements(secondLeftCards, stSecDelCards)

                    ----3.前墩
                    local bFirstFind, firstAllResult = self:Get_Three_Cards_Luck(secondLeftCards, secondLeftLaizi, 1)
                    -- LOG_DEBUG("SetRecommandLaizi.........bFirstFind:%s, firstAllResult:%s\n", tostring(bFirstFind), vardump(firstAllResult))
                    for _, firstResult in ipairs(firstAllResult) do
                        for _, fir in ipairs(firstResult) do
                            local tempFirstCards = fir.card
                            local tempFirstIndex = fir.index

                            --需要移除的牌, 把癞子牌剔除
                            local stFirstDelCards = {}
                            for k, v in ipairs(tempFirstCards) do
                                if tempFirstIndex[k] == nil then
                                    table.insert(stFirstDelCards, v)
                                end
                            end
                            --去除前墩后剩余的牌的数量
                            local firstLeftCards = Array.Clone(secondLeftCards)
                            Array.DelElements(firstLeftCards, stFirstDelCards)

                            --组合成的牌型
                            local firstCards, secondCards, thirdCards = {}, {}, {}

                            --第三墩  把鬼牌换上
                            local stthirdLaiziCards = Array.Clone(stLaiziCards)
                            for k, v in ipairs(tempthirdCards) do
                                if tempthirdIndex[k] and #stthirdLaiziCards > 0 then
                                    local nLaiziCard = table.remove(stthirdLaiziCards)
                                    table.insert(thirdCards, nLaiziCard)
                                else
                                    table.insert(thirdCards, v)
                                end
                            end
                            --第二墩  把鬼牌换上
                            for k, v in ipairs(tempSecCards) do
                                if tempSecIndex[k] and #stthirdLaiziCards > 0 then
                                    local nLaiziCard = table.remove(stthirdLaiziCards)
                                    table.insert(secondCards, nLaiziCard)
                                else
                                    table.insert(secondCards, v)
                                end
                            end
                            --第一墩  把鬼牌换上
                            for k, v in ipairs(tempFirstCards) do
                                if tempFirstIndex[k] and #stthirdLaiziCards > 0 then
                                    local nLaiziCard = table.remove(stthirdLaiziCards)
                                    table.insert(firstCards, nLaiziCard)
                                else
                                    table.insert(firstCards, v)
                                end
                            end

                            --记得把剩余的鬼牌也加上 防止少牌
                            for _, v in pairs(stthirdLaiziCards) do
                                table.insert(firstLeftCards, v)
                            end

                            local bContinuCheck = true
                            ---补充牌 使其成牌
                            for i=1, 5-#tempthirdCards do
                                if #firstLeftCards > 0 then 
                                    local nCard = table.remove(firstLeftCards)
                                    table.insert(thirdCards, nCard)
                                end
                            end
                            for i=1, 5-#tempSecCards do
                                if #firstLeftCards > 0 then
                                    local nCard = table.remove(firstLeftCards)
                                    table.insert(secondCards, nCard)
                                end
                            end
                            for i=1, 3-#tempFirstCards do
                                if #firstLeftCards > 0 then
                                    local nCard = table.remove(firstLeftCards)
                                    table.insert(firstCards, nCard)
                                end
                            end
                            if #firstCards ~= 3 or #secondCards ~= 5 or #thirdCards ~= 5 then
                                bContinuCheck = false
                            end
                            
                            if bContinuCheck then
                                --
                                local bSuc1, firstType, values1 = LibNormalCardLogic:GetCardTypeByLaizi(firstCards)
                                local bSuc2, secondType, values2 = LibNormalCardLogic:GetCardTypeByLaizi(secondCards)
                                local bSuc3, thirdType, values3 = LibNormalCardLogic:GetCardTypeByLaizi(thirdCards)
                                --判断相公  相公则交换牌
                                local nXianggongCount = 0
                                if LibNormalCardLogic:CompareCardsLaizi(firstType, secondType, values1, values2) > 0 then
                                    nXianggongCount = nXianggongCount + 1
                                    local temp1 = Array.Clone(firstCards)
                                    local temp2 = Array.Clone(secondCards)
                                    firstCards[1] = temp2[1]
                                    firstCards[2] = temp2[2]
                                    firstCards[3] = temp2[3]
                                    secondCards[1] = temp1[1]
                                    secondCards[2] = temp1[2]
                                    secondCards[3] = temp1[3]
                                end
                                if LibNormalCardLogic:CompareCardsLaizi(secondType, thirdType, values2, values3) > 0 then
                                    nXianggongCount = nXianggongCount + 1
                                    local temp2 = Array.Clone(secondCards)
                                    local temp3 = Array.Clone(thirdCards)
                                    secondCards[1] = temp3[1]
                                    secondCards[2] = temp3[2]
                                    secondCards[3] = temp3[3]
                                    secondCards[4] = temp3[4]
                                    secondCards[5] = temp3[5]
                                    thirdCards[1] = temp2[1]
                                    thirdCards[2] = temp2[2]
                                    thirdCards[3] = temp2[3]
                                    thirdCards[4] = temp2[4]
                                    thirdCards[5] = temp2[5]
                                end
                                if LibNormalCardLogic:CompareCardsLaizi(firstType, thirdType, values1, values3) > 0 then
                                    nXianggongCount = nXianggongCount + 1
                                    local temp1 = Array.Clone(firstCards)
                                    local temp3 = Array.Clone(thirdCards)
                                    firstCards[1] = temp3[1]
                                    firstCards[2] = temp3[2]
                                    firstCards[3] = temp3[3]
                                    thirdCards[1] = temp1[1]
                                    thirdCards[2] = temp1[2]
                                    thirdCards[3] = temp1[3]
                                end
                                --重新获取一遍
                                bSuc1, firstType, values1 = LibNormalCardLogic:GetCardTypeByLaizi(firstCards)
                                bSuc2, secondType, values2 = LibNormalCardLogic:GetCardTypeByLaizi(secondCards)
                                bSuc3, thirdType, values3 = LibNormalCardLogic:GetCardTypeByLaizi(thirdCards)

                                --需要重新再比一次  防止换牌后还有相公
                                local bXianggong = false
                                if nXianggongCount > 0 then
                                    if LibNormalCardLogic:CompareCardsLaizi(firstType, secondType, values1, values2) > 0 then
                                        bXianggong = true
                                    end
                                    if bXianggong == false and LibNormalCardLogic:CompareCardsLaizi(secondType, thirdType, values2, values3) > 0 then
                                        bXianggong = true
                                    end
                                    if bXianggong == false and LibNormalCardLogic:CompareCardsLaizi(firstType, thirdType, values1, values3) > 0 then
                                        bXianggong = true
                                    end
                                end

                                if bXianggong == false then
                                    --最后形成的推荐牌
                                    local stCards = {}
                                    for _, v in ipairs(thirdCards) do
                                        table.insert(stCards, v)
                                    end
                                    for _, v in ipairs(secondCards) do
                                        table.insert(stCards, v)
                                    end
                                    for _, v in ipairs(firstCards) do
                                        table.insert(stCards, v)
                                    end

                                    ---判断牌是否正确
                                    if #stCards ~= #cards or Array.IsSubSet(stCards, cards) == false then
                                        -- LOG_DEBUG("=============ERROR==========SrcCards:%s\n, DestCards:%s", vardump(cards), vardump(stCards))
                                    else
                                        local stTypes = {thirdType, secondType, firstType}
                                        local stValues = {values3, values2, values1}
                                        local stFinds = { Cards = stCards, Types = stTypes, Values = stValues }
                                        -- LOG_DEBUG("SetRecommandLuck..firstType:%d, secondType:%d, thirdType:%d", firstType, secondType, thirdType)
                                        -- LOG_DEBUG("SetRecommandLuck..values1:%s, values2:%s, values3:%s", TableToString(values1), TableToString(values2), TableToString(values3))
                                        -- LOG_DEBUG("SetRecommandLuck..stCards:%s", TableToString(stCards))
                                        
                                        if firstType >= GStars_Normal_Type.PT_TWO_GHOST then
                                            --头墩冲三或以上
                                            table.insert(recommend_cards_first, stFinds)
                                            return recommend_cards_first
                                        else
                                            --普通
                                            table.insert(recommend_cards, stFinds)
                                            return recommend_cards
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return recommend_cards
end

--获取能组成5张牌的所有牌型 nWhat:3后墩 2中墩 1前墩
function libRecomand:Get_Five_Cards_Luck(cards, nLaziCount, nWhat)
    local copyCards = Array.Clone(cards)
    LibNormalCardLogic:Sort(copyCards)

    local stOrders = {
        GStars_Normal_Type.PT_FIVE,
        GStars_Normal_Type.PT_STRAIGHT_FLUSH,
        GStars_Normal_Type.PT_FOUR,
        GStars_Normal_Type.PT_FULL_HOUSE,
        GStars_Normal_Type.PT_FLUSH,
        GStars_Normal_Type.PT_STRAIGHT,
        GStars_Normal_Type.PT_THREE,
        GStars_Normal_Type.PT_TWO_PAIR,
        GStars_Normal_Type.PT_ONE_PAIR,
    }
    --从大到小
    table.sort(stOrders, function(a, b)
        local comp1 = GetGStarsNormalCompare(a)
        local comp2 = GetGStarsNormalCompare(b)
        return comp1 > comp2       
    end)
    -- LOG_DEBUG("libRecomand:Get_Five_Cards_Laizi...%s", vardump(stOrders))

    local stAllCardTypes = {}
    local nTotal = 0
    local nCheckMax = 1  --最多找N个推荐牌型，好处是减少计算量,不好的地方就是有可能不是最优的
    for _, nCardType in ipairs(stOrders) do
        local tempCards = Array.Clone(copyCards)
        local bFind = false
        local result = {}

        if nCardType == GStars_Normal_Type.PT_FIVE then
            bFind, result = self:Get_Pt_Five_Laizi(tempCards, nLaziCount, nWhat)

        elseif nCardType == GStars_Normal_Type.PT_STRAIGHT_FLUSH then
            bFind, result = self:Get_Pt_Straight_Flush_Laizi(tempCards, nLaziCount, nWhat)

        elseif nCardType == GStars_Normal_Type.PT_FOUR then
            bFind, result = self:Get_Pt_Four_Laizi(tempCards, nLaziCount, nWhat)

        elseif nCardType == GStars_Normal_Type.PT_FULL_HOUSE then
            bFind, result = self:Get_Pt_Full_Hosue_Laizi(tempCards, nLaziCount, nWhat)

        elseif nCardType == GStars_Normal_Type.PT_FLUSH then
            bFind, result = self:Get_Pt_Flush_Laizi(tempCards, nLaziCount, nWhat)

        elseif nCardType == GStars_Normal_Type.PT_STRAIGHT then
            bFind, result = self:Get_Pt_Straight_Laizi(tempCards, nLaziCount, nWhat)

        elseif nCardType == GStars_Normal_Type.PT_THREE then
            bFind, result = self:Get_Pt_Three_Laizi(tempCards, nLaziCount, nWhat)

        elseif nCardType == GStars_Normal_Type.PT_TWO_PAIR then
            bFind, result = self:Get_Pt_Two_Pair_Laizi(tempCards, nLaziCount, nWhat)

        elseif nCardType == GStars_Normal_Type.PT_ONE_PAIR then
            bFind, result = self:Get_Pt_One_Pair_Laizi(tempCards, nLaziCount, nWhat)
        end

        if bFind then
            table.insert(stAllCardTypes, result)
            nTotal = nTotal + #result
        end
        if nWhat > 1  and nTotal >= nCheckMax then
            return true, stAllCardTypes
        end
    end

    if #stAllCardTypes == 0 then
        local tempCards = Array.Clone(copyCards)
        --散牌5张
        local result = {}
        local temp = {}
        local index = {}

        if nLaziCount >= 5 then
            table.insert(temp, 0x5F)
            table.insert(temp, 0x5F)
            table.insert(temp, 0x5F)
            table.insert(temp, 0x5F)
            table.insert(temp, 0x5F)

            index[1] = 1
            index[2] = 2
            index[3] = 3
            index[4] = 4
            index[5] = 5
        elseif nLaziCount == 2 then
            table.insert(temp, tempCards[#tempCards])
            table.insert(temp, tempCards[#tempCards])
            table.insert(temp, tempCards[#tempCards])
            index[2] = 2
            index[3] = 3
        elseif nLaziCount == 1 then
            table.insert(temp, tempCards[#tempCards])
            table.insert(temp, tempCards[#tempCards])
            index[2] = 2
        else
            table.insert(temp, tempCards[#tempCards])
            table.insert(temp, tempCards[#tempCards-1])
            table.insert(temp, tempCards[#tempCards-2])
            table.insert(temp, tempCards[#tempCards-3])
            table.insert(temp, tempCards[#tempCards-4])
        end
        table.insert(result, { card = temp, index = index })

        table.insert(stAllCardTypes, result)
    end

    return true, stAllCardTypes
end

--获取能组成3张牌的所有牌型 nWhat:3后墩 2中墩 1前墩
function libRecomand:Get_Three_Cards_Luck(cards, nLaziCount, nWhat)
    local copyCards = Array.Clone(cards)
    LibNormalCardLogic:Sort(copyCards)

    local tempCards = Array.Clone(copyCards)
    local stAllCardTypes = {}

    local bFind, result = self:Get_Pt_Three_Laizi(tempCards, nLaziCount, nWhat)
    if bFind then
        table.insert(stAllCardTypes, result)

        return true, stAllCardTypes
    end

    tempCards = Array.Clone(copyCards)
    bFind, result = self:Get_Pt_One_Pair_Laizi(tempCards, nLaziCount, nWhat)
    if bFind then
        -- LOG_DEBUG("11111=======Get_Three_Cards_Laizi:%s", vardump(result))
        if nLaziCount >= 1 then
            table.insert(result[1].card, result[1].card[1])
            result[1].index[3] = 3
        end
        -- LOG_DEBUG("2222=======Get_Three_Cards_Laizi:%s", vardump(result.card))
        table.insert(stAllCardTypes, result)
        
        return true, stAllCardTypes
    end

    if #stAllCardTypes == 0 then
        tempCards = Array.Clone(copyCards)
        --散牌
        local result = {}
        local temp = {}
        local index = {}

        if nLaziCount == 3 then
            table.insert(temp, 0x5F)
            table.insert(temp, 0x5F)
            table.insert(temp, 0x5F)

            index[1] = 1
            index[2] = 2
            index[3] = 3
        elseif nLaziCount == 2 then
            table.insert(temp, tempCards[#tempCards])
            table.insert(temp, tempCards[#tempCards])
            table.insert(temp, tempCards[#tempCards])
            index[2] = 2
            index[3] = 3
        elseif nLaziCount == 1 then
            table.insert(temp, tempCards[#tempCards])
            table.insert(temp, tempCards[#tempCards])
            index[2] = 2
        else
            table.insert(temp, tempCards[#tempCards])
            table.insert(temp, tempCards[#tempCards-1])
            table.insert(temp, tempCards[#tempCards-2])
        end
        table.insert(result, { card = temp, index = index })

        -- LOG_DEBUG("========#index:%d", #index)
        -- for k, v in pairs(index) do
        --     LOG_DEBUG("xxxxxxxxxxxxx%d---%d", k, v)
        -- end

        table.insert(stAllCardTypes, result)
    end


    return true, stAllCardTypes
end

return libRecomand
LibNormalCardLogic = {}

function LibNormalCardLogic:ctor()
end

function LibNormalCardLogic:CreateInit(strSlotName)
    return true
end

function LibNormalCardLogic:OnGameStart()
end

--移除
function LibNormalCardLogic:RemoveCard(srcCards, rmCards)
    if type(srcCards) ~= "table" then
        return
    end
    if type(rmCards) ~= "table" then
        return
    end
    if #srcCards == 0 or #rmCards == 0 then
        return
    end

    for _, v in ipairs(rmCards) do
        Array.RemoveOne(srcCards, v)
    end
end

--按值升序 2-14(A)
function LibNormalCardLogic:Sort(cards)
    -- --LOG_DEBUG("LibNormalCardLogic:Sort..before, cards: %s\n", TableToString(cards))
    if not cards.isSorted then
        table.sort(cards, function(a,b)
            local valueA,colorA = GetCardValue(a), GetCardColor(a)
            local valueB,colorB = GetCardValue(b), GetCardColor(b)
            if valueA == valueB then
                return colorA < colorB
            else
                return valueA < valueB
            end
        end)
        cards.isSorted = true
    end
    -- --LOG_DEBUG("LibNormalCardLogic:Sort..end, cards: %s\n", TableToString(cards))
end
--分花色排序 花色相同按值升序
function LibNormalCardLogic:Sort_By_Color(cards)
    -- --LOG_DEBUG("LibNormalCardLogic:Sort_By_Color..before, cards: %s\n", TableToString(cards))
    table.sort(cards, function(a,b)
        local valueA,colorA = GetCardValue(a), GetCardColor(a)
        local valueB,colorB = GetCardValue(b), GetCardColor(b)
        if colorA == colorB then
            return valueA < valueB
        else
            return colorA < colorB
        end
    end)
    cards.isSorted = false
    -- --LOG_DEBUG("LibNormalCardLogic:Sort_By_Color..end, cards: %s\n", TableToString(cards))
end
--按值排序  从小到大
function LibNormalCardLogic:Sort_By_Value(values)
    if not values.isSorted then
        table.sort(values, function(a, b)
            return a < b
        end)
        values.isSorted = true
    end
end

--有几张不同点数的牌
function LibNormalCardLogic:Uniqc(cards)
    self:Sort(cards)
    local n, uniq, val = 0, 0, 0
    for _,v in ipairs(cards) do
        val = GetCardValue(v)
        if val ~= uniq then
            uniq = val
            n = n + 1
        end
    end
    return n
end

--是否是同花
function LibNormalCardLogic:IsFlush(cards)
    if #cards == 0 then
        return false
    end
    -- --LOG_DEBUG("LibNormalCardLogic:IsFlush.., cards: %s\n", TableToString(cards))

    local color = GetCardColor(cards[1])
    for i=2, #cards do
        if color ~= GetCardColor(cards[i]) then
            return false
        end
    end
    return true
end

-- 是否顺子 普通情况
function LibNormalCardLogic:IsStraight_Common(cards)
    self:Sort(cards)
    local nLen = #cards
    local a1, an = GetCardValue(cards[1]), GetCardValue(cards[nLen])
    if an - a1 ~= nLen - 1 then
        return false
    end
    local a = a1
    for i=2, nLen do
        local rank = GetCardValue(cards[i])
        if rank-a ~= 1 then
            return false
        end
        a = rank
    end
    return true
end

--是否是顺子(A值是1的情况) 2 3 4 5 A
function LibNormalCardLogic:IsStraight(cards)
    self:Sort(cards)
    local nLen = #cards
    local a1, an = GetCardValue(cards[1]), GetCardValue(cards[nLen])
    if a1 ~= 2 or an ~= 14 then
        return self:IsStraight_Common(cards)
    else
        local a = a1
        for i=2, nLen-1 do
            local rank = GetCardValue(cards[i])
            if rank-a ~= 1 then
                return false
            end
            a = rank
        end
        return true
    end
end

--各墩牌的类型(对内外接口)--要加个癞子在cards的位置 代表
function LibNormalCardLogic:GetCardType(cards)
    local cardType = GStars_Normal_Type.PT_ERROR
    local tempCards = Array.Clone(cards)
    ----LOG_DEBUG("LibNormalCardLogic:GetCardType.., cards: %s\n", TableToString(cards))

    self:Sort(tempCards)
    local tempValues = {}
    for i=1, #tempCards do
        local nV = GetCardValue(tempCards[i])
        table.insert(tempValues, nV)
    end
    -- --值排序
    -- self:Sort_By_Value(tempValues)

    if #tempCards == 3 then
        --前墩
        local n = self:Uniqc(tempCards)
        if n == 1 then
            cardType = GStars_Normal_Type.PT_THREE
        elseif n == 2 then
            cardType = GStars_Normal_Type.PT_ONE_PAIR
        elseif n == 3 then
            cardType = GStars_Normal_Type.PT_SINGLE
        else
            cardType = GStars_Normal_Type.PT_ERROR
        end
    elseif #tempCards == 5 then
        --中墩 后墩
        local bFlush = self:IsFlush(tempCards)
        local bStraight = self:IsStraight(tempCards)
        if bFlush then
            --判断是否是同花顺
            if bStraight then
                cardType = GStars_Normal_Type.PT_STRAIGHT_FLUSH
            else
                cardType = GStars_Normal_Type.PT_FLUSH
            end
        elseif bStraight then
            cardType = GStars_Normal_Type.PT_STRAIGHT
        else
            local n = self:Uniqc(tempCards)
            if n == 1 then
                cardType = GStars_Normal_Type.PT_FIVE
            elseif n == 2 then
                local v1 = GetCardValue(tempCards[1])
                local v2 = GetCardValue(tempCards[2])
                local v4 = GetCardValue(tempCards[4])
                local v5 = GetCardValue(tempCards[5])
                if v1 == v2 and v4 == v5 then
                    cardType = GStars_Normal_Type.PT_FULL_HOUSE
                else
                    cardType = GStars_Normal_Type.PT_FOUR
                end
            elseif n == 3 then
                local v1 = GetCardValue(tempCards[1])
                local v2 = GetCardValue(tempCards[2])
                local v3 = GetCardValue(tempCards[3])
                local v4 = GetCardValue(tempCards[4])
                local v5 = GetCardValue(tempCards[5])
                if v1 == v3 or v2 == v4 or v3 == v5 then
                    cardType = GStars_Normal_Type.PT_THREE
                else
                    cardType = GStars_Normal_Type.PT_TWO_PAIR
                end
            elseif n == 4 then
                cardType = GStars_Normal_Type.PT_ONE_PAIR
            elseif n == 5 then
                cardType = GStars_Normal_Type.PT_SINGLE
            else
                cardType = GStars_Normal_Type.PT_ERROR
            end
        end
    else
        cardType = GStars_Normal_Type.PT_ERROR
    end

    ----LOG_DEBUG("LibNormalCardLogic:GetCardType.., cardType: %d\n", cardType)
    return cardType, tempValues
end
--普通牌型比牌(对外接口)
function LibNormalCardLogic:CompareCards(cardsA, cardsB)
    ----LOG_DEBUG("LibNormalCardLogic:CompareCards.., cardsA: %s, cardsB: %s\n", TableToString(cardsA), TableToString(cardsB))
    local tempA = Array.Clone(cardsA)
    local tempB = Array.Clone(cardsB)
    local type1 = self:GetCardType(tempA)
    local type2 = self:GetCardType(tempB)
    -- ----LOG_DEBUG("LibNormalCardLogic:CompareCards.., type1: %d, type1: %d\n", type1, type2)

    if type1 == type2 then
        if type1 == GStars_Normal_Type.PT_ONE_PAIR then
            local p1 = self:GetPairValue(tempA)
            local p2 = self:GetPairValue(tempB)
            if p1 ~= p2 then
                return p1 - p2
            end

        elseif type1 == GStars_Normal_Type.PT_TWO_PAIR then
            --先比较大对子，大对子相等比较小对子
            local pa1, pb1 = self:GetPairValue(tempA)
            local pa2, pb2 = self:GetPairValue(tempB)
            local n = pb1 - pb2
            if n == 0 then
                n = pa1 - pa2
            end
            if n ~= 0 then
                return n
            end

        elseif type1 == GStars_Normal_Type.PT_THREE
            or type1 == GStars_Normal_Type.PT_FULL_HOUSE
            or type1 == GStars_Normal_Type.PT_FOUR then
            --只需要比较中间这张牌
            local p1 = GetCardValue(tempA[3])
            local p2 = GetCardValue(tempB[3])
            if p1 ~= p2 then
                return p1 - p2
            end
        elseif type1 == GStars_Normal_Type.PT_FLUSH then
            --比较对同花
            --if GGameCfg.GameSetting.bSupportWaterBanker then
                local pa1, pb1 = self:GetPairValue(tempA)
                local pa2, pb2 = self:GetPairValue(tempB)
                --先比大对子  再比小对 最后比单张大小
                local n = pb1 - pb2
                if n == 0 then
                    n = pa1 - pa2
                end
                -- --LOG_DEBUG("flush compare,  n= %d", n)
                if n ~= 0 then
                    return n
                end 
            --end
        end
        --比单张
        local singA = {}
        local singB = {}
        return self:CompareSingle(tempA, tempB)
    else
        return type1 - type2
    end
end

--返回值0表示没对子, 值是按从小到大返回的
function LibNormalCardLogic:GetPairValue(cards)
    self:Sort(cards)
    local ret = {}
    local tempVal = nil
    for _, v in ipairs(cards) do
        local val = GetCardValue(v)
        if tempVal == val and ret[#ret] ~= val then
            table.insert(ret, val)
        else
            tempVal = val
        end
    end

    -- --LOG_DEBUG("LibNormalCardLogic:GetPairValue..ret: %s\n", vardump(ret))
    --return table.unpack(ret)
    return (ret[1] or 0), (ret[2] or 0)
end

--比较散牌：从大到小 一对一比较
function LibNormalCardLogic:CompareSingle(cardsA, cardsB)
    if #cardsA == 0 and #cardsB == 0 then
        return 0
    elseif #cardsA == 0 then
        return -1
    elseif #cardsB == 0 then
        return 1
    end

    self:Sort(cardsA)
    self:Sort(cardsB)

    local va = GetCardValue(cardsA[#cardsA])
    local vb = GetCardValue(cardsB[#cardsB])
    local n = va - vb
    if n ~= 0 then
        return n
    else
        table.remove(cardsA)
        table.remove(cardsB)
        return self:CompareSingle(cardsA, cardsB) 
    end
end




--==================配牌库 普通牌型=========================
--注意： 目前这些普通牌型库 不使用  主要原因是不支持癞子牌

--获取最大5张牌(对外接口)
function LibNormalCardLogic:GetMaxFiveCard(cards, skipType)
    if skipType == nil then
        skipType = GStars_Normal_Type.PT_FIVE
    end
    if skipType < GStars_Normal_Type.PT_SINGLE then
        skipType = GStars_Normal_Type.PT_FIVE
    end
    -- --LOG_DEBUG("LibNormalCardLogic:GetMaxFiveCard..before, skipType:%d, cards: %s\n", skipType, TableToString(cards))

    if #cards < 5 then
        LOG_ERROR(" LibNormalCardLogic:GetMaxFiveCard Failed.Card is not enough %d", #cards);
        return nil
    end

    --5同
    local suc, t = self:Get_Max_Pt_Five(cards, skipType)
    if suc then
        return t
    end

    --同花顺
    local suc, t = self:Get_Max_Pt_Straight_Flush(cards, skipType)
    if suc then
        return t
    end

    --铁枝
    local suc, t = self:Get_Max_Pt_Four(cards, skipType)
    if suc then
        local _, tempCard = self:Get_Min_Pt_Single(cards)
        table.insert(t, tempCard)
        return t
    end

    --葫芦
    local suc, t = self:Get_Max_Pt_Full_Hosue(cards, skipType)
    if suc then
        return t
    end

    --同花
    local suc, t = self:Get_Max_Pt_Flush(cards, skipType)
    if suc then
        return t
    end

    --顺子
    local suc, t = self:Get_Max_Pt_Straight(cards, skipType)
    if suc then
        return t
    end

    --三条
    local suc, t = self:Get_Max_Pt_Three(cards, skipType)
    if suc then
        for i=1, 2 do
            local _, tempCard = self:Get_Min_Pt_Single(cards)
            table.insert(t, tempCard)
        end
        return t
    end

    --两对
    local suc, t, nType = self:Get_Max_Pt_Two_Pair(cards, skipType)
    if suc then
        local _, tempCard = self:Get_Max_Pt_Single(cards)
        table.insert(t, tempCard)
        return t
    end

    --一对
    local suc, t, nType = self:Get_Max_Pt_One_Pair(cards, skipType)
    if suc then
        for i=1, 3 do
            local _, tempCard = self:Get_Max_Pt_Single(cards)
            table.insert(t, tempCard)
        end
        return t
    end

    --乌龙
    local t = {}
    for i=1, 5 do
        local _, tempCard = self:Get_Max_Pt_Single(cards)
        table.insert(t, tempCard)
    end

    -- --LOG_DEBUG("LibNormalCardLogic:GetMaxFiveCard..end, cards: %s\n", TableToString(cards))
    -- --LOG_DEBUG("LibNormalCardLogic:GetMaxFiveCard..get table t: %s\n", TableToString(t))
    return t
end

--获取最大3张牌(对外接口)
function LibNormalCardLogic:GetMaxThreeCard(cards, skipType)
    if skipType == nil then
        skipType = GStars_Normal_Type.PT_THREE
    end
    if skipType < GStars_Normal_Type.PT_SINGLE then
        skipType = GStars_Normal_Type.PT_THREE
    end
    -- --LOG_DEBUG("LibNormalCardLogic:GetMaxThreeCard..before, skipType:%d, cards: %s\n", skipType, TableToString(cards))
    if #cards < 3 then
        LOG_ERROR(" LibNormalCardLogic:GetMaxThreeCard Failed.Card is not enough %d", #cards);
        return nil
    end
    --三条
    local suc, t = self:Get_Max_Pt_Three(cards, skipType)
    if suc then
        return t
    end

    --一对
    local suc, t = self:Get_Max_Pt_One_Pair(cards, skipType)
    if suc then
        local _, tempCard = self:Get_Max_Pt_Single(cards)
        table.insert(t, tempCard)
        return t
    end

    --乌龙
    local t = {}
    for i=1, 3 do
        local _, tempCard = self:Get_Max_Pt_Single(cards)
        table.insert(t, tempCard)
    end

    -- --LOG_DEBUG("LibNormalCardLogic:GetMaxThreeCard..end, cards: %s\n", TableToString(cards))
    -- --LOG_DEBUG("LibNormalCardLogic:GetMaxThreeCard..get table t: %s\n", TableToString(t))
    return t
end

--====下面是配牌函数=========
--5同
function LibNormalCardLogic:Get_Max_Pt_Five(cards, skipType)
    -- --LOG_DEBUG("Get_Max_Pt_Five..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 5 then
        return false
    end
    -- --LOG_DEBUG("======Get_Max_Pt_Five======skipType:%d, myType:%d\n", skipType, GStars_Normal_Type.PT_FIVE)
    --[[if GStars_Normal_Type.PT_FIVE < skipType then
        return false
    end--]]

    self:Sort(cards)

    for i = #cards - 4, 1 , -1 do
        local v1 = GetCardValue(cards[i])
        local v2 = GetCardValue(cards[i+1])
        local v3 = GetCardValue(cards[i+2])
        local v4 = GetCardValue(cards[i+3])
        local v5 = GetCardValue(cards[i+4])

        if v1 == v2 and v1 == v3 and v1 == v4 and v1 == v5 then
            local t = {}
            for k=1,5 do
                table.insert(t,table.remove(cards,i))
            end
            -- --LOG_DEBUG("Get_Max_Pt_Five..end, cards: %s\n", TableToString(cards))
            -- --LOG_DEBUG("Get_Max_Pt_Five..get table t: %s\n", TableToString(t))
            return true, t, GStars_Normal_Type.PT_FIVE
        end
    end
    return false
end

--同花顺
function LibNormalCardLogic:Get_Max_Pt_Straight_Flush(cards, skipType)
    -- --LOG_DEBUG("Get_Max_Pt_Straight_Flush..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 5 then
        return false
    end
    -- --LOG_DEBUG("======Get_Max_Pt_Straight_Flush======skipType:%d, myType:%d\n", skipType, GStars_Normal_Type.PT_STRAIGHT_FLUSH)
 --[[   if GStars_Normal_Type.PT_STRAIGHT_FLUSH > skipType then
        return false
    end--]]
    --先按花色排序
    local flush = {}
    self:Sort_By_Color(cards)
    --按花色分组
    for k, v in ipairs(cards) do
        local color = GetCardColor(v)
        if not flush[color] then
            flush[color] = {}
        end
        table.insert(flush[color], v)
    end
    --
    local bFound = false
    local temp = nil
    for _, v in pairs(flush) do
        -- --LOG_DEBUG("Get_Max_Pt_Straight_Flush..color, cards: %s\n", TableToString(v))
        local bSuc, t = self:Get_Max_Pt_Straight(v, skipType)
        if bSuc then
            if temp then
                --比较 找最大的顺子
                local nRet = self:CompareCards(temp, t)
                if nRet < 0 then
                    temp = t
                end
            else
                temp = t
            end
            bFound = true
        end
    end
    if bFound then
        self:RemoveCard(cards, temp)
    end

    -- --LOG_DEBUG("Get_Max_Pt_Straight_Flush..end, cards: %s\n", TableToString(cards))
    -- if bFound then
    --     --LOG_DEBUG("Get_Max_Pt_Straight_Flush..get table t: %s\n", TableToString(temp))
    -- end

    return bFound, temp, GStars_Normal_Type.PT_STRAIGHT_FLUSH
end

--铁枝 (只拿4张相同的 剩下的一张 再处理)
function LibNormalCardLogic:Get_Max_Pt_Four(cards, skipType)
    -- --LOG_DEBUG("Get_Max_Pt_Four..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 4 then
        return false
    end
    -- --LOG_DEBUG("======Get_Max_Pt_Four======skipType:%d, myType:%d\n", skipType, GStars_Normal_Type.PT_FOUR)
    --[[if GStars_Normal_Type.PT_FOUR > skipType then
        return false
    end--]]
    self:Sort(cards)
    for i = #cards - 3, 1 , -1 do
        local v1 = GetCardValue(cards[i])
        local v2 = GetCardValue(cards[i+1])
        local v3 = GetCardValue(cards[i+2])
        local v4 = GetCardValue(cards[i+3])

        if v1 == v2 and v1 == v3 and v1 == v4 then
            local t = {}
            for k=1,4 do
                table.insert(t,table.remove(cards,i))
            end
            -- --LOG_DEBUG("Get_Max_Pt_Four..end, cards: %s\n", TableToString(cards))
            -- --LOG_DEBUG("Get_Max_Pt_Four..get table t: %s\n", TableToString(t))
            return true, t, GStars_Normal_Type.PT_FOUR
        end
    end
    return false
end

--葫芦
function LibNormalCardLogic:Get_Max_Pt_Full_Hosue(cards, skipType)
    -- --LOG_DEBUG("Get_Max_Pt_Full_Hosue..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 5 then
        return false
    end
    -- --LOG_DEBUG("======Get_Max_Pt_Full_Hosue======skipType:%d, myType:%d\n", skipType, GStars_Normal_Type.PT_FULL_HOUSE)
    --[[if GStars_Normal_Type.PT_FULL_HOUSE > skipType then
        return false
    end--]]
    -- 3+2
    local tempCards = Array.Clone(cards)
    local bSuc1 = self:Get_Max_Pt_Three(tempCards, skipType)
    local bSuc2 = false
    if bSuc1 then
        bSuc2 = self:Get_Min_Pt_One_Pair(tempCards, skipType)
    end
    if bSuc1 and bSuc2 then
        local bSuc1, c1 = self:Get_Max_Pt_Three(cards, skipType)
        local bSuc2, c2 = self:Get_Min_Pt_One_Pair(cards, skipType)
        for _, v in ipairs(c2) do
            table.insert(c1, v)
        end
        -- --LOG_DEBUG("Get_Max_Pt_Full_Hosue..end, cards: %s\n", TableToString(cards))
        -- --LOG_DEBUG("Get_Max_Pt_Full_Hosue..get table t: %s\n", TableToString(c1))
        return true, c1, GStars_Normal_Type.PT_FULL_HOUSE
    end
    return false
end

--同花
function LibNormalCardLogic:Get_Max_Pt_Flush(cards, skipType)
    -- --LOG_DEBUG("Get_Max_Pt_Flush..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 5 then
        return false
    end
    -- --LOG_DEBUG("======Get_Max_Pt_Flush======skipType:%d, myType:%d\n", skipType, GStars_Normal_Type.PT_FLUSH)
    --[[if GStars_Normal_Type.PT_FLUSH > skipType then
        return false
    end--]]
    --先按花色排序
    local flush = {}
    self:Sort_By_Color(cards)
    --按花色分组
    for k, v in ipairs(cards) do
        local color = GetCardColor(v)
        if not flush[color] then
            flush[color] = {}
        end
        table.insert(flush[color], v)
    end
    --再遍历找同花
    local bFound = false
    local t = {}
    for _, v in pairs(flush) do
        local len = #v
        if len >= 5 then
            table.insert(t, v[len])
            table.insert(t, v[len-1])
            table.insert(t, v[len-2])
            table.insert(t, v[len-3])
            table.insert(t, v[len-4])
            bFound = true
            break
        end
    end
    if bFound then
        self:RemoveCard(cards, t)
    end  

    -- --LOG_DEBUG("Get_Max_Pt_Flush..end, cards: %s\n", TableToString(cards))
    -- if bFound then
    --     --LOG_DEBUG("Get_Max_Pt_Flush..get table t: %s\n", TableToString(t))
    -- end  

    return bFound, t, GStars_Normal_Type.PT_FLUSH
end

--顺子 10JQKA > A2345 > 910JQK > ...> 23456
function LibNormalCardLogic:Get_Max_Pt_Straight(cards, skipType)
    -- --LOG_DEBUG("Get_Max_Pt_Straight..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 5 then
        return false
    end
    -- --LOG_DEBUG("======Get_Max_Pt_Straight======skipType:%d, myType:%d\n", skipType, GStars_Normal_Type.PT_STRAIGHT)
   --[[ if GStars_Normal_Type.PT_STRAIGHT > skipType then
        return false
    end--]]

    local tempCards = Array.Clone(cards) 
    local bSuc1, t1 = self:Get_Max_Pt_Straight_Normal(tempCards)
    if bSuc1 and GetCardValue(t1[1]) == 14 then
        --10JQKA
        -- --LOG_DEBUG("Get_Max_Pt_Straight..end, cards: %s\n", TableToString(cards))
        -- --LOG_DEBUG("Get_Max_Pt_Straight..get table t1: %s\n", TableToString(t1))
        self:RemoveCard(cards, t1)
        return true, t1, GStars_Normal_Type.PT_STRAIGHT
    end

    --2345A
    local tempCards = Array.Clone(cards) 
    local bSuc2, t2 = self:Get_Max_Pt_Straight_A(tempCards, 5)
    if bSuc2 then
        -- --LOG_DEBUG("Get_Max_Pt_Straight..end, cards: %s\n", TableToString(cards))
        -- --LOG_DEBUG("Get_Max_Pt_Straight..get table t2: %s\n", TableToString(t2))
        self:RemoveCard(cards, t2)
        return true, t2, GStars_Normal_Type.PT_STRAIGHT
    end

    if bSuc1 then
        -- --LOG_DEBUG("Get_Max_Pt_Straight..end, cards: %s\n", TableToString(cards))
        -- --LOG_DEBUG("Get_Max_Pt_Straight..get table t3: %s\n", TableToString(t1))
        self:RemoveCard(cards, t1)
        return true, t1, GStars_Normal_Type.PT_STRAIGHT
    end

    -- --LOG_DEBUG("Get_Max_Pt_Straight..end, cards: %s\n", TableToString(cards))
    return false
end

--普通顺子 不包括A2345
function LibNormalCardLogic:Get_Max_Pt_Straight_Normal(cards)
    -- --LOG_DEBUG("Get_Max_Pt_Straight_Normal..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 5 then
        return false
    end

    self:Sort(cards)
    --遍历找到能组成顺子的 开始和结束位置
    --24 34 35 26 36 37 18 1D
    local bSuc1 = false
    local t = {}
    local len = #cards
    
    local nLastValue = GetCardValue(cards[len])
    table.insert(t, cards[len])
    for i=len-1, 1, -1 do
        local nValue = GetCardValue(cards[i])
        --值相同则跳过这张牌
        if nLastValue ~= nValue then
            if nLastValue ~= nValue + 1 then
                t = {}
                table.insert(t, cards[i])
            else
                table.insert(t, cards[i])
            end
        end
        nLastValue = nValue
        if #t >= 5 then
            bSuc1 = true
            break
        end
    end
    if bSuc1 then
        --从牌库移除
        self:RemoveCard(cards, t)
    end

    -- --LOG_DEBUG("Get_Max_Pt_Straight_Normal..end, cards: %s\n", TableToString(cards))
    -- if bSuc1 then
    --     --LOG_DEBUG("Get_Max_Pt_Straight_Normal..get table t: %s\n", TableToString(t))
    -- end

    return bSuc1, t
end

--A2345 顺子中第二大  nFindValue必须填，5则是找A2345, 3则是找A23
function LibNormalCardLogic:Get_Max_Pt_Straight_A(cards, nFindValue)
    -- --LOG_DEBUG("Get_Max_Pt_Straight_A..before, nFindValue: %d, cards: %s\n", nFindValue, TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 5 then
        return false
    end
    if nFindValue == nil then
        return false
    end

    self:Sort(cards)

    local len = #cards
    if GetCardValue(cards[len]) ~= 14 then
        return false
    end

    local t = {}
    table.insert(t, cards[len])
    for i=len, 1, -1 do
        --找5432
        if nFindValue == GetCardValue(cards[i]) then
            nFindValue = nFindValue - 1
            table.insert(t, cards[i])
            if nFindValue == 1 then
                break
            end
        end
    end
    if nFindValue ~= 1 then
        return false
    end
    if nFindValue ~= 1 then
        return false
    end

    --从牌库移除
    self:RemoveCard(cards, t)

    -- --LOG_DEBUG("Get_Max_Pt_Straight_A..end, nFindValue: %d, cards: %s\n", nFindValue, TableToString(cards))
    -- --LOG_DEBUG("Get_Max_Pt_Straight_A..get table nFindValue: %d, t: %s\n", nFindValue, TableToString(t))

    return true, t
end

--3条
function LibNormalCardLogic:Get_Max_Pt_Three(cards, skipType)
    -- --LOG_DEBUG("Get_Max_Pt_Three..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 3 then
        return false
    end
    -- --LOG_DEBUG("======Get_Max_Pt_Three======skipType:%d, myType:%d\n", skipType, GStars_Normal_Type.PT_THREE)
    --[[if GStars_Normal_Type.PT_THREE > skipType then
        return false
    end--]]
    self:Sort(cards)
    for i = #cards - 2, 1 , -1 do
        local v1 = GetCardValue(cards[i])
        local v2 = GetCardValue(cards[i+1])
        local v3 = GetCardValue(cards[i+2])

        if v1 == v2 and v1 == v3 then
            local t = {}
            for k=1,3 do
                table.insert(t,table.remove(cards,i))
            end
            -- --LOG_DEBUG("Get_Max_Pt_Three..end, cards: %s\n", TableToString(cards))
            -- --LOG_DEBUG("Get_Max_Pt_Three..get table t: %s\n", TableToString(t))
            return true, t, GStars_Normal_Type.PT_THREE
        end
    end
    -- --LOG_DEBUG("Get_Max_Pt_Three..end, cards: %s\n", TableToString(cards))
    return false
end

--两对
function LibNormalCardLogic:Get_Max_Pt_Two_Pair(cards, skipType)
    -- --LOG_DEBUG("Get_Max_Pt_Two_Pair..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 4 then
        return false
    end
    -- --LOG_DEBUG("======Get_Max_Pt_Two_Pair======skipType:%d, myType:%d\n", skipType, GStars_Normal_Type.PT_TWO_PAIR)
    --[[if GStars_Normal_Type.PT_TWO_PAIR > skipType then
        return false
    end--]]
    local tempCards = Array.Clone(cards)
    local bSuc1 = self:Get_Max_Pt_One_Pair(tempCards, skipType)
    local bSuc2 = self:Get_Max_Pt_One_Pair(tempCards, skipType)
    if bSuc1 and bSuc2 then
        local bSuc1, c1 = self:Get_Max_Pt_One_Pair(cards, skipType)
        local bSuc2, c2 = self:Get_Max_Pt_One_Pair(cards, skipType)
        for _, v in ipairs(c2) do
            table.insert(c1, v)
        end
        -- --LOG_DEBUG("Get_Max_Pt_Two_Pair..end, cards: %s\n", TableToString(cards))
        -- --LOG_DEBUG("Get_Max_Pt_Two_Pair..get table t: %s\n", TableToString(c1))
        return true, c1, GStars_Normal_Type.PT_TWO_PAIR
    end
    -- --LOG_DEBUG("Get_Max_Pt_Two_Pair..end, cards: %s\n", TableToString(cards))
    return false
end

--一对
function LibNormalCardLogic:Get_Max_Pt_One_Pair(cards, skipType)
    -- --LOG_DEBUG("Get_Max_Pt_One_Pair..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 2 then
        return false
    end
    -- --LOG_DEBUG("======Get_Max_Pt_One_Pair======skipType:%d, myType:%d\n", skipType, GStars_Normal_Type.PT_ONE_PAIR)
    --[[if GStars_Normal_Type.PT_ONE_PAIR > skipType then
        return false
    end--]]

    self:Sort(cards)
    for i = #cards - 1, 1 , -1 do
        local v1 = GetCardValue(cards[i])
        local v2 = GetCardValue(cards[i+1])

        if v1 == v2 then
            local t = {}
            for k=1,2 do
                table.insert(t,table.remove(cards,i))
            end
            -- --LOG_DEBUG("Get_Max_Pt_One_Pair..end, cards: %s\n", TableToString(cards))
            -- --LOG_DEBUG("Get_Max_Pt_One_Pair..get table t: %s\n", TableToString(t))
            return true, t, GStars_Normal_Type.PT_ONE_PAIR
        end
    end
    -- --LOG_DEBUG("Get_Max_Pt_One_Pair..end, cards: %s\n", TableToString(cards))
    return false
end

function LibNormalCardLogic:Get_Min_Pt_One_Pair(cards, skipType)
    -- --LOG_DEBUG("Get_Max_Pt_One_Pair..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 2 then
        return false
    end
    -- --LOG_DEBUG("======Get_Max_Pt_One_Pair======skipType:%d, myType:%d\n", skipType, GStars_Normal_Type.PT_ONE_PAIR)
    --[[if GStars_Normal_Type.PT_ONE_PAIR > skipType then
        return false
    end--]]

    self:Sort(cards)
    for i = 1, #cards-1 do
        local v1 = GetCardValue(cards[i])
        local v2 = GetCardValue(cards[i+1])

        if v1 == v2 then
            local t = {}
            for k=1,2 do
                table.insert(t,table.remove(cards,i))
            end
            -- --LOG_DEBUG("Get_Max_Pt_One_Pair..end, cards: %s\n", TableToString(cards))
            -- --LOG_DEBUG("Get_Max_Pt_One_Pair..get table t: %s\n", TableToString(t))
            return true, t, GStars_Normal_Type.PT_ONE_PAIR
        end
    end
    -- --LOG_DEBUG("Get_Max_Pt_One_Pair..end, cards: %s\n", TableToString(cards))
    return false
end

--散牌
function LibNormalCardLogic:Get_Max_Pt_Single(cards)
    -- --LOG_DEBUG("Get_Max_Pt_Single..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards == 0 then
        return false
    end

    self:Sort(cards)
    return true,table.remove(cards,#cards)
end

function LibNormalCardLogic:Get_Min_Pt_Single(cards)
    -- --LOG_DEBUG("Get_Min_Pt_Single..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards == 0 then
        return false
    end

    self:Sort(cards)
    return true,table.remove(cards,1)
end

--=========================================================================










--================================================================
--癞子版顺子
function LibNormalCardLogic:IsStraight_Laizi(cards, nLaiziCount)
    local bFind = true
    if nLaiziCount == 0 then
        bFind = self:IsStraight(cards)
    else
        if #cards == 0 then
            return true, 0
        end

        self:Sort(cards)
        local nLen = #cards
        local a1 = GetCardValue(cards[1])
        local an = GetCardValue(cards[nLen])

        local a = a1
        local tempLZCount = nLaiziCount

        --普通顺子
        for i=2, nLen do
            local rank = GetCardValue(cards[i])
            if rank-a > 1 then
                local nSub = rank - a -1
                if nSub <= tempLZCount then
                    tempLZCount = tempLZCount - nSub
                else
                    bFind = false
                    break
                end
            elseif rank-a <= 0 then
                bFind = false
                break
            end
            a = rank
        end

        --A顺
        if bFind == false then
            if an == 14 then
                a = 1
            end
            bFind = true
            for i=2, nLen-1 do
                local rank = GetCardValue(cards[i])
                if rank-a > 1 then
                    local nSub = rank - a -1
                    if nSub <= tempLZCount then
                        tempLZCount = tempLZCount - nSub
                    else
                        bFind = false
                        break
                    end
                 elseif rank-a <= 0 then
                    bFind = false
                    break
                end
                a = rank
            end 
        end
    end

   return bFind, tempLZCount
end

--牌值 花色 分离
function LibNormalCardLogic:CardsChange(cards)
    local stColorValue = {}
    for i=0, 4 do
        if stColorValue[i] == nil then
            stColorValue[i] = {}
        end
        for j=0, 14 do
            stColorValue[i][j] = 0
        end
    end

    for _, v in pairs(cards) do
        local color = GetCardColor(v)
        local value = GetCardValue(v)
        --[color][value] = count
        stColorValue[color][value] = stColorValue[color][value] + 1
        --[color][0] = count 花色数量
        stColorValue[color][0] = stColorValue[color][0] + 1
        --[4][value] = count 点数数量
        stColorValue[4][value] = stColorValue[4][value] + 1
    end

    return stColorValue
end

--获取顺子
function LibNormalCardLogic:GetStraight_Laizi(values, nLaiziCount)
    local t = {}
    local bFind = false
    --找所有能组成顺子 A2345,23456。。。10JQKA
    local bHasAShun = false
    local stAShun = {}
    for i=1, 10 do
        local tempLZCount = nLaiziCount
        local straight = true
        local temp = {}
        for j=1, 5 do
            local nV = i+j-1
            if values[nV] == 0 then
                if tempLZCount > 0 then
                    if nV == 1 then
                        nV = 14
                    end
                    table.insert(temp, nV)
                    tempLZCount = tempLZCount -1
                else
                    straight = false
                    break
                end 
            else
                if nV == 1 then
                    nV = 14
                end
                table.insert(temp, nV)
            end 
        end
        if straight then
            -- local cardType = GStars_Normal_Type.PT_STRAIGHT_FLUSH
            bFind = true
            if i == 1 then
                bHasAShun = true
                stAShun = temp
            else
                table.insert(t, temp)
            end
        end
    end
    if bHasAShun then
        table.insert(t, stAShun)
    end
    return bFind, t
end

--获取同花 5张
function LibNormalCardLogic:GetFlush_Laizi(values, nLaiziCount)
    local t = {}
    local bFind = false
    for i=14, 2, -1 do
        local temp = {}
        local tempLZCount = nLaiziCount
        local flush = true
        if values[i] > 0 then
            if values[i] == 2 then
                for k=1, values[i] do
                    table.insert(temp, i)
                end
            elseif values[i] == 1 then
                table.insert(temp, i)
                if tempLZCount > 0 then
                    table.insert(temp, i)
                    tempLZCount = tempLZCount - 1
                end
            end
            if #temp < 5 then
                for j=i-1, 2, -1 do
                    if values[j] == 2 then
                        for k=1, values[j] do
                            table.insert(temp, j)
                        end
                    elseif values[j] == 1 then
                        table.insert(temp, j)
                        if tempLZCount > 0 then
                            table.insert(temp, j)
                            tempLZCount = tempLZCount - 1
                        end
                    end
                    if #temp == 5 then
                        bFind = true
                        table.insert(t, temp)
                        break
                    end
                end
            end
            --找到一个就退出了
            if bFind then
                break
            end
        end
    end

    return bFind, t 
end

--5张牌  获取最大的牌型及牌值
function LibNormalCardLogic:GetCardsAndTypeFive_Laizi(cards, nLaiziCount)
    local tempValues = {}
    local bFind = false
    -- local cardType = GStars_Normal_Type.PT_ERROR
    --全是癞子
    if nLaiziCount == #cards then
        local cardType = GStars_Normal_Type.PT_FIVE
        bFind = true
        if tempValues[cardType] == nil then
            tempValues[cardType] = {}
        end
        table.insert(tempValues[cardType], {14, 14, 14, 14, 14})
    else
        local stColorValue = self:CardsChange(cards)
        for i=2, 14 do
            local nCount = stColorValue[4][i]
            if nCount > 0 then
                local nTotalSame = nCount + nLaiziCount
                if nTotalSame == 5 then
                    local cardType = GStars_Normal_Type.PT_FIVE
                    bFind = true
                    if tempValues[cardType] == nil then
                        tempValues[cardType] = {}
                    end
                    --最大的放在最后
                    table.insert(tempValues[cardType], {i, i, i ,i, i})
                elseif nTotalSame == 4 then
                    local cardType = GStars_Normal_Type.PT_FOUR
                    if tempValues[cardType] == nil then
                        tempValues[cardType] = {}
                    end
                    for j=2, 14 do
                        if i ~= j and stColorValue[4][j] == 1 then
                            bFind = true
                            --最大的放在最后
                            table.insert(tempValues[cardType], {i, i, i, i, j})
                            break
                        end
                    end
                elseif nTotalSame == 3 then
                    --葫芦 3条
                    for j=2, 14 do
                        if i ~= j and stColorValue[4][j] > 0 then
                            if stColorValue[4][j] == 2 then
                                local cardType = GStars_Normal_Type.PT_FULL_HOUSE
                                if tempValues[cardType] == nil then
                                    tempValues[cardType] = {}
                                end
                                bFind = true
                                --最大的放在最后
                                table.insert(tempValues[cardType], {i, i, i, j, j})
                                break
                            elseif stColorValue[4][j] == 1 then
                                local temp = {i, i, i, j}
                                for k=j+1, 14 do
                                    if stColorValue[4][k] == 1 then
                                        table.insert(temp, k)
                                        break
                                    end
                                end
                                if #temp == 5 then
                                    local cardType = GStars_Normal_Type.PT_THREE
                                    if tempValues[cardType] == nil then
                                        tempValues[cardType] = {}
                                    end
                                    bFind = true
                                    table.insert(tempValues[cardType], temp)
                                    break
                                end
                            end
                        end
                    end
                elseif nTotalSame == 2 then
                    --2对 1对
                    for j=2, 14 do
                        if i ~= j and stColorValue[4][j] > 0 then
                            if stColorValue[4][j] == 2 then
                                local temp = {i, i, j, j}
                                for k=j+1, 14 do
                                    if stColorValue[4][k] == 1 then
                                        table.insert(temp, k)
                                        break
                                    end
                                end
                                if #temp == 5 then
                                    local cardType = GStars_Normal_Type.PT_TWO_PAIR
                                    if tempValues[cardType] == nil then
                                        tempValues[cardType] = {}
                                    end
                                    bFind = true
                                    table.insert(tempValues[cardType], temp)
                                    break
                                end
                            elseif stColorValue[4][j] == 1 then
                                local temp = {i, i, j}
                                for k=j+1, 14 do
                                    if stColorValue[4][k] == 1 then
                                        table.insert(temp, k)
                                    end
                                    if #temp == 5 then
                                        break
                                    end
                                end
                                if #temp == 5 then
                                    local cardType = GStars_Normal_Type.PT_ONE_PAIR
                                    if tempValues[cardType] == nil then
                                        tempValues[cardType] = {}
                                    end
                                    bFind = true
                                    table.insert(tempValues[cardType], temp)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        --同花顺
        local bFlushStraight = false
        for i=0, 3 do
            local nCount = 0
            local values = {}
            for j=2, 14 do
                values[j] = stColorValue[i][j]
                if stColorValue[i][j] > 0 then
                    nCount = nCount + 1
                end
            end
            values[1] = values[14]

            local nTotalSame = nCount + nLaiziCount
            if nTotalSame == 5 then
                local bSuc, temp = self:GetStraight_Laizi(values, nLaiziCount)
                if bSuc then
                    bFind = true
                    bFlushStraight = true
                    local cardType = GStars_Normal_Type.PT_STRAIGHT_FLUSH
                    if tempValues[cardType] == nil then
                        tempValues[cardType] = {}
                    end
                    for _, v in ipairs(temp) do
                        table.insert(tempValues[cardType], v)
                    end
                end
            end
        end
        --同花
        if bFlushStraight == false then
            for i=0, 3 do
                local nCount = 0
                local values = {}
                for j=2, 14 do
                    values[j] = stColorValue[i][j]
                    if stColorValue[i][j] > 0 then
                        nCount = nCount + stColorValue[i][j]
                    end
                end
                local nTotalSame = nCount + nLaiziCount
                if nTotalSame == 5 then
                    local bSuc, temp = self:GetFlush_Laizi(values, nLaiziCount)
                    if bSuc then
                        bFind = true
                        local cardType = GStars_Normal_Type.PT_FLUSH
                        if tempValues[cardType] == nil then
                            tempValues[cardType] = {}
                        end
                        for _, v in ipairs(temp) do
                            table.insert(tempValues[cardType], v)
                        end
                    end
                end
            end
        end
        --顺子
        if bFlushStraight == false then
            local nCount = 0
            local values = {}
            for j=2, 14 do
                values[j] = stColorValue[4][j]
                if stColorValue[4][j] > 0 then
                    nCount = nCount + 1
                end
            end
            values[1] = values[14]
            local nTotalSame = nCount + nLaiziCount
            if nTotalSame == 5 then
                local bSuc, temp = self:GetStraight_Laizi(values, nLaiziCount)
                if bSuc then
                    bFind = true
                    local cardType = GStars_Normal_Type.PT_STRAIGHT
                    if tempValues[cardType] == nil then
                        tempValues[cardType] = {}
                    end
                    for _, v in ipairs(temp) do
                        table.insert(tempValues[cardType], v)
                    end
                end
            end
        end
    end
    return bFind, tempValues
end
--3张牌  获取最大的牌型及牌值
function LibNormalCardLogic:GetCardsAndTypeThree_Laizi(cards, nLaiziCount)
    local tempValues = {}
    local bFind = false
    -- local cardType = GStars_Normal_Type.PT_ERROR
    --全是癞子
    if nLaiziCount == #cards then
        local cardType = GStars_Normal_Type.PT_THREE
        bFind = true
        if tempValues[cardType] == nil then
            tempValues[cardType] = {}
        end
        table.insert(tempValues[cardType], {14, 14, 14})
    else
        local stColorValue = self:CardsChange(cards)
        for i=2, 14 do
            local nCount = stColorValue[4][i]
            if nCount > 0 then
                local nTotalSame = nCount + nLaiziCount
                if nTotalSame == 3 then
                    local cardType = GStars_Normal_Type.PT_THREE
                    bFind = true
                    if tempValues[cardType] == nil then
                        tempValues[cardType] = {}
                    end
                    table.insert(tempValues[cardType], {i, i, i})
                elseif nTotalSame == 2 then
                    local cardType = GStars_Normal_Type.PT_ONE_PAIR
                    if tempValues[cardType] == nil then
                        tempValues[cardType] = {}
                    end
                    for j=2, 14 do
                        if i ~= j and stColorValue[4][j] > 0 then
                            bFind = true
                            --最大的放在最后了
                            table.insert(tempValues[cardType], {i, i, j})
                        end
                    end 
                end
            end
        end
    end
    return bFind, tempValues
end

--返回值0表示没对子, 值是按从小到大返回的
function LibNormalCardLogic:GetPairValueByValue(values)
    self:Sort_By_Value(values)
    local ret = {}
    local tempVal = nil
    for _, val in ipairs(values) do
        if tempVal == val and ret[#ret] ~= val then
            table.insert(ret, val)
        else
            tempVal = val
        end
    end

    --LOG_DEBUG("LibNormalCardLogic:GetPairValueByValue..ret: %s\n", vardump(ret))
    --return table.unpack(ret)
    return (ret[1] or 0), (ret[2] or 0)
end

--比较散牌：从大到小 一对一比较
function LibNormalCardLogic:CompareSingleByValue(valuesA, valuesB)
    if #valuesA == 0 and #valuesB == 0 then
        return 0
    elseif #valuesA == 0 then
        return -1
    elseif #valuesB == 0 then
        return 1
    end

    self:Sort_By_Value(valuesA)
    self:Sort_By_Value(valuesB)

    local va = valuesA[#valuesA] or 0
    local vb = valuesB[#valuesB] or 0
    local n = va - vb
    if n ~= 0 then
        return n
    else
        table.remove(valuesA)
        table.remove(valuesB)
        return self:CompareSingle(valuesA, valuesB) 
    end
end


--=========================================================================
--[[
    接口函数 GetCardTypeByLaizi(cards)  主要是检查玩家出的牌各墩所能组成的最大牌型
    接口函数 CompareCardsLaizi(type1, type2, values1, values2)  主要用来比牌，判断大小

    这两个函数一般都是结合在一起用
--]]
--=========================================================================
--玩家出牌检查 对外接口
function LibNormalCardLogic:GetCardTypeByLaizi(cards)
    --LOG_DEBUG("LibNormalCardLogic:GetCardTypeByLaizi....#cards:%d", #cards)
    local tempCards = Array.Clone(cards)
    local normalCards = {}
    local laiziCards = {}
    for _, v in ipairs(tempCards) do
        local nValue = GetCardValue(v)
        if LibLaiZi:IsLaiZi(nValue) then
            table.insert(laiziCards, v)
        else
            table.insert(normalCards, v)
        end
    end

    local bSuc = false
    local tempValues = {}

    local cardType = GStars_Normal_Type.PT_ERROR
    local values = {}

    local nLaiziCount = #laiziCards
    if nLaiziCount == 0 then
        cardType, values = self:GetCardType(normalCards)
        --LOG_DEBUG("111111111GetCardTypeByLaizi....cardType:%d values:%s\n", cardType, vardump(values))
        return true, cardType, values
    else
        if #tempCards == 3 then
            bSuc, tempValues = self:GetCardsAndTypeThree_Laizi(normalCards, nLaiziCount)
        elseif #tempCards == 5 then
            bSuc, tempValues = self:GetCardsAndTypeFive_Laizi(normalCards, nLaiziCount)
        end
        --LOG_DEBUG("LibNormalCardLogic:GetCardTypeByLaizi....bSuc:%s, tempValues:%s\n", tostring(bSuc), vardump(tempValues))
    end

    if bSuc then
        --获取最大牌型
        for i=10, 1, -1 do
            if tempValues[i] then
                cardType = i
                local nLen = #tempValues[i]
                --LOG_DEBUG("LibNormalCardLogic:GetCardTypeByLaizi...cardType:%d, nLen:%d", cardType, nLen)
                values = Array.Clone(tempValues[i][nLen])
                --LOG_DEBUG("LibNormalCardLogic:GetCardTypeByLaizi...valuesSRC:%s\n, valuesDST:%s\n", vardump(tempValues[i][nLen]), vardump(values))
                break
            end
        end
    else
        --LOG_DEBUG("===============ERROR, GetCardTypeByLaizi:%s", vardump(tempCards))
        values = {}
        for _, v in ipairs(tempCards) do
            table.insert(values, GetCardValue(v))
        end
    end

    --LOG_DEBUG("222222222GetCardTypeByLaizi....bSuc:%s, cardType:%d values:%s\n", tostring(bSuc), cardType, vardump(values))
    
    return bSuc, cardType, values
end

--玩家比牌对外接口
function LibNormalCardLogic:CompareCardsLaizi(type1, type2, values1, values2)
    if type1 == type2 then
        local valuesA = Array.Clone(values1)
        local valuesB = Array.Clone(values2)
        self:Sort_By_Value(valuesA)
        self:Sort_By_Value(valuesB)

        if type1 == GStars_Normal_Type.PT_ONE_PAIR then
            local p1 = self:GetPairValueByValue(valuesA)
            local p2 = self:GetPairValueByValue(valuesB)
            if p1 ~= p2 then
                return p1 - p2
            end

        elseif type1 == GStars_Normal_Type.PT_TWO_PAIR then
            --先比较大对子，大对子相等比较小对子
            local pa1, pb1 = self:GetPairValueByValue(valuesA)
            local pa2, pb2 = self:GetPairValueByValue(valuesB)
            local n = pb1 - pb2
            if n == 0 then
                n = pa1 - pa2
            end
            if n ~= 0 then
                return n
            end

        elseif type1 == GStars_Normal_Type.PT_THREE
            or type1 == GStars_Normal_Type.PT_FULL_HOUSE
            or type1 == GStars_Normal_Type.PT_FOUR then
            --只需要比较中间这张牌
            local p1 = valuesA[3]
            local p2 = valuesB[3]
            if p1 ~= p2 then
                return p1 - p2
            end
        elseif type1 == GStars_Normal_Type.PT_FLUSH then
            --比较对同花
            local pa1, pb1 = self:GetPairValueByValue(valuesA)
            local pa2, pb2 = self:GetPairValueByValue(valuesB)
            --先比大对子  再比小对 最后比单张大小
            local n = pb1 - pb2
            if n == 0 then
                n = pa1 - pa2
            end
            -- --LOG_DEBUG("flush compare,  n= %d", n)
            if n ~= 0 then
                return n
            end 
        end
        --比单张
        return self:CompareSingleByValue(valuesA, valuesB)
    else
        return type1 - type2
    end
end

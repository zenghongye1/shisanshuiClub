local LibBase = import(".lib_base")
local LibLaiZi = import(".lib_laizi"):create()
local LibNormalCardLogic = class("LibNormalCardLogic", LibBase)

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
    if cards and type(cards) == "table" and #cards > 0 then
        -- LOG_DEBUG("LibNormalCardLogic:Sort..before, cards: %s\n", TableToString(cards))
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
        -- LOG_DEBUG("LibNormalCardLogic:Sort..end, cards: %s\n", TableToString(cards))
    end
end
--分花色排序 花色相同按值升序
function LibNormalCardLogic:Sort_By_Color(cards)
    if cards and type(cards) == "table" and #cards > 0 then
        -- LOG_DEBUG("LibNormalCardLogic:Sort_By_Color..before, cards: %s\n", TableToString(cards))
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
        -- LOG_DEBUG("LibNormalCardLogic:Sort_By_Color..end, cards: %s\n", TableToString(cards))
    end
end
--按值排序  从小到大
function LibNormalCardLogic:Sort_By_Value(values)
    if values and type(values) == "table" and #values > 0 then
        if not values.isSorted then
            table.sort(values, function(a, b)
                return a < b
            end)
            values.isSorted = true
        end
    end
end

--有几张不同点数的牌>=0没问题  <0表明cards为空,不做处理
function LibNormalCardLogic:Uniqc(cards)
    if cards and type(cards) == "table" and #cards > 0 then
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

    return -1
end

--是否是同花
function LibNormalCardLogic:IsFlush(cards)
    if cards and type(cards) == "table" and #cards > 0 then
        -- LOG_DEBUG("LibNormalCardLogic:IsFlush.., cards: %s\n", TableToString(cards))
        --1.把癞子牌和普通牌分离
        local normalCards = {}
        for _, v in ipairs(cards) do
            if v > 0 then
                local nValue = GetCardValue(v)
                if not LibLaiZi:IsLaiZi(nValue) then
                    table.insert(normalCards, v)
                end
            end
        end
        if #normalCards > 0 then
            local color = GetCardColor(normalCards[1])
            for i=2, #normalCards do
                if color ~= GetCardColor(normalCards[i]) then
                    return false
                end
            end
        end
        return true

        -- local color = GetCardColor(cards[1])
        -- for i=2, #cards do
        --     if color ~= GetCardColor(cards[i]) then
        --         return false
        --     end
        -- end
        -- return true
    end

    return false
end

-- 是否顺子 普通情况
function LibNormalCardLogic:IsStraight_Common(cards)
    if cards and type(cards) == "table" and #cards > 0 then
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

    return false
end

--是否是顺子(A值是1的情况) 2 3 4 5 A
function LibNormalCardLogic:IsStraight(cards)
    if cards and type(cards) == "table" and #cards > 0 then
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

    return false
end

--返回>=nSameCoun的牌值 返回val, count
function LibNormalCardLogic:GetSameValue(values, nSameCount)
    if nSameCount == nil or type(nSameCount) ~= "number" or nSameCount < 1 then
        return 0,0 
    end

    if values and type(values) == "table" and #values > 0 then
        local hash = {}
        for i=1, 15 do
            hash[i] = 0
        end
        for _, val in ipairs(values) do
            hash[val] = hash[val] + 1
        end

        for val, count in ipairs(hash) do
            if count >= nSameCount then
                return val, count
            end
        end
    end

    return 0,0       
end

--返回值0表示没对子, 值是按从小到大返回的
function LibNormalCardLogic:GetPairValue(cards)
    if cards and type(cards) == "table" and #cards > 0 then
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

        -- LOG_DEBUG("LibNormalCardLogic:GetPairValue..ret: %s\n", vardump(ret))
        --return table.unpack(ret)
        return (ret[1] or 0), (ret[2] or 0)
    end

    return 0,0
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

--获取牌值相同的数量 最多5张
function LibNormalCardLogic:GetLarge2SameCard(cards)
    local one,two,three,four,five = 0,0,0,0,0
    if cards and type(cards) == "table" and #cards > 0 then
        local values = {}
        for i=1, 14 do
            values[i] = 0
        end
        for _, v in ipairs(cards) do
            local val = GetCardValue(v)
            values[val] = values[val] + 1
        end
        for val, count in ipairs(values) do
            if count == 1 then
                one = one + 1
            elseif count == 2 then
                two = two + 1
            elseif count == 3 then
                three = three + 1
            elseif count == 4 then
                four = four + 1
            elseif count >= 5 then
                five = five + 1
            end
        end
    end

    return one,two,three,four,five
end


--普通顺子 不包括A2345
function LibNormalCardLogic:Get_Max_Pt_Straight_Normal(cards)
    -- LOG_DEBUG("Get_Max_Pt_Straight_Normal..before, cards: %s\n", TableToString(cards))
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

    -- LOG_DEBUG("Get_Max_Pt_Straight_Normal..end, cards: %s\n", TableToString(cards))
    -- if bSuc1 then
    --     LOG_DEBUG("Get_Max_Pt_Straight_Normal..get table t: %s\n", TableToString(t))
    -- end

    return bSuc1, t
end

--A2345 顺子中第二大  nFindValue必须填，5则是找A2345, 3则是找A23
function LibNormalCardLogic:Get_Max_Pt_Straight_A(cards, nFindValue)
    -- LOG_DEBUG("Get_Max_Pt_Straight_A..before, nFindValue: %d, cards: %s\n", nFindValue, TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 5 then
        return false
    end
    if nFindValue == nil or type(cards) ~= "number" then
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

    -- LOG_DEBUG("Get_Max_Pt_Straight_A..end, nFindValue: %d, cards: %s\n", nFindValue, TableToString(cards))
    -- LOG_DEBUG("Get_Max_Pt_Straight_A..get table nFindValue: %d, t: %s\n", nFindValue, TableToString(t))

    return true, t
end

--是否支持222333规则
function LibNormalCardLogic:IsSubport23Rule()
    return card_define.GetIsSubport23Rule()
end

function LibNormalCardLogic:IsValue23Rule(nValue)
    if self:IsSubport23Rule() then
        local nGhostAdd = card_define.GetGhostNum()
        local stDTemp = {2,3,4,5,6,7,8,9,10,11,12,13,14,}
        for i=1, nGhostAdd do
            if stDTemp[i] and stDTemp[i] == nValue then
                return true
            end
        end
    end

    return false
end

--23规则前墩牌型
function LibNormalCardLogic:Get23RuleFirstType(nValue)
    nValue = nValue or 0

    local bFind = false
    local cardType = 0
    if self:IsValue23Rule(nValue) then
        local stTempType = {
            [2] = GStars_Normal_Type.PT_THREE_TWO,
            [3] = GStars_Normal_Type.PT_THREE_THREE,
            [4] = GStars_Normal_Type.PT_THREE_FOUR,
            [5] = GStars_Normal_Type.PT_THREE_FIVE,
            [6] = GStars_Normal_Type.PT_THREE_SIX,
            [7] = GStars_Normal_Type.PT_THREE_SEVEN,
            [8] = GStars_Normal_Type.PT_THREE_EIGHT,
            [9] = GStars_Normal_Type.PT_THREE_NINE,
            [10] = GStars_Normal_Type.PT_THREE_TEN,
            [11] = GStars_Normal_Type.PT_THREE_JJJ,
            [12] = GStars_Normal_Type.PT_THREE_QQQ,
            [13] = GStars_Normal_Type.PT_THREE_KKK,
            [14] = GStars_Normal_Type.PT_THREE_AAA,
        }

        cardType = stTempType[nValue] or 0
        if cardType > 0 then
            bFind = true
        end
    end
    -- LOG_DEBUG("LibNormalCardLogic:Get23RuleFirstType...bFind:%s, cardType:%d", tostring(bFind), cardType)

    return bFind, cardType
end

--牌堆有癞子cards是否有count张指定牌值。如是否有铁枝
function LibNormalCardLogic:IsHaveNSameValue(cards, count)
    if cards and type(cards) == "table" and #cards > 0 then
        if count == nil or type(count) ~= "number" or #cards < count or count < 1 then
            return false
        end
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

        --是否有炸弹
        local values = {}
        for i=1, 14 do
            values[i] = 0
        end
        for _, v in ipairs(normalCards) do
            local val = GetCardValue(v)
            if values[val] then
                values[val] = values[val] + 1
            end
        end
        for k, v in ipairs(values) do
            --222/333 + 1
            if self:IsValue23Rule(k) then
                v = v + 1
            end
            if #laiziCards + v >= count then
                return true
            end
        end
    end
    return false
end
--牌堆有癞子cards是否有count张同花顺。如5张的同花顺
function LibNormalCardLogic:IsHaveStraightFlush(cards, count)
    if cards and type(cards) == "table" and #cards > 0 then
        if count == nil or type(count) ~= "number" or #cards < count or count < 1 then
            return false
        end

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
        --2
        local nLaiziCount = #laiziCards
        if nLaiziCount >= count then
            return true
        end
        --3按花色归类
        local stColorValue = {}
        local stColorCount = {}
        for i=0, 3 do
            if stColorValue[i] == nil then
                stColorValue[i] = {}
            end
            for j=1, 14 do
                stColorValue[i][j] = 0
            end
            --
            stColorCount[i] = 0
        end
        for _, v in pairs(normalCards) do
            local color = GetCardColor(v)
            local value = GetCardValue(v)
            if stColorValue[color] then
                if stColorValue[color][value] == 0 then
                    stColorCount[color] = stColorCount[color] + 1
                end
                stColorValue[color][value] = v
            end
        end
        --判断是否有同花顺   
        for i=0, 3 do
            stColorValue[i][1] = stColorValue[i][14]    --1与A(14)

            local values = stColorValue[i]
            local nColorCount = stColorCount[i] + nLaiziCount
            if values and nColorCount >= count then
                for i=1, 10 do
                    local tempLZCount = nLaiziCount
                    local straight = true
                    for j=1, count do
                        local nV = i+j-1
                        if values[nV] == 0 then
                            if tempLZCount > 0 then
                                tempLZCount = tempLZCount -1
                            else
                                straight = false
                                break
                            end 
                        end 
                    end
                    if straight then
                        return true
                    end
                end
            end
        end
    end

    return false
end
--牌堆里有癞子cards是否有count张顺子。如5张的顺子
function LibNormalCardLogic:IsHaveStraight(cards, count)
    if cards and type(cards) == "table" and #cards > 0 then
        if count == nil or type(count) ~= "number" or #cards < count or count < 1 then
            return false
        end

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
        --2
        local nLaiziCount = #laiziCards
        if nLaiziCount >= count then
            return true
        end
        --3按花色归类
        local values = {}
        for i=1, 14 do
            values[i] = 0
        end

        for _, v in pairs(normalCards) do
            local val = GetCardValue(v)
            values[val] = 1
        end
        values[1] = values[14]

        --判断是否有顺子
        for i=1, 10 do
            local tempLZCount = nLaiziCount
            local straight = true
            for j=1, count do
                local nV = i+j-1
                if values[nV] == 0 then
                    if tempLZCount > 0 then
                        tempLZCount = tempLZCount -1
                    else
                        straight = false
                        break
                    end 
                end 
            end
            if straight then
                return true
            end
        end
    end

    return false
end



--================================================================
--癞子版顺子cards无赖子手牌（做m+n测试 m>=0 n>=0）
function LibNormalCardLogic:IsStraight_Laizi(cards, nLaiziCount)
    local bFind = true
    local tempLZCount = nLaiziCount

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
            for i=1, nLen-1 do
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

--获取顺子 5张
function LibNormalCardLogic:GetStraight_Laizi(values, nLaiziCount)
    local t = {}
    local bFind = false
    --找所有能组成顺子 A2345,23456。。。10JQKA
    local bHasAShun = false
    local bHasKShun = false
    local stAShun = {}
    local stKShun = {}
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
            elseif i == 10 then
                bHasKShun = true
                stKShun = temp 
            else
                table.insert(t, temp)
            end
        end
    end
    --把最大的放最后
    if bHasAShun then
        table.insert(t, stAShun)
    end
    if bHasKShun then
        table.insert(t, stKShun)
    end
    return bFind, t
end

--获取同花 5张
function LibNormalCardLogic:GetFlush_Laizi(values, nLaiziCount)
    -- LOG_DEBUG("LibNormalCardLogic:GetFlush_Laizi...values:%s, nLaiziCount:%s", vardump(values), tostring(nLaiziCount))
    local tempValue = {}
    for value, count in pairs(values) do
        if count > 0 then
            table.insert(tempValue, {value = value, count = count})
        end
    end

    local t = {}
    local tempLZCount = nLaiziCount or 0
    if #tempValue > 0 then
        --desc
        table.sort(tempValue, function(a, b)
            if a.count == b.count then
                return a.value > b.value
            else
                return a.count > b.count
            end
        end)

        for _, v in ipairs(tempValue) do
            if v.count > 0 then
                for i=1, v.count do
                    table.insert(t, v.value)
                end
                for i=1, tempLZCount do
                    table.insert(t, v.value)
                end
                tempLZCount = 0
            end
        end
    else
        for i=1, tempLZCount do
            table.insert(t, 15)
        end  
    end
    -- LOG_DEBUG("LibNormalCardLogic:GetFlush_Laizi...t:%s", vardump(t))

    local stRet = {}
    if #t == 5 then
        table.insert(stRet, t)
        return true, stRet
    end

    return false, stRet
end

--5张牌  获取最大的牌型及牌值---算法应该可以优化
function LibNormalCardLogic:GetCardsAndTypeFive_Laizi(cards, nLaiziCount)
    local tempValues = {}
    local bFind = false
    --全是癞子
    if nLaiziCount >= 5 then
        local cardType = GStars_Normal_Type.PT_FIVE_GHOST
        bFind = true
        if tempValues[cardType] == nil then
            tempValues[cardType] = {}
        end
        table.insert(tempValues[cardType], {15, 15, 15, 15, 15})
    else
        local stColorValue = self:CardsChange(cards)
        for i=2, 14 do
            local nCount = stColorValue[4][i]   --点数数量
            if nCount > 0 then
                local nTotalSame = nCount + nLaiziCount
                if nTotalSame == 5 then
                    bFind = true
                    local cardType = GStars_Normal_Type.PT_FIVE
                    -- 22222 33333
                    if self:IsValue23Rule(i) then
                        cardType = GStars_Normal_Type.PT_SIX
                    end
                    if tempValues[cardType] == nil then
                        tempValues[cardType] = {}
                    end
                    --最大的放在最后
                    table.insert(tempValues[cardType], {i, i, i ,i, i})
                elseif nTotalSame == 4 then
                    local cardType = GStars_Normal_Type.PT_FOUR
                    for j=2, 14 do
                        if i ~= j and stColorValue[4][j] == 1 then
                            bFind = true
                            -- 2222+x 3333+x
                            if self:IsValue23Rule(i) then
                                cardType = GStars_Normal_Type.PT_FIVE
                            end
                            if tempValues[cardType] == nil then
                                tempValues[cardType] = {}
                            end
                            --最大的放在最后
                            table.insert(tempValues[cardType], {i, i, i, i, j})
                            break
                        end
                    end
                elseif nTotalSame == 3 then
                    --222/333+xy
                    if self:IsValue23Rule(i) then
                        local cardType = GStars_Normal_Type.PT_FOUR
                        if tempValues[cardType] == nil then
                            tempValues[cardType] = {}
                        end
                        bFind = true
                        local stAddValues = {}
                        table.insert(stAddValues, i)
                        table.insert(stAddValues, i)
                        table.insert(stAddValues, i)
                        for j=2, 14 do
                            local nj = stColorValue[4][j]
                            if i ~= j and nj > 0 then
                                for k=1, nj do
                                    table.insert(stAddValues, j)
                                end
                            end
                            if #stAddValues == 5 then
                                break
                            end
                        end
                        --最大的放在最后
                        table.insert(tempValues[cardType], stAddValues)
                    else
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
                    end
                elseif nTotalSame == 2 then
                    --2对 1对
                    local cardType = GStars_Normal_Type.PT_ONE_PAIR
                    local temp = {i,i,}
                    for j=2, 14 do
                        local n = stColorValue[4][j]
                        if i ~= j and n > 0 then
                            for i=1, n do
                                table.insert(temp, j)
                            end
                            if n == 2 then
                                cardType = GStars_Normal_Type.PT_TWO_PAIR
                            end
                        end
                    end
                    if #temp == 5 then
                        if tempValues[cardType] == nil then
                            tempValues[cardType] = {}
                        end
                        bFind = true
                        table.insert(tempValues[cardType], temp)
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
            --5张不同的点数才有可能 组合成同花顺
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
                    --这个花色这个点数有几张
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
                        bFlushStraight = true
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
        --散牌
        if bFind == false then
            local cardType = GStars_Normal_Type.PT_SINGLE
            bFind = true
            if tempValues[cardType] == nil then
                tempValues[cardType] = {}
            end
            local stAddValues = {}
            for j=2, 14 do
                local nj = stColorValue[4][j]
                if nj > 0 then
                    for k=1, nj do
                        table.insert(stAddValues, j)
                    end
                end
                if #stAddValues == 5 then
                    break
                end
            end
            table.insert(tempValues[cardType], stAddValues)
        end
    end
    return bFind, tempValues
end
--3张牌  获取最大的牌型及牌值---算法应该可以优化
function LibNormalCardLogic:GetCardsAndTypeThree_Laizi(cards, nLaiziCount)
    local tempValues = {}
    local bFind = false
    --全是癞子
    if nLaiziCount >= 3 then
        local cardType = GStars_Normal_Type.PT_THREE_GHOST
        if tempValues[cardType] == nil then
            tempValues[cardType] = {}
        end
        bFind = true
        table.insert(tempValues[cardType], {15, 15, 15})
    else
        local stColorValue = self:CardsChange(cards)
        for i=2, 14 do
            local nCount = stColorValue[4][i]
            if nCount > 0 then
                local nTotalSame = nCount + nLaiziCount
                if nTotalSame == 3 then
                    bFind = true
                    local cardType = GStars_Normal_Type.PT_THREE
                    local b23Find, tempType = self:Get23RuleFirstType(i)
                    local stAddValues = {}
                    --TODO:对222 333 对鬼冲前 做特殊处理
                    if b23Find then
                        cardType = tempType
                        stAddValues = {i, i, i}
                    elseif nLaiziCount == 2 then
                        cardType = GStars_Normal_Type.PT_TWO_GHOST
                        stAddValues = {i, 15, 15}
                    else
                        cardType = GStars_Normal_Type.PT_THREE
                        stAddValues = {i, i, i}
                    end
                    if tempValues[cardType] == nil then
                        tempValues[cardType] = {}
                    end
                    table.insert(tempValues[cardType], stAddValues)
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
        if bFind == false then
            local cardType = GStars_Normal_Type.PT_SINGLE
            bFind = true
            if tempValues[cardType] == nil then
                tempValues[cardType] = {}
            end
            local stAddValues = {}
            for j=2, 14 do
                local nj = stColorValue[4][j]
                if nj > 0 then
                    for k=1, nj do
                        table.insert(stAddValues, j)
                    end
                end
                if #stAddValues == 5 then
                    break
                end
            end
            table.insert(tempValues[cardType], stAddValues)
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

    -- LOG_DEBUG("LibNormalCardLogic:GetPairValueByValue..ret: %s\n", vardump(ret))
    return (ret[1] or 0), (ret[2] or 0)
end
--返回值0表示没有三条
function LibNormalCardLogic:GetThreeValueByValue(values)
    -- LOG_DEBUG("LibNormalCardLogic:GetThreeValueByValue...values:%s", vardump(values))
    local stCount = {}
    for _, val in ipairs(values) do
        if stCount[val] == nil then
            stCount[val] = 0
        end
        stCount[val] = stCount[val] + 1 
    end
    
    local nMaxCount = 0
    local nMaxValue = 0
    for val, count in pairs(stCount) do
        -- LOG_DEBUG("LibNormalCardLogic:GetThreeValueByValue...val:%d, count:%d", val, count)
        if nMaxCount == 0 then
            nMaxCount = count
            nMaxValue = val
        elseif nMaxCount < count then
            nMaxCount = count
            nMaxValue = val
        end
    end

    local nThreeValue = 0
    if nMaxCount >= 3 then
        nThreeValue = nMaxValue
    end
    -- LOG_DEBUG("LibNormalCardLogic:GetThreeValueByValue...nMaxValue:%d, nMaxCount:%d, nThreeValue:%d", nMaxValue, nMaxCount, nThreeValue)

    return nThreeValue
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
        return self:CompareSingleByValue(valuesA, valuesB) 
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
    -- LOG_DEBUG("LibNormalCardLogic:GetCardTypeByLaizi....#cards:%d", #cards)
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
    -- LOG_DEBUG("LibNormalCardLogic:GetCardTypeByLaizi...len:%d, normalCards:%s", #normalCards, TableToString(normalCards))
    -- LOG_DEBUG("LibNormalCardLogic:GetCardTypeByLaizi...len:%d, laiziCards:%s", #laiziCards, TableToString(laiziCards))

    local bSuc = false
    local bFind = false
    local tempValues = {}

    local cardType = GStars_Normal_Type.PT_SINGLE
    local values = {}

    local nLaiziCount = #laiziCards
    if #tempCards == 3 then
        bSuc, tempValues = self:GetCardsAndTypeThree_Laizi(normalCards, nLaiziCount)
        -- LOG_DEBUG("LibNormalCardLogic:GetCardTypeByLaizi33333333....bSuc:%s, tempValues:%s\n", tostring(bSuc), vardump(tempValues))
    elseif #tempCards == 5 then
        bSuc, tempValues = self:GetCardsAndTypeFive_Laizi(normalCards, nLaiziCount)
        -- LOG_DEBUG("LibNormalCardLogic:GetCardTypeByLaizi55555555....bSuc:%s, tempValues:%s\n", tostring(bSuc), vardump(tempValues))
    end
    -- LOG_DEBUG("LibNormalCardLogic:GetCardTypeByLaizi....bSuc:%s, tempValues:%s\n", tostring(bSuc), vardump(tempValues))

    if bSuc then
        ---找出最大的牌型
        local nMaxScore = -1
        local nMaxType = 0
        for k, v in pairs(tempValues) do
            local nTempScore = GetGStarsNormalCompare(k)
            if nMaxScore < 0 then
                nMaxType = k
                nMaxScore = nTempScore
            else
                if nMaxScore < nTempScore then
                    nMaxType = k
                    nMaxScore = nTempScore
                end
            end
        end
        if tempValues[nMaxType] then
            cardType = nMaxType
            local nLen = #tempValues[nMaxType]
            if tempValues[nMaxType][nLen] then
                values = Array.Clone(tempValues[nMaxType][nLen])
                bFind = true
            end
        end
    end

    if bFind == false then
        bSuc = true
        cardType = GStars_Normal_Type.PT_SINGLE
        values = {}
        for _, v in ipairs(tempCards) do
            table.insert(values, GetCardValue(v))
        end
    end

    -- LOG_DEBUG("222222222GetCardTypeByLaizi....bSuc:%s, cardType:%d values:%s\n", tostring(bSuc), cardType, vardump(values))
    
    return bSuc, cardType, values
end

--自比，判断相公<注意：头墩type1和中墩type2；头墩type1和尾墩墩type2；中墩type1和尾墩墩type2 >
function LibNormalCardLogic:CompareCardsLaizi(type1, type2, values1, values2)
    local comp1 = GetGStarsNormalCompare(type1)
    local comp2 = GetGStarsNormalCompare(type2)

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
            or type1 == GStars_Normal_Type.PT_FOUR  --xxxx+y 222/333+xy
            or type1 == GStars_Normal_Type.PT_FIVE  --xxxxx 2222/3333+x
            then
            --只需要比较有三张相同的牌就行
            local p1 = self:GetSameValue(valuesA, 3)
            local p2 = self:GetSameValue(valuesB, 3)
            if p1 ~= p2 then
                return p1 - p2
            end

        elseif type1 == GStars_Normal_Type.PT_SIX then
            --22222/33333
            local p1 = valuesA[1]
            local p2 = valuesB[1]
            return p1 - p2

        elseif type1 == GStars_Normal_Type.PT_FLUSH then
            ----三条同花>两对同花>对子同花>单张同花
            local pt1 = self:GetThreeValueByValue(valuesA)
            local pt2 = self:GetThreeValueByValue(valuesB)
            --LOG_DEBUG("LibNormalCardLogic:CompareCardsLaizi...pt1:%d, pt2:%d", pt1, pt2)
            if pt1 == 0 and pt2 == 0 then
                --比较对同花
                local pa1, pb1 = self:GetPairValueByValue(valuesA)
                local pa2, pb2 = self:GetPairValueByValue(valuesB)
                --先比大对子  再比小对 最后比单张大小
                local n = pb1 - pb2
                if n == 0 then
                    n = pa1 - pa2
                end
                -- LOG_DEBUG("flush compare,  n= %d", n)
                if n ~= 0 then
                    return n
                end
            else
                --三条同花
                local m = pt1 - pt2
                if m ~= 0 then
                    return m
                end
            end
        end
        --比单张
        return self:CompareSingleByValue(valuesA, valuesB)
    
    --特殊情况比较(头墩是对鬼冲前 中墩是三条)
    elseif type1 == GStars_Normal_Type.PT_TWO_GHOST then

        if type2 == GStars_Normal_Type.PT_THREE then
            local valuesA = Array.Clone(values1)
            local valuesB = Array.Clone(values2)
            self:Sort_By_Value(valuesA)
            self:Sort_By_Value(valuesB)

            local p1 = valuesA[1]
            local p2 = self:GetSameValue(valuesB, 3)
            if p1 ~= p2 then
                return p1 - p2
            else
                --鬼鬼4 < 444+xy
                return -1
            end
        else
            return comp1 - comp2
        end

    else
        return comp1 - comp2
    end
end

--和别人比，判断大小
function LibNormalCardLogic:CompareCardsLaizi_other(type1, type2, values1, values2)
    local comp1 = GetGStarsNormalCompare(type1)
    local comp2 = GetGStarsNormalCompare(type2)

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
         
        elseif type1 == GStars_Normal_Type.PT_TWO_GHOST
            or type1 == GStars_Normal_Type.PT_THREE_TWO
            or type1 == GStars_Normal_Type.PT_THREE_THREE
            or type1 == GStars_Normal_Type.PT_THREE_FOUR
            or type1 == GStars_Normal_Type.PT_THREE_FIVE
            or type1 == GStars_Normal_Type.PT_THREE_SIX
            or type1 == GStars_Normal_Type.PT_THREE_SEVEN
            or type1 == GStars_Normal_Type.PT_THREE_EIGHT
            or type1 == GStars_Normal_Type.PT_THREE_NINE
            or type1 == GStars_Normal_Type.PT_THREE_TEN
            or type1 == GStars_Normal_Type.PT_THREE_JJJ
            or type1 == GStars_Normal_Type.PT_THREE_QQQ
            or type1 == GStars_Normal_Type.PT_THREE_KKK
            or type1 == GStars_Normal_Type.PT_THREE_AAA
            or type1 == GStars_Normal_Type.PT_THREE_GHOST then
            --前墩 特殊3条比较
            local p1 = valuesA[1]
            local p2 = valuesB[1]
            return p1 - p2

        elseif type1 == GStars_Normal_Type.PT_THREE
            or type1 == GStars_Normal_Type.PT_FULL_HOUSE
            or type1 == GStars_Normal_Type.PT_FOUR  --xxxx+y 222/333+xy
            or type1 == GStars_Normal_Type.PT_FIVE  --xxxxx 2222/3333+x
            then
            --只需要比较有三张相同的牌就行
            local p1 = self:GetSameValue(valuesA, 3)
            local p2 = self:GetSameValue(valuesB, 3)
            if p1 ~= p2 then
                return p1 - p2
            end

        elseif type1 == GStars_Normal_Type.PT_SIX
            or type1 == GStars_Normal_Type.PT_FIVE_GHOST then
            --22222/33333
            local p1 = valuesA[1]
            local p2 = valuesB[1]
            return p1 - p2

        elseif type1 == GStars_Normal_Type.PT_FLUSH then
            ----三条同花>两对同花>对子同花>单张同花
            local pt1 = self:GetThreeValueByValue(valuesA)
            local pt2 = self:GetThreeValueByValue(valuesB)
            --LOG_DEBUG("LibNormalCardLogic:CompareCardsLaizi_other...pt1:%d, pt2:%d", pt1, pt2)
            if pt1 == 0 and pt2 == 0 then
                --比较对同花
                local pa1, pb1 = self:GetPairValueByValue(valuesA)
                local pa2, pb2 = self:GetPairValueByValue(valuesB)
                --先比大对子  再比小对 最后比单张大小
                local n = pb1 - pb2
                if n == 0 then
                    n = pa1 - pa2
                end
                -- LOG_DEBUG("flush compare,  n= %d", n)
                if n ~= 0 then
                    return n
                end
            else
                --三条同花
                local m = pt1 - pt2
                if m ~= 0 then
                    return m
                end
            end
        end
        --比单张
        return self:CompareSingleByValue(valuesA, valuesB)
    else
        return comp1 - comp2
    end
end

return LibNormalCardLogic
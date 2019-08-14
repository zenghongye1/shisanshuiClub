--local LibBase = import(".lib_base")
--local LibSpCardLogic = class("LibSpCardLogic", LibBase)

LibSpCardLogic = {}
function LibSpCardLogic:ctor()
end

function LibSpCardLogic:CreateInit(strSlotName)
    return true
end

function LibSpCardLogic:OnGameStart()
end

--获取特殊牌型
function LibSpCardLogic:GetSpecialType(cards)
    if #cards ~= MAX_HAND_CARD_NUM then
        return GStars_Special_Type.PT_SP_NIL
    end

    if #cards ~= MAX_HAND_CARD_NUM then
        return GStars_Special_Type.PT_SP_NIL
    end
    local tempCards = Array.Clone(cards)
    -- LOG_DEBUG("LibSpCardLogic:GetSpecialType...tempCards:%s",  TableToString(tempCards))

    --至尊清龙：同花2、3、4、5、6、7、8、9、10、J、Q、K、A
    if self:Check_Pt_Sp_Straight_Flush(tempCards) then
        LibNormalCardLogic:Sort(cards)
        return GStars_Special_Type.PT_SP_STRAIGHT_FLUSH

    --一条龙：非同花的2、3、4、5、6、7、8、9、10、J、Q、K、A
    elseif self:Check_Pt_Sp_Straight(tempCards) then
        LibNormalCardLogic:Sort(cards)
        return GStars_Special_Type.PT_SP_STRAIGHT

    --四套三条：4副相同的三张牌加一张杂牌，举例：AAA、BBB、CCC、DDD、E
    elseif self:Check_Pt_Sp_Four_Three(tempCards) then
        LibNormalCardLogic:Sort(cards)
        return GStars_Special_Type.PT_SP_FOUR_THREE

    --三炸弹：3副炸弹加一张杂牌，举例：AAAA、BBBB、CCCC、E
    elseif self:Check_Pt_Sp_Three_Bomb(tempCards) then
        LibNormalCardLogic:Sort(cards)
        return GStars_Special_Type.PT_SP_THREE_BOMB

    --三皇五帝：2张五同加一张三条，举例：AAAAA、BBBBB、CCC
    elseif self:Check_Pt_Sp_Five_And_Three_King(tempCards) then
        LibNormalCardLogic:Sort(cards)
        return GStars_Special_Type.PT_SP_FIVE_AND_THREE_KING

    --十二皇族：12张牌全是J、Q、K、A，剩余一张可以是任意牌，举例：JQKA、JQKA、JQKA，5
    elseif self:Check_Pt_Sp_All_King(tempCards) then
        LibNormalCardLogic:Sort(cards)
        return GStars_Special_Type.PT_SP_ALL_KING

    --三同花顺：三墩分别都是同花顺，举例：同花23456、同花78910J、同花JQK
    elseif self:Check_Pt_Sp_Three_Straight_Flush(tempCards) then
        LibNormalCardLogic:Sort_By_Color(cards)
        return GStars_Special_Type.PT_SP_THREE_STRAIGHT_FLUSH

    --六六大顺：13张牌出现6张相同牌，举例：13张牌至少含有6张相同牌型
    elseif self:Check_Pt_Sp_Six(tempCards) then
        LibNormalCardLogic:Sort(cards)
        return GStars_Special_Type.PT_SP_SIX

    --全大：13张牌数字都为8----A，举例：最小为8，最大为A范围内的牌
    elseif self:Check_Pt_Sp_All_Big(tempCards) then
        LibNormalCardLogic:Sort(cards)
        return GStars_Special_Type.PT_SP_ALL_BIG

    --全小：13张牌数字都为2----8，举例：最小为2，最大为8范围内的牌
    elseif self:Check_Pt_Sp_All_Small(tempCards) then
        LibNormalCardLogic:Sort(cards)
        return GStars_Special_Type.PT_SP_ALL_SMALL

    --五队冲三：5个一对加三张相同牌型，举例：AA、BB、CC、DD、EE、FFF
    elseif self:Check_Pt_Sp_Five_Pair_And_Three(tempCards) then
        LibNormalCardLogic:Sort(cards)
        return GStars_Special_Type.PT_SP_FIVE_PAIR_AND_THREE

    --六对半：6个对子加一张杂牌，举例：AA、BB、CC、DD、EE、FF、G
    elseif self:Check_Pt_Sp_Six_Pairs(tempCards) then
        LibNormalCardLogic:Sort(cards)
        return GStars_Special_Type.PT_SP_SIX_PAIRS

    --三顺子：三墩都是顺子牌，举例：23456、678910、JQK牌型，且至少有一墩非同花
    elseif self:Check_Pt_Sp_Three_Straight(tempCards) then
        LibNormalCardLogic:Sort(cards)
        return GStars_Special_Type.PT_SP_THREE_STRAIGHT

    --三同花：三墩都是同一花色，举例：三墩都是同一花色，且至少有一墩非顺子
    elseif self:Check_Pt_Sp_Three_Flush(tempCards) then
        LibNormalCardLogic:Sort_By_Color(cards)
        return GStars_Special_Type.PT_SP_THREE_FLUSH

    --凑一色：13张牌都是方块、红心或者黑桃、梅花
    elseif self:Check_Pt_Sp_Same_Suit(tempCards) then
        LibNormalCardLogic:Sort_By_Color(cards)
        return GStars_Special_Type.PT_SP_SAME_SUIT

    else
        return GStars_Special_Type.PT_SP_NIL
    end
end

--=========下面是特殊牌型判断================

--至尊清龙
function LibSpCardLogic:Check_Pt_Sp_Straight_Flush(cards)
    -- assert(#cards == MAX_HAND_CARD_NUM)
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

    local bFind = false
    local nLaziCount = #laiziCards

    LibNormalCardLogic:Sort(normalCards)
    local bStraight = LibNormalCardLogic:IsStraight_Laizi(normalCards, nLaziCount)
    local bFlush = LibNormalCardLogic:IsFlush(normalCards)

    -- LOG_DEBUG("Check_Pt_Sp_Straight_Flush=====bStraight:%s, bFlush:%s", tostring(bStraight), tostring(bFlush))
    if bStraight == true and bFlush == true then
        bFind =  true
    end
    return bFind
end

--一条龙
function LibSpCardLogic:Check_Pt_Sp_Straight(cards)
    -- assert(#cards == MAX_HAND_CARD_NUM)
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

    local bFind = false
    local nLaziCount = #laiziCards
    
    LibNormalCardLogic:Sort(normalCards)
    local bStraight = LibNormalCardLogic:IsStraight_Laizi(normalCards, nLaziCount)
    local bFlush = LibNormalCardLogic:IsFlush(normalCards)

    -- LOG_DEBUG("Check_Pt_Sp_Straight=====bStraight:%s, bFlush:%s", tostring(bStraight), tostring(bFlush))
    if bStraight == true and bFlush == false then
        return true
    end
    return false    
end

--四套三条  4个3条
function LibSpCardLogic:Check_Pt_Sp_Four_Three(cards)
    --assert(#cards == MAX_HAND_CARD_NUM)
    --1.把癞子牌和普通牌分离
    -- LOG_DEBUG("==========Check_Pt_Sp_Four_Three: cards:%s", TableToString(cards))
    local normalCards = {}
    local laiziCards = {}
    for _, v in ipairs(cards) do
        local nValue = GetCardValue(v)
        -- LOG_DEBUG("============Check_Pt_Sp_Four_Three..nValue:%d, IsLaiZi:%s", nValue, tostring(LibLaiZi:IsLaiZi(nValue)))
        if LibLaiZi:IsLaiZi(nValue) then
            table.insert(laiziCards, v)
        else
            table.insert(normalCards, v)
        end
    end
    local nLaziCount = #laiziCards

    --
    local values = {}
    for i=1, 14 do
        values[i] = 0
    end
    for _, v in ipairs(normalCards) do
        local val = GetCardValue(v)
        values[val] = values[val] + 1
    end

    --优先过滤能组成3条的牌  剩余的就是不能组成3条的牌
    local count = 0
    for k, v in ipairs(values) do
        local n = math.floor(v/3)
        if n >=1 then
            count = count + n
            values[k] = values[k] - 3 * n
        end
    end
    if count >= 4 then
        return true
    end

    --不够癞子来凑
    if nLaziCount > 0 then
        --从大到小 排序
        table.sort(values, function(a, b)
            return a > b
        end)

        --剩余的就是不能组成3条的牌
        for _, v in ipairs(values) do
            if v > 0 and v < 3 then
                local nSub = 3 - v
                if nSub >=0 and nSub <= nLaziCount then
                    nLaziCount = nLaziCount - nSub
                    count = count + 1
                else
                    break
                end
            end

            if count >= 4 then
                return true
            end
        end
    end

    if count >= 4 then
        return true
    end
    return false
end

--三炸弹   3个铁枝
function LibSpCardLogic:Check_Pt_Sp_Three_Bomb(cards)
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

    --
    local values = {}
    for i=1, 14 do
        values[i] = 0
    end
    for _, v in ipairs(normalCards) do
        local val = GetCardValue(v)
        values[val] = values[val] + 1
    end

    --优先过滤能组成4条的牌  剩余的就是不能组成4条的牌
    local count = 0
    for k, v in ipairs(values) do
        local n = math.floor(v/4)
        if n >=1 then
            count = count + n
            values[k] = values[k] - 4 * n
        end
    end
    if count >= 3 then
        return true
    end

    --不够癞子来凑
    if nLaziCount > 0 then
        --从大到小 排序
        table.sort(values, function(a, b)
            return a > b
        end)

        --剩余的就是不能组成4条的牌
        for _, v in ipairs(values) do
            if v > 0 and v < 4 then
                local nSub = 4 - v
                if nSub >=0 and nSub <= nLaziCount then
                    nLaziCount = nLaziCount - nSub
                    count = count + 1
                else
                    break
                end
            end

            if count >= 3 then
                return true
            end
        end
    end

    if count >= 3 then
        return true
    end
    return false
end

--三皇五帝 2个5同+3条
function LibSpCardLogic:Check_Pt_Sp_Five_And_Three_King(cards)
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

    --
    local values = {}
    for i=1, 14 do
        values[i] = 0
    end
    for _, v in ipairs(normalCards) do
        local val = GetCardValue(v)
        values[val] = values[val] + 1
    end

    --优先过滤能组成3条或5条的牌   剩余的就是小于4条的牌
    local count5, count3 = 0, 0
    for k, v in ipairs(values) do
        if v == 3 and count3 == 0 then
            count3 = count3 + 1
            values[k] = values[k] - 3
        else
            local n = math.floor(v/5)
            if n >=1 and count5 < 2 then
                for i=1, n do
                    count5 = count5 + 1
                    values[k] = values[k] - 5
                    if count5 == 2 then
                        break
                    end
                end
            end
        end
    end
    if count5 >= 2 and count3 >= 1 then
        return true
    end

    --不够癞子来凑
    if nLaziCount > 0 then
        --从大到小 排序
        table.sort(values, function(a, b)
            return a > b
        end)

        for _, v in ipairs(values) do
            --先凑5条  再凑3条
            if v > 0 then
                if count5 < 2 then
                    if v < 5 then
                        local nSub = 5 - v
                        if nSub <= nLaziCount then
                            count5 = count5 + 1
                            nLaziCount = nLaziCount - nSub
                        else
                            break
                        end
                    end   
                elseif count3 < 1 then
                    if v + nLaziCount >= 3 then
                        count3 = count3 + 1
                    else
                        break
                    end
                end
            end

            if count5 >= 2 and count3 >= 1 then
                return true
            end
        end
    end

    if count5 >= 2 and count3 >= 1 then
        return true
    end
    return false
end

--十二皇族 12张牌全是J、Q、K、A，剩余一张可以是任意牌
function LibSpCardLogic:Check_Pt_Sp_All_King(cards)
    --assert(#cards == MAX_HAND_CARD_NUM)
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

    local count = 0
    for _,v in ipairs(normalCards) do
        local value = GetCardValue(v)
        if value < 11 then  --比J小
            count = count + 1
            if count >= 2 then
                return false
            end
        end
    end

    return true
end

--三同花顺
function LibSpCardLogic:Check_Pt_Sp_Three_Straight_Flush(cards)
    --assert(#cards == MAX_HAND_CARD_NUM)
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
    if nLaziCount == 0 then
        --出现三同花顺时，各花色数量只能为0,3,5,8,10,13(当等于13时为一条龙)
        --先按花色排序
        local flush = {}
        -- LibNormalCardLogic:Sort_By_Color(normalCards)
        --按花色分组
        for k, v in ipairs(normalCards) do
            local color = GetCardColor(v)
            if not flush[color] then
                flush[color] = {}
            end
            table.insert(flush[color], v)
        end

        for _, v in pairs(flush) do
            if not (#v == 0 or #v == 3 or #v == 5 or #v == 8 or #v == 10 or #v == 13) then
                return false
            end
            if #v == 3 or #v == 5 then
                if not LibNormalCardLogic:IsStraight(v) then
                    return false
                end
            end

            if #v == 8 or #v == 10 then
                local pass1, pass2, pass3 = false, false, false
                --情况1 普通顺子
                local tempCards = Array.Clone(v)
                --1.先取一个顺子
                local bSuc, _ = LibNormalCardLogic:Get_Max_Pt_Straight_Normal(tempCards)
                --2.是顺子，再判断剩下的是否是顺子
                if bSuc and LibNormalCardLogic:IsStraight(tempCards) then
                    pass1 = true
                end

                --情况2 A5432
                local tempCards = Array.Clone(v)
                local bSuc, _ = LibNormalCardLogic:Get_Max_Pt_Straight_A(tempCards, 5)
                if bSuc and LibNormalCardLogic:IsStraight(tempCards) then
                    pass2 = true
                end

                --情况3 A32
                if #v == 8 then
                    local tempCards = Array.Clone(v)
                    local bSuc, _ = LibNormalCardLogic:Get_Max_Pt_Straight_A(tempCards, 3)
                    if bSuc and LibNormalCardLogic:IsStraight(tempCards) then
                        pass3 = true
                    end
                end
                
                --必须要满足以上中的一种
                if not (pass1 or pass2 or pass3) then
                    return false
                end 
            end

            if #v == 13 then
                local bStraight = self:Check_Pt_Sp_Three_Straight(normalCards)
                if bStraight == false then
                    return false
                end
            end
        end
    else

        local flush = {}
        local nColorCount = 0
        --按花色分组:0-3
        LibNormalCardLogic:Sort_By_Color(normalCards)
        for k, v in ipairs(normalCards) do
            local color = GetCardColor(v)
            if not flush[color] then
                flush[color] = {}
                nColorCount = nColorCount + 1
            end
            table.insert(flush[color], v)
        end

        --4色
        if nColorCount >= 4 then
            return false
        end
        --1色
        if nColorCount == 1 then
            return self:Check_Pt_Sp_Three_Straight(cards) 
        end

        local bThreeStraight = self:Check_Pt_Sp_Three_Straight(cards)
        local bThreeFlush = self:Check_Pt_Sp_Three_Flush(cards)

        --LOG_DEBUG("Check_Pt_Sp_Three_Straight_Flush....bThreeStraight:%s, bThreeFlush:%s", tostring(bThreeStraight), tostring(bThreeFlush))
        if bThreeStraight and  bThreeFlush then
          return true
        end
        ---TODO:先考虑最多只有两张癞子牌
        --2色
        -- local count5, count3 = 0, 0
        -- if nColorCount == 2 then
        -- end

        -- --3色
        -- count5, count3 = 0, 0
        -- if nColorCount == 3 then
        --     for _, vCards in pairs(flush) do

        --     end
        -- end
    end

    return false
end

--六六大顺  6同
function LibSpCardLogic:Check_Pt_Sp_Six(cards)
    --assert(#cards == MAX_HAND_CARD_NUM)
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

    --
    local values = {}
    for i=1, 14 do
        values[i] = 0
    end
    for _, v in ipairs(normalCards) do
        local val = GetCardValue(v)
        values[val] = values[val] + 1
    end

    for _, v in ipairs(values) do
        if #laiziCards + v >= 6 then
            return true
        end
    end

    return false
end

--全大
function LibSpCardLogic:Check_Pt_Sp_All_Big(cards)
    --assert(#cards == MAX_HAND_CARD_NUM)
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
    for _,v in ipairs(normalCards) do
        local value = GetCardValue(v)
        if value < 8 then  --比8小
            return false
        end
    end
    return true
end

--全小
function LibSpCardLogic:Check_Pt_Sp_All_Small(cards)
    --assert(#cards == MAX_HAND_CARD_NUM)
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
    for _,v in ipairs(normalCards) do
        local value = GetCardValue(v)
        if value > 8 then  --比8大
            return false
        end
    end
    return true
end

--凑一色 13张是黑色牌(梅花+黑桃) 或 是红色牌(方块+红心)
function LibSpCardLogic:Check_Pt_Sp_Same_Suit(cards)
    --assert(#cards == MAX_HAND_CARD_NUM)
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
    local color1 = (GetCardColor(normalCards[1])) % 2
    for _, v in pairs(normalCards) do
        local color2 = (GetCardColor(v)) % 2
        if color1 ~= color2 then
            return false
        end
    end
    return true
end

--五队冲三 5对+3条
function LibSpCardLogic:Check_Pt_Sp_Five_Pair_And_Three(cards)
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

    --
    local values = {}
    for i=1, 14 do
        values[i] = 0
    end
    for _, v in ipairs(normalCards) do
        local val = GetCardValue(v)
        values[val] = values[val] + 1
    end

    --优先过滤能组成3条 对子 牌
    local count2, count3 = 0, 0
    for k, v in ipairs(values) do
        if v == 3 and count3 == 0 then
            count3 = count3 + 1
            values[k] = values[k] - 3
        else
            local n = math.floor(v/2)
            if n >=1 and count2 < 5 then
                for i=1, n do
                    count2 = count2 + 1
                    values[k] = values[k] - 2
                    if count2 == 5 then
                        break
                    end
                end
            end
        end
    end
    -- LOG_DEBUG("=========count2:%d, count3:%d", count2, count3)
    if count2 >= 5 and count3 >= 1 then
        return true
    end

    --不够癞子来凑
    if nLaziCount > 0 then
        --从大到小 排序
        table.sort(values, function(a, b)
            return a > b
        end)
        for _, v in ipairs(values) do
            if v > 0 then
                if count3 < 1 then
                    local nSub = 3 - v
                    if nSub>=0 and nSub <= nLaziCount then
                        nLaziCount = nLaziCount - nSub
                        count3 = count3 + 1
                    else
                        break
                    end
                elseif count2 < 5 then
                    local n = math.floor(v/2)
                    if n >=1 then
                        count2 = count2 + n
                    else
                        local nSub = 2 - v
                        if nSub>=0 and nSub <= nLaziCount then
                            nLaziCount = nLaziCount - nSub
                            count2 = count2 + 1
                        else
                            break
                        end
                    end
                end
            end

            if count2 >= 5 and count3 >= 1 then
                return true
            end
        end
    end

    if count2 >= 5 and count3 >= 1 then
        return true
    end
    return false
end

--六对半   6对+散牌
function LibSpCardLogic:Check_Pt_Sp_Six_Pairs(cards)
    --assert(#cards == MAX_HAND_CARD_NUM)
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

    --
    local values = {}
    for i=1, 14 do
        values[i] = 0
    end
    for _, v in ipairs(normalCards) do
        local val = GetCardValue(v)
        values[val] = values[val] + 1
    end
    --优先过滤能组成3条 对子 牌
    local count6 = 0
    for k, v in ipairs(values) do
        local n = math.floor(v/2)
        -- LOG_DEBUG("=========v:%d--n:%d", v , n)
        if n >=1 then
            count6 = count6 + n
        elseif v > 0 then
            --癞子凑
            local nSub = 2 - v
            if nSub >=0 and nSub <= nLaziCount then
                count6 = count6 + 1
                nLaziCount = nLaziCount - nSub
            end
        end
    end
    -- LOG_DEBUG("============count6:%d", count6)
    if count6 >= 6 then
        return true
    end

    return false
end

--三顺子
function LibSpCardLogic:Check_Pt_Sp_Three_Straight(cards)
    --assert(#cards == MAX_HAND_CARD_NUM)
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

    --找出所有的顺子 A12345,23456,...10JQKA
    local function Find_All_Straight_Laizi(values, nLazi)
        local t = {}
        for i=1, 10 do
            local values2 = Array.Clone(values)
            local straight = true
            local tempLaizi = nLazi
            for j=1, 5 do
                if values2[i+j-1] == 0 then
                    if tempLaizi <= 0 then
                        straight = false
                        break
                    else
                        values2[i+j-1] = 1
                        --对A做处理
                        if i + j - 1 == 1 then
                            values2[14] = 1
                        end
                        if i + j - 1 == 14 then
                            values2[1] = 1
                        end
                        tempLaizi = tempLaizi -1
                    end
                end
            end
            --是顺子
            if straight then
                for k=1, 5 do
                    --数量-1 防止重用
                    values2[i+k-1] = values2[i+k-1] - 1

                    --对A做处理
                    if i + k - 1 == 1 then
                        values2[14] = values2[14] - 1
                    end
                    if i + k - 1 == 14 then
                        values2[1] = values2[1] - 1
                    end
                end

                local found = {}
                found.leftLaizi = tempLaizi
                found.values = values2
                table.insert(t, found)
            end
        end
        return t
    end

    --设置各个牌值的数量
    local values = {}   --[牌值]=数量
    for i=1, 14 do
        values[i] = 0
    end
    for _, v in ipairs(normalCards) do
        local val = GetCardValue(v)
        values[val] = values[val] + 1
    end
    values[1] = values[14]

    --第一组顺子 剔除能组成顺子的牌，把剩余的牌留下
    local pattern1 = Find_All_Straight_Laizi(values, nLaziCount)
    for _, v in ipairs(pattern1) do
        --从第一组剩余的牌找第二组顺子
        local pattern2 = Find_All_Straight_Laizi(v.values, v.leftLaizi)
        for _, v2 in ipairs(pattern2) do
            for i=1, 12 do
                local straight = true
                local nLaiziTCount = v2.leftLaizi
                --从第二组剩余的牌找第三组顺子
                for j=1, 3 do
                    if v2.values[i+j-1] == 0 then
                        if nLaiziTCount <= 0 then
                            straight = false
                            break
                        else
                            nLaiziTCount = nLaiziTCount -1
                        end
                    end
                end
                if straight then
                    return true
                end
            end
        end
    end

    return false
end

--三同花
function LibSpCardLogic:Check_Pt_Sp_Three_Flush(cards)
    --assert(#cards == MAX_HAND_CARD_NUM)
    --出现三同花时，各花色数量只能为0,3,5,8,10,13(当等于13时为一条龙)
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
    --先按花色排序
    local flush = {}
    for i=1, 4 do
        flush[i] = 0
    end

    --按花色分组
    for k, v in ipairs(normalCards) do
        local color = GetCardColor(v) + 1
        flush[color] = flush[color] + 1
    end

    -- LOG_DEBUG("Check_Pt_Sp_Three_Flush.1111.....flush:%s", vardump(flush))

    local nLaziCount = #laiziCards
    -- LOG_DEBUG("=====nLaziCount:%d", nLaziCount)
    if nLaziCount == 0 then
        for _, v in pairs(flush) do
            if not (v == 0 or v == 3 or v == 5 or v == 8 or v == 10 or v == 13) then
                return false
            end
        end 
        return true
    else
        --4色
        local nColorCount = 0
        for i=1, 4 do
            if flush[i] > 0 then
                nColorCount = nColorCount + 1
            end
        end

        if nColorCount >= 4 then
            -- LOG_DEBUG("=111111=======nColorCount:%d", nColorCount)
            return false
        end

        --一色
        if nColorCount == 1 then
            -- LOG_DEBUG("=2222222=======nColorCount:%d", nColorCount)
            return true
        end

        --二色 
        if nColorCount == 2 then
            local count3 = 0
            for _, v in ipairs(flush) do
                if v > 0 then
                    if v > 5 then
                        count3 = count3 + 1
                    elseif v+nLaziCount < 3 then
                        -- LOG_DEBUG("=33333====v:%d===v+nLaziCount:%d", v, v+nLaziCount)              
                        return false
                    end
                end
            end
            if count3 >= 2 then
                -- LOG_DEBUG("=444444=======count3:%d", count3)
                return false
            end
            return true
        end

        --三色
        if nColorCount == 3 then
            --从小到大
            table.sort(flush, function(a, b)
                return a < b
            end)
            -- LOG_DEBUG("Check_Pt_Sp_Three_Flush.22222222.....flush:%s", vardump(flush))
            
            local count5, count3 = 0, 0
            for k, v in ipairs(flush) do
                -- LOG_DEBUG("Check_Pt_Sp_Three_Flush......nLaziCount:%d, k:%d, v:%d", nLaziCount, k, v)
                if v > 0 then
                    if count3 < 1 then
                        if v == 3 then
                            count3 = count3 + 1
                        elseif v < 3 then
                            local nSub = 3 - v
                            if nSub <= nLaziCount then
                                count3 = count3 + 1
                                nLaziCount = nLaziCount - nSub
                            else
                                -- LOG_DEBUG("=5555555=====v:%d==count3:%d", v, count3)
                                return false
                            end
                        elseif v > 3 then
                            break
                        end
                    elseif count5 < 2 then
                        if v == 5 then
                            count5 = count5 + 1
                        elseif v < 5 then
                            local nSub = 5 - v
                            if nSub <= nLaziCount then
                                count5 = count5 + 1
                                nLaziCount = nLaziCount - nSub
                            else
                                -- LOG_DEBUG("=6666666====v:%d===count5:%d", v, count5)
                                return false
                            end
                        elseif v > 5 then
                            -- LOG_DEBUG("=777777777====v:%d===count5:%d", v, count5)
                            return false
                        end
                    end

                    if count5 >= 2 and count3 >= 1 then
                        return true
                    end
                end
            end

            if count5 >= 2 and count3 >= 1 then
                return true
            end
        end 
    end
    return false  
end
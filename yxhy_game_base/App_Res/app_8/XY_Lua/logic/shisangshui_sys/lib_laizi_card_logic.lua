
require "logic/shisangshui_sys/lib_laizi"
require "logic/shisangshui_sys/common/array"

LibLaiziCardLogic = {}
function LibLaiziCardLogic:ctor()
end

function LibLaiziCardLogic:CreateInit(strSlotName)
    return true
end

function LibLaiziCardLogic:OnGameStart()
end

--按值降序 14（A）-2
function LibLaiziCardLogic:Sort(cards)
    -- LOG_DEBUG("LibLaiziCardLogic:Sort_down..before, cards: %s\n", TableToString(cards))
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
    -- LOG_DEBUG("LibLaiziCardLogic:Sort_down..end, cards: %s\n", TableToString(cards))
end


--是否是同花
function LibLaiziCardLogic:IsFlush_Laizi(cards)
    -- LOG_DEBUG("LibLaiziCardLogic:IsFlush_Laizi..before, cards: %s\n", TableToString(cards))
    if #cards == 0 then
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

    local t = {}
    local bSuc = false

    local color = GetCardColor(normalCards[1])
    for i=2, #normalCards do
        if color ~= GetCardColor(normalCards[i]) then
            return false
        end
    end
    -- LOG_DEBUG("LibLaiziCardLogic:IsFlush_Laizi..end, cards: %s\n", TableToString(cards))
    return true
end

--是否是顺子
function LibLaiziCardLogic:IsStraight_Laizi(cards)
     -- LOG_DEBUG("LibLaiziCardLogic:IsStraight_Laizi..before, cards: %s\n", TableToString(cards))
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

    local t = {}
    local bSuc = false
    local nLen = #normalCards
   
	LibNormalCardLogic:Sort(normalCards)
	local v1, vn = GetCardValue(normalCards[1]),GetCardValue(normalCards[nLen])

	--此处判断唯一
	local n = LibNormalCardLogic:Uniqc(normalCards)
	if n ~= nLen then
		return false
	else
		if vn ~= 14 then
			if vn - v1 > 4 then
				return false
			else
				return true
			end
		else
			local vm = GetCardValue(normalCards[nLen-1])
			if vm > 5 then
				if vn - v1 > 4 then
					return false
				else
					return true
				end    
			end
			return true
		end
	end 
end

--各墩牌的类型(对内外接口)
function LibLaiziCardLogic:GetCardType_Laizi(cards)
    local cardType = GStars_Normal_Type.PT_ERROR
    local tempCards = Array.Clone(cards)
    -- LOG_DEBUG("LibLaiziCardLogic:GetCardType_Laizi.., cards: %s\n", TableToString(cards))

     --1.把癞子牌和普通牌分离
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

    if #tempCards == 3 then
        --前墩
        local n = LibNormalCardLogic:Uniqc(normalCards)
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
        local bFlush = LibLaiziCardLogic:IsFlush_Laizi(tempCards)
        local bStraight = LibLaiziCardLogic:IsStraight_Laizi(tempCards)
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
            LibNormalCardLogic:Sort(tempCards)
            local n = LibNormalCardLogic:Uniqc(normalCards)
            if n == 1 then
                cardType = GStars_Normal_Type.PT_FIVE
            elseif n == 2 then
                local v1 = GetCardValue(tempCards[1])
                local v2 = GetCardValue(tempCards[2])
                local v3 = GetCardValue(tempCards[3])
                local v4 = GetCardValue(tempCards[4])
                local v5 = GetCardValue(tempCards[5])
                if #laiziCards == 0 then
                    if v1 == v2 and v4 == v5 then
                        cardType = GStars_Normal_Type.PT_FULL_HOUSE
                    else
                        cardType = GStars_Normal_Type.PT_FOUR
                    end
                else
                    if v1 == v2 and v3 == v4 and v4 ~= laiziCards[#laiziCards] then
                        cardType = GStars_Normal_Type.PT_FULL_HOUSE
                    else
                        cardType = GStars_Normal_Type.PT_FOUR
                    end
                end
            elseif n == 3 then
                local v1 = GetCardValue(tempCards[1])
                local v2 = GetCardValue(tempCards[2])
                local v3 = GetCardValue(tempCards[3])
                local v4 = GetCardValue(tempCards[4])
                local v5 = GetCardValue(tempCards[5])
                if #laiziCards > 0 then
                    cardType = GStars_Normal_Type.PT_THREE
                else
                    if v1 == v3 or v2 == v4 or v3 == v5 then
                        cardType = GStars_Normal_Type.PT_THREE
                    else
                        cardType = GStars_Normal_Type.PT_TWO_PAIR
                    end
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

    -- LOG_DEBUG("LibLaiziCardLogic:GetCardType_Laizi.., cardType: %d\n", cardType)
    return cardType
end

--获取癞子数量
function LibLaiziCardLogic:GetLaiziNum(cards)
    local laiziCards = {}
    for _, v in ipairs(cards) do
        local nValue = GetCardValue(v)
        if LibLaiZi:IsLaiZi(nValue) then
            table.insert(laiziCards, v)
        end
    end
    return #laiziCards
end

--获取最大的n张相同的牌
function LibLaiziCardLogic:Get_Maxn_Value(cards, vNum)
    --1.把癞子牌和普通牌分离
    local laiziCards = {}
    local normalCards = {}
    for _, v in ipairs(cards) do
        local nValue = GetCardValue(v)
        if LibLaiZi:IsLaiZi(nValue) then
            table.insert(laiziCards, v)
        else
            table.insert(normalCards, v)
        end
    end
    LibLaiziCardLogic:Sort(normalCards)
    local t = {}
    local ValueNum = {}
    local tempVal = nil
    local bSuc = false
    for _, v in ipairs(normalCards) do
        local val = GetCardValue(v)
        if tempVal == val then
            ValueNum[val] = ValueNum[val] + 1
        else
            ValueNum[val] = 1
            tempVal = val
        end
    end 
    local nLaizi = #laiziCards 
    for k, v in pairs(ValueNum) do
        local Num = GetCardValue(v)
        if vNum == Num + nLaizi then
            bSuc = true
            for i=1, Num do
                table.insert(t, k)
            end
            return bSuc, t
        end
    end
    return bSuc, t
end
--普通牌型比牌(对外接口)
function LibLaiziCardLogic:CompareCards_Laizi(cardsA, cardsB)
    -- LOG_DEBUG("LibLaiziCardLogic:CompareCards_Laizi.., cardsA: %s, cardsB: %s\n", TableToString(cardsA), TableToString(cardsB))
    local tempA = Array.Clone(cardsA)
    local tempB = Array.Clone(cardsB)
    local type1 = LibLaiziCardLogic:GetCardType_Laizi(tempA)
    local type2 = LibLaiziCardLogic:GetCardType_Laizi(tempB)
    -- LOG_DEBUG("LibLaiziCardLogic:CompareCards_Laizi.., type1: %d, type2: %d\n", type1, type2)
   
    LibNormalCardLogic:Sort(tempA)
    LibNormalCardLogic:Sort(tempB)

    if type1 == type2 then
        if type1 == GStars_Normal_Type.PT_ONE_PAIR then

            local vNum = 2
            local bSuc = false
            local t = {}
            local p1 = 0
            local p2 = 0
            bSuc, t = LibLaiziCardLogic:Get_Maxn_Value(tempA, vNum)
            if bSuc then
                p1 = t[#t]
                LibNormalCardLogic.RemoveCard(tempA, t)
            end
            bSuc, t = LibLaiziCardLogic:Get_Maxn_Value(tempB, vNum)
            if bSuc then
                p2 = t[#t]
                LibNormalCardLogic.RemoveCard(tempB, t)
            end
            if p1 ~= p2 then
                return p1 - p2
            end
        elseif type1 == GStars_Normal_Type.PT_TWO_PAIR then
            --先比较大对子，大对子相等比较小对子
            local pa1, pb1 = LibNormalCardLogic:GetPairValue(tempA)
            local pa2, pb2 = LibNormalCardLogic:GetPairValue(tempB)
            local n = pb1 - pb2
            if n == 0 then
                n = pa1 - pa2
            end
            if n ~= 0 then
                return n
            end
        elseif type1 == GStars_Normal_Type.PT_THREE then
            local vNum = 3
            local bSuc = false
            local t = {}
            local p1 = 0
            local p2 = 0
            bSuc, t = LibLaiziCardLogic:Get_Maxn_Value(tempA, vNum)
            if bSuc then
                p1 = t[#t]
                LibNormalCardLogic.RemoveCard(tempA, t)
            end
            bSuc, t = LibLaiziCardLogic:Get_Maxn_Value(tempB, vNum)
            if bSuc then
                p2 = t[#t]
                LibNormalCardLogic.RemoveCard(tempB, t)
            end
            if p1 ~= p2 then
                return p1 - p2
            end
        elseif type1 == GStars_Normal_Type.PT_FULL_HOUSE then
            --葫芦这里如果三个的相等 还得比较一对
            local vNum = 3
            local bSuc = false
            local t = {}
            local p1 = 0
            local p2 = 0
            bSuc, t = LibLaiziCardLogic:Get_Maxn_Value(tempA, vNum)
            if bSuc then
                p1 = t[#t]
                LibNormalCardLogic.RemoveCard(tempA, t)
            end
            bSuc, t = LibLaiziCardLogic:Get_Maxn_Value(tempB, vNum)
            if bSuc then
                p2 = t[#t]
                LibNormalCardLogic.RemoveCard(tempB, t)
            end
            if p1 ~= p2 then
                return p1 - p2
            else
                local pa1 = LibNormalCardLogic:GetPairValue(tempA)
                local pa2 = LibNormalCardLogic:GetPairValue(tempB)
                if pa1 ~= pa2 then
                    return pa1 - pa2
                end
            end
        elseif type1 == GStars_Normal_Type.PT_FOUR then
            local vNum = 4
            local bSuc = false
            local t = {}
            local p1 = 0
            local p2 = 0
            bSuc, t = LibLaiziCardLogic:Get_Maxn_Value(tempA, vNum)
            if bSuc then
                p1 = t[#t]
                LibNormalCardLogic.RemoveCard(tempA, t)
            end
            bSuc, t = LibLaiziCardLogic:Get_Maxn_Value(tempB, vNum)
            if bSuc then
                p2 = t[#t]
                LibNormalCardLogic.RemoveCard(tempB, t)
            end
            if p1 ~= p2 then
                return p1 - p2
            end
        elseif type1 == GStars_Normal_Type.PT_FLUSH then
            --水庄 比较对同花
            --if GGameCfg.GameSetting.bSupportWaterBanker then
                local pa1, pb1 = LibLaiziCardLogic:GetPairValue_Laizi(tempA)
                local pa2, pb2 = LibLaiziCardLogic:GetPairValue_Laizi(tempB)
                --先比大对子  再比小对 最后比单张大小
                local n = pb1 - pb2
                if n == 0 then
                    n = pa1 - pa2
                end
                -- LOG_DEBUG("flush compare,  n= %d", n)
                if n ~= 0 then
                    return n
                end 
            --end
        end
        --比单张
        return LibLaiziCardLogic:CompareSingle(tempA, tempB)
    else
        return type1 - type2
    end
end

--返回值0表示没对子, 值是按从小到大返回的
function LibLaiziCardLogic:GetPairValue_Laizi(cards)
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

    local t = {}
    local bSuc = false
    local nLen = #normalCards
    local nLaizi = #laiziCards
    local ret = {}
    local tempVal = nil
    LibNormalCardLogic:Sort(normalCards)
    if nLaizi == 0 then
        for _, v in ipairs(normalCards) do
            local val = GetCardValue(v)
            if tempVal == val and ret[#ret] ~= val then
                table.insert(ret, val)
            else
                tempVal = val
            end
        end
    else
        for _, v in ipairs(normalCards) do
            local val = GetCardValue(v)
            if tempVal == val and ret[#ret] ~= val then
                table.insert(ret, val)
                break
            else
                tempVal = val
            end
        end
        if val ~= normalCards[nLen] then
            table.insert(ret, normalCards[nLen])
        else
            table.insert(ret, normalCards[nLen-1])
        end
    end

    -- LOG_DEBUG("LibLaiziCardLogic:GetPairValue..ret: %s\n", vardump(ret))
    --return table.unpack(ret)
    return (ret[1] or 0), (ret[2] or 0)
end

--比较散牌：从大到小 一对一比较
function LibLaiziCardLogic:CompareSingle(cardsA, cardsB)
    if #cardsA == 0 and #cardsB == 0 then
        return 0
    elseif #cardsA == 0 then
        return -1
    elseif #cardsB == 0 then
        return 1
    end
    -- LOG_DEBUG("LibLaiziCardLogic:CompareSingle(cardsA, %s\n", TableToString(cardsA))
    -- LOG_DEBUG("LibLaiziCardLogic:CompareSingle(cardsB, %s\n", TableToString(cardsB))
    LibNormalCardLogic:Sort(cardsA)
    LibNormalCardLogic:Sort(cardsB)

    local va = GetCardValue(cardsA[#cardsA])
    local vb = GetCardValue(cardsB[#cardsB])
    local n = va - vb
    if n ~= 0 then
        return n
    else
        table.remove(cardsA)
        table.remove(cardsB)
        return LibLaiziCardLogic:CompareSingle(cardsA, cardsB) 
    end
end

--==================配牌库 癞子牌型=========================

--癞子牌获取最大5张牌
function LibLaiziCardLogic:GetMaxFiveCard_Laizi(cards)
    -- LOG_DEBUG("LibLaiziCardLogic:GetMaxFiveCard_Laizi..before, cards: %s\n", TableToString(cards))

    if #cards < 5 then
        LOG_ERROR(" LibLaiziCardLogic:GetMaxFiveCard_Laizi Failed.Card is not enough %d", #cards);
        return nil
    end

    --5同
    local suc, t = LibLaiziCardLogic:Get_Max_Pt_Five_Laizi(cards)
    if suc then
        return t
    end

    --同花顺
    local suc, t = LibLaiziCardLogic:Get_Max_Pt_Straight_Flush_Laizi(cards)
    if suc then
        return t
    end

    --铁枝
    local suc, t = LibLaiziCardLogic:Get_Max_Pt_Four_Laizi(cards)
    if suc then
        local _, tempCard = LibLaiziCardLogic:Get_Max_Pt_Single_Laizi(cards)
        table.insert(t, tempCard)
        return t
    end

    --葫芦
    local suc, t = LibLaiziCardLogic:Get_Max_Pt_Full_Hosue_Laizi(cards)
    if suc then
        return t
    end

    --同花
    local suc, t = LibLaiziCardLogic:Get_Max_Pt_Flush_Laizi(cards)
    if suc then
        return t
    end

    --顺子
    local suc, t = LibLaiziCardLogic:Get_Max_Pt_Straight_Laizi(cards)
    if suc then
        return t
    end

    --三条
    local suc, t = LibLaiziCardLogic:Get_Max_Pt_Three_Laizi(cards)
    if suc then
        for i=1, 2 do
            local _, tempCard = LibLaiziCardLogic:Get_Max_Pt_Single_Laizi(cards)
            table.insert(t, tempCard)
        end
        return t
    end

    --两对
    local suc, t = LibLaiziCardLogic:Get_Max_Pt_Two_Pair_Laizi(cards)
    if suc then
        local _, tempCard = LibLaiziCardLogic:Get_Max_Pt_Single_Laizi(cards)
        table.insert(t, tempCard)
        return t
    end

    --一对
    local suc, t = LibLaiziCardLogic:Get_Max_Pt_One_Pair_Laizi(cards)
    if suc then
        for i=1, 3 do
            local _, tempCard = LibLaiziCardLogic:Get_Max_Pt_Single_Laizi(cards)
            table.insert(t, tempCard)
        end
        return t
    end

    --乌龙
    local t = {}
    for i=1, 5 do
        local _, tempCard = LibLaiziCardLogic:Get_Max_Pt_Single_Laizi(cards)
        table.insert(t, tempCard)
    end

    -- LOG_DEBUG("LibLaiziCardLogic:GetMaxFiveCard_Laizi..end, cards: %s\n", TableToString(cards))
    -- LOG_DEBUG("LibLaiziCardLogic:GetMaxFiveCard_Laizi..table t: %s\n", TableToString(t))
    return t
end

--癞子牌获取最大3张牌
function LibLaiziCardLogic:GetMaxThreeCard_Laizi(cards)
    -- LOG_DEBUG("LibLaiziCardLogic:GetMaxThreeCard..before, cards: %s\n", TableToString(cards))
    if #cards < 3 then
        -- LOG_ERROR(" LibLaiziCardLogic:GetMaxThreeCard Failed.Card is not enough %d", #cards);
        return nil
    end
    --三条
    local suc, t = LibLaiziCardLogic:Get_Max_Pt_Three_Laizi(cards)
    if suc then
        return t
    end

    --一对
    local suc, t = LibLaiziCardLogic:Get_Max_Pt_One_Pair_Laizi(cards)
    if suc then
        local _, tempCard = LibLaiziCardLogic:Get_Max_Pt_Single_Laizi(cards)
        table.insert(t, tempCard)
        return t
    end

    --乌龙
    local t = {}
    for i=1, 3 do
        local _, tempCard = LibLaiziCardLogic:Get_Max_Pt_Single_Laizi(cards)
        table.insert(t, tempCard)
    end

    -- LOG_DEBUG("LibLaiziCardLogic:GetMaxThreeCard..end, cards: %s\n", TableToString(cards))
    -- LOG_DEBUG("LibLaiziCardLogic:GetMaxThreeCard..get table t: %s\n", TableToString(t))

    return t
end

--====下面是配牌函数=========
--同花顺
function LibLaiziCardLogic:Get_Max_Pt_Straight_Flush_Laizi(cards)
    -- LOG_DEBUG("Get_Max_Pt_Straight_Flush_Laizi..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 5 then
        return false
    end
    --1.把癞子牌和普通牌分离
    local normalCards = {}
    local laiziCards = {}
     local deliveryCards = {}
    for _, v in ipairs(cards) do
        local nValue = GetCardValue(v)
        if LibLaiZi:IsLaiZi(nValue) then
            table.insert(laiziCards, v)
        else
            table.insert(normalCards, v)
            table.insert(deliveryCards, v)
        end
    end

    local t = {}
    local bSuc = false
    local nLen = #normalCards
    local nLaizi = #laiziCards

     table.insert(deliveryCards, #laiziCards)
    -- LOG_DEBUG("before test tonghuashunzi ---: %s\n", TableToString(deliveryCards))
    local result =  card_algrithm_test.get_the_same_color_tonghuashun(deliveryCards)
    -- LOG_DEBUG("after test tonghuashunzi ---: %s\n", TableToString(t))

    --同花顺子算法
    local shunziMaxCards = card_vec[#card_vec]
    local nLastValue = card_vec[#card_vec]
    LibLaiziCardLogic:Sort(normalCards)
    local ntemp = 0
    if shunziMaxCards >=5 then
        for _, v in ipairs(normalCards) do
            local nValue = GetCardValue(v)
            if nValue == shunziMaxCards and ntemp < 1 then
                table.insert(t, v)
                ntemp = ntemp + 1
            end
            if nValue <= shunziMaxCards then
                local subValue = nLastValue - nValue
                if subValue ~= 0 then
                    if subValue > 1 then
                        for i=1, subValue-1, 1 do
                            table.insert(t, laiziCards[nLaizi])
                            nLaizi = nLaizi - 1
                            if #t >= 5 then
                                LibNormalCardLogic:RemoveCard(cards, t)
                                return true, t
                            end
                        end
                    else
                        table.insert(t, v)
                        if #t >= 5 then
                            LibNormalCardLogic:RemoveCard(cards, t)
                            return true, t
                        end
                    end
                end
                nLastValue = nValue
            end
        end   
    end
    return false
--[[
    --2.判断是否有癞子
    local bSuc = false
    local t = {}
    if #laiziCards == 0 then
        bSuc, t = LibNormalCardLogic:Get_Max_Pt_Straight_Flush(normalCards)
        if bSuc then
            return bSuc, t
        end
    else
        --先按花色排序
        local flush = {}
        LibNormalCardLogic:Sort_By_Color(normalCards)
        --按花色分组
        for k, v in ipairs(normalCards) do
            local color = GetCardColor(v)
            if not flush[color] then
                flush[color] = {}
            end
            table.insert(flush[color], v)
            LOG_DEBUG("Get_Max_Pt_Straight_Flush_Laizi..have laizi --00: %s\n", TableToString(flush[color]))   
        end
        --
        local bFound = false
        local temp = nil
        for _, v in pairs(flush) do
            for i=#laiziCards, 1, -1 do
                table.insert(v, laiziCards[nLaizi])
                nLaizi = nLaizi - 1
            end
            nLaizi = #laiziCards
            local bSuc, t = LibLaiziCardLogic:Get_Max_Pt_Straight_Laizi(v)
            if bSuc then
                if temp then
                    --比较 找最大的顺子
                    local nRet = LibNormalCardLogic:CompareCards(temp, t)
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
            LibNormalCardLogic:RemoveCard(cards, temp)
            LOG_DEBUG("Get_Max_Pt_Straight_Flush_Laizi..get table t success: %s\n", TableToString(temp))
        else
            LOG_DEBUG("Get_Max_Pt_Straight_Flush_Laizi..get table t Failed: %s\n", TableToString(temp))
        end
        return bFound, temp
    end
    ]]
end

--同花
function LibLaiziCardLogic:Get_Max_Pt_Flush_Laizi(cards)
    -- LOG_DEBUG("Get_Max_Pt_Flush_Laizi..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 5 then
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

    local t = {}
    local bSuc = false
    local nLen = #normalCards
    local nLaizi = #laiziCards
    
    --2.判断是否有癞子
    local bSuc = false
    local t = {}
    if #laiziCards == 0 then
        bSuc, t = LibNormalCardLogic:Get_Max_Pt_Flush(cards)
        if bSuc then
            return bSuc, t
        end
    else
        --先按花色排序
        local flush = {}
        LibNormalCardLogic:Sort_By_Color(normalCards)
        --按花色分组
        for k, v in ipairs(normalCards) do
            local color = GetCardColor(v)
            if not flush[color] then
                flush[color] = {}
            end
            table.insert(flush[color], v)
            -- LOG_DEBUG("Get_Max_Pt_Flush_Laizi..colorsort --00: %s\n", TableToString(flush[color])) 
        end
        --再遍历找同花
        local bFound = false
        local t = {}
        for _, v in pairs(flush) do
            local len = #v
            if len + nLaizi >= 5 then
                for i=len, 1, -1 do
                    table.insert(t, v[len])
                len = len - 1
                end
                for i=nLaizi, 1, -1 do
                    table.insert(t, laiziCards[nLaizi])
                    nLaizi = nLaizi - 1
                end
                --LOG_DEBUG("Get_Max_Pt_Flush_Laizi..success --00: %s\n", TableToString(flush[color])) 
                bFound = true
                break
            end  
        end
        if bFound then
            bSuc = true
            LibLaiziCardLogic:RemoveCard(cards, t)
            -- LOG_DEBUG("Get_Max_Pt_Flush_Laizi..get table t success: %s\n", TableToString(t))
        else
             -- LOG_DEBUG("Get_Max_Pt_Flush_Laizi..table t Failed: %s\n", TableToString(t))
        end  
    end
    return bSuc, t
end

--顺子 10JQKA > A2345 > 910JQK > ...> 23456
function LibLaiziCardLogic:Get_Max_Pt_Straight_Laizi(cards)
    -- LOG_DEBUG("Get_Max_Pt_Straight_Laizi..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards < 5 then
        return false
    end
    --1.把癞子牌和普通牌分离
    local normalCards = {}
    local laiziCards = {}
     local deliveryCards = {}
    for _, v in ipairs(cards) do
        local nValue = GetCardValue(v)
        if LibLaiZi:IsLaiZi(nValue) then
            table.insert(laiziCards, v)
        else
            table.insert(normalCards, v)
            table.insert(deliveryCards, v)
        end
    end

    local t = {}
    local bSuc = false
    local nLen = #normalCards
    local nLaizi = #laiziCards

    table.insert(deliveryCards, #laiziCards)
    -- LOG_DEBUG("test shunzi ---: %s\n", TableToString(deliveryCards))
    local result =  card_algrithm_test.get_not_the_same_color_tonghuashun(deliveryCards)
    -- LOG_DEBUG("after test tonghuashunzi ---: %s\n", TableToString(card_vec))
   
    --顺子的算法
    local shunziMaxCards = card_vec[#card_vec]
    local nLastValue = card_vec[#card_vec]
    LibLaiziCardLogic:Sort(normalCards)
    if shunziMaxCards >=5 then
        for _, v in ipairs(normalCards) do
            local nValue = GetCardValue(v)
            if nValue <= shunziMaxCards then
                local subValue = nLastValue - nValue
                if subValue ~= 0 then
                    if subValue > 1 then
                        for i=1, subValue-1, 1 do
                            table.insert(t, laiziCards[nLaizi])
                            nLaizi = nLaizi - 1
                            if #t >= 5 then
                                LibNormalCardLogic:RemoveCard(cards, t)
                                return true, t
                            end
                        end
                    else
                        table.insert(t, v)
                        if #t >= 5 then
                            LibNormalCardLogic:RemoveCard(cards, t)
                            return true, t
                        end
                    end
                end
                nLastValue = nValue
            end
        end   
    end
--[[
    --2.判断是否有癞子
    local bSuc = false
    local t = {}
    if #laiziCards == 0 then
        bSuc, t = LibNormalCardLogic:Get_Max_Pt_Straight(normalCards)
        if bSuc then
            return bSuc, t
        end
    else
        local bSuc1, t1 = self:Get_Max_Pt_Straight_Normal_Laizi(normalCards, laiziCards)
        --顺子10JQKA
        if bSuc1 and GetCardValue(t1[1]) == 14 then
            LOG_DEBUG("Get_Max_Pt_Straight_Normal_Laizi..end, cards: %s\n", TableToString(normalCards))
            LOG_DEBUG("Get_Max_Pt_Straight_Normal_Laizi..get table t1: %s\n", TableToString(t1))
            LibNormalCardLogic:RemoveCard(cards, t1)
            return true, t1
        end

        --顺子A2345
        local bSuc2, t2 = self:Get_Max_Pt_Straight_A_Laizi(normalCards, laiziCards)
        if bSuc2 then
            LOG_DEBUG("Get_Max_Pt_Straight_A_Laizi..end, cards: %s\n", TableToString(normalCards))
            LOG_DEBUG("Get_Max_Pt_Straight_A_Laizi..get table t2: %s\n", TableToString(t2))
            LibNormalCardLogic:RemoveCard(cards, t2)
            return true, t2
        end

        --普通顺子
        if bSuc1 then
            LOG_DEBUG("Get_Max_Pt_Straight_Normal_Laizi..end, cards: %s\n", TableToString(normalCards))
            LOG_DEBUG("Get_Max_Pt_Straight_Normal_Laizi..get table t1: %s\n", TableToString(t1))
            LibNormalCardLogic:RemoveCard(cards, t1)
            return true, t1
        end
    end
    ]]

    -- LOG_DEBUG("Get_Max_Pt_Straight..Failed, cards: %s\n", TableToString(normalCards))
    return false
end

function LibLaiziCardLogic:Get_Max_Pt_Straight_Normal_Laizi(normalCards, laiziCards)
    --排序
    LibNormalCardLogic:Sort(normalCards)

    local t = {}
    local bSuc = false
    local nLen = #normalCards
    local nLaizi = #laiziCards

    local nLastValue = GetCardValue(normalCards[nLen])
    table.insert(t, normalCards[nLen])
    --找最大  癞子牌往最大的放
    if nLaizi >0 and #t < 5 and #t + nLaizi >=5 then
        local nMaxValue = GetCardValue(t[1])
        local nNeedCount = 5 - #t
        for j=1, nNeedCount do
            if nMaxValue + j <= 14 then
                table.insert(t, 1, laiziCards[nLaizi])
                nLaizi = nLaizi - 1
            else
                break
            end
        end
    end
    -- LOG_DEBUG("Get_Max_Pt_Straight_Normal_Laizi MaxCards: %s\n", TableToString(t))
    if #t >= 5 then
        -- LOG_DEBUG("Get_Max_Pt_Straight_Normal_Laizi..get table t success: %s\n", TableToString(t))
        return true, t
    end

    for i=nLen-1, 1, -1 do
        local nValue = GetCardValue(normalCards[i])
        local nSubValue = nLastValue - nValue
        if nSubValue == 0 then
            --有对子
            nLaizi = #laiziCards
            t = {}
            table.insert(t, normalCards[i])
            -- LOG_DEBUG("Get_Max_Pt_Straight_Normal_Laizi have pairs: %s\n", TableToString(t))
        elseif nSubValue ~= 1 then
            -- LOG_DEBUG("Get_Max_Pt_Straight_Normal_Laizi no pairs: %s\n", TableToString(t))
            if nLaizi > 0 then
                --不是连着  癞子来补
                -- LOG_DEBUG("Get_Max_Pt_Straight_Normal_Laizi have laiziNum: %d\n", nLaizi)
                if nSubValue -1 >= nLaizi then
                    nLaizi = #laiziCards
                    t = {}
                    table.insert(t, normalCards[i])
                else
                    for j=1, nSubValue-1 do
                        table.insert(t, laiziCards[nLaizi])
                        nLaizi = nLaizi - 1
                    end
                    table.insert(t, normalCards[i])
                end
            else
                nLaizi = #laiziCards
                t = {}
                table.insert(t, normalCards[i])
            end
        else
            table.insert(t, normalCards[i])
        end
        nLastValue = nValue  
        -- LOG_DEBUG("Get_Max_Pt_Straight_Normal_Laizi cards: %s\n", TableToString(t))
        --找最大  癞子牌往最大的放
        if nLaizi >0 and #t < 5 and #t + nLaizi >=5 then
            local nMaxValue = GetCardValue(t[1])
            local nNeedCount = 5 - #t
            for j=1, nNeedCount do
                if nMaxValue + j <= 14 then
                    table.insert(t, 1, laiziCards[nLaizi])
                    nLaizi = nLaizi - 1
                else
                    break
                end
            end
        end
        if #t >= 5 then
            bSuc = true
            -- LOG_DEBUG("Get_Max_Pt_Straight_Normal_Laizi.. success: %s\n", TableToString(t))
            break
        end
    end
    -- LOG_DEBUG("Get_Max_Pt_Straight_Normal_Laizi.. Failed: %s\n", TableToString(t))
    return bSuc, t
end

function LibLaiziCardLogic:Get_Max_Pt_Straight_A_Laizi(normalCards, laiziCards)
    local nLastValue = GetCardValue(normalCards[#normalCards])
    -- LOG_DEBUG("Get_Max_Pt_Straight_A_Laizi..begin--1 %d\n",nLastValue)
   --排序
    LibNormalCardLogic:Sort(normalCards)

    local t = {}
    local bSuc = false
    local nLen = #normalCards
    local nLaizi = #laiziCards

    local nFirstValue = GetCardValue(normalCards[1])
    table.insert(t, normalCards[1])
    --找最小  癞子牌往最小的放
    if nLaizi >0 and #t < 4 and #t + nLaizi >= 5 then
        local nMinValue = GetCardValue(t[1])
        local nNeedCount = 4 - #t
        for j=1, nNeedCount do
            if nMinValue - j >= 2 then
                table.insert(t, -1, laiziCards[nLaizi])
                nLaizi = nLaizi - 1
            else
                if #t == 4 then
                    if normalCards[#normalCards] == 14 then
                        table.insert(t, 1, normalCards[#normalCards])
                        return true, t
                    elseif nLaizi > 0 then
                        table.insert(t, 1, laiziCards[nLaizi])
                        return true, t 
                    end
                end
                break
            end
        end
    end
    -- LOG_DEBUG("Get_Max_Pt_Straight_A_Laizi..firstCards: %s\n", TableToString(t))
    for i=2, 5, 1 do
        local nValue = GetCardValue(normalCards[i])
        local nSubValue = nValue - nFirstValue
        -- LOG_DEBUG("Get_Max_Pt_Straight_A_Laizi..get table t--3: %s\n", TableToString(t))
        if nSubValue == 0 then
            --有对子
            nLaizi = #laiziCards
            t = {}
            table.insert(t, normalCards[i])
        elseif nSubValue ~= 1 then
            if nLaizi > 0 then
                --不是连着  癞子来补
                if nSubValue -1 > nLaizi then
                    return false
                elseif nSubValue -1 == 0 then
                    table.insert(t, 1, normalCards[i])
                else
                    for j=1, nSubValue-1 do
                        table.insert(t, laiziCards[nLaizi])
                        nLaizi = nLaizi - 1
                    end
                    if #t >= 4 then
                        if nLastValue == 14 then
                            table.insert(t, 1, normalCards[#normalCards])
                            -- LOG_DEBUG("Get_Max_Pt_Straight_A_Laizi..success--4: %s\n", TableToString(t))
                            return true, t
                        elseif nLaizi > 0 then
                            table.insert(t, 1, laiziCards[nLaizi])
                            -- LOG_DEBUG("Get_Max_Pt_Straight_A_Laizi..success--5: %s\n", TableToString(t))
                            return true, t 
                        end
                    end 
                end
            else
                table.insert(t, normalCards[i]) 
            end
        else
            table.insert(t, normalCards[i]) 
        end
        nFirstValue = nValue
        -- LOG_DEBUG("Get_Max_Pt_Straight_A_Laizi..get table t--00: %s\n", TableToString(t))
        --找最小  癞子牌往最小的放
        if nLaizi >0 and #t < 4 and #t + nLaizi >= 4 then
            local nMinValue = GetCardValue(t[1])
            local nNeedCount = 4 - #t
            for j=1, nNeedCount do
                if nMinValue - j >= 2 then
                    table.insert(t, 1, laiziCards[nLaizi])
                    nLaizi = nLaizi - 1
                else
                    if #t == 4 then
                        if nLastValue == 14 then
                            table.insert(t, 1, normalCards[#normalCards])
                            -- LOG_DEBUG("Get_Max_Pt_Straight_A_Laizi..success--6: %s\n", TableToString(t))
                            return true, t
                        elseif nLaizi > 0 then
                            table.insert(t, 1, laiziCards[nLaizi])
                            -- LOG_DEBUG("Get_Max_Pt_Straight_A_Laizi..success-7: %s\n", TableToString(t))
                            return true, t 
                        end
                    end
                    break
                end
            end
        end
        if #t >= 4 then
            bSuc = true
            if nLastValue == 14 then
                table.insert(t, 1, normalCards[#normalCards])
                -- LOG_DEBUG("Get_Max_Pt_Straight_A_Laizi..success--8: %s\n", TableToString(t))
                return true, t
            elseif nLaizi > 0 then
                table.insert(t, 1, laiziCards[nLaizi])
                -- LOG_DEBUG("Get_Max_Pt_Straight_A_Laizi..success--9: %s\n", TableToString(t))
                return true, t 
            end
            -- LOG_DEBUG("Get_Max_Pt_Straight_A_Laizi..get table t--10: %s\n", TableToString(t))
            break
        end
    end

    -- LOG_DEBUG("Get_Max_Pt_Straight_A_Laizi..Failed--11\n")
    return bSuc, t
end

--获取相同的牌  数量
function LibLaiziCardLogic:Get_Same_Maxn_Value(cards, vNum)
    -- LOG_DEBUG("LibLaiziCardLogic:Get_Same_Maxn_Value..before, cards--: %s\n", TableToString(cards))
    -- LOG_DEBUG("LibLaiziCardLogic:Get_Same_Maxn_Value..before, vNum--: %d\n", vNum)
    if (type(cards) ~= "table") then
    return false
    end
    if #cards < 5 then
        return false
    end
    if vNum <= 0 then
        return false
    end
      --1.把癞子牌和普通牌分离
    local normalCards = {}
    local laiziCards = {}
    local deliveryCards = {}
    for _, v in ipairs(cards) do
        local nValue = GetCardValue(v)
        if LibLaiZi:IsLaiZi(nValue) then
            table.insert(laiziCards, v)
        else
            table.insert(normalCards, v)
            table.insert(deliveryCards, v)
        end
    end

    local t = {}
    local bSuc = false
    local nLen = #normalCards
    local nLaizi = #laiziCards

    table.insert(deliveryCards, #laiziCards)
    table.insert(deliveryCards, vNum)
    -- LOG_DEBUG("Get_Same_Maxn_Value..2: %s\n", TableToString(deliveryCards))
    local result =  card_algrithm_test.get_the_same_maxn_card(deliveryCards)
    -- LOG_DEBUG("card_vec size..: %d\n", #card_vec)   
    -- LOG_DEBUG("lua call Get_Same_Maxn_Value 3..: %s\n", TableToString(card_vec))
    --获取的数值的算法
    local nNumCards = card_vec[#card_vec]
    LibLaiziCardLogic:Sort(normalCards)
    if nNumCards > 0 then
        for _, v in ipairs(normalCards) do
            local nValue = GetCardValue(v)
            if nNumCards == nValue then
                table.insert(t, v)
            else
                table.insert(t, laiziCards[nLaizi])
                nLaizi = nLaizi - 1
            end
            if #t >= vNum then
                return true, t
            end
        end
    end
    return false
end

--五同
function LibLaiziCardLogic:Get_Max_Pt_Five_Laizi(cards)
    -- LOG_DEBUG("Get_Max_Pt_Five_Laizi..before, cards--1: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
    return false
    end
    if #cards < 5 then
        return false
    end
    local vNum = 5
    local bSuc = false
    local t = {}
    bSuc, t = LibLaiziCardLogic:Get_Same_Maxn_Value(cards, vNum)
    if bSuc then
        if #t >= vNum then
            LibNormalCardLogic:RemoveCard(cards, t)
            -- LOG_DEBUG("Get_Max_Pt_Five_Laizi RemoveCard--cards..: %s\n", TableToString(cards))
            -- LOG_DEBUG("Get_Max_Pt_Five_Laizi RemoveCard t..: %s\n", TableToString(t))
            return true, t
        end
    end
       
    -- LOG_DEBUG("Get_Max_Pt_Five_Laizi..Failed, cards: %s\n", TableToString(cards))
    return false
end


--铁枝 
function LibLaiziCardLogic:Get_Max_Pt_Four_Laizi(cards)
    -- LOG_DEBUG("Get_Max_Pt_Four_Laizi..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
    return false
    end
    if #cards < 5 then
        return false
    end
    local vNum = 4
    local bSuc = false
    local t = {}
    bSuc, t = LibLaiziCardLogic:Get_Same_Maxn_Value(cards, vNum)
    if bSuc then
        LibNormalCardLogic:Sort(cards)
        if #t >= vNum then
            LibNormalCardLogic:RemoveCard(cards, t)
            -- LOG_DEBUG("Get_Max_Pt_Four_Laizi RemoveCard--cards..: %s\n", TableToString(cards))
            -- LOG_DEBUG("Get_Max_Pt_Four_Laizi RemoveCard t..: %s\n", TableToString(t))
            return true, t
        end
    end
     -- LOG_DEBUG("Get_Max_Pt_Four_Laizi..Failed, cards: %s\n", TableToString(cards))
    return false
end

--葫芦
function LibLaiziCardLogic:Get_Max_Pt_Full_Hosue_Laizi(cards)
    -- LOG_DEBUG("Get_Max_Pt_Full_Hosue_Laizi..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
    return false
    end
    if #cards < 5 then
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

    local t = {}
    local bSuc = false
    local nLen = #normalCards
    local nLaizi = #laiziCards

    --2.判断是否有癞子
    local bSuc = false
    if #laiziCards == 0 then
        local bSuc, t = LibNormalCardLogic:Get_Max_Pt_Full_Hosue(cards)
        if bSuc then
            return bSuc, t
        end
    else
        local val = {}
        LibLaiziCardLogic:Sort(normalCards)
        -- LOG_DEBUG("Get_Max_Pt_Full_Hosue_Laizi..sortdown, cards: %s\n", TableToString(normalCards))
        --按值分组
        for k, v in ipairs(normalCards) do
            local nValue= GetCardValue(v)
            if not val[nValue] then
                val[nValue] = {}
            end
            table.insert(val[nValue], v)
            -- LOG_DEBUG("Get_Max_Pt_Full_Hosue_Laizi..have laizi --00: %s\n", TableToString(val[nValue]))           
        end
         --再遍历找相同值
        for _, v in pairs(val) do
            local len = #v 
            if len + nLaizi >= 3 then
                for i=1, len do 
                    table.insert(t, v[len])
                    len = len - 1
                end
                for i=1, nLaizi do 
                    table.insert(t, laiziCards[nLaizi])
                    nLaizi = nLaizi - 1
                end
            end
            len = #v
            if len >= 2 then
                for i=1, len do 
                    table.insert(t, v[len])
                    len = len - 1
                end
            end  
            if #t >= 5 then
                 bSuc = true
                LibNormalCardLogic:RemoveCard(cards, t)
                return bSuc, t
            end
        end 
    end
    -- LOG_DEBUG("Get_Max_Pt_Full_Hosue_Laizi..Failed, cards: %s\n", TableToString(cards))
    return false
end

--3条
function LibLaiziCardLogic:Get_Max_Pt_Three_Laizi(cards)
    -- LOG_DEBUG("Get_Max_Pt_Three_Laizi..before, cards: %s\n", TableToString(cards))
    
 if (type(cards) ~= "table") then
    return false
    end
    if #cards < 5 then
        return false
    end
    local vNum = 3
    local bSuc = false
    local t = {}
    bSuc, t = LibLaiziCardLogic:Get_Same_Maxn_Value(cards, vNum)
    if bSuc then
        if #t >= vNum then
            LibNormalCardLogic:RemoveCard(cards, t)
            -- LOG_DEBUG("Get_Max_Pt_Three_Laizi RemoveCard--cards..: %s\n", TableToString(cards))
            -- LOG_DEBUG("Get_Max_Pt_Three_Laizi RemoveCard t..: %s\n", TableToString(t))
            return true, t
        end
    end
       
    -- LOG_DEBUG("Get_Max_Pt_Three_Laizi..Failed, cards: %s\n", TableToString(cards))
    return false
end

--两对
function LibLaiziCardLogic:Get_Max_Pt_Two_Pair_Laizi(cards)
    -- LOG_DEBUG("Get_Max_Pt_Two_Pair_Laizi..before, cards: %s\n", TableToString(cards))
    local bSuc, t = LibNormalCardLogic:Get_Max_Pt_Two_Pair(cards)
    if bSuc then
        return bSuc, t
    end
    -- LOG_DEBUG("Get_Max_Pt_Two_Pair_Laizi..Failed, cards: %s\n", TableToString(cards))
    return false
end

--一对
function LibLaiziCardLogic:Get_Max_Pt_One_Pair_Laizi(cards)
    -- LOG_DEBUG("Get_Max_Pt_One_Pair_Laizi..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
    return false
    end
    if #cards < 5 then
        return false
    end
    local vNum = 2
    local bSuc = false
    local t = {}
    bSuc, t = LibLaiziCardLogic:Get_Same_Maxn_Value(cards, vNum)
    if bSuc then
        if #t >= vNum then
            LibNormalCardLogic:RemoveCard(cards, t)
            -- LOG_DEBUG("Get_Max_Pt_One_Pair_Laizi RemoveCard--cards..: %s\n", TableToString(cards))
            -- LOG_DEBUG("Get_Max_Pt_One_Pair_Laizi RemoveCard t..: %s\n", TableToString(t))
            return true, t
        end
    end
    -- LOG_DEBUG("Get_Max_Pt_One_Pair_Laizi..Failed, cards: %s\n", TableToString(cards))
    return false
end

--散牌
function LibLaiziCardLogic:Get_Max_Pt_Single_Laizi(cards)
    -- LOG_DEBUG("Get_Max_Pt_Single_Laizi..before, cards: %s\n", TableToString(cards))
    if (type(cards) ~= "table") then
        return false
    end
    if #cards == 0 then
        return false
    end

    LibNormalCardLogic:Sort(cards)
    return true,table.remove(cards,#cards)
end

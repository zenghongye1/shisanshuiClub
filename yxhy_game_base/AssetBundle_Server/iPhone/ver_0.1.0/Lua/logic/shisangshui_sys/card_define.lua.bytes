
require "logic/shisangshui_sys/common/bit"
--require "logic/shisangshui_sys/lib_recomand"
card_define = {}


local this = card_define

this.cardDic = {
--[[	[0x02] ="diamond2",[0x03] ="diamond3",[0x04] ="diamond4",[0x05] ="diamond5",[0x06] ="diamond6",[0x07] ="diamond7",[0x08] ="diamond8",
	[0x09] ="diamond9",[0x0A] ="diamond10",[0x0B] ="diamondJ",[0x0C] ="diamondQ",[0x0D] ="diamondK",[0x0E] ="diamondA",
	
	[0x12] ="club2",[0x13] ="club3",[0x14] ="club4",[0x15] ="club5",[0x16] ="club6",[0x17] ="club7",[0x18] ="club8",
	[0x19] ="club9",[0x1A] ="club10",[0x1B] ="clubJ",[0x1C] ="clubQ",[0x1D] ="clubK",[0x1E] ="clubA",
	
	[0x22] ="heart2",[0x23] ="heart3",[0x24] ="heart4",[0x25] ="heart5",[0x26] ="heart6",[0x27] ="heart7",[0x28] ="heart8",
	[0x29] ="heart9",[0x2A] ="heart10",[0x2B] ="heartJ",[0x2C] ="heartQ",[0x2D] ="heartK",[0x2E] ="heartA",
	
	[0x32] ="spade2",[0x33] ="spade3",[0x34] ="spade4",[0x35] ="spade5",[0x36] ="spade6",[0x37] ="spade7",[0x38] ="spade8",
	[0x39] ="spade9",[0x3A] ="spade10",[0x3B] ="spadeJ",[0x3C] ="spadeQ",[0x3D] ="spadeK",[0x3E] ="spadeA",
	
	[0x4F] ="JokerB",[0x5F] ="JokerA",
	]]
	[0x02] =13,[0x03] =14,[0x04] =15,[0x05] =16,[0x06] =17,[0x07] =18,[0x08] =19,
	[0x09] =20,[0x0A] =21,[0x0B] =23,[0x0C] =25,[0x0D] =24,[0x0E] =22,
	
	[0x12] =0,[0x13] =1,[0x14] =2,[0x15] =3,[0x16] =4,[0x17] =5,[0x18] =6,
	[0x19] =7,[0x1A] =8,[0x1B] =10,[0x1C] =12,[0x1D] =11,[0x1E] =9,
	
	[0x22] =26,[0x23] =27,[0x24] =28,[0x25] =29,[0x26] =30,[0x27] =31,[0x28] =32,
	[0x29] =33,[0x2A] =34,[0x2B] =36,[0x2C] =38,[0x2D] =37,[0x2E] =35,
	
	[0x32] =41,[0x33] =42,[0x34] =43,[0x35] =44,[0x36] =45,[0x37] =46,[0x38] =47,
	[0x39] =48,[0x3A] =49,[0x3B] =51,[0x3C] =53,[0x3D] =52,[0x3E] =50,
	
	[0x4F] =40,[0x5F] =39,
}

function this.GetCardMeshByValue(cardValue)
	local card = this.cardDic[value]
	return card
end


--普通52张牌 无大小鬼
GStars_Normal_Cards = {
    0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,   --方块 2 - A 	2- 14
    0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,   --梅花 2 - A 	18 - 30
    0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x2E,   --红桃 2 - A 	34 - 46
    0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,    --黑桃 2 - A 	50 -62
}
--鬼牌
GStars_Ghost_Cards = {
    0x4F,   --小鬼  79
    0x5F,   --大鬼	95
} 
--加一色
GStars_One_Color = {
    0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,   --方块 2 - A
}
--加二色
GStars_Two_Color = {
    0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,   --方块 2 - A
    0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,   --梅花 2 - A
}
--码牌 红桃8
GStars_Code_Card = 0x28

--普通牌型
GStars_Normal_Type = {
    PT_ERROR = 0,
    PT_SINGLE = 1,                          --散牌(乌龙)    
    PT_ONE_PAIR = 2,                        --一对
    PT_TWO_PAIR = 3,                        --两对
    PT_THREE = 4,                           --三条
    PT_STRAIGHT = 5,                        --顺子
    PT_FLUSH = 6,                           --同花
    PT_FULL_HOUSE = 7,                      --葫芦
    PT_FOUR = 8,                            --铁支(炸弹)
    PT_STRAIGHT_FLUSH = 9,                  --同花顺
    PT_FIVE = 10,                           -- 五同
}



GStars_Normal_Type_Name = {
    [1] = "乌龙",                          --散牌(乌龙)    
     [2] = "一对",                          --一对
     [3] = "两对",                          --两对
     [4] = "三条",                             --三条
     [5] = "顺子",                        --顺子
     [6] = "同花",                             --同花
     [7] = "葫芦",                        --葫芦
     [8] = "铁支",                              --铁支(炸弹)
     [9] = "同花顺",                    --同花顺
     [10] = "五同",                           -- 五同
}

--普通排型音效表
NormalTypeMusicConfig = {
[1] = "wulong_nv",
[2] = "duizi_nv",
[3]="liangdui_nv",
[4]="santiao_nv",
[5]="shunzi_nv",
[6]="tonghua_nv",
[7]="hulu_nv",
[8]="tiezhi_nv",
[9]="tonghuashun_nv",
[10]="wutong_nv",
[11]="chongsan_nv",	--冲三
[12]="zhongdunhulu_nv",  --中墩葫芦
[13]= "duiguichongqian_nv" --对鬼冲前

}

--特殊排型音效表
SpecialTypeMusicConfig = {
[1] = "santonghua_nv",
[2] = "sanshunzi_nv",
[3]="liuduiban_nv",
[4]="wuduisantiao_nv",
[5]="couyise_nv",
[6]="quanxiao_nv",
[7]="quanda_nv",
[8]="liuliudashun_nv", 
[9]="santonghuashun_nv",
[10]="shierhuangzu_nv",
[11]="sanhuangwudi_nv",
[12]="sanfentianxia_nv",
[13]="sitaosantiao_nv",
[14]="yitiaolong_nv",
[15]="zhizunqinglong_nv",
[16]="qikaidesheng_nv",--旗开得胜
[17]="baxianguohai_nv", --八仙过海
}

--特殊牌型
GStars_Special_Type = {
    PT_SP_NIL = 0,
    PT_SP_THREE_FLUSH = 1,              --三同花
    PT_SP_THREE_STRAIGHT = 2,           --三顺子
    PT_SP_SIX_PAIRS = 3,                --六对半   6对+散牌
    PT_SP_FIVE_PAIR_AND_THREE = 4,      --五队三条 5对+3条
    PT_SP_SAME_SUIT = 5,                --凑一色
    PT_SP_ALL_SMALL = 6,                --全小
    PT_SP_ALL_BIG = 7,                  --全大
    PT_SP_SIX = 8,                      --六六大顺  6同
    PT_SP_THREE_STRAIGHT_FLUSH = 9,     --三同花顺
    PT_SP_ALL_KING = 10,                --十二皇族
    PT_SP_FIVE_AND_THREE_KING = 11,     --三皇五帝 2个5同+3条
    PT_SP_THREE_BOMB = 12,              --三炸弹   3个铁枝
    PT_SP_FOUR_THREE = 13,              --四套三条  4个3条
    PT_SP_STRAIGHT = 14,                --一条龙
    PT_SP_STRAIGHT_FLUSH = 15,          --至尊清龙
	PT_SP_SEVEN = 16,                  --旗开得胜
    PT_SP_EIGHT = 17,                   --八仙过海
	
}

---[[
--特殊牌型名字
GStars_Special_Type_Name = {
    [GStars_Special_Type.PT_SP_NIL] = "散牌",
    [GStars_Special_Type.PT_SP_THREE_FLUSH] = "三同花",              --三同花
    [GStars_Special_Type.PT_SP_THREE_STRAIGHT] = "三顺子",           --三顺子
    [GStars_Special_Type.PT_SP_SIX_PAIRS] = "六对半",                --六对半   6对+散牌
    [GStars_Special_Type.PT_SP_FIVE_PAIR_AND_THREE] = "五对三条",      --五队冲三 5对+3条
    [GStars_Special_Type.PT_SP_SAME_SUIT] = "凑一色",             --凑一色
    [GStars_Special_Type.PT_SP_ALL_SMALL] = "全小",             --全小
    [GStars_Special_Type.PT_SP_ALL_BIG] = "全大",                 --全大
    [GStars_Special_Type.PT_SP_SIX] = "六六大顺",                     --六六大顺  6同
    [GStars_Special_Type.PT_SP_THREE_STRAIGHT_FLUSH] = "三同花顺",    --三同花顺
    [GStars_Special_Type.PT_SP_ALL_KING] = "十二皇族",                --十二皇族
    [GStars_Special_Type.PT_SP_FIVE_AND_THREE_KING] = "三皇五帝",     --三皇五帝 2个5同+3条
    [GStars_Special_Type.PT_SP_THREE_BOMB] = "三分天下",              --三炸弹   3个铁枝
    [GStars_Special_Type.PT_SP_FOUR_THREE] = "四套三条" ,             --四套三条  4个3条
    [GStars_Special_Type.PT_SP_STRAIGHT] = "一条龙",               --一条龙
    [GStars_Special_Type.PT_SP_STRAIGHT_FLUSH] = "至尊清龙",			--至尊清龙
	[GStars_Special_Type.PT_SP_SEVEN] = "旗开得胜",			--旗开得胜
	[GStars_Special_Type.PT_SP_EIGHT] = "八仙过海",			--八仙过海
}
--]]

--普通牌型每一墩算1水
GStars_Normal_Score = 
{
    [GStars_Normal_Type.PT_SINGLE]              =  1,
    [GStars_Normal_Type.PT_ONE_PAIR]            =  1,
    [GStars_Normal_Type.PT_TWO_PAIR]            =  1,
    [GStars_Normal_Type.PT_THREE]               =  1,
    [GStars_Normal_Type.PT_STRAIGHT]            =  1,
    [GStars_Normal_Type.PT_FLUSH]               =  1,
    [GStars_Normal_Type.PT_FULL_HOUSE]          =  1,
    [GStars_Normal_Type.PT_FOUR]                =  4,
    [GStars_Normal_Type.PT_STRAIGHT_FLUSH]      =  5,
    [GStars_Normal_Type.PT_FIVE]                =  10,
}

--特殊分
GStars_Special_Score = {
    --[GStars_Special_Type.PT_SP_NIL]                     = 0,	--
    [GStars_Special_Type.PT_SP_THREE_FLUSH]             = 6,	--三同花
    [GStars_Special_Type.PT_SP_THREE_STRAIGHT]          = 6,	--三顺子
    [GStars_Special_Type.PT_SP_SIX_PAIRS]               = 6,	--六对半
    [GStars_Special_Type.PT_SP_FIVE_PAIR_AND_THREE]     = 6,	--五对冲三
    [GStars_Special_Type.PT_SP_SAME_SUIT]               = 6,	--凑一色
    [GStars_Special_Type.PT_SP_ALL_SMALL]               = 6,	--全小
    [GStars_Special_Type.PT_SP_ALL_BIG]                 = 6,	--全大
    [GStars_Special_Type.PT_SP_SIX]                     = 20,	--六六大顺
    [GStars_Special_Type.PT_SP_THREE_STRAIGHT_FLUSH]    = 26,	--三同花顺
    [GStars_Special_Type.PT_SP_ALL_KING]                = 26,	--十二皇族
    [GStars_Special_Type.PT_SP_FIVE_AND_THREE_KING]     = 26,	--三皇五帝
    [GStars_Special_Type.PT_SP_THREE_BOMB]              = 52,	--三炸弹
    [GStars_Special_Type.PT_SP_FOUR_THREE]              = 52,	--四套三冲
    [GStars_Special_Type.PT_SP_STRAIGHT]                = 52,	--一条龙
    [GStars_Special_Type.PT_SP_STRAIGHT_FLUSH]          = 104,  --至尊清龙
	[GStars_Special_Type.PT_SP_SEVEN]         			= 40,  --旗开得胜
	[GStars_Special_Type.PT_SP_EIGHT]         			= 80,  --八仙过海
}

--加成分
GStars_Ext_Score = {
    --前墩加成
    [1] = {
        [GStars_Normal_Type.PT_THREE] = 2,
    },
    --中墩加成
    [2] = {
        [GStars_Normal_Type.PT_FIVE] = 10,
        [GStars_Normal_Type.PT_STRAIGHT_FLUSH] = 5,
        [GStars_Normal_Type.PT_FOUR] = 4,
        [GStars_Normal_Type.PT_FULL_HOUSE] = 1,
    },
    --后墩加成
    [3] = {
        [GStars_Normal_Type.PT_FIVE] = 0,
        [GStars_Normal_Type.PT_STRAIGHT_FLUSH] = 0,
        [GStars_Normal_Type.PT_FOUR] = 0,
    },
}

MASK_COLOR = 0xF0   --花色掩码
MASK_VALUE = 0x0F   --数值掩码
--获取牌的花色
function GetCardColor(nCard)
    if nCard == nil or type(nCard) ~= "number" then
        return -1
    else
        local ot = bit.band(nCard, MASK_COLOR)
        return bit.brshift(ot, 4)
    end
end
--获取牌的点数
function GetCardValue(nCard)
    if nCard == nil or type(nCard) ~= "number" then
        return -1
    else
        return bit.band(nCard, MASK_VALUE)
    end
end
--根据花色和点数  获取牌
function GetCardByColorValue(nColor, nValue)
    --花色：0-3
    if nColor < 0 or nColor > 3 then
        nColor = nColor % 3
    end

    --A
    if nValue == 1 then
        nValue = 14
    end
    --点数2-14
    if nValue < 2 or nValue > 14 then
        nValue = 0
    end

    return (bit.blshift(nColor, 4) + nValue)
end
--判断是否是鬼牌
function IsGhostCard(nCard)
    local bRet = false
    for _, v in pairs(GStars_Ghost_Cards) do
        if nCard == v then
            bRet = true
            break
        end
    end
    return bRet
end
--获取手牌鬼牌数量
function GetGhostCard(cards)
    if type(cards) ~= "table" then
        return 0
    end

    local count = 0
    for _, v in pairs(cards) do
        if IsGhostCard(v) then
            count = count + 1
        end
    end
    return count
end
--是否是码牌
function IsCodeCard(nCard)
    return (GStars_Code_Card == nCard)
end
--获取特殊积分
function GetSpecialScore(nSpType)
    return GStars_Special_Score[nSpType] or 0
end
--获取加成分 nIndex:1前墩 2中墩 3后墩
function GetExtScore(nIndex, nType)
    if GStars_Ext_Score[nIndex] then
        return GStars_Ext_Score[nIndex][nType] or 0
    else
        return 0
    end
end
--获取基础分
function GetBaseScore(nType)
    if GStars_Normal_Score[nType] then
        return GStars_Normal_Score[nType] or 0
    else
        return 0
    end
end

--只是显示16进制格式  table格式 t={1,2,3,3}
function TableToString(t)
    local str = ""
    if type(t) == "table" then
        for i=1,#t  do
            str = str .. string.format("0x%X, ", t[i])
        end
    end
    return str
end
--十三水系列游戏
require "logic/shisangshui_sys/common/bit"

card_define = {}
local this = card_define
this.GameSetting = {}


----------------------------------------↓全局谨慎改动↓----------------------------------------------
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
    0x6F,   --花牌  111
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
--加三色
GStars_Three_Cards = {
    0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,   --方块 2 - A
    0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,   --梅花 2 - A
    0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x2E,   --红桃 2 - A
}

--普通牌型		----server推荐算法使用
GStars_Normal_Type = {
	PT_ERROR = 0,
    PT_SINGLE = 1,                          --散牌(乌龙)    
    PT_ONE_PAIR = 2,                        --一对
    PT_TWO_PAIR = 3,                        --两对
    PT_THREE = 4,                           --三条
    PT_TWO_GHOST = 5,                       --对鬼冲前(只在前墩有效)
    PT_THREE_TWO = 6,                       --三条2(只在前墩有效)
    PT_THREE_THREE = 7,                     --三条3(只在前墩有效)
    PT_THREE_GHOST = 8,                     --3鬼冲前(只在前墩有效)
    PT_STRAIGHT = 9,                        --顺子
    PT_FLUSH = 10,                          --同花
    PT_FULL_HOUSE = 11,                     --葫芦
    PT_FOUR = 12,                           --铁支(炸弹)
    PT_STRAIGHT_FLUSH = 13,                 --同花顺
    PT_FIVE = 14,                           --五同
    PT_SIX = 15,                            --六同
    PT_FIVE_GHOST = 16,                     --五鬼
    PT_THREE_FOUR = 17,                     --三条4(只在前墩有效)
    PT_THREE_FIVE = 18,                     --三条5(只在前墩有效)
    PT_THREE_SIX = 19,                      --三条6(只在前墩有效)
    PT_THREE_SEVEN = 20,                    --三条7(只在前墩有效)
    PT_THREE_EIGHT = 21,                    --三条8(只在前墩有效)
    PT_THREE_NINE = 22,                     --三条9(只在前墩有效)
    PT_THREE_TEN = 23,                      --三条10(只在前墩有效)
    PT_THREE_JJJ = 24,                   --三条J(只在前墩有效)
    PT_THREE_QQQ = 25,                   --三条Q(只在前墩有效)
    PT_THREE_KKK = 26,                 --三条K(只在前墩有效)
    PT_THREE_AAA = 27,                 --三条A(只在前墩有效)

    ---------------以下客户端自定义----------------
    PT_THREE_FIRST = 104,					--冲三
    PT_HOUSE_SECOND = 111,					--中墩葫芦
}

--普通牌型比较大小设置
GStars_Normal_Compare = {
    [GStars_Normal_Type.PT_SINGLE]              =  1,
    [GStars_Normal_Type.PT_ONE_PAIR]            =  10,
    [GStars_Normal_Type.PT_TWO_PAIR]            =  20,
    [GStars_Normal_Type.PT_THREE]               =  30,
    [GStars_Normal_Type.PT_TWO_GHOST]           =  40,
    [GStars_Normal_Type.PT_THREE_TWO]           =  50,
    [GStars_Normal_Type.PT_THREE_THREE]         =  60,

    [GStars_Normal_Type.PT_THREE_FOUR]          =  70,
    [GStars_Normal_Type.PT_THREE_FIVE]          =  80,
    [GStars_Normal_Type.PT_THREE_SIX]           =  90,
    [GStars_Normal_Type.PT_THREE_SEVEN]         =  100,
    [GStars_Normal_Type.PT_THREE_EIGHT]         =  110,
    [GStars_Normal_Type.PT_THREE_NINE]          =  120,
    [GStars_Normal_Type.PT_THREE_TEN]           =  130,
    [GStars_Normal_Type.PT_THREE_JJJ]           =  140,
    [GStars_Normal_Type.PT_THREE_QQQ]           =  150,
    [GStars_Normal_Type.PT_THREE_KKK]           =  160,
    [GStars_Normal_Type.PT_THREE_AAA]           =  170,

    [GStars_Normal_Type.PT_THREE_GHOST]         =  180,
    [GStars_Normal_Type.PT_STRAIGHT]            =  190,
    [GStars_Normal_Type.PT_FLUSH]               =  200,
    [GStars_Normal_Type.PT_FULL_HOUSE]          =  210,
    [GStars_Normal_Type.PT_FOUR]                =  220,
    [GStars_Normal_Type.PT_STRAIGHT_FLUSH]      =  230,
    [GStars_Normal_Type.PT_FIVE]                =  240,
    [GStars_Normal_Type.PT_SIX]                 =  250,
    [GStars_Normal_Type.PT_FIVE_GHOST]          =  260,
}

--特殊牌型		----server推荐算法使用
GStars_Special_Type = {
    PT_SP_NIL = 0,
    PT_SP_THREE_FLUSH = 1,              --三同花
    PT_SP_THREE_STRAIGHT = 2,           --三顺子
    PT_SP_SIX_PAIRS = 3,                --六对半   6对+散牌
    PT_SP_FIVE_PAIR_AND_THREE = 4,      --五队冲三 5对+3条
    PT_SP_SAME_SUIT = 5,                --凑一色
    PT_SP_ALL_SMALL = 6,                --全小
    PT_SP_ALL_BIG = 7,                  --全大
    PT_SP_SIX = 8,                      --六六大顺  6同
    PT_SP_THREE_STRAIGHT_FLUSH = 9,     --三同花顺
    PT_SP_ALL_KING = 10,                --十二皇族
    PT_SP_FIVE_AND_THREE_KING = 11,     --三皇五帝 2个5同+3条
    PT_SP_THREE_BOMB = 12,              --三分天下   3个铁枝
    PT_SP_FOUR_THREE = 13,              --四套三条  4个3条
    PT_SP_STRAIGHT = 14,                --一条龙
    PT_SP_STRAIGHT_FLUSH = 15,          --至尊清龙
    PT_SP_SEVEN = 16,                   --7同(旗开得胜)
    PT_SP_EIGHT = 17,                   --8同(八仙过海)
    PT_SP_NINE = 18,                    --9同(长长久久)
    PT_SP_TEN = 19,                     --10同(十全十美)
    PT_SP_ELEVEN = 20,                  --11同(步步高升)
    PT_SP_TWELVE = 21,                  --12同(雄霸天下)
	PT_SP_THIRTEEN = 22,                --13同(福星高照)
    PT_SP_FOURTEEN  = 23,               --14同(无敌至尊)
}

--获取牌的花色
function GetCardColor(nCard)
	local MASK_COLOR = 0xF0   --花色掩码
    if nCard == nil or type(nCard) ~= "number" then
        return -1
    else
        local ot = bit.band(nCard, MASK_COLOR)
        return bit.brshift(ot, 4)
    end
end
--获取牌的点数
function GetCardValue(nCard)
	local MASK_VALUE = 0x0F   --数值掩码
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

function GetGStarsNormalCompare(nType)
    return GStars_Normal_Compare[nType] or 0
end
----------------------------------------↑谨慎改动↑----------------------------------------------

local GStars_Normal_Type_Name = {
	[GStars_Normal_Type.PT_SINGLE] = "乌龙",                      --散牌(乌龙)    
	[GStars_Normal_Type.PT_ONE_PAIR] = "一对",                    --一对
	[GStars_Normal_Type.PT_TWO_PAIR] = "两对",                    --两对
	[GStars_Normal_Type.PT_THREE] = "三条",                       --三条
	[GStars_Normal_Type.PT_TWO_GHOST] = "对鬼冲前",               --对鬼冲前(只在前墩有效)
	[GStars_Normal_Type.PT_THREE_TWO] = "冲三",					  --三条2(只在前墩有效)
	[GStars_Normal_Type.PT_THREE_THREE] = "冲三",				  --三条3(只在前墩有效)
	[GStars_Normal_Type.PT_THREE_GHOST] = "三鬼冲前",             --三鬼冲前(只在前墩有效)
	[GStars_Normal_Type.PT_STRAIGHT] = "顺子",                    --顺子
	[GStars_Normal_Type.PT_FLUSH] = "同花",                       --同花
	[GStars_Normal_Type.PT_FULL_HOUSE] = "葫芦",                  --葫芦
	[GStars_Normal_Type.PT_FOUR] = "铁支",                        --铁支(炸弹)
	[GStars_Normal_Type.PT_STRAIGHT_FLUSH] = "同花顺",            --同花顺
	[GStars_Normal_Type.PT_FIVE] = "五同",                        --五同
	[GStars_Normal_Type.PT_SIX] = "六同",                         --六同
    [GStars_Normal_Type.PT_FIVE_GHOST] = "六同",                  --五鬼
    [GStars_Normal_Type.PT_THREE_FOUR] = "冲三",                  --三条4(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_FIVE] = "冲三",                  --三条5(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_SIX] = "冲三",                   --三条6(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_SEVEN] = "冲三",                 --三条7(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_EIGHT] = "冲三",                 --三条8(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_NINE] = "冲三",                  --三条9(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_TEN] = "冲三",                   --三条10(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_JJJ] = "冲三",                   --三条J(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_QQQ] = "冲三",                   --三条Q(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_KKK] = "冲三",                   --三条K(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_AAA] = "冲三",                   --三条A(只在前墩有效)
	
	[GStars_Normal_Type.PT_THREE_FIRST] = "冲三",                 --冲三
	[GStars_Normal_Type.PT_HOUSE_SECOND] = "中墩葫芦",            --中墩葫芦
}

--特殊牌型名字
local GStars_Special_Type_Name = {
    [GStars_Special_Type.PT_SP_THREE_FLUSH] = "三同花",                --1三同花
    [GStars_Special_Type.PT_SP_THREE_STRAIGHT] = "三顺子",             --2三顺子
    [GStars_Special_Type.PT_SP_SIX_PAIRS] = "六对半",                  --3六对半   6对+散牌
    [GStars_Special_Type.PT_SP_FIVE_PAIR_AND_THREE] = "五对三条",      --4五队冲三 5对+3条
    [GStars_Special_Type.PT_SP_SAME_SUIT] = "凑一色",                  --5凑一色
    [GStars_Special_Type.PT_SP_ALL_SMALL] = "全小",                    --6全小
    [GStars_Special_Type.PT_SP_ALL_BIG] = "全大",                 	   --7全大
    [GStars_Special_Type.PT_SP_SIX] = "六六大顺",                      --8六六大顺  6同
    [GStars_Special_Type.PT_SP_THREE_STRAIGHT_FLUSH] = "三同花顺",     --9三同花顺
    [GStars_Special_Type.PT_SP_ALL_KING] = "十二皇族",                 --10十二皇族
    [GStars_Special_Type.PT_SP_FIVE_AND_THREE_KING] = "三皇五帝",      --11三皇五帝 2个5同+3条
    [GStars_Special_Type.PT_SP_THREE_BOMB] = "三分天下",               --12三炸弹   3个铁枝
    [GStars_Special_Type.PT_SP_FOUR_THREE] = "四套三条" ,              --13四套三条  4个3条
    [GStars_Special_Type.PT_SP_STRAIGHT] = "一条龙",                   --14一条龙
    [GStars_Special_Type.PT_SP_STRAIGHT_FLUSH] = "至尊清龙",		   --15至尊清龙
	[GStars_Special_Type.PT_SP_SEVEN] = "旗开得胜",					   --16旗开得胜
	[GStars_Special_Type.PT_SP_EIGHT] = "八仙过海",			           --17八仙过海
	[GStars_Special_Type.PT_SP_NINE] = "长长久久",					   --18长长久久
	[GStars_Special_Type.PT_SP_TEN] = "十全十美",			           --19十全十美
    [GStars_Special_Type.PT_SP_ELEVEN] = "步步高升",                   --20步步高升
    [GStars_Special_Type.PT_SP_TWELVE] = "雄霸天下",                   --21雄霸天下
	[GStars_Special_Type.PT_SP_THIRTEEN] = "福星高照",                   --22福星高照
    [GStars_Special_Type.PT_SP_FOURTEEN] = "无敌至尊",                   --23无敌至尊
}

--十三水普通牌型对应spriteName表(cardTypeAtlas)
local GStars_Normal_Type_spriteName = {
	[GStars_Normal_Type.PT_SINGLE] = "wulong",                     --散牌(乌龙)    
	[GStars_Normal_Type.PT_ONE_PAIR] = "duizi",                    --一对
	[GStars_Normal_Type.PT_TWO_PAIR] = "erdui",                    --两对
	[GStars_Normal_Type.PT_THREE] = "santiao",                     --三条
	[GStars_Normal_Type.PT_TWO_GHOST] = "duiguichongqian",         --对鬼冲前(只在前墩有效)
	[GStars_Normal_Type.PT_THREE_TWO] = "chongsan",				   --三条2(只在前墩有效)
	[GStars_Normal_Type.PT_THREE_THREE] = "chongsan",			   --三条3(只在前墩有效)
	[GStars_Normal_Type.PT_THREE_GHOST] = "sanguichongqian",       --三鬼冲前(只在前墩有效)
	[GStars_Normal_Type.PT_STRAIGHT] = "shunzi",                   --顺子
	[GStars_Normal_Type.PT_FLUSH] = "tonghua",                     --同花
	[GStars_Normal_Type.PT_FULL_HOUSE] = "hulu",                   --葫芦
	[GStars_Normal_Type.PT_FOUR] = "tiezhi",                       --铁支(炸弹)
	[GStars_Normal_Type.PT_STRAIGHT_FLUSH] = "tonghuashun",        --同花顺
	[GStars_Normal_Type.PT_FIVE] = "wutong",                       --五同
	[GStars_Normal_Type.PT_SIX] = "liutong",                       --六同
    [GStars_Normal_Type.PT_FIVE_GHOST] = "liutong",                --五鬼(六同)
    [GStars_Normal_Type.PT_THREE_FOUR] = "chongsan",               --三条4(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_FIVE] = "chongsan",               --三条5(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_SIX] = "chongsan",                --三条6(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_SEVEN] = "chongsan",              --三条7(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_EIGHT] = "chongsan",              --三条8(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_NINE] = "chongsan",               --三条9(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_TEN] = "chongsan",                --三条10(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_JJJ] = "chongsan",                --三条J(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_QQQ] = "chongsan",                --三条Q(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_KKK] = "chongsan",                --三条K(只在前墩有效)
    [GStars_Normal_Type.PT_THREE_AAA] = "chongsan",                --三条A(只在前墩有效)
	
	[GStars_Normal_Type.PT_THREE_FIRST] = "chongsan",              --冲三
	[GStars_Normal_Type.PT_HOUSE_SECOND] = "zhongdunhulu",         --中墩葫芦
}

--十三水普通排型音效表
local NormalTypeMusicConfig = {
	["female"] = {
		[GStars_Normal_Type.PT_SINGLE] = "wulong_nv",
		[GStars_Normal_Type.PT_ONE_PAIR] = "duizi_nv",
		[GStars_Normal_Type.PT_TWO_PAIR] = "liangdui_nv",
		[GStars_Normal_Type.PT_THREE] = "santiao_nv",
		[GStars_Normal_Type.PT_TWO_GHOST] = "duiguichongqian_nv",    	  --对鬼冲前(只在前墩有效)
		[GStars_Normal_Type.PT_THREE_TWO] = "chongsan_nv",				  --三条2(只在前墩有效)
		[GStars_Normal_Type.PT_THREE_THREE] = "chongsan_nv",			  --三条3(只在前墩有效)
		[GStars_Normal_Type.PT_THREE_GHOST] = "sanguichongqian_nv",       --三鬼冲前(只在前墩有效)
		[GStars_Normal_Type.PT_STRAIGHT] = "shunzi_nv",
		[GStars_Normal_Type.PT_FLUSH] = "tonghua_nv",
		[GStars_Normal_Type.PT_FULL_HOUSE] = "hulu_nv",
		[GStars_Normal_Type.PT_FOUR] = "tiezhi_nv",
		[GStars_Normal_Type.PT_STRAIGHT_FLUSH] = "tonghuashun_nv",
		[GStars_Normal_Type.PT_FIVE] = "wutong_nv",
		[GStars_Normal_Type.PT_SIX] = "liutong_nv",
        [GStars_Normal_Type.PT_FIVE_GHOST] = "liutong_nv",                --五鬼(六同)
        [GStars_Normal_Type.PT_THREE_FOUR] = "chongsan_nv",               --三条4(只在前墩有效)
        [GStars_Normal_Type.PT_THREE_FIVE] = "chongsan_nv",               --三条5(只在前墩有效)
        [GStars_Normal_Type.PT_THREE_SIX] = "chongsan_nv",                --三条6(只在前墩有效)
        [GStars_Normal_Type.PT_THREE_SEVEN] = "chongsan_nv",              --三条7(只在前墩有效)
        [GStars_Normal_Type.PT_THREE_EIGHT] = "chongsan_nv",              --三条8(只在前墩有效)
        [GStars_Normal_Type.PT_THREE_NINE] = "chongsan_nv",               --三条9(只在前墩有效)
        [GStars_Normal_Type.PT_THREE_TEN] = "chongsan_nv",                --三条10(只在前墩有效)
        [GStars_Normal_Type.PT_THREE_JJJ] = "chongsan_nv",                --三条J(只在前墩有效)
        [GStars_Normal_Type.PT_THREE_QQQ] = "chongsan_nv",                --三条Q(只在前墩有效)
        [GStars_Normal_Type.PT_THREE_KKK] = "chongsan_nv",                --三条K(只在前墩有效)
        [GStars_Normal_Type.PT_THREE_AAA] = "chongsan_nv",                --三条A(只在前墩有效)
		
		[GStars_Normal_Type.PT_THREE_FIRST] = "chongsan_nv",             --冲三
		[GStars_Normal_Type.PT_HOUSE_SECOND] = "zhongdunhulu_nv",        --中墩葫芦
	},
	["male"] = {
		
	}
}

--特殊排型音效表
local SpecialTypeMusicConfig = {
	["female"] = {
		[GStars_Special_Type.PT_SP_THREE_FLUSH] = "santonghua_nv",
		[GStars_Special_Type.PT_SP_THREE_STRAIGHT] = "sanshunzi_nv",
		[GStars_Special_Type.PT_SP_SIX_PAIRS] = "liuduiban_nv",
		[GStars_Special_Type.PT_SP_FIVE_PAIR_AND_THREE] = "wuduisantiao_nv",
		[GStars_Special_Type.PT_SP_SAME_SUIT] = "couyise_nv",
		[GStars_Special_Type.PT_SP_ALL_SMALL] = "quanxiao_nv",
		[GStars_Special_Type.PT_SP_ALL_BIG] = "quanda_nv",
		[GStars_Special_Type.PT_SP_SIX] = "liuliudashun_nv", 
		[GStars_Special_Type.PT_SP_THREE_STRAIGHT_FLUSH] = "santonghuashun_nv",
		[GStars_Special_Type.PT_SP_ALL_KING] = "shierhuangzu_nv",
		[GStars_Special_Type.PT_SP_FIVE_AND_THREE_KING] = "sanhuangwudi_nv",
		[GStars_Special_Type.PT_SP_THREE_BOMB] = "sanfentianxia_nv",
		[GStars_Special_Type.PT_SP_FOUR_THREE] = "sitaosantiao_nv",
		[GStars_Special_Type.PT_SP_STRAIGHT] = "yitiaolong_nv",
		[GStars_Special_Type.PT_SP_STRAIGHT_FLUSH] = "zhizunqinglong_nv",
		[GStars_Special_Type.PT_SP_SEVEN] = "qikaidesheng_nv",
		[GStars_Special_Type.PT_SP_EIGHT] = "baxianguohai_nv",
		[GStars_Special_Type.PT_SP_NINE] = "changchangjiujiu_nv",					
		[GStars_Special_Type.PT_SP_TEN] = "shiquanshimei_nv",				
        [GStars_Special_Type.PT_SP_ELEVEN] = "bubugaosheng_nv",           
        [GStars_Special_Type.PT_SP_TWELVE] = "xiongbatianxia_nv",             
		[GStars_Special_Type.PT_SP_THIRTEEN] = "fuxinggaozhao_nv",          
        [GStars_Special_Type.PT_SP_FOURTEEN] = "wudizhizun_nv",             
	},
	["male"] = {
		
	}
}

local codeCardMode = {
	["0"] = "None",
	["1"] = "Heart8",
	["2"] = "Heart5",
	["3"] = "Heart10",
	["4"] = "HeartK",
	["5"] = "Random",
}

local codeCardDefault = {	---默认马牌
	["None"] = 0,
	["Heart5"] = 37,
	["Heart8"] = 40,
	["Heart10"] = 42,
	["HeartK"] = 45,
	["Random"] = 0,
}

--------------------------外部接口----------------------

function this.SetCodeCardValue(cardValue)
	local nBuyCode = this.GameSetting["nBuyCode"]
	local mode = codeCardMode[tostring(nBuyCode)]
	if mode == codeCardMode["5"] then
		codeCardDefault[mode] = cardValue
	end
end

---新增type
function this.UpdateGameRuleSetting(tbl)
	if not tbl then
		logError("server给的GameSetting  error")
		return
	end

	this.GameSetting = tbl

	if tbl["stGStarsNormalType"] then 		---只做Add
		for k,v in pairs (tbl["stGStarsNormalType"]) do
			if not GStars_Normal_Type[k] then
				GStars_Normal_Type[k] = v
			end
		end
	end

	if tbl["stGStarsNormalCompare"] then
		GStars_Normal_Compare = tbl["stGStarsNormalCompare"]
	end

	if tbl["stGStarsSpecialType"] then
		GStars_Special_Type = tbl["stGStarsSpecialType"]
	end
end

--判断牌是否是鬼牌
function this.IsGhostCard(nCard)
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
function this.GetGhostCard(cards)
    if type(cards) ~= "table" then
        return 0
    end

    local count = 0
    for _, v in pairs(cards) do
        if this.IsGhostCard(v) then
            count = count + 1
        end
    end
    return count
end

--[[
 * @Description: 获取十三水普通牌型名字
 * cardType	牌型索引
 * gid 11;2011
 ]]
function this.GetNormalTypeName(cardType)
	return GStars_Normal_Type_Name[cardType] or ""
end

--[[
 * @Description: 获取十三水普通牌型对应spriteName表
 * cardType	牌型索引
 * gid 11;2011
 ]]
function this.GetNormalTypeSpriteName(cardType,gid)
	return GStars_Normal_Type_spriteName[cardType] or ""
end

--[[
 * @Description: 获取十三水特殊牌型名字
 * cardType	牌型索引
 * gid 11;2011
 ]]
function this.GetSpecialTypeName(cardType,gid)
	return GStars_Special_Type_Name[cardType] or ""
end

--[[
 * @Description: 获取十三水普通牌型音效
 * cardType	牌型索引
 * gid 11;2011
 * sex	0女;1男
 ]]
function this.GetNormalTypeMusicConfig(cardType,gid,sex)
	local sex = sex or 0
	local isFemale = (sex == 0)
	if isFemale then
		return NormalTypeMusicConfig["female"][cardType] or NormalTypeMusicConfig["female"][1]
	else
		logError("暂未配置男声")
		return NormalTypeMusicConfig["male"][cardType] or NormalTypeMusicConfig["male"][1]
	end
end

--[[
 * @Description: 获取十三水特殊牌型音效
 * cardType	牌型索引
 * gid 可不传
 * sex	0女;1男
 ]]
function this.GetSpecialTypeMusicConfig(cardType,gid,sex)
	local sex = sex or 0
	local isFemale = (sex == 0)
	if isFemale then
		return SpecialTypeMusicConfig["female"][cardType] or SpecialTypeMusicConfig["female"][1]
	else
		logError("暂未配置男声")
		return SpecialTypeMusicConfig["male"][cardType] or SpecialTypeMusicConfig["male"][1]
	end
end

---获取马牌
function this.GetCodeCard()
	local nBuyCode = this.GameSetting["nBuyCode"]
	local mode = codeCardMode[tostring(nBuyCode)]
	if mode then
		return codeCardDefault[mode]
	else
		logError("nBuyCode Error:-----"..tostring(nBuyCode))
		return 0
	end
end

---推荐算法用到
function this.GetIsSubport23Rule()
	return this.GameSetting["bSubport23Rule"] or false
end

---推荐算法用到
function this.GetGhostNum()
    return this.GameSetting["nGhostAdd"] or 0
end
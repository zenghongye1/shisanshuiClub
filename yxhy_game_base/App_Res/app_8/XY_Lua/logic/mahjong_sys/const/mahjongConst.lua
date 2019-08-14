--[[--
 * @Description: 麻将常量
 * @Author:      ShushingWong
 * @FileName:    mahjongConst.lua
 * @DateTime:    2017-06-20 15:27:39
 ]]

mahjongConst = {}

--mahjongConst.IsUsed2DCamera             = true;--是否使用2d相机


mahjongConst.MahjongScale = 1

mahjongConst.MahjongOffset_x            = 0.30 * mahjongConst.MahjongScale;--麻将宽度
mahjongConst.MahjongOffset_y            = 0.21 * mahjongConst.MahjongScale;--麻将厚度
mahjongConst.MahjongOffset_z            = 0.41 * mahjongConst.MahjongScale;--麻将长度

mahjongConst.OutCardNum_x               = 5;--出牌区每行个数
mahjongConst.OutCardNum_y               = 4;--出牌区每列个数

--mahjongConst.MahjongPlayerCount         = 4;--人数
--mahjongConst.MahjongTotalCount          = 136;--总牌数
--mahjongConst.MahjongDunCount            = 17;--一排多少墩
--mahjongConst.MahjongHandCount           = 14;--手牌
--mahjongConst.MahjongMaxOutCount         = 0;--最多出牌数

mahjongConst.MahjongAnimationTime       = 0.05;--麻将动画时间

mahjongConst.MahjongOperCardInterval    = 0.1;--麻将操作牌间距

--[[--
 * @Description: 所有操作类型  
 ]]
MahjongOperAllEnum = {
    None                = 0x0001,
    GiveUp              = 0x0002,--过,
    Collect             = 0x0003,--吃,
    TripletLeft         = 0x0004,--碰左,
    TripletCenter       = 0x0005,--碰中,
    TripletRight        = 0x0006,--碰右,
    DarkBar             = 0x0007,--暗杠,
    BrightBarLeft       = 0x0008,--明杠左,
    BrightBarCenter     = 0x0009,--明杠中,
    BrightBarRight      = 0x0010,--明杠右,
    AddBar              = 0x0011,--补杠,
    AddBarLeft          = 0x0012,--补杠左,
    AddBarCenter        = 0x0013,--补杠中,
    AddBarRight         = 0x0014,--补杠右,
    Ting                = 0x0015,--听,
    Hu                  = 0x0016,--胡,
}

--[[--
 * @Description: 吃碰杠胡提示类型  
 ]]
MahjongOperTipsEnum = {
    None                = 0x0001,
    GiveUp              = 0x0002,--过,
    Collect             = 0x0003,--吃,
    Triplet             = 0x0004,--碰,
    Quadruplet          = 0x0005,--杠,
    Ting                = 0x0006,--听,
    Hu                  = 0x0007,--胡,
    Qiang               = 0x0008,--抢
}

--[[--
 * @Description: 骰子数值对应方向  
 ]]
MahjongDiceVector = {
    [1] = Vector3(90,0,0),
    [2] = Vector3(0,0,-90),
    [3] = Vector3(0,0,0),
    [4] = Vector3(0,0,90),
    [5] = Vector3(0,0,180),
    [6] = Vector3(-90,0,0),
}


MahjongLayer = 
{
    DefaultLayer = 0,
    TwoDLayer = 8,
}

--[[--
 * @Description: 玩法描述
 * "GameSetting":{"bCounterLian":false,"bSupportCollect":false,"bSupportDealerAdd":true,"bSupportGangCi":false,
 * "bSupportGangFlowAdd":true,"bSupportGangPao":true,"bSupportGunWin":true,"bSupportHiddenQuadruplet":true,"bSupportHun":true,
 * "bSupportQuadruplet":true,"bSupportSevenDoubleAdd":true,"bSupportTing":false,"bSupportTriplet":true,
 * "bSupportTriplet2Quadruplet":true,"bSupportWind":true,"bSupportXiaPao":true,"bTingCanPlayOther":true,"nTimeOutCountToAuto":-1},
 ]]
MahjongGameSetting = {
    --["bCounterLian"] = "连庄加番",
    --["bSupportCollect"] = "可吃",
    --["bSupportDealerAdd"] = "庄家加底",
    --["bSupportGangCi"] = "可杠次",
    --["bSupportGangFlowAdd"] = "杠上花加倍",
    --["bSupportGangPao"] = "可杠跑",
    --["bSupportGunWin"] = "可放炮",
    --["bSupportHiddenQuadruplet"] = "暗杠不显示",
    --["bSupportHun"] = "带混",
    --["bSupportQuadruplet"] = "可杠",
    --["bSupportSevenDoubleAdd"] = "七对加倍",
    --["bSupportTing"] = "可听",
    --["bSupportTriplet"] = "可碰",
    --["bSupportTriplet2Quadruplet"] = "可碰上杠",
    --["bSupportWind"] = "带字",
    --["bSupportXiaPao"] = "带跑",
    --["bTingCanPlayOther"] = "听后可换",
    --["nTimeOutCountToAuto"] = "可托管",
    ["bSupportOneColor"] = "清一色",
    --["bSupportHalfColor"] = "半清一色",
    ["bSupportGoldDragon"] = "可胡金龙",
    ["bSupportGunAll"] = "放炮三家赔",
    ["bSupportGunOne"] = "放炮单赔",

    --["bSupportSingleGold"] = "可胡单金",
}


MahjongGameAnimState = 
{
    start = 1,   -- 游戏开始
    changeFlower = 2,   --抢花
    openGold = 3,     -- 开金
    grabGold = 4,   -- 抢金
}


MahjongSyncGameState = 
{
    reward = 0,  --结算阶段 
    gameend = 100, --结束阶段
    prepare = 200, --准备阶段
    xiapao = 300, -- 下跑  发牌之前显示
    deal = 400,  -- 发牌
    laizi = 500, --癞子
    changeflower = 510, -- 补花
    opengold = 520, -- 开金
    round = 600, -- 出牌阶段
}

MahjongItemState =
{
    inWall = 1, --牌墩
    inSelfHand = 2,  -- 在自己手牌
    inOtherHand = 3,    -- 在别人手牌
    inOperatorCard = 4, -- 在操作牌区
    inDiscardCard = 5,  -- 出牌区
    hide = 6,   -- 隐藏
    other = 7,  -- 其他（金，clone牌等）
}
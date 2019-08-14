--[[--
 * @Description: 麻将常量
 * @Author:      ShushingWong
 * @FileName:    mahjongConst.lua
 * @DateTime:    2017-06-20 15:27:39
 ]]

mahjongConst = {}

mahjongConst.MahjongScale = 1

mahjongConst.MahjongOffset_x            = 0.30 * mahjongConst.MahjongScale;--麻将宽度
mahjongConst.MahjongOffset_y            = 0.21 * mahjongConst.MahjongScale;--麻将厚度
mahjongConst.MahjongOffset_z            = 0.41 * mahjongConst.MahjongScale;--麻将长度

mahjongConst.OutCardNum_x               = 5;--出牌区每行个数
mahjongConst.OutCardNum_y               = 4;--出牌区每列个数

mahjongConst.MahjongAnimationTime       = 0.05;--麻将动画时间

mahjongConst.MahjongOperCardInterval    = 0.05;--麻将操作牌间距

mahjongConst.TableFontColor = 
{
    Color(22/255,66/255,48/255),
    Color(5/255,71/255,66/255),
    Color(18/255,58/255,69/255)
}
--[[--
 * @Description: 所有操作类型（3D展示的操作牌类型）
 ]]
MahjongOperAllEnum = {
    None                = 0x0000,-- 无
    GiveUp              = 0x0100,-- 过,
    Collect             = 0x0200,-- 吃,
    NBZZ                = 0x0201,-- 边钻砸消息
    Triplet             = 0x0307,-- 碰,
    TripletLeft         = 0x0301,-- 碰左,
    TripletCenter       = 0x0302,-- 碰中,
    TripletRight        = 0x0304,-- 碰右,
    LiangXiEr           = 0x0399,-- 亮喜儿（中发白）
    DarkBar             = 0x0400,-- 暗杠,
    BrightBar           = 0x0507,-- 明杠,
    BrightBarLeft       = 0x0501,-- 明杠左,
    BrightBarCenter     = 0x0502,-- 明杠中,
    BrightBarRight      = 0x0504,-- 明杠右,
    AddBar              = 0x0607,-- 补杠,
    AddBarLeft          = 0x0601,-- 补杠左,
    AddBarCenter        = 0x0602,-- 补杠中,
    AddBarRight         = 0x0604,-- 补杠右,
    FengGang            = 0x0605,-- 风杠（东南西北）
    Ting                = 0x0700,-- 听,
    TingJinKan          = 0x0701,-- 听金坎,
    QiangTing           = 0x0702,-- 抢听,
    Hu                  = 0x0800,-- 胡,
}

--[[--
 * @Description: 吃碰杠胡提示类型（即askblock按钮，一一对应）
 ]]
MahjongOperTipsEnum = {
    None                = 0x0001,
    GiveUp              = 0x0002,-- 过
    Collect             = 0x0003,-- 吃
    Triplet             = 0x0004,-- 碰
    Quadruplet          = 0x0005,-- 杠
    Ting                = 0x0006,-- 听
    Xiao                = 0x0008,-- 潇洒
    TingJinKan          = 0x0009,-- 听金坎
    TingYouJin          = 0x0010,-- 听游金
    YingKou             = 0x0011,-- 硬扣
    TingDouJin          = 0x0012,-- 听双金
    TingThrJin          = 0x0013,-- 听三金
    NiuBiJiao           = 0x0015,-- 牛逼叫
    LiangXiEr           = 0x0016,-- 亮喜儿
    TianTing            = 0x0017,-- 天听
    Liang               = 0x0018,-- 亮倒
    N_ZA_FLAG           = 0x0019,-- 砸
    N_ZUAN_FLAG         = 0x0020,-- 钻
    N_BIAN_FLAG         = 0x0021,-- 边
    N_ZAGANG_FLAG       = 0x0022,-- 砸杠
    MT                  = 0x0023,-- 明提
    RuanBao             = 0x0024,-- 天听软报
    YingBao             = 0x0025,-- 天听硬报
    QiangTing           = 0x0026,-- 抢听

    Hu                  = 0x0100,-- 胡
    Qiang               = 0x0101,-- 抢
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


MahjongGameAnimState = 
{
    start = 1,   -- 游戏开始
    changeFlower = 2,   --抢花
    openGold = 3,     -- 开金
    grabGold = 4,   -- 抢金
    none = 99, 
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

mahjong_path_enum = 
{
    game = 1,
    mjCommon = 2,
    common = 3, 
}

-- 每圈每人发牌数量
GameDealSendHandCardMap = 
{
    -- 16张
    [1] = 
    {
        [1] = {4,4,4,4},
        [2] = {4,4,4,4},
        [3] = {4,4,4,4},
        [4] = {4,4,4,4},
        [5] = {1,0,0,0}
    },
    -- 13张
    [2] = 
    {
        [1] = {4,4,4,4},
        [2] = {4,4,4,4},
        [3] = {4,4,4,4},
        [4] = {1,1,1,1},
        [5] = {1,0,0,0}
    }
}

MahjongCommonSceneCfg = 
{

}

MahjongSceneCfg = 
{
    -- 16张
    [1] = 
    {
        mainCameraPos = Vector3(0, 8.31, -7.52),
        mainCameraEulers = Vector3(48.6, 0,0),
        mainCameraFieldOfView = 30,

        twoCameraPos = Vector3(0.25, 2.4, -4.52),
        twoCameraEulers = Vector3(12, 0, 0),
        twoCameraSize = 1.66,

        mainCameraPos_4p3 = Vector3(0,11.5,-6.4),
        mainCameraEulers_4p3 = Vector3(62.04,0,0),
        mainCameraFieldOfView_4p3 = 31.3,

        twoCameraPos_4p3 = Vector3(0.26,3.2,-5.72),
        twoCameraEulers_4p3 = Vector3(12, 0, 0),
        twoCameraSize_4p3 = 2.2,

        operPointPosList = 
        {
            Vector3(-3.76, 0.7, -3.59),
            Vector3(2.819, 0.7, -4.123),
            Vector3(3.5,0.7, -3.49),
            Vector3(2.231, 0.7, -4.153),
        },

    },
    -- 13张
    [2] = 
    {
        mainCameraPos = Vector3(0, 8.31, -7.62),
        mainCameraEulers = Vector3(48.6, 0,0),
        mainCameraFieldOfView = 30,

        twoCameraPos = Vector3(0.25, 2.14, -4.52),
        twoCameraEulers = Vector3(12, 0, 0),
        twoCameraSize = 1.4,

        mainCameraPos_4p3 = Vector3(0,11.5,-6.4),
        mainCameraEulers_4p3 = Vector3(62.04,0,0),
        mainCameraFieldOfView_4p3 = 31.3,

        twoCameraPos_4p3 = Vector3(0.26,3.2,-5.72),
        twoCameraEulers_4p3 = Vector3(12, 0, 0),
        twoCameraSize_4p3 = 2.2,

        operPointPosList = 
        {
            Vector3(-3.8, 0.7, -3.67),
            Vector3(2.16, 0.7, -4.123),
            Vector3(3.641,0.7, -3.43),
            Vector3(2.231, 0.7, -4.153),
        },

    },
}

MahjongSelfHandPosOffsetList = 
{
    -- 16张 杠叠起
    [1] = 
    {
        selfHandPosOffsetList = {3.5,2.7,1.8,1,0.3,0.3,0.3}
    },
    -- 13张 杠叠起
    [2] = 
    {
        selfHandPosOffsetList = {5.5,5,4.5,4,3.5,3,2.5}
    },
    -- 13张 杠不叠起
    [3] = 
    {
        selfHandPosOffsetList = {4.5,3.5,2.5,1.5,1,1,1}
    }
}
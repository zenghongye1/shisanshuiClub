using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using UnityEngine;
using LitJson;

namespace TingInfo
{
    public class huTips
    {
#if !UNITY_EDITOR && UNITY_IPHONE
        const string LUADLL = "__Internal";
#else
        const string LUADLL = "dstars";
#endif

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl, EntryPoint = "initLib")]
        extern static void initLib_So(uint style, byte ziMoJiaDi, byte jiaJiaYou);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl, EntryPoint = "checkHuPaiCount")]
        extern static int checkHuPaiCount_So();

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi, EntryPoint = "setEnvironment")]
        extern static int setEnvironment_So(IntPtr env);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi, EntryPoint = "getHuPaiCount")]
        extern static IntPtr getHuPaiCount_So();

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl, EntryPoint = "getVersion")]
        extern static int getVersion_So();

        //[DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl, EntryPoint = "setEnvironment")]
        //extern static int setEnvironment_So(IntPtr ptrEnv);

        //[DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl, EntryPoint = "getHuPaiCount")]
        //extern static int getHuPaiCount_So(ref tagHUPAI_COUNT tn);

        public int getHuTipsVersion()
        {
            return getVersion_So();
        }

        /// <summary>
        /// 初始化听牌参数
        /// </summary>
        /// <param name="style"> 模式，0: --普通模式， 1: --血战模式</param>
        /// <param name="ziMoJiaDi">自摸加底标志</param>
        /// <param name="jiaJiaYou">家家有标志</param>
        public void initHuTipsLib(uint style = 0, byte ziMoJiaDi = 0, byte jiaJiaYou = 0)
        {
            initLib_So(style, ziMoJiaDi, jiaJiaYou);
        }

        public int checkHuTips()
        {
            return checkHuPaiCount_So();
        }

        public string getHuTipsInfo()
        {
            IntPtr intPtr = getHuPaiCount_So();
            string str = Marshal.PtrToStringAnsi(intPtr);
            return str;
        }

        public void setHuTipsEnvironment(string envJson)
        {
            IntPtr intPtr = Marshal.StringToHGlobalAnsi(envJson);
            int ret = setEnvironment_So(intPtr);
        }
    }

    //#region 游戏环境
    //[System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential, CharSet = System.Runtime.InteropServices.CharSet.Ansi)]
    //public struct tagENV_FAN
    //{
    //    public uint byFanType;      //番型
    //    public uint byFanNumber;    //番数
    //    public uint byCount;
    //    [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 256, ArraySubType = System.Runtime.InteropServices.UnmanagedType.I4)]
    //    public int[] byNoCheck;    //相斥的番型
    //}

    ////checkWin 一些附带参数
    //[System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential, CharSet = System.Runtime.InteropServices.CharSet.Ansi)]
    //public struct tagCheckWinParam
    //{
    //    //特殊胡牌
    //    public uint byCheck7pairs;         //检查7小对：0不检查 1癞子做普通牌 2癞子可替任何牌
    //    public uint byCheck8Pairs;         //检查8小对：0不检查 1癞子做普通牌 2癞子可替任何牌
    //    public uint byCheckShiSanYao;      //检查十三幺：0不检查 1癞子做普通牌 2癞子可替任何牌
    //    public uint byLaiziWinNums;        //N张癞子牌可胡 0不检查
    //    public uint byShiSanBuKao;         //十三不靠: 0不检查 1检查

    //    public uint byQiXingBuKao;		   //七星不靠: 0不检查 1检查
    //    //
    //    public uint by258Jiang;            //258将: 0不检查, 1癞子做普通牌 2癞子可替任何牌
    //    public uint byWindPu;              //风扑: 0不检查
    //    public uint byJiangPu;             //将扑: 0不检查
    //    public uint byYaoJiuPu;            //幺九扑: 0不检查

    //    public uint byShunZFB;             //中发白是顺子: 0不检查 1癞子做普通牌 2癞子可替任何牌
    //    public uint byShunWind;            //东南西北是顺子: 0不检查 1任意三张组合成顺子(癞子不可替换), 
    //                                       //2按顺序组合成顺子(癞子不可替换),3任意三张组合成顺子(癞子可替换), 
    //                                       //4按顺序组合成顺子(癞子可替换)

    //    public uint byBKDHu;			   //胡牌必须是边卡吊:0不检查，1

    //    public uint byBaiChangeGoldUse;    //白板当金本身使用(白板充当做癞子的那张牌)
    //    public uint byMaxHandCardLength;   //手牌最大的数量
    //    public uint nGameStyle;            //游戏类型

    //    public uint nEightFlowerHu;        //八张花是否可胡牌,0:否，1是
    //    public uint byKaiMenLimit;	 	   //开门限制，0没有，1没有吃碰杠不能胡
    //    public uint byColorLimit;		   //胡牌需要花色限制 0没有，1缺一门胡可带风牌，2缺一门胡不可带风牌，3种花色齐全
    //    public uint byQYSHu;			   //有花色限制时，是否可以胡清一色，0不可以，1可以
    //    public uint byYaoJiuLimit;	 	   //幺九限制，0没有，1有
    //    public uint byDanDiaoLimit;	       //手把一，单吊胡牌仅允许飘胡牌型，即有“吃”就不允许单吊胡牌，0无，1 有

    //    [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 37)]
    //    public uint[] nNSNum;              // 剩余各个牌的数

    //    public uint byOneGoldLimit;     //单金不能点炮胡
    //    public uint byTwoGoldLimit;		//双金以上必须游金胡
    //}

    //[System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential, CharSet = System.Runtime.InteropServices.CharSet.Ansi)]
    //public struct tagENVIRONMENT
    //{
    //    public uint byChair;        // 检查谁的
    //    public uint byTurn;         // 轮到谁，如果是点炮，则是点炮的那个人

    //    /// unsigned int[56]
    //    [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 4*17, ArraySubType = System.Runtime.InteropServices.UnmanagedType.U4)]
    //    public uint[] tHand;        // 四家手上的牌

    //    /// unsigned int[4]
    //    [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 4, ArraySubType = System.Runtime.InteropServices.UnmanagedType.U4)]
    //    public uint[] byHandCount; // 手上有几张牌

    //    /// unsigned int[48]
    //    [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 4*4*3, ArraySubType = System.Runtime.InteropServices.UnmanagedType.U4)]
    //    public uint[] tSet;         // 四家，4手牌，flag、tile、chair

    //    /// unsigned int[4]
    //    [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 4, ArraySubType = System.Runtime.InteropServices.UnmanagedType.U4)]
    //    public uint[] bySetCount;   // set有几手牌

    //    /// unsigned int[160]
    //    [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 4*40, ArraySubType = System.Runtime.InteropServices.UnmanagedType.U4)]
    //    public uint[] tGive;        // 四家出过的牌

    //    /// unsigned int[4]
    //    [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 4, ArraySubType = System.Runtime.InteropServices.UnmanagedType.U4)]
    //    public uint[] byGiveCount;  // 每人出了几张牌

    //    /// unsigned int
    //    public uint tLast;          // 最后和的那张牌

    //    /// unsigned int
    //    public uint byFlag;         // 0自摸、1点炮、2杠上花、3抢杠

    //    /// unsigned int
    //    public uint byRoundWind;    // 圈风

    //    /// unsigned int
    //    public uint byPlayerWind;   // 门风

    //    /// unsigned int
    //    public uint byTilesLeft;    // 还剩多少张牌，用来计算海底等

    //    /// unsigned int[4]
    //    [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 4, ArraySubType = System.Runtime.InteropServices.UnmanagedType.U4)]
    //    public uint[] byFlowerCount;    // 4家各有多少张花

    //    /// unsigned int[4]
    //    [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 4, ArraySubType = System.Runtime.InteropServices.UnmanagedType.U4)]
    //    public uint[] byTing;           // 听牌的玩家

    //    /// unsigned int[4]
    //    [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 4, ArraySubType = System.Runtime.InteropServices.UnmanagedType.U4)]
    //    public uint[] byDoFirstGive;    // 4家是否出过牌(这个主要用来判断地胡)

    //    /// unsigned int[6]
    //    [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 6, ArraySubType = System.Runtime.InteropServices.UnmanagedType.U4)]
    //    public uint[] byRecv;

    //    /// unsigned int[4]
    //    [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 4, ArraySubType = System.Runtime.InteropServices.UnmanagedType.U4)]
    //    public uint[] byLaiziCards; // 癞子牌数组，暂定最大是4个

    //    /// unsigned int[37]
    //    [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 37, ArraySubType = System.Runtime.InteropServices.UnmanagedType.U4)]
    //    public uint[] nNSNum;   // 剩余各个牌的数目

    //    /// unsigned int
    //    public uint byMaxHandCardLength;   //手牌最大的数量

    //    [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 256, ArraySubType = System.Runtime.InteropServices.UnmanagedType.I4)]
    //    public int[] byDoCheck;	//需要计算的番型

    //    [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 256)]
    //    public tagENV_FAN[] byEnvFan;  //番型数据:{"byFanNumber"=1,"byFanType"=2,"byNoCheck"={1,2,3...}}

    //    [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.Struct)]
    //    public tagCheckWinParam checkWinParam;  //check win 中一些必要的参数

    //    /// unsigned int
    //    public uint byQYSNoWord;		//清一色是否包含字一色

    //    /// unsigned int
    //    public uint nMissHu;            // 缺一门标志

    //    /// unsigned int
    //    public uint nMissWind;			// 缺一门可以有风牌

    //    /// unsigned int
    //    public uint byDealer;   // 庄家

    //    /// unsigned int
    //    public uint gamestyle;  // 游戏类型

    //    /// unsigned int
    //    public uint laizi;      // 癞子数量，或金数量

    //    /// unsigned int
    //    public uint flower;     // 花数量

    //    /// unsigned int
    //    public uint byGangTimes;        // 杠上花时，杠的次数

    //    public uint byHaiDi;			// 是否是海底(荒局前最后一张，用来判断海底捞月和海底炮)

    //    /// unsigned int
    //    public uint byGodTingFlag;      // 天听标志

    //    /// unsigned int
    //    public uint byGroundTingFlag;   // 地听标志

    //    /// unsigned int
    //    public uint byXiaoSaTingFlag;   // 潇洒标志

    //    /// unsigned int
    //    //public uint bDanDiaoHu;         // 单吊胡

    //    /// unsigned int
    //    public uint byHunYouFlag;       // 混悠标志

    //    /// unsigned int
    //    public uint KeLimit;            //刻子limit

    //    /// unsigned int
    //    public uint byHaveWinds;        //牌池不一样的牌的总数，一般是27，31，34

    //    /// unsigned int
    //    //public uint bkaAdd;             // 卡张胡

    //    /// unsigned int
    //    //public uint n258Jiang;          // 258标志
    //}
    //#endregion

    //#region 胡牌信息
    //[System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential, CharSet = System.Runtime.InteropServices.CharSet.Ansi)]
    //public struct tagHUPAIINFO_NODE
    //{
    //    public byte bHu;                    //每种胡是否满足
    //    public uint szHuCard;               //听的牌
    //    public uint szHuCardleft;           //听的牌剩余几张
    //}

    //[System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential, CharSet = System.Runtime.InteropServices.CharSet.Ansi)]
    //public struct tagHUPAI_NODE
    //{
    //    [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 37, ArraySubType = System.Runtime.InteropServices.UnmanagedType.Struct)]
    //    public tagHUPAIINFO_NODE[] szHuPaiInfo;     //胡的牌
    //    public uint szGiveCard;                     //出的牌
    //    public uint flag;                           //1表示胡所有
    //    public byte bCanHuPai;                      //出这张牌是否能胡
    //}

    //[System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential, CharSet = System.Runtime.InteropServices.CharSet.Ansi)]
    //public struct tagHUPAI_COUNT
    //{
    //    [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 17, ArraySubType = System.Runtime.InteropServices.UnmanagedType.Struct)]
    //    public tagHUPAI_NODE[] m_HuPaiNode;
    //}
    //#endregion

}

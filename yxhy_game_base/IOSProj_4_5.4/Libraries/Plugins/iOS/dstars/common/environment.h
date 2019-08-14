//////////////////////////////////////////////////////////////////////////////////////
//
//  FileName    :   environment.h
//  Comment     :   游戏环境，计算番时使用
//
//////////////////////////////////////////////////////////////////////////////////////

#ifndef _ENVIRONMENT_H
#define _ENVIRONMENT_H
#include <stdio.h>
typedef	unsigned int BYTE;
typedef unsigned int TILE;

#define MAX_ENV_FAN 256
typedef struct tagENV_FAN
{
	BYTE    byFanType; 		//番型
	BYTE    byFanNumber;	//番数
	BYTE    byCount;
	int    byNoCheck[MAX_ENV_FAN];	//相斥的番型
}ENV_FAN;

//checkWin 一些附带参数
typedef struct tagCheckWinParam
{
	//特殊胡牌
	BYTE	byCheck7pairs;			//检查7小对：0不检查 1癞子做普通牌 2癞子可替任何牌
	BYTE	byCheck8Pairs;			//检查8小对：0不检查 1癞子做普通牌 2癞子可替任何牌
	BYTE	byCheckShiSanYao;		//检查十三幺：0不检查 1癞子做普通牌 2癞子可替任何牌
	BYTE    byLaiziWinNums;			//N张癞子牌可胡 0不检查
	BYTE	byShiSanBuKao;			//十三不靠: 0不检查 1检查

	BYTE	byQiXingBuKao;			//七星不靠: 0不检查 1检查
	//
	BYTE	by258Jiang;				//258将: 0不检查, 1癞子做普通牌 2癞子可替任何牌
	BYTE	byWindPu;				//风扑: 0不检查
	BYTE	byJiangPu;				//将扑: 0不检查
	BYTE	byYaoJiuPu;				//幺九扑: 0不检查

	BYTE	byShunZFB;				//中发白是顺子: 0不检查 1癞子做普通牌 2癞子可替任何牌
	BYTE	byShunWind;				//东南西北是顺子: 0不检查 1任意三张组合成顺子(癞子不可替换), 
									//2按顺序组合成顺子(癞子不可替换),3任意三张组合成顺子(癞子可替换), 
									//4按顺序组合成顺子(癞子可替换)

	BYTE	byBKDHu;				//胡牌必须是边卡吊:0不检查，1
	
	BYTE   	byBaiChangeGoldUse;	 	//白板当金本身使用(白板充当做癞子的那张牌)
	BYTE    byMaxHandCardLength;	//手牌最大的数量
	BYTE	nGameStyle;				//游戏类型

	BYTE    nEightFlowerHu;      //0没有，1八张花可胡
	BYTE   	byKaiMenLimit;	 	//开门限制，0没有，1没有吃碰杠不能胡
	BYTE    byColorLimit;		////胡牌需要花色限制 0没有，1缺一门胡可带风牌，2缺一门胡不可带风牌，3种花色齐全
	BYTE	byQYSHu;				//有花色限制时，是否可以胡清一色，0不可以，1可以
	BYTE   	byYaoJiuLimit;	 	//幺九限制，0没有，1有
	BYTE    byDanDiaoLimit;	//手把一，单吊胡牌仅允许飘胡牌型，即有“吃”就不允许单吊胡牌，0无，1 有

	BYTE    nNSNum[37];         // 剩余各个牌的数目
	BYTE    byOneGoldLimit;     //单金不能点炮胡
	BYTE    byTwoGoldLimit;		//双金以上必须游金胡
	tagCheckWinParam()
	{
		byCheck7pairs = 0;
		byCheck8Pairs = 0;
		byCheckShiSanYao = 0;
		byLaiziWinNums = 0;
		byShiSanBuKao = 0;
		byQiXingBuKao = 0;
		by258Jiang = 0;
		byWindPu = 0;
		byJiangPu = 0;
		byYaoJiuPu = 0;

		byShunZFB = 0;
		byShunWind = 0;
		byBKDHu = 0;
		byBaiChangeGoldUse = 0;
		byMaxHandCardLength = 14;
		nGameStyle = 0;
		nEightFlowerHu = 0;
		byKaiMenLimit = 0;
		byColorLimit = 0;
		byQYSHu = 0;// 胡牌有花色限制的话(兴安盟必须3色胡)，可以胡清一色
		byYaoJiuLimit = 0;
		byDanDiaoLimit = 0;
		//不用初始化
		//memset(&nNSNum, 0, sizeof(nNSNum));
		byOneGoldLimit = 0;     //单金不能点炮胡
		byTwoGoldLimit = 0 ;		//双金以上必须游金胡
	};
}CHECKWIN_PARAM;

typedef	struct tagENVIRONMENT
{
	BYTE	byChair;			// 检查谁的
	BYTE	byTurn;				// 轮到谁，如果是点炮，则是点炮的那个人
	TILE	tHand[4][17];		// 四家手上的牌
	BYTE	byHandCount[4];		// 手上有几张牌

	TILE	tSet[4][4][3];		// 四家，4手牌，flag、tile、chair
	BYTE	bySetCount[4];		// set有几手牌

	TILE	tGive[4][40];		// 四家出过的牌
	BYTE	byGiveCount[4];		// 每人出了几张牌

	TILE	tLast;				// 最后和的那张牌
	BYTE	byFlag;				// 0自摸、1点炮、2杠上花、3抢杠
	
	BYTE	byRoundWind;		// 圈风
	BYTE	byPlayerWind;		// 门风
	BYTE	byTilesLeft;		// 还剩多少张牌，用来计算海底等

	BYTE	byFlowerCount[4];	// 4家各有多少张花
	
	BYTE	byTing[4];			// 听牌的玩家

	BYTE	byDoFirstGive[4];	// 4家是否出过牌(这个主要用来判断地胡)

	BYTE	byRecv[6];

	BYTE    byLaiziCards[4];    // 癞子牌数组，暂定最大是4个

	BYTE    nNSNum[37];         // 剩余各个牌的数目

	BYTE    byMaxHandCardLength;	//手牌最大的数量

	int 	byDoCheck[MAX_ENV_FAN];	//需要计算的番型

	ENV_FAN byEnvFan[MAX_ENV_FAN];  //番型数据:{"byFanNumber"=1,"byFanType"=2,"byNoCheck"={1,2,3...}}

	CHECKWIN_PARAM checkWinParam;	//check win 中一些必要的参数

	BYTE   	byQYSNoWord;		//清一色是否包含字一色
	BYTE    nMissHu;            // 缺一门标志
	BYTE    nMissWind;			// 缺一门可以有风牌
	// BYTE    nMissHun;		// 缺一门可以有混牌(缺筒子,如果混牌是筒子,则不用检查胡)
	BYTE    byDealer;			// 庄家
	BYTE    gamestyle;          // 游戏类型，
	BYTE    laizi;              // 癞子数量，或金数量
	BYTE    flower;             // 花数量
	BYTE    byGangTimes;        // 杠上花时，杠的次数
	BYTE    byHaiDi;			// 是否是海底(荒局前最后一张，用来判断海底捞月和海底炮)


	//可在lua做判断 就不要在C++做判断了
	BYTE    byGodTingFlag;      // 天听标志
	BYTE    byGroundTingFlag;   // 地听标志
	BYTE    byXiaoSaTingFlag;   // 潇洒标志
	// BYTE    bDanDiaoHu;	        // 单吊胡
	BYTE    byHunYouFlag;       // 混悠标志
			
	BYTE   KeLimit;                 //刻子limit
	BYTE   byHaveWinds;             //牌池不一样的牌的总数，一般是27，31，34
	// BYTE    bkaAdd;             // 卡张胡
	// BYTE    n258Jiang;          // 258标志

}ENVIRONMENT;

//void PrintEnv(const ENVIRONMENT* pstEnv);

#endif	// _ENVIRONMENT_H

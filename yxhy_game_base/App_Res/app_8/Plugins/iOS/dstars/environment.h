//////////////////////////////////////////////////////////////////////////////////////
//
//  FileName    :   environment.h
//  Version     :   1.0
//  Creater     :   floppy
//  Date        :   2004-4-1 14:28:15
//  Comment     :   游戏环境，计算番时使用
//
//////////////////////////////////////////////////////////////////////////////////////

#ifndef _ENVIRONMENT_H
#define _ENVIRONMENT_H
#include <stdio.h>
typedef	unsigned char BYTE;
typedef unsigned char TILE;

typedef	struct tagENVIRONMENT
{
	BYTE	byChair;			// 检查谁的
	BYTE	byTurn;				// 轮到谁，如果是点炮，则是点炮的那个人
	TILE	tHand[4][17];		// 四家手上的牌
	BYTE	byHandCount[4];		// 手上有几张牌

	TILE	tSet[4][5][3];		// 四家，4手牌，flag、tile、chair
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
	//TILE	tBefore[10];		// 和牌前别人出过的牌

	BYTE    gamestyle;          //游戏类型，
	BYTE    qianggang;          //抢杠，
	BYTE    menqing;			//门清
	BYTE    bkd;				//边卡吊
	BYTE    wukui;				//五魁
	BYTE    byDealer;				//庄家

	BYTE    qiangjin;             //是否是抢金胡：1是，0非
	BYTE    laizi;             //癞子数量，或金数量
	BYTE    flower;             //花数量
	BYTE    byLaiziCards[4];    //癞子牌数组，暂定最大是4个

	BYTE    halfQYS;           //是否支持在半清一色
	BYTE    allQYS;           //是否支持全清一色
	BYTE    goldDragon;           //是否支持金龙
	BYTE    nNSNum[37];         //剩余各个牌的数目
	BYTE    bankerfirst;
	
}ENVIRONMENT;

void PrintEnv(const ENVIRONMENT* pstEnv);

#endif	// _ENVIRONMENT_H

// MJFanCounter.h: interface for the CMJFanBaseFuzhou class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_MJFANCOUNTER_H__A720C7FA_091F_47FC_A284_B75795F05DE3__INCLUDED_)
#define AFX_MJFANCOUNTER_H__A720C7FA_091F_47FC_A284_B75795F05DE3__INCLUDED_
#pragma once

#include "MJ_sc_def.h"
#include "environment.h"
//typedef		unsigned char	BOOL;
#define		TRUE	1
#define		FALSE	0

#define MAX_FAN_NUMBER		60
#define MAX_FAN_NAME		24

#define MAX_CARD_NUMBER		144

#define MAX_CARD_LENGTH		17

#define MAX_CARD_POOL		30


class CMJFanGuoBiao;
class CMJFanPop;
class CMJFanNormal;
class CMJFunFuZhou;
class CMJFanBaseFuzhou
{
public:
	typedef void (*CHECKFUNC)(CMJFanBaseFuzhou*);
	typedef struct tagFAN_NODE
	{
		BOOL		bFan;						// 每种番是否满足
		BOOL		bCheck;						// 是否检查该项
		CHECKFUNC	Check;						// 检查函数
		char		szFanName[MAX_FAN_NAME];	// 每种番的名字
		int		byFanNumber;				// 每种番是多少番
		BYTE		byCount;					// 数量
		BYTE        byFanType;                  //对应番名字
	}FAN_NODE;

	typedef	struct tagFAN_COUNT
	{
		FAN_NODE	m_FanNode[MAX_FAN_NUMBER];
	}FAN_COUNT;

	//听牌信息
	typedef void(*TINGFUNC)(CMJFanBaseFuzhou*);
	typedef struct tagTINGINFO_NODE
	{
		BOOL		bTing;						// 每种Ting是否满足
		int		byTingFanNumber;				// 听这张牌是多少番
		BYTE        szTingCard;                  //听的牌
		BYTE        szTingCardleft;                  //听的牌剩余几张

	}TINGINFO_NODE;

	typedef struct tagTING_NODE
	{
		TINGINFO_NODE        szTingInfo[MAX_CARD_POOL];                  //听的牌
		BYTE				 szGiveCard;                  //出的牌
		BOOL		bCanTing;						// 出这张牌是否能听
		BYTE        flag;                          //1表示听所有
		BOOL        bIsYouJin;                     //是否是游金/闲金

	}TING_NODE;

	typedef	struct tagTING_COUNT
	{
		TING_NODE	m_TingNode[MAX_CARD_LENGTH];
	}TING_COUNT;
	//

	class CTiles
	{
	public:
		TILE	tile[MAX_CARD_NUMBER];
		int		nCurrentLength;

		CTiles();
		virtual ~CTiles();

		void	Swap(int src, int dst);

		void	AddTile(TILE t);
		void	AddTiles(CTiles& tiles);
		void	AddTiles(TILE* pTiles, int nCount);

		void	DelTile(TILE t);
		void	DelTiles(CTiles& tiles);

		BOOL	IsSubSet(CTiles& tiles);
		BOOL	IsHave(TILE t);

		void	ReleaseAll();
		void	Sort();

		void	AddCollect(TILE tStart);	// 增加一个tStart开始的顺子
		void	AddTriplet(TILE t);			// 增加t的刻子

	};

	CMJFanBaseFuzhou();
    int InitFanCounter(int nMinWin, int nBaseBet)
    {
        m_nMinWin = nMinWin;
        m_nBaseBet = nBaseBet;
        return 0;
    }
    ENVIRONMENT* MutableEnv() { return &env;}
	virtual ~CMJFanBaseFuzhou();

	virtual	BOOL Count(FAN_COUNT*& pFanCount);
	virtual BOOL GetScore(int nScore[4]);
    virtual void InitForNext() {};
    virtual bool CheckWin(CTiles & tilesHand,int nlaiziCount, CTiles & laiziCard,int ngamestyle);
	virtual	int TingCount();
	virtual TING_COUNT getTingCount() { return m_TingCount; };
	
protected:
    ENVIRONMENT env;
    FAN_COUNT	m_FanCount;
	TING_COUNT	m_TingCount;
    int			m_nGameStyle;			// 游戏类型
    int			m_nMinWin;				// 能和牌的最小番数
    int			m_nBaseBet;				// 底分
protected:
	static void	CollectAllTile(CTiles& tilesAll, ENVIRONMENT& env, BYTE chair);	// 得到某全家全部的牌
	static void	CollectHandTile(CTiles& tilesHand, ENVIRONMENT& env, BYTE chair);   // 得到手上的牌

    static BOOL CheckWinDouble(CTiles &tilesHand);
	static BOOL CheckWinNormal(CTiles &tilesHand);
	static BOOL CheckWinNoJiang(CTiles &tilesHand);	// 去掉将剩下的牌
	static BOOL CheckWinShiSanYao(CTiles &tilesHand);

	static BOOL CheckWinDoubleLaiZi(CTiles &tilesHand,int nLaiZiCount, CTiles & nLaiZiCard);
	static BOOL CheckWinNormalLaiZi(CTiles &tilesHand, int nLaiZiCount,int nCardLength);

	static BOOL CheckWinNoJiangLaizi(CTiles &tilesHand, int nLaiZiCount, int nCardLength);	// 去掉将剩下的牌,可以有癞子


    friend class CMJFunFuZhou;

};

#endif // !defined(AFX_MJFANCOUNTER_H__A720C7FA_091F_47FC_A284_B75795F05DE3__INCLUDED_)

// MJFanCounter.h: interface for the CMJFanCounter class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_MJFANCOUNTER_H__A720C7FA_091F_47FC_A284_B75795F05DE3__INCLUDED_)
#define AFX_MJFANCOUNTER_H__A720C7FA_091F_47FC_A284_B75795F05DE3__INCLUDED_
#pragma once

#include "MJ_sc_def.h"
#include "environment.h"
#define SO_VERSION 101

#ifndef BOOL
typedef		unsigned char	BOOL;
#endif // !BOOL

#ifndef TRUE
#define		TRUE	1
#endif

#ifndef FALSE
#define		FALSE	0
#endif

#define MAX_FAN_NUMBER		256
#define MAX_FAN_NAME		24

#define MAX_CARD_NUMBER		128


#define MAX_CARD_LENGTH		17

#define MAX_CARD_POOL		37

class CMJFun;
class CMJFanCounter
{
public:
	typedef void(*CHECKFUNC)(CMJFanCounter*);
	typedef struct tagFAN_NODE
	{
		BOOL		bFan;						// 每种番是否满足
		BOOL		bCheck;						// 是否检查该项
		CHECKFUNC	Check;						// 检查函数
		char		szFanName[MAX_FAN_NAME];	// 每种番的名字
		BYTE		byFanNumber;				// 每种番是多少番
		BYTE		byCount;					// 数量
		BYTE        byFanType;                  //对应番名字
	}FAN_NODE;

	typedef	struct tagFAN_COUNT
	{
		FAN_NODE	m_FanNode[MAX_FAN_NUMBER];
	}FAN_COUNT;

	//听牌信息
	typedef void(*TINGFUNC)(CMJFanCounter*);
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


	//胡牌信息
	typedef void(*HUPAIFUNC)(CMJFanCounter*);
	typedef struct tagHUPAIINFO_NODE
	{
		BOOL		bHu;					// 每种胡是否满足
		BYTE        szHuCard;               //听的牌
		BYTE        szHuCardleft;           //听的牌剩余几张

	}HUPAIINFO_NODE;

	typedef struct tagHUPAI_NODE
	{
		HUPAIINFO_NODE        	szHuPaiInfo[MAX_CARD_POOL];   //胡的牌
		BYTE				 	szGiveCard;                  //出的牌
		BYTE					flag;                          //1表示胡所有
		BOOL					bCanHuPai;					// 出这张牌是否能胡
	}HUPAI_NODE;

	typedef	struct tagHUPAI_COUNT
	{
		HUPAI_NODE	m_HuPaiNode[MAX_CARD_LENGTH];
	}HUPAI_COUNT;

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
		void	DelTileAll(TILE t);

		BOOL	IsSubSet(CTiles& tiles);
		BOOL	IsHave(TILE t);
		BOOL	IsHaveNum(TILE t, int num);
		void	ReleaseAll();
		void	Sort();

		void	AddCollect(TILE tStart);	// 增加一个tStart开始的顺子
		void	AddTriplet(TILE t);			// 增加t的刻子

		int     size();

	};

	CMJFanCounter();
	int InitFanCounter(int nMinWin, int nBaseBet)
	{
		m_nMinWin = nMinWin;
		m_nBaseBet = nBaseBet;
		return 0;
	}
	ENVIRONMENT* MutableEnv() { return &env; }
	virtual ~CMJFanCounter();

	virtual	BOOL Count(FAN_COUNT*& pFanCount);
	virtual BOOL GetScore(int nScore[4]);
	virtual void InitForNext() {};
	virtual BOOL CheckWin(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam);
	virtual	BOOL TingCount(TING_COUNT*& pTingCount);
	virtual	BOOL HuPaiCount(HUPAI_COUNT*& pHuPaiCount);
protected:
	ENVIRONMENT env;
	FAN_COUNT	m_FanCount;

	TING_COUNT	m_TingCount;
	HUPAI_COUNT	m_HuPaiCount;

	int			m_nGameStyle;			// 游戏类型
	int			m_nMinWin;				// 能和牌的最小番数
	int			m_nBaseBet;				// 底分
	static int         m_nWind;
	static int         m_nJiang;
	static int         m_nYaoJiu;
	static int         m_bZFBWind; //中发白成顺
protected:

	//胡牌先决条件检查
	static BOOL CheckWinLimit(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam);

	//特殊胡牌检查：7小对、十三幺、13不靠、8小对等。。。
	static BOOL CheckWinSpecial(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam);

	//正常胡牌检查
	static BOOL CheckWinPublic(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam);
	//龙岩麻将特殊胡法
	static BOOL CheckWinNormalLongYan(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam);
	//风扑将扑幺九扑特殊胡法  如濮阳麻将
	static BOOL CheckWinNormalWJYJPu(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam);
	//258将特殊胡法  如新乡、开封麻将
	static BOOL CheckWinNormal258Jiang(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam);

	//边卡吊胡:通辽麻将
	static BOOL CheckWinNormalBKD(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam);
	static BOOL CheckWinNormalB(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam);
	static BOOL CheckWinNormalK(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam);
	static BOOL CheckWinNormalD(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam);

protected:
	static void	CollectAllTile(CTiles &tilesAll, ENVIRONMENT &env, BYTE chair);	// 得到某全家全部的牌
	static void	CollectHandTile(CTiles &tilesHand, ENVIRONMENT &env, BYTE chair);   // 得到手上的牌
	static void	CollectLaiziTile(CTiles &tilesLaizi, ENVIRONMENT &env);   // 得到牌局的癞子牌

	//tilesHand全部手牌
	static BOOL CheckWinNormal(CTiles &tilesHand, int nCardLength);
	//tilesHand去掉将后的全部手牌
	static BOOL CheckWinNoJiang(CTiles &tilesHand, int nCardLength);
	//tilesHand无赖子手牌
	static BOOL CheckWinNormalLaiZi(CTiles &tilesHand, CTiles &laiziCard, int nLaiZiCount, int nCardLength, CHECKWIN_PARAM &checkWinParam);
	//tilesHand去掉将后的无赖子手牌
	static BOOL CheckWinNoJiangLaizi(CTiles &tilesHand, CTiles &laiziCard, int nLaiZiCount, int nCardLength, CHECKWIN_PARAM &checkWinParam);	// 去掉将剩下的牌,可以有癞子
	//检查风扑将扑幺九扑是否可赢， tilesHand无赖子手牌
	static BOOL CheckWinWJYJPu(CTiles &tilesHand, CHECKWIN_PARAM &checkWinParam);

	static BOOL		CheckIsTriplet(CTiles tilesHand);	// 检查的牌型是否“碰碰胡”牌型

	//7小对
	static BOOL CheckWinDouble(CTiles &tilesHand);
	static BOOL CheckWinDoubleLaiZi(CTiles &tilesHand, int nLaiZiCount);
	//十三幺
	static BOOL CheckWinShiSanYao(CTiles &tilesHand);
	static BOOL CheckWinShiSanYaoLaizi(CTiles &tilesHand, int nLaiZiCount);//带癞子的13幺
	static BOOL CheckWinShiSanYaoLaiziLongYan(CTiles &tilesHand, CTiles &laiziCard, int nLaiZiCount); //带癞子的13幺 白板替换金牌原来的牌
	//十三不靠
	static BOOL CheckWinShiSanBuKao(CTiles &tilesHand);
	//七星不靠
	static BOOL CheckWinQiXingBuKao(CTiles &tilesHand);
	//8小对
	static int  CheckWinPair8(CTiles &tilesHand, int nLaiZiCount, int nLength = 17, bool bLast = false);


	friend class CMJFun;
};

#endif // !defined(AFX_MJFANCOUNTER_H__A720C7FA_091F_47FC_A284_B75795F05DE3__INCLUDED_)

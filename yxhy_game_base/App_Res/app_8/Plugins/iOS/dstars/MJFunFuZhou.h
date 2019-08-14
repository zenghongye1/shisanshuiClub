// MJFunFuZhou.h: interface for the CMJFunFuZhou class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_MJFUNCHENGDU_H__6B6B9972_76DC_4ED5_B98D_407370829DBD__INCLUDED_)
#define AFX_MJFUNCHENGDU_H__6B6B9972_76DC_4ED5_B98D_407370829DBD__INCLUDED_


#include "MJFanBaseFuzhou.h"


/*
struct CHENGDU_SCORE_RECORD
{
	BYTE	byCount;			//本局血战的次数，最多为3，即最多三次胡(最后一次可能是荒牌)。
	BYTE	byFlag[3];			// 状态，荒牌、点炮、自摸
	BYTE	byFan[3][32];		// 番， 只需要传递128字节的前面32字节就足够了。
	BYTE	byFanNumber[3][32];	// 番数，如杠、根等。只需要传递128字节的前面32字节就足够了。
	BYTE	byWhoHu[3];			// 谁和的
	BYTE	byWhoGun[3];			// 谁点炮的
	int		nScore[3][4];
	int		nMoney[3][4];
	int		nScoreGang[4];		//再说明下刮风下雨的情况，每个人得分，之前已经被扣或者加。
	int		nMoneyGang[4];		//再说明下刮风下雨的情况，每个人游戏币，之前已经被扣或者加。
	int		nScoreZiMoJiaDi[4];		// 自摸加底的得分
	int		nMoneyZiMoJiaDi[4];		// 自摸加底的游戏币

	BOOL	bHuaZhu[4];			//谁花猪	FINISH_NOTILE的时候才有用
	BOOL	bTing[4];			//谁听		FINISH_NOTILE的时候才有用
	char	cFanTing[4];		//听的人的番数	FINISH_NOTILE的时候才有用

	int		nScoreTotal[4];		//总输赢分
	int		nMoneyTotal[4];		//总输赢游戏币
	int		nScoreLast[4];		//最后输赢分
	int		nMoneyLast[4];		//最后输赢游戏币

	BYTE	tLast[3];			// 和的那一张
	CHENGDU_SCORE_RECORD()
	{
		memset(this, 0, sizeof(CHENGDU_SCORE_RECORD)); 
	}
};

*/
class CMJFunFuZhou : public CMJFanBaseFuzhou  
{
public:
	CMJFunFuZhou();
	virtual ~CMJFunFuZhou();
public:
	
    int InitFanChengDuCounter(BYTE byStyle, bool bZiMoJiaDi, bool bJiaJiaYou)
    {
        m_byStyle = byStyle;
        m_bZiMoJiaDi = bZiMoJiaDi;
        m_bJiaJiaYou = bJiaJiaYou;
        return 0;
    }
   

	int GetFan();
	int GetFangold(BOOL isgold);
	BOOL CountTing(FAN_COUNT*& pFanCount,bool isgold);

public:
    virtual	BOOL Count(FAN_COUNT*& pFanCount);
    virtual BOOL GetScore(int nScore[4]);
    virtual void InitForNext();
	virtual	int TingCount();
	virtual TING_COUNT getTingCount() { return m_TingCount; };

private:		//CHD, 成都麻将专用 
    BOOL  CHD_SetRecordAndGetScore(int nScore[4]);	//血战模式记分。一次胡的分，而非总分
private:

	BYTE m_byStyle; // 0: --普通模式， 1: --血战模式
	BOOL m_bZiMoJiaDi;			// 自摸加底
	BOOL m_bJiaJiaYou;			// 家家有
	int m_nZiMoJiaDi[4];		//得到加底的数量
	static BOOL m_bNew19Check;			// 新的幺九牌型检查

private:
	//辅助函数
	static BOOL		CheckIsAllPairs(CTiles tiles);	//检查是否都是对子 
	static BOOL		CheckIsOneColor(CTiles tiles);	//检查是否清一色
	static BOOL		CheckIsTripletsHu(CTiles tilesHand);	// 检查的牌型是否“碰碰胡”牌型
	static BOOL		CheckIs19Hu(CTiles tiles);	// 检查牌型是否幺九胡牌型。 

private:
	static void		Check000(CMJFanBaseFuzhou* pCounter);	// 平胡 
	static void		Check001(CMJFanBaseFuzhou* pCounter);	// 碰碰胡
	static void		Check002(CMJFanBaseFuzhou* pCounter);	// 清一色
	static void		Check003(CMJFanBaseFuzhou* pCounter);	// 带幺九
	static void		Check004(CMJFanBaseFuzhou* pCounter);	// 七小对
	static void		Check005(CMJFanBaseFuzhou* pCounter);	// 龙七对
	static void		Check006(CMJFanBaseFuzhou* pCounter);	// 清对
	static void		Check007(CMJFanBaseFuzhou* pCounter);	// 清七对
	static void		Check008(CMJFanBaseFuzhou* pCounter);	// 清幺九
	static void		Check009(CMJFanBaseFuzhou* pCounter);	// 将对	, 258碰碰胡
	static void		Check010(CMJFanBaseFuzhou* pCounter);	// 清龙七对 

	static void		Check011(CMJFanBaseFuzhou* pCounter);	//另加番: 杠
	static void		Check012(CMJFanBaseFuzhou* pCounter);	//另加番: 根
	static void		Check013(CMJFanBaseFuzhou* pCounter);	//另加番：杠上花 
	static void		Check014(CMJFanBaseFuzhou* pCounter);	//另加番：杠上炮  
	static void		Check015(CMJFanBaseFuzhou* pCounter);	//另加番：抢杠胡 

	static void		Check016(CMJFanBaseFuzhou* pCounter);	//庄家起手自模，即“天胡”。 
	static void		Check017(CMJFanBaseFuzhou* pCounter);	//非庄家起手自模，即“地胡”。 
												
	//河北麻将
	static void		Check018(CMJFanBaseFuzhou* pCounter);	// 自摸 
	static void		Check019(CMJFanBaseFuzhou* pCounter);	// 点炮
	static void		Check020(CMJFanBaseFuzhou* pCounter);	// 门清 
	static void		Check021(CMJFanBaseFuzhou* pCounter);	// 边 
	static void		Check022(CMJFanBaseFuzhou* pCounter);	// 卡 
	static void		Check023(CMJFanBaseFuzhou* pCounter);	// 吊 
	static void		Check024(CMJFanBaseFuzhou* pCounter);	// 庄家 
	static void		Check025(CMJFanBaseFuzhou* pCounter);	// 一条龙
	static void		Check026(CMJFanBaseFuzhou* pCounter);	// 海底捞月
	static void		Check027(CMJFanBaseFuzhou* pCounter);	// 豪华七对 
	static void		Check028(CMJFanBaseFuzhou* pCounter);	// 超豪华七对
	static void		Check029(CMJFanBaseFuzhou* pCounter);	// 捉五魁
	static void		Check030(CMJFanBaseFuzhou* pCounter);	// 十三幺

	//福州麻将                                                                         
	static void		Check031(CMJFanBaseFuzhou* pCounter);	// // 闲金//泉州麻将是游金
	static void		Check032(CMJFanBaseFuzhou* pCounter);	// 无花无杠
	static void		Check033(CMJFanBaseFuzhou* pCounter);	// 一张花 
	//static void		Check035(CMJFanBaseFuzhou* pCounter);	// 三金倒 
	static void		Check034(CMJFanBaseFuzhou* pCounter);	// 金雀 
	static void		Check035(CMJFanBaseFuzhou* pCounter);	// 金龙
	static void		Check036(CMJFanBaseFuzhou* pCounter);	// 半清一色 
	static void		Check037(CMJFanBaseFuzhou* pCounter);	// 全清一色
	static void		Check038(CMJFanBaseFuzhou* pCounter);	// 抢金


};

#endif // !defined(AFX_MJFUNCHENGDU_H__6B6B9972_76DC_4ED5_B98D_407370829DBD__INCLUDED_)

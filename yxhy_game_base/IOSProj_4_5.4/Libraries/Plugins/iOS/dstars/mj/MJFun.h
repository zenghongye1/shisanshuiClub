// MJFun.h: interface for the CMJFun class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_MJFUNCHENGDU_H__6B6B9972_76DC_4ED5_B98D_407370829DBD__INCLUDED_)
#define AFX_MJFUNCHENGDU_H__6B6B9972_76DC_4ED5_B98D_407370829DBD__INCLUDED_


#include "MJFanCounter.h"
#include<vector>

typedef unsigned int uint32_t;
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
class CMJFun : public CMJFanCounter  
{
public:
	CMJFun();
	virtual ~CMJFun();
public:
	
    int InitFanMJCounter(BYTE byStyle, bool bZiMoJiaDi, bool bJiaJiaYou)
    {
        m_byStyle = byStyle;
        m_bZiMoJiaDi = bZiMoJiaDi;
        m_bJiaJiaYou = bJiaJiaYou;
        return 0;
    }
   

	BYTE GetFan();
	BYTE GetFanMuTi();
	BOOL CountTing(FAN_COUNT*& pFanCount);

public:
    virtual	BOOL Count(FAN_COUNT*& pFanCount);
    virtual BOOL GetScore(int nScore[4]);
    virtual void InitForNext();
	virtual	BOOL TingCount(TING_COUNT*& pTingCount);
	virtual	BOOL HuPaiCount(HUPAI_COUNT*& pHuPaiCount);

public:
	//客户端添加方法 begin
	virtual int HuPaiCount();
	virtual HUPAI_COUNT& GetHuPaiCount() { return m_HuPaiCount; }
	//客户端添加方法 end

private:		//CHD, 成都麻将专用 
    BOOL  CHD_SetRecordAndGetScore(int nScore[4]);	//血战模式记分。一次胡的分，而非总分
private:

	BYTE m_byStyle; // 0: --普通模式， 1: --血战模式
	BOOL m_bZiMoJiaDi;			// 自摸加底
	BOOL m_bJiaJiaYou;			// 家家有
	int m_nZiMoJiaDi[4];		//得到加底的数量
	static BOOL m_bNew19Check;			// 新的幺九牌型检查
	static int m_nFourCount;
	static int m_nLaiZiNeed;

private:
	//辅助函数
	static BOOL		CheckIsAllPairs(CTiles tiles);	//检查是否都是对子 
	static BOOL		CheckIsOneColor(CTiles tiles);	//检查是否清一色
	static BOOL		CheckIsTripletsHu(CTiles tilesHand);	// 检查的牌型是否“碰碰胡”牌型
	static BOOL		CheckIs19Hu(CTiles tiles);	// 检查牌型是否幺九胡牌型。
	static BOOL		CheckIsHunColor(CTiles tiles);	//检查是否混一色 
	static BOOL		CheckWin7PairLaiZi(CTiles &tilesHand, int nLaiZiCount);
	static BOOL		CheckIsTripletsHuLaiZi(CTiles& tilesHand, int nlaiziCount);	// 检查的牌型是否“碰碰胡”牌型癞子
	static int      GetColorTypeCout(CTiles tiles);		//获得颜色种数

	//全手牌,癞子数，癞子牌
	static BOOL		CheckWinYouJin(CTiles &tilesHand, int nLaiZiCount, ENVIRONMENT &env, TILE tileHu);

private:
	static void		Check000(CMJFanCounter* pCounter);	// 平胡 
	static void		Check001(CMJFanCounter* pCounter);	// 碰碰胡
	static void		Check002(CMJFanCounter* pCounter);	// 清一色
	static void		Check003(CMJFanCounter* pCounter);	// 带幺九
	static void		Check004(CMJFanCounter* pCounter);	// 七小对
	static void		Check005(CMJFanCounter* pCounter);	// 龙七对
	static void		Check006(CMJFanCounter* pCounter);	// 清对（清大碰）
	static void		Check007(CMJFanCounter* pCounter);	// 清七对
	static void		Check008(CMJFanCounter* pCounter);	// 清幺九
	static void		Check009(CMJFanCounter* pCounter);	// 将对	, 258碰碰胡
	static void		Check010(CMJFanCounter* pCounter);	// 清龙七对 

	static void		Check011(CMJFanCounter* pCounter);	//另加番: 杠
	static void		Check012(CMJFanCounter* pCounter);	//另加番: 根
	static void		Check013(CMJFanCounter* pCounter);	//另加番：杠上花 
	static void		Check014(CMJFanCounter* pCounter);	//另加番：杠上炮  
	static void		Check015(CMJFanCounter* pCounter);	//另加番：抢杠胡 

	static void		Check016(CMJFanCounter* pCounter);	//庄家起手自模，即“天胡”。 
	static void		Check017(CMJFanCounter* pCounter);	//非庄家起手自模，即“地胡”。 
												
	//河北麻将
	static void		Check018(CMJFanCounter* pCounter);	// 自摸 
	static void		Check019(CMJFanCounter* pCounter);	// 点炮
	static void		Check020(CMJFanCounter* pCounter);	// 门清 
	static void		Check021(CMJFanCounter* pCounter);	// 边 
	static void		Check022(CMJFanCounter* pCounter);	// 卡 
	static void		Check023(CMJFanCounter* pCounter);	// 吊 
	static void		Check024(CMJFanCounter* pCounter);	// 庄家 
	static void		Check025(CMJFanCounter* pCounter);	// 一条龙
	static void		Check026(CMJFanCounter* pCounter);	// 海底捞月

	static void		Check027(CMJFanCounter* pCounter);	// 豪华七对 
	static void		Check028(CMJFanCounter* pCounter);	// 清豪华七对 

	static void		Check029(CMJFanCounter* pCounter);	// 超豪华七对
	static void		Check030(CMJFanCounter* pCounter);	// 清超豪华七对
 
	static void		Check031(CMJFanCounter* pCounter);	// 至尊豪华七对
	static void		Check032(CMJFanCounter* pCounter);	// 清至尊豪华七对

	static void		Check033(CMJFanCounter* pCounter);	// 捉五魁
	static void		Check034(CMJFanCounter* pCounter);	// 十三幺  
	static void		Check035(CMJFanCounter* pCounter);	// 清一色一条龙  
	static void		Check036(CMJFanCounter* pCounter);	// 杠上杠 

	//以下为带癞子的胡法，河北廊坊麻将
	static void		Check037(CMJFanCounter* pCounter);	// 素胡
	static void		Check038(CMJFanCounter* pCounter);	// 捉五魁（带癞子）  
	static void		Check039(CMJFanCounter* pCounter);	// 一条龙（带癞子）
	static void		Check040(CMJFanCounter* pCounter);	// 七小对（带癞子） 
	static void		Check041(CMJFanCounter* pCounter);	// 豪华七对（带癞子）
	static void		Check042(CMJFanCounter* pCounter);	// 超级豪华七对（带癞子） 
	static void		Check043(CMJFanCounter* pCounter);	// 至尊豪华七对（带癞子）  
	static void		Check044(CMJFanCounter* pCounter);	// 混钓（带癞子） 
	static void		Check045(CMJFanCounter* pCounter);	// 混钓混（带癞子）
	static void		Check046(CMJFanCounter* pCounter);	// 碰碰胡（带癞子） 
	static void		Check047(CMJFanCounter* pCounter);	// 清一色（带癞子）  
	static void		Check048(CMJFanCounter* pCounter);	// 13幺（带癞子）
	static void		Check049(CMJFanCounter* pCounter);	// 混悠（带癞子）

	//以下为唐山新增
	static void		Check051(CMJFanCounter* pCounter);	// 本混龙（带癞子）
	static void		Check052(CMJFanCounter* pCounter);	// 海底炮（带癞子）
	static void		Check053(CMJFanCounter* pCounter);	// 天听（带癞子）
	static void		Check054(CMJFanCounter* pCounter);	// 地听（带癞子）
	static void		Check055(CMJFanCounter* pCounter);	// 潇洒（带癞子）

	//南阳新增
	static void		Check056(CMJFanCounter* pCounter);	// 卡五星（带癞子）
	static void		Check057(CMJFanCounter* pCounter);	// 四金胡、四混胡

	//许昌濮阳新增
	static void		Check058(CMJFanCounter* pCounter);	// 风摸
	static void		Check059(CMJFanCounter* pCounter);	// 缺一门
	static void		Check060(CMJFanCounter* pCounter);	// 单吊胡
	static void		Check061(CMJFanCounter* pCounter);	// 幺九扑
	static void		Check062(CMJFanCounter* pCounter);	// 暗卡
	static void		Check063(CMJFanCounter* pCounter);	// 十三不靠
	static void		Check064(CMJFanCounter* pCounter);	// 字一色

	//沧州混一色
	static void		Check065(CMJFanCounter* pCounter);	// 混一色
	static void		Check066(CMJFanCounter* pCounter);	// 中发白顺子
	static void		Check067(CMJFanCounter* pCounter);	// 风扑
	static void		Check068(CMJFanCounter* pCounter);	// 将扑
	
// 	static void		Check069(CMJFanCounter* pCounter);	// 清一色七对
// 	static void		Check070(CMJFanCounter* pCounter);	// 清一色豪华七对
// 	static void		Check071(CMJFanCounter* pCounter);	// 清一色一条龙
// 	static void		Check072(CMJFanCounter* pCounter);	// 七星不靠


	static void		Check069(CMJFanCounter* pCounter);	// 牛逼叫

	//卡五星新增
	static void		Check070(CMJFanCounter* pCounter);	// 小三元
	static void		Check071(CMJFanCounter* pCounter);	// 大三元
	static void		Check072(CMJFanCounter* pCounter);	// 明四归 全频道
	static void		Check073(CMJFanCounter* pCounter);	// 暗四归 全频道
	static void		Check074(CMJFanCounter* pCounter);	// 明四归 半频道
	static void		Check075(CMJFanCounter* pCounter);	// 暗四归 半频道

	static void		Check076(CMJFanCounter* pCounter);	// 夹胡
	//捉鸡新增
	static void		Check077(CMJFanCounter* pCounter);	// 双清
	static void		Check078(CMJFanCounter* pCounter);	// 龙七对
	static void		Check079(CMJFanCounter* pCounter);	// 清龙背
};

#endif // !defined(AFX_MJFUNCHENGDU_H__6B6B9972_76DC_4ED5_B98D_407370829DBD__INCLUDED_)

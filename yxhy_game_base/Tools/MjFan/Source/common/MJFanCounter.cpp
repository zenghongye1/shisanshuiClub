// MJFanCounter.cpp: implementation of the CMJFanCounter class.
//
//////////////////////////////////////////////////////////////////////

//#include "StdAfx.h"

#include "environment.h"
#include "MJFanCounter.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////
int CMJFanCounter::m_nWind = 0;
int CMJFanCounter::m_nJiang = 0;
int CMJFanCounter::m_nYaoJiu = 0;
int CMJFanCounter::m_bZFBWind = false;

CMJFanCounter::CMJFanCounter()
{
	memset(&m_FanCount, 0, sizeof(FAN_COUNT));
	memset(&m_TingCount, 0, sizeof(TING_COUNT));
	memset(&m_HuPaiCount, 0, sizeof(HUPAI_COUNT));
	memset(&env, 0, sizeof(env));
	m_nMinWin = 0;
	m_nGameStyle = 0;
	m_nBaseBet = 0;
	m_nWind = 0;
	m_nJiang = 0;
	m_nYaoJiu = 0;
	m_bZFBWind = false;
}

CMJFanCounter::~CMJFanCounter()
{
}

BOOL CMJFanCounter::Count(FAN_COUNT *&pFanCount)
{
	// 返回详细信息
	pFanCount = &m_FanCount;
	return TRUE;
}

// 胡牌入口检查函数 tilesHand为全手牌
BOOL CMJFanCounter::CheckWin(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam)
{
	BOOL bResult = FALSE;
	///注意：如果有哪款麻将的胡牌很特殊不能公用，可以单独出来用checkWinParam.byGameStyle来区分

	///下面是公用的胡牌判断
	//1.检查特殊胡牌
	CTiles TilesTemp;
	TilesTemp.AddTiles(tilesHand);

	CTiles TilesLimitTemp;
	TilesLimitTemp.AddTiles(tilesHand);

	if (CheckWinLimit(TilesLimitTemp, nLaiziCount, laiziCard, checkWinParam))
	{
		return false;
	}
	bResult = CheckWinSpecial(TilesTemp, nLaiziCount, laiziCard, checkWinParam);
	//2.检查正常胡牌
	if (!bResult)
	{	
		int	nGameStyle = checkWinParam.nGameStyle;
		if (nGameStyle == GAME_STYLE_LONGYAN)
		{
			//龙岩
			bResult = CheckWinNormalLongYan(tilesHand, nLaiziCount, laiziCard, checkWinParam);
		}
		else if (checkWinParam.byWindPu || checkWinParam.byJiangPu || checkWinParam.byYaoJiuPu)
		{
			//风扑 将扑 幺九扑 如：濮阳麻将
			bResult = CheckWinNormalWJYJPu(tilesHand, nLaiziCount, laiziCard, checkWinParam);
		}
		else if (checkWinParam.by258Jiang)
		{
			//258将
			bResult = CheckWinNormal258Jiang(tilesHand, nLaiziCount, laiziCard, checkWinParam);
		}
		else if (checkWinParam.byBKDHu)
		{
			//边卡吊胡
			bResult = CheckWinNormalBKD(tilesHand, nLaiziCount, laiziCard, checkWinParam);
		}
		else
		{
			bResult = CheckWinPublic(tilesHand, nLaiziCount, laiziCard, checkWinParam);
		}
	}

	return bResult;
}

//无将牌检查 
BOOL CMJFanCounter::CheckWinNoJiang(CTiles &tilesHand, int nCardLength)
{
	if (tilesHand.nCurrentLength < 0 
		|| tilesHand.nCurrentLength > nCardLength 
		|| tilesHand.nCurrentLength % 3 != 0)
	{
		return FALSE;
	}

	if (tilesHand.nCurrentLength == 0)
	{
		return TRUE;
	}

	tilesHand.Sort();
	int i;
	CTiles TilesTemp;
	// 检查顺子
	for (i = 0; i < tilesHand.nCurrentLength - 2; i++)
	{

		if (tilesHand.tile[i] > TILE_BALL_9)
		{
			// 到箭牌了
			break;
		}
		if (tilesHand.IsHave(tilesHand.tile[i] + 1) && tilesHand.IsHave(tilesHand.tile[i] + 2))
		{
			TilesTemp.ReleaseAll();
			TilesTemp.AddTiles(tilesHand);

			TilesTemp.DelTile(tilesHand.tile[i]);
			TilesTemp.DelTile(tilesHand.tile[i] + 1);
			TilesTemp.DelTile(tilesHand.tile[i] + 2);
			if (CheckWinNoJiang(TilesTemp, nCardLength))
			{
				return TRUE;
			}
		}
	}

	// 检查刻子
	CTiles TilesTriplet;
	for (i = 0; i < tilesHand.nCurrentLength - 2; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
		{
			// 和上一张相同，不用检查了
			continue;
		}

		TilesTriplet.ReleaseAll();
		TilesTriplet.AddTile(tilesHand.tile[i]);
		TilesTriplet.AddTile(tilesHand.tile[i]);
		TilesTriplet.AddTile(tilesHand.tile[i]);
		if (TilesTriplet.IsSubSet(tilesHand))
		{
			TilesTemp.ReleaseAll();
			TilesTemp.AddTiles(tilesHand);
			TilesTemp.DelTiles(TilesTriplet);
			if (CheckWinNoJiang(TilesTemp, nCardLength))
			{
				return TRUE;
			}
		}
	}

	return FALSE;
}

//无将牌检查 tilesHand为无癞子的手牌
BOOL CMJFanCounter::CheckWinNoJiangLaizi(CTiles &tilesHand, CTiles &laiziCard, int nLaiZiCount, int nCardLength, CHECKWIN_PARAM &checkWinParam)
{
	int AllLength = tilesHand.nCurrentLength + nLaiZiCount;
	int nTempLength = nCardLength;

	if (AllLength < 0 || AllLength > nCardLength || AllLength % 3 != 0)
	{
		return FALSE;
	}

	if (AllLength == 0)
	{
		return TRUE;
	}

	tilesHand.Sort();
	int i;
	CTiles TilesTemp;
	int nLaiziLastCount = 0;
	TILE laizi = laiziCard.tile[0];

	// 检查顺子
	for (i = 0; i < tilesHand.nCurrentLength; i++)
	{
		TilesTemp.ReleaseAll();
		TilesTemp.AddTiles(tilesHand);
		//开封中发白算顺子 注意：开封混牌不可做中发白顺子中的任意牌，如果混牌本身是“中”“发”“白”则可用
		// if (tilesHand.tile[i] >= TILE_ZHONG &&
		// 	(nGameStyle == GAME_STYLE_TANGSHAN
		// 		|| nGameStyle == GAME_STYLE_KAIFENG
		// 		|| (nGameStyle == GAME_STYLE_CANGZHOU && m_bZFBWind)))
		if (tilesHand.tile[i] >= TILE_ZHONG && checkWinParam.byShunZFB)
		{
			//正常情况
			if (tilesHand.IsHave(tilesHand.tile[i] + 1) && tilesHand.IsHave(tilesHand.tile[i] + 2))
			{
				TilesTemp.DelTile(tilesHand.tile[i]);
				TilesTemp.DelTile(tilesHand.tile[i] + 1);
				TilesTemp.DelTile(tilesHand.tile[i] + 2);
				nLaiziLastCount = nLaiZiCount;
				if (CheckWinNoJiangLaizi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
				{
					return TRUE;
				}
			}
			//只有后面一个
			else if (tilesHand.IsHave(tilesHand.tile[i] + 1) && nLaiZiCount >= 1)
			{	
				// if (nGameStyle == GAME_STYLE_KAIFENG)
				// {
				// 	continue;
				// }
				if (1 == checkWinParam.byShunZFB)
				{//癞子做普通牌
					if (laizi == TilesTemp.tile[i] + 2 ||(laizi == TilesTemp.tile[i] -1 && laizi == TILE_ZHONG))
					{
					}
					else
					{
						continue;
					}
				}
				TilesTemp.DelTile(tilesHand.tile[i]);
				TilesTemp.DelTile(tilesHand.tile[i] + 1);
				nLaiziLastCount = nLaiZiCount - 1;
				if (CheckWinNoJiangLaizi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
				{
					return TRUE;
				}
			}
			//只有最后面一个，判断是不是9
			else if (tilesHand.IsHave(tilesHand.tile[i] + 2) && nLaiZiCount >= 1 && ((tilesHand.tile[i] % 10) != 9))
			{
				// if (nGameStyle == GAME_STYLE_KAIFENG)
				// {
				// 	continue;
				// }
				if (1 == checkWinParam.byShunZFB)
				{//癞子做普通牌
					if (laizi == TilesTemp.tile[i] + 1)
					{
					}
					else
					{
						continue;
					}
				}
				TilesTemp.DelTile(tilesHand.tile[i]);
				TilesTemp.DelTile(tilesHand.tile[i] + 2);
				nLaiziLastCount = nLaiZiCount - 1;
				if (CheckWinNoJiangLaizi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
				{
					return TRUE;
				}
			}
			//2个以上癞子
			else if (nLaiZiCount >= 2)
			{
				// if (nGameStyle == GAME_STYLE_KAIFENG)
				// {
				// 	continue;
				// }
				if (1 == checkWinParam.byShunZFB)
				{
					continue;
				}
				TilesTemp.DelTile(tilesHand.tile[i]);
				nLaiziLastCount = nLaiZiCount - 2;
				if (CheckWinNoJiangLaizi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
				{
					return TRUE;
				}
			}
		}
		else
		{
			if (tilesHand.tile[i] > TILE_BALL_9)
			{
				// 到箭牌了
				break;
			}
			//正常情况
			if (tilesHand.IsHave(tilesHand.tile[i] + 1) && tilesHand.IsHave(tilesHand.tile[i] + 2))
			{
				TilesTemp.DelTile(tilesHand.tile[i]);
				TilesTemp.DelTile(tilesHand.tile[i] + 1);
				TilesTemp.DelTile(tilesHand.tile[i] + 2);
				nLaiziLastCount = nLaiZiCount;
				if (CheckWinNoJiangLaizi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
				{
					return TRUE;
				}
			}
			//只有后面一个
			else if (tilesHand.IsHave(tilesHand.tile[i] + 1) && nLaiZiCount >= 1)
			{
				TilesTemp.DelTile(tilesHand.tile[i]);
				TilesTemp.DelTile(tilesHand.tile[i] + 1);
				nLaiziLastCount = nLaiZiCount - 1;
				if (CheckWinNoJiangLaizi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
				{
					return TRUE;
				}
			}
			//只有最后面一个，判断是不是9
			else if (tilesHand.IsHave(tilesHand.tile[i] + 2) && nLaiZiCount >= 1 && ((tilesHand.tile[i] % 10) != 9))
			{
				TilesTemp.DelTile(tilesHand.tile[i]);
				TilesTemp.DelTile(tilesHand.tile[i] + 2);
				nLaiziLastCount = nLaiZiCount - 1;
				if (CheckWinNoJiangLaizi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
				{
					return TRUE;
				}
			}
			//2个以上癞子
			else if (nLaiZiCount >= 2)
			{
				TilesTemp.DelTile(tilesHand.tile[i]);
				nLaiziLastCount = nLaiZiCount - 2;
				if (CheckWinNoJiangLaizi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
				{
					return TRUE;
				}
			}
		}
	}

	// 检查刻子
	CTiles TilesTriplet;
	CTiles TilesTripletOne;
	CTiles TilesTripletTwo;
	for (i = 0; i < tilesHand.nCurrentLength; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
		{
			// 和上一张相同，不用检查了
			continue;
		}
		TilesTriplet.ReleaseAll();
		TilesTripletTwo.ReleaseAll();
		TilesTripletTwo.AddTile(tilesHand.tile[i]);
		TilesTripletTwo.AddTile(tilesHand.tile[i]);
		TilesTriplet.AddTile(tilesHand.tile[i]);
		TilesTriplet.AddTile(tilesHand.tile[i]);
		TilesTriplet.AddTile(tilesHand.tile[i]);
		TilesTemp.ReleaseAll();
		TilesTemp.AddTiles(tilesHand);
		//正常情况
		if (TilesTriplet.IsSubSet(tilesHand))
		{
			TilesTemp.DelTiles(TilesTriplet);
			nLaiziLastCount = nLaiZiCount;
			if (CheckWinNoJiangLaizi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
			{
				return TRUE;
			}
		}
		//2个
		else if (TilesTripletTwo.IsSubSet(tilesHand) && nLaiZiCount >= 1)
		{
			TilesTemp.DelTiles(TilesTripletTwo);
			nLaiziLastCount = nLaiZiCount - 1;
			if (CheckWinNoJiangLaizi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
			{
				return TRUE;
			}
		}
		else if (nLaiZiCount >= 2)
		{
			TilesTemp.DelTile(tilesHand.tile[i]);
			nLaiziLastCount = nLaiZiCount - 2;
			if (CheckWinNoJiangLaizi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
			{
				return TRUE;
			}
		}
	}

	return FALSE;
}

// 胡牌检查函数不带癞子 tilesHand全手牌
BOOL CMJFanCounter::CheckWinNormal(CTiles &tilesHand, int nCardLength)
{
	if (tilesHand.nCurrentLength < 2 
		|| tilesHand.nCurrentLength > nCardLength 
		|| tilesHand.nCurrentLength % 3 != 2)
	{
		return FALSE;
	}

	if (tilesHand.nCurrentLength == 2)
	{
		return (tilesHand.tile[0] == tilesHand.tile[1]);
	}

	tilesHand.Sort();
	int i;
	CTiles TilesTemp;
	// 检查顺子
	for (i = 0; i < tilesHand.nCurrentLength - 2; i++)
	{

		if (tilesHand.tile[i] > TILE_BALL_9)
		{
			// 到箭牌了
			break;
		}
		if (tilesHand.IsHave(tilesHand.tile[i] + 1) && tilesHand.IsHave(tilesHand.tile[i] + 2))
		{
			TilesTemp.ReleaseAll();
			TilesTemp.AddTiles(tilesHand);

			TilesTemp.DelTile(tilesHand.tile[i]);
			TilesTemp.DelTile(tilesHand.tile[i] + 1);
			TilesTemp.DelTile(tilesHand.tile[i] + 2);
			if (CheckWinNormal(TilesTemp, nCardLength))
			{
				return TRUE;
			}
		}
	}

	// 检查刻子
	CTiles TilesTriplet;
	for (i = 0; i < tilesHand.nCurrentLength - 2; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
		{
			// 和上一张相同，不用检查了
			continue;
		}

		TilesTriplet.ReleaseAll();
		TilesTriplet.AddTile(tilesHand.tile[i]);
		TilesTriplet.AddTile(tilesHand.tile[i]);
		TilesTriplet.AddTile(tilesHand.tile[i]);
		if (TilesTriplet.IsSubSet(tilesHand))
		{
			TilesTemp.ReleaseAll();
			TilesTemp.AddTiles(tilesHand);
			TilesTemp.DelTiles(TilesTriplet);
			if (CheckWinNormal(TilesTemp, nCardLength))
			{
				return TRUE;
			}
		}
	}

	return FALSE;
}

// 胡牌检查函数带癞子 tilesHand为无癞子的手牌
BOOL CMJFanCounter::CheckWinNormalLaiZi(CTiles &tilesHand, CTiles &laiziCard, int nLaiZiCount, int nCardLength, CHECKWIN_PARAM &checkWinParam)
{
	int AllLength = tilesHand.nCurrentLength + nLaiZiCount;
	int nTempLength = nCardLength;

	if (AllLength < 2 || AllLength > nTempLength || AllLength % 3 != 2)
	{
		return FALSE;
	}
	if (AllLength == 2)
	{
		// 正常情况
		if (tilesHand.tile[0] == tilesHand.tile[1])
		{
			return TRUE;
		}
		// 还有至少一个癞子，肯定可以胡
		else if (nLaiZiCount >= 1)
		{
			return TRUE;
		}
		else
		{
			return FALSE;
		}
	}
	if (tilesHand.nCurrentLength == 0 && nLaiZiCount > 0)
	{
		return TRUE;
	}
	tilesHand.Sort();
	int i;
	CTiles TilesTemp;
	int nLaiziLastCount = 0;
	TILE laizi = laiziCard.tile[0];

	// 检查顺子
	for (i = 0; i < tilesHand.nCurrentLength; i++)
	{
		TilesTemp.ReleaseAll();
		TilesTemp.AddTiles(tilesHand);
		//开封中发白也算顺子
		// if ((nGameStyle == GAME_STYLE_TANGSHAN || nGameStyle == GAME_STYLE_KAIFENG || nGameStyle == GAME_STYLE_CHENGDE 
		// 	|| (nGameStyle == GAME_STYLE_CANGZHOU && m_bZFBWind))
		//  && tilesHand.tile[i] >= TILE_ZHONG)
		if (tilesHand.tile[i] >= TILE_ZHONG && checkWinParam.byShunZFB)
		{
			//正常情况
			if (tilesHand.IsHave(tilesHand.tile[i] + 1) && tilesHand.IsHave(tilesHand.tile[i] + 2))
			{
				TilesTemp.DelTile(tilesHand.tile[i]);
				TilesTemp.DelTile(tilesHand.tile[i] + 1);
				TilesTemp.DelTile(tilesHand.tile[i] + 2);
				nLaiziLastCount = nLaiZiCount;
				if (CheckWinNormalLaiZi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
				{
					return TRUE;
				}
			}
			//只有后面一个
			else if (nLaiZiCount >= 1 && tilesHand.IsHave(tilesHand.tile[i] + 1))
			{
				// if (nGameStyle == GAME_STYLE_KAIFENG)
				// {
				// 	if (laizi == tilesHand.tile[i] + 2 ||(laizi == tilesHand.tile[i] -1 && laizi == TILE_ZHONG))
				// 	{
				// 	}
				// 	else
				// 	{
				// 		continue;
				// 	}					
				// }
				if (1 == checkWinParam.byShunZFB)
				{//癞子做普通牌
					if (laizi == tilesHand.tile[i] + 2 ||(laizi == tilesHand.tile[i] -1 && laizi == TILE_ZHONG))
					{
					}
					else
					{
						continue;
					}					
				}
				TilesTemp.DelTile(tilesHand.tile[i]);
				TilesTemp.DelTile(tilesHand.tile[i] + 1);
				nLaiziLastCount = nLaiZiCount - 1;
				if (CheckWinNormalLaiZi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
				{
					return TRUE;
				}
			}
			//只有最后面一个，判断是不是9
			else if (tilesHand.IsHave(tilesHand.tile[i] + 2) && nLaiZiCount >= 1 && ((tilesHand.tile[i] % 10) != 9))
			{
				// if (nGameStyle == GAME_STYLE_KAIFENG)
				// {
				// 	if (laizi == tilesHand.tile[i] + 1)
				// 	{
				// 	}
				// 	else
				// 	{
				// 		continue;
				// 	}
				// }
				if (1 == checkWinParam.byShunZFB)
				{//癞子做普通牌
					if (laizi == tilesHand.tile[i] + 1)
					{
					}
					else
					{
						continue;
					}
				}
				TilesTemp.DelTile(tilesHand.tile[i]);
				TilesTemp.DelTile(tilesHand.tile[i] + 2);
				nLaiziLastCount = nLaiZiCount - 1;

				if (CheckWinNormalLaiZi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
				{
					return TRUE;
				}
			}
			//2个以上癞子
			else if (nLaiZiCount >= 2)
			{
				// if (nGameStyle == GAME_STYLE_KAIFENG)
				// {
				// 	continue;
				// }
				if (1 == checkWinParam.byShunZFB)
				{//癞子做普通牌
					continue;
				}
				TilesTemp.DelTile(tilesHand.tile[i]);
				nLaiziLastCount = nLaiZiCount - 2;
				if (CheckWinNormalLaiZi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
				{
					return TRUE;
				}
			}
		}
		//东南西北任意3张组成的顺子 (癞子不可替换)--目前许昌麻将有用到
		// else if ((nGameStyle == GAME_STYLE_XUCHANG) && tilesHand.tile[i] >= TILE_EAST)
		else if (tilesHand.tile[i] >= TILE_EAST && 1 == checkWinParam.byShunWind)
		{
			if (tilesHand.tile[i] >= TILE_EAST && tilesHand.tile[i] <= TILE_NORTH)
			{
				if (tilesHand.tile[i] == TILE_EAST)
				{	
					//东南西
					if (tilesHand.IsHave(tilesHand.tile[i] + 1) && tilesHand.IsHave(tilesHand.tile[i] + 2))
					{
						TilesTemp.DelTile(tilesHand.tile[i]);
						TilesTemp.DelTile(tilesHand.tile[i] + 1);
						TilesTemp.DelTile(tilesHand.tile[i] + 2);
						nLaiziLastCount = nLaiZiCount;
						if (laizi == tilesHand.tile[i] || laizi == tilesHand.tile[i] + 1 || laizi == tilesHand.tile[i] + 2)
						{
							nLaiziLastCount = nLaiziLastCount - 1;
						}
						if (CheckWinNormalLaiZi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
						{
							return TRUE;
						}
					}
					//东南北
					else if (tilesHand.IsHave(tilesHand.tile[i] + 1) && tilesHand.IsHave(tilesHand.tile[i] + 3))
					{
						TilesTemp.DelTile(tilesHand.tile[i]);
						TilesTemp.DelTile(tilesHand.tile[i] + 1);
						TilesTemp.DelTile(tilesHand.tile[i] + 3);
						nLaiziLastCount = nLaiZiCount;
						if (laizi == tilesHand.tile[i] || laizi == tilesHand.tile[i] + 1 || laizi == tilesHand.tile[i] + 3)
						{
							nLaiziLastCount = nLaiziLastCount - 1;
						}
						if (CheckWinNormalLaiZi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
						{
							return TRUE;
						}
					}
					//东西北
					else if (tilesHand.IsHave(tilesHand.tile[i] + 2) && tilesHand.IsHave(tilesHand.tile[i] + 3))
					{
						TilesTemp.DelTile(tilesHand.tile[i]);
						TilesTemp.DelTile(tilesHand.tile[i] + 2);
						TilesTemp.DelTile(tilesHand.tile[i] + 3);
						nLaiziLastCount = nLaiZiCount;
						if (laizi == tilesHand.tile[i] || laizi == tilesHand.tile[i] + 2 || laizi == tilesHand.tile[i] + 3)
						{
							nLaiziLastCount = nLaiziLastCount - 1;
						}
						if (CheckWinNormalLaiZi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
						{
							return TRUE;
						}
					}
				}
				else if (tilesHand.tile[i] == TILE_SOUTH)
				{	
					//南西北
					if (tilesHand.IsHave(tilesHand.tile[i] + 1) && tilesHand.IsHave(tilesHand.tile[i] + 2))
					{
						TilesTemp.DelTile(tilesHand.tile[i]);
						TilesTemp.DelTile(tilesHand.tile[i] + 1);
						TilesTemp.DelTile(tilesHand.tile[i] + 2);
						nLaiziLastCount = nLaiZiCount;
						if (laizi == tilesHand.tile[i] || laizi == tilesHand.tile[i] + 1 || laizi == tilesHand.tile[i] + 2)
						{
							nLaiziLastCount = nLaiziLastCount - 1;
						}
						if (CheckWinNormalLaiZi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
						{
							return TRUE;
						}
					}
				}
			}
			else if (tilesHand.tile[i] >= TILE_ZHONG)
			{
				if (tilesHand.IsHave(tilesHand.tile[i] + 1) && tilesHand.IsHave(tilesHand.tile[i] + 2))
				{
					TilesTemp.DelTile(tilesHand.tile[i]);
					TilesTemp.DelTile(tilesHand.tile[i] + 1);
					TilesTemp.DelTile(tilesHand.tile[i] + 2);
					nLaiziLastCount = nLaiZiCount;
					if (laizi == tilesHand.tile[i] || laizi == tilesHand.tile[i] + 1 || laizi == tilesHand.tile[i] + 2)
					{
						nLaiziLastCount = nLaiziLastCount - 1;
					}
					if (CheckWinNormalLaiZi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
					{
						return TRUE;
					}
				}
			}
		}
		else if (tilesHand.tile[i] <= TILE_BALL_9)
		{
			//正常情况
			if (tilesHand.IsHave(tilesHand.tile[i] + 1) && tilesHand.IsHave(tilesHand.tile[i] + 2))
			{
				TilesTemp.DelTile(tilesHand.tile[i]);
				TilesTemp.DelTile(tilesHand.tile[i] + 1);
				TilesTemp.DelTile(tilesHand.tile[i] + 2);
				nLaiziLastCount = nLaiZiCount;
				if (CheckWinNormalLaiZi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
				{
					return TRUE;
				}
			}
			//只有后面一个
			else if (tilesHand.IsHave(tilesHand.tile[i] + 1) && nLaiZiCount >= 1)
			{
				TilesTemp.DelTile(tilesHand.tile[i]);
				TilesTemp.DelTile(tilesHand.tile[i] + 1);
				nLaiziLastCount = nLaiZiCount - 1;
				if (CheckWinNormalLaiZi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
				{
					return TRUE;
				}
			}
			//只有最后面一个，判断是不是9
			else if (tilesHand.IsHave(tilesHand.tile[i] + 2) && nLaiZiCount >= 1 && ((tilesHand.tile[i] % 10) != 9))
			{
				TilesTemp.DelTile(tilesHand.tile[i]);
				TilesTemp.DelTile(tilesHand.tile[i] + 2);
				nLaiziLastCount = nLaiZiCount - 1;
				if (CheckWinNormalLaiZi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
				{
					return TRUE;
				}
			}
			//2个以上癞子
			else if (nLaiZiCount >= 2)
			{
				TilesTemp.DelTile(tilesHand.tile[i]);
				nLaiziLastCount = nLaiZiCount - 2;
				if (CheckWinNormalLaiZi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
				{
					return TRUE;
				}
			}
		}
	}

	// 检查刻子
	CTiles TilesTriplet;
	CTiles TilesTripletOne;
	CTiles TilesTripletTwo;
	for (i = 0; i < tilesHand.nCurrentLength; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
		{
			// 和上一张相同，不用检查了
			continue;
		}
		TilesTriplet.ReleaseAll();
		TilesTripletTwo.ReleaseAll();
		TilesTripletTwo.AddTile(tilesHand.tile[i]);
		TilesTripletTwo.AddTile(tilesHand.tile[i]);
		TilesTriplet.AddTile(tilesHand.tile[i]);
		TilesTriplet.AddTile(tilesHand.tile[i]);
		TilesTriplet.AddTile(tilesHand.tile[i]);
		TilesTemp.ReleaseAll();
		TilesTemp.AddTiles(tilesHand);
		//正常情况
		if (TilesTriplet.IsSubSet(tilesHand))
		{
			TilesTemp.DelTiles(TilesTriplet);
			nLaiziLastCount = nLaiZiCount;
			if (CheckWinNormalLaiZi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
			{
				return TRUE;
			}
		}
		//2个
		else if (TilesTripletTwo.IsSubSet(tilesHand) && nLaiZiCount >= 1)
		{
			TilesTemp.DelTiles(TilesTripletTwo);
			nLaiziLastCount = nLaiZiCount - 1;
			if (CheckWinNormalLaiZi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
			{
				return TRUE;
			}
		}
		else if (nLaiZiCount >= 2)
		{
			TilesTemp.DelTile(tilesHand.tile[i]);
			nLaiziLastCount = nLaiZiCount - 2;
			if (CheckWinNormalLaiZi(TilesTemp, laiziCard, nLaiziLastCount, nTempLength, checkWinParam))
			{
				return TRUE;
			}
		}
	}

	return FALSE;
}


//十三幺检查函数  全手牌（不支持癞子算法）
BOOL CMJFanCounter::CheckWinShiSanYao(CTiles &tilesHand) // 十三幺
{
	CTiles tilesTemp;
	tilesTemp.ReleaseAll();
	tilesTemp.AddTiles(tilesHand);
	if (tilesHand.nCurrentLength != 14)
	{
		return FALSE;
	}
	CTiles tilesAll;
	tilesAll.AddTile(TILE_CHAR_1);
	tilesAll.AddTile(TILE_CHAR_9);
	tilesAll.AddTile(TILE_BAMBOO_1);
	tilesAll.AddTile(TILE_BAMBOO_9);
	tilesAll.AddTile(TILE_BALL_1);
	tilesAll.AddTile(TILE_BALL_9);
	tilesAll.AddTile(TILE_EAST);
	tilesAll.AddTile(TILE_SOUTH);
	tilesAll.AddTile(TILE_WEST);
	tilesAll.AddTile(TILE_NORTH);
	tilesAll.AddTile(TILE_ZHONG);
	tilesAll.AddTile(TILE_FA);
	tilesAll.AddTile(TILE_BAI);

	if (!tilesAll.IsSubSet(tilesTemp))
	{
		return FALSE;
	}

	tilesTemp.DelTiles(tilesAll);
	if (!tilesTemp.IsSubSet(tilesAll))
	{
		return FALSE;
	}
	return TRUE;
}
//十三幺检查函数  无癞子手牌（支持癞子算法）
BOOL CMJFanCounter::CheckWinShiSanYaoLaizi(CTiles &tiles, int nLaiZiCount) // 带癞子的十三幺
{
	int i;
	int have_num = 0;		 // 记录已有的牌张数
	bool have_jiang = false; // 记录是对将牌(中发白)

	// 遍历所有手牌
	CTiles tilesHand;
	tilesHand.ReleaseAll();
	tilesHand.AddTiles(tiles);
	tilesHand.Sort();
	for (i = 0; i < tilesHand.nCurrentLength; i++)
	{
		TILE tmp = tilesHand.tile[i];

		if (tilesHand.IsHaveNum(tmp, 3))
		{
			// 有3张或4张相同的牌返回
			return false;
		}

		if (tilesHand.IsHaveNum(tmp, 2))
		{
			// 检测二张相同的
			if (tmp == TILE_BAI || tmp == TILE_ZHONG || tmp == TILE_FA || tmp == TILE_CHAR_1 || tmp == TILE_CHAR_9 || tmp == TILE_BAMBOO_1 || tmp == TILE_BAMBOO_9 || tmp == TILE_BALL_1 || tmp == TILE_BALL_9 || tmp == TILE_EAST || tmp == TILE_SOUTH || tmp == TILE_WEST || tmp == TILE_NORTH)
			{
				// 标志有将牌
				have_jiang = true;
			}
			else
			{
				return false;
			}
		}
	}

	if (!have_jiang)
	{
		// 没有对将牌，则用赖子添加为将作为一对将牌。
		if (tilesHand.IsHave(TILE_BAI) || tilesHand.IsHave(TILE_ZHONG) || tilesHand.IsHave(TILE_FA) || tilesHand.IsHave(TILE_CHAR_1) || tilesHand.IsHave(TILE_CHAR_9) || tilesHand.IsHave(TILE_BAMBOO_1) || tilesHand.IsHave(TILE_BAMBOO_9) || tilesHand.IsHave(TILE_BALL_1) || tilesHand.IsHave(TILE_BALL_9) || tilesHand.IsHave(TILE_EAST) || tilesHand.IsHave(TILE_SOUTH) || tilesHand.IsHave(TILE_WEST) || tilesHand.IsHave(TILE_NORTH))
		{
			if (nLaiZiCount > 0)
			{
				if (tilesHand.IsHave(TILE_BAI))
				{
					tilesHand.AddTile(TILE_BAI);
				}
				else if (tilesHand.IsHave(TILE_ZHONG))
				{
					tilesHand.AddTile(TILE_ZHONG);
				}
				else if (tilesHand.IsHave(TILE_FA))
				{
					tilesHand.AddTile(TILE_FA);
				}
				else if (tilesHand.IsHave(TILE_CHAR_1))
				{
					tilesHand.AddTile(TILE_CHAR_1);
				}
				else if (tilesHand.IsHave(TILE_CHAR_9))
				{
					tilesHand.AddTile(TILE_CHAR_9);
				}
				else if (tilesHand.IsHave(TILE_BAMBOO_1))
				{
					tilesHand.AddTile(TILE_BAMBOO_1);
				}
				else if (tilesHand.IsHave(TILE_BAMBOO_9))
				{
					tilesHand.AddTile(TILE_BAMBOO_9);
				}
				else if (tilesHand.IsHave(TILE_BALL_1))
				{
					tilesHand.AddTile(TILE_BALL_1);
				}
				else if (tilesHand.IsHave(TILE_BALL_9))
				{
					tilesHand.AddTile(TILE_BALL_9);
				}
				else if (tilesHand.IsHave(TILE_EAST))
				{
					tilesHand.AddTile(TILE_EAST);
				}
				else if (tilesHand.IsHave(TILE_SOUTH))
				{
					tilesHand.AddTile(TILE_SOUTH);
				}
				else if (tilesHand.IsHave(TILE_WEST))
				{
					tilesHand.AddTile(TILE_WEST);
				}
				else if (tilesHand.IsHave(TILE_NORTH))
				{
					tilesHand.AddTile(TILE_NORTH);
				}
				nLaiZiCount--;
				have_jiang = true;
			}
			else
			{
				// 没有赖子替换牌（则没一对将牌）, 返回
				return false;
			}
		}
		else
		{
			// 都不存在则返回
			return false;
		}
	}

	if (!have_jiang)
	{
		// 没有对将牌，返回
		return false;
	}

	/////注意不管这张牌有几张，如果存在只算一张
	// 判断手牌 1万、9万、1条、9条、1筒、9筒 是否存在  
	for (i = 0; i < 3; i++)
	{
		if (tilesHand.IsHave(i * 10 + 1))
		{
			have_num++;
		}

		if (tilesHand.IsHave(i * 10 + 9))
		{
			have_num++;
		}
	}
	// 判断手牌东南西北中发白 是否存在
	for (i = 0; i < 7; i++)
	{
		if (tilesHand.IsHave(TILE_EAST + i))
		{
			have_num++;
		}
	}

	// 判断是否符合十三幺的张数
	if (have_num + nLaiZiCount == 13)
	{
		return true;
	}
	else
	{
		return false;
	}
}
//十三幺检查函数  无癞子手牌（支持癞子算法）
//白板可替换成癞子那张牌使用 --龙岩麻将：白板当金
BOOL CMJFanCounter::CheckWinShiSanYaoLaiziLongYan(CTiles &tilesHand, CTiles &laiziCard, int nLaiZiCount)
{
	if ((tilesHand.nCurrentLength + nLaiZiCount) != 14)
	{
		return FALSE;
	}

	int cardNum[38] = { 0 };
	for (int i = 0; i < tilesHand.nCurrentLength; i++)
	{
		int card = tilesHand.tile[i];
		if (card >= TILE_CHAR_1 && card <= TILE_BAI)
		{
			if (card % 10 == 1 || card % 10 == 9 || (card >= TILE_EAST && card <= TILE_BAI))
			{
				cardNum[card] = cardNum[card] + 1;
			}
			else
			{
				return FALSE;
			}
		}
		else
		{
			return FALSE;
		}
	}

	int nCount = 0;
	int nBaiCount = 0;
	for (int i = 0; i < 38; i++)
	{
		if (i == TILE_BAI)
		{
			nBaiCount = cardNum[i];
		}
		else
		{
			if (cardNum[i] == 2)
			{
				nCount++;
			}
			else if (cardNum[i] == 3 || cardNum[i] == 4)
			{
				return FALSE;
			}
		}
	}
	//除白板外有2个以上对子 不符合十三幺牌形
	if (nCount > 1)
	{
		return FALSE;
	}

	//白板替换金牌
	for (int i = 0; i < laiziCard.nCurrentLength; i++)
	{
		if (nBaiCount > 0)
		{
			int card = laiziCard.tile[i];
			if (card % 10 == 1 || card % 10 == 9 || (card >= TILE_EAST && card <= TILE_BAI))
			{
				nBaiCount--;
			}
		}
		else if (nBaiCount == 0)
		{
			break;
		}
	}
	//白板替换金牌后 有2个对子 不是十三幺
	if ((nCount == 1 && nBaiCount >= 2) || (nCount == 0 && nBaiCount > 2))
	{
		return false;
	}

	return TRUE;
}
//十三不靠检查函数  全手牌
BOOL CMJFanCounter::CheckWinShiSanBuKao(CTiles &tilesHand) // 十三不靠
{
	BOOL bResult = FALSE;
	BOOL bXuFlag = FALSE;
	if (tilesHand.nCurrentLength != 14)
	{
		return bResult;
	}

	CTiles tilesTmps;
	CTiles handsTmps;
	handsTmps.ReleaseAll();
	handsTmps.AddTiles(tilesHand);
	int hand[6][3] = {{0, 1, 2}, {0, 2, 1}, {1, 0, 2}, {1, 2, 0}, {2, 0, 1}, {2, 1, 0}};
	for (int i = 0; i < 6; i++)
	{
		tilesTmps.ReleaseAll();
		for (int j = 0; j < 3; j++)
		{
			for (int m = 1 + j; m <= 9; m = m + 3)
			{
				int n = hand[i][j];
				int card = 10 * n + m;
				tilesTmps.AddTile(card);
			}
		}
		// 检查序牌
		if (tilesTmps.IsSubSet(handsTmps))
		{
			handsTmps.DelTiles(tilesTmps);
			bXuFlag = TRUE;
			break;
		}
	}

	if (bXuFlag == TRUE) // 检查字牌
	{
		CTiles tmp;
		tmp.ReleaseAll();
		for (int card = TILE_EAST; card <= TILE_BAI; card++)
		{
			tmp.AddTile(card);
		}
		if (handsTmps.IsSubSet(tmp))
		{
			bResult = TRUE;
		}
	}

	return bResult;
}
BOOL CMJFanCounter::CheckWinQiXingBuKao(CTiles &tilesHand)
// 七星不靠
{
	BOOL bResult = FALSE;
	if (tilesHand.nCurrentLength != 14)
	{
		return bResult;
	}

	CTiles handsTmps;
	handsTmps.ReleaseAll();
	handsTmps.AddTiles(tilesHand);

	CTiles tilesZi;
	tilesZi.ReleaseAll();
	for (int card = TILE_EAST; card <= TILE_BAI; card++)
	{
		tilesZi.AddTile(card);
	}
	if (tilesZi.IsSubSet(handsTmps))
	{
		handsTmps.DelTiles(tilesZi);
	}
	else
	{
		return bResult;
	}

	CTiles tilesTmps;
	int hand[6][3] = { { 0, 1, 2 },{ 0, 2, 1 },{ 1, 0, 2 },{ 1, 2, 0 },{ 2, 0, 1 },{ 2, 1, 0 } };
	for (int i = 0; i < 6; i++)
	{
		tilesTmps.ReleaseAll();
		for (int j = 0; j < 3; j++)
		{
			for (int m = 1 + j; m <= 9; m = m + 3)
			{
				int n = hand[i][j];
				int card = 10 * n + m;
				tilesTmps.AddTile(card);
			}
		}
		// 检查序牌
		if (handsTmps.IsSubSet(tilesTmps))
		{
			bResult = TRUE;
			break;
		}
	}

	return bResult;
}

// 七对检查函数不带癞子 tilesHand全手牌
BOOL CMJFanCounter::CheckWinDouble(CTiles &tilesHand)
{
	BOOL bResult = FALSE;
	BOOL bTemp = TRUE;
	tilesHand.Sort();
	if (tilesHand.nCurrentLength == 14)
	{
		for (int i = 0; i < 7; i++)
		{
			if (tilesHand.tile[i * 2] != tilesHand.tile[i * 2 + 1])
			{
				bTemp = FALSE;
				break;
			}
		}
		if (bTemp)
		{
			bResult = TRUE;
		}
	}
	return bResult;
}
// 七对检查函数带癞子 tilesHand为无癞子的手牌
BOOL CMJFanCounter::CheckWinDoubleLaiZi(CTiles &tilesHand, int nLaiZiCount)
{
	BOOL bResult = FALSE;
	if (tilesHand.nCurrentLength + nLaiZiCount != 14)
	{
		return FALSE;
	}

	int arrCard[38] = {0};
	for (int i = 0; i < tilesHand.nCurrentLength; i++)
	{
		int card = tilesHand.tile[i];
		arrCard[card] = arrCard[card] + 1;
	}

	int nCount = 0;
	for (int i = 0; i < 38; i++)
	{
		if (arrCard[i] % 2 == 1)
		{
			nCount++;
		}
	}

	if (nCount <= nLaiZiCount && (nCount + nLaiZiCount) % 2 == 0)
	{
		bResult = TRUE;
	}

	return bResult;

	// BOOL bResult = FALSE;
	// BOOL bTemp = TRUE;
	// tilesHand.Sort();
	// CTiles tilesHandnolaizi;
	// tilesHandnolaizi.AddTiles(tilesHand);
	// int nEqualCardsNum = 0;
	// if (tilesHand.nCurrentLength + nLaiZiCount != 14)
	// {
	// 	return FALSE;
	// }
	// if (nLaiZiCount == 0)
	// {
	// 	if (tilesHand.nCurrentLength == 14)
	// 	{
	// 		for (int i = 0; i < 7; i++)
	// 		{
	// 			if (tilesHand.tile[i * 2] != tilesHand.tile[i * 2 + 1])
	// 			{
	// 				bTemp = FALSE;
	// 				break;
	// 			}
	// 		}
	// 		if (bTemp)
	// 		{
	// 			bResult = TRUE;
	// 		}
	// 	}
	// 	return bResult;
	// }
	// else
	// {
	// 	tilesHandnolaizi.Sort();
	// 	//4个的情况
	// 	CTiles tempFour;
	// 	tempFour.ReleaseAll();
	// 	tempFour.AddTiles(tilesHandnolaizi);
	// 	for (int i = 0; i < tilesHandnolaizi.nCurrentLength - 3; i++)
	// 	{
	// 		if (tilesHandnolaizi.tile[i] == tilesHandnolaizi.tile[i + 1] && tilesHandnolaizi.tile[i] == tilesHandnolaizi.tile[i + 2] && tilesHandnolaizi.tile[i] == tilesHandnolaizi.tile[i + 3])
	// 		{
	// 			nEqualCardsNum = nEqualCardsNum + 2;
	// 			tempFour.DelTile(tilesHandnolaizi.tile[i]);
	// 			tempFour.DelTile(tilesHandnolaizi.tile[i + 1]);
	// 			tempFour.DelTile(tilesHandnolaizi.tile[i + 2]);
	// 			tempFour.DelTile(tilesHandnolaizi.tile[i + 3]);
	// 		}
	// 	}
	// 	//3个的情况
	// 	CTiles tempThree;
	// 	tempThree.ReleaseAll();
	// 	tempThree.AddTiles(tempFour);
	// 	for (int m = 0; m < tempFour.nCurrentLength - 2; m++)
	// 	{
	// 		if (tempFour.tile[m] == tempFour.tile[m + 1] && tempFour.tile[m] == tempFour.tile[m + 2])
	// 		{
	// 			nEqualCardsNum++;
	// 			tempThree.DelTile(tempFour.tile[m]);
	// 			tempThree.DelTile(tempFour.tile[m + 1]);
	// 		}
	// 	}
	// 	//2个的情况
	// 	CTiles tempTwo;
	// 	tempTwo.ReleaseAll();
	// 	tempTwo.AddTiles(tempThree);
	// 	for (int m = 0; m < tempThree.nCurrentLength - 1; m++)
	// 	{
	// 		if (tempThree.tile[m] == tempThree.tile[m + 1])
	// 		{
	// 			nEqualCardsNum++;
	// 			tempTwo.DelTile(tempThree.tile[m]);
	// 			tempTwo.DelTile(tempThree.tile[m + 1]);
	// 		}
	// 	}
	// 	if (nEqualCardsNum + nLaiZiCount == 7)
	// 	{
	// 		return TRUE;
	// 	}
	// 	else
	// 	{
	// 		return FALSE;
	// 	}
	// }
}
//八小对
int CMJFanCounter::CheckWinPair8(CTiles &tilesHand, int nLaiZiCount, int nLength /*= 17*/, bool bLast /*= false*/)  //8小对
{
	if (tilesHand.nCurrentLength + nLaiZiCount != nLength)
	{
		return 0;
	}

	int arrCard[38] = { 0 };
	for (int i = 0; i < tilesHand.nCurrentLength; i++)
	{
		int card = tilesHand.tile[i];
		arrCard[card] = arrCard[card] + 1;
	}

	int nOneCount = 0;
	int nThrCount = 0;
	for (int i = 0; i < 38; i++)
	{
		if (arrCard[i] == 1)
		{
			nOneCount++;
		}
		else if (arrCard[i] == 3)
		{
			nThrCount++;
		}
	}

	if ((nOneCount == 0 && nThrCount == 1 && nLaiZiCount == 0) || (nOneCount == 0 && nThrCount == 0 && nLaiZiCount == 1))
	{
		return 1;  // 普通的8小对
	}

	if ((nThrCount > 0 && nLaiZiCount > 0 && nLaiZiCount >= nOneCount + nThrCount - 1))
	{
		if (nLaiZiCount == 1 && bLast)
		{
			return 1;  // 普通的8小对
		}
		return 2;  // 8小对 + 游金
	}
	else if (nThrCount == 0 && nOneCount > 0 && nLaiZiCount - 1 >= nOneCount)
	{
		return 2;  // 8小对 + 游金
	}

	return 0;
}

///----------------------------------------------------------------------------------------------------------------------

BOOL CMJFanCounter::CheckWinLimit(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam)
{

	//先决条件
	int nKaiMenLimit = checkWinParam.byKaiMenLimit;
	int byColorLimit = checkWinParam.byQYSHu;
	int nQYSHu = checkWinParam.byQYSHu;
	int nYaoJiuLimit = checkWinParam.byYaoJiuLimit;
	int nDanDiaoLimit = checkWinParam.byDanDiaoLimit;

	//开门限制，未吃碰杠不能胡牌
	if (nKaiMenLimit && tilesHand.nCurrentLength == checkWinParam.byMaxHandCardLength)
	{
		return TRUE;
	}
	//花色限制，必须三色才能胡，nQYSHu==1时支持此种情况胡清一色
// 	if (byColorLimit == 3)
// 	{
// 		BOOL bBall = FALSE;
// 		BOOL bBaboo = FALSE;
// 		BOOL bChar = FALSE;
// 		int nColorNum = 0;
// 		for (int k = 0; k < tilesHand.nCurrentLength; k++)
// 		{
// 			if (tilesHand.tile[k] >= TILE_CHAR_1
// 				&& tilesHand.tile[k] <= TILE_CHAR_9)
// 			{
// 				bChar = TRUE;
// 			}
// 			else if (tilesHand.tile[k] >= TILE_BALL_1
// 				&& tilesHand.tile[k] <= TILE_BALL_9)
// 			{
// 				bBall = TRUE;
// 			}
// 			else if (tilesHand.tile[k] >= TILE_BAMBOO_1
// 				&& tilesHand.tile[k] <= TILE_BAMBOO_9)
// 			{
// 				bBaboo = TRUE;
// 			}
// 		}
// 		if (bChar)
// 		{
// 			nColorNum = nColorNum + 1;
// 		}
// 		if (bBall)
// 		{
// 			nColorNum = nColorNum + 1;
// 		}
// 		if (bBaboo)
// 		{
// 			nColorNum = nColorNum + 1;
// 		}
// 		if (nColorNum == 3 || (nColorNum == 1 && nQYSHu == 1))
// 		{
// 		}
// 		else
// 		{
// 			return TRUE;
// 		}
// 	}
	//幺九限制，必须有幺九才能胡
// 	if (nYaoJiuLimit)
// 	{
// 		BOOL bYao = FALSE;
// 		BOOL bJiu = FALSE;
// 		BOOL bZi = FALSE;
// 		for (int k = 0; k < tilesHand.nCurrentLength; k++)
// 		{
// 			if (tilesHand.tile[k] % 10 == 1)
// 			{
// 				bYao = TRUE;
// 			}
// 			if (tilesHand.tile[k] % 10 == 9)
// 			{
// 				bJiu = TRUE;
// 			}
// 			if (tilesHand.tile[k] > 34)
// 			{
// 				bZi = TRUE;
// 			}
// 		}
// 		if ((bYao && bJiu) || bZi)
// 		{
// 		}
// 		else
// 		{
// 			return TRUE;
// 		}
// 	}
	//手把一，单吊胡牌只能是飘牌形
// 	if (nDanDiaoLimit)
// 	{
// 		CTiles tilestemp;
// 		tilestemp.AddTiles(tilesHand);
// 
// 		if (tilestemp.nCurrentLength == 2 
// 			&& (tilestemp.tile[0] == tilestemp.tile[1]))
// 		{
// 			CTiles tilescheck;
// 			tilescheck.AddTiles(tilesHand);
// 
// // 			TILE tLast = tilesHand.tile[tilesHand.nCurrentLength - 1];
// // 
// // 			CTiles tilesJiang;
// // 			tilesJiang.AddTile(tLast);
// // 			tilesJiang.AddTile(tLast);
// // 
// // 			if (tilestemp.IsHaveNum(tLast, 2))
//  			{
// // 				tilestemp.DelTiles(tilesJiang);
// // 				if (CheckWinNoJiang(tilestemp, checkWinParam.byMaxHandCardLength))
// 				{
// 					//单吊胡牌  如果不是碰碰胡不能胡
// 					if (!CheckIsTriplet(tilescheck))
// 					{
// 						return TRUE;
// 					}
// 				}
// 			}
// 		}
// 	}

	return FALSE;
}
BOOL CMJFanCounter::CheckIsTriplet(CTiles tilesHand)
{
	if (tilesHand.nCurrentLength < 2
		// || tilesHand.nCurrentLength > 14 
		|| tilesHand.nCurrentLength % 3 != 2)
	{
		return FALSE;
	}

	if (tilesHand.nCurrentLength == 2)
	{
		return (tilesHand.tile[0] == tilesHand.tile[1]);
	}

	tilesHand.Sort();
	int i;
	CTiles TilesTemp;
	// 不检查顺子
	// 检查刻子
	CTiles TilesTriplet;
	for (i = 0; i < tilesHand.nCurrentLength - 2; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
		{
			// 和上一张相同，不用检查了
			continue;
		}

		TilesTriplet.ReleaseAll();
		TilesTriplet.AddTile(tilesHand.tile[i]);
		TilesTriplet.AddTile(tilesHand.tile[i]);
		TilesTriplet.AddTile(tilesHand.tile[i]);
		if (TilesTriplet.IsSubSet(tilesHand))
		{
			TilesTemp.ReleaseAll();
			TilesTemp.AddTiles(tilesHand);
			TilesTemp.DelTiles(TilesTriplet);
			if (CheckIsTriplet(TilesTemp))
			{
				return TRUE;
			}
		}
	}

	return FALSE;
}
//特殊胡牌检查：7小对、十三幺、13不靠、8小对等。。。
BOOL CMJFanCounter::CheckWinSpecial(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam)
{
	BOOL bResult = FALSE;
	//炮牌是癞子牌+1000
    int nGunIndex = -1;
    for (int j = 0; j < tilesHand.nCurrentLength; j++)
	{
		if (tilesHand.tile[j] > 1000)
		{
			tilesHand.tile[j]  -= 1000;
			nGunIndex = j;
		}
	}
	CTiles TilesTemp;
	TilesTemp.AddTiles(tilesHand);

	//2.分离 癞子牌堆和非癞子牌堆
	CTiles TilesLaiZi;
	TilesLaiZi.ReleaseAll();
	//癞子数大于0才做检查癞子（有些麻将碰杠后 癞子牌不能当万能牌使用（nlaiziCount传个0））
	if (nLaiziCount > 0)
	{
		for (int i = 0; i < laiziCard.nCurrentLength; i++)
		{
			for (int j = 0; j < tilesHand.nCurrentLength; j++)
			{
				if (j != nGunIndex && tilesHand.tile[j] == laiziCard.tile[i])
				{
					TilesLaiZi.AddTile(tilesHand.tile[j]);
				}
			}
		}
	}
	TilesLaiZi.Sort();
	tilesHand.DelTiles(TilesLaiZi);
	CTiles TilesHandsNoLaiZi;
	TilesHandsNoLaiZi.ReleaseAll();
	TilesHandsNoLaiZi.AddTiles(tilesHand);

	///N张癞子牌可胡
	if (checkWinParam.byLaiziWinNums >0 && nLaiziCount >= checkWinParam.byLaiziWinNums)
	{
		return TRUE;
	}

	///7小对
	if (1 == checkWinParam.byCheck7pairs)
	{
		//1癞子做普通牌
		bResult = CheckWinDouble(TilesTemp);
		if (bResult)
		{
			return TRUE;
		}
	}
	else if (2 == checkWinParam.byCheck7pairs)
	{
		//2癞子可替任何牌  TODO这个算法可用福建的那个比较简单明了
		bResult = CheckWinDoubleLaiZi(TilesHandsNoLaiZi, nLaiziCount);
		if (bResult)
		{
			return TRUE;
		}
	}

	///13幺
	if (1 == checkWinParam.byCheckShiSanYao)
	{
		//癞子做普通牌
		bResult = CheckWinShiSanYao(TilesTemp);
		if (bResult)
		{
			return TRUE;
		}
	}
	else if (2 == checkWinParam.byCheckShiSanYao)
	{
		//癞子可替任何牌 
		bResult = CheckWinShiSanYaoLaizi(TilesHandsNoLaiZi, nLaiziCount);
		if (bResult)
		{
			return TRUE;
		}
	}
	else if (2 == checkWinParam.byCheckShiSanYao && checkWinParam.byBaiChangeGoldUse)
	{	
		//白板当金是福建麻将的一个特殊玩法--龙岩，三明等
		//癞子可替任何牌, 白板可替换成癞子那张牌使用
		bResult = CheckWinShiSanYaoLaiziLongYan(TilesHandsNoLaiZi, laiziCard, nLaiziCount);
		if (bResult)
		{
			return TRUE;
		}
	}
	///七星不靠
	if (1 == checkWinParam.byQiXingBuKao)
	{
		bResult = CheckWinQiXingBuKao(TilesTemp);
		if (bResult)
		{
			return TRUE;
		}
	}

	///13不靠
	if (1 == checkWinParam.byShiSanBuKao)
	{
		bResult = CheckWinShiSanBuKao(TilesTemp);
		if (bResult)
		{
			return TRUE;
		}		
	}


	///8小对
	if (1 == checkWinParam.byCheck8Pairs)
	{
		//1癞子做普通牌
		int nResult = CheckWinPair8(TilesTemp, 0, 17, false);
		if (nResult > 0)
		{
			return TRUE;
		}
	}
	else if (2 == checkWinParam.byCheck8Pairs)
	{
		//2癞子可替任何牌
		int nResult = CheckWinPair8(TilesHandsNoLaiZi, nLaiziCount, 17, false);
		if (nResult > 0)
		{
			return TRUE;
		}
	}


    return FALSE;
}


//正常胡牌检查
BOOL CMJFanCounter::CheckWinPublic(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam)
{
	BOOL bResult = FALSE;
	//1.正常牌堆 不考虑癞子牌
    int nGunIndex = -1;
    for (int j = 0; j < tilesHand.nCurrentLength; j++)
	{
		if (tilesHand.tile[j] > 1000)
		{
			tilesHand.tile[j]  -= 1000;
			nGunIndex = j;
		}
	}
	//分离 癞子牌堆和非癞子牌堆
	CTiles TilesLaiZi;
	TilesLaiZi.ReleaseAll();
	//癞子数大于0才做检查癞子（有些麻将碰杠后 癞子牌不能当万能牌使用（nlaiziCount传个0））
	if (nLaiziCount > 0)
	{
		for (int i = 0; i < laiziCard.nCurrentLength; i++)
		{
			for (int j = 0; j < tilesHand.nCurrentLength; j++)
			{
				if (j != nGunIndex && tilesHand.tile[j] == laiziCard.tile[i])
				{
					TilesLaiZi.AddTile(tilesHand.tile[j]);
				}
			}
		}
	}
	TilesLaiZi.Sort();
	tilesHand.DelTiles(TilesLaiZi);
	CTiles tilesHandNew;
	tilesHandNew.ReleaseAll();
	tilesHandNew.AddTiles(tilesHand);

	//白板充当做癞子的那张牌
	int nBaiCount = 0;
	if (checkWinParam.byBaiChangeGoldUse)
	{
		for (int m = 0; m < tilesHand.nCurrentLength; m++)
		{
			if (tilesHand.tile[m] == TILE_BAI)
			{
				nBaiCount++;
				tilesHandNew.DelTile(tilesHand.tile[m]);
				tilesHandNew.AddTile(laiziCard.tile[0]);
			}
		}
	}
	//3.2无癞子手牌
	CTiles TilesHandsNoLaiZi;
	TilesHandsNoLaiZi.ReleaseAll();
	TilesHandsNoLaiZi.AddTiles(tilesHandNew);

	//手牌17张
	int nCardLength = checkWinParam.byMaxHandCardLength;
	bResult = CheckWinNormalLaiZi(TilesHandsNoLaiZi, laiziCard, nLaiziCount, nCardLength, checkWinParam);
    if (bResult)
    {
        return TRUE;
	}

	return FALSE;
}

//龙岩麻将特殊检查函数
BOOL CMJFanCounter::CheckWinNormalLongYan(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam)
{
	BOOL bResult = FALSE;
	//1.正常牌堆 不考虑癞子牌
    int nGunIndex = -1;
    for (int j = 0; j < tilesHand.nCurrentLength; j++)
	{
		if (tilesHand.tile[j] > 1000)
		{
			tilesHand.tile[j]  -= 1000;
			nGunIndex = j;
		}
	}
	//分离 癞子牌堆和非癞子牌堆
	CTiles TilesLaiZi;
	TilesLaiZi.ReleaseAll();
	//癞子数大于0才做检查癞子（有些麻将碰杠后 癞子牌不能当万能牌使用（nlaiziCount传个0））
	if (nLaiziCount > 0)
	{
		for (int i = 0; i < laiziCard.nCurrentLength; i++)
		{
			for (int j = 0; j < tilesHand.nCurrentLength; j++)
			{
				if (j != nGunIndex && tilesHand.tile[j] == laiziCard.tile[i])
				{
					TilesLaiZi.AddTile(tilesHand.tile[j]);
				}
			}
		}
	}
	TilesLaiZi.Sort();
	tilesHand.DelTiles(TilesLaiZi);
	CTiles tilesHandNew;
	tilesHandNew.ReleaseAll();
	tilesHandNew.AddTiles(tilesHand);

	//白板充当做癞子的那张牌
	int nBaiCount = 0;
	if (checkWinParam.byBaiChangeGoldUse)
	{
		for (int m = 0; m < tilesHand.nCurrentLength; m++)
		{
			if (tilesHand.tile[m] == TILE_BAI)
			{
				nBaiCount++;
				tilesHandNew.DelTile(tilesHand.tile[m]);
				tilesHandNew.AddTile(laiziCard.tile[0]);
			}
		}
	}
	//3.2无癞子手牌
	CTiles TilesHandsNoLaiZi;
	TilesHandsNoLaiZi.ReleaseAll();
	TilesHandsNoLaiZi.AddTiles(tilesHandNew);

	//手牌17张
	int nCardLength = checkWinParam.byMaxHandCardLength;
	for (int i = 0; i <= nBaiCount; i++)
	{
		if (i > 0 && laiziCard.nCurrentLength == 2)
		{
			TilesHandsNoLaiZi.DelTile(laiziCard.tile[0]);
			TilesHandsNoLaiZi.AddTile(laiziCard.tile[1]);
		}
		bResult = CheckWinNormalLaiZi(TilesHandsNoLaiZi, laiziCard, nLaiziCount, nCardLength, checkWinParam);
		if (bResult)
		{
			return TRUE;
		}
	}

	return FALSE;
}

//风扑将扑幺九扑特殊胡法如濮阳麻将, tilesHand全手牌
BOOL CMJFanCounter::CheckWinNormalWJYJPu(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam)
{
	BOOL bResult = FALSE;
	//炮牌是癞子牌+1000
    int nGunIndex = -1;
    for (int j = 0; j < tilesHand.nCurrentLength; j++)
	{
		if (tilesHand.tile[j] > 1000)
		{
			tilesHand.tile[j]  -= 1000;
			nGunIndex = j;
		}
	}
	CTiles TilesTemp;
	TilesTemp.AddTiles(tilesHand);

	//2.分离 癞子牌堆和非癞子牌堆
	CTiles TilesLaiZi;
	TilesLaiZi.ReleaseAll();
	//癞子数大于0才做检查癞子（有些麻将碰杠后 癞子牌不能当万能牌使用（nlaiziCount传个0））
	if (nLaiziCount > 0)
	{
		for (int i = 0; i < laiziCard.nCurrentLength; i++)
		{
			for (int j = 0; j < tilesHand.nCurrentLength; j++)
			{
				if (j != nGunIndex && tilesHand.tile[j] == laiziCard.tile[i])
				{
					TilesLaiZi.AddTile(tilesHand.tile[j]);
				}
			}
		}
	}
	TilesLaiZi.Sort();
	tilesHand.DelTiles(TilesLaiZi);
	CTiles TilesHandsNoLaiZi;
	TilesHandsNoLaiZi.ReleaseAll();
	TilesHandsNoLaiZi.AddTiles(tilesHand);

	//风扑 将扑 幺九扑
	m_nWind = 0;
	m_nJiang = 0;
	m_nYaoJiu = 0;
	bResult = CheckWinWJYJPu(TilesHandsNoLaiZi, checkWinParam);
	if (bResult)
	{
		// printf("\n====m_nWind==%d\n", m_nWind);
		// printf("\n====m_nJiang==%d\n", m_nJiang);
		// printf("\n====m_nYaoJiu==%d\n", m_nYaoJiu);
		if ((m_nWind == 0))
		{
			if (checkWinParam.byWindPu)
			{
				bResult = FALSE;
			}
		}
		if ((m_nJiang == 0))
		{
			if (checkWinParam.byJiangPu)
			{
				bResult = FALSE;
			}
		}
		if ((m_nYaoJiu == 0))
		{
			if (checkWinParam.byYaoJiuPu)
			{
				bResult = FALSE;
			}
		}
	}
	return bResult;
}
//检查风扑将扑幺九扑是否可赢， tilesHand无赖子手牌
BOOL CMJFanCounter::CheckWinWJYJPu(CTiles &tilesHand, CHECKWIN_PARAM &checkWinParam)
{
	if (tilesHand.nCurrentLength < 2 
		|| tilesHand.nCurrentLength > checkWinParam.byMaxHandCardLength 
		|| tilesHand.nCurrentLength % 3 != 2)
	{
		return FALSE;
	}

	if (tilesHand.nCurrentLength == 2)
	{
		return (tilesHand.tile[0] == tilesHand.tile[1]);
	}

	tilesHand.Sort();
	int i;
	CTiles TilesTemp;
	// 检查顺子
	for (i = 0; i < tilesHand.nCurrentLength; i++)
	{
		if (tilesHand.tile[i] > TILE_BALL_9)
		{
			TilesTemp.ReleaseAll();
			TilesTemp.AddTiles(tilesHand);
			//风扑
			if (checkWinParam.byWindPu && tilesHand.tile[i] >= TILE_EAST && tilesHand.tile[i] <= TILE_NORTH)
			{
				if (tilesHand.tile[i] == TILE_EAST)
				{
					if (tilesHand.IsHave(TILE_SOUTH) && tilesHand.IsHave(TILE_WEST))
					{
						TilesTemp.DelTile(TILE_EAST);
						TilesTemp.DelTile(TILE_SOUTH);
						TilesTemp.DelTile(TILE_WEST);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nWind++;
							return TRUE;
						}
					}
				}
				else if (tilesHand.tile[i] == TILE_SOUTH)
				{
					if (tilesHand.IsHave(TILE_NORTH) && tilesHand.IsHave(TILE_WEST))
					{
						TilesTemp.DelTile(TILE_SOUTH);
						TilesTemp.DelTile(TILE_WEST);
						TilesTemp.DelTile(TILE_NORTH);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nWind++;
							return TRUE;
						}
					}
				}
				else if (tilesHand.tile[i] == TILE_WEST)
				{
					if (tilesHand.IsHave(TILE_EAST) && tilesHand.IsHave(TILE_NORTH))
					{
						TilesTemp.DelTile(TILE_EAST);
						TilesTemp.DelTile(TILE_WEST);
						TilesTemp.DelTile(TILE_NORTH);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nWind++;
							return TRUE;
						}
					}
				}
				else if (tilesHand.tile[i] == TILE_NORTH)
				{
					if (tilesHand.IsHave(TILE_EAST) && tilesHand.IsHave(TILE_SOUTH))
					{
						TilesTemp.DelTile(TILE_NORTH);
						TilesTemp.DelTile(TILE_EAST);
						TilesTemp.DelTile(TILE_SOUTH);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nWind++;
							return TRUE;
						}
					}
				}
			}
			//将扑
			else if (checkWinParam.byJiangPu && tilesHand.tile[i] == TILE_ZHONG)
			{
				if (tilesHand.tile[i] == TILE_ZHONG)
				{
					if (tilesHand.IsHave(TILE_FA) && tilesHand.IsHave(TILE_BAI))
					{
						TilesTemp.DelTile(TILE_ZHONG);
						TilesTemp.DelTile(TILE_FA);
						TilesTemp.DelTile(TILE_BAI);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nJiang++;
							return TRUE;
						}
					}
				}
			}
			else
			{
				// 到箭牌了
				break;
			}
		}
		else
		{
			TilesTemp.ReleaseAll();
			TilesTemp.AddTiles(tilesHand);
			//幺九扑
			if (checkWinParam.byYaoJiuPu && (tilesHand.tile[i] % 10 == 1 || tilesHand.tile[i] % 10 == 9))
			{
				if (tilesHand.tile[i] % 10 == 1 || tilesHand.tile[i] % 10 == 9)
				{
					//119
					if (tilesHand.IsHave(1) && tilesHand.IsHave(11) && tilesHand.IsHave(9))
					{
						TilesTemp.DelTile(1);
						TilesTemp.DelTile(11);
						TilesTemp.DelTile(9);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nYaoJiu++;
							return TRUE;
						}
					}
					else if (tilesHand.IsHave(1) && tilesHand.IsHave(11) && tilesHand.IsHave(19))
					{
						TilesTemp.DelTile(1);
						TilesTemp.DelTile(11);
						TilesTemp.DelTile(19);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nYaoJiu++;
							return TRUE;
						}
					}
					else if (tilesHand.IsHave(1) && tilesHand.IsHave(11) && tilesHand.IsHave(29))
					{
						TilesTemp.DelTile(1);
						TilesTemp.DelTile(11);
						TilesTemp.DelTile(29);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nYaoJiu++;
							return TRUE;
						}
					}
					else if (tilesHand.IsHave(1) && tilesHand.IsHave(21) && tilesHand.IsHave(9))
					{
						TilesTemp.DelTile(1);
						TilesTemp.DelTile(21);
						TilesTemp.DelTile(9);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nYaoJiu++;
							return TRUE;
						}
					}
					else if (tilesHand.IsHave(1) && tilesHand.IsHave(21) && tilesHand.IsHave(19))
					{
						TilesTemp.DelTile(1);
						TilesTemp.DelTile(21);
						TilesTemp.DelTile(19);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nYaoJiu++;
							return TRUE;
						}
					}
					else if (tilesHand.IsHave(1) && tilesHand.IsHave(11) && tilesHand.IsHave(29))
					{
						TilesTemp.DelTile(1);
						TilesTemp.DelTile(11);
						TilesTemp.DelTile(29);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nYaoJiu++;
							return TRUE;
						}
					}
					else if (tilesHand.IsHave(11) && tilesHand.IsHave(21) && tilesHand.IsHave(9))
					{
						TilesTemp.DelTile(11);
						TilesTemp.DelTile(21);
						TilesTemp.DelTile(9);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nYaoJiu++;
							return TRUE;
						}
					}
					else if (tilesHand.IsHave(11) && tilesHand.IsHave(21) && tilesHand.IsHave(19))
					{
						TilesTemp.DelTile(11);
						TilesTemp.DelTile(21);
						TilesTemp.DelTile(19);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nYaoJiu++;
							return TRUE;
						}
					}
					else if (tilesHand.IsHave(11) && tilesHand.IsHave(21) && tilesHand.IsHave(29))
					{
						TilesTemp.DelTile(11);
						TilesTemp.DelTile(21);
						TilesTemp.DelTile(29);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nYaoJiu++;
							return TRUE;
						}
					}

					//991
					else if (tilesHand.IsHave(9) && tilesHand.IsHave(19) && tilesHand.IsHave(1))
					{
						TilesTemp.DelTile(9);
						TilesTemp.DelTile(19);
						TilesTemp.DelTile(1);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nYaoJiu++;
							return TRUE;
						}
					}
					else if (tilesHand.IsHave(9) && tilesHand.IsHave(19) && tilesHand.IsHave(11))
					{
						TilesTemp.DelTile(9);
						TilesTemp.DelTile(19);
						TilesTemp.DelTile(11);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nYaoJiu++;
							return TRUE;
						}
					}
					else if (tilesHand.IsHave(9) && tilesHand.IsHave(19) && tilesHand.IsHave(21))
					{
						TilesTemp.DelTile(21);
						TilesTemp.DelTile(19);
						TilesTemp.DelTile(9);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nYaoJiu++;
							return TRUE;
						}
					}
					else if (tilesHand.IsHave(9) && tilesHand.IsHave(29) && tilesHand.IsHave(1))
					{
						TilesTemp.DelTile(1);
						TilesTemp.DelTile(29);
						TilesTemp.DelTile(9);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nYaoJiu++;
							return TRUE;
						}
					}
					else if (tilesHand.IsHave(9) && tilesHand.IsHave(29) && tilesHand.IsHave(11))
					{
						TilesTemp.DelTile(29);
						TilesTemp.DelTile(11);
						TilesTemp.DelTile(9);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nYaoJiu++;
							return TRUE;
						}
					}
					else if (tilesHand.IsHave(9) && tilesHand.IsHave(29) && tilesHand.IsHave(21))
					{
						TilesTemp.DelTile(29);
						TilesTemp.DelTile(21);
						TilesTemp.DelTile(9);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nYaoJiu++;
							return TRUE;
						}
					}
					else if (tilesHand.IsHave(19) && tilesHand.IsHave(29) && tilesHand.IsHave(1))
					{
						TilesTemp.DelTile(1);
						TilesTemp.DelTile(19);
						TilesTemp.DelTile(29);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nYaoJiu++;
							return TRUE;
						}
					}
					else if (tilesHand.IsHave(19) && tilesHand.IsHave(29) && tilesHand.IsHave(11))
					{
						TilesTemp.DelTile(19);
						TilesTemp.DelTile(11);
						TilesTemp.DelTile(29);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nYaoJiu++;
							return TRUE;
						}
					}
					else if (tilesHand.IsHave(19) && tilesHand.IsHave(29) && tilesHand.IsHave(21))
					{
						TilesTemp.DelTile(21);
						TilesTemp.DelTile(19);
						TilesTemp.DelTile(29);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							m_nYaoJiu++;
							return TRUE;
						}
					}
					//正常顺子
					else if (tilesHand.IsHave(tilesHand.tile[i] + 1) && tilesHand.IsHave(tilesHand.tile[i] + 2))
					{
						TilesTemp.DelTile(tilesHand.tile[i]);
						TilesTemp.DelTile(tilesHand.tile[i] + 1);
						TilesTemp.DelTile(tilesHand.tile[i] + 2);
						if (CheckWinWJYJPu(TilesTemp, checkWinParam))
						{
							return TRUE;
						}
					}
				}
			}
		}
	}
	// 检查顺子
	for (i = 0; i < tilesHand.nCurrentLength - 2; i++)
	{
		if (tilesHand.tile[i] > TILE_BALL_9)
		{
			// 到箭牌了
			break;
		}
		if (tilesHand.IsHave(tilesHand.tile[i] + 1) && tilesHand.IsHave(tilesHand.tile[i] + 2))
		{
			TilesTemp.ReleaseAll();
			TilesTemp.AddTiles(tilesHand);

			TilesTemp.DelTile(tilesHand.tile[i]);
			TilesTemp.DelTile(tilesHand.tile[i] + 1);
			TilesTemp.DelTile(tilesHand.tile[i] + 2);
			if (CheckWinWJYJPu(TilesTemp, checkWinParam))
			{
				return TRUE;
			}
		}
	}
	// 检查刻子
	CTiles TilesTriplet;
	for (i = 0; i < tilesHand.nCurrentLength - 2; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
		{
			// 和上一张相同，不用检查了
			continue;
		}

		TilesTriplet.ReleaseAll();
		TilesTriplet.AddTile(tilesHand.tile[i]);
		TilesTriplet.AddTile(tilesHand.tile[i]);
		TilesTriplet.AddTile(tilesHand.tile[i]);
		if (TilesTriplet.IsSubSet(tilesHand))
		{
			TilesTemp.ReleaseAll();
			TilesTemp.AddTiles(tilesHand);
			TilesTemp.DelTiles(TilesTriplet);
			if (CheckWinWJYJPu(TilesTemp, checkWinParam))
			{
				return TRUE;
			}
		}
	}
	return FALSE;
}

//258将胡法检查函数
BOOL CMJFanCounter::CheckWinNormal258Jiang(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam)
{
	BOOL bResult = FALSE;
	//炮牌是癞子牌+1000
    int nGunIndex = -1;
    for (int j = 0; j < tilesHand.nCurrentLength; j++)
	{
		if (tilesHand.tile[j] > 1000)
		{
			tilesHand.tile[j]  -= 1000;
			nGunIndex = j;
		}
	}
	CTiles TilesJiang;
	TilesJiang.AddTiles(tilesHand);
	TilesJiang.Sort();

	//分离 癞子牌堆和非癞子牌堆
	CTiles TilesLaiZi;
	TilesLaiZi.ReleaseAll();
	//癞子数大于0才做检查癞子（有些麻将碰杠后 癞子牌不能当万能牌使用（nlaiziCount传个0））
	if (nLaiziCount > 0)
	{
		for (int i = 0; i < laiziCard.nCurrentLength; i++)
		{
			for (int j = 0; j < tilesHand.nCurrentLength; j++)
			{
				if (j != nGunIndex && tilesHand.tile[j] == laiziCard.tile[i])
				{
					TilesLaiZi.AddTile(tilesHand.tile[j]);
				}
			}
		}
	}
	TilesLaiZi.Sort();
	tilesHand.DelTiles(TilesLaiZi);

	CTiles tilesTempJiang, tilesGood;
	int nCardLength = checkWinParam.byMaxHandCardLength;

	for (int i = 0; i < TilesJiang.nCurrentLength; i++)
	{
		if (i > 0 && TilesJiang.tile[i] == TilesJiang.tile[i - 1])
		{
			continue;
		}
		if (TilesJiang.tile[i] >= TILE_EAST)
		{
			continue; // 到字牌了
		}
		if ((TilesJiang.tile[i] % 10) % 3 != 2)
		{
			continue; // 不是258
		}
		tilesGood.ReleaseAll();
		tilesGood.AddTile(TilesJiang.tile[i]);
		tilesGood.AddTile(TilesJiang.tile[i]);
		//癞子可替任何牌
		// if (ngamestyle == GAME_STYLE_ZHOUKOU || ngamestyle == GAME_STYLE_KAIFENG)
		if (2 == checkWinParam.by258Jiang)
		{
			if (tilesGood.IsSubSet(TilesJiang))
			{
				tilesTempJiang.ReleaseAll();
				tilesTempJiang.AddTiles(TilesJiang);
				tilesTempJiang.DelTiles(tilesGood);
				if (TilesJiang.tile[i] == laiziCard.tile[0] && nLaiziCount >= 2)
				{
					nLaiziCount = nLaiziCount - 2;
					TilesLaiZi.DelTile(laiziCard.tile[0]);
					TilesLaiZi.DelTile(laiziCard.tile[0]);
				}
				CTiles tilesTempJiangNoLaiZi;
				tilesTempJiangNoLaiZi.ReleaseAll();
				tilesTempJiangNoLaiZi.AddTiles(tilesTempJiang);
				tilesTempJiangNoLaiZi.DelTiles(TilesLaiZi);
				if (CMJFanCounter::CheckWinNoJiangLaizi(tilesTempJiangNoLaiZi, laiziCard, nLaiziCount, nCardLength, checkWinParam))
				{
					bResult = TRUE;
					break;
				}
			}
		}
		//癞子做普通牌
		// else if (ngamestyle == GAME_STYLE_258 || ngamestyle == GAME_STYLE_GEERMU || ngamestyle == GAME_STYLE_XINGXIANG)
		else if (1 == checkWinParam.by258Jiang)
		{
			if (tilesGood.IsSubSet(TilesJiang))
			{
				tilesTempJiang.ReleaseAll();
				tilesTempJiang.AddTiles(TilesJiang);
				tilesTempJiang.DelTiles(tilesGood);
				CTiles tilesTempJiangTemp;
				tilesTempJiangTemp.ReleaseAll();
				tilesTempJiangTemp.AddTiles(tilesTempJiang);
				if (CMJFanCounter::CheckWinNoJiang(tilesTempJiangTemp, nCardLength))
				{
					bResult = TRUE;
					break;
				}
			}
		}
	}

	return bResult;	
}

///---------------------------------------------------------------------------------------------------------------------
//边卡吊胡法检查函数
BOOL CMJFanCounter::CheckWinNormalBKD(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam)
{
	BOOL bResultB = FALSE;
	BOOL bResultK = FALSE;
	BOOL bResultD = FALSE;
	CTiles tilesBian, tilesKa, tilesDiao;
	tilesBian.ReleaseAll();
	tilesBian.AddTiles(tilesHand);

	tilesKa.ReleaseAll();
	tilesKa.AddTiles(tilesHand);

	tilesDiao.ReleaseAll();
	tilesDiao.AddTiles(tilesHand);

	bResultB = CheckWinNormalB(tilesBian, nLaiziCount, laiziCard, checkWinParam);
	bResultK = CheckWinNormalK(tilesKa, nLaiziCount, laiziCard, checkWinParam);
	bResultD = CheckWinNormalD(tilesDiao, nLaiziCount, laiziCard, checkWinParam);
	if (!bResultB && !bResultK && !bResultD)
	{
		return FALSE;
	}
	else
	{
		return TRUE;
	}
}
BOOL CMJFanCounter::CheckWinNormalB(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam)
{
	int nLaizi = nLaiziCount;
	TILE t = tilesHand.tile[tilesHand.nCurrentLength-1];
	int nCardLength = tilesHand.nCurrentLength;

	CTiles tilesGood, tilesTemp;
	if (tilesHand.nCurrentLength < 3 || nLaizi > 0)
	{
		return FALSE;
	}
	// 摸到的牌不是3、7不算边
	if (t > TILE_BALL_9 || (t % 10 != 3) && (t % 10 != 7))
	{
		return FALSE;
	}
	if (t % 10 == 3)
	{
		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t - 2);
		if (!tilesGood.IsSubSet(tilesHand))
		{
			return FALSE;
		}
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (!CheckWinPublic(tilesTemp, nLaiziCount, laiziCard, checkWinParam))
		{
			return FALSE;
		}

		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t - 1);
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (CheckWinPublic(tilesTemp, nLaiziCount, laiziCard, checkWinParam))
		{
			return FALSE;
		}

		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t);
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (CheckWinPublic(tilesTemp, nLaiziCount, laiziCard, checkWinParam))
		{
			return FALSE;
		}
	}
	else if (t % 10 == 7)
	{
		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t);
		if (!tilesGood.IsSubSet(tilesHand))
		{
			return FALSE;
		}
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (!CheckWinPublic(tilesTemp, nLaiziCount, laiziCard, checkWinParam))
		{
			return FALSE;
		}

		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t - 1);
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (CheckWinPublic(tilesTemp, nLaiziCount, laiziCard, checkWinParam))
		{
			return FALSE;
		}

		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t - 2);
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (CheckWinPublic(tilesTemp, nLaiziCount, laiziCard, checkWinParam))
		{
			return FALSE;
		}
	}

	// 检查是否能对chu
	tilesGood.ReleaseAll();
	tilesGood.AddTriplet(t);
	if (tilesGood.IsSubSet(tilesHand))
	{
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (CheckWinPublic(tilesTemp, nLaiziCount, laiziCard, checkWinParam))
		{
			return FALSE;
		}
	}

	return TRUE;
}
BOOL CMJFanCounter::CheckWinNormalK(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam) // 卡
{
	int nLaizi = nLaiziCount;
	TILE t = tilesHand.tile[tilesHand.nCurrentLength-1];
	int nCardLength = tilesHand.nCurrentLength;

	CTiles tilesGood, tilesTemp;
	if ((t % 10 == 1) || (t % 10 == 9))
	{
		return FALSE;
	}
	if (tilesHand.nCurrentLength < 3 || nLaizi > 0)
	{
		return FALSE;
	}
	if (t > TILE_BALL_9)
	{
		return FALSE;
	}

	tilesGood.ReleaseAll();
	tilesGood.AddCollect(t - 1);
	if (!tilesGood.IsSubSet(tilesHand))
	{
		return FALSE;
	}
	tilesTemp.ReleaseAll();
	tilesTemp.AddTiles(tilesHand);
	tilesTemp.DelTiles(tilesGood);
	if (!CheckWinPublic(tilesTemp, nLaiziCount, laiziCard, checkWinParam))
	{
		return FALSE;
	}

	if (t % 10 > 2)
	{
		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t - 2);	// t-2, t-1, t
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (CheckWinPublic(tilesTemp, nLaiziCount, laiziCard, checkWinParam))
		{
			return FALSE;
		}
	}
	if (t % 10 < 8)
	{
		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t);	// t, t+1, t+2
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (CheckWinPublic(tilesTemp, nLaiziCount, laiziCard, checkWinParam))
		{
			return FALSE;
		}
	}

	// 检查是否能对chu
	tilesGood.ReleaseAll();
	tilesGood.AddTriplet(t);
	if (tilesGood.IsSubSet(tilesHand))
	{
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (CheckWinPublic(tilesTemp, nLaiziCount, laiziCard, checkWinParam))
		{
			return FALSE;
		}
	}
	return TRUE;
}
BOOL CMJFanCounter::CheckWinNormalD(CTiles &tilesHand, int nLaiziCount, CTiles &laiziCard, CHECKWIN_PARAM &checkWinParam) // 吊
{
	int nLaizi = nLaiziCount;
	TILE t = tilesHand.tile[tilesHand.nCurrentLength-1];
	int nCardLength = tilesHand.nCurrentLength;
	CTiles tilesGood, tilesTemp;

	tilesGood.AddTile(t);
	tilesGood.AddTile(t);
	if (!tilesGood.IsSubSet(tilesHand))
	{
		return FALSE;
	}
	tilesTemp.AddTiles(tilesHand);
	tilesTemp.DelTiles(tilesGood);
	int nTempLength = checkWinParam.byMaxHandCardLength - 2;
	if (!CheckWinNoJiangLaizi(tilesTemp, laiziCard, nLaiziCount, nTempLength,checkWinParam))
	{
		return FALSE;
	}

	// 检查能不能和其他的方式
	// 检查是否能对chu
	tilesGood.ReleaseAll();
	tilesGood.AddTriplet(t);
	if (tilesGood.IsSubSet(tilesHand))
	{
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (CheckWinNoJiangLaizi(tilesTemp, laiziCard, nLaiziCount,nTempLength, checkWinParam))
		{
			return FALSE;
		}
	}

	// 普通吃
	if (t <= TILE_BALL_9 && t % 10 > 2)
	{
		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t - 2);	// t-2, t-1, t
		if (tilesGood.IsSubSet(tilesHand))
		{
			tilesTemp.ReleaseAll();
			tilesTemp.AddTiles(tilesHand);
			tilesTemp.DelTiles(tilesGood);
			if (CheckWinNoJiangLaizi(tilesTemp, laiziCard, nLaiziCount,nTempLength, checkWinParam))
			{
				return FALSE;
			}
		}
	}
	if (t <= TILE_BALL_9 && t % 10 > 1 && t % 10 < 9)
	{
		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t - 1);	// t-2, t-1, t
		if (tilesGood.IsSubSet(tilesHand))
		{
			tilesTemp.ReleaseAll();
			tilesTemp.AddTiles(tilesHand);
			tilesTemp.DelTiles(tilesGood);
			if (CheckWinNoJiangLaizi(tilesTemp, laiziCard, nLaiziCount,nTempLength, checkWinParam))
			{
				return FALSE;
			}
		}
	}
	if (t <= TILE_BALL_9 && t % 10 < 8)
	{
		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t);	// t, t+1, t+2
		if (tilesGood.IsSubSet(tilesHand))
		{
			tilesTemp.ReleaseAll();
			tilesTemp.AddTiles(tilesHand);
			tilesTemp.DelTiles(tilesGood);
			if (CheckWinNoJiangLaizi(tilesTemp, laiziCard, nLaiziCount, nTempLength, checkWinParam))
			{
				return FALSE;
			}
		}
	}

	// 检查能不能有1234这种的
	if (t <= TILE_BALL_9 && t % 10 > 3)
	{
		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t - 3);
		tilesGood.AddTile(t);
		tilesGood.AddTile(t);
		if (tilesGood.IsSubSet(tilesHand))
		{
			tilesTemp.ReleaseAll();	
			tilesTemp.AddTiles(tilesHand);
			tilesTemp.DelTiles(tilesGood);
			if (CheckWinNoJiangLaizi(tilesTemp, laiziCard, nLaiziCount,  nTempLength, checkWinParam))
			{
				return FALSE;
			}
		}
	}
	if (t <= TILE_BALL_9 && t % 10 < 7)
	{
		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t + 1);
		tilesGood.AddTile(t);
		tilesGood.AddTile(t);
		if (tilesGood.IsSubSet(tilesHand))
		{
			tilesTemp.ReleaseAll();
			tilesTemp.AddTiles(tilesHand);
			tilesTemp.DelTiles(tilesGood);
			if (CheckWinNoJiangLaizi(tilesTemp, laiziCard, nLaiziCount,  nTempLength, checkWinParam))
			{
				return FALSE;
			}
		}
	}
	return TRUE;
}

CMJFanCounter::CTiles::CTiles()
{
	nCurrentLength = 0;
}

CMJFanCounter::CTiles::~CTiles()
{
}

BOOL CMJFanCounter::CTiles::IsHave(TILE t)
{
	for (int i = 0; i < nCurrentLength; i++)
	{
		if (tile[i] == t)
		{
			return TRUE;
		}
	}
	return FALSE;
}

BOOL CMJFanCounter::CTiles::IsHaveNum(TILE t, int num)
{
	int nTempNum = 0;
	for (int i = 0; i < nCurrentLength; i++)
	{
		if (tile[i] == t)
		{
			nTempNum++;
		}
	}
	if (nTempNum == num)
	{
		return TRUE;
	}
	return FALSE;
}

void CMJFanCounter::CTiles::AddCollect(TILE tStart)
{
	AddTile(tStart);
	AddTile(tStart + 1);
	AddTile(tStart + 2);
}

void CMJFanCounter::CTiles::AddTriplet(TILE t)
{
	AddTile(t);
	AddTile(t);
	AddTile(t);
}

void CMJFanCounter::CTiles::AddTile(TILE t)
{
	if (nCurrentLength > MAX_CARD_NUMBER - 1)
	{
		return;
	}

	tile[nCurrentLength] = t;
	nCurrentLength++;
}

void CMJFanCounter::CTiles::AddTiles(TILE *pTiles, int nCount)
{
	for (int i = 0; i < nCount; i++)
	{
		if (nCurrentLength >= MAX_CARD_NUMBER)
		{
			break;
		}
		AddTile(pTiles[i]);
	}
}

void CMJFanCounter::CTiles::AddTiles(CMJFanCounter::CTiles &tiles)
{
	for (int i = 0; i < tiles.nCurrentLength; i++)
	{
		if (nCurrentLength >= MAX_CARD_NUMBER)
		{
			break;
		}
		AddTile(tiles.tile[i]);
	}
}

void CMJFanCounter::CTiles::ReleaseAll()
{
	nCurrentLength = 0;
}

void CMJFanCounter::CTiles::Swap(int src, int dst)
{
	if (src < 0 || src >= nCurrentLength || dst < 0 || dst >= nCurrentLength)
	{
		return;
	}
	TILE tempTile = tile[src];
	tile[src] = tile[dst];
	tile[dst] = tempTile;
}

void CMJFanCounter::CTiles::DelTile(TILE t)
{
	for (int i = 0; i < nCurrentLength; i++)
	{
		if (t == tile[i])
		{
			Swap(i, nCurrentLength - 1);
			nCurrentLength--;
			return;
		}
	}
}

void CMJFanCounter::CTiles::DelTiles(CTiles &tiles)
{
	for (int i = 0; i < tiles.nCurrentLength; i++)
	{
		DelTile(tiles.tile[i]);
	}
}

void CMJFanCounter::CTiles::DelTileAll(TILE t)
{
	for (int i = 0; i < nCurrentLength;)
	{
		if (t == tile[i])
		{
			Swap(i, nCurrentLength - 1);
			nCurrentLength--;
			continue;
		}

		i++;
	}
}

void CMJFanCounter::CTiles::Sort()
{
	if (nCurrentLength < 2 || nCurrentLength > MAX_CARD_NUMBER)
	{
		return;
	}

	int i, j;
	for (i = 0; i < nCurrentLength; i++)
	{
		for (j = i + 1; j < nCurrentLength; j++)
		{
			if (tile[i] > tile[j])
			{
				Swap(i, j);
			}
		}
	}
}

BOOL CMJFanCounter::CTiles::IsSubSet(CTiles &tiles)
{
	if (0 == nCurrentLength)
	{
		return TRUE;
	}

	if (nCurrentLength > tiles.nCurrentLength)
	{
		return FALSE;
	}

	CTiles dup;
	dup.AddTiles(tiles);

	dup.DelTiles(*this);

	if (dup.nCurrentLength == tiles.nCurrentLength - nCurrentLength)
	{
		return TRUE;
	}

	return FALSE;
}

int CMJFanCounter::CTiles::size()
{
	return nCurrentLength;
}

void CMJFanCounter::CollectAllTile(CTiles &tilesAll, ENVIRONMENT &env, BYTE chair)
{
	for (int i = 0; i < env.byHandCount[chair]; i++)
	{
		tilesAll.AddTile(env.tHand[chair][i]);
	}

	for (int i = 0; i < env.bySetCount[chair]; i++)
	{
		switch (env.tSet[chair][i][0])
		{
		case ACTION_COLLECT:
		{
			tilesAll.AddTile(env.tSet[chair][i][1]);
			tilesAll.AddTile(env.tSet[chair][i][1] + 1);
			tilesAll.AddTile(env.tSet[chair][i][1] + 2);
		}
		break;
		case ACTION_TRIPLET:
		case ACTION_QUADRUPLET:
		case ACTION_QUADRUPLET_REVEALED:
		case ACTION_QUADRUPLET_CONCEALED:
		{
			tilesAll.AddTile(env.tSet[chair][i][1]);
			tilesAll.AddTile(env.tSet[chair][i][1]);
			tilesAll.AddTile(env.tSet[chair][i][1]);
		}
		case ACTION_LIANGXIER:
		{
			tilesAll.AddTile(TILE_ZHONG);
			tilesAll.AddTile(TILE_FA);
			tilesAll.AddTile(TILE_BAI);
		}
		break;
		default:
			break;
		}
	}
	tilesAll.Sort();
}

void CMJFanCounter::CollectHandTile(CTiles &tilesHand, ENVIRONMENT &env, BYTE chair)
{
	for (int i = 0; i < env.byHandCount[chair]; i++)
	{
		tilesHand.AddTile(env.tHand[chair][i]);
	}
}

void CMJFanCounter::CollectLaiziTile(CTiles &tilesLaizi, ENVIRONMENT &env)
{
	for (int i = 0; i < 4; i++)
	{
		if (env.byLaiziCards[i] > 0)
		{
			tilesLaizi.AddTile(env.byLaiziCards[i]);
		}
	}
}

BOOL CMJFanCounter::TingCount(TING_COUNT *&pTingCount)
{
	printf("CMJFan TingCount===\n");
	pTingCount = &m_TingCount;
	return TRUE;
}
BOOL CMJFanCounter::HuPaiCount(HUPAI_COUNT *&pHuPaiCount)
{
	printf("CMJFan HuPaiCount===\n");
	pHuPaiCount = &m_HuPaiCount;
	return TRUE;
}
// 默认的算番方法
// 将各个
BOOL CMJFanCounter::GetScore(int nScore[4])
{
	return TRUE;
}

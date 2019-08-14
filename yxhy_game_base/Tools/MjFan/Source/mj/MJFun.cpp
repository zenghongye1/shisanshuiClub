// MJFun.cpp: implementation of the CMJFun class.
//
//////////////////////////////////////////////////////////////////////

//#include "StdAfx.h"
#include "common/environment.h"
#include "common/MJFanCounter.h"
#include "MJFun.h"
#include <math.h>

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

BOOL CMJFun::m_bNew19Check = TRUE;
int CMJFun::m_nFourCount = 0;
int CMJFun::m_nLaiZiNeed = 0;
#define NOCHECK(n)                                    \
	pCounter->m_FanCount.m_FanNode[n].bCheck = FALSE; \
	pCounter->m_FanCount.m_FanNode[n].bFan = FALSE;
#define DOCHECK(n) pCounter->m_FanCount.m_FanNode[n].bCheck = TRUE;

#define COUNTNOCHECK(n)                     \
	m_FanCount.m_FanNode[n].bCheck = FALSE; \
	m_FanCount.m_FanNode[n].bFan = FALSE;

#define COUNTDOCHECK(n) m_FanCount.m_FanNode[n].bCheck = TRUE;

CMJFun::CMJFun()
{
	m_nGameStyle = GAME_STYLE_CHENGDU;
	m_nMinWin = 0;  // 成都麻将没规定多少
	m_nBaseBet = 1; // 成都麻将没有基本分, 这里表示的是一番对应6分。意义和国标不同。

	m_byStyle = 0;  // 0: --普通模式， 1: --血战模式
	m_bZiMoJiaDi = FALSE;

	int i = 0;

	for (i = 0; i < 4; i++)
	{
		m_nZiMoJiaDi[i] = 0;
	}
	memset(&m_FanCount, 0, sizeof(FAN_COUNT));
	memset(&m_TingCount, 0, sizeof(TING_COUNT));
	memset(&m_HuPaiCount, 0, sizeof(HUPAI_COUNT));

	// 1番
	strncpy(m_FanCount.m_FanNode[0].szFanName, "平胡", MAX_FAN_NAME);
	m_FanCount.m_FanNode[0].bCheck = TRUE;
	m_FanCount.m_FanNode[0].bFan = FALSE;
	m_FanCount.m_FanNode[0].byFanNumber = 1;
	m_FanCount.m_FanNode[0].Check = Check000;
	m_FanCount.m_FanNode[0].byFanType = 0;
	// 2番
	strncpy(m_FanCount.m_FanNode[1].szFanName, "对对胡", MAX_FAN_NAME);
	m_FanCount.m_FanNode[1].bCheck = TRUE;
	m_FanCount.m_FanNode[1].bFan = FALSE;
	m_FanCount.m_FanNode[1].byFanNumber = 2;
	m_FanCount.m_FanNode[1].Check = Check001;
	m_FanCount.m_FanNode[1].byFanType = 1;
	// 3番
	strncpy(m_FanCount.m_FanNode[2].szFanName, "清一色", MAX_FAN_NAME);
	m_FanCount.m_FanNode[2].bCheck = TRUE;
	m_FanCount.m_FanNode[2].bFan = FALSE;
	m_FanCount.m_FanNode[2].byFanNumber = 3;
	m_FanCount.m_FanNode[2].Check = Check002;
	m_FanCount.m_FanNode[2].byFanType = 2;

	strncpy(m_FanCount.m_FanNode[3].szFanName, "带幺九", MAX_FAN_NAME);
	m_FanCount.m_FanNode[3].bCheck = TRUE;
	m_FanCount.m_FanNode[3].bFan = FALSE;
	m_FanCount.m_FanNode[3].byFanNumber = 3;
	m_FanCount.m_FanNode[3].Check = Check003;
	m_FanCount.m_FanNode[3].byFanType = 3;

	strncpy(m_FanCount.m_FanNode[4].szFanName, "七对", MAX_FAN_NAME);
	m_FanCount.m_FanNode[4].bCheck = TRUE;
	m_FanCount.m_FanNode[4].bFan = FALSE;
	m_FanCount.m_FanNode[4].byFanNumber = 3;
	m_FanCount.m_FanNode[4].Check = Check004;
	m_FanCount.m_FanNode[4].byFanType = 4;

	strncpy(m_FanCount.m_FanNode[5].szFanName, "龙七对", MAX_FAN_NAME);
	m_FanCount.m_FanNode[5].bCheck = TRUE;
	m_FanCount.m_FanNode[5].bFan = FALSE;
	m_FanCount.m_FanNode[5].byFanNumber = 4;
	m_FanCount.m_FanNode[5].Check = Check005;
	m_FanCount.m_FanNode[5].byFanType = 5;

	// 4番
	strncpy(m_FanCount.m_FanNode[6].szFanName, "清对", MAX_FAN_NAME);
	m_FanCount.m_FanNode[6].bCheck = TRUE;
	m_FanCount.m_FanNode[6].bFan = FALSE;
	m_FanCount.m_FanNode[6].byFanNumber = 4;
	m_FanCount.m_FanNode[6].Check = Check006;
	m_FanCount.m_FanNode[6].byFanType = 6;

	// 5番
	strncpy(m_FanCount.m_FanNode[7].szFanName, "清七对", MAX_FAN_NAME);
	m_FanCount.m_FanNode[7].bCheck = TRUE;
	m_FanCount.m_FanNode[7].bFan = FALSE;
	m_FanCount.m_FanNode[7].byFanNumber = 5;
	m_FanCount.m_FanNode[7].Check = Check007;
	m_FanCount.m_FanNode[7].byFanType = 7;

	strncpy(m_FanCount.m_FanNode[8].szFanName, "清幺九", MAX_FAN_NAME);
	m_FanCount.m_FanNode[8].bCheck = TRUE;
	m_FanCount.m_FanNode[8].bFan = FALSE;
	m_FanCount.m_FanNode[8].byFanNumber = 5;
	m_FanCount.m_FanNode[8].Check = Check008;
	m_FanCount.m_FanNode[8].byFanType = 8;

	strncpy(m_FanCount.m_FanNode[9].szFanName, "将一色", MAX_FAN_NAME); //将对
	m_FanCount.m_FanNode[9].bCheck = TRUE;
	m_FanCount.m_FanNode[9].bFan = FALSE;
	m_FanCount.m_FanNode[9].byFanNumber = 2;
	m_FanCount.m_FanNode[9].Check = Check009;
	m_FanCount.m_FanNode[9].byFanType = 9;
	// 6番
	strncpy(m_FanCount.m_FanNode[10].szFanName, "清龙七对", MAX_FAN_NAME);
	m_FanCount.m_FanNode[10].bCheck = TRUE;
	m_FanCount.m_FanNode[10].bFan = FALSE;
	m_FanCount.m_FanNode[10].byFanNumber = 6;
	m_FanCount.m_FanNode[10].Check = Check010;
	m_FanCount.m_FanNode[10].byFanType = 10;
	// 另加番: 杠1番
	strncpy(m_FanCount.m_FanNode[11].szFanName, "杠", MAX_FAN_NAME);
	m_FanCount.m_FanNode[11].bCheck = TRUE;
	m_FanCount.m_FanNode[11].bFan = FALSE;
	m_FanCount.m_FanNode[11].byFanNumber = 1; //
	m_FanCount.m_FanNode[11].Check = Check011;
	m_FanCount.m_FanNode[11].byFanType = 11;
	// 另加番: 根1番
	strncpy(m_FanCount.m_FanNode[12].szFanName, "根", MAX_FAN_NAME);
	m_FanCount.m_FanNode[12].bCheck = TRUE;
	m_FanCount.m_FanNode[12].bFan = FALSE;
	m_FanCount.m_FanNode[12].byFanNumber = 1; //
	m_FanCount.m_FanNode[12].Check = Check012;
	m_FanCount.m_FanNode[12].byFanType = 12;
	// 另加番: 杠上花1番
	strncpy(m_FanCount.m_FanNode[13].szFanName, "杠上花", MAX_FAN_NAME);
	m_FanCount.m_FanNode[13].bCheck = TRUE;
	m_FanCount.m_FanNode[13].bFan = FALSE;
	m_FanCount.m_FanNode[13].byFanNumber = 1; // jzhang 杠上花改为1番
	m_FanCount.m_FanNode[13].Check = Check013;
	m_FanCount.m_FanNode[13].byFanType = 13;
	// 另加番: 杠上炮	1番
	strncpy(m_FanCount.m_FanNode[14].szFanName, "杠上炮", MAX_FAN_NAME);
	m_FanCount.m_FanNode[14].bCheck = TRUE;
	m_FanCount.m_FanNode[14].bFan = FALSE;
	m_FanCount.m_FanNode[14].byFanNumber = 1;
	m_FanCount.m_FanNode[14].Check = Check014;
	m_FanCount.m_FanNode[14].byFanType = 14;
	// 另加番: 抢杠胡	1番
	strncpy(m_FanCount.m_FanNode[15].szFanName, "抢杠胡", MAX_FAN_NAME);
	m_FanCount.m_FanNode[15].bCheck = TRUE;
	m_FanCount.m_FanNode[15].bFan = FALSE;
	m_FanCount.m_FanNode[15].byFanNumber = 1;
	m_FanCount.m_FanNode[15].Check = Check015;
	m_FanCount.m_FanNode[15].byFanType = 15;
	// 庄家起手自模，即"天胡"。5番
	strncpy(m_FanCount.m_FanNode[16].szFanName, "天胡", MAX_FAN_NAME);
	m_FanCount.m_FanNode[16].bCheck = TRUE;
	m_FanCount.m_FanNode[16].bFan = FALSE;
	m_FanCount.m_FanNode[16].byFanNumber = 6;
	m_FanCount.m_FanNode[16].Check = Check016;
	m_FanCount.m_FanNode[16].byFanType = 16;
	// 非庄家起手自模，即"地胡"。5番
	strncpy(m_FanCount.m_FanNode[17].szFanName, "地胡", MAX_FAN_NAME);
	m_FanCount.m_FanNode[17].bCheck = TRUE;
	m_FanCount.m_FanNode[17].bFan = FALSE;
	m_FanCount.m_FanNode[17].byFanNumber = 6;
	m_FanCount.m_FanNode[17].Check = Check017;
	m_FanCount.m_FanNode[17].byFanType = 17;

	strncpy(m_FanCount.m_FanNode[18].szFanName, "自摸", MAX_FAN_NAME);
	m_FanCount.m_FanNode[18].bCheck = TRUE;
	m_FanCount.m_FanNode[18].bFan = FALSE;
	m_FanCount.m_FanNode[18].byFanNumber = 1;
	m_FanCount.m_FanNode[18].Check = Check018;
	m_FanCount.m_FanNode[18].byFanType = 18;

	strncpy(m_FanCount.m_FanNode[19].szFanName, "点炮", MAX_FAN_NAME);
	m_FanCount.m_FanNode[19].bCheck = TRUE;
	m_FanCount.m_FanNode[19].bFan = FALSE;
	m_FanCount.m_FanNode[19].byFanNumber = 1;
	m_FanCount.m_FanNode[19].Check = Check019;
	m_FanCount.m_FanNode[19].byFanType = 19;

	strncpy(m_FanCount.m_FanNode[20].szFanName, "门清", MAX_FAN_NAME);
	m_FanCount.m_FanNode[20].bCheck = TRUE;
	m_FanCount.m_FanNode[20].bFan = FALSE;
	m_FanCount.m_FanNode[20].byFanNumber = 1;
	m_FanCount.m_FanNode[20].Check = Check020;
	m_FanCount.m_FanNode[20].byFanType = 20;

	strncpy(m_FanCount.m_FanNode[21].szFanName, "边", MAX_FAN_NAME);
	m_FanCount.m_FanNode[21].bCheck = TRUE;
	m_FanCount.m_FanNode[21].bFan = FALSE;
	m_FanCount.m_FanNode[21].byFanNumber = 1;
	m_FanCount.m_FanNode[21].Check = Check021;
	m_FanCount.m_FanNode[21].byFanType = 21;

	strncpy(m_FanCount.m_FanNode[22].szFanName, "卡", MAX_FAN_NAME);
	m_FanCount.m_FanNode[22].bCheck = TRUE;
	m_FanCount.m_FanNode[22].bFan = FALSE;
	m_FanCount.m_FanNode[22].byFanNumber = 1;
	m_FanCount.m_FanNode[22].Check = Check022;
	m_FanCount.m_FanNode[22].byFanType = 22;

	strncpy(m_FanCount.m_FanNode[23].szFanName, "吊", MAX_FAN_NAME);
	m_FanCount.m_FanNode[23].bCheck = TRUE;
	m_FanCount.m_FanNode[23].bFan = FALSE;
	m_FanCount.m_FanNode[23].byFanNumber = 1;
	m_FanCount.m_FanNode[23].Check = Check023;
	m_FanCount.m_FanNode[23].byFanType = 23;

	strncpy(m_FanCount.m_FanNode[24].szFanName, "庄家", MAX_FAN_NAME);
	m_FanCount.m_FanNode[24].bCheck = TRUE;
	m_FanCount.m_FanNode[24].bFan = FALSE;
	m_FanCount.m_FanNode[24].byFanNumber = 1;
	m_FanCount.m_FanNode[24].Check = Check024;
	m_FanCount.m_FanNode[24].byFanType = 24;

	strncpy(m_FanCount.m_FanNode[25].szFanName, "一条龙", MAX_FAN_NAME);
	m_FanCount.m_FanNode[25].bCheck = TRUE;
	m_FanCount.m_FanNode[25].bFan = FALSE;
	m_FanCount.m_FanNode[25].byFanNumber = 1;
	m_FanCount.m_FanNode[25].Check = Check025;
	m_FanCount.m_FanNode[25].byFanType = 25;

	strncpy(m_FanCount.m_FanNode[26].szFanName, "海底捞月", MAX_FAN_NAME);
	m_FanCount.m_FanNode[26].bCheck = TRUE;
	m_FanCount.m_FanNode[26].bFan = FALSE;
	m_FanCount.m_FanNode[26].byFanNumber = 1;
	m_FanCount.m_FanNode[26].Check = Check026;
	m_FanCount.m_FanNode[26].byFanType = 26;

	strncpy(m_FanCount.m_FanNode[27].szFanName, "豪华七对", MAX_FAN_NAME);
	m_FanCount.m_FanNode[27].bCheck = TRUE;
	m_FanCount.m_FanNode[27].bFan = FALSE;
	m_FanCount.m_FanNode[27].byFanNumber = 2;
	m_FanCount.m_FanNode[27].Check = Check027;
	m_FanCount.m_FanNode[27].byFanType = 27;

	strncpy(m_FanCount.m_FanNode[28].szFanName, "清豪华七对", MAX_FAN_NAME);
	m_FanCount.m_FanNode[28].bCheck = TRUE;
	m_FanCount.m_FanNode[28].bFan = FALSE;
	m_FanCount.m_FanNode[28].byFanNumber = 4;
	m_FanCount.m_FanNode[28].Check = Check028;
	m_FanCount.m_FanNode[28].byFanType = 28;

	strncpy(m_FanCount.m_FanNode[29].szFanName, "超豪华七对", MAX_FAN_NAME);
	m_FanCount.m_FanNode[29].bCheck = TRUE;
	m_FanCount.m_FanNode[29].bFan = FALSE;
	m_FanCount.m_FanNode[29].byFanNumber = 3;
	m_FanCount.m_FanNode[29].Check = Check029;
	m_FanCount.m_FanNode[29].byFanType = 29;

	strncpy(m_FanCount.m_FanNode[30].szFanName, "清超豪华七对", MAX_FAN_NAME);
	m_FanCount.m_FanNode[30].bCheck = TRUE;
	m_FanCount.m_FanNode[30].bFan = FALSE;
	m_FanCount.m_FanNode[30].byFanNumber = 5;
	m_FanCount.m_FanNode[30].Check = Check030;
	m_FanCount.m_FanNode[30].byFanType = 30;

	strncpy(m_FanCount.m_FanNode[31].szFanName, "至尊豪华七对", MAX_FAN_NAME);
	m_FanCount.m_FanNode[31].bCheck = TRUE;
	m_FanCount.m_FanNode[31].bFan = FALSE;
	m_FanCount.m_FanNode[31].byFanNumber = 4;
	m_FanCount.m_FanNode[31].Check = Check031;
	m_FanCount.m_FanNode[31].byFanType = 31;

	strncpy(m_FanCount.m_FanNode[32].szFanName, "清至尊豪华七对", MAX_FAN_NAME);
	m_FanCount.m_FanNode[32].bCheck = TRUE;
	m_FanCount.m_FanNode[32].bFan = FALSE;
	m_FanCount.m_FanNode[32].byFanNumber = 6;
	m_FanCount.m_FanNode[32].Check = Check032;
	m_FanCount.m_FanNode[32].byFanType = 32;

	strncpy(m_FanCount.m_FanNode[33].szFanName, "捉五魁", MAX_FAN_NAME);
	m_FanCount.m_FanNode[33].bCheck = TRUE;
	m_FanCount.m_FanNode[33].bFan = FALSE;
	m_FanCount.m_FanNode[33].byFanNumber = 2;
	m_FanCount.m_FanNode[33].Check = Check033;
	m_FanCount.m_FanNode[33].byFanType = 33;

	strncpy(m_FanCount.m_FanNode[34].szFanName, "十三幺", MAX_FAN_NAME);
	m_FanCount.m_FanNode[34].bCheck = TRUE;
	m_FanCount.m_FanNode[34].bFan = FALSE;
	m_FanCount.m_FanNode[34].byFanNumber = 4;
	m_FanCount.m_FanNode[34].Check = Check034;
	m_FanCount.m_FanNode[34].byFanType = 34;

	strncpy(m_FanCount.m_FanNode[35].szFanName, "清一色一条龙", MAX_FAN_NAME);
	m_FanCount.m_FanNode[35].bCheck = TRUE;
	m_FanCount.m_FanNode[35].bFan = FALSE;
	m_FanCount.m_FanNode[35].byFanNumber = 3;
	m_FanCount.m_FanNode[35].Check = Check035;
	m_FanCount.m_FanNode[35].byFanType = 35;

	strncpy(m_FanCount.m_FanNode[36].szFanName, "杠上杠", MAX_FAN_NAME);
	m_FanCount.m_FanNode[36].bCheck = TRUE;
	m_FanCount.m_FanNode[36].bFan = FALSE;
	m_FanCount.m_FanNode[36].byFanNumber = 2;
	m_FanCount.m_FanNode[36].Check = Check036;
	m_FanCount.m_FanNode[36].byFanType = 36;

	strncpy(m_FanCount.m_FanNode[37].szFanName, "素胡", MAX_FAN_NAME);
	m_FanCount.m_FanNode[37].bCheck = TRUE;
	m_FanCount.m_FanNode[37].bFan = FALSE;
	m_FanCount.m_FanNode[37].byFanNumber = 2;
	m_FanCount.m_FanNode[37].Check = Check037;
	m_FanCount.m_FanNode[37].byFanType = 37;

	strncpy(m_FanCount.m_FanNode[38].szFanName, "捉五魁", MAX_FAN_NAME);
	m_FanCount.m_FanNode[38].bCheck = TRUE;
	m_FanCount.m_FanNode[38].bFan = FALSE;
	m_FanCount.m_FanNode[38].byFanNumber = 2;
	m_FanCount.m_FanNode[38].Check = Check038;
	m_FanCount.m_FanNode[38].byFanType = 38;

	strncpy(m_FanCount.m_FanNode[39].szFanName, "一条龙", MAX_FAN_NAME);
	m_FanCount.m_FanNode[39].bCheck = TRUE;
	m_FanCount.m_FanNode[39].bFan = FALSE;
	m_FanCount.m_FanNode[39].byFanNumber = 4;
	m_FanCount.m_FanNode[39].Check = Check039;
	m_FanCount.m_FanNode[39].byFanType = 39;

	strncpy(m_FanCount.m_FanNode[40].szFanName, "七小对", MAX_FAN_NAME);
	m_FanCount.m_FanNode[40].bCheck = TRUE;
	m_FanCount.m_FanNode[40].bFan = FALSE;
	m_FanCount.m_FanNode[40].byFanNumber = 2;
	m_FanCount.m_FanNode[40].Check = Check040;
	m_FanCount.m_FanNode[40].byFanType = 40;

	strncpy(m_FanCount.m_FanNode[41].szFanName, "豪华七对", MAX_FAN_NAME);
	m_FanCount.m_FanNode[41].bCheck = TRUE;
	m_FanCount.m_FanNode[41].bFan = FALSE;
	m_FanCount.m_FanNode[41].byFanNumber = 4;
	m_FanCount.m_FanNode[41].Check = Check041;
	m_FanCount.m_FanNode[41].byFanType = 41;

	strncpy(m_FanCount.m_FanNode[42].szFanName, "超级豪华七对", MAX_FAN_NAME);
	m_FanCount.m_FanNode[42].bCheck = TRUE;
	m_FanCount.m_FanNode[42].bFan = FALSE;
	m_FanCount.m_FanNode[42].byFanNumber = 8;
	m_FanCount.m_FanNode[42].Check = Check042;
	m_FanCount.m_FanNode[42].byFanType = 42;

	strncpy(m_FanCount.m_FanNode[43].szFanName, "至尊豪华七对", MAX_FAN_NAME);
	m_FanCount.m_FanNode[43].bCheck = TRUE;
	m_FanCount.m_FanNode[43].bFan = FALSE;
	m_FanCount.m_FanNode[43].byFanNumber = 16;
	m_FanCount.m_FanNode[43].Check = Check043;
	m_FanCount.m_FanNode[43].byFanType = 43;

	strncpy(m_FanCount.m_FanNode[44].szFanName, "混钓", MAX_FAN_NAME);
	m_FanCount.m_FanNode[44].bCheck = TRUE;
	m_FanCount.m_FanNode[44].bFan = FALSE;
	m_FanCount.m_FanNode[44].byFanNumber = 2;
	m_FanCount.m_FanNode[44].Check = Check044;
	m_FanCount.m_FanNode[44].byFanType = 44;

	strncpy(m_FanCount.m_FanNode[45].szFanName, "混钓混", MAX_FAN_NAME);
	m_FanCount.m_FanNode[45].bCheck = TRUE;
	m_FanCount.m_FanNode[45].bFan = FALSE;
	m_FanCount.m_FanNode[45].byFanNumber = 4;
	m_FanCount.m_FanNode[45].Check = Check045;
	m_FanCount.m_FanNode[45].byFanType = 45;

	strncpy(m_FanCount.m_FanNode[46].szFanName, "碰碰胡", MAX_FAN_NAME);
	m_FanCount.m_FanNode[46].bCheck = TRUE;
	m_FanCount.m_FanNode[46].bFan = FALSE;
	m_FanCount.m_FanNode[46].byFanNumber = 2;
	m_FanCount.m_FanNode[46].Check = Check046;
	m_FanCount.m_FanNode[46].byFanType = 46;

	strncpy(m_FanCount.m_FanNode[47].szFanName, "清一色", MAX_FAN_NAME);
	m_FanCount.m_FanNode[47].bCheck = TRUE;
	m_FanCount.m_FanNode[47].bFan = FALSE;
	m_FanCount.m_FanNode[47].byFanNumber = 2;
	m_FanCount.m_FanNode[47].Check = Check047;
	m_FanCount.m_FanNode[47].byFanType = 47;

	strncpy(m_FanCount.m_FanNode[48].szFanName, "十三幺", MAX_FAN_NAME);
	m_FanCount.m_FanNode[48].bCheck = TRUE;
	m_FanCount.m_FanNode[48].bFan = FALSE;
	m_FanCount.m_FanNode[48].byFanNumber = 10;
	m_FanCount.m_FanNode[48].Check = Check048;
	m_FanCount.m_FanNode[48].byFanType = 48;

	strncpy(m_FanCount.m_FanNode[49].szFanName, "混悠", MAX_FAN_NAME);
	m_FanCount.m_FanNode[49].bCheck = TRUE;
	m_FanCount.m_FanNode[49].bFan = FALSE;
	m_FanCount.m_FanNode[49].byFanNumber = 2;
	m_FanCount.m_FanNode[49].Check = Check049;
	m_FanCount.m_FanNode[49].byFanType = 49;

	strncpy(m_FanCount.m_FanNode[51].szFanName, "本混龙", MAX_FAN_NAME);
	m_FanCount.m_FanNode[51].bCheck = TRUE;
	m_FanCount.m_FanNode[51].bFan = FALSE;
	m_FanCount.m_FanNode[51].byFanNumber = 4;
	m_FanCount.m_FanNode[51].Check = Check051;
	m_FanCount.m_FanNode[51].byFanType = 51;

	strncpy(m_FanCount.m_FanNode[52].szFanName, "海底炮", MAX_FAN_NAME);
	m_FanCount.m_FanNode[52].bCheck = TRUE;
	m_FanCount.m_FanNode[52].bFan = FALSE;
	m_FanCount.m_FanNode[52].byFanNumber = 2;
	m_FanCount.m_FanNode[52].Check = Check052;
	m_FanCount.m_FanNode[52].byFanType = 52;

	strncpy(m_FanCount.m_FanNode[53].szFanName, "天听", MAX_FAN_NAME);
	m_FanCount.m_FanNode[53].bCheck = TRUE;
	m_FanCount.m_FanNode[53].bFan = FALSE;
	m_FanCount.m_FanNode[53].byFanNumber = 4;
	m_FanCount.m_FanNode[53].Check = Check053;
	m_FanCount.m_FanNode[53].byFanType = 53;

	strncpy(m_FanCount.m_FanNode[54].szFanName, "地听", MAX_FAN_NAME);
	m_FanCount.m_FanNode[54].bCheck = TRUE;
	m_FanCount.m_FanNode[54].bFan = FALSE;
	m_FanCount.m_FanNode[54].byFanNumber = 4;
	m_FanCount.m_FanNode[54].Check = Check054;
	m_FanCount.m_FanNode[54].byFanType = 54;

	strncpy(m_FanCount.m_FanNode[55].szFanName, "潇洒", MAX_FAN_NAME);
	m_FanCount.m_FanNode[55].bCheck = TRUE;
	m_FanCount.m_FanNode[55].bFan = FALSE;
	m_FanCount.m_FanNode[55].byFanNumber = 4;
	m_FanCount.m_FanNode[55].Check = Check055;
	m_FanCount.m_FanNode[55].byFanType = 55;

	strncpy(m_FanCount.m_FanNode[56].szFanName, "卡五星", MAX_FAN_NAME);
	m_FanCount.m_FanNode[56].bCheck = TRUE;
	m_FanCount.m_FanNode[56].bFan = FALSE;
	m_FanCount.m_FanNode[56].byFanNumber = 2;
	m_FanCount.m_FanNode[56].Check = Check056;
	m_FanCount.m_FanNode[56].byFanType = 56;

	strncpy(m_FanCount.m_FanNode[57].szFanName, "四混胡", MAX_FAN_NAME);
	m_FanCount.m_FanNode[57].bCheck = TRUE;
	m_FanCount.m_FanNode[57].bFan = FALSE;
	m_FanCount.m_FanNode[57].byFanNumber = 2;
	m_FanCount.m_FanNode[57].Check = Check057;
	m_FanCount.m_FanNode[57].byFanType = 57;

	strncpy(m_FanCount.m_FanNode[58].szFanName, "风摸", MAX_FAN_NAME);
	m_FanCount.m_FanNode[58].bCheck = TRUE;
	m_FanCount.m_FanNode[58].bFan = FALSE;
	m_FanCount.m_FanNode[58].byFanNumber = 2;
	m_FanCount.m_FanNode[58].Check = Check058;
	m_FanCount.m_FanNode[58].byFanType = 58;

	strncpy(m_FanCount.m_FanNode[59].szFanName, "断门", MAX_FAN_NAME);
	m_FanCount.m_FanNode[59].bCheck = TRUE;
	m_FanCount.m_FanNode[59].bFan = FALSE;
	m_FanCount.m_FanNode[59].byFanNumber = 1;
	m_FanCount.m_FanNode[59].Check = Check059;
	m_FanCount.m_FanNode[59].byFanType = 59;

	strncpy(m_FanCount.m_FanNode[60].szFanName, "单吊胡", MAX_FAN_NAME);
	m_FanCount.m_FanNode[60].bCheck = TRUE;
	m_FanCount.m_FanNode[60].bFan = FALSE;
	m_FanCount.m_FanNode[60].byFanNumber = 1;
	m_FanCount.m_FanNode[60].Check = Check060;
	m_FanCount.m_FanNode[60].byFanType = 60;

	strncpy(m_FanCount.m_FanNode[61].szFanName, "幺九扑", MAX_FAN_NAME);
	m_FanCount.m_FanNode[61].bCheck = TRUE;
	m_FanCount.m_FanNode[61].bFan = FALSE;
	m_FanCount.m_FanNode[61].byFanNumber = 1;
	m_FanCount.m_FanNode[61].Check = Check061;
	m_FanCount.m_FanNode[61].byFanType = 61;

	strncpy(m_FanCount.m_FanNode[62].szFanName, "暗卡", MAX_FAN_NAME);
	m_FanCount.m_FanNode[62].bCheck = TRUE;
	m_FanCount.m_FanNode[62].bFan = FALSE;
	m_FanCount.m_FanNode[62].byFanNumber = 1;
	m_FanCount.m_FanNode[62].Check = Check062;
	m_FanCount.m_FanNode[62].byFanType = 62;

	strncpy(m_FanCount.m_FanNode[63].szFanName, "十三不靠", MAX_FAN_NAME);
	m_FanCount.m_FanNode[63].bCheck = TRUE;
	m_FanCount.m_FanNode[63].bFan = FALSE;
	m_FanCount.m_FanNode[63].byFanNumber = 2;
	m_FanCount.m_FanNode[63].Check = Check063;
	m_FanCount.m_FanNode[63].byFanType = 63;

	strncpy(m_FanCount.m_FanNode[64].szFanName, "字一色", MAX_FAN_NAME);
	m_FanCount.m_FanNode[64].bCheck	= TRUE;
	m_FanCount.m_FanNode[64].bFan = FALSE;
	m_FanCount.m_FanNode[64].byFanNumber = 8;
	m_FanCount.m_FanNode[64].Check = Check064;
	m_FanCount.m_FanNode[64].byFanType = 64;

	strncpy(m_FanCount.m_FanNode[65].szFanName, "混一色", MAX_FAN_NAME);
	m_FanCount.m_FanNode[65].bCheck	= TRUE;
	m_FanCount.m_FanNode[65].bFan = FALSE;
	m_FanCount.m_FanNode[65].byFanNumber = 2;
	m_FanCount.m_FanNode[65].Check = Check065;
	m_FanCount.m_FanNode[65].byFanType = 65;

	strncpy(m_FanCount.m_FanNode[66].szFanName, "中发白顺子", MAX_FAN_NAME);
	m_FanCount.m_FanNode[66].bCheck = TRUE;
	m_FanCount.m_FanNode[66].bFan = FALSE;
	m_FanCount.m_FanNode[66].byFanNumber = 1;
	m_FanCount.m_FanNode[66].Check = Check066;
	m_FanCount.m_FanNode[66].byFanType = 66;

	strncpy(m_FanCount.m_FanNode[67].szFanName, "风扑", MAX_FAN_NAME);
	m_FanCount.m_FanNode[67].bCheck = TRUE;
	m_FanCount.m_FanNode[67].bFan = FALSE;
	m_FanCount.m_FanNode[67].byFanNumber = 1;
	m_FanCount.m_FanNode[67].Check = Check067;
	m_FanCount.m_FanNode[67].byFanType = 67;

	strncpy(m_FanCount.m_FanNode[68].szFanName, "将扑", MAX_FAN_NAME);
	m_FanCount.m_FanNode[68].bCheck = TRUE;
	m_FanCount.m_FanNode[68].bFan = FALSE;
	m_FanCount.m_FanNode[68].byFanNumber = 1;
	m_FanCount.m_FanNode[68].Check = Check068;
	m_FanCount.m_FanNode[68].byFanType = 68;

	strncpy(m_FanCount.m_FanNode[69].szFanName, "牛逼叫", MAX_FAN_NAME);
	m_FanCount.m_FanNode[69].bCheck = TRUE;
	m_FanCount.m_FanNode[69].bFan = FALSE;
	m_FanCount.m_FanNode[69].byFanNumber = 1;
	m_FanCount.m_FanNode[69].Check = Check069;
	m_FanCount.m_FanNode[69].byFanType = 69;

	strncpy(m_FanCount.m_FanNode[70].szFanName, "小三元", MAX_FAN_NAME);
	m_FanCount.m_FanNode[70].bCheck = TRUE;
	m_FanCount.m_FanNode[70].bFan = FALSE;
	m_FanCount.m_FanNode[70].byFanNumber = 4;
	m_FanCount.m_FanNode[70].Check = Check070;
	m_FanCount.m_FanNode[70].byFanType = 70;

	strncpy(m_FanCount.m_FanNode[71].szFanName, "大三元", MAX_FAN_NAME);
	m_FanCount.m_FanNode[71].bCheck = TRUE;
	m_FanCount.m_FanNode[71].bFan = FALSE;
	m_FanCount.m_FanNode[71].byFanNumber = 8;
	m_FanCount.m_FanNode[71].Check = Check071;
	m_FanCount.m_FanNode[71].byFanType = 71;

	strncpy(m_FanCount.m_FanNode[72].szFanName, "明四归", MAX_FAN_NAME); // 全频道
	m_FanCount.m_FanNode[72].bCheck = TRUE;
	m_FanCount.m_FanNode[72].bFan = FALSE;
	m_FanCount.m_FanNode[72].byFanNumber = 2;
	m_FanCount.m_FanNode[72].Check = Check072;
	m_FanCount.m_FanNode[72].byFanType = 72;

	strncpy(m_FanCount.m_FanNode[73].szFanName, "暗四归", MAX_FAN_NAME); // 全频道
	m_FanCount.m_FanNode[73].bCheck = TRUE;
	m_FanCount.m_FanNode[73].bFan = FALSE;
	m_FanCount.m_FanNode[73].byFanNumber = 4;
	m_FanCount.m_FanNode[73].Check = Check073;
	m_FanCount.m_FanNode[73].byFanType = 73;

	strncpy(m_FanCount.m_FanNode[74].szFanName, "明四归", MAX_FAN_NAME); // 半频道
	m_FanCount.m_FanNode[74].bCheck = TRUE;
	m_FanCount.m_FanNode[74].bFan = FALSE;
	m_FanCount.m_FanNode[74].byFanNumber = 2;
	m_FanCount.m_FanNode[74].Check = Check074;
	m_FanCount.m_FanNode[74].byFanType = 74;

	strncpy(m_FanCount.m_FanNode[75].szFanName, "暗四归", MAX_FAN_NAME); // 半频道
	m_FanCount.m_FanNode[75].bCheck = TRUE;
	m_FanCount.m_FanNode[75].bFan = FALSE;
	m_FanCount.m_FanNode[75].byFanNumber = 4;
	m_FanCount.m_FanNode[75].Check = Check075;
	m_FanCount.m_FanNode[75].byFanType = 75;

	strncpy(m_FanCount.m_FanNode[76].szFanName, "夹胡", MAX_FAN_NAME); // 夹胡
	m_FanCount.m_FanNode[76].bCheck = TRUE;
	m_FanCount.m_FanNode[76].bFan = FALSE;
	m_FanCount.m_FanNode[76].byFanNumber = 4;
	m_FanCount.m_FanNode[76].Check = Check076;
	m_FanCount.m_FanNode[76].byFanType = 76;

	strncpy(m_FanCount.m_FanNode[77].szFanName, "双清", MAX_FAN_NAME);
	m_FanCount.m_FanNode[77].bCheck = TRUE;
	m_FanCount.m_FanNode[77].bFan = FALSE;
	m_FanCount.m_FanNode[77].byFanNumber = 20;
	m_FanCount.m_FanNode[77].Check = Check077;
	m_FanCount.m_FanNode[77].byFanType = 77;

	strncpy(m_FanCount.m_FanNode[78].szFanName, "龙七对", MAX_FAN_NAME);
	m_FanCount.m_FanNode[78].bCheck = TRUE;
	m_FanCount.m_FanNode[78].bFan = FALSE;
	m_FanCount.m_FanNode[78].byFanNumber = 20;
	m_FanCount.m_FanNode[78].Check = Check078;
	m_FanCount.m_FanNode[78].byFanType = 78;

	strncpy(m_FanCount.m_FanNode[79].szFanName, "清龙背", MAX_FAN_NAME);
	m_FanCount.m_FanNode[79].bCheck = TRUE;
	m_FanCount.m_FanNode[79].bFan = FALSE;
	m_FanCount.m_FanNode[79].byFanNumber = 30;
	m_FanCount.m_FanNode[79].Check = Check079;
	m_FanCount.m_FanNode[79].byFanType = 79;

	strncpy(m_FanCount.m_FanNode[80].szFanName, "夹胡", MAX_FAN_NAME); // 夹胡
	m_FanCount.m_FanNode[80].bCheck = TRUE;
	m_FanCount.m_FanNode[80].bFan = FALSE;
	m_FanCount.m_FanNode[80].byFanNumber = 2;
	m_FanCount.m_FanNode[80].Check = Check080;
	m_FanCount.m_FanNode[80].byFanType = 80;

	strncpy(m_FanCount.m_FanNode[81].szFanName, "对宝", MAX_FAN_NAME); // 夹胡
	m_FanCount.m_FanNode[81].bCheck = TRUE;
	m_FanCount.m_FanNode[81].bFan = FALSE;
	m_FanCount.m_FanNode[81].byFanNumber = 2;
	m_FanCount.m_FanNode[81].Check = Check081;
	m_FanCount.m_FanNode[81].byFanType = 81;

	strncpy(m_FanCount.m_FanNode[82].szFanName, "三清", MAX_FAN_NAME); // 三清
	m_FanCount.m_FanNode[82].bCheck = TRUE;
	m_FanCount.m_FanNode[82].bFan = FALSE;
	m_FanCount.m_FanNode[82].byFanNumber = 2;
	m_FanCount.m_FanNode[82].Check = Check082;
	m_FanCount.m_FanNode[82].byFanType = 82;

	strncpy(m_FanCount.m_FanNode[83].szFanName, "四清", MAX_FAN_NAME); // 四清
	m_FanCount.m_FanNode[83].bCheck = TRUE;
	m_FanCount.m_FanNode[83].bFan = FALSE;
	m_FanCount.m_FanNode[83].byFanNumber = 2;
	m_FanCount.m_FanNode[83].Check = Check083;
	m_FanCount.m_FanNode[83].byFanType = 83;

	strncpy(m_FanCount.m_FanNode[84].szFanName, "三清夹五", MAX_FAN_NAME); // 三清夹五
	m_FanCount.m_FanNode[84].bCheck = TRUE;
	m_FanCount.m_FanNode[84].bFan = FALSE;
	m_FanCount.m_FanNode[84].byFanNumber = 2;
	m_FanCount.m_FanNode[84].Check = Check084;
	m_FanCount.m_FanNode[84].byFanType = 84;

	strncpy(m_FanCount.m_FanNode[84].szFanName, "三清夹五", MAX_FAN_NAME); // 三清夹五
	m_FanCount.m_FanNode[84].bCheck = TRUE;
	m_FanCount.m_FanNode[84].bFan = FALSE;
	m_FanCount.m_FanNode[84].byFanNumber = 2;
	m_FanCount.m_FanNode[84].Check = Check084;
	m_FanCount.m_FanNode[84].byFanType = 84;

	strncpy(m_FanCount.m_FanNode[85].szFanName, "摸宝", MAX_FAN_NAME); // 摸宝
	m_FanCount.m_FanNode[85].bCheck = TRUE;
	m_FanCount.m_FanNode[85].bFan = FALSE;
	m_FanCount.m_FanNode[85].byFanNumber = 2;
	m_FanCount.m_FanNode[85].Check = Check085;
	m_FanCount.m_FanNode[85].byFanType = 85;
}

CMJFun::~CMJFun()
{
}

//碰碰胡
BOOL CMJFun::CheckIsTripletsHu(CTiles tilesHand)
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
			if (CheckIsTripletsHu(TilesTemp))
			{
				return TRUE;
			}
		}
	}

	return FALSE;
}

// 无癞子手牌
BOOL CMJFun::CheckIsTripletsHuLaiZi(CTiles &tilesHand, int nLaiZiCount)
{
	int AllLength = tilesHand.nCurrentLength + nLaiZiCount;
	// int nTempLength = 14;
	if (AllLength < 2 
		// || AllLength > nTempLength 
		|| AllLength % 3 != 2)
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

	tilesHand.Sort();
	int i;
	CTiles TilesTemp;
	int nLaiziLastCount = 0;
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
		// 正常情况
		if (TilesTriplet.IsSubSet(tilesHand))
		{
			TilesTemp.DelTiles(TilesTriplet);
			nLaiziLastCount = nLaiZiCount;
			if (CheckIsTripletsHuLaiZi(TilesTemp, nLaiziLastCount))
			{
				return TRUE;
			}
		}
		// 2个
		else if (TilesTripletTwo.IsSubSet(tilesHand) && nLaiZiCount >= 1)
		{
			TilesTemp.DelTiles(TilesTripletTwo);
			nLaiziLastCount = nLaiZiCount - 1;
			if (CheckIsTripletsHuLaiZi(TilesTemp, nLaiziLastCount))
			{
				return TRUE;
			}
		}
		else if (nLaiZiCount >= 2)
		{
			TilesTemp.DelTile(tilesHand.tile[i]);
			nLaiziLastCount = nLaiZiCount - 2;
			if (CheckIsTripletsHuLaiZi(TilesTemp, nLaiziLastCount))
			{
				return TRUE;
			}
		}
	}

	return FALSE;
}

BOOL CMJFun::CheckIsOneColor(CTiles tiles) // 检查是否清一色
{
	if (1 > tiles.nCurrentLength)
	{
		//printf("====CheckIsOneColor=1 >=\n");
		return FALSE;
	}

	int nType = tiles.tile[0] / 10; // 花色
	// printf("====CheckIsOneColor=1 >=%d=====%d\n", nType, tiles.tile[0]);
	for (int i = 1; i < tiles.nCurrentLength; i++)
	{
		if (tiles.tile[i] / 10 != nType)
		{
			// printf("====CheckIsOneColor= 10 !=%d===i==%d..==%d \n", tiles.tile[i],i, tiles.tile[i] / 10);
			return FALSE;
		}
	}

	return TRUE;
}

BOOL CMJFun::CheckIsAllPairs(CTiles tiles) // 检查是否都是对子
{
	CTiles tilesTemp;
	tilesTemp.ReleaseAll();
	tilesTemp.AddTiles(tiles);
	tilesTemp.Sort();
	if (tilesTemp.nCurrentLength % 2)
		return FALSE;
	for (int i = 0; i < (tilesTemp.nCurrentLength / 2); i++)
	{
		if (tilesTemp.tile[i * 2 + 1] != tilesTemp.tile[i * 2])
		{
			return FALSE;
		}
	}
	return TRUE;
}

BOOL CMJFun::CheckIs19Hu(CTiles tilesHand) // 检查是否幺九胡
{
	if (tilesHand.nCurrentLength < 2 
		// || tilesHand.nCurrentLength > 14 
		|| tilesHand.nCurrentLength % 3 != 2)
	{
		return FALSE;
	}

	if (tilesHand.nCurrentLength == 2)
	{
		if (tilesHand.tile[0] != tilesHand.tile[1])
		{
			return FALSE;
		}
		// 检查将要不是字牌
		if (tilesHand.tile[0] > TILE_BALL_9)
		{
			return FALSE;
		}
		if ((tilesHand.tile[0] % 10 != 1) && (tilesHand.tile[0] % 10 != 9))
		{
			return FALSE;
		}
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
		if (((1 == tilesHand.tile[i] % 10) || (9 == (tilesHand.tile[i] + 2) % 10)) && tilesHand.IsHave(tilesHand.tile[i] + 1) && tilesHand.IsHave(tilesHand.tile[i] + 2))
		{
			TilesTemp.ReleaseAll();
			TilesTemp.AddTiles(tilesHand);

			TilesTemp.DelTile(tilesHand.tile[i]);
			TilesTemp.DelTile(tilesHand.tile[i] + 1);
			TilesTemp.DelTile(tilesHand.tile[i] + 2);
			if (CheckIs19Hu(TilesTemp))
			{
				return TRUE;
			}
		}
		else // 检查刻子
		{
			if (tilesHand.tile[i] % 10 == 1 || tilesHand.tile[i] % 10 == 9)
			{
				CTiles temp;
				temp.ReleaseAll();
				temp.AddTile(tilesHand.tile[i]);
				temp.AddTile(tilesHand.tile[i]);
				temp.AddTile(tilesHand.tile[i]);
				if (temp.IsSubSet(tilesHand))
				{
					TilesTemp.ReleaseAll();
					TilesTemp.AddTiles(tilesHand);
					TilesTemp.DelTile(tilesHand.tile[i]);
					TilesTemp.DelTile(tilesHand.tile[i]);
					TilesTemp.DelTile(tilesHand.tile[i]);
					if (CheckIs19Hu(TilesTemp))
					{
						return TRUE;
					}
				}
			}
		}
	}
	// 不检查刻子

	return FALSE;
}

BOOL CMJFun::CheckIsHunColor(CTiles tiles)	//检查是混一色
{
	if(tiles.nCurrentLength < 2
		// || tiles.nCurrentLength < 14
		|| tiles.nCurrentLength % 3 != 2)
    {
        return FALSE;
    }

	tiles.Sort();
	if(tiles.tile[0] > TILE_BALL_9)
	{
		// 全是字
		return FALSE;
	}
	if(tiles.tile[tiles.nCurrentLength - 1] <= TILE_BALL_9)
	{
		// 没有字
		return FALSE;
	}
	int nType = tiles.tile[0] / 10;	// 花色

	
	CTiles tilesGood;
	int i, j;
	for(i = 0; i < 4; i++)
	{
		for(j = 0; j < 9; j++)
		{
			tilesGood.AddTile(TILE_CHAR_1 + nType * 10 + j);
		}
		for(j = 0; j < 7; j++)
		{
			tilesGood.AddTile(TILE_EAST + j);
		}
	}

	if(!tiles.IsSubSet(tilesGood))
	{
		return FALSE;
	}

	return TRUE;
}

//传过来的tilesHand是无赖子手牌
BOOL CMJFun::CheckWin7PairLaiZi(CTiles &tilesHand, int nLaiZiCount)
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
	// m_nFourCount = 0;
	// int templaizi = nLaiZiCount;
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
	// 			for (int i = 0; i < 6; i++)
	// 			{
	// 				if (tilesHand.tile[i * 2] == tilesHand.tile[i * 2 + 1] && tilesHand.tile[i * 2] == tilesHand.tile[i * 2 + 2] && tilesHand.tile[i * 2] == tilesHand.tile[i * 2 + 3])
	// 				{
	// 					m_nFourCount++;
	// 				}
	// 			}
	// 		}
	// 	}
	// 	return bResult;
	// }
	// else
	// {
	// 	tilesHandnolaizi.Sort();
	// 	// 4个的情况
	// 	CTiles tempFour;
	// 	tempFour.ReleaseAll();
	// 	tempFour.AddTiles(tilesHandnolaizi);
	// 	for (int i = 0; i < tilesHandnolaizi.nCurrentLength - 3; i++)
	// 	{
	// 		if (tilesHandnolaizi.tile[i] == tilesHandnolaizi.tile[i + 1] && tilesHandnolaizi.tile[i] == tilesHandnolaizi.tile[i + 2] && tilesHandnolaizi.tile[i] == tilesHandnolaizi.tile[i + 3])
	// 		{
	// 			nEqualCardsNum = nEqualCardsNum + 2;
	// 			m_nFourCount++;
	// 			tempFour.DelTile(tilesHandnolaizi.tile[i]);
	// 			tempFour.DelTile(tilesHandnolaizi.tile[i + 1]);
	// 			tempFour.DelTile(tilesHandnolaizi.tile[i + 2]);
	// 			tempFour.DelTile(tilesHandnolaizi.tile[i + 3]);
	// 		}
	// 	}
	// 	// 3个的情况
	// 	CTiles tempThree;
	// 	tempThree.ReleaseAll();
	// 	tempThree.AddTiles(tempFour);
	// 	for (int m = 0; m < tempFour.nCurrentLength - 2; m++)
	// 	{
	// 		if (tempFour.tile[m] == tempFour.tile[m + 1] && tempFour.tile[m] == tempFour.tile[m + 2])
	// 		{
	// 			nEqualCardsNum++;
	// 			if (templaizi >= 1)
	// 			{
	// 				templaizi--;
	// 				m_nFourCount++;
	// 				nEqualCardsNum++;
	// 				tempThree.DelTile(tempFour.tile[m + 2]);
	// 			}
	// 			tempThree.DelTile(tempFour.tile[m]);
	// 			tempThree.DelTile(tempFour.tile[m + 1]);
	// 		}
	// 	}
	// 	// 2个的情况
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
	// 			// 				if (templaizi >= 2)
	// 			// 				{
	// 			// 					templaizi= templaizi-2;
	// 			// 					m_nFourCount++;
	// 			// 				}
	// 		}
	// 	}
	// 	if (nEqualCardsNum == 6 && templaizi >= 2)
	// 	{
	// 		nEqualCardsNum++;
	// 		m_nFourCount++;
	// 		return TRUE;
	// 	}
	// 	else if (nEqualCardsNum == 5 && templaizi == 3)
	// 	{
	// 		nEqualCardsNum = nEqualCardsNum + 1;
	// 		m_nFourCount = m_nFourCount + 1;
	// 		return TRUE;
	// 	}
	// 	else if (nEqualCardsNum == 5 && templaizi >= 4)
	// 	{
	// 		nEqualCardsNum = nEqualCardsNum + 2;
	// 		m_nFourCount = m_nFourCount + 2;
	// 		return TRUE;
	// 	}
	// 	if (nEqualCardsNum + templaizi >= 7)
	// 	{
	// 		return TRUE;
	// 	}
	// 	else
	// 	{
	// 		return FALSE;
	// 	}
	// }
}

int CMJFun::GetColorTypeCout(CTiles tiles) //获得颜色种数
{
	if (1 > tiles.nCurrentLength)
	{
		return 0;
	}

	int nCount = 1;
	TILE oColorTile = tiles.tile[0] / 10; // 花色
	CTiles ColorTypeTile;
	ColorTypeTile.AddTile(oColorTile);

	for (int i = 1; i < tiles.nCurrentLength; i++)
	{
		oColorTile = tiles.tile[i] / 10; // 花色
		if (!ColorTypeTile.IsHave(oColorTile))
		{
			ColorTypeTile.AddTile(oColorTile);
			nCount++;
		}
	}

	return nCount;
}

//============================================================================

BOOL CMJFun::CheckWinYouJin(CTiles &tilesYouJin, int laizitemp, ENVIRONMENT &env,TILE tileHu)
{

	//手牌中所有癞子牌
	CTiles TilesLaiZi;
	TilesLaiZi.ReleaseAll();
	for (int i = 0; i < 4; i++)
	{
		if (env.byLaiziCards[i] > 0)
		{
			for (int j = 0; j < tilesYouJin.nCurrentLength; j++)
			{
				if (tilesYouJin.tile[j] == env.byLaiziCards[i])
				{
					TilesLaiZi.AddTile(env.byLaiziCards[i]);
				}
			}
		}
	}
	CTiles TilesHandsNoLaiZi; //无癞子手牌
	TilesHandsNoLaiZi.ReleaseAll();
	tilesYouJin.DelTiles(TilesLaiZi);
	TilesHandsNoLaiZi.AddTiles(tilesYouJin);
	//去掉当闲金后的癞子数
	int nNoJiangLaizi = laizitemp - 1;
	//删除胡的那张牌后的手牌

	if (TilesLaiZi.IsHave(tileHu))
	{
		nNoJiangLaizi = nNoJiangLaizi - 1;
	}
	int nMaxNoJiangLength = env.checkWinParam.byMaxHandCardLength - 2;
	CTiles laiziCard;
	CMJFanCounter::CollectLaiziTile(laiziCard, env);
	if (CMJFanCounter::CheckWinNoJiangLaizi(TilesHandsNoLaiZi, laiziCard, nNoJiangLaizi, nMaxNoJiangLength, env.checkWinParam))
	{
		return TRUE;
	}
	return FALSE;
}
void CMJFun::Check000(CMJFanCounter *pCounter) // 平胡
{
	ENVIRONMENT *pEnv = &pCounter->env;
	pCounter->m_FanCount.m_FanNode[0].bFan = TRUE;
}

void CMJFun::Check001(CMJFanCounter *pCounter) // 碰碰胡
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesAll;
	CMJFanCounter::CollectAllTile(tilesAll, *pEnv, chair);
	if (tilesAll.nCurrentLength != pEnv->checkWinParam.byMaxHandCardLength)
	{
		return;
	}
	if (CheckIsTripletsHu(tilesAll))
	{
		pCounter->m_FanCount.m_FanNode[1].bFan = TRUE;
	}
}

void CMJFun::Check002(CMJFanCounter *pCounter) // 清一色
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesAll;
	CMJFanCounter::CollectAllTile(tilesAll, *pEnv, chair);
	if (tilesAll.nCurrentLength != pEnv->checkWinParam.byMaxHandCardLength)
	{
		return;
	}
	if (CheckIsOneColor(tilesAll))
	{

		//沧州清一色不能是风一色
		// if(pEnv->gamestyle == GAME_STYLE_CANGZHOU && tilesAll.tile[0] /10 == 3) 
		if (pEnv->byQYSNoWord && tilesAll.tile[0] /10 == 3)
		{
			return;
		}

		pCounter->m_FanCount.m_FanNode[2].bFan = TRUE;
	}
}

void CMJFun::Check003(CMJFanCounter *pCounter) // 带幺九
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	if (m_bNew19Check)
	{
		for (int i = 0; i < pEnv->bySetCount[chair]; i++)
		{
			switch (pEnv->tSet[chair][i][0])
			{
			case ACTION_COLLECT:
			{
				if (pEnv->tSet[chair][i][1] > TILE_BALL_9)
				{
					return;
				}
				if ((pEnv->tSet[chair][i][1] % 10 != 1) || (pEnv->tSet[chair][i][1] % 10 != 7))
				{
					return;
				}
			}
			break;
			case ACTION_QUADRUPLET_REVEALED:
			case ACTION_QUADRUPLET_CONCEALED:
			case ACTION_TRIPLET:
			{
				if (pEnv->tSet[chair][i][1] > TILE_BALL_9)
				{
					return;
				}
				if ((pEnv->tSet[chair][i][1] % 10 != 1) && (pEnv->tSet[chair][i][1] % 10 != 9))
				{
					return;
				}
			}
			break;
			default:
				break;
			}
		}

		CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	}
	else
	{
		CMJFanCounter::CollectAllTile(tilesHand, *pEnv, chair);
		if (tilesHand.nCurrentLength != pEnv->checkWinParam.byMaxHandCardLength)
		{
			return;
		}
	}
	if (CheckIs19Hu(tilesHand))
	{
		pCounter->m_FanCount.m_FanNode[3].bFan = TRUE;
	}
}

void CMJFun::Check004(CMJFanCounter *pCounter) // 七对子
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	if (tilesHand.nCurrentLength != 14)
	{
		return;
	}

	if (CheckIsAllPairs(tilesHand))
	{
		pCounter->m_FanCount.m_FanNode[4].bFan = TRUE;
	}
}

void CMJFun::Check005(CMJFanCounter *pCounter) // 龙七对
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	if (tilesHand.nCurrentLength != 14)
	{
		return;
	}
	if (!CheckIsAllPairs(tilesHand))
	{
		return;
	}
	tilesHand.Sort();
	CTiles tilesTemp;
	for (int i = 0; i < 14; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
		{
			continue;
		}
		tilesTemp.ReleaseAll();
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		if (tilesTemp.IsSubSet(tilesHand))
		{
			pCounter->m_FanCount.m_FanNode[5].bFan = TRUE;
			pCounter->m_FanCount.m_FanNode[5].byCount++;
		}
	}
}

void CMJFun::Check006(CMJFanCounter *pCounter) // 清对 (清一色碰碰胡）
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectAllTile(tilesHand, *pEnv, chair);
	if (tilesHand.nCurrentLength != pEnv->checkWinParam.byMaxHandCardLength)
	{
		return;
	}
	if (CheckIsOneColor(tilesHand) && CheckIsTripletsHu(tilesHand))
	{
		pCounter->m_FanCount.m_FanNode[6].bFan = TRUE;
	}
}

void CMJFun::Check007(CMJFanCounter *pCounter) // 清七对
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	if (tilesHand.nCurrentLength != 14)
	{
		return;
	}
	if (CheckIsOneColor(tilesHand) && CheckIsAllPairs(tilesHand))
	{
		pCounter->m_FanCount.m_FanNode[7].bFan = TRUE;
		// if (pEnv->gamestyle == GAME_STYLE_258 || pEnv->gamestyle == GAME_STYLE_GEERMU)
		// {
		// 	pCounter->m_FanCount.m_FanNode[7].bFan = TRUE;
		// }
		// else
		// {
		// 	pCounter->m_FanCount.m_FanNode[7].bFan = TRUE;
		// }
	}
}

void CMJFun::Check008(CMJFanCounter *pCounter) // 清幺九
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;

	CMJFanCounter::CollectAllTile(tilesHand, *pEnv, chair);
	if (tilesHand.nCurrentLength != pEnv->checkWinParam.byMaxHandCardLength)
	{
		return;
	}
	if (!CheckIsOneColor(tilesHand))
	{
		return;
	}

	//////////////////////////////////////////////////////////////////////////
	if (m_bNew19Check)
	{
		for (int i = 0; i < pEnv->bySetCount[chair]; i++)
		{
			switch (pEnv->tSet[chair][i][0])
			{
			case ACTION_COLLECT:
			{
				if (pEnv->tSet[chair][i][1] > TILE_BALL_9)
				{
					return;
				}
				if ((pEnv->tSet[chair][i][1] % 10 != 1) || (pEnv->tSet[chair][i][1] % 10 != 7))
				{
					return;
				}
			}
			break;
			case ACTION_QUADRUPLET_REVEALED:
			case ACTION_QUADRUPLET_CONCEALED:
			case ACTION_TRIPLET:
			{
				if (pEnv->tSet[chair][i][1] > TILE_BALL_9)
				{
					return;
				}
				if ((pEnv->tSet[chair][i][1] % 10 != 1) && (pEnv->tSet[chair][i][1] % 10 != 9))
				{
					return;
				}
			}
			break;
			default:
				break;
			}
		}
		tilesHand.ReleaseAll();
		CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	}
	//////////////////////////////////////////////////////////////////////////

	if (CheckIs19Hu(tilesHand))
	{
		pCounter->m_FanCount.m_FanNode[8].bFan = TRUE;
	}
}

void CMJFun::Check009(CMJFanCounter *pCounter) // 将对, 258碰碰胡
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectAllTile(tilesHand, *pEnv, chair);

	int nCardLength = pEnv->checkWinParam.byMaxHandCardLength;
	if (tilesHand.nCurrentLength != nCardLength)
	{
		return;
	}
	if (!CheckIsTripletsHu(tilesHand))
	{
		return;
	}

	int i = 0;
	for (i = 0; i < nCardLength; i++)
	{
		if ((tilesHand.tile[i] % 10 != 2) && (tilesHand.tile[i] % 10 != 5) && (tilesHand.tile[i] % 10 != 8))
		{
			return;
		}
	}
	pCounter->m_FanCount.m_FanNode[9].bFan = TRUE;
}

void CMJFun::Check010(CMJFanCounter *pCounter) // 清龙七对
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	if (tilesHand.nCurrentLength != 14)
	{
		return;
	}
	if (!CheckIsAllPairs(tilesHand))
	{
		return;
	}
	if (!CheckIsOneColor(tilesHand))
	{
		return;
	}
	tilesHand.Sort();
	CTiles tilesTemp;
	for (int i = 0; i < 14; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
		{
			continue;
		}
		tilesTemp.ReleaseAll();
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		if (tilesTemp.IsSubSet(tilesHand))
		{
			pCounter->m_FanCount.m_FanNode[10].bFan = TRUE;
			pCounter->m_FanCount.m_FanNode[10].byCount++;
		}
	}
}

void CMJFun::Check011(CMJFanCounter *pCounter) // 另加番: 杠
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;

	int nGang = 0;
	for (int i = 0; i < pEnv->bySetCount[chair]; i++)
	{
		if (pEnv->tSet[chair][i][0] == ACTION_QUADRUPLET_REVEALED || pEnv->tSet[chair][i][0] == ACTION_QUADRUPLET_CONCEALED)
		{
			nGang++;
		}
	}
	if (nGang)
	{
		pCounter->m_FanCount.m_FanNode[11].bFan = TRUE;
		pCounter->m_FanCount.m_FanNode[11].byCount = nGang;
	}
}

void CMJFun::Check012(CMJFanCounter *pCounter) // 另加番: 根
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectAllTile(tilesHand, *pEnv, chair);
	tilesHand.Sort();
	int nGen = 0;
	CTiles tilesTemp;
	for (int i = 0; i < tilesHand.nCurrentLength; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
			continue;
		tilesTemp.ReleaseAll();
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		if (tilesTemp.IsSubSet(tilesHand))
		{
			nGen++;
		}
	}
	if (nGen)
	{
		pCounter->m_FanCount.m_FanNode[12].bFan = TRUE;
		pCounter->m_FanCount.m_FanNode[12].byCount = nGen;
	}
}

void CMJFun::Check013(CMJFanCounter *pCounter) // 另加番：杠上花
{
	ENVIRONMENT *pEnv = &pCounter->env;
	if (pEnv->byFlag != WIN_GANGDRAW)
	{
		return;
	}
	pCounter->m_FanCount.m_FanNode[13].bFan = TRUE;
}

void CMJFun::Check014(CMJFanCounter *pCounter) // 另加番：杠上炮
{
	ENVIRONMENT *pEnv = &pCounter->env;
	if (pEnv->byFlag != WIN_GANGGIVE)
	{
		return;
	}
	pCounter->m_FanCount.m_FanNode[14].bFan = TRUE;
}

void CMJFun::Check015(CMJFanCounter *pCounter) // 另加番：抢杠胡
{
	ENVIRONMENT *pEnv = &pCounter->env;
	if (pEnv->byFlag != WIN_GANG)
	{
		return;
	}
	pCounter->m_FanCount.m_FanNode[15].bFan = TRUE;
}

// "天胡"，庄家起手自模,条件仅: 第一轮模牌即胡，这里也容许有花而补花的情况。
void CMJFun::Check016(CMJFanCounter *pCounter)
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	int nMaxHandCardLength = pEnv->checkWinParam.byMaxHandCardLength;
	//printf("====Check016==\n");
	if (WIN_SELFDRAW == pEnv->byFlag 
		&& nMaxHandCardLength == pEnv->byHandCount[chair]
		&& pEnv->byDealer == chair)
	{
		for (int i = 0; i < 4; i++)
		{
			if (0 != pEnv->byDoFirstGive[i])
			{
				//printf("====Check016=o0 != pEnv->byDoF=\n");
				return;
			}
		}
		//printf("====Check016=ok=\n");
		pCounter->m_FanCount.m_FanNode[16].bFan = TRUE;
	}
}

// “地胡”，非庄家起手自模,条件仅: 第一轮模牌即胡，这里也容许有花而补花的情况。
void CMJFun::Check017(CMJFanCounter *pCounter)
{
	ENVIRONMENT *pEnv = &pCounter->env;
	//printf("====Check017==\n");
	BYTE chair = pEnv->byChair;
	int nMaxHandCardLength = pEnv->checkWinParam.byMaxHandCardLength;
	if (nMaxHandCardLength == pEnv->byHandCount[chair] 
		&& 0 == pEnv->byDoFirstGive[chair] 
		&& pEnv->byDealer != chair)
	{

		pCounter->m_FanCount.m_FanNode[17].bFan = TRUE;

	}
}

void CMJFun::Check018(CMJFanCounter *pCounter) // 自摸
{
	ENVIRONMENT *pEnv = &pCounter->env;
	if(pEnv->byFlag == WIN_SELFDRAW || pEnv->byFlag == WIN_GANGDRAW)
	{
		pCounter->m_FanCount.m_FanNode[18].bFan = TRUE;
	}

	// ENVIRONMENT *pEnv = &pCounter->env;
	// BYTE chair = pEnv->byChair;
	// if (pEnv->gamestyle == GAME_STYLE_HBTDH 
	// 	|| pEnv->gamestyle == GAME_STYLE_TANGSHAN
	// 	|| pEnv->gamestyle == GAME_STYLE_LANGFANG
	// 	|| pEnv->gamestyle == GAME_STYLE_QINHUANGDAO
	// 	|| pEnv->gamestyle == GAME_STYLE_XINGXIANG
	// 	|| pEnv->gamestyle == GAME_STYLE_CHENGDE)
	// {
	// 	if (pEnv->byFlag != WIN_SELFDRAW && pEnv->byFlag != WIN_GANGDRAW)
	// 	{
	// 		return;
	// 	}
	// 	pCounter->m_FanCount.m_FanNode[18].byFanNumber = 2;
	// }
	// else
	// {
	// 	if (pEnv->byFlag != WIN_SELFDRAW)
	// 	{
	// 		return;
	// 	}
	// }
	// pCounter->m_FanCount.m_FanNode[18].bFan = TRUE;
}

void CMJFun::Check019(CMJFanCounter *pCounter) // 点炮
{
	ENVIRONMENT *pEnv = &pCounter->env;
	if (pEnv->byFlag == WIN_GUN || pEnv->byFlag == WIN_GANGGIVE || pEnv->byFlag == WIN_GANG)
	{
		pCounter->m_FanCount.m_FanNode[19].bFan = TRUE;
	}
	// ENVIRONMENT *pEnv = &pCounter->env;
	// BYTE chair = pEnv->byChair;
	// if (pEnv->gamestyle == GAME_STYLE_TANGSHAN
	// 	|| pEnv->gamestyle == GAME_STYLE_CHENGDE)
	// {
	// 	if (pEnv->byFlag != WIN_GUN && pEnv->byFlag != WIN_GANGGIVE && pEnv->byFlag != WIN_GANG)
	// 	{
	// 		return;
	// 	}
	// }
	// else
	// {
	// 	if (pEnv->byFlag != WIN_GUN)
	// 	{
	// 		return;
	// 	}
	// }
	// pCounter->m_FanCount.m_FanNode[19].bFan = TRUE;
}

// 门清，除了暗杠，没有其他吃碰杠
void CMJFun::Check020(CMJFanCounter *pCounter)
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;

	// 检查拦牌，暗杠不影响
	for (int i = 0; i < pEnv->bySetCount[chair]; i++)
	{
		if (pEnv->tSet[chair][i][0] == ACTION_COLLECT ||
		    pEnv->tSet[chair][i][0] == ACTION_TRIPLET ||
			pEnv->tSet[chair][i][0] == ACTION_QUADRUPLET ||
			pEnv->tSet[chair][i][0] == ACTION_QUADRUPLET_REVEALED)
		{
			return;
		}
	}

	// ok
	pCounter->m_FanCount.m_FanNode[20].bFan = TRUE;
}

void CMJFun::Check021(CMJFanCounter *pCounter) // 边
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	int nLaizi = pEnv->laizi;
	TILE t = pEnv->tLast;
	int nCardLength = pEnv->checkWinParam.byMaxHandCardLength;

	CTiles tilesHand, tilesGood, tilesTemp;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	if (tilesHand.nCurrentLength < 3 || nLaizi > 0)
	{
		return;
	}
	
	// 摸到的牌不是3、7不算边卡吊
	if (t > TILE_BALL_9 || (t % 10 != 3) && (t % 10 != 7))
	{
		return;
	}

	if (t % 10 == 3)
	{
		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t - 2);
		if (!tilesGood.IsSubSet(tilesHand))
		{
			return;
		}
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (!CMJFanCounter::CheckWinNormal(tilesTemp, nCardLength))
		{
			return;
		}

		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t - 1);
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (CMJFanCounter::CheckWinNormal(tilesTemp, nCardLength))
		{
			return;
		}

		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t);
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (CMJFanCounter::CheckWinNormal(tilesTemp, nCardLength))
		{
			return;
		}
	}
	else if (t % 10 == 7)
	{
		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t);
		if (!tilesGood.IsSubSet(tilesHand))
		{
			return;
		}
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (!CMJFanCounter::CheckWinNormal(tilesTemp, nCardLength))
		{
			return;
		}

		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t - 1);
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (CMJFanCounter::CheckWinNormal(tilesTemp, nCardLength))
		{
			return;
		}

		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t - 2);
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (CMJFanCounter::CheckWinNormal(tilesTemp, nCardLength))
		{
			return;
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
		if (CMJFanCounter::CheckWinNormal(tilesTemp, nCardLength))
		{
			return;
		}
	}

	// ok
	pCounter->m_FanCount.m_FanNode[21].bFan = TRUE;
}

//TODO:看看怎么修改1
void CMJFun::Check022(CMJFanCounter *pCounter) // 卡
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	int nLaizi = pEnv->laizi;
	TILE t = pEnv->tLast;
	int nCardLength = pEnv->checkWinParam.byMaxHandCardLength;

	CTiles tilesHand, tilesGood, tilesTemp;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	//lua判断是否需要计算这个番型
	// if (pEnv->gamestyle == GAME_STYLE_PUYANG )
	// {
	// 	//卡张胡
	// 	if (pEnv->bkaAdd != 1)
	// 	{
	// 		return;
	// 	}
	// }

	if ((t % 10 == 1) || (t % 10 == 9))
	{
		return;
	}
	if (tilesHand.nCurrentLength < 3 || nLaizi > 0)
	{
		return;
	}
	if (t > TILE_BALL_9)
	{
		if (pEnv->gamestyle == GAME_STYLE_TANGSHAN)
		{
			if (t != TILE_FA)
			{
				return;
			}
		}
		else
		{
			return;
		}
	}

	tilesGood.ReleaseAll();
	tilesGood.AddCollect(t - 1);
	if (!tilesGood.IsSubSet(tilesHand))
	{
		return;
	}
	tilesTemp.ReleaseAll();
	tilesTemp.AddTiles(tilesHand);
	tilesTemp.DelTiles(tilesGood);
	if (!CMJFanCounter::CheckWinNormal(tilesTemp, nCardLength))
	{
		return;
	}

	if (t % 10 > 2)
	{
		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t - 2);	// t-2, t-1, t
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (CMJFanCounter::CheckWinNormal(tilesTemp, nCardLength))
		{
			return;
		}
	}
	if (t % 10 < 8)
	{
		tilesGood.ReleaseAll();
		tilesGood.AddCollect(t);	// t, t+1, t+2
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (CMJFanCounter::CheckWinNormal(tilesTemp, nCardLength))
		{
			return;
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
		if (CMJFanCounter::CheckWinNormal(tilesTemp, nCardLength))
		{
			return;
		}
	}
	pCounter->m_FanCount.m_FanNode[22].bFan = TRUE;
}

void CMJFun::Check023(CMJFanCounter *pCounter) // 吊
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	int nCardLength = pEnv->checkWinParam.byMaxHandCardLength;

	CTiles tilesHand, tilesGood, tilesTemp;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	TILE t = pEnv->tLast;
	tilesGood.AddTile(t);
	tilesGood.AddTile(t);
	if (!tilesGood.IsSubSet(tilesHand))
	{
		return;
	}
	tilesTemp.AddTiles(tilesHand);
	tilesTemp.DelTiles(tilesGood);
	if (!CMJFanCounter::CheckWinNoJiang(tilesTemp, nCardLength))
	{
		return;
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
		if (CMJFanCounter::CheckWinNormal(tilesTemp, nCardLength))
		{
			return;
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
			if (CMJFanCounter::CheckWinNormal(tilesTemp, nCardLength))
			{
				return;
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
			if (CMJFanCounter::CheckWinNormal(tilesTemp, nCardLength))
			{
				return;
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
			if (CMJFanCounter::CheckWinNormal(tilesTemp, nCardLength))
			{
				return;
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
			if (CMJFanCounter::CheckWinNoJiang(tilesTemp, nCardLength))
			{
				return;
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
			if (CMJFanCounter::CheckWinNoJiang(tilesTemp, nCardLength))
			{
				return;
			}
		}
	}
	pCounter->m_FanCount.m_FanNode[23].bFan = TRUE;
}

void CMJFun::Check024(CMJFanCounter *pCounter) // 庄家
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;

	if (chair != pEnv->byDealer)
	{
		return;
	}
	// ok
	pCounter->m_FanCount.m_FanNode[24].bFan = TRUE;
}

void CMJFun::Check025(CMJFanCounter *pCounter) // 一条龙
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	tilesHand.Sort();
	CTiles tilesTempChar; // 万
	tilesTempChar.ReleaseAll();
	CTiles tilesTempBamboo; // 条
	tilesTempBamboo.ReleaseAll();
	CTiles tilesTempBall; // 筒
	tilesTempBall.ReleaseAll();

	tilesTempChar.AddTile(TILE_CHAR_1);
	tilesTempChar.AddTile(TILE_CHAR_2);
	tilesTempChar.AddTile(TILE_CHAR_3);
	tilesTempChar.AddTile(TILE_CHAR_4);
	tilesTempChar.AddTile(TILE_CHAR_5);
	tilesTempChar.AddTile(TILE_CHAR_6);
	tilesTempChar.AddTile(TILE_CHAR_7);
	tilesTempChar.AddTile(TILE_CHAR_8);
	tilesTempChar.AddTile(TILE_CHAR_9);

	tilesTempBamboo.AddTile(TILE_BAMBOO_1);
	tilesTempBamboo.AddTile(TILE_BAMBOO_2);
	tilesTempBamboo.AddTile(TILE_BAMBOO_3);
	tilesTempBamboo.AddTile(TILE_BAMBOO_4);
	tilesTempBamboo.AddTile(TILE_BAMBOO_5);
	tilesTempBamboo.AddTile(TILE_BAMBOO_6);
	tilesTempBamboo.AddTile(TILE_BAMBOO_7);
	tilesTempBamboo.AddTile(TILE_BAMBOO_8);
	tilesTempBamboo.AddTile(TILE_BAMBOO_9);

	tilesTempBall.AddTile(TILE_BALL_1);
	tilesTempBall.AddTile(TILE_BALL_2);
	tilesTempBall.AddTile(TILE_BALL_3);
	tilesTempBall.AddTile(TILE_BALL_4);
	tilesTempBall.AddTile(TILE_BALL_5);
	tilesTempBall.AddTile(TILE_BALL_6);
	tilesTempBall.AddTile(TILE_BALL_7);
	tilesTempBall.AddTile(TILE_BALL_8);
	tilesTempBall.AddTile(TILE_BALL_9);

	if (tilesTempBall.IsSubSet(tilesHand) || tilesTempBamboo.IsSubSet(tilesHand) || tilesTempChar.IsSubSet(tilesHand))
	{
		// ok
		pCounter->m_FanCount.m_FanNode[25].bFan = TRUE;
	}
}

//TODO:看看怎么修改1
void CMJFun::Check026(CMJFanCounter *pCounter) // 海底捞月
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;

	if (NULL == pEnv)
	{
		return;
	}
	if (pEnv->byFlag != WIN_SELFDRAW && pEnv->byFlag != WIN_GANGDRAW)
	{
		// 非自摸
		return;
	}
	if (pEnv->byHaiDi)
	{
		// ok
		pCounter->m_FanCount.m_FanNode[26].bFan = TRUE;		
	}
	// // 牌墙剩余张数
	// int nLength = pEnv->byTilesLeft;
	// if (pEnv->gamestyle == GAME_STYLE_TANGSHAN)
	// {
	// 	if (nLength == 14)
	// 	{
	// 		pCounter->m_FanCount.m_FanNode[26].byFanNumber = 2;
	// 		pCounter->m_FanCount.m_FanNode[26].bFan = TRUE;
	// 	}
	// }
	// else if (pEnv->gamestyle == GAME_STYLE_QINHUANGDAO)
	// {
	// 	if (nLength < 4)
	// 	{
	// 		pCounter->m_FanCount.m_FanNode[26].byFanNumber = 2;
	// 		pCounter->m_FanCount.m_FanNode[26].bFan = TRUE;
	// 	}
	// }
	// else
	// {
	// 	if (nLength == 0)
	// 	{
	// 		// ok
	// 		pCounter->m_FanCount.m_FanNode[26].bFan = TRUE;
	// 	}
	// }
}

void CMJFun::Check027(CMJFanCounter *pCounter) // 豪华七对
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	tilesHand.Sort();
	if (NULL == pCounter)
	{
		return;
	}
	if (tilesHand.nCurrentLength != 14)
	{
		return;
	}

	if (!CheckIsAllPairs(tilesHand))
	{
		return;
	}
	int nGen = 0;
	CTiles tilesTemp;
	for (int i = 0; i < tilesHand.nCurrentLength; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
		{
			continue;
		}
		tilesTemp.ReleaseAll();
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		if (tilesTemp.IsSubSet(tilesHand))
		{
			nGen++;
		}
	}
	if (nGen)
	{
		pCounter->m_FanCount.m_FanNode[27].bFan = TRUE;
	}
}

void CMJFun::Check028(CMJFanCounter *pCounter) // 清豪华七对
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	tilesHand.Sort();
	if (NULL == pCounter)
	{
		return;
	}
	if (tilesHand.nCurrentLength != 14)
	{
		return;
	}

	if (!CheckIsAllPairs(tilesHand))
	{
		return;
	}
	if (!CheckIsOneColor(tilesHand))
	{
		return;
	}
	int nGen = 0;
	CTiles tilesTemp;
	for (int i = 0; i < tilesHand.nCurrentLength; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
		{
			continue;
		}
		tilesTemp.ReleaseAll();
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		if (tilesTemp.IsSubSet(tilesHand))
		{
			nGen++;
		}
	}
	if (nGen)
	{
		pCounter->m_FanCount.m_FanNode[28].bFan = TRUE;
	}
}

void CMJFun::Check029(CMJFanCounter *pCounter) //超豪华七对
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	tilesHand.Sort();
	if (NULL == pCounter)
	{
		return;
	}
	if (tilesHand.nCurrentLength != 14)
	{
		return;
	}

	if (!CheckIsAllPairs(tilesHand))
	{
		return;
	}

	int nGen = 0;
	CTiles tilesTemp;
	for (int i = 0; i < tilesHand.nCurrentLength; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
		{
			continue;
		}
		tilesTemp.ReleaseAll();
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		if (tilesTemp.IsSubSet(tilesHand))
		{
			nGen++;
		}
	}
	if (nGen >= 2)
	{
		pCounter->m_FanCount.m_FanNode[29].bFan = TRUE;
	}
}

void CMJFun::Check030(CMJFanCounter *pCounter) //清超豪华七对
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	tilesHand.Sort();
	if (NULL == pCounter)
	{
		return;
	}
	if (tilesHand.nCurrentLength != 14)
	{
		return;
	}

	if (!CheckIsAllPairs(tilesHand))
	{
		return;
	}
	if (!CheckIsOneColor(tilesHand))
	{
		return;
	}
	int nGen = 0;
	CTiles tilesTemp;
	for (int i = 0; i < tilesHand.nCurrentLength; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
		{
			continue;
		}
		tilesTemp.ReleaseAll();
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		if (tilesTemp.IsSubSet(tilesHand))
		{
			nGen++;
		}
	}
	if (nGen >= 2)
	{
		pCounter->m_FanCount.m_FanNode[30].bFan = TRUE;
	}
}

void CMJFun::Check031(CMJFanCounter *pCounter) //至尊豪华七对
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	tilesHand.Sort();
	if (NULL == pCounter)
	{
		return;
	}
	if (tilesHand.nCurrentLength != 14)
	{
		return;
	}

	if (!CheckIsAllPairs(tilesHand))
	{
		return;
	}

	int nGen = 0;
	CTiles tilesTemp;
	for (int i = 0; i < tilesHand.nCurrentLength; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
			continue;
		tilesTemp.ReleaseAll();
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		if (tilesTemp.IsSubSet(tilesHand))
		{
			nGen++;
		}
	}
	if (nGen >= 3)
	{
		pCounter->m_FanCount.m_FanNode[31].bFan = TRUE;
	}
}

void CMJFun::Check032(CMJFanCounter *pCounter) //清至尊豪华七对
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	tilesHand.Sort();
	if (NULL == pCounter)
	{
		return;
	}
	if (tilesHand.nCurrentLength != 14)
	{
		return;
	}

	if (!CheckIsAllPairs(tilesHand))
	{
		return;
	}
	if (!CheckIsOneColor(tilesHand))
	{
		return;
	}
	int nGen = 0;
	CTiles tilesTemp;
	for (int i = 0; i < tilesHand.nCurrentLength; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
		{
			continue;
		}
		tilesTemp.ReleaseAll();
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		if (tilesTemp.IsSubSet(tilesHand))
		{
			nGen++;
		}
	}
	if (nGen >= 3)
	{
		pCounter->m_FanCount.m_FanNode[32].bFan = TRUE;
	}
}

void CMJFun::Check033(CMJFanCounter *pCounter) //捉五魁
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	BYTE tLast = pEnv->tLast;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	if (tLast != TILE_CHAR_5)
	{
		// 和的那张牌不是5W
		return;
	}
	if (!tilesHand.IsHave(TILE_CHAR_4) || !tilesHand.IsHave(TILE_CHAR_6))
	{
		// 手牌中没有4W或6W则不能够成捉5W
		return;
	}
	// ok
	pCounter->m_FanCount.m_FanNode[33].bFan = TRUE;
}

void CMJFun::Check034(CMJFanCounter *pCounter) //十三幺
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	if (tilesHand.nCurrentLength != 14)
	{
		return;
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

	if (!tilesAll.IsSubSet(tilesHand))
	{
		return;
	}

	tilesHand.DelTiles(tilesAll);
	if (!tilesHand.IsSubSet(tilesAll))
	{
		return;
	}

	// ok
	pCounter->m_FanCount.m_FanNode[34].bFan = TRUE;
}

void CMJFun::Check035(CMJFanCounter *pCounter) //清一色一条龙
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	if (!CheckIsOneColor(tilesHand))
	{
		return;
	}

	tilesHand.Sort();
	CTiles tilesTempChar; //万
	tilesTempChar.ReleaseAll();
	CTiles tilesTempBamboo; // 条
	tilesTempBamboo.ReleaseAll();
	CTiles tilesTempBall; //筒
	tilesTempBall.ReleaseAll();

	tilesTempChar.AddTile(TILE_CHAR_1);
	tilesTempChar.AddTile(TILE_CHAR_2);
	tilesTempChar.AddTile(TILE_CHAR_3);
	tilesTempChar.AddTile(TILE_CHAR_4);
	tilesTempChar.AddTile(TILE_CHAR_5);
	tilesTempChar.AddTile(TILE_CHAR_6);
	tilesTempChar.AddTile(TILE_CHAR_7);
	tilesTempChar.AddTile(TILE_CHAR_8);
	tilesTempChar.AddTile(TILE_CHAR_9);

	tilesTempBamboo.AddTile(TILE_BAMBOO_1);
	tilesTempBamboo.AddTile(TILE_BAMBOO_2);
	tilesTempBamboo.AddTile(TILE_BAMBOO_3);
	tilesTempBamboo.AddTile(TILE_BAMBOO_4);
	tilesTempBamboo.AddTile(TILE_BAMBOO_5);
	tilesTempBamboo.AddTile(TILE_BAMBOO_6);
	tilesTempBamboo.AddTile(TILE_BAMBOO_7);
	tilesTempBamboo.AddTile(TILE_BAMBOO_8);
	tilesTempBamboo.AddTile(TILE_BAMBOO_9);

	tilesTempBall.AddTile(TILE_BALL_1);
	tilesTempBall.AddTile(TILE_BALL_2);
	tilesTempBall.AddTile(TILE_BALL_3);
	tilesTempBall.AddTile(TILE_BALL_4);
	tilesTempBall.AddTile(TILE_BALL_5);
	tilesTempBall.AddTile(TILE_BALL_6);
	tilesTempBall.AddTile(TILE_BALL_7);
	tilesTempBall.AddTile(TILE_BALL_8);
	tilesTempBall.AddTile(TILE_BALL_9);

	if (tilesTempBall.IsSubSet(tilesHand) || tilesTempBamboo.IsSubSet(tilesHand) || tilesTempChar.IsSubSet(tilesHand))
	{
		// ok
		pCounter->m_FanCount.m_FanNode[35].bFan = TRUE;
	}
}

void CMJFun::Check036(CMJFanCounter *pCounter) //另加番：杠上杠
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	if (pEnv->byFlag != WIN_GANGDRAW)
	{
		return;
	}
	if (pEnv->byGangTimes <= 1)
	{
		return;
	}
	// //2杠，的杠上花
	// if (pEnv->byGangTimes == 2)
	// {
	// 	pCounter->m_FanCount.m_FanNode[36].byFanNumber = 1;
	// }
	// //3杠，的杠上花
	// if (pEnv->byGangTimes == 3)
	// {
	// 	pCounter->m_FanCount.m_FanNode[36].byFanNumber = 2;
	// }

	pCounter->m_FanCount.m_FanNode[36].bFan = TRUE;
}

void CMJFun::Check037(CMJFanCounter *pCounter) //素胡
{
	ENVIRONMENT *pEnv = &pCounter->env;
	if (pEnv->laizi != 0)
	{
		return;
	}
	// // ok
	// if (pEnv->gamestyle == GAME_STYLE_TANGSHAN)
	// {
	// 	strncpy(pCounter->m_FanCount.m_FanNode[37].szFanName, "干博", MAX_FAN_NAME);
	// }
	pCounter->m_FanCount.m_FanNode[37].bFan = TRUE;
}

void CMJFun::Check038(CMJFanCounter *pCounter) //捉五魁（带癞子）
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	BYTE tLast = pEnv->tLast;
	BYTE LaiziCount = pEnv->laizi;
	BYTE nCardLength = pEnv->checkWinParam.byMaxHandCardLength;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	CTiles laiziCard;
	CMJFanCounter::CollectLaiziTile(laiziCard, *pEnv);

	if (tLast != TILE_CHAR_5)
	{
		// 和的那张牌不是5W
		return;
	}
	if ((pEnv->laizi == 0) && (!tilesHand.IsHave(TILE_CHAR_4) || !tilesHand.IsHave(TILE_CHAR_6)))
	{
		// 手牌中没有4W或6W则不能够成捉5W
		return;
	}
	if (pEnv->laizi == 1)
	{
		if (!tilesHand.IsHave(TILE_CHAR_4) && !tilesHand.IsHave(TILE_CHAR_6))
		{
			return;
		}
		else if (tilesHand.IsHave(TILE_CHAR_4) && !tilesHand.IsHave(TILE_CHAR_6))
		{
			//有4万无六万，癞子替代6万
			tilesHand.DelTile(TILE_CHAR_4);
			tilesHand.DelTile(TILE_CHAR_5);
			tilesHand.DelTile(pEnv->byLaiziCards[0]);
			LaiziCount = 0;
		}
		else if (!tilesHand.IsHave(TILE_CHAR_4) && tilesHand.IsHave(TILE_CHAR_6))
		{
			//有6万无4万，癞子替代4万
			tilesHand.DelTile(TILE_CHAR_6);
			tilesHand.DelTile(TILE_CHAR_5);
			tilesHand.DelTile(pEnv->byLaiziCards[0]);
			LaiziCount = 0;
		}
		else if (tilesHand.IsHave(TILE_CHAR_4) && tilesHand.IsHave(TILE_CHAR_6))
		{
			tilesHand.DelTile(TILE_CHAR_4);
			tilesHand.DelTile(TILE_CHAR_5);
			tilesHand.DelTile(TILE_CHAR_6);
			LaiziCount = 1;
		}
	}
	else if (pEnv->laizi >= 2)
	{
		if (!tilesHand.IsHave(TILE_CHAR_4) && !tilesHand.IsHave(TILE_CHAR_6))
		{
			tilesHand.DelTile(pEnv->byLaiziCards[0]);
			tilesHand.DelTile(pEnv->byLaiziCards[0]);
			tilesHand.DelTile(TILE_CHAR_5);
			LaiziCount = pEnv->laizi - 2;
		}
		else if (tilesHand.IsHave(TILE_CHAR_4) && !tilesHand.IsHave(TILE_CHAR_6))
		{
			//有4万无六万，癞子替代6万
			tilesHand.DelTile(TILE_CHAR_4);
			tilesHand.DelTile(TILE_CHAR_5);
			tilesHand.DelTile(pEnv->byLaiziCards[0]);
			LaiziCount = pEnv->laizi - 1;
		}
		else if (!tilesHand.IsHave(TILE_CHAR_4) && tilesHand.IsHave(TILE_CHAR_6))
		{
			//有6万无4万，癞子替代4万
			tilesHand.DelTile(TILE_CHAR_6);
			tilesHand.DelTile(TILE_CHAR_5);
			tilesHand.DelTile(pEnv->byLaiziCards[0]);
			LaiziCount = pEnv->laizi - 1;
		}
		else if (tilesHand.IsHave(TILE_CHAR_4) && tilesHand.IsHave(TILE_CHAR_6))
		{
			tilesHand.DelTile(TILE_CHAR_4);
			tilesHand.DelTile(TILE_CHAR_5);
			tilesHand.DelTile(TILE_CHAR_6);
			LaiziCount = pEnv->laizi;
		}
	}
	// ok
	CTiles TilesHandsNoLaiZi; //无癞子手牌
	TilesHandsNoLaiZi.ReleaseAll();
	if (LaiziCount == 1)
	{
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
	}
	else if (LaiziCount == 2)
	{
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
	}
	else if (LaiziCount == 3)
	{
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
	}
	else if (LaiziCount == 4)
	{
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
	}
	TilesHandsNoLaiZi.AddTiles(tilesHand);
	if (CMJFanCounter::CheckWinNormalLaiZi(TilesHandsNoLaiZi, laiziCard, LaiziCount, nCardLength, pEnv->checkWinParam))
	{
		pCounter->m_FanCount.m_FanNode[38].bFan = TRUE;
	}
}

//TODO:看看怎么修改1
void CMJFun::Check039(CMJFanCounter *pCounter) //一条龙（带混）
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	int nLaizi = pEnv->laizi;

	//lua判断是否需要计算这个番型
	// if (pEnv->gamestyle == GAME_STYLE_QINHUANGDAO && pEnv->n258Jiang & 8 == 0)
	// {
	// 	return;
	// }

	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	
	CTiles laiziCard;
	CTiles TilesLaiZi;
	laiziCard.ReleaseAll();
	TilesLaiZi.ReleaseAll();
	for (int i = 0; i < 4; i++)
	{
		if (pEnv->byLaiziCards[i] > 0)
		{
			laiziCard.AddTile(pEnv->byLaiziCards[i]);
			for (int j = 0; j < tilesHand.nCurrentLength; j++)
			{
				if (tilesHand.tile[j] == pEnv->byLaiziCards[i])
				{
					TilesLaiZi.AddTile(tilesHand.tile[j]);
				}
			}
		}
	}

	int nChar = 0;
	int nBall = 0;
	int nBamboo = 0;
	CTiles tilesNoLaizi;
	tilesNoLaizi.ReleaseAll();
	tilesNoLaizi.AddTiles(tilesHand);
	tilesNoLaizi.DelTiles(TilesLaiZi);

	for (int i = TILE_CHAR_1; i <= TILE_BALL_9; i++)
	{
		if (tilesNoLaizi.IsHave(i))
		{
			if (i > 0 && i < 10)
			{
				nChar++;
			}
			else if (i > 10 && i < 20)
			{
				nBamboo++;
			}
			else if (i > 20 && i < 30)
			{
				nBall++;
			}
		}
	}
	
	//一条龙是条、筒、万的哪一种
	if (nChar + nLaizi < 9 && nBamboo + nLaizi < 9 && nBall + nLaizi < 9)
	{
		return;
	}
	
	CMJFanCounter mjbase;
	if (mjbase.CheckWin(tilesHand, pEnv->laizi, laiziCard, pEnv->checkWinParam))
	{
		pCounter->m_FanCount.m_FanNode[39].bFan = TRUE;
	}
}

//TODO:看看怎么修改1
void CMJFun::Check040(CMJFanCounter *pCounter) //七小对（带癞子）
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	//删除癞子牌后的手牌
	CTiles tilesHands;
	int laizicount = pEnv->laizi;
	CMJFanCounter::CollectHandTile(tilesHands, *pEnv, chair);

	int nGunIndex = -1;
	for (int j = 0; j < tilesHands.nCurrentLength; j++)
	{
		if (tilesHands.tile[j] > 1000)
		{
			tilesHands.tile[j] -= 1000;
			nGunIndex = j;
			break;
		}
	}
	m_nFourCount = 0;
	CTiles TilesLaiZi;
	TilesLaiZi.ReleaseAll();
	for (int i = 0; i < 4; i++)
	{
		if (pEnv->byLaiziCards[i] > 0)
		{
			for (int j = 0; j < tilesHands.nCurrentLength; j++)
			{
				if (j != nGunIndex && tilesHands.tile[j] == pEnv->byLaiziCards[i])
				{
					TilesLaiZi.AddTile(tilesHands.tile[j]);
				}
			}
		}
	}
	TilesLaiZi.Sort();		  //癞子牌堆
	CTiles TilesHandsNoLaiZi; //无癞子手牌
	TilesHandsNoLaiZi.ReleaseAll();
	tilesHands.DelTiles(TilesLaiZi);
	TilesHandsNoLaiZi.AddTiles(tilesHands);
	if (CheckWin7PairLaiZi(TilesHandsNoLaiZi, laizicount))
	{
		// ok
		pCounter->m_FanCount.m_FanNode[40].bFan = TRUE;

		//lua判断是否需要计算这个番型
		// if (pEnv->gamestyle == GAME_STYLE_XUCHANG && (pEnv->n258Jiang & 32 == 0) && laizicount > 0)
		// {
		// 	pCounter->m_FanCount.m_FanNode[40].bFan = FALSE;
		// }
	}
}

void CMJFun::Check041(CMJFanCounter *pCounter) //豪华七对（带癞子）
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	//删除癞子牌后的手牌
	CTiles tilesHands;
	int laizicount = pEnv->laizi;
	CMJFanCounter::CollectHandTile(tilesHands, *pEnv, chair);

	int nGunIndex = -1;
	for (int j = 0; j < tilesHands.nCurrentLength; j++)
	{
		if (tilesHands.tile[j] > 1000)
		{
			tilesHands.tile[j] -= 1000;
			nGunIndex = j;
			break;
		}
	}
	m_nFourCount = 0;
	CTiles TilesLaiZi;
	TilesLaiZi.ReleaseAll();
	for (int i = 0; i < 4; i++)
	{
		if (pEnv->byLaiziCards[i] > 0)
		{
			for (int j = 0; j < tilesHands.nCurrentLength; j++)
			{
				if (j != nGunIndex && tilesHands.tile[j] == pEnv->byLaiziCards[i])
				{
					TilesLaiZi.AddTile(tilesHands.tile[j]);
				}
			}
		}
	}
	TilesLaiZi.Sort();		  //癞子牌堆
	CTiles TilesHandsNoLaiZi; //无癞子手牌
	TilesHandsNoLaiZi.ReleaseAll();
	tilesHands.DelTiles(TilesLaiZi);
	TilesHandsNoLaiZi.AddTiles(tilesHands);
	if (CheckWin7PairLaiZi(TilesHandsNoLaiZi, laizicount))
	{
		if (m_nFourCount >= 1)
		{
			// ok
			pCounter->m_FanCount.m_FanNode[41].bFan = TRUE;
		}
	}
}

void CMJFun::Check042(CMJFanCounter *pCounter) //超级豪华七对（带癞子）
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	//删除癞子牌后的手牌
	CTiles tilesHands;
	int laizicount = pEnv->laizi;
	CMJFanCounter::CollectHandTile(tilesHands, *pEnv, chair);

	int nGunIndex = -1;
	for (int j = 0; j < tilesHands.nCurrentLength; j++)
	{
		if (tilesHands.tile[j] > 1000)
		{
			tilesHands.tile[j] -= 1000;
			nGunIndex = j;
			break;
		}
	}
	m_nFourCount = 0;
	CTiles TilesLaiZi;
	TilesLaiZi.ReleaseAll();
	for (int i = 0; i < 4; i++)
	{
		if (pEnv->byLaiziCards[i] > 0)
		{
			for (int j = 0; j < tilesHands.nCurrentLength; j++)
			{
				if (j != nGunIndex && tilesHands.tile[j] == pEnv->byLaiziCards[i])
				{
					TilesLaiZi.AddTile(tilesHands.tile[j]);
				}
			}
		}
	}
	TilesLaiZi.Sort();		  //癞子牌堆
	CTiles TilesHandsNoLaiZi; //无癞子手牌
	TilesHandsNoLaiZi.ReleaseAll();
	tilesHands.DelTiles(TilesLaiZi);
	TilesHandsNoLaiZi.AddTiles(tilesHands);
	if (CheckWin7PairLaiZi(TilesHandsNoLaiZi, laizicount))
	{
		if (m_nFourCount >= 2)
		{
			// ok
			pCounter->m_FanCount.m_FanNode[42].bFan = TRUE;
		}
	}
}

void CMJFun::Check043(CMJFanCounter *pCounter) //至尊豪华七对（带癞子）
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	//删除癞子牌后的手牌
	CTiles tilesHands;
	int laizicount = pEnv->laizi;
	CMJFanCounter::CollectHandTile(tilesHands, *pEnv, chair);

	int nGunIndex = -1;
	for (int j = 0; j < tilesHands.nCurrentLength; j++)
	{
		if (tilesHands.tile[j] > 1000)
		{
			tilesHands.tile[j] -= 1000;
			nGunIndex = j;
			break;
		}
	}
	m_nFourCount = 0;
	CTiles TilesLaiZi;
	TilesLaiZi.ReleaseAll();
	for (int i = 0; i < 4; i++)
	{
		if (pEnv->byLaiziCards[i] > 0)
		{
			for (int j = 0; j < tilesHands.nCurrentLength; j++)
			{
				if (j != nGunIndex && tilesHands.tile[j] == pEnv->byLaiziCards[i])
				{
					TilesLaiZi.AddTile(tilesHands.tile[j]);
				}
			}
		}
	}
	TilesLaiZi.Sort();		  //癞子牌堆
	CTiles TilesHandsNoLaiZi; //无癞子手牌
	TilesHandsNoLaiZi.ReleaseAll();
	tilesHands.DelTiles(TilesLaiZi);
	TilesHandsNoLaiZi.AddTiles(tilesHands);
	if (CheckWin7PairLaiZi(TilesHandsNoLaiZi, laizicount))
	{
		if (m_nFourCount >= 3)
		{
			// ok
			pCounter->m_FanCount.m_FanNode[43].bFan = TRUE;
		}
	}
}

void CMJFun::Check044(CMJFanCounter *pCounter) //混钓
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	if (pEnv->laizi < 1)
	{
		return;
	}
	if (pEnv->byFlag == WIN_GUN || pEnv->byFlag == WIN_GANGGIVE)
	{
		return;
	}
	//删除癞子牌后的手牌
	int nGunIndex = -1;
	for (int j = 0; j < tilesHand.nCurrentLength; j++)
	{
		if (tilesHand.tile[j] > 1000)
		{
			tilesHand.tile[j] -= 1000;
			nGunIndex = j;
			break;
		}
	}
	CTiles TilesLaiZi;
	CTiles TilesHuPai; //胡的那张牌
	TilesLaiZi.ReleaseAll();
	TilesHuPai.ReleaseAll();
	TilesHuPai.AddTile(pEnv->tLast);
	for (int i = 0; i < 4; i++)
	{
		if (pEnv->byLaiziCards[i] > 0)
		{
			for (int j = 0; j < tilesHand.nCurrentLength; j++)
			{
				if (j != nGunIndex && tilesHand.tile[j] == pEnv->byLaiziCards[i])
				{
					TilesLaiZi.AddTile(tilesHand.tile[j]);
				}
			}
		}
	}
	TilesLaiZi.Sort(); //癞子牌堆
	int nNoJiangLaizi = 0;
	//如果胡的那张牌是癞子，手牌的癞子数要>=2
	if (TilesHuPai.IsSubSet(TilesLaiZi))
	{
		if (pEnv->laizi < 2)
		{
			return;
		}
		//胡的那张牌是癞子，癞子数要减1
		nNoJiangLaizi = nNoJiangLaizi - 1;
	}
	CTiles TilesHandsNoLaiZi; //无癞子手牌
	TilesHandsNoLaiZi.ReleaseAll();
	tilesHand.DelTiles(TilesLaiZi);
	TilesHandsNoLaiZi.AddTiles(tilesHand);

	//删除胡的那张牌后的手牌
	TilesHandsNoLaiZi.DelTiles(TilesHuPai);

	//去掉当闲金后的癞子数
	nNoJiangLaizi = nNoJiangLaizi + pEnv->laizi - 1;
	int nMaxNoJiangLength = pEnv->checkWinParam.byMaxHandCardLength - 2;
	CTiles laiziCard;
	CMJFanCounter::CollectLaiziTile(laiziCard, *pEnv);
	if (CMJFanCounter::CheckWinNoJiangLaizi(TilesHandsNoLaiZi, laiziCard, nNoJiangLaizi, nMaxNoJiangLength, pEnv->checkWinParam))
	{
		// ok
		pCounter->m_FanCount.m_FanNode[44].bFan = TRUE;
	}
}

void CMJFun::Check045(CMJFanCounter *pCounter) //混钓混
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	if (pEnv->laizi < 2)
	{
		return;
	}
	if (pEnv->byFlag == WIN_GUN || pEnv->byFlag == WIN_GANGGIVE)
	{
		return;
	}
	//删除癞子牌后的手牌
	int nGunIndex = -1;
	for (int j = 0; j < tilesHand.nCurrentLength; j++)
	{
		if (tilesHand.tile[j] > 1000)
		{
			tilesHand.tile[j] -= 1000;
			nGunIndex = j;
			break;
		}
	}
	CTiles TilesLaiZi;
	CTiles TilesHuPai; //胡的那张牌
	TilesLaiZi.ReleaseAll();
	TilesHuPai.ReleaseAll();
	TilesHuPai.AddTile(pEnv->tLast);
	for (int i = 0; i < 4; i++)
	{
		if (pEnv->byLaiziCards[i] > 0)
		{
			for (int j = 0; j < tilesHand.nCurrentLength; j++)
			{
				if (j != nGunIndex && tilesHand.tile[j] == pEnv->byLaiziCards[i])
				{
					TilesLaiZi.AddTile(tilesHand.tile[j]);
				}
			}
		}
	}
	TilesLaiZi.Sort(); //癞子牌堆
	int nNoJiangLaizi = 0;
	//如果胡的那张牌是癞子，手牌的癞子数要>=2
	if (!TilesHuPai.IsSubSet(TilesLaiZi))
	{
		return;
	}
	else
	{
		if (pEnv->laizi < 2)
		{
			return;
		}
		//胡的那张牌是癞子，癞子数要减1
		nNoJiangLaizi = nNoJiangLaizi - 1;
	}
	CTiles TilesHandsNoLaiZi; //无癞子手牌
	TilesHandsNoLaiZi.ReleaseAll();
	tilesHand.DelTiles(TilesLaiZi);
	TilesHandsNoLaiZi.AddTiles(tilesHand);

	//删除胡的那张牌后的手牌
	TilesHandsNoLaiZi.DelTiles(TilesHuPai);

	//去掉当闲金后的癞子数
	nNoJiangLaizi = nNoJiangLaizi + pEnv->laizi - 1;
	int nMaxNoJiangLength = pEnv->checkWinParam.byMaxHandCardLength - 2;
	CTiles laiziCard;
	CMJFanCounter::CollectLaiziTile(laiziCard, *pEnv);
	if (CMJFanCounter::CheckWinNoJiangLaizi(TilesHandsNoLaiZi, laiziCard, nNoJiangLaizi, nMaxNoJiangLength, pEnv->checkWinParam))
	{
		// ok
		pCounter->m_FanCount.m_FanNode[45].bFan = TRUE;
	}
}

void CMJFun::Check046(CMJFanCounter *pCounter) //碰碰胡（带癞子）
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE    chair = pEnv->byChair;
	int nLaiZiCount = pEnv->laizi;

	CTiles tilesAll;
	CMJFanCounter::CollectAllTile(tilesAll, *pEnv, chair);
	if (tilesAll.nCurrentLength != 14)
	{
		return;
	}
	int nGunIndex = -1;
	for (int j = 0; j < tilesAll.nCurrentLength; j++)
	{
		if (tilesAll.tile[j] > 1000)
		{
			tilesAll.tile[j] -= 1000;
			nGunIndex = j;
			break;
		}
	}
	CTiles TilesLaiZi;
	TilesLaiZi.ReleaseAll();
	for (int i = 0; i < 4; i++)
	{
		if (pEnv->byLaiziCards[i] > 0)
		{
			for (int j = 0; j < tilesAll.nCurrentLength; j++)
			{
				if (j != nGunIndex && tilesAll.tile[j] == pEnv->byLaiziCards[i])
				{
					TilesLaiZi.AddTile(tilesAll.tile[j]);
				}
			}
		}
	}
	TilesLaiZi.Sort();		  //癞子牌堆
	CTiles TilesHandsNoLaiZi; //无癞子手牌
	TilesHandsNoLaiZi.ReleaseAll();
	tilesAll.DelTiles(TilesLaiZi);
	TilesHandsNoLaiZi.AddTiles(tilesAll);

	if (CheckIsTripletsHuLaiZi(TilesHandsNoLaiZi, nLaiZiCount))
	{
		pCounter->m_FanCount.m_FanNode[46].bFan = TRUE;
	}
}

void CMJFun::Check047(CMJFanCounter *pCounter) //清一色（带癞子）
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesAll;
	CMJFanCounter::CollectAllTile(tilesAll, *pEnv, chair);

	int nGunIndex = -1;
	for (int j = 0; j < tilesAll.nCurrentLength; j++)
	{
		if (tilesAll.tile[j] > 1000)
		{
			tilesAll.tile[j] -= 1000;
			nGunIndex = j;
			break;
		}
	}
	CTiles TilesLaiZi;
	TilesLaiZi.ReleaseAll();
	for (int i = 0; i < 4; i++)
	{
		if (pEnv->byLaiziCards[i] > 0)
		{
			for (int j = 0; j < tilesAll.nCurrentLength; j++)
			{
				if (j != nGunIndex && tilesAll.tile[j] == pEnv->byLaiziCards[i])
				{
					TilesLaiZi.AddTile(tilesAll.tile[j]);
				}
			}
		}
	}
	TilesLaiZi.Sort();		  //癞子牌堆
	CTiles TilesHandsNoLaiZi; //无癞子手牌
	TilesHandsNoLaiZi.ReleaseAll();
	tilesAll.DelTiles(TilesLaiZi);
	TilesHandsNoLaiZi.AddTiles(tilesAll);

	if (CheckIsOneColor(TilesHandsNoLaiZi))
	{
		pCounter->m_FanCount.m_FanNode[47].bFan = TRUE;
	}
}

void CMJFun::Check048(CMJFanCounter *pCounter) //13幺（带癞子）
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;

	CTiles tilesHands;
	CMJFanCounter::CollectHandTile(tilesHands, *pEnv, chair);
	if (tilesHands.nCurrentLength != 14)
	{
		return;
	}
	//所有癞子牌
	CTiles tLaiziCards;
	tLaiziCards.ReleaseAll();
	for (int i = 0; i < 4; i++)
	{
		if (pEnv->byLaiziCards[i] > 0)
		{
			tLaiziCards.AddTile(pEnv->byLaiziCards[i]);
		}
	}
	tilesHands.DelTiles(tLaiziCards);
	// ok
	if (CMJFanCounter::CheckWinShiSanYaoLaizi(tilesHands, pEnv->laizi))
	{
		pCounter->m_FanCount.m_FanNode[48].bFan = TRUE;
	}
}

void CMJFun::Check049(CMJFanCounter *pCounter) //混悠
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	if (pEnv->laizi < 1)
	{
		return;
	}
	if (pEnv->byFlag == WIN_GUN || pEnv->byFlag == WIN_GANGGIVE)
	{
		return;
	}
	if (pEnv->byHunYouFlag != 1)
	{
		return;
	}
	//删除癞子牌后的手牌
	int nGunIndex = -1;
	for (int j = 0; j < tilesHand.nCurrentLength; j++)
	{
		if (tilesHand.tile[j] > 1000)
		{
			tilesHand.tile[j] -= 1000;
			nGunIndex = j;
			break;
		}
	}
	CTiles TilesLaiZi;
	CTiles TilesHuPai; //胡的那张牌
	TilesLaiZi.ReleaseAll();
	TilesHuPai.ReleaseAll();
	TilesHuPai.AddTile(pEnv->tLast);
	for (int i = 0; i < 4; i++)
	{
		if (pEnv->byLaiziCards[i] > 0)
		{
			for (int j = 0; j < tilesHand.nCurrentLength; j++)
			{
				if (j != nGunIndex && tilesHand.tile[j] == pEnv->byLaiziCards[i])
				{
					TilesLaiZi.AddTile(tilesHand.tile[j]);
				}
			}
		}
	}
	TilesLaiZi.Sort(); //癞子牌堆
	int nNoJiangLaizi = 0;
	//如果胡的那张牌是癞子，手牌的癞子数要>=2
	if (TilesHuPai.IsSubSet(TilesLaiZi))
	{
		if (pEnv->laizi < 2)
		{
			return;
		}
		//胡的那张牌是癞子，癞子数要减1
		nNoJiangLaizi = nNoJiangLaizi - 1;
	}
	CTiles TilesHandsNoLaiZi; //无癞子手牌
	TilesHandsNoLaiZi.ReleaseAll();
	tilesHand.DelTiles(TilesLaiZi);
	TilesHandsNoLaiZi.AddTiles(tilesHand);

	//删除胡的那张牌后的手牌
	TilesHandsNoLaiZi.DelTiles(TilesHuPai);

	//去掉当闲金后的癞子数
	nNoJiangLaizi = nNoJiangLaizi + pEnv->laizi - 1;
	int nMaxNoJiangLength = pEnv->checkWinParam.byMaxHandCardLength - 2;
	CTiles laiziCard;
	CMJFanCounter::CollectLaiziTile(laiziCard, *pEnv);
	if (CMJFanCounter::CheckWinNoJiangLaizi(TilesHandsNoLaiZi, laiziCard, nNoJiangLaizi, nMaxNoJiangLength, pEnv->checkWinParam))
	{
		// ok
		pCounter->m_FanCount.m_FanNode[49].bFan = TRUE;
	}
}

void CMJFun::Check051(CMJFanCounter *pCounter) //本混龙
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	int nLaiZiCount = pEnv->laizi;
	CMJFanCounter::CollectAllTile(tilesHand, *pEnv, chair);
	tilesHand.Sort();

	TILE laizicard = pEnv->byLaiziCards[0];

	//癞子牌的花色
	int nColorType = laizicard / 10;
	int nColorDragon = 0;
	//本混龙的癞子牌不能是字牌
	if (laizicard >= TILE_NORTH)
	{
		return;
	}
	if (nLaiZiCount < 1)
	{
		return;
	}
	CTiles tilesTempChar; //万
	tilesTempChar.ReleaseAll();
	CTiles tilesTempBamboo; // 条
	tilesTempBamboo.ReleaseAll();
	CTiles tilesTempBall; //筒
	tilesTempBall.ReleaseAll();

	tilesTempChar.AddTile(TILE_CHAR_1);
	tilesTempChar.AddTile(TILE_CHAR_2);
	tilesTempChar.AddTile(TILE_CHAR_3);
	tilesTempChar.AddTile(TILE_CHAR_4);
	tilesTempChar.AddTile(TILE_CHAR_5);
	tilesTempChar.AddTile(TILE_CHAR_6);
	tilesTempChar.AddTile(TILE_CHAR_7);
	tilesTempChar.AddTile(TILE_CHAR_8);
	tilesTempChar.AddTile(TILE_CHAR_9);

	tilesTempBamboo.AddTile(TILE_BAMBOO_1);
	tilesTempBamboo.AddTile(TILE_BAMBOO_2);
	tilesTempBamboo.AddTile(TILE_BAMBOO_3);
	tilesTempBamboo.AddTile(TILE_BAMBOO_4);
	tilesTempBamboo.AddTile(TILE_BAMBOO_5);
	tilesTempBamboo.AddTile(TILE_BAMBOO_6);
	tilesTempBamboo.AddTile(TILE_BAMBOO_7);
	tilesTempBamboo.AddTile(TILE_BAMBOO_8);
	tilesTempBamboo.AddTile(TILE_BAMBOO_9);

	tilesTempBall.AddTile(TILE_BALL_1);
	tilesTempBall.AddTile(TILE_BALL_2);
	tilesTempBall.AddTile(TILE_BALL_3);
	tilesTempBall.AddTile(TILE_BALL_4);
	tilesTempBall.AddTile(TILE_BALL_5);
	tilesTempBall.AddTile(TILE_BALL_6);
	tilesTempBall.AddTile(TILE_BALL_7);
	tilesTempBall.AddTile(TILE_BALL_8);
	tilesTempBall.AddTile(TILE_BALL_9);
	if (tilesTempBall.IsSubSet(tilesHand))
	{
		if (nColorType == 2 && pEnv->laizi >= 1)
		{
			pCounter->m_FanCount.m_FanNode[51].bFan = TRUE;
			// NOCHECK(39);
			return;
		}
	}
	else if (tilesTempBamboo.IsSubSet(tilesHand))
	{
		if (nColorType == 1 && pEnv->laizi >= 1)
		{
			pCounter->m_FanCount.m_FanNode[51].bFan = TRUE;
			// NOCHECK(39);
			return;
		}
	}
	else if (tilesTempChar.IsSubSet(tilesHand))
	{
		if (nColorType == 0 && pEnv->laizi >= 1)
		{
			pCounter->m_FanCount.m_FanNode[51].bFan = TRUE;
			// NOCHECK(39);
			return;
		}
	}
	CTiles temp;
	temp.ReleaseAll();
	temp.AddTiles(tilesHand);
	//删除重复的牌，计算条筒万的张数
	for (int m = 0; m < 13; m++)
	{
		if (tilesHand.tile[m] == tilesHand.tile[m + 1])
		{
			temp.DelTile(tilesHand.tile[m]);
		}
	}
	int nChar = 0;
	int nBall = 0;
	int nBamboo = 0;
	int ArrayChar[9] = {0};
	int ArrayBall[9] = {0};
	int ArrayBamboo[9] = {0};
	//各个不同的条筒万的张数
	temp.Sort();
	for (int n = 0; n < temp.nCurrentLength; n++)
	{
		if (temp.tile[n] > 0 && temp.tile[n] < 10)
		{
			nChar++;
			ArrayChar[temp.tile[n] - 1] = temp.tile[n];
		}
		else if (temp.tile[n] > 10 && temp.tile[n] < 20)
		{
			int toNumBamoo = temp.tile[n] % 10;
			ArrayBamboo[toNumBamoo - 1] = temp.tile[n];
			nBamboo++;
		}
		else if (temp.tile[n] > 20 && temp.tile[n] < 30)
		{
			int toNumBall = temp.tile[n] % 10;
			ArrayBall[toNumBall - 1] = temp.tile[n];
			nBall++;
		}
	}
	int nMax = 0;
	//一条龙是条、筒、万的哪一种
	if (nChar >= nBamboo && nChar >= nBall)
	{
		nMax = nChar;
		if (nMax < 5)
		{
			return;
		}
		if (tilesTempChar.IsHave(laizicard) && nLaiZiCount > 0)
		{
			nLaiZiCount--;
		}
		for (int k = 0; k < 9; k++)
		{
			if (ArrayChar[k] == 0)
			{
				if (nLaiZiCount > 0)
				{
					nLaiZiCount--;
					tilesHand.DelTile(laizicard);
					tilesHand.AddTile(k + 1);
					nMax++;
				}
			}
		}
		nColorDragon = 0;
	}
	else if (nBamboo >= nChar && nBamboo >= nBall)
	{
		nMax = nBamboo;
		if (nMax < 5)
		{
			return;
		}
		if (tilesTempBamboo.IsHave(laizicard) && nLaiZiCount > 0)
		{
			nLaiZiCount--;
		}
		for (int k = 0; k < 9; k++)
		{
			if (ArrayBamboo[k] == 0)
			{
				if (nLaiZiCount > 0)
				{
					nLaiZiCount--;
					tilesHand.DelTile(laizicard);
					tilesHand.AddTile(k + 1 + 10);
					nMax++;
				}
			}
		}
		nColorDragon = 1;
	}
	else if (nBall >= nBamboo && nBall >= nChar)
	{
		nMax = nBall;
		if (nMax < 5)
		{
			return;
		}
		if (tilesTempBall.IsHave(laizicard) && nLaiZiCount > 0)
		{
			nLaiZiCount--;
		}
		for (int k = 0; k < 9; k++)
		{
			if (ArrayBall[k] == 0)
			{
				if (nLaiZiCount > 0)
				{
					nLaiZiCount--;
					tilesHand.DelTile(laizicard);
					tilesHand.AddTile(k + 1 + 20);
					nMax++;
				}
			}
		}
		nColorDragon = 2;
	}
	//癞子已经替换完成不存在的牌时，小于9个已有的肯定不是一条龙
	if (nMax < 9)
	{
		return;
	}
	else
	{
		if (nColorDragon != nColorType)
		{
			return;
		}
		CTiles tLaiziCards;
		tLaiziCards.ReleaseAll();

		tLaiziCards.AddTile(pEnv->byLaiziCards[0]);
		CMJFanCounter mjbase;
		if (!mjbase.CheckWin(tilesHand, pEnv->laizi, tLaiziCards, pEnv->checkWinParam))
		{
			return;
		}
		pCounter->m_FanCount.m_FanNode[51].bFan = TRUE;
	}
}

//TODO:看看怎么修改
void CMJFun::Check052(CMJFanCounter *pCounter) //海底炮
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;

	if (NULL == pEnv)
	{
		return;
	}
	if (pEnv->byFlag != WIN_GUN && pEnv->byFlag != WIN_GANGGIVE && pEnv->byFlag != WIN_GANG)
	{
		return;
	}
	if (pEnv->byHaiDi)
	{
		pCounter->m_FanCount.m_FanNode[52].bFan = TRUE;
	}
	
	// // 牌墙剩余张数
	// int nLength = pEnv->byTilesLeft;

	// if (pEnv->gamestyle == GAME_STYLE_TANGSHAN)
	// {
	// 	if (nLength == 14)
	// 	{
	// 		pCounter->m_FanCount.m_FanNode[52].bFan = TRUE;
	// 	}
	// }
	// else
	// {
	// 	if (nLength == 0)
	// 	{
	// 		pCounter->m_FanCount.m_FanNode[52].bFan = TRUE;
	// 	}
	// }
}

void CMJFun::Check053(CMJFanCounter *pCounter) //天听
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;

	if (NULL == pEnv)
	{
		return;
	}
	if (pEnv->byGodTingFlag != 1)
	{
		return;
	}
	{
		// ok
		pCounter->m_FanCount.m_FanNode[53].bFan = TRUE;
	}
}

void CMJFun::Check054(CMJFanCounter *pCounter) //地听
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;

	if (NULL == pEnv)
	{
		return;
	}
	if (pEnv->byGroundTingFlag != 1)
	{
		return;
	}

	{
		// ok
		pCounter->m_FanCount.m_FanNode[54].bFan = TRUE;
	}
}

void CMJFun::Check055(CMJFanCounter *pCounter) //潇洒
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;

	if (NULL == pEnv)
	{
		return;
	}
	if (pEnv->byXiaoSaTingFlag != 1)
	{
		return;
	}
	{
		// ok
		pCounter->m_FanCount.m_FanNode[55].bFan = TRUE;
	}
}

void CMJFun::Check056(CMJFanCounter *pCounter) //卡五星（带癞子）
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	BYTE tLast = pEnv->tLast;
	BYTE LaiziCount = pEnv->laizi;
	BYTE nCardLength = pEnv->checkWinParam.byMaxHandCardLength;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	CTiles laiziCard;
	CMJFanCounter::CollectLaiziTile(laiziCard, *pEnv);

	if (tLast % 10 != 5)
	{
		// 和的那张牌不是5W
		return;
	}
	if (tLast == TILE_ZHONG)
	{
		// 排除风牌
		return;
	}

	if ((pEnv->laizi == 0) && (!tilesHand.IsHave(tLast - 1) || !tilesHand.IsHave(tLast + 1)))
	{
		// 手牌中没有4或6则不能够成卡5
		return;
	}
	if ((pEnv->laizi == 0) && (tilesHand.IsHave(tLast - 1) || tilesHand.IsHave(tLast + 1)))
	{
		tilesHand.DelTile(tLast - 1);
		tilesHand.DelTile(tLast);
		tilesHand.DelTile(tLast + 1);
	}
	if (pEnv->laizi == 1)
	{
		if (!tilesHand.IsHave(tLast - 1) && !tilesHand.IsHave(tLast + 1))
		{
			return;
		}
		else if (tilesHand.IsHave(tLast - 1) && !tilesHand.IsHave(tLast + 1))
		{
			//有4无六，癞子替代6
			tilesHand.DelTile(tLast - 1);
			tilesHand.DelTile(tLast);
			tilesHand.DelTile(pEnv->byLaiziCards[0]);
			LaiziCount = 0;
			if (pEnv->byLaiziCards[0] == tLast - 1)
			{
				return;
			}
		}
		else if (!tilesHand.IsHave(tLast - 1) && tilesHand.IsHave(tLast + 1))
		{
			//有6万无4万，癞子替代4万
			tilesHand.DelTile(tLast + 1);
			tilesHand.DelTile(tLast);
			tilesHand.DelTile(pEnv->byLaiziCards[0]);
			LaiziCount = 0;
			if (pEnv->byLaiziCards[0] == tLast + 1)
			{
				return;
			}
		}
		else if (tilesHand.IsHave(tLast - 1) && tilesHand.IsHave(tLast + 1))
		{
			tilesHand.DelTile(tLast - 1);
			tilesHand.DelTile(tLast);
			tilesHand.DelTile(tLast + 1);
			LaiziCount = 1;
		}
	}
	else if (pEnv->laizi >= 2)
	{
		if (!tilesHand.IsHave(tLast - 1) && !tilesHand.IsHave(tLast + 1))
		{
			tilesHand.DelTile(pEnv->byLaiziCards[0]);
			tilesHand.DelTile(pEnv->byLaiziCards[0]);
			tilesHand.DelTile(tLast);
			LaiziCount = pEnv->laizi - 2;
		}
		else if (tilesHand.IsHave(tLast - 1) && !tilesHand.IsHave(tLast + 1))
		{
			//有4无六，癞子替代6
			tilesHand.DelTile(tLast - 1);
			tilesHand.DelTile(tLast);
			tilesHand.DelTile(pEnv->byLaiziCards[0]);
			LaiziCount = pEnv->laizi - 1;
			if (pEnv->byLaiziCards[0] == tLast - 1)
			{
				LaiziCount--;
			}
		}
		else if (!tilesHand.IsHave(tLast - 1) && tilesHand.IsHave(tLast + 1))
		{
			//有6万无4万，癞子替代4万
			tilesHand.DelTile(tLast + 1);
			tilesHand.DelTile(tLast);
			tilesHand.DelTile(pEnv->byLaiziCards[0]);
			LaiziCount = pEnv->laizi - 1;
			if (pEnv->byLaiziCards[0] == tLast - 1)
			{
				LaiziCount--;
			}
		}
		else if (tilesHand.IsHave(tLast - 1) && tilesHand.IsHave(tLast + 1))
		{
			tilesHand.DelTile(tLast - 1);
			tilesHand.DelTile(tLast);
			tilesHand.DelTile(tLast + 1);
			LaiziCount = pEnv->laizi;
			if (pEnv->byLaiziCards[0] == tLast - 1)
			{
				LaiziCount--;
			}
			else if (pEnv->byLaiziCards[0] == tLast + 1)
			{
				LaiziCount--;
			}
		}
	}
	// ok
	CTiles TilesHandsNoLaiZi; //无癞子手牌
	TilesHandsNoLaiZi.ReleaseAll();
	if (LaiziCount == 1)
	{
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
	}
	else if (LaiziCount == 2)
	{
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
	}
	else if (LaiziCount == 3)
	{
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
	}
	else if (LaiziCount == 4)
	{
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
		tilesHand.DelTile(pEnv->byLaiziCards[0]);
	}
	TilesHandsNoLaiZi.AddTiles(tilesHand);
	if (CMJFanCounter::CheckWinNormalLaiZi(TilesHandsNoLaiZi, laiziCard, LaiziCount, nCardLength, pEnv->checkWinParam))
	{
		pCounter->m_FanCount.m_FanNode[56].bFan = TRUE;
	}
}

//TODO:看看怎么修改1
void CMJFun::Check057(CMJFanCounter *pCounter) //四金/混胡
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	if (pEnv->laizi < 4)
	{
		return;
	}
	if (pEnv->byFlag == WIN_GUN || pEnv->byFlag == WIN_GANGGIVE)
	{
		return;
	}

	//在lua判断是否检查这番型
	// if (pEnv->gamestyle == GAME_STYLE_QINHUANGDAO && pEnv->n258Jiang & 2 <= 0)
	// {
	// 	return;
	// }
	
	pCounter->m_FanCount.m_FanNode[57].bFan = TRUE;
}

//TODO:看看怎么修改1
void CMJFun::Check058(CMJFanCounter *pCounter) //风摸(风扑+将扑)
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	BYTE tLast = pEnv->tLast;
	CTiles tilesHand;
	BYTE LaiziCount = pEnv->laizi;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	int nBlack = 0;
	int nWhite = 0;
	CTiles TilesWindsEast;
	CTiles TilesWindsSouth;
	CTiles TilesWindsWest;
	CTiles TilesWindsNorth;
	TilesWindsEast.ReleaseAll();
	TilesWindsEast.AddTile(TILE_SOUTH);
	TilesWindsEast.AddTile(TILE_WEST);
	TilesWindsEast.AddTile(TILE_NORTH);

	TilesWindsSouth.ReleaseAll();
	TilesWindsSouth.AddTile(TILE_EAST);
	TilesWindsSouth.AddTile(TILE_WEST);
	TilesWindsSouth.AddTile(TILE_NORTH);

	TilesWindsWest.ReleaseAll();
	TilesWindsWest.AddTile(TILE_SOUTH);
	TilesWindsWest.AddTile(TILE_EAST);
	TilesWindsWest.AddTile(TILE_NORTH);

	TilesWindsNorth.ReleaseAll();
	TilesWindsNorth.AddTile(TILE_SOUTH);
	TilesWindsNorth.AddTile(TILE_WEST);
	TilesWindsNorth.AddTile(TILE_EAST);

	CTiles TilesJian;
	TilesJian.ReleaseAll();
	TilesJian.AddTile(TILE_ZHONG);
	TilesJian.AddTile(TILE_FA);
	TilesJian.AddTile(TILE_BAI);

	CTiles temp;
	temp.ReleaseAll();
	temp.AddTiles(tilesHand);
	for (int i = 0; i < (temp.nCurrentLength / 3); i++)
	{
		if (TilesWindsEast.IsSubSet(tilesHand))
		{
			nBlack++;
			tilesHand.DelTiles(TilesWindsEast);
		}
		if (TilesWindsWest.IsSubSet(tilesHand))
		{
			nBlack++;
			tilesHand.DelTiles(TilesWindsWest);
		}
		if (TilesWindsSouth.IsSubSet(tilesHand))
		{
			nBlack++;
			tilesHand.DelTiles(TilesWindsSouth);
		}
		if (TilesWindsNorth.IsSubSet(tilesHand))
		{
			nBlack++;
			tilesHand.DelTiles(TilesWindsNorth);
		}
		if (TilesJian.IsSubSet(tilesHand))
		{
			nWhite++;
			tilesHand.DelTiles(TilesJian);
		}

		// //濮阳的风扑 将扑 可以在lua做判断
		// if (pEnv->gamestyle == GAME_STYLE_PUYANG)
		// {
		// 	if (pEnv->n258Jiang & 2 == 0)
		// 	{
		// 		nBlack = 0;
		// 	}
		// 	if (pEnv->n258Jiang & 4 == 0)
		// 	{
		// 		nWhite = 0;
		// 	}
		// }
		if (nWhite > 0 || nBlack > 0)
		{
			pCounter->m_FanCount.m_FanNode[58].bFan = TRUE;
			pCounter->m_FanCount.m_FanNode[58].byFanNumber = nWhite + nBlack;
		}
	}
}

//TODO:看看怎么修改1
void CMJFun::Check059(CMJFanCounter *pCounter) //缺一门
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	BYTE tLast = pEnv->tLast;
	CTiles tilesHand;
	BYTE LaiziCount = pEnv->laizi;
	CMJFanCounter::CollectAllTile(tilesHand, *pEnv, chair);
	
	// if (pEnv->gamestyle == GAME_STYLE_KAIFENG)
	// {
	// 	for (int i = 0; i < tilesHand.nCurrentLength; i++)
	// 	{
	// 		if (tilesHand.tile[i] >= TILE_EAST)
	// 		{
	// 			return;
	// 		}
	// 	}
	// }
	if (!pEnv->nMissWind)
	{
		return;
	}
	//去掉癞子 和 风牌 再判断缺门数
	else
	{
		tilesHand.DelTileAll(pEnv->byLaiziCards[0]);
		tilesHand.DelTileAll(TILE_EAST);
		tilesHand.DelTileAll(TILE_SOUTH);
		tilesHand.DelTileAll(TILE_WEST);
		tilesHand.DelTileAll(TILE_NORTH);
		tilesHand.DelTileAll(TILE_ZHONG);
		tilesHand.DelTileAll(TILE_BAI);
		tilesHand.DelTileAll(TILE_FA);
	}
	int nLoseCount = 3 - GetColorTypeCout(tilesHand);
	if (nLoseCount > 0)
	{
		pCounter->m_FanCount.m_FanNode[59].bFan = TRUE;
		pCounter->m_FanCount.m_FanNode[59].byFanNumber = nLoseCount;
	}
}

void CMJFun::Check060(CMJFanCounter *pCounter) // 单吊胡
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;

	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	// if (!pEnv->bDanDiaoHu)
	// {
	// 	return;
	// }

	if (tilesHand.size() != 2)
	{
		return;
	}

	pCounter->m_FanCount.m_FanNode[60].bFan = TRUE;
}

//TODO:看看怎么修改1
void CMJFun::Check061(CMJFanCounter *pCounter) //幺九扑
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	BYTE tLast = pEnv->tLast;
	CTiles tilesHand;
	BYTE LaiziCount = pEnv->laizi;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	CTiles laiziCard;
	CMJFanCounter::CollectLaiziTile(laiziCard, *pEnv);

	//lua做判断是否计算这番型
	// if (pEnv->gamestyle == GAME_STYLE_PUYANG && pEnv->n258Jiang & 8 == 0)
	// {
	// 	return;
	// }

	if (LaiziCount > 0)
	{
		return;
	}

	if (tilesHand.size() < 5)
	{
		return;
	}
	CMJFanCounter mjbase;
	mjbase.m_nWind = 0;
	mjbase.m_nJiang = 0;
	mjbase.m_nYaoJiu = 0;

	if (mjbase.CheckWinNormalWJYJPu(tilesHand, LaiziCount, laiziCard, pEnv->checkWinParam))
	{
		if (mjbase.m_nYaoJiu > 0)
		{
			pCounter->m_FanCount.m_FanNode[61].bFan = TRUE;
			// pCounter->m_FanCount.m_FanNode[61].byFanNumber = mjbase.m_nYaoJiu;
		}
	}
}

void CMJFun::Check062(CMJFanCounter *pCounter) //另加番: 暗卡
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	tilesHand.Sort();
	int nGen = 0;
	CTiles tilesTemp;
	for (int i = 0; i < tilesHand.nCurrentLength; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
		{
			continue;
		}
		tilesTemp.ReleaseAll();
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		if (tilesTemp.IsSubSet(tilesHand))
		{
			nGen++;
		}
	}
	if (nGen)
	{
		pCounter->m_FanCount.m_FanNode[62].bFan = TRUE;
		pCounter->m_FanCount.m_FanNode[62].byCount = nGen;
	}
}

//TODO:看看怎么修改1
void CMJFun::Check063(CMJFanCounter *pCounter) //十三不靠
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;

	//lua做判断是否计算这番型
	// if (pEnv->gamestyle == GAME_STYLE_PINGDINGSHAN && pEnv->n258Jiang & 16 == 0)
	// {
	// 	return;
	// }

	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	if (CMJFanCounter::CheckWinShiSanBuKao(tilesHand))
	{
		pCounter->m_FanCount.m_FanNode[63].bFan = TRUE;
	}
}

void CMJFun::Check064(CMJFanCounter *pCounter) //字一色
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE	chair = pEnv->byChair;

	CTiles tilesAll, tilesGood;
	CMJFanCounter::CollectAllTile(tilesAll, *pEnv, chair);

	CTiles tilesLaiZi;
	tilesLaiZi.ReleaseAll();
	for (int i = 0; i < 4; i++)
	{
		if (pEnv->byLaiziCards[i] > 0)
		{
			for (int j = 0; j < tilesAll.nCurrentLength; j++)
			{
				if (tilesAll.tile[j] == pEnv->byLaiziCards[i])
				{
					tilesLaiZi.AddTile(tilesAll.tile[j]);
				}
			}
		}
	}

	CTiles tilesNoLaiZi;
	tilesNoLaiZi.ReleaseAll();
	tilesAll.DelTiles(tilesLaiZi);
	tilesNoLaiZi.AddTiles(tilesAll);

	for (int i = 0; i < 7; i++)
	{
		for (int j = 0; j < 4; j++)
		{
			tilesGood.AddTile(TILE_EAST + i);
		}
	}

	if (tilesNoLaiZi.IsSubSet(tilesGood))
	{
		pCounter->m_FanCount.m_FanNode[64].bFan = TRUE;
	}
}

void CMJFun::Check065(CMJFanCounter *pCounter) //混一色 带风，无癞子
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE	chair = pEnv->byChair;

	CTiles tilesAll;
	CMJFanCounter::CollectAllTile(tilesAll, *pEnv, chair);

	CTiles tilesWind;
	tilesWind.ReleaseAll();

	for (int j = 0; j < tilesAll.nCurrentLength; j++)
	{
		if (tilesAll.tile[j] / 10 == 3)
		{
			tilesWind.AddTile(tilesAll.tile[j]);
		}
	}

	if (tilesWind.size() == 0 )
	{
		return;
	}

	CTiles tilesNoWind;
	tilesNoWind.ReleaseAll();
	tilesNoWind.AddTiles(tilesAll);
	tilesNoWind.DelTiles(tilesWind);

	if (tilesNoWind.size() != 0 && CheckIsOneColor(tilesNoWind) == FALSE)
	{
		return;
	}
	
	pCounter->m_FanCount.m_FanNode[65].bFan = TRUE;
}

void CMJFun::Check066(CMJFanCounter *pCounter) // 中发白顺子
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	tilesHand.Sort();

	if (NULL == pCounter)
	{
		return;
	}
	CTiles tilesTemp;
	tilesTemp.ReleaseAll();
	tilesTemp.AddTile(TILE_ZHONG);
	tilesTemp.AddTile(TILE_FA);
	tilesTemp.AddTile(TILE_BAI);

	CTiles tilesNew;
	tilesNew.ReleaseAll();
	tilesNew.AddTiles(tilesHand);

	BYTE laiziCount = pEnv->laizi;

	if (tilesTemp.IsSubSet(tilesHand))
	{		
		tilesNew.DelTiles(tilesTemp);
		if (pEnv->byLaiziCards[0] == TILE_ZHONG || pEnv->byLaiziCards[0] == TILE_FA || pEnv->byLaiziCards[0] == TILE_BAI)
		{
			laiziCount = laiziCount - 1;
		}
	}
	else
	{
		return;
	}
	CMJFanCounter mjbase;
	CTiles tLaiziCards;
	tLaiziCards.ReleaseAll();

	tLaiziCards.AddTile(pEnv->byLaiziCards[0]);

	if (!mjbase.CheckWin(tilesNew, laiziCount, tLaiziCards, pEnv->checkWinParam))
	{
		return;
	}
	pCounter->m_FanCount.m_FanNode[66].bFan = TRUE;
}

//TODO:看看怎么修改1
void CMJFun::Check067(CMJFanCounter *pCounter) //风扑
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	BYTE tLast = pEnv->tLast;
	CTiles tilesHand;
	BYTE LaiziCount = pEnv->laizi;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	int nBlack = 0;
	int nWhite = 0;
	CTiles TilesWindsEast;
	CTiles TilesWindsSouth;
	CTiles TilesWindsWest;
	CTiles TilesWindsNorth;
	TilesWindsEast.ReleaseAll();
	TilesWindsEast.AddTile(TILE_SOUTH);
	TilesWindsEast.AddTile(TILE_WEST);
	TilesWindsEast.AddTile(TILE_NORTH);

	TilesWindsSouth.ReleaseAll();
	TilesWindsSouth.AddTile(TILE_EAST);
	TilesWindsSouth.AddTile(TILE_WEST);
	TilesWindsSouth.AddTile(TILE_NORTH);

	TilesWindsWest.ReleaseAll();
	TilesWindsWest.AddTile(TILE_SOUTH);
	TilesWindsWest.AddTile(TILE_EAST);
	TilesWindsWest.AddTile(TILE_NORTH);

	TilesWindsNorth.ReleaseAll();
	TilesWindsNorth.AddTile(TILE_SOUTH);
	TilesWindsNorth.AddTile(TILE_WEST);
	TilesWindsNorth.AddTile(TILE_EAST);

	CTiles TilesJian;
	TilesJian.ReleaseAll();
	TilesJian.AddTile(TILE_ZHONG);
	TilesJian.AddTile(TILE_FA);
	TilesJian.AddTile(TILE_BAI);

	CTiles temp;
	temp.ReleaseAll();
	temp.AddTiles(tilesHand);
	for (int i = 0; i < (temp.nCurrentLength / 3); i++)
	{
		if (TilesWindsEast.IsSubSet(tilesHand))
		{
			nBlack++;
			tilesHand.DelTiles(TilesWindsEast);
		}
		if (TilesWindsWest.IsSubSet(tilesHand))
		{
			nBlack++;
			tilesHand.DelTiles(TilesWindsWest);
		}
		if (TilesWindsSouth.IsSubSet(tilesHand))
		{
			nBlack++;
			tilesHand.DelTiles(TilesWindsSouth);
		}
		if (TilesWindsNorth.IsSubSet(tilesHand))
		{
			nBlack++;
			tilesHand.DelTiles(TilesWindsNorth);
		}
		if (TilesJian.IsSubSet(tilesHand))
		{
			nWhite++;
			tilesHand.DelTiles(TilesJian);
		}

		//濮阳的风扑 将扑 可以在lua做判断
		// if (pEnv->gamestyle == GAME_STYLE_PUYANG)
		// {
		// 	if (pEnv->n258Jiang & 2 == 0)
		// 	{
		// 		nBlack = 0;
		// 	}
		// 	if (pEnv->n258Jiang & 4 == 0)
		// 	{
		// 		nWhite = 0;
		// 	}
		// }
		if (nBlack > 0)
		{
			pCounter->m_FanCount.m_FanNode[67].bFan = TRUE;
			pCounter->m_FanCount.m_FanNode[67].byFanNumber = nBlack;
		}
	}
}

//TODO:看看怎么修改1
void CMJFun::Check068(CMJFanCounter *pCounter) //将扑
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	BYTE tLast = pEnv->tLast;
	CTiles tilesHand;
	BYTE LaiziCount = pEnv->laizi;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	int nBlack = 0;
	int nWhite = 0;
	CTiles TilesWindsEast;
	CTiles TilesWindsSouth;
	CTiles TilesWindsWest;
	CTiles TilesWindsNorth;
	TilesWindsEast.ReleaseAll();
	TilesWindsEast.AddTile(TILE_SOUTH);
	TilesWindsEast.AddTile(TILE_WEST);
	TilesWindsEast.AddTile(TILE_NORTH);

	TilesWindsSouth.ReleaseAll();
	TilesWindsSouth.AddTile(TILE_EAST);
	TilesWindsSouth.AddTile(TILE_WEST);
	TilesWindsSouth.AddTile(TILE_NORTH);

	TilesWindsWest.ReleaseAll();
	TilesWindsWest.AddTile(TILE_SOUTH);
	TilesWindsWest.AddTile(TILE_EAST);
	TilesWindsWest.AddTile(TILE_NORTH);

	TilesWindsNorth.ReleaseAll();
	TilesWindsNorth.AddTile(TILE_SOUTH);
	TilesWindsNorth.AddTile(TILE_WEST);
	TilesWindsNorth.AddTile(TILE_EAST);

	CTiles TilesJian;
	TilesJian.ReleaseAll();
	TilesJian.AddTile(TILE_ZHONG);
	TilesJian.AddTile(TILE_FA);
	TilesJian.AddTile(TILE_BAI);

	CTiles temp;
	temp.ReleaseAll();
	temp.AddTiles(tilesHand);
	for (int i = 0; i < (temp.nCurrentLength / 3); i++)
	{
		if (TilesWindsEast.IsSubSet(tilesHand))
		{
			nBlack++;
			tilesHand.DelTiles(TilesWindsEast);
		}
		if (TilesWindsWest.IsSubSet(tilesHand))
		{
			nBlack++;
			tilesHand.DelTiles(TilesWindsWest);
		}
		if (TilesWindsSouth.IsSubSet(tilesHand))
		{
			nBlack++;
			tilesHand.DelTiles(TilesWindsSouth);
		}
		if (TilesWindsNorth.IsSubSet(tilesHand))
		{
			nBlack++;
			tilesHand.DelTiles(TilesWindsNorth);
		}
		if (TilesJian.IsSubSet(tilesHand))
		{
			nWhite++;
			tilesHand.DelTiles(TilesJian);
		}

		//濮阳的风扑 将扑 可以在lua做判断
		// if (pEnv->gamestyle == GAME_STYLE_PUYANG)
		// {
		// 	if (pEnv->n258Jiang & 4 == 0)
		// 	{
		// 		nWhite = 0;
		// 	}
		// }
		if (nWhite > 0)
		{
			pCounter->m_FanCount.m_FanNode[68].bFan = TRUE;
			pCounter->m_FanCount.m_FanNode[68].byFanNumber = nWhite;
		}
	}
}
void CMJFun::Check069(CMJFanCounter *pCounter) // 牛逼叫
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	//赢家没有选择听牌的话不算牛逼叫
	if (pEnv->byTing[chair] != TING_NBJ)
	{
		return;
	}
	pCounter->m_FanCount.m_FanNode[69].bFan = TRUE;
}
void CMJFun::Check070(CMJFanCounter *pCounter) // 小三元
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesAll;
	CMJFanCounter::CollectAllTile(tilesAll, *pEnv, chair);

	int nTwoCount = 0;
	int nThrCount = 0;
	for (int i = 0; i < 3; i++)
	{
		if (tilesAll.IsHaveNum(TILE_ZHONG + i, 2))
		{
			nTwoCount++;
		}
		else if (tilesAll.IsHaveNum(TILE_ZHONG + i, 3) || tilesAll.IsHaveNum(TILE_ZHONG + i, 4))
		{
			nThrCount++;
		}
	}

	if (nTwoCount == 1 && nThrCount == 2)
	{
		pCounter->m_FanCount.m_FanNode[70].bFan = TRUE;
	}
}
void CMJFun::Check071(CMJFanCounter *pCounter) // 大三元
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesAll;
	CMJFanCounter::CollectAllTile(tilesAll, *pEnv, chair);

	int nThrCount = 0;
	for (int i = 0; i < 3; i++)
	{
		if (tilesAll.IsHaveNum(TILE_ZHONG + i, 3) || tilesAll.IsHaveNum(TILE_ZHONG + i, 4))
		{
			nThrCount++;
		}
	}

	if (nThrCount == 3)
	{
		pCounter->m_FanCount.m_FanNode[71].bFan = TRUE;
	}
}
void CMJFun::Check072(CMJFanCounter *pCounter) // 明四归 全频道
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	for (int i = 0; i < pEnv->bySetCount[chair]; i++)
	{
		if (pEnv->tSet[chair][i][0] == ACTION_TRIPLET)
		{
			if (tilesHand.IsHave(pEnv->tSet[chair][i][1]))
			{
				pCounter->m_FanCount.m_FanNode[72].bFan = TRUE;
				break;
			}
		}
	}
}
void CMJFun::Check073(CMJFanCounter *pCounter) // 暗四归 全频道
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	tilesHand.Sort();
	for (int i = 0; i < tilesHand.nCurrentLength; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
		{
			continue;
		}

		if (tilesHand.IsHaveNum(tilesHand.tile[i], 4))
		{
			pCounter->m_FanCount.m_FanNode[73].bFan = TRUE;
			break;
		}
	}
}
void CMJFun::Check074(CMJFanCounter *pCounter) // 明四归 半频道
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	for (int i = 0; i < pEnv->bySetCount[chair]; i++)
	{
		if (pEnv->tSet[chair][i][0] == ACTION_TRIPLET)
		{
			if (tilesHand.IsHave(pEnv->tSet[chair][i][1]) && pEnv->tLast == pEnv->tSet[chair][i][1])
			{
				pCounter->m_FanCount.m_FanNode[74].bFan = TRUE;
				break;
			}
		}
	}
}
void CMJFun::Check075(CMJFanCounter *pCounter) // 暗四归 半频道
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	tilesHand.Sort();
	for (int i = 0; i < tilesHand.nCurrentLength; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
		{
			continue;
		}

		if (tilesHand.IsHaveNum(tilesHand.tile[i], 4) && pEnv->tLast == pEnv->tSet[chair][i][1])
		{
			pCounter->m_FanCount.m_FanNode[75].bFan = TRUE;
			break;
		}
	}
}
void CMJFun::Check076(CMJFanCounter *pCounter) // 夹胡
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	int nLaizi = pEnv->laizi;
	TILE t = pEnv->tLast;
	int nCardLength = pEnv->checkWinParam.byMaxHandCardLength;

	BOOL bKa = FALSE;
	BOOL bDiao = FALSE;
	CTiles tilesHand, tilesGood, tilesTemp;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	tilesGood.ReleaseAll();
	tilesGood.AddCollect(t - 1);
	if (tilesGood.IsSubSet(tilesHand))
	{
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (CMJFanCounter::CheckWinNormal(tilesTemp, nCardLength))
		{
			bKa = TRUE;
		}
	}

	tilesGood.ReleaseAll();
	tilesGood.AddTile(t);
	tilesGood.AddTile(t);
	if (tilesGood.IsSubSet(tilesHand))
	{
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (CMJFanCounter::CheckWinNoJiang(tilesTemp, nCardLength))
		{
			bDiao = TRUE;
		}
	}

	if (bKa || bDiao)
	{
		pCounter->m_FanCount.m_FanNode[76].bFan = TRUE;
	}
}
void CMJFun::Check077(CMJFanCounter *pCounter) // 双清 (清一色碰碰胡+单吊）
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	CTiles tilesHand;
	CMJFanCounter::CollectAllTile(tilesHand, *pEnv, chair);
	if (2 != pEnv->byHandCount[chair]) // 2张手牌
	{
		return;
	}
	if (tilesHand.nCurrentLength != pEnv->checkWinParam.byMaxHandCardLength)
	{
		return;
	}
	if (CheckIsOneColor(tilesHand) && CheckIsTripletsHu(tilesHand))
	{
		pCounter->m_FanCount.m_FanNode[77].bFan = TRUE;
	}
}
void CMJFun::Check078(CMJFanCounter *pCounter) // 龙七对
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	TILE t = pEnv->tLast;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	if (tilesHand.nCurrentLength != 14)
	{
		return;
	}
	if (!CheckIsAllPairs(tilesHand))
	{
		return;
	}
	tilesHand.Sort();
	CTiles tilesTemp;
	for (int i = 0; i < 14; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
		{
			continue;
		}
		tilesTemp.ReleaseAll();
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		if (tilesTemp.IsSubSet(tilesHand) && t == tilesHand.tile[i])
		{
			pCounter->m_FanCount.m_FanNode[78].bFan = TRUE;
			break;
		}
	}
}
void CMJFun::Check079(CMJFanCounter *pCounter) // 清龙背
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	TILE t = pEnv->tLast;
	CTiles tilesHand;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	if (tilesHand.nCurrentLength != 14)
	{
		return;
	}
	if (!CheckIsAllPairs(tilesHand) || !CheckIsOneColor(tilesHand))
	{
		return;
	}
	tilesHand.Sort();
	CTiles tilesTemp;
	for (int i = 0; i < 14; i++)
	{
		if (i > 0 && tilesHand.tile[i] == tilesHand.tile[i - 1])
		{
			continue;
		}
		tilesTemp.ReleaseAll();
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		tilesTemp.AddTile(tilesHand.tile[i]);
		if (tilesTemp.IsSubSet(tilesHand) && t == tilesHand.tile[i])
		{
			pCounter->m_FanCount.m_FanNode[79].bFan = TRUE;
			break;
		}
	}
}

void CMJFun::Check080(CMJFanCounter *pCounter) // 松原夹胡
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	int nLaizi = pEnv->laizi;
	TILE t = pEnv->tLast;
	int nCardLength = pEnv->checkWinParam.byMaxHandCardLength;

	BOOL bKa = FALSE;
	CTiles tilesHand, tilesGood, tilesTemp;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);

	tilesGood.ReleaseAll();
	tilesGood.AddCollect(t - 1);
	if (tilesGood.IsSubSet(tilesHand))
	{
		tilesTemp.ReleaseAll();
		tilesTemp.AddTiles(tilesHand);
		tilesTemp.DelTiles(tilesGood);
		if (CMJFanCounter::CheckWinNormal(tilesTemp, nCardLength))
		{
			bKa = TRUE;
		}
	}
	if (bKa )
	{
		pCounter->m_FanCount.m_FanNode[80].bFan = TRUE;
	}
}
void CMJFun::Check081(CMJFanCounter *pCounter) // 对宝
{
	ENVIRONMENT *pEnv = &pCounter->env;
	if (pEnv->byFlag != WIN_DUIBAO)
	{
		return;
	}
	pCounter->m_FanCount.m_FanNode[81].bFan = TRUE;
}
void CMJFun::Check082(CMJFanCounter *pCounter) // 三清
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	if (pEnv->bySetCount[chair] == 0)
	{
		return;
	}
	for (int i = 0; i < 4; i++)
	{
		if (chair != i)
		{
			if (pEnv->bySetCount[i] != 0)
			{
				return;
			}
		}

	}
	pCounter->m_FanCount.m_FanNode[82].bFan = TRUE;
}
void CMJFun::Check083(CMJFanCounter *pCounter) // 四清
{
	ENVIRONMENT *pEnv = &pCounter->env;
	for (int i = 0; i < 4; i++)
	{
		if (pEnv->bySetCount[i] != 0)
		{
			return;
		}
	}
	pCounter->m_FanCount.m_FanNode[83].bFan = TRUE;
}
void CMJFun::Check084(CMJFanCounter *pCounter) // 三清夹五
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	if (pEnv->bySetCount[chair] == 0)
	{
		return;
	}
	for (int i = 0; i < 4; i++)
	{
		if (chair != i)
		{
			if (pEnv->bySetCount[i] != 0)
			{
				return;
			}
		}

	}
	BYTE tLast = pEnv->tLast;

	if (tLast % 10 != 5)
	{
		// 和的那张牌不是5W
		return;
	}
	if (tLast == TILE_ZHONG)
	{
		// 排除风牌
		return;
	}

	pCounter->m_FanCount.m_FanNode[84].bFan = TRUE;
}
void CMJFun::Check085(CMJFanCounter *pCounter) // 摸宝
{
	ENVIRONMENT *pEnv = &pCounter->env;
	BYTE chair = pEnv->byChair;
	BYTE tLast = pEnv->tLast;
	if (pEnv->byFlag != WIN_MOBAO)
	{
		return;
	}
	pCounter->m_FanCount.m_FanNode[85].bFan = TRUE;
}
//胡牌后 番型计算
BOOL CMJFun::Count(FAN_COUNT *&pFanCount)
{
	//ERRLOG("CMJFun::Count()\r\n");
	CMJFanCounter *pCounter = this;
	ENVIRONMENT *pEnv = &pCounter->env;

	//init
	int i;
	for (i = 0; i < MAX_FAN_NUMBER; i++)
	{
		if (m_FanCount.m_FanNode[i].Check != NULL)
		{
			m_FanCount.m_FanNode[i].bFan = FALSE;
			m_FanCount.m_FanNode[i].bCheck = FALSE;
			m_FanCount.m_FanNode[i].byCount = 1;
		}
	}

	//do check
	for (i = 0; i < MAX_ENV_FAN; i++)
	{	
		int byDoCheckType = pEnv->byDoCheck[i];
		// printf("CMJFun::byDoCheckType= %d\n", byDoCheckType);

		if (byDoCheckType >= 0 && m_FanCount.m_FanNode[byDoCheckType].Check != NULL)
		{
			COUNTDOCHECK(byDoCheckType);
		}
		else
		{
			break;
		}
	}

	//check and set no check
	for (i = MAX_FAN_NUMBER - 1; i >= 0; i--)
	{
		if (m_FanCount.m_FanNode[i].Check != NULL && m_FanCount.m_FanNode[i].bCheck)
		{
			// printf("CMJFun::Count...Check= %d\n", i);
			m_FanCount.m_FanNode[i].Check(this);

			if (m_FanCount.m_FanNode[i].bFan)
			{
				for (int j=0; j<MAX_ENV_FAN; j++)
				{
					if (i == pEnv->byEnvFan[j].byFanType)
					{	
						// printf("CMJFun::Count...byFanType=%d\n", i);
						//set no check
						for (int k=0; k<MAX_ENV_FAN; k++)
						{
							int byNoCheckType = pEnv->byEnvFan[j].byNoCheck[k];
							// printf("CMJFun::Count...byNoCheckType=%d\n", byNoCheckType);
							if (byNoCheckType != i && byNoCheckType >= 0 && m_FanCount.m_FanNode[byNoCheckType].Check != NULL)
							{
								COUNTNOCHECK(byNoCheckType);
							}
							if (byNoCheckType < 0)
							{
								break;
							}
						}
						break;
					}
				}
			}
		}
	}

	// 返回详细信息
	pFanCount = &m_FanCount;

	return TRUE; 
}

//客户端胡牌提示
BOOL CMJFun::HuPaiCount(HUPAI_COUNT *&pHuPaiCount)
{
	CMJFanCounter *pCounter = this;
	ENVIRONMENT *pEnv = &pCounter->env;
	CTiles tilesHand;
	CTiles tilesTempHand;
	CTiles temp;
	BYTE chair = pEnv->byChair;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	int i;
	int j;
	CTiles tilesAll;
	tilesAll.ReleaseAll();
	CMJFanCounter::CollectAllTile(tilesAll, *pEnv, chair);
	//所有癞子牌
	CTiles tLaiziCards;
	tLaiziCards.ReleaseAll();
	for (i = 0; i < 4; i++)
	{
		if (pEnv->byLaiziCards[i] > 0)
		{
			tLaiziCards.AddTile(pEnv->byLaiziCards[i]);
		}
	}

	tilesHand.Sort();
	int nLaiziCount = pEnv->laizi;
	int nCardPoolLength = 37;
	memset(&m_HuPaiCount, 0, sizeof(HUPAI_COUNT));
	for (i = 0; i < tilesHand.nCurrentLength; i++)
	{
		int nFlagIndex = 0;
		//不检查出同样的牌
		if (i+1 == tilesHand.nCurrentLength || tilesHand.tile[i] != tilesHand.tile[i + 1])
		{
			//删除要出的牌
			//每次判断要重置手牌
			tilesTempHand.ReleaseAll();
			tilesTempHand.AddTiles(tilesHand);
			tilesTempHand.DelTile(tilesHand.tile[i]);
			//要出的牌
			m_HuPaiCount.m_HuPaiNode[i].szGiveCard = tilesHand.tile[i];
			//printf("=HHHHHHH===GIVE===11==szGiveCard[%d]==%d\n", i, tilesHand.tile[i]);

			//如果要出的牌是癞子，癞子数减1
			if (tLaiziCards.IsHave(tilesHand.tile[i]))
			{
				//printf("==11==chu laizi nLaiziCount==%d\n", nLaiziCount);
				nLaiziCount = nLaiziCount - 1;
			}
			int nCardPoolReallyLength = 0;

			//所有手牌,检查是否是游金牌形
			BOOL bIsYouJin = FALSE;
			if (pEnv->checkWinParam.byTwoGoldLimit >= 2 && pEnv->checkWinParam.byTwoGoldLimit <= nLaiziCount)
			{
				CTiles tilesYouJin;
				tilesYouJin.ReleaseAll();
				//癞子数组
				CTiles tilesYouJinLaiZi;
				tilesYouJinLaiZi.ReleaseAll();
				//无癞子癞子手牌
				CTiles tilesYouJinNoLaiZi;
				tilesYouJinNoLaiZi.ReleaseAll();

				tilesYouJin.AddTiles(tilesTempHand);
				//2金或3金及以上要游金
				int nYouJinLaiZiNum = nLaiziCount;
				tilesYouJin.DelTile(pEnv->byLaiziCards[0]);
				nYouJinLaiZiNum = nYouJinLaiZiNum - 1;
				for (int m = 0; m < 4; m++)
				{
					if (pEnv->byLaiziCards[m] > 0)
					{
						for (int n = 0; n < tilesYouJin.nCurrentLength; n++)
						{
							if (tilesYouJin.tile[n] == pEnv->byLaiziCards[m])
							{
								tilesYouJinLaiZi.AddTile(pEnv->byLaiziCards[m]);
							}
						}
					}
				}
				//无癞子手牌
				tilesYouJin.DelTiles(tilesYouJinLaiZi);
				tilesYouJinNoLaiZi.AddTiles(tilesYouJin);
				int nYouJinNoJiangLength = pEnv->checkWinParam.byMaxHandCardLength - 2;
				if (CMJFanCounter::CheckWinNoJiangLaizi(tilesYouJinNoLaiZi, tLaiziCards, nYouJinLaiZiNum, nYouJinNoJiangLength, pEnv->checkWinParam))
				{
					bIsYouJin = TRUE;
				}
			}
			for (j = 1; j <= nCardPoolLength; j++)
			{
				//if (j % 10 != 0 && pEnv->nNSNum[j - 1] != 99999)
				if (j % 10 != 0 && pEnv->nNSNum[j - 1] != 99999)
				{
					nCardPoolReallyLength++;
					//printf("====MAX_CARD_POOL.j=  %d==\n", j);
					//1.遍历增加牌池的SS牌j
					tilesTempHand.AddTile(j);

					//用做判断能否win的牌
					temp.ReleaseAll();
					temp.AddTiles(tilesTempHand);
					//假设拿到的是癞子牌，癞子数加1
					int laizitemp = nLaiziCount;
					BOOL bMoJin = FALSE;
					if (tLaiziCards.IsHave(j))
					{
						bMoJin = TRUE;
						laizitemp = laizitemp + 1;
					}

					//TODO:先判断是否可以检查胡  缺一门的情况
					BOOL bCanCheck = TRUE;
					BOOL bBall = FALSE;
					BOOL bBaboo = FALSE;
					BOOL bChar = FALSE;
					int nColorLimit = pEnv->checkWinParam.byColorLimit;
					if (nColorLimit>0)
					{
						CTiles tilesAllTemp;
						tilesAllTemp.ReleaseAll();
						tilesAllTemp.AddTiles(tilesAll);
						//这个牌应该是检查现有的牌
						tilesAllTemp.DelTile(tilesHand.tile[i]);
						tilesAllTemp.AddTile(j);
						for (int k = 0; k < tilesAllTemp.nCurrentLength; k++)
						{
							if (tilesAllTemp.tile[k] >= TILE_EAST)
							{
								if (2 == pEnv->checkWinParam.byColorLimit)
								{
								}
								else
								{
									bCanCheck = FALSE;
								}
							}
							//缺一门支持癞子
							else if (tilesAllTemp.tile[k] >= TILE_CHAR_1
								&& tilesAllTemp.tile[k] <= TILE_CHAR_9
								&& !tLaiziCards.IsHave(tilesAllTemp.tile[k]))
							{
								bChar = TRUE;
							}
							else if (tilesAllTemp.tile[k] >= TILE_BALL_1
								&& tilesAllTemp.tile[k] <= TILE_BALL_9
								&& !tLaiziCards.IsHave(tilesAllTemp.tile[k]))
							{
								bBall = TRUE;
							}
							else if (tilesAllTemp.tile[k] >= TILE_BAMBOO_1
								&& tilesAllTemp.tile[k] <= TILE_BAMBOO_9
								&& !tLaiziCards.IsHave(tilesAllTemp.tile[k]))
							{
								bBaboo = TRUE;
							}
						}
						//缺一门不可胡
						if (bChar && bBall && bBaboo && (nColorLimit == 1 || nColorLimit == 2))
						{
							bCanCheck = FALSE;
						}
						//有缺门不能胡
						if (!bChar || !bBall || !bBaboo && (nColorLimit == 3))
						{
							bCanCheck = FALSE;
						}
						//不能胡清一色
						if (((bChar && !bBall && !bBaboo) || (!bChar && bBall && !bBaboo) || (!bChar && !bBall && bBaboo))
							&& (nColorLimit == 4))
						{
							bCanCheck = FALSE;
						}
					}
					int nKeLimit = pEnv->KeLimit;
					BOOL bHaveKe = FALSE;
					if (nKeLimit)
					{
						CTiles tilesKe;
						for (int ke = 0; ke < temp.nCurrentLength; ke++)
						{
							tilesKe.ReleaseAll();
							tilesKe.AddTile(temp.tile[ke]);
							tilesKe.AddTile(temp.tile[ke]);
							tilesKe.AddTile(temp.tile[ke]);
							if (tilesKe.IsSubSet(temp))
							{
								bHaveKe = TRUE;
							}
						}
						for (int setnum = 0; setnum < pEnv->bySetCount[chair]; setnum++)
						{
							if (pEnv->tSet[chair][setnum][0]== ACTION_TRIPLET
								|| pEnv->tSet[chair][setnum][0] == ACTION_QUADRUPLET
								|| pEnv->tSet[chair][setnum][0] == ACTION_QUADRUPLET_CONCEALED
								|| pEnv->tSet[chair][setnum][0] == ACTION_QUADRUPLET_REVEALED
								|| pEnv->tSet[chair][setnum][0] == ACTION_LIANGXIER)
							{
								bHaveKe = TRUE;
							}
						}

						if (!bHaveKe)
						{
							bCanCheck = FALSE;
						}
					}
					int nYaoJiuLimit = pEnv->checkWinParam.byYaoJiuLimit;
					if (nYaoJiuLimit)
					{
						CTiles tilesAllTemp;
						tilesAllTemp.ReleaseAll();
						tilesAllTemp.AddTiles(tilesAll);
						//这个牌应该是检查现有的牌
						tilesAllTemp.DelTile(tilesHand.tile[i]);
						tilesAllTemp.AddTile(j);
						BOOL bYao = FALSE;
						BOOL bJiu = FALSE;
						BOOL bZi = FALSE;
						for (int k = 0; k < tilesAllTemp.nCurrentLength; k++)
						{
							if (tilesAllTemp.tile[k] % 10 == 1)
							{
								bYao = TRUE;
							}
							if (tilesAllTemp.tile[k] % 10 == 9)
							{
								bJiu = TRUE;
							}
							if (tilesAllTemp.tile[k] > 34)
							{
								bZi = TRUE;
							}
						}
						if ((bYao || bJiu) || bZi)
						{
						}
						else
						{
							bCanCheck = FALSE;
						}
					}
					int nDanDiaoLimit = pEnv->checkWinParam.byDanDiaoLimit;
					if (nDanDiaoLimit == 1 && tilesHand.nCurrentLength == 2)
					{
						CTiles tileAllTemp;
						tileAllTemp.ReleaseAll();
						tileAllTemp.AddTiles(tilesAll);
						if (!CheckIsTripletsHu(tileAllTemp))
						{
							bCanCheck = FALSE;
						}
					}
					if (bCanCheck)
					{
						//检查是否可胡
						BOOL bWin = FALSE;
						//几张癞子牌可胡在这边判断，不用在CheckWin检查
						int byLaiziWinNums = pEnv->checkWinParam.byLaiziWinNums;
						if ( byLaiziWinNums > 0 && byLaiziWinNums <= laizitemp)
						{
							//pEnv->checkWinParam.byLaiziWinNums = 0;
							bWin = TRUE;
						}
						if (pEnv->flower ==8 && pEnv->checkWinParam.nEightFlowerHu ==1)
						{
							bWin = TRUE;
						}
						if (!bWin)
						{
							bWin = CMJFanCounter::CheckWin(temp, laizitemp, tLaiziCards, pEnv->checkWinParam);
						}
						//2金或3金及以上要游金
						int tempjin = 0;
						if (bMoJin)
						{
							tempjin = laizitemp - 1;
						}
						else
						{
							tempjin = laizitemp;
						}
						if (pEnv->checkWinParam.byTwoGoldLimit >= 2 && pEnv->checkWinParam.byTwoGoldLimit <= tempjin)
						{
							if (!bIsYouJin)
							{
								bWin = FALSE;
							}
							
						}
						//pEnv->checkWinParam.byLaiziWinNums = byLaiziWinNums;

						if (bWin)
						{
							nFlagIndex++;
							m_HuPaiCount.m_HuPaiNode[i].bCanHuPai = TRUE;
							m_HuPaiCount.m_HuPaiNode[i].szHuPaiInfo[j - 1].bHu = TRUE;
							m_HuPaiCount.m_HuPaiNode[i].szHuPaiInfo[j - 1].szHuCard = j;
							//计算胡这张牌j 还剩多少个
							int szHuCardleft = 0;
							int nHaveCount = 0;
							for (int k = 0; k < tilesHand.nCurrentLength; k++)
							{
								if (tilesHand.tile[k] == j)
								{
									nHaveCount = nHaveCount + 1;
								}
							}
							szHuCardleft = pEnv->nNSNum[j-1] - nHaveCount;
							if (szHuCardleft < 0)
							{
								szHuCardleft = 0;
							}
							m_HuPaiCount.m_HuPaiNode[i].szHuPaiInfo[j - 1].szHuCardleft = szHuCardleft;

						}
					}

					//2.牌池去掉这张牌j
					tilesTempHand.DelTile(j);						
				}
			}
			//如果要出的牌是癞子，癞子数减1(i判断完了后要加回来)
			if (tLaiziCards.IsHave(tilesHand.tile[i]))
			{
				nLaiziCount = nLaiziCount + 1;
			}
			if (nFlagIndex >= nCardPoolReallyLength || bIsYouJin)
			{
				m_HuPaiCount.m_HuPaiNode[i].flag = 1;
			}
		}
	}


	pHuPaiCount = &m_HuPaiCount;
	return TRUE;
}

//
BOOL CMJFun::TingCount(TING_COUNT *&pTingCount)
{
	CMJFanCounter *pCounter = this;
	ENVIRONMENT *pEnv = &pCounter->env;
	CTiles tilesHand;
	CTiles tilesTempHand;
	CTiles temp;
	BYTE chair = pEnv->byChair;
	CMJFanCounter::CollectHandTile(tilesHand, *pEnv, chair);
	int i;
	int j;
	CTiles tilesAll;
	tilesAll.ReleaseAll();
	CMJFanCounter::CollectAllTile(tilesAll, *pEnv, chair);
	//所有癞子牌
	CTiles tLaiziCards;
	tLaiziCards.ReleaseAll();
	for (i = 0; i < 4; i++)
	{
		if (pEnv->byLaiziCards[i] > 0)
		{
			tLaiziCards.AddTile(pEnv->byLaiziCards[i]);
		}
	}

	tilesHand.Sort();
	int nLaiziCount = pEnv->laizi;
	int nCardPoolLength = 37;
	memset(&m_TingCount, 0, sizeof(TING_COUNT));
	for (i = 0; i < tilesHand.nCurrentLength; i++)
	{
		int nFlagIndex = 0;
		//不检查出同样的牌
		if (i+1 == tilesHand.nCurrentLength || tilesHand.tile[i] != tilesHand.tile[i + 1])
		{
			//删除要出的牌
			//每次判断要重置手牌
			tilesTempHand.ReleaseAll();
			tilesTempHand.AddTiles(tilesHand);
			tilesTempHand.DelTile(tilesHand.tile[i]);
			//要出的牌
			m_TingCount.m_TingNode[i].szGiveCard = tilesHand.tile[i];
			//printf("=HHHHHHH===GIVE===11==szGiveCard[%d]==%d\n", i, tilesHand.tile[i]);

			//如果要出的牌是癞子，癞子数减1
			if (tLaiziCards.IsHave(tilesHand.tile[i]))
			{
				//printf("==11==chu laizi nLaiziCount==%d\n", nLaiziCount);
				nLaiziCount = nLaiziCount - 1;
			}

			//所有手牌,检查是否是游金牌形
			BOOL bIsYouJin = FALSE;
			if (pEnv->checkWinParam.byTwoGoldLimit >= 2 && pEnv->checkWinParam.byTwoGoldLimit <= nLaiziCount)
			{
				CTiles tilesYouJin;
				tilesYouJin.ReleaseAll();
				//癞子数组
				CTiles tilesYouJinLaiZi;
				tilesYouJinLaiZi.ReleaseAll();
				//无癞子癞子手牌
				CTiles tilesYouJinNoLaiZi;
				tilesYouJinNoLaiZi.ReleaseAll();
				tilesYouJin.AddTiles(tilesTempHand);
				//2金或3金及以上要游金
				int nYouJinLaiZiNum = nLaiziCount;
				tilesYouJin.DelTile(pEnv->byLaiziCards[0]);
				nYouJinLaiZiNum = nYouJinLaiZiNum - 1;
				for (int m = 0; m < 4; m++)
				{
					if (pEnv->byLaiziCards[m] > 0)
					{
						for (int n = 0; n < tilesYouJin.nCurrentLength; n++)
						{
							if (tilesYouJin.tile[n] == pEnv->byLaiziCards[m])
							{
								tilesYouJinLaiZi.AddTile(pEnv->byLaiziCards[m]);
							}
						}
					}
				}
				//无癞子手牌
				tilesYouJin.DelTiles(tilesYouJinLaiZi);
				tilesYouJinNoLaiZi.AddTiles(tilesYouJin);
				int nYouJinNoJiangLength = pEnv->checkWinParam.byMaxHandCardLength - 2;
				if (CMJFanCounter::CheckWinNoJiangLaizi(tilesYouJinNoLaiZi, tLaiziCards, nYouJinLaiZiNum, nYouJinNoJiangLength, pEnv->checkWinParam))
				{
					bIsYouJin = TRUE;
				}
			}
			int nCardPoolReallyLength = 0;
			for (j = 1; j <= nCardPoolLength; j++)
			{
				//if (j % 10 != 0 && pEnv->nNSNum[j - 1] != 99999)
				if (j % 10 != 0 && pEnv->nNSNum[j - 1] != 99999)
				{
					nCardPoolReallyLength++;
					//printf("====MAX_CARD_POOL.j=  %d==\n", j);
					//1.遍历增加牌池的SS牌j
					tilesTempHand.AddTile(j);

					//用做判断能否win的牌
					temp.ReleaseAll();
					temp.AddTiles(tilesTempHand);
					//假设拿到的是癞子牌，癞子数加1
					int laizitemp = nLaiziCount;
					BOOL bMoJin = FALSE;
					if (tLaiziCards.IsHave(j))
					{
						bMoJin = TRUE;
						laizitemp = laizitemp + 1;
					}

					//TODO:先判断是否可以检查胡  缺一门的情况
					BOOL bCanCheck = TRUE;
					BOOL bBall = FALSE;
					BOOL bBaboo = FALSE;
					BOOL bChar = FALSE;
					int nColorLimit = pEnv->checkWinParam.byColorLimit;
					if (nColorLimit > 0)
					{
						CTiles tilesAllTemp;
						tilesAllTemp.ReleaseAll();
						tilesAllTemp.AddTiles(tilesAll);
						//这个牌应该是检查现有的牌
						tilesAllTemp.DelTile(tilesHand.tile[i]);
						tilesAllTemp.AddTile(j);
						for (int k = 0; k < tilesAllTemp.nCurrentLength; k++)
						{
							if (tilesAllTemp.tile[k] >= TILE_EAST)
							{
								if (2 == pEnv->checkWinParam.byColorLimit)
								{
								}
								else
								{
									bCanCheck = FALSE;
								}
							}
							//缺一门支持癞子
							else if (tilesAllTemp.tile[k] >= TILE_CHAR_1
								&& tilesAllTemp.tile[k] <= TILE_CHAR_9
								&& !tLaiziCards.IsHave(tilesAllTemp.tile[k]))
							{
								bChar = TRUE;
							}
							else if (tilesAllTemp.tile[k] >= TILE_BALL_1
								&& tilesAllTemp.tile[k] <= TILE_BALL_9
								&& !tLaiziCards.IsHave(tilesAllTemp.tile[k]))
							{
								bBall = TRUE;
							}
							else if (tilesAllTemp.tile[k] >= TILE_BAMBOO_1
								&& tilesAllTemp.tile[k] <= TILE_BAMBOO_9
								&& !tLaiziCards.IsHave(tilesAllTemp.tile[k]))
							{
								bBaboo = TRUE;
							}
						}
						//缺一门不可胡
						if (bChar && bBall && bBaboo && (nColorLimit == 1 || nColorLimit == 2))
						{
							bCanCheck = FALSE;
						}
						//有缺门不能胡
						if (!bChar || !bBall || !bBaboo && (nColorLimit == 3))
						{
							bCanCheck = FALSE;
						}
						//不能胡清一色
						if (((bChar && !bBall && !bBaboo) || (!bChar && bBall && !bBaboo) || (!bChar && !bBall && bBaboo))
							&& (nColorLimit == 4))
						{
							bCanCheck = FALSE;
						}
					}

					int nKeLimit = pEnv->KeLimit;
					BOOL bHaveKe= FALSE;
					if (nKeLimit)
					{
						CTiles tilesKe;
						for (int ke = 0; ke < temp.nCurrentLength; ke++)
						{
							tilesKe.ReleaseAll();
							tilesKe.AddTile(temp.tile[ke]);
							tilesKe.AddTile(temp.tile[ke]);
							tilesKe.AddTile(temp.tile[ke]);
							if (tilesKe.IsSubSet(temp))
							{
								bHaveKe = TRUE;
							}
						}
						if (!bHaveKe)
						{
							bCanCheck = FALSE;
						}
					}
					int nYaoJiuLimit = pEnv->checkWinParam.byYaoJiuLimit;
					if (nYaoJiuLimit)
					{
						CTiles tilesAllTemp;
						tilesAllTemp.ReleaseAll();
						tilesAllTemp.AddTiles(tilesAll);
						//这个牌应该是检查现有的牌
						tilesAllTemp.DelTile(tilesHand.tile[i]);
						tilesAllTemp.AddTile(j);
						BOOL bYao = FALSE;
						BOOL bJiu = FALSE;
						BOOL bZi = FALSE;
						for (int k = 0; k < tilesAllTemp.nCurrentLength; k++)
						{
							if (tilesAllTemp.tile[k] % 10 == 1)
							{
								bYao = TRUE;
							}
							if (tilesAllTemp.tile[k] % 10 == 9)
							{
								bJiu = TRUE;
							}
							if (tilesAllTemp.tile[k] > 34)
							{
								bZi = TRUE;
							}
						}
						if ((bYao && bJiu) || bZi)
						{
						}
						else
						{
							bCanCheck = FALSE;
						}
					}
					int nDanDiaoLimit = pEnv->checkWinParam.byDanDiaoLimit;
					if (nDanDiaoLimit == 1  && tilesHand.nCurrentLength == 2)
					{
						CTiles tileAllTemp;
						tileAllTemp.ReleaseAll();
						tileAllTemp.AddTiles(tilesAll);
						if (!CheckIsTripletsHu(tileAllTemp))
						{
							bCanCheck = FALSE;
						}
					}
					if (bCanCheck)
					{
						//检查是否可胡
						BOOL bWin = FALSE;
						//几张癞子牌可胡在这边判断，不用在CheckWin检查
						int byLaiziWinNums = pEnv->checkWinParam.byLaiziWinNums;
						if ( byLaiziWinNums > 0 && byLaiziWinNums <= laizitemp)
						{
							//pEnv->checkWinParam.byLaiziWinNums = 0;
							bWin = TRUE;
						}
						if (pEnv->flower == 8 && pEnv->checkWinParam.nEightFlowerHu == 1)
						{
							bWin = TRUE;
						}
						//pEnv->checkWinParam.byLaiziWinNums = byLaiziWinNums;
						if (!bWin)
						{
							bWin = CMJFanCounter::CheckWin(temp, laizitemp, tLaiziCards, pEnv->checkWinParam);
						}
						//2金或3金及以上要游金
						int tempjin = 0;
						if (bMoJin)
						{
							tempjin = laizitemp - 1;
						}
						else
						{
							tempjin = laizitemp;
						}
						if (pEnv->checkWinParam.byTwoGoldLimit >= 2 && pEnv->checkWinParam.byTwoGoldLimit <= tempjin)
						{
							if (!bIsYouJin)
							{
								bWin = FALSE;
							}

						}
						if (bWin)
						{
							nFlagIndex++;
							m_TingCount.m_TingNode[i].bCanTing = TRUE;
							m_TingCount.m_TingNode[i].szTingInfo[j - 1].bTing = TRUE;

							//番计算
							CMJFanCounter::FAN_COUNT* pFanCount = NULL;
							this->env.laizi = laizitemp;
							for (int n = 0; n < tilesTempHand.nCurrentLength; n++)
							{
								this->env.tHand[chair][n] = tilesTempHand.tile[n];
								this->env.tLast = j;
							}
							BOOL bRetCode = CountTing(pFanCount);
							m_TingCount.m_TingNode[i].szTingInfo[j - 1].byTingFanNumber = GetFan();
							m_TingCount.m_TingNode[i].szTingInfo[j - 1].szTingCard = j;

							
							//计算自己手上有几张牌 更新剩余牌数 szTingCardleft
							int nHaveCount = 0;
							for (int k = 0; k < tilesHand.nCurrentLength; k++)
							{
								if (tilesHand.tile[k] == j)
								{
									nHaveCount = nHaveCount + 1;
								}
							}
							int szTingCardleft = pEnv->nNSNum[j-1] - nHaveCount;
							// printf("CMJFun::TingCount...card:%d, nHaveCount:%d, nNSNum:%d, szTingCardleft:%d \n", j, nHaveCount, pEnv->nNSNum[j-1], szTingCardleft);
							if (szTingCardleft < 0)
							{
								szTingCardleft = 0;
							}
							m_TingCount.m_TingNode[i].szTingInfo[j - 1].szTingCardleft = szTingCardleft;
						}
					}

					//2.牌池去掉这张牌j
					tilesTempHand.DelTile(j);						
				}
			}

			//如果要出的牌是癞子，癞子数减1(i判断完了后要加回来)
			if (tLaiziCards.IsHave(tilesHand.tile[i]))
			{
				nLaiziCount = nLaiziCount + 1;
			}
			if (nFlagIndex >= nCardPoolReallyLength || bIsYouJin)
			{
				m_TingCount.m_TingNode[i].flag = 1;
			}
		}
	}
	pTingCount = &m_TingCount;
	return TRUE;
}
// 听牌时的检查番，不再检查天地胡及其他一些特殊番
BOOL CMJFun::CountTing(FAN_COUNT *&pFanCount)
{
	// ERRLOG("CMJFun::Count()\r\n");
	CMJFanCounter *pCounter = this;
	ENVIRONMENT *pEnv = &pCounter->env;

	//init
	int i;
	for (i = 0; i < MAX_FAN_NUMBER; i++)
	{
		if (m_FanCount.m_FanNode[i].Check != NULL)
		{
			m_FanCount.m_FanNode[i].bFan = FALSE;
			m_FanCount.m_FanNode[i].bCheck = FALSE;
			m_FanCount.m_FanNode[i].byCount = 1;
		}
	}

	//do check
	for (i = 0; i < MAX_ENV_FAN; i++)
	{	
		int byDoCheckType = pEnv->byDoCheck[i];
		// printf("CMJFun::byDoCheckType= %d\n", byDoCheckType);

		if (byDoCheckType >= 0 && m_FanCount.m_FanNode[byDoCheckType].Check != NULL)
		{
			COUNTDOCHECK(byDoCheckType);
		}
		else
		{
			break;
		}
	}

	//check and set no check
	for (i = MAX_FAN_NUMBER - 1; i >= 0; i--)
	{
		if (m_FanCount.m_FanNode[i].Check != NULL && m_FanCount.m_FanNode[i].bCheck)
		{
			// printf("CMJFun::Count...Check= %d\n", i);
			m_FanCount.m_FanNode[i].Check(this);

			if (m_FanCount.m_FanNode[i].bFan)
			{
				for (int j=0; j<MAX_ENV_FAN; j++)
				{
					if (i == pEnv->byEnvFan[j].byFanType)
					{	
						// printf("CMJFun::Count...byFanType=%d\n", i);
						//set no check
						for (int k=0; k<MAX_ENV_FAN; k++)
						{
							int byNoCheckType = pEnv->byEnvFan[j].byNoCheck[k];
							// printf("CMJFun::Count...byNoCheckType=%d\n", byNoCheckType);
							if (byNoCheckType != i && byNoCheckType >= 0 && m_FanCount.m_FanNode[byNoCheckType].Check != NULL)
							{
								COUNTNOCHECK(byNoCheckType);
							}
							if (byNoCheckType < 0)
							{
								break;
							}
						}
						break;
					}
				}
			}
		}
	}

	// 返回详细信息
	pFanCount = &m_FanCount;

	return TRUE;
}

BOOL CMJFun::GetScore(int nScore[4]) // 血战中，计算一次胡的成绩。而不是总成绩。
{
	return CHD_SetRecordAndGetScore(nScore);
}

BOOL CMJFun::CHD_SetRecordAndGetScore(int nScore[4]) // 血战模式记分。一次胡的分，而非总分
{
	return TRUE;
}

BYTE CMJFun::GetFan()
{
	BYTE byFan = 0;
	for (int i = 0; i < MAX_FAN_NUMBER; i++)
	{
		if (m_FanCount.m_FanNode[i].bFan)
		{
			byFan += m_FanCount.m_FanNode[i].byFanNumber * m_FanCount.m_FanNode[i].byCount;
		}
	}
	return byFan;
}

BYTE CMJFun::GetFanMuTi()
{
	BYTE byFan = 1;
	for (int i = 0; i < MAX_FAN_NUMBER; i++)
	{
		if (m_FanCount.m_FanNode[i].bFan)
		{
			byFan = byFan * m_FanCount.m_FanNode[i].byFanNumber;
		}
	}
	return byFan;
}

void CMJFun::InitForNext()
{
	int i = 0;
	int j = 0;
	for (i = 0; i < 4; i++)
	{
		m_nZiMoJiaDi[i] = 0;
	}
}
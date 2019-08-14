#include "environment.h"

void PrintEnv(const ENVIRONMENT* pstEnv)
{
	printf("gamestyle:%d\n", pstEnv->gamestyle);
    printf("byChair:%d\n", pstEnv->byChair);
    printf("byTurn:%d\n", pstEnv->byTurn);
    printf("tLast:%d\n", pstEnv->tLast);
    printf("byFlag:%d\n", pstEnv->byFlag);
    printf("byRoundWind:%d\n", pstEnv->byRoundWind);
    printf("byPlayerWind:%d\n", pstEnv->byPlayerWind);
    printf("byTilesLeft:%d\n", pstEnv->byTilesLeft);

    printf("byHandCount:%d %d %d %d\n", pstEnv->byHandCount[0], pstEnv->byHandCount[1], pstEnv->byHandCount[2], pstEnv->byHandCount[3]);
    for (int i = 0; i < 4; ++i)
    {
        printf("tHand[%d]: ", i);
        for (int j = 0; j < pstEnv->byHandCount[i]; ++j)
        {
            printf("%d ", pstEnv->tHand[i][j]);
        }
        printf("\n");
    }
    printf("byTing:%d %d %d %d\n", pstEnv->byTing[0], pstEnv->byTing[1], pstEnv->byTing[2], pstEnv->byTing[3]);
    printf("byFlowerCount:%d %d %d %d\n", pstEnv->byFlowerCount[0], pstEnv->byFlowerCount[1], pstEnv->byFlowerCount[2], pstEnv->byFlowerCount[3]);
    printf("byDoFirstGive:%d %d %d %d\n", pstEnv->byDoFirstGive[0], pstEnv->byDoFirstGive[1], pstEnv->byDoFirstGive[2], pstEnv->byDoFirstGive[3]);

    printf("byGiveCount:%d %d %d %d\n", pstEnv->byGiveCount[0], pstEnv->byGiveCount[1], pstEnv->byGiveCount[2], pstEnv->byGiveCount[3]);
    for (int i = 0; i < 4; ++i)
    {
        printf("tGives[%d]: ", i);
        for (int j = 0; j < pstEnv->byGiveCount[i]; ++j)
        {
            printf("%d", pstEnv->tGive[i][j]);
        }
        printf("\n");
    }
}
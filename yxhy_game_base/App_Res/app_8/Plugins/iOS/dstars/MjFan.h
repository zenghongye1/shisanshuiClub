#pragma once
#include <string>
#include "MJFunFuZhou.h"

#ifdef WIN32 
#define EXPORT_DLL extern "C" __declspec(dllexport) 
#else
#define EXPORT_DLL extern "C"  
#endif
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


CMJFunFuZhou *fz;

EXPORT_DLL void init();

EXPORT_DLL BOOL TingCount();

EXPORT_DLL void setEnvironment(tagENVIRONMENT& env);

EXPORT_DLL void getTingCount(tagTING_COUNT& tn);







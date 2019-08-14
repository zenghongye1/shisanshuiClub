#pragma once
#include <string>
#include "mj/MJFun.h"

#ifdef WIN32 
	#define EXPORT_DLL extern "C" __declspec(dllexport) 
#else
	#define EXPORT_DLL extern "C"  
#endif

//----------------------------------------------------------------------
//胡牌信息
typedef struct tagHUPAIINFO_NODE
{
	BOOL		bHu;					//每种胡是否满足
	BYTE        szHuCard;               //听的牌
	BYTE        szHuCardleft;           //听的牌剩余几张

}HUPAIINFO_NODE;

typedef struct tagHUPAI_NODE
{
	HUPAIINFO_NODE        	szHuPaiInfo[MAX_CARD_POOL]; //胡的牌
	BYTE				 	szGiveCard;                 //出的牌
	BYTE					flag;						//1表示胡所有
	BOOL					bCanHuPai;					//出这张牌是否能胡
}HUPAI_NODE;

typedef	struct tagHUPAI_COUNT
{
	HUPAI_NODE	m_HuPaiNode[MAX_CARD_LENGTH];
}HUPAI_COUNT;

//----------------------------------------------------------------------
CMJFun *fz = NULL;

/// <summary>
/// 初始化胡牌提示系统参数
/// </summary>
/// <param name="byStyle"> 模式，0: --普通模式， 1: --血战模式</param>
/// <param name="bZiMoJiaDi">自摸加底标志</param>
/// <param name="bJiaJiaYou">家家有标志</param>
EXPORT_DLL void initLib(BYTE byStyle = 0, BOOL bZiMoJiaDi = FALSE, BOOL bJiaJiaYou = FALSE);

/// <summary>
/// 检查是否有胡牌提示
/// </summary>
/// <return>1:表示有胡牌提示,其他值:表示没有胡牌提示</param>
EXPORT_DLL int checkHuPaiCount();

/// <summary>
/// 设置胡牌提示游戏环境
/// <param name="env">游戏环境</param>
/// </summary>
EXPORT_DLL int setEnvironment(tagENVIRONMENT* env);

/// <summary>
/// 获取胡牌提示信息
/// <param name="tn">胡牌提示对象，用于把C++里的数据传给Unity供Unity使用</param>
/// </summary>
/// <return>0:表示获取胡牌提示信息成功,其他值:表示获取胡牌提示信息失败</param>
EXPORT_DLL int getHuPaiCount(HUPAI_COUNT* tn);

/// <summary>
/// 获取胡牌提示库的版本信息
/// </summary>
EXPORT_DLL int getVersion();
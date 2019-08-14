#pragma once
#include <string>
#include "mj/MJFun.h"

#ifdef WIN32 
	#define EXPORT_DLL extern "C" __declspec(dllexport)
#else
	#define EXPORT_DLL extern "C"  
#endif

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
/// <param name="env">游戏环境json字符串</param>
/// </summary>
EXPORT_DLL int setEnvironment(char* env);

/// <summary>
/// 获取胡牌提示信息
/// </summary>
/// <return>获取胡牌提示信息json格式的字符串,格式如下：
/// [{"give":1,"flag":0,"win":[{"nFan":0,"nCard":3,"nLeft":4},{"nFan":0,"nCard":6,"nLeft":3},{"nFan":0,"nCard":14,"nLeft":4}, {...}, ...]}, {...}, ...]
/// 
///</return>
EXPORT_DLL char* getHuPaiCount();

/// <summary>
/// 获取胡牌提示库的版本信息
/// </summary>
EXPORT_DLL int getVersion();
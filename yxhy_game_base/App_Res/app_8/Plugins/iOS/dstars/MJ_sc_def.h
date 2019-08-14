#ifndef __MJ_SC_DEF_H__
#define __MJ_SC_DEF_H__

#include <stdlib.h>
#include <string.h>
#define PLAYER_NUMBER		4
#define WATCHER_NUMBER		16
#define MAX_HAND_TILE		17	// 手上最多可以有多少张牌
#define MAX_TOTAL_TILES		144
#define MAX_TOTAL_TILES_108	108
#define MAX_FAN_NUMBER		60	// 最多有多少种番



#define KICK_CANNOT_LOCK_MONEY			1010
#define KICK_NOMONEY					1011
#define KICK_REQUEST_EXIT				1020
#define KICK_OFFLINE					1021
//#define CS_REQUEST_BASE_INFO			301
//#define CS_SELL							302
//#define CS_GIVE							303
//#define	CS_UPDATE_WATCH_OPTION			304
//#define CS_REQUEST_EXIT					305		//玩家向服务器发消息请求退出
//#define CS_REQUEST_EXIT_ANSWER			306		//玩家答复

//so 传给 Client


//MY_NAMESPACE_BEGIN


enum PLAYER_STATUS				//游戏者状态
{
	psNoLogIn		= 0,		//用户未进入
	psSit			= 1,		//用户坐在座位上，没点开始
	psReady			= 2,		//用户已经点了开始，等待其他玩家
	psFlower		= 3,		//补花，刚收到牌时做的
	psGive			= 4,		//出牌
	psWait			= 5,		//等待别人出牌或者选择吃、碰
	psBlock			= 6,		//选择是否吃碰
	psLookOn		= 7,		//旁观
	psOffLine		= 8,		//掉线
	psDingQue		= 9			//定缺
};

enum GAME_STATUS				//游戏状态
{
	gsNoStart		= 0,		//未开始
	gsFlower		= 1,		//补花
	gsGive			= 2,		//等待某玩家出牌，即玩家下一步该出牌
	gsBlock			= 3,		//等待玩家拦牌：吃、碰、杠、和，即下一步该抓牌
	gsSelfBlock		= 4,		//自己抓牌后能碰、和
	gsDingQue		= 5			//等待玩家定缺
};

// 起始：增加人: boat   日期: 2004-3-17
enum ERRCODE
{
    EERROR = 0x000,
    ESUCCESS = 0x001
};
// 终止: 增加人: boat   日期: 2004-3-17

typedef unsigned char TILE;
typedef unsigned char TILE_TYPE;

#define TILE_INVALID	0
#define TILE_BEGIN		1		// 循环时用
#define TILE_CHAR_1		1
#define TILE_CHAR_2		2
#define TILE_CHAR_3		3
#define TILE_CHAR_4		4
#define TILE_CHAR_5		5
#define TILE_CHAR_6		6
#define TILE_CHAR_7		7
#define TILE_CHAR_8		8
#define TILE_CHAR_9		9
#define TILE_BAMBOO_1	11
#define TILE_BAMBOO_2	12
#define TILE_BAMBOO_3	13
#define TILE_BAMBOO_4	14
#define TILE_BAMBOO_5	15
#define TILE_BAMBOO_6	16
#define TILE_BAMBOO_7	17
#define TILE_BAMBOO_8	18
#define TILE_BAMBOO_9	19
#define TILE_BALL_1		21
#define TILE_BALL_2		22
#define TILE_BALL_3		23
#define TILE_BALL_4		24
#define TILE_BALL_5		25
#define TILE_BALL_6		26
#define TILE_BALL_7		27
#define TILE_BALL_8		28
#define TILE_BALL_9		29

#define TILE_EAST		31
#define TILE_SOUTH		32
#define TILE_WEST		33
#define TILE_NORTH		34
#define TILE_ZHONG		35
#define TILE_FA			36
#define TILE_BAI		37

#define TILE_FLOWER_CHUN	41
#define TILE_FLOWER_XIA		42
#define TILE_FLOWER_QIU		43
#define TILE_FLOWER_DONG	44
#define TILE_FLOWER_MEI		45
#define TILE_FLOWER_LAN		46
#define TILE_FLOWER_ZHU		47
#define TILE_FLOWER_JU		48
#define TILE_END			48		// 循环时用

#define	TILE_TYPE_CHAR			1	// 万
#define	TILE_TYPE_BAMBOO		2	// 条
#define	TILE_TYPE_BALL			3	// 筒
#define TILE_TYPE_OTHER			4	// 其他

#define IS_TILE(t) ((t) >= TILE_BEGIN && (t) <= TILE_END)		// 这个宏不准确~
#define TILE_IS_CHAR(t) ((t) >= TILE_CHAR_1 && (t) <= TILE_CHAR_9)
#define TILE_IS_BAMBOO(t) ((t) >= TILE_BAMBOO_1 && (t) <= TILE_BAMBOO_9)
#define TILE_IS_BALL(t) ((t) >= TILE_BALL_1 && (t) <= TILE_BALL_9)


#define IS_TILE_SC(t) (TILE_IS_CHAR(t) || TILE_IS_BAMBOO(t) || TILE_IS_BALL(t))

#define TILE_NAME(t)\
	(TILE_CHAR_1 == (t) ? "一万" : \
	(TILE_CHAR_2 == (t) ? "二万" : \
	(TILE_CHAR_3 == (t) ? "三万" : \
	(TILE_CHAR_4 == (t) ? "四万" : \
	(TILE_CHAR_5 == (t) ? "五万" : \
	(TILE_CHAR_6 == (t) ? "六万" : \
	(TILE_CHAR_7 == (t) ? "七万" : \
	(TILE_CHAR_8 == (t) ? "八万" : \
	(TILE_CHAR_9 == (t) ? "九万" : \
	(TILE_BAMBOO_1 == (t) ? "一条" : \
	(TILE_BAMBOO_2 == (t) ? "二条" : \
	(TILE_BAMBOO_3 == (t) ? "三条" : \
	(TILE_BAMBOO_4 == (t) ? "四条" : \
	(TILE_BAMBOO_5 == (t) ? "五条" : \
	(TILE_BAMBOO_6 == (t) ? "六条" : \
	(TILE_BAMBOO_7 == (t) ? "七条" : \
	(TILE_BAMBOO_8 == (t) ? "八条" : \
	(TILE_BAMBOO_9 == (t) ? "九条" : \
	(TILE_BALL_1 == (t) ? "一筒" : \
	(TILE_BALL_2 == (t) ? "二筒" : \
	(TILE_BALL_3 == (t) ? "三筒" : \
	(TILE_BALL_4 == (t) ? "四筒" : \
	(TILE_BALL_5 == (t) ? "五筒" : \
	(TILE_BALL_6 == (t) ? "六筒" : \
	(TILE_BALL_7 == (t) ? "七筒" : \
	(TILE_BALL_8 == (t) ? "八筒" : \
	(TILE_BALL_9 == (t) ? "九筒" : \
	(TILE_EAST == (t) ? "东风" : \
	(TILE_SOUTH == (t) ? "南风" : \
	(TILE_WEST == (t) ? "西风" : \
	(TILE_NORTH == (t) ? "北风" : \
	(TILE_ZHONG == (t) ? "红中" : \
	(TILE_FA == (t) ? "发财" : \
	(TILE_BAI == (t) ? "白板" : \
	(TILE_FLOWER_CHUN == (t) ? "春" : \
	(TILE_FLOWER_XIA == (t) ? "夏" : \
	(TILE_FLOWER_QIU == (t) ? "秋" : \
	(TILE_FLOWER_DONG == (t) ? "冬" : \
	(TILE_FLOWER_MEI == (t) ? "梅" : \
	(TILE_FLOWER_LAN == (t) ? "兰" : \
	(TILE_FLOWER_ZHU == (t) ? "竹" : \
	(TILE_FLOWER_JU == (t) ? "菊" : \
	"???"))))))))))))))))))))))))))))))))))))))))))


#define TILE_TYPE_NAME(t)\
	(TILE_TYPE_CHAR == (t) ? "万" : (TILE_TYPE_BAMBOO == (t) ? "条" : (TILE_TYPE_BALL == (t) ? "筒" : (TILE_TYPE_OTHER == (t) ? "其他牌类型" : "错误牌类型"))))

#define GET_TILE_TYPE(t)\
	(IS_TILE(t) ? (TILE_IS_CHAR(t) ? TILE_TYPE_CHAR : (TILE_IS_BAMBOO(t) ? TILE_TYPE_BAMBOO : (TILE_IS_BALL(t) ? TILE_TYPE_BALL : TILE_TYPE_OTHER))) : TILE_INVALID)

#define DINGQUE_STATE_NAME(t)\
	(DINGQUE_STATE_NONE == (t) ? "没在定缺状态" : \
	(DINGQUE_STATE_DONE == (t) ? "已选定缺" : \
(DINGQUE_STATE_DOING == (t) ? "正在定缺" : "错误的定缺状态")))

// #define DINGQUE_TYPE_NAME(t)\
// 	(DINGQUE_SELECT_PAI == (t) ? "定牌" : \
// 	(DINGQUE_SELECT_HUASE == (t) ? "定花色" : \
// 	(DINGQUE_AUTO_SELECT == (t) ? "自动定缺" : "错误的定缺类型")))

// #define SHOW_DINGQUE_INFO(type, t)\
// 	switch(type)\
// 	{\
// 	case DINGQUE_SELECT_PAI:\
// 		{\
// 		XDEBUG_INFO("定牌 %s", TILE_NAME(t));\
// 		}\
// 		break;\
// 	case DINGQUE_SELECT_HUASE:\
// 		{\
// 		XDEBUG_INFO("定花色 %s", TILE_TYPE_NAME(t));\
// 		}\
// 		break;\
// 	case DINGQUE_AUTO_SELECT:\
// 		{\
// 		XDEBUG_INFO("自动定缺");\
// 		}\
// 		break;\
// 	default:\
// 		{\
// 		XDEBUG_INFO("定缺类型错误 %d", type);\
// 		}\
// 		break;\
// 	}

//定义吃、碰、杠
#define ACTION_EMPTY				0x0
#define ACTION_COLLECT				0x10
#define ACTION_TRIPLET				0x11
#define ACTION_QUADRUPLET			0x12
#define ACTION_QUADRUPLET_CONCEALED	0x13
#define ACTION_QUADRUPLET_REVEALED	0x14
#define ACTION_WIN					0x15
#define ACTION_TING					0x16
#define ACTION_FLOWER				0x17
#define ACTION_CANCEL_TRAY			0x18
#define ACTION_LOST					0x17	//CHD, 跟ACTION_FLOWER一样

#define ACTION_CANCEL_QUADRUPLET_REVEALED	0x18	// 通知客户端取消一个补杠(用于抢杠的时候)

// 听牌
#define TING_NONE					0x00
#define TING_REQUEST_REVEALED		0x1
#define TING_REQUEST_CONCEALED		0x2
#define TING_REVEALED				0x3
#define TING_CONCEALED				0x4


// 房间类型
#define GAME_STYLE_NORMAL			0x01	// 不记番场
#define GAME_STYLE_GUOBIAO			0x02	// 国标
#define GAME_STYLE_POP				0x03	// 大众麻将

#define GAME_STYLE_CHENGDU			0X04	// 地方麻将:成都麻将
#define GAME_STYLE_HANGZHOU			0x05	// 地方麻将:杭州麻将
#define GAME_STYLE_WUHAN			0x06	// 地方麻将:武汉麻将

#define LOCAL_CHENGDU_NOT_XUEZHAN	0		//成都麻将，非血战模式。
#define LOCAL_CHENGDU_XUEZHAN		1		//成都麻将，血战模式。 

#define GAME_STYLE_ZHENGZHOU			0x11		//--地方麻将:郑州麻将17
#define GAME_STYLE_ZHUMADIAN			0x12		//--地方麻将 : 驻马店麻将18
#define GAME_STYLE_LUOYANG				0x13		//--地方麻将 : 洛阳麻将19

#define GAME_STYLE_SHIJIAZHUANG			0x21		//--地方麻将 : 石家庄麻将33
#define GAME_STYLE_BAZHOU				0x22		//--地方麻将 : 霸州麻将34
#define GAME_STYLE_LANGFANG				0x23		//--地方麻将 : 廊坊麻将35


#define GAME_STYLE_FUZHOU			0x24		//--地方麻将 : 福州麻将
#define GAME_STYLE_QUANZHOU			0x25		//--地方麻将 : 泉州麻将
#define GAME_STYLE_XIAMEN			0x26		//--地方麻将 : 厦门麻将
#define GAME_STYLE_ZHANGZHOU			0x27		//--地方麻将 : 漳州麻将

#define WIN_SELFDRAW					0	// 自摸
#define WIN_GUN							1	// 点炮
#define WIN_GANGDRAW					2	// 杠上花
#define WIN_GANG						3	// 抢杠
#define WIN_GANGGIVE					4	// 杠上炮
#define WIN_CHD_NOTILE					5	// 成都麻将荒牌查大叫查花猪。
#define WIN_CHD_EXIT					6	//有人逃跑

#define GIVE_STATUS_NONE				0		// 普通
#define GIVE_STATUS_GANG				1		// 明杠
#define GIVE_STATUS_GANGGIVE			2		// 开杠后打出来的

#define DRAW_STATUS_NONE				0
#define DRAW_STATUS_GANG				1		// 杠起来的


#endif //__MJ_SC_DEF_H__

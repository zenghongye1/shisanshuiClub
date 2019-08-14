--[[--
 * @Description: msgEventTable  所有事件table
 ]]
require "logic/gameplay/cmd_shisanshui"
require "logic/gameplay/cmd_niuniu"
require "logic/poker_sys/common/cmd/cmd_poker"
local msgEventTable = 
{

-----------------server(websocket)事件--------------------  
  --游戏通用
  ["enter"] = cmdName.GAME_SOCKET_ENTER,            --进入
  ["ready"] = cmdName.GAME_SOCKET_READY,            --准备
  ["game_start"] = cmdName.GAME_SOCKET_GAMESTART,       --游戏开始
  ["win"] = cmdName.MAHJONG_HU_CARD,                      --胡
  ["rewards"] = cmdName.GAME_SOCKET_SMALL_SETTLEMENT,     --结算
  ["points_refresh"] = cmdName.F1_POINTS_REFRESH,       --玩家金币更新
  ["gameend"] = cmdName.GAME_SOCKET_GAMEEND,          --游戏结束
  ["ask_ready"] = cmdName.GAME_SOCKET_ASK_READY,        --通知准备
  ["sync_begin"] = cmdName.GAME_SOCKET_SYNC_BEGIN,      --重连同步开始
  ["sync_table"] = cmdName.GAME_SOCKET_SYNC_TABLE,      --重连同步表
  ["sync_end"] = cmdName.GAME_SOCKET_SYNC_END,        --通知准备
  ["leave"] = cmdName.GAME_SOCKET_PLAYER_LEAVE,         --用户离开
  ["offline"] = cmdName.GAME_SOCKET_OFFLINE,          --用户掉线
  ["chat"] =  cmdName.GAME_SOCKET_CHAT,             --聊天
  ["autoplay"] = cmdName.GAME_SOCKET_AUTOPLAY,          --托管
  ["vote_draw"] =  cmdName.GAME_NIT_VOTE_DRAW,        --请求和局
  ["vote_draw_start"] = cmdName.GAME_VOTE_DRAW_START,     --请求和局开始
  ["vote_draw_end"] = cmdName.GAME_VOTE_DRAW_END,         --请求和局结束
  ["account"] = cmdName.F3_ACCOUNT,             -- 牌局分数
  ["banker"] = cmdName.GAME_SOCKET_BANKER,              --定庄
  ["change_table"] = cmdName.GAME_CHANGE_TABLE,       -- 换桌
  ["alltingType"]=cmdName.GAME_TINGSTATE,               --各家听牌状态
  ["early_settlement"] = cmdName.MSG_EARLY_SETTLEMENT,    --提前结算
  ["account_suspended"] = cmdName.MSG_FREEZE_USER,      --管理员封号
  ["room_owner_suspended"] = cmdName.MSG_FREEZE_OWNER,    --未开局管理员封房主号
  ["totalreward"] = cmdName.GAME_SOCKET_BIG_SETTLEMENT,     --大结算

  ["vote_start_show"] = cmdName.GAME_VOTE_START_SHOW,    ---- 显示请求开始按钮
  ["vote_start_startflag"] = cmdName.GAME_VOTE_STARTFLAG,   --开始手动游戏投票
  ["vote_start"] = cmdName.GAME_VOTE_START,   --投票
  ["vote_start_result"] = cmdName.GAME_VOTE_RESULT, -- 开始游戏投票结果
  ["vote_stop"] = cmdName.GAME_VOTE_STOP, -- 投票过程中有人进来,终止投票

  ["ready_count_timer"] = cmdName.GAME_READY_COUNT_TIMER, -- 人满弹准备倒计时

  --麻将通用

  ["deal"] = cmdName.GAME_SOCKET_GAME_DEAL,           --发牌
  ["showcards"]=cmdName.MAHJONG_SHOWCARD,              --显示手牌
  ["play_start"] = cmdName.MAHJONG_PLAY_CARDSTART,      --打牌开始
  ["ask_play"] = cmdName.MAHJONG_ASK_PLAY_CARD,         --提示出牌
  ["play"] = cmdName.MAHJONG_PLAY_CARD,             --出牌
  ["give_card"] = cmdName.MAHJONG_GIVE_CARD,        --摸牌
  ["ask_block"] = cmdName.MAHJONG_ASK_BLOCK,        --提示操作
  ["triplet"] = cmdName.MAHJONG_TRIPLET_CARD,         --碰
  ["quadruplet"] = cmdName.MAHJONG_QUADRUPLET_CARD,     --杠
  ["collect"] = cmdName.MAHJONG_COLLECT_CARD,         --吃
  ["ting"] =  cmdName.MAHJONG_HU_TIPS_CARD,             --听
  ["tingType"] = cmdName.MAHJONG_TING_TYPE,           -- 报听 
  ["tingInfo"] =cmdName.MAHJONG_TINGINFO,
  ["yingkou"]=cmdName.MAHJONG_YINGKOU,                  --硬扣
  ["lastlap"] = cmdName.LASTLAP,                      -- 最后一圈牌

  --河南
  ["ask_xiapao"] = cmdName.F1_GAME_GOXIAPAO, 				-- 通知下跑/买马
  ["xiapao"] = cmdName.F1_GAME_XIAPAO,              --下跑
  ["allplayerxiapao"] = cmdName.F1_GAME_ALLXIAPAO,        --所有玩家下跑
  ["laizi"] = cmdName.F1_GAME_LAIZI,              --定赖
  ["ci"]=cmdName.MAHJONG_CI,
  --福州
  ["changeflower"] = cmdName.MAHJONG_CHANGE_FLOWER,       --补花
  ["opengold"] = cmdName.MAHJONG_OPEN_GOLD,               --开金
  ["robgold"] =  cmdName.MAHJONG_ROB_GOLD,                --抢金

  --泉州
  ["youstatus"] = cmdName.MAHJONG_20_YOU_STATUS,  --双游 三游状态

  -- 漳州
  ["followBanker"] = cmdName.MAHJONG_26_FOLLOW_BANKER, -- 分饼（跟庄）

  -- 三明
  ["threePeng"] = cmdName.MAHJONG_43_THREE_PENG, -- 开局三连碰

  -- 莆田十三张
  ["youjin_count"] = cmdName.MAHJONG_YOUJIN_COUNT, -- 游金数

  --十三水
  ["ask_choose"] = cmd_shisanshui.ASK_CHOOSE, 				--选择牌型即摆牌
  ["choose_ok"] = cmd_shisanshui.CHOOSE_OK, 				--某人已经选好牌型
  ["compare_start"] = cmd_shisanshui.COMPARE_START, 		--比牌开始
  ["compare_result"] = cmd_shisanshui.COMPARE_RESULT,		--比牌结果
  ["compare_end"] = cmd_shisanshui.COMPARE_END,				--比牌结束
  ["game_end"] = cmdName.GAME_SOCKET_GAMEEND,				-- 游戏结束
  ["autoplay"] = cmdName.AUTOPLAY ,							--某人(chair1)修改了他的托管状态设置

  -- 内蒙
  ["ask_buyselfdraw"] = cmdName.MAHJONG_ASK_BUYSELFDRAW, -- 通知可以买自摸的玩家买自摸
  ["buyselfdrawResult"] = cmdName.MAHJONG_BUYSELFDRAW_RESULT, -- 通知可以买自摸的玩家买自摸
  ["liangxier"] = cmdName.MAHJONG_LIANGXIER_CARD,     --亮喜儿

  -- 卡五星
  ["buycode"] = cmdName.MAHJONG_BUYCODE,     --结算买马

  -- 捉鸡
  ["jitype"] = cmdName.MAHJONG_JITYPE,     -- 鸡牌播报
  
  -- 吉林
  ["baoInfo"] = cmdName.MAHJONG_BAOINFO,     -- 松原定宝换宝
  ["qiangting"] = cmdName.MAHJONG_QIANGTING,     -- 松原抢听

  --河北
  ["flag_bzz"] = cmdName.MAHJONG_FLAG_BZZ,            --边钻砸消息通知

  --牛牛
	["ask_choosebanker"] = cmd_niuniu.ASK_CHOOSEBANKER,    --提示选庄(固定庄家)
	--["banker"] = cmd_niuniu.BANKER,						   --定庄
	["ask_robbanker"] = cmd_niuniu.ASK_ROBBANKER,			--提示抢庄
	["robbanker"] = cmd_niuniu.ROBBANKER,					--抢庄倍数通知
	["ask_opencard"] = cmd_niuniu.ASK_OPENCARD ,			--提示亮牌(开牌)
	["opencard"] = cmd_niuniu.OPENCARD,						--某人已经亮牌
--------------------逻辑处理通知事件-------------------------------

  --通用
  ["start_flag"] = cmdName.F3_START_FLAG,         --游戏是否开始过 
  ["mid_join"] = cmd_poker.MID_JOIN,              -- 中途加入

 ---牌类
  ["room_sum_score"] = cmd_poker.room_sum_score,			--更新积分 

  --十三水
  ["ask_mult"] = cmd_shisanshui.FuZhouSSS_ASKMULT,			--等待闲家选择倍数
  ["mult"] = cmd_shisanshui.FuZhouSSS_MULT, 				-- 选择倍数通知(回复自己选择倍数)
  ["all_mult"] = cmd_shisanshui.FuZhouSSS_ALLMULT,			--选择倍数通知(所有人的选择倍数)
  ["recommend"] = cmd_shisanshui.Card_RECOMMEND,			--推荐牌
	
	--赢三张
	["turn"] = cmd_poker.turn,
	["ask_action"] = cmd_poker.ask_action,
	["call"] = cmd_poker.call,
	["raise"] = cmd_poker.raise,
	["fold"] = cmd_poker.fold,
	["compare"] = cmd_poker.compare,
	["all_compare"] = cmd_poker.all_compare,
	
}

return msgEventTable
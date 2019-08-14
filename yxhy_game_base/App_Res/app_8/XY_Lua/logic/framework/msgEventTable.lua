--[[--
 * @Description: msgEventTable  所有事件table
 ]]
require "logic/gameplay/cmd_shisanshui"
local msgEventTable = 
{

-----------------server(websocket)事件--------------------
  
  --游戏通用
  ["enter"] = cmdName.GAME_SOCKET_ENTER,   					--进入
  ["ready"] = cmdName.GAME_SOCKET_READY,   					--准备
  ["game_start"] = cmdName.GAME_SOCKET_GAMESTART, 			--游戏开始
  ["win"] = cmdName.MAHJONG_HU_CARD,                  		--胡
  ["rewards"] = cmdName.GAME_SOCKET_SMALL_SETTLEMENT,  		--结算
  ["points_refresh"] = cmdName.F1_POINTS_REFRESH,  			--玩家金币更新
  ["gameend"] = cmdName.GAME_SOCKET_GAMEEND,  				--游戏结束
  ["ask_ready"] = cmdName.GAME_SOCKET_ASK_READY,  			--通知准备
  ["sync_begin"] = cmdName.GAME_SOCKET_SYNC_BEGIN,  		--重连同步开始
  ["sync_table"] = cmdName.GAME_SOCKET_SYNC_TABLE,  		--重连同步表
  ["sync_end"] = cmdName.GAME_SOCKET_SYNC_END,  			--通知准备
  ["leave"] = cmdName.GAME_SOCKET_PLAYER_LEAVE,      		--用户离开
  ["offline"] = cmdName.GAME_SOCKET_OFFLINE,    			--用户掉线
  ["chat"] =  cmdName.GAME_SOCKET_CHAT,     				--聊天
  ["autoplay"] = cmdName.GAME_SOCKET_AUTOPLAY,     			--托管
  ["vote_draw"] =  cmdName.GAME_NIT_VOTE_DRAW,   			--请求和局
  ["vote_draw_start"] = cmdName.GAME_VOTE_DRAW_START,  		--请求和局开始
  ["vote_draw_end"] = cmdName.GAME_VOTE_DRAW_END,     		--请求和局结束
  ["account"] = cmdName.F3_ACCOUNT,							-- 牌局分数
  
  ["early_settlement"] = cmdName.MSG_EARLY_SETTLEMENT,		--提前结算
  ["account_suspended"] = cmdName.MSG_FREEZE_USER,			--管理员封号
  ["room_owner_suspended"] = cmdName.MSG_FREEZE_OWNER,		--未开局管理员封房主号


  --麻将通用
  ["banker"] = cmdName.F1_GAME_BANKER,    					--定庄
  ["deal"] = cmdName.GAME_SOCKET_GAME_DEAL,      			--发牌
  ["play_start"] = cmdName.MAHJONG_PLAY_CARDSTART, 			--打牌开始
  ["ask_play"] = cmdName.MAHJONG_ASK_PLAY_CARD, 				--提示出牌
  ["play"] = cmdName.MAHJONG_PLAY_CARD,     				--出牌
  ["give_card"] = cmdName.MAHJONG_GIVE_CARD, 				--摸牌
  ["ask_block"] = cmdName.MAHJONG_ASK_BLOCK, 				--提示操作
  ["triplet"] = cmdName.MAHJONG_TRIPLET_CARD,  				--碰
  ["quadruplet"] = cmdName.MAHJONG_QUADRUPLET_CARD,  		--杠
  ["collect"] = cmdName.MAHJONG_COLLECT_CARD,   			--吃
  ["ting"] =  cmdName.MAHJONG_TING_CARD,     				--听

  --河南
  ["ask_xiapao"] = cmdName.F1_GAME_GOXIAPAO, 				-- 通知下跑
  ["xiapao"] = cmdName.F1_GAME_XIAPAO,    					--下跑
  ["allplayerxiapao"] = cmdName.F1_GAME_ALLXIAPAO,    		--所有玩家下跑
  ["laizi"] = cmdName.F1_GAME_LAIZI,    					--定赖

  --福州
  ["changeflower"] = cmdName.F3_CHANGE_FLOWER,  			--补花
  ["opengold"] = cmdName.F3_OPEN_GOLD,        				--开金
  ["robgold"] =  cmdName.F3_ROB_GOLD,      					--抢金

  --十三水
  ["ask_choose"] = cmd_shisanshui.ASK_CHOOSE, 				--选择牌型即摆牌
  ["choose_ok"] = cmd_shisanshui.CHOOSE_OK, 				--某人已经选好牌型
  ["compare_start"] = cmd_shisanshui.COMPARE_START, 		--比牌开始
  ["compare_result"] = cmd_shisanshui.COMPARE_RESULT,		--比牌结果
  ["compare_end"] = cmd_shisanshui.COMPARE_END,				--比牌结束
  ["game_end"] = cmdName.GAME_SOCKET_GAMEEND,				-- 游戏结束
  ["autoplay"] = cmdName.AUTOPLAY ,							--某人(chair1)修改了他的托管状态设置


--------------------逻辑处理通知事件-------------------------------

  --通用
  ["start_flag"] = cmdName.F3_START_FLAG,					--游戏是否开始过

  --十三水
  ["room_sum_score"] = cmd_shisanshui.ROOM_SUM_SCORE,		--重入更新积分
  ["ask_mult"] = cmd_shisanshui.FuZhouSSS_ASKMULT,			--等待闲家选择倍数
  ["mult"] = cmd_shisanshui.FuZhouSSS_MULT, 				-- 选择倍数通知(回复自己选择倍数)
  ["all_mult"] = cmd_shisanshui.FuZhouSSS_ALLMULT,			--选择倍数通知(所有人的选择倍数)
  ["recommend"] = cmd_shisanshui.Card_RECOMMEND,			--推荐牌
}

return msgEventTable
--[[--
 * @Description: 在这里放置所有的命令字，所有在lua内部使用
                 Notifier.regist(cmdName,fnCallback,context)
                 Notifier.dispatchCmd(cmdName , param)
                 进行事件注册及触发所使用的cmdName，必须在这里定义，从而避免命令字覆盖
 * @Author:      shine
 * @FileName:    cmdName.lua
 * @DateTime:    2017-05-16 11:50:39
 ]]
----------------------------------------------------------------
--cmd消息过多，增加一些外部模块消息在此申明
--require "xxxx"
cmdName = {}
cmdName.LOGIN_OK 					 = "LOGIN_OK"  		-- 命令字示例
cmdName.RECONNECT_OK				 = "RECONNECT_OK"  	-- 断线重连的情况,与login区分
cmdName.MSG_WAIT_ENTER_GAME_FINISH 	 = "MSG_WAIT_ENTER_GAME_FINISH" --时序问题登录等待数据返回
cmdName.MSG_LOST_CONNECT_TO_SERVER 	 = "MSG_LOST_CONNECT_TO_SERVER"	-- 断线

--///////////////////////////////////////跳转页面命令start///////////////////////////////////////
cmdName.SHOW_PAGE 			= "SHOW_PAGE"                   -- 显示页面
cmdName.SHOW_PAGE_HALL 		= "SHOW_PAGE_HALL"         		-- 大厅界面
cmdName.SHOW_PAGE_PLAY 		= "SHOW_PAGE_PLAY"        		-- 游戏界面
cmdName.SHOW_PAGE_PACK	    = "SHOW_PAGE_PACK"        		-- 背包
cmdName.SHOW_PAGE_SETTING 	= "SHOW_PAGE_SETTING"   		-- 设置
cmdName.SHOW_PAGE_SHOP 		= "SHOW_PAGE_SHOP"         		-- 商店
--///////////////////////////////////////跳转页面命令end///////////////////////////////////////

--///////////////////////////////////////跳转页场景命令start///////////////////////////////////////
cmdName.SHOW_SCENE 			= "SHOW_SCENE"  -- 准备场景跳转 参数1：scene_type
--///////////////////////////////////////跳转页场景命令end///////////////////////////////////////

cmdName.NETWORK_CONNECTION_CLOSE      = "NETWORK_CONNECTION_CLOSE"  -- 网络链接断开
cmdName.MSG_Refresh_NET_STATE_UI 	  = "MSG_Refresh_NET_STATE_UI"  --刷新网络状态UI
cmdName.MSG_APP_NOTIFY 			 	  = "MSG_APP_NOTIFY" 			-- 游戏从后台启动
cmdName.MSG_DESTROY_VERSION_UPDATE_UI = "MSG_DESTROY_VERSION_UPDATE_UI"	--销毁版本更新UI


cmdName.MSG_LOGOUT_GAME  = "MSG_LOGOUT_GAME"    --登出游戏
cmdName.MSG_HEART_BEAT   = "MSG_HEART_BEAT"     --心跳消息
cmdName.MSG_LBL_LINK_MSG = "MSG_LBL_LINK_MSG"   --链接字处理

---------------------------------------游戏类公共事件Begin--------------------------------------------
cmdName.GAME_SOCKET_ENTER 				= "GAME_SOCKET_ENTER" 				-- 进入游戏
cmdName.GAME_SOCKET_ASK_READY			= "GAME_SOCKET_ASK_READY"			--通知可以准备
cmdName.GAME_SOCKET_READY 				= "GAME_SOCKET_READY" 				-- 准备
cmdName.GAME_SOCKET_GAMESTART 			= "GAME_SOCKET_GAMESTART" 			-- 游戏开始
cmdName.GAME_SOCKET_GAME_DEAL 			= "GAME_SOCKET_GAME_DEAL" 			--发牌
cmdName.GAME_SOCKET_GAMEEND				= "GAME_SOCKET_GAMEEND"				-- 游戏结束
cmdName.GAME_SOCKET_SMALL_SETTLEMENT	= "GAME_SOCKET_SMALL_SETTLEMENT" 	-- 小结算
cmdName.GAME_SOCKET_LUMP_SUM 			= "GAME_SOCKET_LUMP_SUM"			--总结算
cmdName.GAME_SOCKET_OFFLINE 			= "GAME_SOCKET_OFFLINE" 			-- 离线
cmdName.GAME_SOCKET_AUTOPLAY 			= "GAME_SOCKET_AUTOPLAY" 			-- 托管
cmdName.GAME_SOCKET_CHAT 				= "GAME_SOCKET_CHAT" 				-- 聊天
cmdName.GAME_SOCKET_GAME_OFFLINE 		= "GAME_SOCKET_GAME_OFFLINE" 		--用户掉线
cmdName.GAME_SOCKET_PLAYER_LEAVE 		= "GAME_SOCKET_PLAYER_LEAVE" 		--用户离开
cmdName.GAME_SOCKET_LEAVE 				= "GAME_SOCKET_LEAVE" 				-- 登出游戏
cmdName.GAME_SOCKET_SYNC_BEGIN 			= "GAME_SOCKET_SYNC_BEGIN" 			--重连同步开始
cmdName.GAME_SOCKET_SYNC_TABLE 			= "GAME_SOCKET_SYNC_TABLE" 			--重连同步表
cmdName.GAME_SOCKET_SYNC_END 			= "GAME_SOCKET_SYNC_END" 			--重连同步结束
cmdName.GAME_SOCKET_CHANGETABLE_ERROR 	= "GAME_SOCKET_CHANGETABLE_ERROR" 	-- 换桌失败
--cmdName.GAME_SOCKET_PLAYSTART 			= "GAME_SOCKET_PLAYSTART" 			-- 牌局开始

---------------------------------------游戏类公共事件End  --------------------------------------------

cmdName.GAME_PHP_GAME_OVER 		= "GAME_PHP_GAME_OVER" -- 总结算
cmdName.GAME_PHP_GET_USERINFO 	= "GAME_PHP_GET_USERINFO" -- 获取玩家数据

--------------------------------- 麻将类公共事件 --------------------------------------------------------
cmdName.MAHJONG_ASK_BLOCK 		= "MAHJONG_ASK_BLOCK" 		-- 通知碰杠吃胡等操作
cmdName.MAHJONG_PLAY_CARDSTART	= "MAHJONG_PLAY_CARDSTART"  --打牌开始
cmdName.MAHJONG_COLLECT_CARD 	= "MAHJONG_COLLECT_CARD" 	--吃牌
cmdName.MAHJONG_TRIPLET_CARD 	= "MAHJONG_TRIPLET_CARD" 	--碰牌
cmdName.MAHJONG_QUADRUPLET_CARD = "MAHJONG_QUADRUPLET_CARD" --杠牌
cmdName.MAHJONG_TING_CARD 		= "MAHJONG_TING_CARD" 		--听牌
cmdName.MAHJONG_HU_CARD 		= "MAHJONG_HU_CARD" 		--胡牌 
cmdName.MAHJONG_PLAY_CARD 		= "MAHJONG_PLAY_CARD" 		-- 出牌
cmdName.MAHJONG_GIVE_CARD 		= "MAHJONG_GIVE_CARD" 		-- 摸牌
cmdName.MAHJONG_ASK_PLAY_CARD 	= "MAHJONG_ASK_PLAY_CARD" 	-- 提示出牌 
--------------------------------------------------------------------------------------------------------------

--------------------------------- 麻将类事件 -------------------------
cmdName.F1_GAME_GOXIAPAO 	= "F1_GAME_GOXIAPAO"		--提示下跑
cmdName.F1_GAME_XIAPAO 		= "F1_GAME_XIAPAO"			--下跑
cmdName.F1_GAME_ALLXIAPAO 	= "F1_GAME_ALLXIAPAO"		--所有玩家下跑
cmdName.F1_GAME_LAIZI 		= "F1_GAME_LAIZI"			--定赖
cmdName.F1_GAME_BANKER 		= "F1_GAME_BANKER"			--定庄
cmdName.F1_GAME_PLAYSTART 	= "F1_GAME_PLAYSTART" 		--打牌开始
cmdName.F1_POINTS_REFRESH 	= "F1_POINTS_REFRESH"		--玩家金币更新

-- 福州麻将事件 F3标识
cmdName.F3_CHANGE_FLOWER 	= "F1_CHANGE_FLOWER"    	--补花
cmdName.F3_OPEN_GOLD 		= "F3_OPEN_GOLD" 			-- 开金
cmdName.F3_ROB_GOLD 		= "F3_ROB_GOLD" 			-- 抢金
cmdName.F3_ACCOUNT 			= "F3_ACCOUNT"   			-- 同步玩家分数
cmdName.F3_START_FLAG 		= "F3_START_FLAG"  			--游戏是否开始过




-------------------------------- 房卡类公共事件 -------------------------------------------------------
cmdName.GAME_NIT_VOTE_DRAW 		= "GAME_NIT_VOTE_DRAW" -- 投票
cmdName.GAME_VOTE_DRAW_START 	= "GAME_VOTE_DRAW_START" -- 投票开始
cmdName.GAME_VOTE_DRAW_END 		= "GAME_VOTE_DRAW_END" -- 投票结束
--------------------------------------------------------------------------------------------------------

-- 消息处理结束
cmdName.MSG_HANDLE_DONE 				= "MSG_HANDLE_DONE"

-- 游戏逻辑事件
cmdName.MSG_COIN_REFRESH 				= "MSG_COIN_REFRESH"      		--金币刷新处理
cmdName.MSG_ROOMCARD_REFRESH			= "MSG_ROOMCARD_REFRESH"    	--房卡刷新处理
cmdName.MSG_NOT_ENTER_STATE 			= "MSG_NOT_ENTER_STATE"     	--不在游戏中通知
cmdName.MSG_HASACTIVITY                 ="MSG_HASACTIVITY"              --活动红点刷新
cmdName.MSG_APP_PAUSE 					= "MSG_APP_PAUSE"    			--切换到后台
cmdName.MSG_SELFRANK_REFRESH			= "MSG_SELFRANK_REFRESH"    	--刷新自己的排行
cmdName.MSG_CHANGE_DESK 				= "MSG_CHANGE_DESK"				--更换桌布
cmdName.MSG_SHAKE 						= "MSG_SHAKE"					--手机震动

cmdName.MSG_VOICE_INFO 					= "MSG_VOICE_INFO"   			--语音信息（包含语音id以及下载路径）
cmdName.MSG_VOICE_PLAY_BEGIN 			= "MSG_VOICE_PLAY_BEGIN" 		--语音播放开始通知（参数1代表玩家座位号）
cmdName.MSG_VOICE_PLAY_END 				= "MSG_VOICE_PLAY_END"    		--语音播放结束通知（参数1代表玩家座位号）

cmdName.MSG_CHAT_TEXT 					= "MSG_CHAT_TEXT"  --文字聊天信息
cmdName.MSG_CHAT_IMAGA 					= "MSG_CHAT_IMAGA"  --图片聊天信息
cmdName.MSG_CHAT_INTERACTIN 			= "MSG_CHAT_INTERACTIN"	--互动聊天信息

cmdName.MSG_UPDATE_ROOM_LEFT_CARD       = "MSG_UPDATE_ROOM_LEFT_CARD" -- 更新房间剩余牌数
cmdName.MSG_UPDATE_PLAYER_HUA_CARD 		= "MSG_UPDATE_PLAYER_HUA_CARD"  -- 更新玩家花牌数量
cmdName.MSG_CLIENT_CHECKT_TING 			= "MSG_CLIENT_CHECKT_TING"  -- 客户端计算听牌
cmdName.MSG_ON_GUO_CLICK 				= "GAME_ON_GUO_CLICK"  -- 过点击

cmdName.MSG_EARLY_SETTLEMENT 			= "MSG_EARLY_SETTLEMENT" --管理员强制提前进行游戏结算
cmdName.MSG_FREEZE_USER 				= "MSG_FREEZE_USER" --冻结帐号
cmdName.MSG_FREEZE_OWNER 				= "MSG_FREEZE_OWNER"		--未开局管理员封房主号


cmdName.MSG_MOUSE_BTN_UP 				= "MSG_MOUSE_BTN_UP"   -- 鼠标/触摸 松手事件  暂时只在麻将内有效
cmdName.MSG_MOUSE_BTN_DOWN 				= "MSG_MOUSE_BTN_DOWN"  -- 鼠标/触摸 点下事件
cmdName.MSG_MOUSE_BTN   				= "MSG_MOUSE_BTN"		-- 鼠标/触摸  正在按下事件

--///////////////////////////////////////游戏事件命令end///////////////////////////////////////
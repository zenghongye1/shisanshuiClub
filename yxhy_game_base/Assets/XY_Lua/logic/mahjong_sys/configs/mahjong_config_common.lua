local  mahjong_config_common = class("mahjong_config_common")
function mahjong_config_common:ctor()

self.MahjongBaseCount = 108 -- 用于计算的基础数
self.MahjongTotalCount = 144  -- 麻将总数量

self.wallDunCountMap = 
{
	18,18,18,18
}

self.beishu_wininfo_dic = {}

-- 场景相关
self.sceneCfg = {} 

self.sceneCfg.wallRootPointPosList = 
{
	Vector3(0, 0.349, -2.79),
	Vector3(2.71, 0.349, -0.125),
	Vector3(0, 0.349, 2.66),
	Vector3(-2.74, 0.349, -0.125),
}

self.sceneCfg.wallPointPosList = {
Vector3(0, 0.643, -2.77), 
Vector3(-0.1,0.643,-2.686),
Vector3(0, 0.643, -2.64), 
Vector3(0.1, 0.643, -2.71)}
self.sceneCfg.wallScale = Vector3(0.89,0.89,0.89)

self.sceneCfg.handPointPosList = {
Vector3(0,0.75,-3.4),
Vector3(0,0.75,-3.33),
Vector3(0,0.75,-3.4),
Vector3(0,0.75,-3.38)
}
self.sceneCfg.SecHandPoint={
Vector3(0,0.75,-3.4),
Vector3(0,0.75,-3.33),
Vector3(0,0.75,-3.4),
Vector3(0,0.75,-3.38)
}

-- 需要隐藏的花位置
self.sceneCfg.hideHuaPointPos = Vector3(-2.42, 0.7, -1.93)

self.sceneCfg.tableHuaPointPosList = 
{
	Vector3(2.46, 0.62, -2.59),
	Vector3(2.36, 0.62, -3.29),
	Vector3(2.571, 0.62, -2.554),
	Vector3(2.555, 0.62, -2.45),
}

self.sceneCfg.huaLineCountList = {1,2,1,2}


self.sceneCfg.outPointPosList = 
{
	Vector3(-0.6, 0.7, -1.08),
	Vector3(-0.69, 0.7, -1),
	Vector3(-0.589, 0.7, -1),
	Vector3(-0.46, 0.7, -1.01),
}


-- 游戏阶段
self.game_state = {
    none         = "none",
    prepare      = "prepare",        --开始
    banker       = "banker",          --定庄
    deal         = "deal",               --抓牌
    round        = "round",        --游戏阶段
    reward       = "reward",       --结算
    gameend      = "gameend",       --结束
}

self.mahjongSyncGameState = 
{
    reward = 0,  --结算阶段 
    gameend = 100, --结束阶段
    prepare = 200, --准备阶段
    xiapao = 300, -- 下跑  发牌之前显示
    deal = 400,  -- 发牌
    laizi = 500, --癞子
    changeflower = 510, -- 补花
    opengold = 520, -- 开金
    buyselfdraw = 530, -- 买自摸
    round = 600, -- 出牌阶段
}

-- 出牌一行数量
self.outCardLineNumMap = 
{
	[2] = 14,
	[3] = 8,
	[4] = 6
}

-- 不需要播放声音的牌型
self.ignoreSound = {} 
-- 大结算相关显示
self.big_settlement_mustShow = {} 

-- UI行为相关
self.uiActionCfg = {}
-- gameId, actionname 
self.uiActionCfg.small_reward = {18, "mahjong_action_small_reward_18"}
self.uiActionCfg.total_reward = {0, "mahjong_action_totalreward"}
self.uiActionCfg.account_update = {0, "mahjong_action_account_update"}
self.uiActionCfg.askReady = {0,"mahjong_action_askReady"}
self.uiActionCfg.player_enter = {0,"mahjong_action_playerEnter"}
self.uiActionCfg.player_ready = {0,"mahjong_action_playerReady"}
self.uiActionCfg.player_chat = {0,"mahjong_action_playerChat"}
self.uiActionCfg.player_leave = {0,"mahjong_action_playerLeave"}
self.uiActionCfg.player_offline = {0,"mahjong_action_playerOffline"}
self.uiActionCfg.game_start = {0,"mahjong_action_gameStart"}
self.uiActionCfg.game_banker = {0,"mahjong_action_gameBanker"}
self.uiActionCfg.game_deal = {0,"mahjong_action_gameDeal"}
self.uiActionCfg.game_askBlock = {0,"mahjong_action_gameAskBlock"}
self.uiActionCfg.game_playCard = {0,"mahjong_action_gamePlayCard"}
self.uiActionCfg.game_giveCard = {0,"mahjong_action_gameGiveCard"}
self.uiActionCfg.game_triplet = {0,"mahjong_action_gameTriplet"}
self.uiActionCfg.game_quadruplet = {0,"mahjong_action_gameQuadruplet"}
self.uiActionCfg.game_ting = {0,"mahjong_action_gameTing"}
self.uiActionCfg.game_collect = {0,"mahjong_action_gameCollect"}
self.uiActionCfg.game_bigRewards = {0,"mahjong_action_gameBigRewards"}
self.uiActionCfg.game_end = {0,"mahjong_action_gameEnd"}
self.uiActionCfg.game_win = {0, "mahjong_action_gameWin"}
self.uiActionCfg.game_syncBegin = {0, "mahjong_action_gameSyncBegin"}
self.uiActionCfg.game_syncTable = {0, "mahjong_action_gameSyncTable"}
self.uiActionCfg.game_autoPlay = {0, "mahjong_action_gameAutoPlay"}
self.uiActionCfg.game_askPlay = {0, "mahjong_action_gameAskPlay"}
self.uiActionCfg.game_huaCardUpdate = {0, "mahjong_action_gameHuaCardUpdate"}
self.uiActionCfg.vote_draw = {0, "mahjong_action_voteDraw"}
self.uiActionCfg.vote_start = {0, "mahjong_action_voteStart"}
self.uiActionCfg.vote_end = {0, "mahjong_action_voteEnd"}
self.uiActionCfg.game_tingType={0,"mahjong_action_gameTingType"}
self.uiActionCfg.game_ask_xiaPao = {0, "mahjong_action_askXiaPao"} 
self.uiActionCfg.game_all_xiaPao = {0, "mahjong_action_allXiaPao"} 
self.uiActionCfg.game_xiaPao = {0, "mahjong_action_xiapao"}
self.uiActionCfg.game_lastLap = {0, "mahjong_action_lastLap"}

self.mahjongActionCfg = {}
self.mahjongActionCfg.game_start = {0, "mahjong_mjAction_gameStart"}
self.mahjongActionCfg.game_askPlay = {0, "mahjong_mjAction_gameAskPlay"}
self.mahjongActionCfg.game_changeFlower = {18, "mahjong_mjAction_gameChangeFlower"}

-- 需要播放动画的列表  stat_control 使用
self.stateAnimList = {
	MahjongGameAnimState.start,
	MahjongGameAnimState.changeFlower,
	MahjongGameAnimState.openGold,
	MahjongGameAnimState.grabGold,
	MahjongGameAnimState.none,
}


self.stateAnimMap = {}
-- 预设名，isCommon,动画名，动画时长, 声音
self.stateAnimMap[MahjongGameAnimState.start] = {20008, mahjong_path_enum.mjCommon, "startgame01", 1}
self.stateAnimMap[MahjongGameAnimState.changeFlower] = {20007, mahjong_path_enum.mjCommon,  "hua", 1,"buhua"}
self.stateAnimMap[MahjongGameAnimState.grabGold] = {9004, mahjong_path_enum.game,  "qiangjin", 1}
self.stateAnimMap[MahjongGameAnimState.openGold] = {20015, mahjong_path_enum.game, "kaijin", 1}

self.GetSpecialCardValue = function (value) return value end

-- 替换金牌的值  （白板代替金牌原值）
self.GetReplaceSpecialCardValue = function () return 0 end

end

function mahjong_config_common:SetMahjongTotalCount(hasWind)
	if not hasWind then
		self.MahjongTotalCount = 136 - 28
	else
		self.MahjongTotalCount = 136 
	end
end

function mahjong_config_common:SetWallDunCount(hasWind, p1Seat)
	if not hasWind then		
	    for i=1, #self.wallDunCountMap do  
	    	local p2Seat = p1Seat+1
	    	if p2Seat > 4 then
	    		p2Seat = p2Seat%4
	    	end

	       if (i == p1Seat) or (i == p2Seat) then	       	
	        self.wallDunCountMap[i] = 17 - 3
	       else 
	        self.wallDunCountMap[i] = 17 - 4
	       end
	    end	
	else
		self.wallDunCountMap = {17, 17, 17, 17}
	end
end


return mahjong_config_common
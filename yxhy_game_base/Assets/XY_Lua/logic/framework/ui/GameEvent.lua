local GameEvent = {}


--  基础功能 
GameEvent.LoginSuccess = 1  -- 登录
-- 收到服务器pushmsg协议
GameEvent.OnPushMsg = 2

GameEvent.OnChangeScene = 3  -- 切换场景

GameEvent.OnHallSocketReconnect = 4 -- 大厅socket重连

GameEvent.OnCloseWindow = 10  -- 关闭界面
-- 俱乐部相关
GameEvent.OnSearchClubListReturn = 101  -- 获取俱乐部列表
GameEvent.OnClubInfoUpdate = 102  -- 单个俱乐部信息变化
GameEvent.OnSelfClubNumUpdate = 103  -- 自己俱乐部数量变化（增删）
GameEvent.OnClubMemberUpdate = 104 	 -- 俱乐部人员信息变化
GameEvent.OnClubApplyMemberUpdate = 105  -- 俱乐部申请信息变化
GameEvent.OnClubRoomListUpdate = 106   -- 俱乐部开房信息变化
GameEvent.OnClearFristState = 107  -- 不再是新人
GameEvent.OnCurrentClubChange = 108  -- 当前俱乐部变化
GameEvent.OnClubAgentChange = 109  -- 当前俱乐部变化
GameEvent.OnEnterNewClub = 110    -- 俱乐部申请通过

GameEvent.OnPlayerApplyClubChange = 111  -- 有新的俱乐部申请
GameEvent.OnAllClubRoomListUpdate = 11222   -- 所有俱乐部开房信息变化
GameEvent.OnCanSeeBackSite = 121  -- 查看俱乐部后台权限


GameEvent.OnExpressionPriceUpdate = 130   -- 表情价格刷新

GameEvent.OnAddVote = 201   --- 投票


GameEvent.OnMahjongSceneLoaded = 1001   -- mjScene 加载完成

return GameEvent
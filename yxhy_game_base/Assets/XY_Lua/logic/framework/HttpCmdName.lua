local HttpCmdName = {}

-- 俱乐部相关  club
HttpCmdName.ClubBindAgent = "GameClub.bindAgent"  -- 绑定代理商
HttpCmdName.ClubGetAgentInfo = "GameClub.getAgentInfo" -- 获得自己代理身份
HttpCmdName.ClubCreate  = "CreateClub"  -- 创建俱乐部
HttpCmdName.ClubApply = "ClubApply"  -- 加入俱乐部
HttpCmdName.ClubGetApplyList = "GetClubApplyList" --获得俱乐部申请列表
HttpCmdName.ClubDealClubApply = "DealClubApply" --处理俱乐部申请信息 
HttpCmdName.ClubGetClubUser = "GetClubUser" -- 获得俱乐部成员列表
HttpCmdName.ClubGetUserClubList = "GameClub.getUserClubList" -- 获得用户进入的俱乐部列表
--HttpCmdName.ClubGetAgentClubList = "GetAgentClubList"  --获得自己创建的俱乐部
HttpCmdName.ClubSetManager = "SetClubManager"  -- 设置管理员
HttpCmdName.ClubKickClubUser = "KickClubUser" -- 俱乐部T人
HttpCmdName.ClubQuitClub = "QuitClub" -- 玩家退出俱乐部
HttpCmdName.ClubEditClub = "EditClub" -- 编辑修改俱乐部
HttpCmdName.ClubGetRoomList = "GameClub.getRoomList" -- 获得俱乐部房间列表
HttpCmdName.ClubGetUserAllClubList = "GetUserAllClubList"  --获得用户所有俱乐部,加入的和创建的
HttpCmdName.ClubSearchClubList = "SearchClubList" --获得官方俱乐部列表
HttpCmdName.getUserClubByCid = "GetUserClubByCid"  -- 请求用户加入的指定俱乐部信息
HttpCmdName.BacksiteFlag = "GameClub.backsiteFlag"   -- 是否有查看后台的权限
HttpCmdName.getUserMisdeed = "GameClub.getUserMisdeed"	--查看用户被踢记录
HttpCmdName.joinShareClub = "GameClub.shareClub"		--加入分享的俱乐部
HttpCmdName.getClubInfoByCid = "GetClubInfoByCid"	--根据cid查询俱乐部信息
HttpCmdName.getAllClubRoomList = "GetClubsRooms" -- 获得所有俱乐部房间列表
HttpCmdName.TTHClub="GetRetailClubs"---获得个人俱乐部
HttpCmdName.setClubCfg = "SetClubCfg" -- 设置俱乐部权限
HttpCmdName.DissolutionClub = "DelClub" --解散俱乐部
HttpCmdName.CheckTransferClub = "CheckMoveClub" --获取是否可以转让俱乐部
HttpCmdName.TransferClub = "MoveClub" --转让俱乐部

-- room
HttpCmdName.GetRoomByRno = "GetRoomByRno"
HttpCmdName.ClubCreateClubRoom = "CreateClubRoom" -- 俱乐部开房
HttpCmdName.GetAutoCreateRoom = "GetAutoCreateRoom"--俱乐部自动开房
HttpCmdName.DelAutoCreateRoom = "DelAutoCreateRoom"--删除自动开房
-- user
HttpCmdName.QueryStatus = "QueryStatus"
HttpCmdName.GetGameInfo = "GetGameInfo"
HttpCmdName.GetPaidFace = "GetPaidFace"
HttpCmdName.SendPaidFace = "SendPaidFace"
HttpCmdName.GetRoomRecordList = "GetRoomRecordList"
HttpCmdName.GetRoomRecordInfo = "GetRoomRecordInfo"
HttpCmdName.GetRoomRecordItem = "GetRoomRecordItem"
HttpCmdName.BindPhone = "BindPhone"--用户绑定手机号

-- global
HttpCmdName.GetClientConfig = "getClientConfig"
HttpCmdName.GetCardGameList = "GetCardGameList"   --请求本游戏支持的游戏列表
HttpCmdName.GetCardGameCost = "GetCardGameCost"	  -- 请求游戏的价格配置
HttpCmdName.UserLogin = "UserLogin"  -- 用户登录及注册
HttpCmdName.UserPhoneLogin = "UserPhoneLogin" -- 用户手机登录
HttpCmdName.GetPhoneVerifyCode = "GetPhoneVerifyCode"--获取验证码
HttpCmdName.UpdatePwdByPhone = "UpdatePwdByPhone"--修改手机登录密码

-- app



return HttpCmdName
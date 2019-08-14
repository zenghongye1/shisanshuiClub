local ClubModel = class("ClubModel")
require ("logic/club_sys/ClubUtil")
local http_request_interface = http_request_interface
local HttpCmdName = HttpCmdName
local UIManager = UI_Manager:Instance()
local ClubMemberState = ClubMemberState
local FirstKey = "CLUB_FRIST_PLAY"
local LastClubIDKey = "LAST_CLUB_ID"
local UIManager = UI_Manager:Instance() 

function ClubModel:ctor()
	self.locationTab = {}
	-- 第一版使用，用于遍历显示
	self.locationList = {}
	-- 代理商
	self.agentInfo = nil
	self.firstPlay = true

	if G_isAppleVerifyInvite then
		self.firstPlay = false
	end

	self.clubList = {}
	self.clubMap = {}
	
	self.officalClubList = {}		--官方俱乐部列表
	self.unofficalClubList = {}		--非官方俱乐部列表
	-- 上次登录id
	self.lastClubId = nil
	self.currentClubInfo = nil
	self.currentClubRoomInfos = nil -- 当前俱乐部的开房信息
	
	self.allClubRoomList = {}  --所有俱乐部的房间列表
	self.allClubRoomMap = {} 
	self.allClubRoomNums = 0 	--所有俱乐部房间数量	
	self.roomClubCidList = {}	--俱乐部房间的cid表，用于排序

	-- 只保留一份
	self.currentClubMemberList = {}
	self.currentApplyMemberList = {}

	-- 非俱乐部创建消耗房卡数
	self.noagentclubcost = 300
	-- 代理商创建第二个俱乐部价格
	self.moreclubcost = 30

	-- 是否可以查看管理后台
	self.canSeeBacksite = false

	-- 新加入的俱乐部
	self.newCidMap = {}
	-- cid ---> true     俱乐部是否有新人加入
	self.newApplyMap = {}

	-- 用于心跳
	self.cidList = {}

	self.cachedClubDissolutionNtf = {} --缓存的俱乐部解散提示
	self.cachedClubTransferNtf = {} --缓存的俱乐部转让提示
end

function ClubModel:Init()
	-- ClubUtil.InitGameType()
	self.control = ControlManager:GetCtrl("ClubControl")
	Notifier.regist(HttpCmdName.ClubBindAgent, self.OnResBindAgent, self)
	Notifier.regist(HttpCmdName.ClubGetAgentInfo, self.OnResGetAgentInfo, self)
	Notifier.regist(HttpCmdName.ClubCreate, self.OnResCreateClub, self)
	-- Notifier.regist(HttpCmdName.ClubApply, self.OnResApplyClub, self)
	Notifier.regist(HttpCmdName.ClubGetApplyList, self.OnResGetClubApplyList, self)
	Notifier.regist(HttpCmdName.ClubGetClubUser, self.OnResGetClubUser, self)
	-- Notifier.regist(HttpCmdName.ClubGetUserClubList, self.OnResGetUserClubList, self)
	-- Notifier.regist(HttpCmdName.ClubGetAgentClubList, self.OnResGetAgentClubList, self)
	Notifier.regist(HttpCmdName.ClubSetManager, self.OnResSetManager, self)
	Notifier.regist(HttpCmdName.ClubKickClubUser, self.OnResKickClubUser, self)
	-- Notifier.regist(HttpCmdName.ClubQuitClub, self.OnResQuitClub, self)
	Notifier.regist(HttpCmdName.ClubEditClub, self.OnResEditClub, self)
	Notifier.regist(HttpCmdName.BacksiteFlag, self.OnResBacksizeFlag, self)
	-- Notifier.regist(HttpCmdName.ClubGetRoomList, self.OnResGetRoomList, self)
	Notifier.regist(HttpCmdName.ClubGetUserAllClubList, self.OnResGetUserAllClubList, self)
	Notifier.regist(HttpCmdName.ClubSearchClubList, self.OnResSearchClubList, self)
	Notifier.regist(HttpCmdName.setClubCfg, self.OnResSetClubConfig, self)

	Notifier.regist(GameEvent.LoginSuccess, self.OnLoginSuccess, self)
	Notifier.regist(GameEvent.OnPushMsg, self.OnPushMsg, self)
	Notifier.regist(GameEvent.OnChangeScene, self.OnChangeScene, self)
end

function ClubModel:Clear()
	self.agentInfo = nil
	self.firstPlay = true

	if G_isAppleVerifyInvite then
		self.firstPlay = false
	end

	self.clubList = {}
	self.clubMap = {}
	self.officalClubList = {}		--官方俱乐部列表
	self.unofficalClubList = {}		--非官方俱乐部列表
	-- 上次登录id
	self.lastClubId = nil
	self.currentClubInfo = nil
	self.currentClubRoomInfos = nil -- 当前俱乐部的开房信息
	
	self.allClubRoomList = {}		--所有俱乐部的房间列表
	self.allClubRoomMap = {} 
	self.allClubRoomNums = 0 		--所有俱乐部房间数量
	self.roomClubCidList = {}	--俱乐部房间的cid表，用于排序
	
	-- 只保留一份
	self.currentClubMemberList = {}
	self.currentApplyMemberList = {}

	self.canSeeBacksite = false
	
	self.newApplyMap = {}
	self.newCidMap = {}

	self.cachedClubDissolutionNtf = {} --缓存的俱乐部解散提示
	self.cachedClubTransferNtf = {} --缓存的俱乐部转让提示
end

function ClubModel:OnPushMsg(msgTab)
	if msgTab.type == 10010 then	-- 俱乐部房间信息变化
		--self:ReqGetRoomList()
		self:ReqGetAllRoomList()
	elseif msgTab.type == 10011 then		-- 申请结果处理
		if msgTab.data.type == 1 then
			-- UIManager:FastTip("恭喜你加入俱乐部" .. msgTab.data.cname)
			-- self:ResGetUserAllClubList(true)
			-- if msgTab.data.ctype == 1 then
			-- 	UIManager:CloseUiForms("ClubInfoUI")
			-- 	UIManager:CloseUiForms("ClubSelectUI")
			-- end
			self.newCidMap[msgTab.data.cid] = true
			self:DealClubAccept(msgTab.data.cid, msgTab.data.ctype, msgTab.data.cname,msgTab.data.isEnter)
			if msgTab.data.ctype == 1 then
				UIManager:CloseUiForms("ClubInputUI")
				--				UIManager:CloseUiForms("ClubCreateOrJoinUI")
				-- UIManager:CloseUiForms("ClubInfoUI")
				-- UIManager:CloseUiForms("ClubSelectUI")
			end
			Notifier.dispatchCmd(GameEvent.OnEnterNewClub)
		end
		self:CheckClearFristState()

	elseif msgTab.type == 10012 then		-- 自己被踢出
		UIManager:FastTip("你已被【" .. msgTab.data.cname .. "】俱乐部踢出")
		self:RemoveClub(msgTab.data.cid)
	elseif msgTab.type == 10013 then   -- 刷新俱乐部信息
		self:ReqGetClubInfoByCid(msgTab.data.cid)
		-- self:ResGetUserAllClubList(true)
	elseif msgTab.type == 10014 then  -- 新的申请
		if self.clubMap[msgTab.data.cid] == nil then
			logError('不错在的cid  10014  ' .. msgTab.data.cid)
			return
		end
		if not self:CheckCanSeeApplyList(msgTab.data.cid) then
			logError('不是管理员 '.. msgTab.data.cid)
			return
		end

		self.clubMap[msgTab.data.cid].applyNum = msgTab.data.applyNum
		Notifier.dispatchCmd(GameEvent.OnPlayerApplyClubChange, msgTab.data.cid)
		-- self.newApplyMap[msgTab.data.cid] = true
		-- if self.currentClubInfo ~= nil and self.currentClubInfo.cid == msgTab.data.cid then
		-- Notifier.dispatchCmd(GameEvent.OnPlayerApplyClubChange)
		-- if game_scene.getCurSceneType() == scene_type.HALL and self:IsClubManager() then
		-- 	local view = UIManager:GetUiFormsInShowList("ClubApplyUI")
		-- 	if view == nil or view.IsOpened == false then
		-- 		UIManager:ShowUiForms("ClubApplyUI", nil, nil, self.currentClubInfo.cid)
		-- 	else
		-- 		view:OnOpen(self.currentClubInfo.cid)
		-- 		view:PlayOpenAnimationFinishCallBack()
		-- 	end
		-- end
		-- end
	elseif msgTab.type == 10016 then
		if self.currentClubInfo ~= nil and self.currentClubInfo.cid == msgTab.data.cid then
			self:ReqGetClubUser(msgTab.data.cid)
			self:ReqGetClubInfoByCid(msgTab.data.cid)
		end
	elseif msgTab.type == 10017 then --俱乐部被解散的推送
		local club = self.clubMap[msgTab.data.cid]
		if club ~= nil then
			--您所在的俱乐部【%s】已解散。您可以在首页-俱乐部-加入俱乐部，选择新的俱乐部加入！
			local msgContent = LanguageMgr.GetWord(10304, club.cname)
			if game_scene.getCurSceneType() ~= scene_type.HALL then --当前正在俱乐部房间中
				self.cachedClubDissolutionNtf[#self.cachedClubDissolutionNtf+1] = msgContent
			else
				MessageBox.ShowSingleBox(msgContent)
			end
		end
		self:RemoveClub(msgTab.data.cid)
	elseif msgTab.type == 10018 then --俱乐部转让给我的推送
		--会长【%s】已将俱乐部【%s】转让给您，快去打理您的俱乐部吧！
		local msgContent = LanguageMgr.GetWord(10306, msgTab.data.host_name, msgTab.data.club_name)
		if game_scene.getCurSceneType() ~= scene_type.HALL then --当前正在俱乐部房间中
			self.cachedClubTransferNtf[#self.cachedClubTransferNtf+1] = msgContent
		else
			MessageBox.ShowSingleBox(msgContent)
		end
	end
end

function ClubModel:RemovePlayerApply(cid)
	self.newApplyMap[cid] = nil
	--Notifier.dispatchCmd(GameEvent.OnPlayerApplyClubChange)
end

--单个俱乐部是否有新的申请
function ClubModel:CheckShowApplyHint(cid)
	if self.currentClubInfo == nil then
		return false
	end
	cid = cid or self.currentClubInfo.cid
	if not self:CheckCanSeeApplyList(cid) then
		return false
	end
	local clubInfo = self.clubMap[cid]
	return clubInfo.applyNum ~= nil and clubInfo.applyNum > 0
end

function ClubModel:CheckHasApplyHint()
	for k, v in pairs(self.newApplyMap) do
		if v == true and self:CheckCanSeeApplyList(k) then
			return true
		end
	end
	return false
end


function ClubModel:DealClubAccept(cid ,ctype ,cname ,isEnter)
	self:ReqGetClubInfoByCid(cid, function(clubInfo) 
		if game_scene.getCurSceneType() ~= scene_type.HALL then
			return
		end
		local func = function ()
			self:SetCurrentClubInfo(clubInfo)
--			UIManager:CloseUiForms("ClubInfoUI")
--			UIManager:CloseUiForms("ClubSelectUI")
--			UIManager:CloseUiForms("ClubCreateOrJoinUI")
			--hall_ui:ShowClub()
		end
		local isEnter = (isEnter == 1)		--为1默认进入新加俱乐部
		if ctype ~= 1 then
			if not isEnter then
				MessageBox.ShowYesNoBox(LanguageMgr.GetWord(10081, cname), function() 
					UIManager:CloseUiForms("joinRoom_ui")			
					UIManager:CloseUiForms("openroom_ui")
					UIManager:CloseUiForms("join_ui_new")
					UIManager:CloseUiForms("ClubCreateUI")
					UIManager:ShowUiForms("ClubUI")
					func()
				end)
			else
				UI_Manager:Instance():FastTip(LanguageMgr.GetWord(10051,clubInfo.nickname ,cname), 4)
				func()
			end
		else
			func()
		end
	end)
end


function ClubModel:OnChangeScene()
	if game_scene.getCurSceneType() == scene_type.LOGIN then
		self:Clear()
	elseif game_scene.getCurSceneType() == scene_type.HALL then
		self:ShowClubCachedNtf()
	end
end

--会长解散俱乐部时，俱乐部有已开局未结束的房间，在该房间所有对局结束，且关闭大结算界面后，给这些成员弹出俱乐部已解散提醒
function ClubModel:ShowClubCachedNtf()
	local clubNtfList = {}
	--缓存的俱乐部解散信息
	if #self.cachedClubDissolutionNtf > 0 then
		table.insertto(clubNtfList, self.cachedClubDissolutionNtf)
	end

	--缓存的俱乐部转让信息
	if #self.cachedClubTransferNtf > 0 then
		table.insertto(clubNtfList, self.cachedClubTransferNtf)
	end

	self.cachedClubDissolutionNtf = {}
	self.cachedClubTransferNtf = {}

	--显示俱乐部解散和转让信息提示
	local function ShowNtf()
		LogW("#clubNtfList = "..#clubNtfList)
		if #clubNtfList > 0 then
			MessageBox.ShowSingleBox(clubNtfList[1], function() table.remove(clubNtfList,1) ShowNtf() end, nil, nil, false)
		else
			MessageBox.HideBox()
		end
	end

	ShowNtf()
end

function ClubModel:OnLoginSuccess()
	ClubUtil.InitLocations()
	self.selfPlayerId = data_center.GetLoginUserInfo().uid
	self:LoadNewPlayerState()
	self:LoadLastClubId()
	self:ReqGetAgentInfo()
	self:ResGetUserAllClubList()
	self:ReqBacksiteFlag()
end

function ClubModel:LoadNewPlayerState()
	if PlayerPrefs.HasKey(FirstKey .. self.selfPlayerId) then
		self.firstPlay = false
	end
end

function ClubModel:LoadLastClubId()
	if PlayerPrefs.HasKey(LastClubIDKey .. self.selfPlayerId) then
		self.lastClubId = PlayerPrefs.GetInt(LastClubIDKey .. self.selfPlayerId)
	else
		self.lastClubId = nil
	end
end

function ClubModel:SaveLastClubId(id)
	if self.lastClubId == id then
		return
	end
	self.lastClubId = id
	PlayerPrefs.SetInt(LastClubIDKey .. self.selfPlayerId, id)
end

function ClubModel:CheckClearFristState()
	if self.firstPlay == false then
		return
	end
	self.firstPlay = false
	PlayerPrefs.SetInt(FirstKey .. self.selfPlayerId, 1) 
	Notifier.dispatchCmd(GameEvent.OnClearFristState)
end

--绑定代理商   "exid":推广码
function ClubModel:ReqBindAgent(exid)
	local param = {}
	param.exid = exid
	http_request_interface.SendHttpRequest(HttpCmdName.ClubBindAgent, param)
end
-- agentInfo 暂时不抽成类
--{"uid":2322989,"appid":4,"bid":1,"name":"","status":1,"ctime":1511968543,"parentid":0,"agtype":1,"sharerate":50,"naid":0}
function ClubModel:OnResBindAgent(msgTab)
	if not self:CheckMsgRet(msgTab) then
		return
	end
	UIManager:FastTip(LanguageMgr.GetWord(10045))
	UIManager:CloseUiForms("ClubInputUI")
	self:CheckClearFristState()
	if msgTab.agent == 0 then
		self.agentInfo = nil
	else
		self.agentInfo = msgTab.agent
	end
	Notifier.dispatchCmd(GameEvent.OnClubAgentChange)
	-- 显示俱乐部创建界面
	UIManager:ShowUiForms("ClubCreateUI")
	self:ReqBacksiteFlag()
end

function ClubModel:OnPushBeAgent()
	UIManager:FastTip(LanguageMgr.GetWord(10045))
	http_request_interface.SendHttpRequestWithCallback(HttpCmdName.ClubGetAgentInfo, nil,function (msgTab)
		self:OnResGetAgentInfo(msgTab)
		UI_Manager:Instance():ShowUiForms("ClubCreateUI")
	end)
	self:ReqBacksiteFlag()
end



-- 获取代理商信息
function ClubModel:ReqGetAgentInfo()
	http_request_interface.SendHttpRequest(HttpCmdName.ClubGetAgentInfo, nil)
end

function ClubModel:OnResGetAgentInfo(msgTab)
	if not self:CheckMsgRet(msgTab) then
		return
	end
	if msgTab.agentInfo == 0 then
		self.agentInfo = nil
	else
		self.agentInfo = msgTab.agent
	end
	if self:IsAgent() and msgTab.hasClub and msgTab.hasClub == 0 then
		-- UI_Manager:Instance():ShowUiForms("ClubCreateUI")
		self.isAutoOpenCraeteClub = true
	end
	Notifier.dispatchCmd(GameEvent.OnClubAgentChange)
end

function ClubModel:ReqBacksiteFlag()
	http_request_interface.SendHttpRequest(HttpCmdName.BacksiteFlag, nil)
end

function ClubModel:OnResBacksizeFlag(msgTab)
	if not self:CheckMsgRet(msgTab) then
		return
	end
	self.canSeeBacksite = msgTab.flag == 1 
	Notifier.dispatchCmd(GameEvent.OnCanSeeBackSite)
end


-- 创建俱乐部
function ClubModel:ReqCreateClub(name, gidList, content, locationId, icon, contact)
	local param = {}
	param.cname = name
	param.content = content
	param.position = tonumber(locationId)
	param.gids = gidList
	param.icon = icon
	param.club_phone = contact
	--http_request_interface.SendHttpRequest(HttpCmdName.ClubCreate, param)
	self:SendRequest(HttpCmdName.ClubCreate, param)
end

function ClubModel:OnResCreateClub(msgTab)
	self.isAutoOpenCraeteClub = false
	--UIManager:CloseUiForms("ClubCreateUI")
	ClubUtil.CloseCreateClub()
--	UIManager:CloseUiForms("ClubCreateOrJoinUI")

	-- UIManager:FastTip(LanguageMgr.GetWord(10021, msgTab.club.cname))
	local club = msgTab

	local shareFriendFunc
	shareFriendFunc = function ()
		local shareAgainFunc = function ()
			MessageBox.ShowMultiBox("分享成功，是否继续分享", function ()
				shareFriendFunc()
			end, "是，继续分享", function ()
				UIManager:ShowUiForms("openroom_ui")
			end, "不，去创建房间")
		end
		invite_sys.inviteToClub(club,0,shareAgainFunc)
	end
	local p = "微信"
	if data_center.GetPlatform() == LoginType.QQLOGIN then
		p = "QQ"
	end

	if G_isAppleVerifyInvite then
		MessageBox.ShowSingleBox(LanguageMgr.GetWord(10021, club.cname)) 
	else
		MessageBox.ShowSingleBox(LanguageMgr.GetWord(10021, club.cname),shareFriendFunc,"分享给"..p.."好友") 
	end

	
	self:CheckClearFristState()
	self:AddOrUpdateClub(club)
	self:SetCurrentClubInfo(club)
end


-- 加入俱乐部
function ClubModel:ReqApplyClub(shid, ctype)
	local param = {}
	param.shid = shid 
	--http_request_interface.SendHttpRequestWithCallback(HttpCmdName.ClubApply, param, 
	self:SendRequestWithCalback(HttpCmdName.ClubApply, param, 
		function(msgTab)
			self:OnResApplyClub(msgTab, ctype)
		end, nil)
end

function ClubModel:OnResApplyClub(msgTab, ctype)
	UIManager:CloseUiForms("ClubInputUI")
--	UIManager:CloseUiForms("ClubCreateOrJoinUI")
	if ctype == nil or ctype == 0 then
		UIManager:FastTip(LanguageMgr.GetWord(10042))
	end
	self:CheckClearFristState()
	-- addplayer -> 
end

-- 获得俱乐部申请列表
function ClubModel:ReqGetClubApplyList(cid)

	local param = {}
	param.cid = cid 
	--http_request_interface.SendHttpRequest(HttpCmdName.ClubGetApplyList, param, dontShow)
	self:SendRequest(HttpCmdName.ClubGetApplyList, param)
end

function ClubModel:OnResGetClubApplyList(msgTab)
	self.currentApplyMemberList = msgTab.applylist 
	Notifier.dispatchCmd(GameEvent.OnClubApplyMemberUpdate, nil)
end

--处理俱乐部申请信息  {"cpid":申请id,"type":处理类型0拒绝1同意}
function ClubModel:ReqDealClubApply(cpid, type)
	local param = {}
	param.cpid = cpid
	param.type = type
	--http_request_interface.SendHttpRequestWithCallback(HttpCmdName.ClubDealClubApply, param, 
	self:SendRequestWithCalback(HttpCmdName.ClubDealClubApply, param, 
		function(tab) 
			self:OnResDealClubApply(tab, cpid, type)
		end, nil)
end

function ClubModel:OnResDealClubApply(msgTab, cpid, type)

	if self.currentApplyMemberList == nil then
		return 
	end
	local player = nil
	for i = 1, #self.currentApplyMemberList do
		if self.currentApplyMemberList[i].cpid == cpid then
			player = self.currentApplyMemberList[i]
			player.cpid = nil
			player.logintime = player.atime
			table.remove(self.currentApplyMemberList, i)
			break
		end
	end
	if player == nil then
		return
	end
	if type == 1 then
		if self.currentClubInfo ~= nil then
			self:ReqGetClubUser(self.currentClubInfo.cid)
			self:ReqGetClubInfoByCid(self.currentClubInfo.cid)
		end
		-- if self.currentClubMemberList == nil then
		-- 	self.currentClubMemberList = {}
		-- end
		-- for i = 1, #self.currentClubMemberList do
		-- 	if self.currentClubMemberList[i].uid == player.uid then
		-- 		return
		-- 	end
		-- end
		-- table.insert(self.currentClubMemberList, player)
		-- Notifier.dispatchCmd(GameEvent.OnClubMemberUpdate)
	end
	Notifier.dispatchCmd(GameEvent.OnClubApplyMemberUpdate)
end

--获得俱乐部成员列表 {"cid":俱乐部真实id}
function ClubModel:ReqGetClubUser(cid)
	local param = {}
	param.cid = cid
	--http_request_interface.SendHttpRequest(HttpProxy.HttpHttpMode.Club,HttpCmdName.ClubGetClubUser, param)
	self:SendRequest(HttpCmdName.ClubGetClubUser, param)
end

function ClubModel:OnResGetClubUser(msgTab)
	self.currentClubMemberList = msgTab.userlist
	-- table.sort(self.currentClubMemberList, function(a, b) return self:MemberSortFunc(a,b) end)
	Notifier.dispatchCmd(GameEvent.OnClubMemberUpdate, nil)
end

function ClubModel:MemberSortFunc(playerA, playerB)
	if self.currentClubInfo == nil then
		return false
	end
	if playerA == nil or playerB == nil then
		return false
	end
	if playerA.uid == playerB.uid then
		return false
	end
	if self:CheckIsClubCreater(nil, playerA.uid) then
		return true
	end
	if self:CheckIsClubCreater(nil, playerB.uid) then
		return false
	end

	if self:IsClubManager(nil, playerA.uid) then
		return true
	end

	if self:IsClubManager(nil, playerB.uid) then
		return false
	end

	return false
end

-- --获得用户的俱乐部列表  (参加的俱乐部)
-- function ClubModel:ReqGetUserClubList()
-- 	http_request_interface.SendHttpRequest(HttpCmdName.ClubGetUserClubList, nil)
-- end

-- function ClubModel:OnResGetUserClubList(msgTab)
-- 	if not self:CheckMsgRet(msgTab) then
-- 		return
-- 	end
-- 	self.joinedClubList = msgTab.userclublist
-- end

-- -- 获得代理商创建的俱乐部列表
-- function ClubModel:ReqGetAgentClubList()
-- 	http_request_interface.SendHttpRequest(HttpCmdName.ClubGetAgentClubList, nil)
-- end

-- function ClubModel:OnResGetAgentClubList(msgTab)
-- 	if not self:CheckMsgRet(msgTab) then
-- 		return
-- 	end
-- 	self.createdclubList = msgTab.userclublist
-- 	if #self.createdclubList > 0 then
-- 		UIManager:ShowUiForms("ClubInfoUI", nil, nil, self.createdclubList[1])
-- 	end
-- end

--设置管理员 {"cid":俱乐部真实id,"m_uid":要设置的用户id,"ptype":操作类型(0设置为管理员,1去除管理员身份)}
function ClubModel:ReqSetManager(cid, uid, type)
	local param = {}
	param.cid = cid
	param.m_uid = uid
	param.ptype = type
	self:SendRequest(HttpCmdName.ClubSetManager, param)
end

function ClubModel:OnResSetManager(msgTab)
	self:AddOrUpdateClub(msgTab)
end

--俱乐部T人 {"cid":俱乐部真实id,"k_uid":要T的用户id}
function ClubModel:ReqKickClubUser(cid,uid,kType)
	local param = {}
	param.cid = cid
	param.k_uid = uid
	param.type = kType
	--http_request_interface.SendHttpRequestWithCallback(HttpCmdName.ClubKickClubUser, param, function (msgTab)
	self:SendRequestWithCalback(HttpCmdName.ClubKickClubUser, param, function (msgTab)
		self:OnResKickClubUser(msgTab, cid, uid)
	end)
end

function ClubModel:OnResKickClubUser(msgTab, cid, uid)
	local clubInfo = self.clubMap[cid]
	if clubInfo ~= nil and clubInfo.muids ~= nil then
		for i = 1, #clubInfo.muids do
			if uid == clubInfo.muids[i] then
				table.remove(clubInfo.muids, i)
				break
			end
		end
	end
	self:ReqGetClubUser(self.currentClubInfo.cid)
end

--查看用户被踢出俱乐部劣迹
function ClubModel:ReqGetUserMisdeed(cid,uid,callback)
	local param = {}
	param.cid = cid
	param.k_uid = uid
	http_request_interface.SendHttpRequestWithCallback(HttpCmdName.getUserMisdeed,param,function(msgTab)
		if not self:CheckMsgRet(msgTab) then
			return
		end
		callback(msgTab)
	end)
end

--玩家退出俱乐部 {"cid":俱乐部真实id}
function ClubModel:ReqQuitClub(cid)
	local param = {}
	param.cid = cid
	--http_request_interface.SendHttpRequestWithCallback(HttpCmdName.ClubQuitClub, param, function(msgTab) self:OnResQuitClub(cid, msgTab)end, nil)
	self:SendRequestWithCalback(HttpCmdName.ClubQuitClub, param, function(msgTab) self:OnResQuitClub(cid, msgTab)end)
end

function ClubModel:OnResQuitClub(cid, msgTab)
	UIManager:FastTip(LanguageMgr.GetWord(10052))
	self:RemoveClub(cid)
end

--"ispublic":允许俱乐部展示在个人俱乐部列表中,"allcosthost":俱乐部成员均消耗会长房卡,"mcactuser":管理员可以操作加入/踢出玩家,"mcosthost":管理员开房时消耗会长房卡
function ClubModel:ReqSetClubConfig(cid, ispublic, allcosthost,mcactuser, mcosthost )
	local param = {}
	param.cid = cid
	param.ispublic = ispublic
	param.allcosthost = allcosthost
	param.mcactuser = mcactuser
	param.mcosthost = mcosthost
	self:SendRequest(HttpCmdName.setClubCfg, param)
end

function ClubModel:OnResSetClubConfig(msgTab)
	self:AddOrUpdateClub(msgTab)
end


--编辑修改俱乐部 {"cid":俱乐部真实id必传,"cname":俱乐部名称,"content":内容简介,"position":位置地址}
function ClubModel:ReqEditClub(cid, name, content, gids, icon, position, isPush, contact)
	local  param = {}
	param.cid = cid
	param.cname = name
	param.content = content
	param.gids = gids
	param.icon = icon
	param.position = tonumber(position)
	param.is_push = isPush
	param.club_phone = contact
	--http_request_interface.SendHttpRequest(HttpCmdName.ClubEditClub, param)
	self:SendRequest(HttpCmdName.ClubEditClub, param)
end

function ClubModel:OnResEditClub(param)
	self:AddOrUpdateClub(param)
end

--获得俱乐部房间列表 {"cid":俱乐部真实id必传}
function ClubModel:ReqGetRoomList(force)
	if self.currentClubInfo == nil then
		return
	end
	if not force  and not self.control:CheckCanRequsetRoomList() then
		return
	end
	local  param = {}
	param.cid = self.currentClubInfo.cid
	local cid = self.currentClubInfo.cid
	http_request_interface.SendHttpRequestWithCallback(HttpCmdName.ClubGetRoomList, param,
	function(msgTab, str) 
		self:OnResGetRoomList(cid, msgTab) 
	end, nil, true)
end

function ClubModel:OnResGetRoomList(cid, msgTab)
	if not self:CheckMsgRet(msgTab) then
		return
	end
	if self.currentClubInfo == nil or self.currentClubInfo.cid ~= cid then
		return
	end
	self:FilterRoomList( msgTab.roomlist)
	self.currentClubRoomInfos = msgTab.roomlist
	table.sort(self.currentClubRoomInfos, ClubUtil.RoomListSortFunc)
	Notifier.dispatchCmd(GameEvent.OnClubRoomListUpdate)
end

---获取用户所有俱乐部房间
function ClubModel:ReqGetAllRoomList(force)
	if not self:HasClub() or game_scene.getCurSceneType() ~= scene_type.HALL then
		return
	end
	if not force and not self.control:CheckCanRequsetRoomList() then
		return
	end
	local  param = {}
	HttpProxy.SendRoomRequest(HttpCmdName.getAllClubRoomList,param,
	function(msgTab, str) 
		self:OnResGetAllRoomList(msgTab) 
	end, nil)
end

--获取俱乐部自动开房列表
function ClubModel:ReqGetAutoCreateRoomList(cid,force,callback)
	if not self:HasClub() or game_scene.getCurSceneType() ~= scene_type.HALL then
		return
	end
	if not force and not self.control:CheckCanRequsetRoomList() then
		return
	end
	local  param = {}
	param.cid = cid
	HttpProxy.SendRoomRequest(HttpCmdName.GetAutoCreateRoom,param,
	function(msgTab, str) 
		callback(msgTab)
	end, nil)
end
--删除自动开房房间
function ClubModel:DelAutoCreateRoom(auto_id)
	if not self:HasClub() or game_scene.getCurSceneType() ~= scene_type.HALL then
		return
	end
	local param = {}
	param.auto_id = auto_id
	HttpProxy.SendRoomRequest(HttpCmdName.DelAutoCreateRoom,param, nil, nil)
end
--获取战绩列表
function ClubModel:GetRoomRecordList(param,callback)
	local param = param
	HttpProxy.SendRoomRequest(HttpCmdName.GetRoomRecordList,param,
		function (msgTab,str)
			callback(msgTab)
	end,nil)
end


function ClubModel:OnResGetAllRoomList(msgTab)
	self:FilterRoomList( msgTab.rooms)
	self.allClubRoomList = msgTab.rooms or {}
	self.allClubRoomNums = table.nums(self.allClubRoomList)
	table.sort(self.allClubRoomList, ClubUtil.RoomListSortFunc)
	self.allClubRoomMap = {}
	self.roomClubCidList = {}
	for k,v in ipairs(self.allClubRoomList) do
		if not self.allClubRoomMap[v["cid"]] then
			self.allClubRoomMap[v["cid"]] = {}
			table.insert(self.roomClubCidList,v["cid"])
		end
		table.insert(self.allClubRoomMap[v["cid"]],v)
	end
	table.sort(self.roomClubCidList,function(a,b) return self:CheckCidIsOffical(b) end)	---官方俱乐部cid放在最底下	
	Notifier.dispatchCmd(GameEvent.OnAllClubRoomListUpdate)
end

function ClubModel:GetRoomListByCid(cid)
	if self.currentClubInfo == nil then
		return {}
	end
	if cid == nil then
		cid = self.currentClubInfo.cid
	end
	if self.allClubRoomMap[cid] == nil then
		return {}
	else
		return self.allClubRoomMap[cid]
	end
end


function ClubModel:FilterRoomList(roomList)
	if roomList == nil then 
		return
	end
	for i = #roomList, 1, -1 do
		if roomList[i].cfg ~= nil and (roomList[i].cfg.ishide == 1 or roomList[i].cfg.ishide == true) and roomList[i].uid ~= self.selfPlayerId then
			table.remove(roomList, i)
		end
	end
end
--获得官方俱乐部列表
function ClubModel:ReqSearchClubList(gid, position)
	local param = {}
	param.position = position
	param.gid = gid
	--http_request_interface.SendHttpRequest(HttpCmdName.ClubSearchClubList, param)
	self:SendRequest(HttpCmdName.ClubSearchClubList, param)
end
function ClubModel:ReqSearchOClubList(page,size,callback)
    local param = {}
	param.page = page
	param.size = size
    --http_request_interface.SendHttpRequestWithCallback(HttpCmdName.TTHClub, param, 
    self:SendRequestWithCalback(HttpCmdName.TTHClub, param, 
	function(msgtab)
		if callback then
			callback(msgtab)
		end
	end,nil, true)
end 
function ClubModel:OnResSearchClubList(msgTab)
	if not self:CheckMsgRet(msgTab) then
		return
	end
	self.searchClubList = msgTab.clublist 
	self:SortSearchClub(self.searchClubList)
	--table.sort(self.searchClubList,ClubUtil.SearchClubSortFunc)
	Notifier.dispatchCmd(GameEvent.OnSearchClubListReturn, nil)
end

----获取推荐俱乐部带回调 （临时添加）
function ClubModel:ReqSearchClubListWithCallback(gid,position,callback)
	local param = {}
	param.position = position
	param.gid = gid
	http_request_interface.SendHttpRequestWithCallback(HttpCmdName.ClubSearchClubList, param, 
	function(msgtab)
		if not self:CheckMsgRet(msgtab) then
			return
		end
		if callback then
			callback(msgtab)
		end
	end)
end

function ClubModel:SortSearchClub(list)
	if list == nil or #list == 0 then
		return
	end
	local changeList = {}
	for i = #list, 1, -1 do
		if self:IsClubMember(list[i].cid) then
			table.insert(changeList, {i, list[i]})
			table.remove(list, i)
		end
	end
	for i = #changeList ,1, -1  do
		table.insert(list, changeList[i][2])
	end
end

function ClubModel:ReqGetClubInfoByCid(cid, callback)
	local param = {}
	param.cid = cid
	self:SendRequestWithCalback(HttpCmdName.getUserClubByCid, param, 
	function(msgtab) 
		self:OnResGetClubInfoByCid(msgtab, cid, callback)
	end, nil)
end

---获取未加入的俱乐部信息
function ClubModel:ReqGetJoinClubInfoByCid(cid, callback)
	local param = {}
	param.cid = cid
	self:SendRequestWithCalback(HttpCmdName.getClubInfoByCid, param, 
	function(msgTab) 
		if callback ~= nil then
			callback(msgTab)
		end
	end, nil)
end

function ClubModel:OnResGetClubInfoByCid(msgTab, cid, callback)
	-- 返回不存在 请求全部俱乐部信息
	if msgTab.clublist == nil or #msgTab.clublist == 0 then
		self:ResGetUserAllClubList()
		return
	end
	local clubInfo = msgTab.clublist[1]
	self:AddOrUpdateClub(clubInfo)
	if callback ~= nil then
		callback(clubInfo)
	end
end


function ClubModel:CheckClubIsNew(cid)
	return self.newCidMap[cid] == true
end

function ClubModel:CheckShowApplyUI()
	if not self:HasClub() then
		return
	end
	if self:CheckShowApplyHint(self.currentClubInfo.cid) then
		if game_scene.getCurSceneType() == scene_type.HALL then
			UIManager:ShowUiForms("ClubApplyUI", nil, nil, self.currentClubInfo.cid)
		end
	end
end


--获得用户所有俱乐部,加入的和创建的
function ClubModel:ResGetUserAllClubList(dontShow)
	--http_request_interface.SendHttpRequest(HttpCmdName.ClubGetUserAllClubList, nil, dontShow)
	self:SendRequest(HttpCmdName.ClubGetUserAllClubList)
end

function ClubModel:OnResGetUserAllClubList(msgTab)
	local count = 0
	if self.clubList ~= nil then
		count = #self.clubList
	end
	if msgTab.clublist ~= nil then
		self.clubList = msgTab.clublist
		for i = 1, #self.clubList do
			self.clubMap[self.clubList[i].cid] = self.clubList[i]
		end
	else
		self.clubList = {}
		self.clubMap = {}
	end

	if self:HasClub() then
		if self.lastClubId ~= nil and self.clubMap[self.lastClubId] ~= nil and self.clubMap[self.lastClubId].ctype ~= 1 then
			self:SetCurrentClubInfo(self.clubMap[self.lastClubId], nil, true)
		else
			for i = 1, #self.clubList do
				if self.clubList[i].ctype ~= 1 then
					self:SetCurrentClubInfo(self.clubList[i], nil, true)
					break
				end
			end
		end
		self:CheckClearFristState()
	end
	if count ~= #self.clubList then
		self:ReqGetAllRoomList(true)
		Notifier.dispatchCmd(GameEvent.OnSelfClubNumUpdate)
	else
		Notifier.dispatchCmd(GameEvent.OnClubInfoUpdate)
	end

	-- 刷新所有俱乐部列表
	self.cidList = {}
	if self.clubList ~= nil then
		for i = 1, #self.clubList do
			table.insert(self.cidList, self.clubList[i].cid)
		end
	end
	self:SepClubList()
end

---分离官方俱乐部和非官方俱乐部
function ClubModel:SepClubList()
	if self:HasClub() then
		self.officalClubList = {}
		self.unofficalClubList = {}
		for _,v in ipairs(self.clubList) do 
			if v["ctype"] and v["ctype"] == 1 then
				table.insert(self.officalClubList,v)
			else
				table.insert(self.unofficalClubList,v)
			end
		end
	end
end

function ClubModel:CheckCidIsOffical(cid)
	if self.clubMap[cid] and self.clubMap[cid]["ctype"] == 1 then
		return true
	end
end

function ClubModel:GetClubState(cid)
	local club = self.clubMap[cid]
	if club == nil then
		return ClubMemberState.none 
	end
	if club.uid == self.selfPlayerId then
		return ClubMemberState.agent
	end
	return ClubMemberState.member
end

function ClubModel:GetClubListByType(type)
	local tab = {}
	for i = 1, #self.clubList do
		if self:GetClubState(self.clubList[i].cid) == type then
			table.insert(tab, self.clubList[i])
		end
	end
	return tab
end

function ClubModel:AddOrUpdateClub(clubInfo)
	-- 服务器有时会返回0
	if clubInfo == 0 then
		return
	end
	if self.clubMap[clubInfo.cid] ~= nil then
		if clubInfo.club_phone == nil then
			clubInfo.club_phone = ""
		end
		if clubInfo.is_push == nil then
			clubInfo.is_push = false 
		end
		if clubInfo.content == nil then
			clubInfo.content = ""
		end
		ClubUtil.CopyClubInfo(self.clubMap[clubInfo.cid], clubInfo)
		if self.currentClubInfo ~= nil and self.currentClubInfo.cid == clubInfo.cid then
			self.currentClubInfo = self.clubMap[clubInfo.cid]
		end
		Notifier.dispatchCmd(GameEvent.OnClubInfoUpdate, clubInfo.cid)
	else
		table.insert(self.clubList, clubInfo)
		table.insert(self.cidList, clubInfo.cid)
		self.clubMap[clubInfo.cid] = clubInfo
		if self.currentClubInfo == nil then
			self:SetCurrentClubInfo(clubInfo)
		end
		self:ReqGetAllRoomList()
		self:SepClubList()
		Notifier.dispatchCmd(GameEvent.OnSelfClubNumUpdate, nil)
	end
	-- 清理查询列表
	self.searchClubList = nil
end

function ClubModel:CanCreateClub()
	return self.agentInfo ~= nil and self.agentInfo ~= 0
end

function ClubModel:SetCurrentClubInfo(info, needRefresh ,force)
	if info == nil then
		return
	end
	if not force and self.currentClubInfo ~= nil and info.cid == self.currentClubInfo.cid then
		return
	end
	if self.currentClubInfo ~= nil and info.cid ~= self.currentClubInfo.cid  then
		self:ClearCurrentClubInfo()
	end
	self.currentClubInfo = info
	self:SortClubList()
	self:SaveLastClubId(info.cid)
	--self:ReqGetAllRoomList(true)
	if needRefresh then
		--靠推送 不实时刷新
		--self:ReqGetClubInfoByCid(info.cid)
	end
	Notifier.dispatchCmd(GameEvent.OnCurrentClubChange)
end

function ClubModel:SortClubList()
	-- for i = 1, #self.clubList do
	-- 	if self.clubList[i] == self.currentClubInfo then
	-- 		if i == 1 then
	-- 			return
	-- 		else
	-- 			table.remove(self.clubList, i)
	-- 			table.insert(self.clubList, 1, self.currentClubInfo)
	-- 			return
	-- 		end
	-- 	end
	-- end
end


function ClubModel:RemoveClub(cid)
	if self.clubMap[cid] == nil then
		return
	end
	for i = 1, #self.clubList do
		if self.clubList[i].cid == cid then
			table.remove(self.clubList, i)
			break
		end
	end

	for i =1, #self.cidList do
		if self.cidList[i] == cid then
			table.remove(self.cidList, i)
			break
		end
	end

	self:SepClubList()
	self.clubMap[cid] = nil

	if self.currentClubInfo.cid == cid then
--		UIManager:CloseUiForms("ClubInfoUI")
		-- UIManager:CloseUiForms("ClubMemberUI")
		if self.clubList ==nil or #self.clubList == 0 then
			self:ClearCurrentClubInfo()
		else
			if self.unofficalClubList ~= nil and #self.unofficalClubList > 0 then
				local clubInfo = self.unofficalClubList[1]
				self:SetCurrentClubInfo(clubInfo, true)
			-- else
			-- 	local clubInfo = self.clubList[1]
			-- 	self:SetCurrentClubInfo(clubInfo, true)
			end
		end
	end
	self:ReqGetAllRoomList(true)
	Notifier.dispatchCmd(GameEvent.OnSelfClubNumUpdate, nil)

end

function ClubModel:ClearCurrentClubInfo()
	self.currentClubInfo = nil
	self.currentClubRoomInfos = nil
	-- self.currentClubMemberList = {}
	self.currentApplyMemberList = {}

end

function ClubModel:HasClub()
	return self.clubList ~= nil and #self.clubList > 0  
end

function ClubModel:ClearMemberData()
	self.currentApplyMemberList = nil
	-- self.currentClubMemberList = nil
end

function ClubModel:GetMemberListByType(type)
	if type == ClubMemberEnum.member then
		return self.currentClubMemberList
	else
		return self.currentApplyMemberList
	end
	-- body
end

function ClubModel:IsClubCreater(cid)
	return self:GetClubState(cid) == ClubMemberState.agent
end

function ClubModel:CheckIsClubCreater(cid, uid)
	if cid == nil then
		cid = self.currentClubInfo.cid
	end
	local club = self.clubMap[cid]
	if club == nil then
		return false
	end
	return club.uid == uid
end

function ClubModel:IsClubMember(cid)
	if not self:HasClub() then
		return false
	end
	return self.clubMap[cid] ~= nil
end

function ClubModel:GetHasApplyMemeberList()
	local list = {}
	if not self:HasClub() then
		return list
	end
	for i = 1, #self.clubList do
		if self:CheckCanSeeApplyList(self.clubList[i].cid) and self.clubList[i].applyNum ~= nil and self.clubList[i].applyNum > 0 then
			table.insert(list, self.clubList[i])
		end
	end
	return list
end


-- 查询uid是不是俱乐部管理员，uid为空时，查询自己是不是管理员
function ClubModel:IsClubManager(cid, uid)
	cid = cid or self.currentClubInfo.cid
	uid = uid or self.selfPlayerId
	local clubInfo = self.clubMap[cid]
	if clubInfo == nil then
		return false
	end
	if clubInfo.uid == uid then
		return true
	end
	if clubInfo.muids == nil then
		return false
	end
	for i = 1, #clubInfo.muids do
		if clubInfo.muids[i] == uid then
			return true
		end
	end
	return false
end



-- 能否查看俱乐部申请列表 通过allow_view 判断  1为可以查看
function ClubModel:CheckCanSeeApplyList(cid)
	cid = cid or self.currentClubInfo.cid
	local clubInfo = self.clubMap[cid]
	if clubInfo == nil then
		return false
	end
	if self:IsClubCreater(cid) then
		return true
	elseif self:IsClubManager(cid) and clubInfo.cfg ~= nil and clubInfo.cfg.mcactuser == 1 then
		return true
	else
		return false
	end
end

-- 判断是否消耗会长房卡
function ClubModel:CheckCostCreater(clubInfo)
	if clubInfo.cfg == nil then
		return false
	end
	if clubInfo.cfg.allcosthost == 1 then
		return true
	end
	if clubInfo.cfg.mcosthost == 1 and self:IsClubManager(self.selfPlayerId) then
		return true
	end
	return false
end

function ClubModel:IsAgent()
	return self.agentInfo ~= nil and self.agentInfo ~= 0
end

function ClubModel:GetCreateClubCost()
	if not self:IsAgent() then
		return self.noagentclubcost
	else
		local list = model_manager:GetModel("ClubModel"):GetClubListByType(ClubMemberState.agent)
		if list == nil or #list == 0  then
			return 0
		else
			return self.moreclubcost
		end
	end
end


---加入分享的俱乐部
function ClubModel:ReqJoinShareClub(cid,shareId,stime,callback)
	local param = {}
	param.cid = cid
	param.share_uid = shareId
	param.expire = stime
	http_request_interface.SendHttpRequestWithCallback(HttpCmdName.joinShareClub, param ,function(msgTab)
		--[[if not self:CheckMsgRet(msgTab) then
			return
		end--]]
		callback(msgTab)
	end,nil)
end

function ClubModel:CheckMsgRet(msgTab)
	if msgTab.ret ~= 0 then
		if msgTab.ret >= 100 and msgTab.ret <= 200 then
			if msgTab.msg ~= nil and msgTab.msg ~= "" then
				UIManager:FastTip(msgTab.msg)
			end
		end
		return false
	end
	return true
end

function ClubModel:SendRequest(key, param, showWaiting)
	local sendCfg = nil
	if showWaiting then
		sendCfg = HttpProxy.ShowWaitingSendCfg
	else
		sendCfg = HttpProxy.DefaultSendCfg
	end
	HttpProxy.SendRequest(HttpProxy.HttpMode.Club, key, param, nil, nil, sendCfg)
end

function ClubModel:SendRequestWithCalback(key, param, callback, target, showWaiting)
	local sendCfg = nil
	if showWaiting then
		sendCfg = HttpProxy.ShowWaitingSendCfg
	else
		sendCfg = HttpProxy.DefaultSendCfg
	end
	HttpProxy.SendRequest(HttpProxy.HttpMode.Club, key, param, callback, target, sendCfg)
	-- HttpProxy.SendRequestWithCallback(HttpProxy.HttpMode.Club, key, param, callback, target, showWaiting)
end

--请求解散俱乐部 {"clubid":俱乐部真实id必传, "clubname":俱乐部名称}
function ClubModel:ReqDissolutionClub(clubid, clubname)
	local  param = {}
	param.cid = clubid
	self:SendRequestWithCalback(HttpCmdName.DissolutionClub, param, function(msgTab) self:OnResDissolutionClub(clubid, clubname, msgTab) end)
end

--解散俱乐部服务器响应结果处理 {"cid":俱乐部真实id必传，"clubname":俱乐部名称, "msgTab":服务器返回数据}
function ClubModel:OnResDissolutionClub(clubid, clubname, msgTab)
	self:RemoveClub(clubid)
	MessageBox.ShowSingleBox(LanguageMgr.GetWord(10302, clubname))
end

--向服务器查询俱乐部是否可以转让{"clubid":俱乐部真实id必传，"usrid":转让给的用户Id，"callback":查询结果回调}
function ClubModel:ReqCheckTransferClub(clubid, usrid, callback)
	local  param = {}
	param.cid = clubid
	param.uid = usrid
	self:SendRequestWithCalback(HttpCmdName.CheckTransferClub, param, function(msgTab) self:OnResCheckTransferClub(callback, msgTab) end)
end

--查询俱乐部是否可以转让服务器响应结果处理 {"callback":查询结果回调，"msgTab":服务器返回数据}
function ClubModel:OnResCheckTransferClub(callback, msgTab)
	if callback ~= nil then
		if msgTab.time == nil or msgTab.time == 0 then -- 没有time 字段 或者是 0 表示能转让
			callback(true)
		else
			callback(false)
		end
	end
end

--请求转让俱乐部 {"clubid":俱乐部真实id必传，"clubname":俱乐部名称，"usrid":转让给的用户Id，"usrname"：转让给的用户昵称}
function ClubModel:ReqTransferClub(clubid, clubname, usrid, usrname)
	local  param = {}
	param.cid = clubid
	param.uid = usrid
	self:SendRequestWithCalback(HttpCmdName.TransferClub, param, function(msgTab) self:OnResTransferClub(clubid, clubname, usrid, usrname, msgTab) end)
end

--转让俱乐部服务器响应结果处理 {"clubid":俱乐部真实id必传，"clubname":俱乐部名称，"usrid":转让给的用户Id，"usrname"：转让给的用户昵称，"msgTab":服务器返回数据}
function ClubModel:OnResTransferClub(clubid, clubname, usrid, usrname, msgTab)
	self:ReqGetClubUser(clubid)
	MessageBox.ShowSingleBox(LanguageMgr.GetWord(10305, clubname, usrname))
end


return ClubModel
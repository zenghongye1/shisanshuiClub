--[[--
 * @Description: 游戏状态基类
 * @Author:      shine
 * @FileName:    gs_base.lua
 * @DateTime:    2017-05-16 17:47:37
 ]]

gs_base = {}
gs_base.__index = gs_base

--[[--
 * @Description: 构造函数  
 ]]
function gs_base.New()
	local self = {}
	setmetatable(self, gs_base)
	self.active = false
	return self
end

--[[--
 * @Description: 处理进入大厅
 ]]
function gs_base:HandleEnterHall(ntf)
	-- body
end

--[[--
 * @Description: 处理进入单人模式
 ]]
function gs_base:HandleEnterSingleLevel(ntf)
	-- body
end

--[[--
 * @Description: 处理进入多人模式
 ]]
function gs_base:HandleEnterMultiLevel(ntf)
	-- body
end

--[[--
 * @Description: 处理网络链接关闭
 ]]
function gs_base:HandleOnNetworkClose()
	--Trace("gs_base:HandleOnNetworkClose()", LOG.gs)
	network_mgr.ShowReconnectMsgBox()
end

--[[--
 * @Description: 处理尝试加载场景
 ]]
function gs_base:HandleTryToLoadScene(sceneId, sceneType, newSys)
	game_scene.DoLoadScene(sceneId, sceneType, newSys)
end

--[[--
 * @Description: 处理重连和登录（用于server已经认为用于已下线后需要注销，并且重新连接和登录）
 ]]
function gs_base:HandleReConnectAndLogin()
	gamesrv_alive.UnInit()
	network_mgr.DisConnect()
	network_mgr.ClearNotifySeqIDs()
	login_sys.ReconnectAndLoginServer()
end

--[[--
 * @Description: 当前状态下应该过滤的广播消息，目前只用在roleShow页面（组队消息）
 ]]
function gs_base:IsFilterCmd(cmd)
	return false
end

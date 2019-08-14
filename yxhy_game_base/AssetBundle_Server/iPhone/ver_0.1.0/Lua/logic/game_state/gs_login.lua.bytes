--[[--
 * @Description: 游戏状态, 登录
 * @Author:      shine
 * @FileName:    gs_login.lua
 * @DateTime:    2017-05-16 17:47:37
 ]]
require "logic/game_state/gs_base"

gs_login = gs_base.New()
gs_login.__index = gs_login

--[[--
 * @Description: 构造函数  
 ]]
function gs_login.New()
	local self = {}
	setmetatable(self, gs_login)

	return self
end

--[[--
 * @Description: 初始化
 ]]
function gs_login:Init(npcObj)

end

--[[--
 * @Description: 反初始化
 ]]
function gs_login:Uninit( ... )

end

--[[--
 * @Description: 进入状态
 ]]
function gs_login:EnterState( ... )
	--Trace("gs_login:EnterState", LOG.gs)
	self.active = true
end

--[[--
 * @Description: 离开状态
 ]]
function gs_login:ExitState( ... )
	--Trace("gs_login:ExitState", LOG.gs)
	self.active = false
end

--[[--
 * @Description: 处理进入大厅
 ]]
function gs_login:HandleEnterHall(ntf)
	
end

--[[--
 * @Description: 处理进入单人玩法
 ]]
function gs_login:HandleEnterSingleLevel(ntf)
	
end

--[[--
 * @Description: 处理进入多人玩法
 ]]
function gs_login:HandleEnterMultiLevel(ntf)
	-- body
end

--[[--
 * @Description: 处理网络链接关闭
 ]]
function gs_login:HandleOnNetworkClose()
	--Trace("gs_login:HandleOnNetworkClose(), nothing to do", LOG.gs)
	-- override, nothing to do
end
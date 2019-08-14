--[[--
 * @Description: 游戏状态, 播放cg动画中
 * @Author:      shine
 * @FileName:    gs_cg.lua
 * @DateTime:    2017-05-16 17:47:37
 ]]
require "logic/game_state/gs_base"

gs_cg = gs_base.New()
gs_cg.__index = gs_cg

--[[--
 * @Description: 构造函数  
 ]]
function gs_cg.New()
	local self = {}
	setmetatable(self, gs_cg)

	return self
end

--[[--
 * @Description: 初始化
 ]]
function gs_cg:Init()

end

--[[--
 * @Description: 反初始化
 ]]
function gs_cg:Uninit( ... )

end

--[[--
 * @Description: 进入状态
 ]]
function gs_cg:EnterState( ... )
	--Trace("gs_cg:EnterState", LOG.gs)
	self.active = true
end

--[[--
 * @Description: 离开状态
 ]]
function gs_cg:ExitState( ... )
	--Trace("gs_cg:ExitState", LOG.gs)
	self.active = false
end

--[[--
 * @Description: 处理进入主城（包括世界地图）
 ]]
function gs_cg:HandleEnterHall(ntf)
	--warning("gs_cg:HandleEnterHall, should not be here!", LOG.gs)
end

--[[--
 * @Description: 处理进入单人副本
 ]]
function gs_cg:HandleEnterSingleLevel(ntf)
	
end

--[[--
 * @Description: 处理进入多人副本
 ]]
function gs_cg:HandleEnterMultiLevel(ntf)
	-- body
end

--[[--
 * @Description: 处理网络链接关闭
 ]]
function gs_cg:HandleOnNetworkClose()
	Trace("gs_cg:HandleOnNetworkClose(), nothing to do", LOG.gs)
	-- override, nothing to do
end

--[[--
 * @Description: 游戏状态, 新手引导
 * @Author:      shine
 * @FileName:    gs_level_guide.lua
 * @DateTime:    2017-05-16 17:47:37
 ]]
require "logic/game_state/gs_base"

gs_level_guide = gs_base.New()
gs_level_guide.__index = gs_level_guide

--[[--
 * @Description: 构造函数  
 ]]
function gs_level_guide.New()
	local self = {}
	setmetatable(self, gs_level_guide)

	return self
end

--[[--
 * @Description: 初始化
 ]]
function gs_level_guide:Init()

end

--[[--
 * @Description: 反初始化
 ]]
function gs_level_guide:Uninit( ... )

end

--[[--
 * @Description: 进入状态
 ]]
function gs_level_guide:EnterState( ... )
	--Trace("gs_level_guide:EnterState", LOG.gs)
	self.active = true
end

--[[--
 * @Description: 离开状态
 ]]
function gs_level_guide:ExitState( ... )
	--Trace("gs_level_guide:ExitState", LOG.gs)
	self.active = false
end

--[[--
 * @Description: 处理进入大厅
 ]]
function gs_level_guide:HandleEnterHall(ntf)
	
end

--[[--
 * @Description: 处理进入单人模式
 ]]
function gs_level_guide:HandleEnterSingleLevel(ntf)
	
end

--[[--
 * @Description: 处理进入多人模式
 ]]
function gs_level_guide:HandleEnterMultiLevel(ntf)
	-- body
end

--[[--
 * @Description: 处理网络链接关闭
 ]]
function gs_level_guide:HandleOnNetworkClose()
end
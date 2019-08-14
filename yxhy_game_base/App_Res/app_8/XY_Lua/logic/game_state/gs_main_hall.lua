--[[--
 * @Description: 游戏状态, 大厅
 * @Author:      shine
 * @FileName:    gs_main_hall.lua
 * @DateTime:    2017-05-16 17:47:37
 ]]
require "logic/game_state/gs_base"

gs_main_hall = gs_base.New()
gs_main_hall.__index = gs_main_hall

--[[--
 * @Description: 构造函数  
 ]]
function gs_main_hall.New()
	local self = {}
	setmetatable(self, gs_main_hall)

	return self
end

--[[--
 * @Description: 初始化
 ]]
function gs_main_hall:Init()

end

--[[--
 * @Description: 反初始化
 ]]
function gs_main_hall:Uninit( ... )

end

--[[--
 * @Description: 进入状态
 ]]
function gs_main_hall:EnterState( ... )
	--Trace("gs_main_hall:EnterState", LOG.gs)
	self.active = true
end

--[[--
 * @Description: 离开状态
 ]]
function gs_main_hall:ExitState( ... )
	--Trace("gs_main_hall:ExitState", LOG.gs)
	self.active = false
end
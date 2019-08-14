--[[--
 * @Description: 游戏状态，麻将模式
 * @Author:      shine
 * @FileName:    gs_mahjong.lua
 * @DateTime:    2017-06-13 15:08:21
 ]]

require "logic/game_state/gs_base"

gs_mahjong = gs_base.New()
gs_mahjong.__index = gs_mahjong


gs_mahjong.name = "gs_mahjong"

--[[--
 * @Description: 构造函数  
 ]]
function gs_mahjong.New()
	local self = {}
	setmetatable(self, gs_mahjong)

	return self
end

--[[--
 * @Description: 初始化
 ]]
function gs_mahjong:Init()

end

--[[--
 * @Description: 反初始化
 ]]
function gs_mahjong:Uninit( ... )

end

--[[--
 * @Description: 进入状态
 ]]
function gs_mahjong:EnterState( ... )
	--Trace("gs_level_multi:EnterState", LOG.gs)
	self.active = true
end

--[[--
 * @Description: 离开状态
 ]]
function gs_mahjong:ExitState( ... )
	--Trace("gs_level_multi:ExitState", LOG.gs)
	self.active = false
end
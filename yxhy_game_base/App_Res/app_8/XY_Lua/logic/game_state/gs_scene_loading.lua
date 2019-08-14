--[[--
 * @Description: 游戏状态, 场景加载中
 * @Author:      shine
 * @FileName:    gs_scene_loading.lua
 * @DateTime:    2017-05-16 17:47:37
 ]]
require "logic/game_state/gs_base"

gs_scene_loading = gs_base.New()
gs_scene_loading.__index = gs_scene_loading


--[[--
 * @Description: 构造函数  
 ]]
function gs_scene_loading.New()
	local self = {}
	setmetatable(self, gs_scene_loading)

	return self
end

--[[--
 * @Description: 初始化
 ]]
function gs_scene_loading:Init(npcObj)

end

--[[--
 * @Description: 反初始化
 ]]
function gs_scene_loading:Uninit( ... )

end

--[[--
 * @Description: 进入状态
 ]]
function gs_scene_loading:EnterState( ... )
	--Trace("gs_scene_loading:EnterState", LOG.gs)
	self.active = true
end

--[[--
 * @Description: 离开状态
 ]]
function gs_scene_loading:ExitState( ... )
	--Trace("gs_scene_loading:ExitState", LOG.gs)
	self.active = false
end

--[[--
 * @Description: 处理尝试加载场景
 ]]
function gs_scene_loading:HandleTryToLoadScene(sceneId, sceneType , newSys)
	--Trace("gs_scene_loading:HandleTryToLoadScene", LOG.gs)
	gs_mgr.AddLoadSceneInfo(sceneId, sceneType , newSys)
end

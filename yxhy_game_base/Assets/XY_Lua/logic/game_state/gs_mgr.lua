--[[--
 * @Description: 游戏状态管理类
 * @Author:      shine
 * @FileName:    gs_mgr.lua
 * @DateTime:    2017-05-16 17:47:37
 ]]
--require "logic/game_state/gs_cg"
require "logic/game_state/gs_mahjong"
require "logic/game_state/gs_login"
require "logic/game_state/gs_main_hall"
require "logic/game_state/gs_scene_loading"

gs_mgr = {}
local this = gs_mgr

-- 游戏状态对象
this.state_current = nil

--this.state_cg = nil
this.state_mahjong = nil
this.state_login = nil
this.state_main_hall = nil
this.state_scene_loading = nil

local scenesToLoad = {}

local UninitSingleState = nil
local InitSingleState = nil

local RegisitEvents = nil
local UnRegistEvents = nil
local CheckToDoLoadScene = nil

--[[--
 * @Description: 初始化单个状态
 ]]
function InitSingleState(gs)
	if (gs ~= nil) then
		gs:Init()
	end
end

--[[--
 * @Description: 初始化游戏状态
 ]]
function this.InitGameStates()
	--this.state_cg = gs_cg.New()	
	this.state_login = gs_login.New()
	this.state_scene_loading = gs_scene_loading.New()
	this.state_main_hall = gs_main_hall.New()
	this.state_mahjong = gs_mahjong.New()

	--InitSingleState(this.state_cg)
	InitSingleState(this.state_login)
	InitSingleState(this.state_scene_loading)
	InitSingleState(this.state_main_hall)
	InitSingleState(this.state_mahjong)

	RegisitEvents()
	scenesToLoad = {}
end

--[[--
 * @Description: 反初始化单个状态
 ]]
function UninitSingleState(gs)
	if (gs ~= nil) then
		gs:Uninit()
	end
end

--[[--
 * @Description: 反初始化游戏状态
 ]]
function this.UninitGameStates()
	--UninitSingleState(this.state_cg)
	UninitSingleState(this.state_login)
	UninitSingleState(this.state_scene_loading)
	UninitSingleState(this.state_main_hall)
	UninitSingleState(this.state_mahjong)

	UnRegistEvents()
end

--[[--
 * @Description: 改变状态
 ]]
function this.ChangeState(dstState)
	if (this.state_current == dstState) then
		return
	end

	if (this.state_current ~= nil) then
		this.state_current.active = false
		this.state_current:ExitState()
	end
	
	this.state_current = dstState
	this.state_current:EnterState()
	CheckToDoLoadScene()
end

--[[--
 * @Description: 当前状态
 ]]
function this.GetCurrState()
	return this.state_current
end

--[[--
 * @Description: 注册事件
 ]]
function RegisitEvents()
end

--[[--
 * @Description: 反注册事件
 ]]
function UnRegistEvents()
end

--[[--
 * @Description: 处理尝试加载场景
 ]]
function this.HandleTryToLoadScene(sceneId, sceneType, newSys)
	if (this.state_current ~= nil) then
		this.state_current:HandleTryToLoadScene(sceneId, sceneType, newSys)
	else
		game_scene.DoLoadScene(sceneId, sceneType, newSys)
	end
end

function this.AddLoadSceneInfo(sceneId, sceneType, newSys)
	local loadSceneInfo = {}
	loadSceneInfo.sceneId = sceneId
	loadSceneInfo.sceneType = sceneType
	loadSceneInfo.newSys = newSys
	table.insert(scenesToLoad, loadSceneInfo)
end

function CheckToDoLoadScene()
	if (table.getn(scenesToLoad) > 0 and this.state_current ~= this.state_scene_loading) then
		local sceneId = scenesToLoad[1].sceneId
		local sceneType = scenesToLoad[1].sceneType
		local newSys = scenesToLoad[1].newSys
		table.remove(scenesToLoad, 1)
		game_scene.DoLoadScene(sceneId, sceneType, newSys)
	end
end
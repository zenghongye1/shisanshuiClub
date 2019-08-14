--[[--
 * @Description: main会调用过来
 * @Author:      shine
 * @FileName:    game.lua
 * @DateTime:    2017-05-16 11:50:39
 ]]

require "common/functions"
require "logic/scene_sys/game_scene"
require "logic/network/majong_request_interface"
require "logic/network/http_request_interface" 
require "logic/framework/data_center"	
require "logic/common/global_define"

--管理器--
GameManager = {}
local this = GameManager

local testScene = nil

--[[--
 * @Description: lua的逻辑入口  
 * @param:       testSceneflag    是否为测试场景方式运行
                 sceneTypeString  场景类型
                 levelID          场景ID
 ]]
function this.OnInitOK(testSceneflag, sceneTypeString, levelID)	
	this.InitModules()	
	if (not testSceneflag) then
		--读取本地版本信息
		data_center.InitVersionInfo() 
		game_scene.gotoLogin()
	else
		TestMode.SetSingleMode(true)
		TestMode.SetDirectSceneTestFlag()
		testScene(sceneTypeString, levelID)
	end
end

--[[--
 * @Description: 初始化底层模块  
 ]]
function this.InitModules()
	Time:SetTimeScale(1)			
	game_scene.init()

	require "logic/game_state/gs_mgr"
	gs_mgr.InitGameStates()	

	--加载音频模块
	require "logic/common_ui/ui_sound_mgr"
	ui_sound_mgr.Init()	

	--加载配置模块
	require "logic/common/config_data_center"
	config_data_center.PreLoadConfigData()
end

--[[--
 * @Description: 反初始化各个模块  
 ]]
function this.UnInitModules()
	gs_mgr.UninitGameStates()
	game_scene.unInit()
	ui_sound_mgr.UnInit()	
end

--[[--
 * @Description: 直接测试运行某场景  
 ]]
function testScene(sceneTypeString, levelID)
	game_scene.EnterSceneForTest(sceneTypeString, levelID)
end


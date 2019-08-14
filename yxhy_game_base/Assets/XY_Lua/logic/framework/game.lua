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
ErrorHandler = require "logic/framework/ErrorHandler"
HttpProxy = require "logic/network/HttpProxy"
require "logic/framework/data_center"	
require "logic/common/global_define"
require "utils/co_mgr"
require "logic/invite_sys/invite_sys"
GameEvent = require "logic/framework/ui/GameEvent"
UI_Manager = require("logic/framework/ui/ui_manager")
UIManager = UI_Manager:Instance()
HttpCmdName = require("logic/framework/HttpCmdName")
model_manager = require("logic/framework/ui/model_manager"):create()
ControlManager = require("logic/framework/ui/ControlManager"):create()
LanguageMgr = require("logic/framework/LanguageMgr")
TimeLimitHelper = require("logic/framework/TimeLimitHelper")

MessageBox = require "logic/common_ui/MessageBox"
require "logic/common/EffectMgr".Init()

MessageHelper = require "logic/common/MessageHelper"

hall_msg_mgr = require  "logic/framework/hall_msg_mgr"

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
		data_center.SetCurPlatform()
		data_center.SetAppConfData()
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

	MessageHelper.Init()
	model_manager:Init()
	ControlManager:Init()
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


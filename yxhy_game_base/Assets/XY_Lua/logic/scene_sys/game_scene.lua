--[[--
 * @Description: 负责场景跳转管理，目前也包括了场景固化的UI
 * @Author:      shine
 * @FileName:    game_scene.lua
 * @DateTime:    2017-05-16 17:47:37

 * @目前只有登陆、大厅这几个系统都要有一个HandleLevelLoadComplete()、ExitLevelSystem()
    其中HandleLevelLoadComplete()为加载完场景资源后做的第一件事。
        ExitLevelSystem()为退出该场景前做的最后一件事
 ]]
require("logic/common/global_define")
require("logic/scene_sys/scene_type")

game_scene = {}
local this = game_scene

local TryToLoadScene = nil
local createAllUI = nil
-- local destroyAllUI = nil
local InitCurSysAfterLoaded = nil
local destroyCurSystem = nil

local currSceneType = scene_type.NONE
local currSceneID = 0

--当前正在执行的系统
local curSceneSys = nil

--[[--
 * @Description: 初始化  
 ]]
function this.init()
end

function OnLevelWasLoaded()
	--Time.timeSinceLevelLoad = 0
	collectgarbage("collect")
	--pool_manager.Clear()
	this.onLevelWasLoaded()	
	Notifier.dispatchCmd(cmdName.MSG_SCENE_LOADN_FINSH)
end

--[[--
 * @Description: 反初始化  
 ]]
function this.unInit()
end

--[[--
 * @Description: 直接回大厅 
 ]]
function this.gotoHall(sceneId, newSys)
	require("logic/hall_sys/hall_ui")
	SocketManager:closeSocket("game")
	TryToLoadScene(900001, scene_type.HALL, hall_ui_ctrl)
end


-- --[[--
--  * @Description: 跳转至登录场景
--  ]]
function this.gotoLogin()
	require("logic/login_sys/login_ui")
 	TryToLoadScene(900000, scene_type.LOGIN, login_sys)
end

--[[--
 * @Description: 根据指定的levelID进行场景跳转  
 * @param1: 场景名，@param2: 新执行的系统
 ]]
function this.gotoLevel(sceneId, sceneType, newSys)
	TryToLoadScene(sceneId, sceneType, newSys)
end

--[[--
 * @Description: 获取当前的关卡类型  
 ]]
function this.getCurSceneType()
	return currSceneType
end

function this.GetCurSceneID()
	return currSceneID
end

function this.DestroyCurSence()
	-- 清理相关场景
	destroyCurSystem()
end

--[[--
 * @Description: 响应Level加载完毕  
 ]]
function this.onLevelWasLoaded()
	Trace("onLevelWasLoaded~~~~~~~~~~="..tostring(currSceneID))
	UISys.Instance:DisableUICamera()	
	createAllUI()	
	UISys.Instance:EnableUICamera()
end

--[[--
 * @Description: 加载新场景
 * @param1: 场景名字, param2: 场景类型 param3:执行体
 ]]
function TryToLoadScene(sceneId, sceneType, newSys)	
	gs_mgr.HandleTryToLoadScene(sceneId, sceneType, newSys)
end

function this.DoLoadScene(sceneId, sceneType, newSys)
	collectgarbage("collect")
	-- 清理相关场景
	this.DestroyCurSence()

	local loadingTips = this.GetLoadingTips(sceneId,sceneType)
	--加载新场景
	SceneMgr.Instance:LoadScene(currSceneID, sceneId, true, 0, loadingTips)


	gs_mgr.ChangeState(gs_mgr.state_scene_loading)
	
	--修改当前场景
	currSceneType = sceneType
	currSceneID = sceneId
	
	--当前执行的系统
	this.SetCurSceneSys(newSys)

	-- 河南场景映射为Game场景
	if currSceneType == scene_type.HENANMAHJONG then
		currSceneType = scene_type.GAME 
	end

	--通知
	local paras = {}
	paras.sceneType = sceneType
	paras.sceneID = currSceneID
	
	Notifier.dispatchCmd(cmdName.SHOW_SCENE, paras)	
	Notifier.dispatchCmd(GameEvent.OnChangeScene, sceneType)
end

function this.GetLoadingTips(sceneId, sceneType)
	local loadingTips = ""
	if sceneType == scene_type.LOGIN then
		if currSceneType == scene_type.HALL then
			loadingTips = "返回登录"
		else
			loadingTips = "正在为您加载，即将进入登录界面"
		end
	elseif sceneType == scene_type.HALL then
		if currSceneType == scene_type.LOGIN then --登录界面到大厅界面
			loadingTips = "正在为您加载，即将进入游戏大厅"
		else
			loadingTips = "返回俱乐部"
		end
	else  --大厅界面到麻将牌桌界面
		loadingTips = "正在为您加载，即将进入游戏"
	end
	return loadingTips
end

--[[--
* @Description: 设置当前执行的系统
]]
function this.SetCurSceneSys(newSys)
	--Trace("curSceneSys:"..tostring(newSys))
	curSceneSys = newSys
end


--[[--
 * @Description: 创建当前场景UI
 ]]
function createAllUI()
	--TimeCostLog.Instance:WriteLog(TimeCostType.CreateSceneUI)
	local resourceMgr = GameKernel.GetResourceMgr()
	if (currSceneType ~= scene_type.NONE) then
		--ui类型优先选择表数据配置的。
		local mainUIType = currSceneType
		
		if mainUIType == scene_type.HALL then
			UI_Manager:Instance():ShowUiForms("hall_ui",UiCloseType.UiCloseType_CloseOther)
			if UI_Manager:Instance():GetUiFormsInShowList("hall_ui") ~= nil then
				hall_ui = UI_Manager:Instance():GetUiFormsInShowList("hall_ui")
			end
			InitCurSysAfterLoaded()
		else				
			if mainUIType == scene_type.LOGIN then
				UI_Manager:Instance():ShowUiForms("login_ui",UiCloseType.UiCloseType_CloseOther)
				login_ui = UI_Manager:Instance():GetUiFormsInShowList("login_ui")

			elseif mainUIType == scene_type.HALL then
				UI_Manager:Instance():ShowUiForms("hall_ui",UiCloseType.UiCloseType_CloseOther)
				if UI_Manager:Instance():GetUiFormsInShowList("hall_ui") ~= nil then
					hall_ui = UI_Manager:Instance():GetUiFormsInShowList("hall_ui")
				end
			end
			createAllUICallback()
		end
	end
end

function createAllUICallback(abi)
	if currSceneType ~= scene_type.HALL then
		UI_Manager:Instance():CloseUiForms("message_box")
	end

	InitCurSysAfterLoaded()

	if currSceneType == scene_type.LOGIN then
		coroutine.start(function ()
			coroutine.wait(0.5)
			Lua2csMessenger.Instance:Broadcast(cmdName.MSG_DESTROY_VERSION_UPDATE_UI)
	    end)
	end
end



--[[--
 * @Description: 初始化当前场景系统  
 ]]
function InitCurSysAfterLoaded()
	--一些通用UI在这里清理
	-- waiting_ui.Hide()
	UI_Manager:Instance():CloseUiForms("waiting_ui")
	
	this.HandleLevelLoadComplete()
end

--[[--
 * @Description: 清理当前场景系统  
 ]]
function destroyCurSystem()
	-- 清理相关场景
	--Trace("destroyCurSystem: "..tostring(currSceneType))
	UIManager:OnBeforeChangeScene()
	this.ExitLevelSystem()
end

--[[--
* @Description: 加载完场景资源后做的第一件事
]]
function this.HandleLevelLoadComplete()
	local sceneConfig = config_data_center.getConfigDataByID("dataconfig_sceneconfig", "id", currSceneID)
	if sceneConfig ~= nil then
		--设置音量
		--AudioSys.Instance:SetSceneVolumPercent(sceneConfig.volumPer)
		local mainCamera = GameObject.FindGameObjectWithTag("MainCamera")
		--设置相机角度
	end

	if curSceneSys ~= nil and curSceneSys.HandleLevelLoadComplete then
		curSceneSys.HandleLevelLoadComplete()
	end
end

function this.OnPreloadFinish()
	Notifier.remove(cmdName.MSG_MONSTER_PRELOAD_FINISH, this.OnPreloadFinish)
	curSceneSys.HandleLevelLoadComplete()
end

--[[--
* @Description: 退出场景时做的最后一件事
]]
function this.ExitLevelSystem()
	if curSceneSys ~= nil and curSceneSys.ExitSystem ~= nil then
		curSceneSys.ExitSystem()
	end
end

--[[--
 * @Description: 测试模式下直接进入场景
 ]]
 function this.EnterSceneForTest(sceneTypeString, levelID)
 	currSceneType = sceneTypeString

 	currSceneID = levelID
 	
	if (sceneTypeString == scene_type.LEVEL) then
		level_sys_single.SetLevelIDForTest(levelID)
	end

	--直接进入
	this.onLevelWasLoaded(0)
 end

function this.GetCurSys()
	return curSceneSys
end

function this.GoToLoginHandle() 
	game_scene.DestroyCurSence() 
	SocketManager:closeSocket("hall")
	SocketManager:closeSocket("game")
    PlayerPrefs.SetInt("LoginType", -1) 
    UI_Manager:Instance():CloseUiForms("global_notice_ui")
end
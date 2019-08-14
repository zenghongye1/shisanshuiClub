--[[--
 * @Description: 作为Unity调用Lua的一些常用函数的桥梁
                 目前包括：
                 		  Update
                 		  LateUpdate
                 		  FixedUpdate
 * @Author:      shine
 * @FileName:    Main.lua
 * @DateTime:    2017-05-16 14:39:51
 ]]
require "Global"
require "logic/framework/game"


--require "logic/mahjong_sys/mode_components/comp_mjItemMgr"
--require "logic/mahjong_sys/mode_components/comp_table"
--require "logic/mahjong_sys/mode_components/comp_playerMgr"
--require "logic/mahjong_sys/fuzhou_mahjong/play_mode_fuzhou"
--[[local model
local tab
local function Update()
	if Input.inputString == "@" then
		require "logic/mahjong_sys/mahjong_play_sys"
		map_controller.LoadLevelScene(900002, mahjong_play_sys)
	end
	if Input.inputString == "1" then
		model = play_mode_fuzhou.GetInstance()
		model:Start()
		tab = model:GetComponent("comp_table")
		tab:ShowWall(function() end)
		model:OnResetWall({2,3})
		roomdata_center.zhuang_viewSeat = 1
	end
	if Input.inputString == "2" then
		tab:SendAllHandCard(2, 1, nil, function() end)
	end
end
]]

local function Update()
	if Input.inputString == "@" then
		Trace("断线断线")
		SocketManager:reconnect()
	end
	if Input.inputString == "#" then
		mahjong_gm_manager:OpenGMMode()
	end
	if Input.inputString == "$" then
		mahjong_gm_manager:SetCancelHu()
	end
	local tt = require("logic.shisangshui_sys.ui_shisangshui.shisanshui_ui")
	if Input.inputString == "%" then
		tt.LogTest()
	end
end

--[[--
 * @Description: lua层的主入口
 ]]
function Main()	
	Trace("main------------------------------")
	math.randomseed(os.clock())		
	GameManager.OnInitOK(false, "", 0)
	if  Application.isEditor then
		UpdateBeat:Add(Update)
	end
end


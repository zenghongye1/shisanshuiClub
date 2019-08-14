--endregion
require "logic/shisangshui_sys/play_mode_shisangshui"
require "logic/shisangshui_sys/table_component"
require "logic/shisangshui_sys/player_component"
require "logic/shisangshui_sys/prepare_special/prepare_special"
require "logic/shisangshui_sys/place_card/place_card"
require "logic/shisangshui_sys/resMgr_component"
require "logic/mahjong_sys/mode_components/mode_comp_base"
require "logic/hall_sys/openroom/room_data"
require "logic/shisangshui_sys/config/shisanshui_table_config"
require "logic/shisangshui_sys/ui_shisangshui/shisangshui_ui_sys"

reset_connect_room = {}
local this = reset_connect_room
local instance = nil

function reset_connect_room.GetInstance()
    if (instance == nil) then
        instance = reset_connect_room.create()
    end

    return instance
end

function reset_connect_room.create()
	require "logic/mahjong_sys/mode_components/mode_comp_base"
	local this = mode_comp_base.create()
	this.Class = reset_connect_room
	this.name = "reset_connect_room"
	this.base_init = this.Initialize
	this.connect_para = nil
	
	function this:ReConnect(para)
		this.connect_para = para
		shisangshui_play_sys.HandlerEnterGame()
	end
	
	function this:Initialize()
        this.base_init()
        Notifier.regist(cmdName.LoadTableEnd, LoadTableEnded)--玩家进入
        Notifier.regist(cmdName.GAME_SOCKET_SYNC_TABLE,OnSyncTable)--重连同步表
	
    end

    this.base_uninit = this.Uninitialize

    function this:Uninitialize()
        this.base_uninit()

        Notifier.remove(cmdName.LoadTableEnd, LoadTableEnded)--玩家进入
        Notifier.remove(cmdName.GAME_SOCKET_SYNC_TABLE,OnSyncTable)--重连同步表

        instance = nil
    end
	
	function this:LoadTableEnded()
		local play_uid_list = this.connect_para.stPlayerUid
		--for i = 1, #play_uid_list do
		for i = 1, 2 do
			--shisangshui_ui_sys.OnPlayerEnter(uid, coin, src)
			shisangshui_ui_sys.OnPlayerEnter(21563, 30, i)
		end
	end
	
	return this
end










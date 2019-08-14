--[[--
 * @Description: 福州麻将玩法
 * @Author:      shine
 * @FileName:    play_mode_fuzhou.lua
 * @DateTime:    2017-06-13 10:22:49
 ]]

require "logic/mahjong_sys/mode_base"

require "logic/mahjong_sys/comp_show/mahjong_anim_state_control"
require "logic/mahjong_sys/comp_show/comp_show_base"
require "logic/mahjong_sys/ui_mahjong/mahjong_ui_sys"
require "logic/mahjong_sys/utils/mahjong_path_mgr"
require "logic/mahjong_sys/utils/MahjongFuncSetUtil"

play_mode_fuzhou = {}
local instance = nil

function play_mode_fuzhou.GetInstance()
    if (instance == nil) then
        instance = play_mode_fuzhou.create()
    end

    return instance
end

function play_mode_fuzhou.create(levelID)
    local this = mode_base.create(levelID)
    this.Class = play_mode_fuzhou
    this.name = "play_mode_fuzhou"

    this.gid = player_data.GetGameId()

    this.game_id = GameUtil.GetResId(this.gid)

    this.config = require ("logic/mahjong_sys/configs/mahjong_config_"..this.game_id)
    this.cfg = config_mgr.getConfig("cfg_mahjongconfig",this.game_id)
    this.cfg.isShowWall = false
    this.modeId = this.cfg.mode
    local compPath = "logic/mahjong_sys/components/mode_"..this.modeId.."/"

    mahjong_anim_state_control.InitFuzhouAnims(this.config)
    mahjong_path_mgr.InitGameId(this.game_id)

    --------------------------------  

    local ConstructComponents = nil

    this.base_init = this.Initialize
    function this:Initialize()
        this.base_init()   
        comp_show_base:Init()        
        mahjong_ui_sys.Init()

    end

    this.base_uninit = this.Uninitialize
    function this:Uninitialize()
        this.base_uninit()
        comp_show_base:Uinit()
        mahjong_ui_sys.UInit()
        mahjong_client_ting_mgr:Dispose()
        roomdata_center.UnInitAllData()
        mahjong_anim_state_control.Reset() 
        instance = nil
    end

    --[[--
     * @Description: 组装所需要的组件
     ]]
    function ConstructComponents()
        Trace("ConstructComponents---------------------------------------")
        -- 组装
        this:AddComponent(require ("logic/mahjong_sys/components/base/comp_mjScene"):create())
        this:AddComponent(require ("logic/mahjong_sys/components/base/comp_mjResMgr"):create())
        this:AddComponent(require (compPath.."comp_mjItemMgr"):create(compPath.."comp_mjItem"))
        this:AddComponent(require (compPath.."comp_mjTable"):create())
        this:AddComponent(require (compPath.."comp_mjPlayerMgr"):create(compPath.."comp_mjPlayer"))      
        this:AddComponent(require ("logic/mahjong_sys/components/base/comp_mjDice"):create())   

        mahjong_client_ting_mgr = require "logic/mahjong_sys/mahjong_client_ting_mgr":create()

        if Application.isEditor then
            mahjong_gm_manager = require "logic/mahjong_sys/mahjong_gm_manager":create(this)
        end

        mahjong_effectMgr = require "logic/mahjong_sys/mahjong_effectMgr":create()
    end

    function this:PreloadObjects()
        --预加载场景物体
    end

    function this:GetAnimSpeed()
        return 0.5
    end

    -- 执行下组装
    ConstructComponents()

    return this
end

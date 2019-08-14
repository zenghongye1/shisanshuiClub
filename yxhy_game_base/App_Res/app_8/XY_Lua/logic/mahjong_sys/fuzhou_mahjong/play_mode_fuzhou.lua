--[[--
 * @Description: 福州麻将玩法
 * @Author:      shine
 * @FileName:    play_mode_fuzhou.lua
 * @DateTime:    2017-06-13 10:22:49
 ]]
require "logic/mahjong_sys/mode_base"

require "logic/mahjong_sys/fuzhou_mahjong/fuzhou_comp_show"
require "logic/mahjong_sys/Utils/mahjong_path_mgr"

local comp_mjTable_fuzhou = require "logic/mahjong_sys/components/fuzhou/comp_mjTable_fuzhou"
local comp_mjPlayerMgr = require "logic/mahjong_sys/components/base/comp_mjPlayerMgr"
local comp_mjItemMgr = require "logic/mahjong_sys/components/base/comp_mjItemMgr"
local comp_mjDice = require "logic/mahjong_sys/components/base/comp_mjDice"
local comp_mjResMgr = require "logic/mahjong_sys/components/base/comp_mjResMgr"
local comp_mjClickEvent = require "logic/mahjong_sys/components/base/comp_mjClickEvent"
local comp_mjScene = require "logic/mahjong_sys/components/base/comp_mjScene"




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
    this.config = require "logic/mahjong_sys/fuzhou_mahjong/config/mahjong_config_fuzhou"

    mahjong_anim_state_control.InitFuzhouAnims()
    mahjong_path_mgr.InitGameId(player_data.GetGameId())

    --------------------------------  

    local ConstructComponents = nil

    this.base_init = this.Initialize
    function this:Initialize()
        this.base_init()   
        fuzhou_comp_show:Init()            
    end

    this.base_uninit = this.Uninitialize
    function this:Uninitialize()
        this.base_uninit()
        fuzhou_comp_show:Uinit()
        instance = nil        
        roomdata_center.isRoundStart = false
        roomdata_center.nCurrJu = 0
    end

    --[[--
     * @Description: 组装所需要的组件
     ]]
    function ConstructComponents()
        Trace("ConstructComponents---------------------------------------")
        -- 组装
        this:AddComponent(comp_mjScene:create())
        this:AddComponent(comp_mjClickEvent:create())
        this:AddComponent(comp_mjResMgr:create())
        this:AddComponent(comp_mjItemMgr:create("logic/mahjong_sys/components/base/comp_mjItem"))
        this:AddComponent(comp_mjTable_fuzhou:create())
        this:AddComponent(comp_mjPlayerMgr:create("logic/mahjong_sys/components/fuzhou/comp_mjPlayer_fuzhou"))      
        this:AddComponent(comp_mjDice:create())   
    end

    function this:PreloadObjects()
        --预加载场景物体
    end

    -- 执行下组装
    ConstructComponents()

    return this
end

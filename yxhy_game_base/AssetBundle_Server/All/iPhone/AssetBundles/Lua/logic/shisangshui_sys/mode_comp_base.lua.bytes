--[[--
 * @Description: 模式组件基类
 * @Author:      shine
 * @FileName:    mode_comp_base.lua
 * @DateTime:    2017-06-13 10:44:03
 ]]

mode_comp_base = {}

function mode_comp_base.create()
    local this = LuaObject.create()
    this.Class = mode_comp_base
    this.name = "mode_comp_base"
    this.mode = nil
    --------------------------------

    this.enable = false        

    --[[--
    * @Description: 初始化
    ]]
    function this:Initialize()
        
    end

    --[[--
     * @Description: 开始
     ]]
    function this:Start()
       this.enable = true
    end

    --[[--
    * @Description: 反初始化
    ]]
    function this:Uninitialize()
        this.enable = false
    end

    --[[--
    * @Description: 更新
    ]]
    function this:Update()
        -- body
    end

    return this
end
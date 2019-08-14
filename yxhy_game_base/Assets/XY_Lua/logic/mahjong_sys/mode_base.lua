--[[--
 * @Description: 麻将模式基类
 * @Author:      shine
 * @FileName:    mode_base.lua
 * @DateTime:    2017-06-12 20:45:51
 ]]

mode_base = {}

function mode_base.create()
    local this = LuaObject.create()
    this.Class = mode_base
    this.name = "mode_base"
    this.enable = false
    this.initializeFlag = false
    this.startFlag = false
    --------------------------------

    this.components = {}

    --[[--
    * @Description: 初始化， 在这里进行各个组件装配
    ]]
    function this:Initialize()
        for k, v in ipairs(this.components) do
            v:Initialize()
        end
        this.initializeFlag = true
    end

    --[[--
     * @Description: 开始(逻辑开始运转，和初始化是不一样的)
     ]]
    function this:Start()
        for k, v in ipairs(this.components) do
            v:Start()
        end

        this.enable = true
        this.startFlag = true
        UpdateBeat:Add(this.Update)
    end

    --[[--
    * @Description: 反初始化
    ]]
    function this:Uninitialize()
        for k, v in ipairs(this.components) do
            v:Uninitialize()
        end
        this.components = {}
        this.enable = false
        UpdateBeat:Remove(this.Update)
        this.initializeFlag = false
        this.startFlag = false
    end

    --[[--
    * @Description: 更新
    ]]
    function this.Update()
        if (this.enable) then
            for k, v in ipairs(this.components) do
                v:Update()
            end
        end
    end

    --[[--
     * @Description: 添加组件
     ]]
    function this:AddComponent(comp)
        table.insert(this.components, comp)
        comp.mode = this
        return comp
    end

    --[[--
     * @Description: 删除组件
     * @param:       compName 组件名字 
     ]]
    function this:RemoveComponent(compName)
        for k = table.getn(this.components), 1, -1 do
            local v = this.components[k]
            if (v.name == compName) then
                table.remove(this.components, k)
            end
        end
    end

    --[[--
     * @Description: 根据类型得到某组件  
     * @param:       compName 组件名字 
     ]]
    function this:GetComponent(compName)
        local ret = nil
        for k, v in ipairs(this.components) do
            if (v.name == compName) then
                ret = v
                break
            end
        end

        return ret
    end

    function this:PreloadObjects()
        -- body
    end

    -- 在这里添加公用的组件
    -- 待加    

    function this:CheckToAddComponent(comp)
        if (this:GetComponent(comp.name) == nil) then
            this:AddComponent(comp)
        end
    end
    

    return this

end



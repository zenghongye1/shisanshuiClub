invite_code_input_ui = ui_base.New()

local this = invite_code_input_ui

this.inputNumList = {}
this.itemList = {}


function this.Show()
    if this.gameObject==nil then
        this.gameObject=newNormalUI("app_8/ui/invitecode_ui/invitecode_ui")
    else  
        this.gameObject:SetActive(true)
    end     
    this.transform = this.gameObject.transform
    this.addlistener()
end

function this.Start() 
    this:RegistUSRelation()
end

function this.OnDestroy()
    this:UnRegistUSRelation()
end

function this.addlistener()
    local btn_close=child(this.transform,"invite_code_panel/btn_close")
    if btn_close~=nil then
        addClickCallbackSelf(btn_close.gameObject,this.Hide,this)
    end


    -- this.grid_number=child(this.transform,"invite_code_panel/Panel_Middle/gird_number")
    this.btn_grid=child(this.transform,"invite_code_panel/Panel_Middle/grid_input")
    this.gridGo=child(this.transform,"invite_code_panel/Panel_Middle/gird_number").gameObject
    this.uigrid = this.gridGo:GetComponent(typeof(UIGrid))
    this.item = child(this.transform, "invite_code_panel/Panel_Middle/gird_number/item").gameObject
    this.item:SetActive(false)
    table.insert(this.itemList, this.item)

    local tipLabel = subComponentGet(this.transform, "invite_code_panel/Panel_Middle/lab_warn", typeof(UILabel))
    tipLabel.text = "提示：输入邀请码后即可购买，如未获得，请咨询官方客服"

    this.inputTipsGo = child(this.transform, "invite_code_panel/Panel_Middle/inputTips").gameObject
    this.inputTipsGo:SetActive(true)
    
    for k=0,this.btn_grid.transform.childCount-1,1 do
        local btn_n=this.btn_grid.transform:GetChild(k)
        addClickCallbackSelf(btn_n.gameObject,this.setnumber,this)
    end
end

function this.setnumber(obj,obj2) 
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    if obj2.name~="clear" and obj2.name~="sure" then
        -- 最多输入9位
        if #this.inputNumList >= 9 then
            return
        end
        local num = obj2.name
        table.insert(this.inputNumList, num)
        this.RefreshNums()
    end
    if obj2.name=="clear" then
        this.clear()  
    end

    if obj2.name=="sure" then
        this.BindAgent()
    end
end

function this.RefreshNums()
    this.inputTipsGo:SetActive(#this.inputNumList == 0)
    for i = 1, #this.itemList do
        this.itemList[i]:SetActive(false)
    end
    for i = 1, #this.inputNumList do
        local go = nil
        if i <= #this.itemList then
            go = this.itemList[i]
        else
            go = NGUITools.AddChild(this.gridGo, this.item)
            table.insert(this.itemList, go)
        end
        if go ~= nil then
            this.ShowNum(go, this.inputNumList[i])
        end
    end
    this.uigrid:Reposition()
end

function this.ShowNum(go, num)
    go:SetActive(true)
    local sp = go:GetComponent(typeof(UISprite))
    if sp ~= nil then
        sp.spriteName="j"..num
    end
end

function this.clear()
    this.inputNumList = {}
    this.RefreshNums()
end

function this.BindAgent()
    local num = table.concat(this.inputNumList)
    http_request_interface.BindAgent(num, function(ret) 
        ret = tonumber(ret)
        if ret == 0 or ret == 102 then
            hall_data.BindAgent()
			service_ui.Show()
                --[[waiting_ui.Show()
                http_request_interface.getProductCfg(0,
                function(str)
                    Trace(str)
                    waiting_ui.Hide()
                    local s=string.gsub(str,"\\/","/")  
                    local t=ParseJsonStr(s) 
                    shop_ui.productlist=t.productlist
                    shop_ui.Show()        
                end)--]]
            this.Hide()
        elseif ret == 100 then
            fast_tip.Show("用户ID不存在")
        elseif ret == 101 then
            fast_tip.Show("请输入邀请码")
        -- elseif ret == 102 then
        --     fast_tip.Show("用户已绑定邀请码")
        elseif ret == 103 then
            fast_tip.Show("您输入的邀请码不存在")
        elseif ret == 104 then
            fast_tip.Show("您输入的邀请码已过期")
        elseif ret == 105 then
            fast_tip.Show("绑定邀请码失败")
        elseif ret == 106 then
            fast_tip.Show("您已是代理商，无需绑定")
        elseif ret == 107 then
            fast_tip.Show("请勿自我绑定")
        end

        end)
end


function  this.Hide()
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    if not IsNil(this.gameObject) then  
        this.itemList = {}
        this.inputNumList = {}
        GameObject.Destroy(this.gameObject)
        this.gameObject=nil
    end
end
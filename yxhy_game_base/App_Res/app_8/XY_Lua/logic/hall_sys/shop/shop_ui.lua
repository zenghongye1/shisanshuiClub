--region *.lua
--Date
--此文件由[BabeLua]插件自动生成


--endregion 

shop_ui = ui_base.New()
local this = shop_ui
 
this.gameObject=nil  
this.productlist={}
function this.Show()  
    if IsNil(this.gameObject) then
		require ("logic/hall_sys/shop/shop_ui")
        if tostring(Application.platform)  == "Android" or tostring(Application.platform)  == "WindowsEditor"  then 
		    this.gameObject=newNormalUI("app_8/ui/shop_ui/shop_ui")
            this.RegisterEvent() 
        elseif tostring(Application.platform)  == "IPhonePlayer"then
            this.gameObject=newNormalUI("app_8/ui/shop_ui/shop_iosui")  
            this.IOSRegister()
        end
	else
		this.gameObject:SetActive(true) 
	end    
    
end



function this.Hide()  
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
	if this.gameObject==nil then 
        return
	else
		GameObject.Destroy(this.gameObject)
        this.gameObject=nil
	end
    
end

function this.IOSRegister()
    local btn_close=child(this.transform,"panel_shop/btn_close")
    if btn_close~=nil then
        addClickCallbackSelf(btn_close.gameObject,this.Hide,this)
    end 

    local btn_6=child(this.transform,"panel_shop/Panel_Middle/6")
    if btn_6~=nil then
        addClickCallbackSelf(btn_6.gameObject,this.iosbuy,this)
    end

    local btn_30=child(this.transform,"panel_shop/Panel_Middle/30")
    if btn_30~=nil then
        addClickCallbackSelf(btn_30.gameObject,this.iosbuy,this)
    end
end

function this.iosbuy(obj1,obj2)
    if this.productlist.pid~=nil then 
        local pid =t.productlist[1].pid
        recharge_sys.requestIAppPayOrder(rechargeConfig.IAppPay,pid,tonumber(obj2.name))
    else
        http_request_interface.getProductCfg({["ptype"]=1},function (code,m,str) 
            Trace(str)
            local s=string.gsub(str,"\\/","/")  
            local t=ParseJsonStr(s)
            if tonumber( t.ret)==0 then
                 require "logic/recharge/recharge_sys"
                local pid =t.productlist[1].pid
                 recharge_sys.requestIAppPayOrder(rechargeConfig.IAppPay,pid,tonumber(obj2.name)) 
            end   
        end)
    end
    
end

function  this.RegisterEvent()
    local btn_close=child(this.transform,"panel_shop/btn_close")
    if btn_close~=nil then
        addClickCallbackSelf(btn_close.gameObject,this.Hide,this)
    end 
    local price= child(this.transform,"panel_shop/Panel_Middle/Sprite/lab_price") 
    if price~=nil then
        componentGet(price.gameObject,"UILabel").text="售价"..string.format("%0.f",this.productlist[1].price) .."元"
    end

    local btn_open=child(this.transform,"panel_shop/Panel_Middle/btn_buy")
    if btn_open~=nil then
        addClickCallbackSelf(btn_open.gameObject,this.open,this)
    end 
    local btn_buy=child(this.transform,"panel_shop/panel_buy/buy_panel/Panel_Middle/btn_buy")
    if btn_buy~=nil then
        addClickCallbackSelf(btn_buy.gameObject,this.buy,this)
    end 
    local btn_increase=child(this.transform,"panel_shop/panel_buy/buy_panel/Panel_Middle/sp_background/btn_increase")
    if btn_increase~=nil then
        addClickCallbackSelf(btn_increase.gameObject,this.increase,this)
    end 
    local btn_decrease=child(this.transform,"panel_shop/panel_buy/buy_panel/Panel_Middle/sp_background/btn_decrease")
    if btn_decrease~=nil then
        addClickCallbackSelf(btn_decrease.gameObject,this.decrease,this)
    end 
    this.lab_number=child(this.transform,"panel_shop/panel_buy/buy_panel/Panel_Middle/sp_background/lab_number")
    this.lab_count=child(this.transform,"panel_shop/panel_buy/buy_panel/Panel_Middle/sp_background2/lab_number")

    this.input_price=componentGet(this.lab_number.gameObject,"UIInput")
    EventDelegate.Add(this.input_price.onChange, EventDelegate.Callback(function() this.OnInputChange(this) end))

    local btn_c=child(this.transform,"panel_shop/panel_buy/buy_panel/btn_close")
    if btn_c~=nil then
        addClickCallbackSelf(btn_c.gameObject,this.close,this)
    end 
    this.updateCount()
end

function this.buy()
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    Trace("buy")
    http_request_interface.getProductCfg({["ptype"]=1},function (code,m,str) 
        Trace(str)
        local s=string.gsub(str,"\\/","/")  
        local t=ParseJsonStr(s)
        if tonumber( t.ret)==0 then
             require "logic/recharge/recharge_sys"
            local pid =t.productlist[1].pid
             recharge_sys.requestIAppPayOrder(rechargeConfig.IAppPay,pid,tonumber(this.input_price.value))
            
        end   
    end)
end

function this.increase()
    this.input_price.value=tonumber(this.input_price.value)+1 
    this.updateCount()
end

function this.decrease()
    if tonumber(this.input_price.value)>1 then
       this.input_price.value=tonumber(this.input_price.value)-1 
    end
    this.updateCount()
end

function this.updateCount()
    local count= tonumber(this.input_price.value)
    componentGet(this.lab_count.gameObject,"UILabel").text=count*tonumber(this.productlist[1].price)
end

function this.open()
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    local panel=child(this.transform,"panel_shop/panel_buy")
    panel.gameObject:SetActive(true)
end

function this.close()
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    local panel=child(this.transform,"panel_shop/panel_buy")
    panel.gameObject:SetActive(false)
end

function this.OnInputChange(self)
    local tValue = ""
    local tMsg = this.input_price.value
    if tMsg ~= "" then
        for i=1,string.len(tMsg) do
            local tChar=string.sub(tMsg,i,i)
            if i==1 and  tChar == "0" then
                tValue = "1"
            else
                if (tChar >= "0" and tChar <= "9") then
                    tValue = tValue .. tChar
                end
            end
        end     
    end 
    if tValue == "" then
        tValue = "1"
    end
    this.input_price.value = tValue
    this.updateCount()
end
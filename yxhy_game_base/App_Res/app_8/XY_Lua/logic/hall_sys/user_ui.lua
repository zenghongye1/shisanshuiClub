--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require"logic/hall_sys/hall_data"

user_ui =ui_base.New()
local this = user_ui

this.playinfo={
};
this.mjtype={
["zhengzhoumj"]="zhengzhoumj",
["zhumadianmj"]="zhumadianmj",
["luoyangmj"]="luoyangmj"
}
local transform

function this.Show()
	if this.gameObject==nil then
		require ("logic/hall_sys/user_ui")
		this.gameObject=newNormalUI("Prefabs/UI/Hall/user_ui")
	else
		this.gameObject:SetActive(true)
	end
end

function this.Awake() 

--每次激活都执行向服务器获取消息
   
end

function this.Start() 
    local btn_close=child(this.transform, "btn_cancel")
    if btn_close~=nil then
        addClickCallbackSelf(btn_close.gameObject,this.Hide,this)
    end 
    this.addListener()
	this:RegistUSRelation()
end


function this.OnDestroy()
	this:UnRegistUSRelation()
end

function this.Hide()
    if this.gameObject==nil  then
        Trace("Not Find user_ui")
        return
    else
        GameObject.Destroy(this.gameObject)
        this.gameObject=nil
    end 
end

function this.addListener()
   local btn_coin=child(this.transform,"user/gold_grid/btn_coin")
   if btn_coin~=nil then
        addClickCallbackSelf(btn_coin.gameObject,this.clickgoldbtn,this)
   end 

   local btn_diamond=child(this.transform,"user/gold_grid/btn_diamond")
   if btn_diamond~=nil then
        addClickCallbackSelf(btn_diamond.gameObject,this.clickdiamondbtn,this)
   end 

   local btn_matype=child(this.transform,"user/sv_mj/mj_grid/btn_game01")
   if btn_matype~=nil then
        addClickCallbackSelf(btn_matype.gameObject,this.clickgamebtn,this)
   end

   local tx_photo=child(this.transform,"user/userInfo/tex_photo")
   if tx_photo~=nil then 
        hall_data.getuserimage(componentGet(tx_photo,"UITexture"))
   end

    
end

function this.clickgoldbtn()
    shop_ui.Show(shop_ui.Opentype.gold,{function ()user_ui.Show() end})
    this.Hide()
end
function this.clickdiamondbtn()
    shop_ui.Show(shop_ui.Opentype.diamond,{function ()user_ui.Show() end})
    this.Hide()
end

function this.clickgamebtn()
    Trace("-----------------game")
end
--[[
{"ret":0,"data":{"uid":4554998,"win":14,"sum":16,"maxwin":1000,"maxcard":["11","11","11","6","2","2","3","3","4","4"],"maxcardtype":"1","wincon":14,"viplv":1,"vipNextlv":2,"nickname":"玩家88D7F67B","imageurl":"9"}}
]]--
 
function this.updateinfo(mjtype)
    this.lab_name=child(this.transform, "user/userInfo/lab_name");
    if this.lab_name~=nil then
        componentGet(this.lab_name,"UILabel").text=tostring(this.playinfo[mjtype].nickname) 
    end
    
    this.lab_id=child(this.transform, "user/userInfo/lab_id");
    if this.lab_id~=nil then
        componentGet(this.lab_id,"UILabel").text="ID:".. tostring(this.playinfo[mjtype].uid)
    end
    
    this.lab_winrate=child(this.transform, "user/playinfo/sp_playinfo02/lab_lnum");
    if this.lab_winrate~=nil and tonumber(this.playinfo[mjtype].win)>0 then
        componentGet(this.lab_winrate,"UILabel").text=tostring(this.playinfo[mjtype].win/this.playinfo[mjtype].sum)*100 .."%"
    else componentGet(this.lab_winrate,"UILabel").text=0
    end

    this.lab_coin=child(this.transform, "user/gold_grid/btn_coin/lab_coin");
    if this.lab_coin~=nil then
        componentGet(this.lab_coin,"UILabel").text=tostring(hall_data.coin)
    end
    
    this.lab_diamond=child(this.transform, "user/gold_grid/btn_diamond/lab_diamond");
    if this.lab_diamond~=nil then
        componentGet(this.lab_diamond,"UILabel").text=tostring(hall_data.diamond)
    end

    this.lab_win=child(this.transform, "user/playinfo/sp_playinfo01/lab_rnum");
    if this.lab_win~=nil then
        componentGet(this.lab_win,"UILabel").text=tostring(this.playinfo[mjtype].win)
    end

    this.lab_sum=child(this.transform, "user/playinfo/sp_playinfo01/lab_lnum");
    if this.lab_sum~=nil then
        componentGet(this.lab_sum,"UILabel").text=tostring(this.playinfo[mjtype].sum)
    end

    this.lab_maxwin=child(this.transform, "user/playinfo/sp_playinfo02/lab_rnum");
    if this.lab_maxwin~=nil then
        componentGet(this.lab_maxwin,"UILabel").text=tostring(this.playinfo[mjtype].sum)
    end
        
    this.lab_wincon=child(this.transform, "user/playinfo/sp_playinfo03/lab_lnum");
    if this.lab_wincon~=nil then
        componentGet(this.lab_wincon,"UILabel").text=tostring(this.playinfo[mjtype].maxwin)
    end
    if table.getCount(this.playinfo[mjtype].maxcard) >1 then
        this.showMJtype(true)
        this.mjpai(this.playinfo[mjtype].maxcard)  
    else
        this.showMJtype(false)
    end
    
end

function this.showMJtype(isshow)
    local sp_type=child(this.transform, "user/playinfo/sp_bottom/Sprite/sp_mjptype"); 
    local mj_total=child (this.transform,"user/mjpai")
    local lab_des=child(this.transform, "user/playinfo/lab_des") 
    if isshow then
        sp_type.gameObject:SetActive(true)
        mj_total.gameObject:SetActive(true)
        lab_des.gameObject:SetActive(false)
    else
        sp_type.gameObject:SetActive(false)
        mj_total.gameObject:SetActive(false)
        lab_des.gameObject:SetActive(true)
    end
end

this.currentx=0
function this.mjpai(t)
    for i=1,table.getCount(t),1 do
        local mj_item=child(this.transform,"user/mjpai/mj"..i) 
        if mj_item==nil then  
           local  mj_item_old=child(this.transform,"user/mjpai/mj"..i-1)
           mj_item=GameObject.Instantiate(mj_item_old)
           mj_item.transform.parent=mj_item_old.transform.parent
           mj_item.transform.localScale={x=1,y=1,z=1} 
           mj_item.transform.localPosition={x=this.currentx+43,y=-250,z=0}
           mj_item.name="mj"..i 
        end
        this.currentx=mj_item.transform.localPosition.x
        local sp_mjiten=child(mj_item.transform,"Sprite") 
        local sp_mj=componentGet(sp_mjiten.gameObject,"UISprite") 
        sp_mj.spriteName=t[i].."_hand"
    end
end

--endregion

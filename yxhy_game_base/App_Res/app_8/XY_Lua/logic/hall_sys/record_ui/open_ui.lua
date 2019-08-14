--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
require"logic/common_ui/ui_wrap"
require"logic/hall_sys/record_ui/openrecord_ui"
open_ui=ui_wrap.New()
local this=open_ui

local roomStatus =
{
    "已开房",
    "已开局",
    "已结算",
    "未开局",
}

local sp_roomTbl=
{
    ["已开房"]="weikaishi",
    ["已开局"]="jinxingzhong",
    ["已结算"]="jiesu",
    ["未开局"]="weikaishi"
}
function this.Start()
    this.Init() 
end
function this.InitData(data)   
    this:Initdate(data) 
end

function this.Init() 
    this.OnUpdateItemInfo=this.UpdataOpenRecord
    this:InitUI(85) 
end

function this.UpdataOpenRecord(go,realindex)
    local rindext=realindex   
    if go~=nil then  
        if this.wraprecord[rindext] == nil then
            warning("this.wraprecord[rindext] is nil----------------------------------")
            return
        end
        go.name=rindext
        local lab_date=child(go.transform, "lab_date")--日期
        local lab_type=child(go.transform, "lab_type")--类型
        local lab_status=child(go.transform, "lab_status")--状态  
        local sp_reward=child(go.transform,"sp_reward")  
        if this.wraprecord[rindext].status==nil then
        return
        end
        componentGet(sp_reward,"UISprite").spriteName=sp_roomTbl[roomStatus[this.wraprecord[rindext].status+1]]  
        componentGet(lab_status,"UILabel").text=roomStatus[this.wraprecord[rindext].status+1]
        addClickCallbackSelf(go.gameObject,this.opendetails,hall_ui)
        componentGet(lab_type,"UILabel").text="房号:"..this.wraprecord[rindext].rno
        componentGet(lab_date,"UILabel").text ="日期:".. os.date("%Y.%m.%d",this.wraprecord[rindext].ctime) 
    end 
end

function this.opendetails(obj1,obj2)
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    local rid=this.wraprecord[tonumber(obj2.name)].rid   
    if this.wraprecord[tonumber(obj2.name)].status==2 then 
        openrecord_ui.LoadInfo(2)
    else
        openrecord_ui.LoadInfo(1)
    end  
end

function this.OnUpdateToEnd()
    http_request_interface.getRoomSimpleList(nil,99,this.page,function (str)
        local s=string.gsub(str,"\\/","/")  
        local t=ParseJsonStr(s) 
        local count=table.getCount(this.wraprecord) 
        if table.getCount(t.data)<=0 then
            return
        end
        for i=1,table.getCount(t.data) do
            this.wraprecord[i+count]=t.data[i]
        end
        this.page=this.page+1
        this.maxCount=table.getCount(this.wraprecord)
        this.wrap.minIndex = -this.maxCount+1 
    end) 
end
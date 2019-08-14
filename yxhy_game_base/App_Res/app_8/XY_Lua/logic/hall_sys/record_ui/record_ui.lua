
--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
 
--endregion
require"logic/common_ui/ui_wrap"
record_ui=ui_wrap.New()
local this=record_ui



local NameByGidTbl=
{
    [ENUM_GAME_TYPE.TYPE_FUZHOU_MJ]="福州麻将",
    [ENUM_GAME_TYPE.TYPE_SHISHANSHUI]="十三水"
} 

function this.Start()
    this.Init() 
end
function this.InitData(data)   
    this:Initdate(data) 
end
  
function  this.Init() 
    this.OnUpdateItemInfo=this.UpdateRecord
    this:InitUI(85)  
end

function this.UpdateRecord(go,realindex)  
    local rindext=realindex 
    if go~=nil then 
        go.name=rindext 
        local lab_date=child(go.transform, "lab_date")--日期
        local lab_type=child(go.transform, "lab_type")--类型
        local lab_reward=child(go.transform, "lab_reward")--盈利 
        addClickCallbackSelf(go.gameObject,this.opendetails,hall_ui) 
        if this.wraprecord[rindext]==nil then
            return
        end
        if  this.wraprecord[rindext].gid~=nil then
           componentGet(lab_type,"UILabel").text="牌局类型:"..NameByGidTbl[tonumber(this.wraprecord[rindext].gid)]
        end
        if  this.wraprecord[rindext].ts~=nil then
        componentGet(lab_date,"UILabel").text ="日期:".. os.date("%Y.%m.%d",this.wraprecord[rindext].ts)
        end 
        local sp_cup=componentGet(child(go.transform,"sp_reward"),"UISprite")
        local lab_bnumber=componentGet(child(go.transform,"lab_bnumber"),"UILabel")
        local lab_gnumber=componentGet(child(go.transform,"lab_gnumber"),"UILabel") 
        if this.wraprecord[rindext] ~= nil and this.wraprecord[rindext].all_score~=nil  then
            if  tonumber(this.wraprecord[rindext].all_score) >=0  then
                lab_gnumber.gameObject:SetActive(true)
                lab_bnumber.gameObject:SetActive(false)  
                lab_gnumber.text="+"..this.wraprecord[rindext].all_score
                sp_cup.spriteName="jiangbei"
            else 
                lab_bnumber.gameObject:SetActive(true)
                lab_gnumber.gameObject:SetActive(false)
                lab_bnumber.text=this.wraprecord[rindext].all_score 
                sp_cup.spriteName="jiangbei02"
            end
        end
    end 
     
end



function this.opendetails(obj1,obj2)
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    local rid=this.wraprecord[tonumber(obj2.name)].rid   
    if rid==0 then 
       recorddetails_ui.Show()    
    else 
       http_request_interface.getRoomByRid(rid,1,function (str)   
           local s=string.gsub(str,"\\/","/")  
           local t=ParseJsonStr(s) 
           recorddetails_ui.Show(t)   
       end)
    end  
end


function this.OnUpdateToEnd()
    http_request_interface.getRoomSimpleByUid(nil,2,this.page,function (str)
        local s=string.gsub(str,"\\/","/")  
        local t=ParseJsonStr(s)
        Trace(str)
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
--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



require"logic/hall_sys/record_ui/openrecord/open1"
require"logic/hall_sys/record_ui/openrecord/open2"
--endregion
openrecord_ui=ui_base.New()
local this=openrecord_ui 
local record1={}
local record2={} 
local page1=0
local page2=0 
local roomstatus=
{
    "已开房",
    "已开局",
    "已结算",
    "未开局",
}

function this.Show(code) 
  if IsNil(this.gameObject) then
    require ("logic/hall_sys/record_ui/openrecord_ui")
    this.gameObject=newNormalUI("app_8/ui/openrecord_ui/openrecord_ui")
  else
    this.gameObject:SetActive(true)
  end  
   
    this.addlistener()  
     if code~=2 then 
        componentGet(this.toggle_record1,"UIToggle").value=true
        open1.InitData(record1) 
    else
        componentGet(this.toggle_record2,"UIToggle").value=true
        open2.InitData(record2) 
    end
end 
function this.Start() 
    this:RegistUSRelation()
end

function this.OnDestroy()
    this:UnRegistUSRelation()
end

function this.Hide()
    if not IsNil(this.gameObject) then
        GameObject.Destroy(this.gameObject)
        this.gameObject=nil
    end
    this.ClearInfo()
end
 
function this.ClearInfo()
    record1={}
    record2={}
    open1.page=1
    open2.page=1
end
function this.addlistener()
    local btn_close=child(this.transform,"openrecord_panel/btn_close")
    if btn_close~=nil then
        addClickCallbackSelf(btn_close.gameObject,this.Hide,this)
    end

    this.toggle_record2=child(this.transform,"openrecord_panel/Panel_Middle/toggle_jieshu")
    if this.toggle_record2~=nil then
        addClickCallbackSelf(this.toggle_record2.gameObject,this.Refresh2,this)
    end
    this.toggle_record1=child(this.transform,"openrecord_panel/Panel_Middle/toggle_weikaishi")
    if this.toggle_record1~=nil then
        addClickCallbackSelf(this.toggle_record1.gameObject,this.Refresh1,this)
    end 
    this.scrollbar=componentGet( child(this.transform,"openrecord_panel/Panel_Middle/scroll_bar").gameObject,"UIScrollBar") 
end


function this.LoadInfo(c)
    http_request_interface.getRoomSimpleList(nil,{0,1,3},0, function (str)
           local s=string.gsub(str,"\\/","/")  
           local t=ParseJsonStr(s)  
            
           Trace(str)
           record1={} 
           for k,v in pairs(t.data) do
              table.insert(record1,v)  
           end    
           if c==1 then  
              this.Show(1)  
           end 
           open1.page=1
           http_request_interface.getRoomSimpleList(nil,{2}, 0, function (str) 
               local s=string.gsub(str,"\\/","/")  
               local t=ParseJsonStr(s)  
               Trace(str)
               record2={}
               for k,v in pairs(t.data) do 
                  table.insert(record2,v) 
               end
               if c==2 then 
                  this.Show(2) 
               end 
               
               open2.page=1
          end)
    end)
    
end
function this.Refresh1()
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    open1.InitData(record1)  
end
function this.Refresh2()
     ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
     open2.InitData(record2)  
end 
 

 

function this.messagebox(obj1,obj2)
   local statusn=tonumber(obj1.wraprecord[tonumber(obj2.name)].status)+1
   if roomstatus[statusn]=="已开房" then
    message_box.ShowGoldBox(GetDictString(6027),{function()message_box.Close() end,function()message_box.Close()this.enter(obj1,child(obj2.transform,"btn_enter"))  end},{"quxiao","queding"},{"button_03","button_02"}) 
    elseif roomstatus[statusn]=="未开局" then
     message_box.ShowGoldBox(GetDictString(6028),{function()message_box.Close() end},{"queding"},{"button_02"})
    elseif roomstatus[statusn]=="已结算" then
        this.opendetail(open2.wraprecord[tonumber(obj2.name)])
    end
end

function this.opendetail(data)
    openrecord_ui.Hide()
    local rid=data.rid
    waiting_ui.Show()
    http_request_interface.getRoomByRid(rid,1,function (str)
        local s=string.gsub(str,"\\/","/")  
        local t=ParseJsonStr(s)
        Trace(str)
        recorddetails_ui.Show(t) 
        waiting_ui.Hide()  
    end) 
end 

function this.UpdateInfo(go,t)
    local lab_data=child(go.transform,"sp_data/lab_data")
    if lab_data~=nil then
        componentGet(lab_data.gameObject,"UILabel").text=os.date("%Y/%m/%d %H:%M",t.ctime)
    end  
    local lab_number=child(go.transform,"sp_number/lab_number")
    componentGet(lab_number.gameObject,"UILabel").text=go.name
    local lab_rno=child(go.transform,"lab_rno")
    if lab_rno~=nil then
        componentGet(lab_rno.gameObject,"UILabel").text=t.rno
    end
    local lab_status=child(go.transform,"lab_status")
    if lab_status~=nil then
        componentGet(lab_status.gameObject,"UILabel").text=roomstatus[tonumber(t.status)+1]
    end
    local btn_enter=child(go.transform,"btn_enter")
    if roomstatus[tonumber(t.status)+1]=="已结算" or roomstatus[tonumber(t.status)+1]=="未开局" then 
        componentGet(btn_enter.gameObject,"UIButton").enabled=false
        addClickCallbackSelf(btn_enter.gameObject,function()end,this)
        componentGet(child(btn_enter.transform,"Background").gameObject,"UISprite").spriteName="jinruyouxi"
    else
        componentGet(child(btn_enter.transform,"Background").gameObject,"UISprite").spriteName="jinruyouxi01"
        componentGet(btn_enter.gameObject,"UIButton").enabled=true
        addClickCallbackSelf(btn_enter.gameObject,this.enter,this)
    end
end

function this.enter(obj1,obj2)     
    join_room_ctrl.JoinRoomByRno(open1.wraprecord[tonumber(obj2.transform.parent.name)].rno)
end
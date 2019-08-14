--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
require"logic/common_ui/ui_wrap"
open2=ui_wrap.New()
local this=open2


function this.Start()
    this.Init() 
end
function this.InitData(data)   
    this.Init() 
    this:Initdate(data) 
end
  
function  this.Init() 
    this.OnUpdateItemInfo=this.UpdateRecord
    this:InitUI(95)  
end

function this.UpdateRecord(go,realindex)  
    local rindext=realindex  
    local va=rindext/this.maxCount
    if this.maxCount<5 or rindext<6 then
        openrecord_ui.scrollbar.value=0
    else 
        openrecord_ui.scrollbar.value=va
    end
    local t= this.wraprecord[rindext]
    go.name=rindext
    addClickCallbackSelf(go.gameObject,openrecord_ui.messagebox,this)
    if t~=nil then
        openrecord_ui.UpdateInfo(go,t) 
    end
end

function this.OnUpdateToEnd()
    http_request_interface.getRoomSimpleList(nil,{0,1,3},page1, function (str)
       local s=string.gsub(str,"\\/","/")  
       local t=ParseJsonStr(s)  
       Trace(str) 
       for k,v in pairs(t.data) do
          table.insert(this.wraprecord,v)  
       end  
       if table.getCount(t.data)>0 then 
          this.page=this.page+1
       end  
       this.maxCount=table.getCount(this.wraprecord) 
       this.wrap.minIndex = -this.maxCount+1
    end) 

end
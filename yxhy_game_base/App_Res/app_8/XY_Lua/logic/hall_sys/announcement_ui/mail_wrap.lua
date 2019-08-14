--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion 
mail_wrap={}
local this=mail_wrap

local  grid=nil
local  scrollview=nil
local  maxCount=0
local  wraprecord=nil
local  page=0
local  mitem=nil
local  itemheight=0
function this.InitData(data)   
    maxCount=table.getCount(data)
    wraprecord=data
    this.Init() 
    this.Initdate(data)  
end
  
function this.Init() 
    scrollview=subComponentGet(this.transform,"scrollview","UIScrollView")
    grid=subComponentGet(this.transform,"scrollview/ui_wrapcontent","UIGrid")  
    mitem=child(this.transform,"scrollview/1")
    scrollview.onDragFinished=this.dragFinish
    itemheight=88
    grid.cellHeight=88
    this.checkRead()
    Trace(maxCount)
    this.CheckShowNoMail(maxCount)
end

function this.dragFinish()
    Trace(scrollview.transform.localPosition.y.."scrollview.transform.localPosition.y")
    if scrollview.transform.localPosition.y>=(maxCount-6)*itemheight then
        this.OnUpdateToEnd()
    end
end

function this.Initdate(data)  
    for i=0,grid.transform.childCount-1 do
        destroy(grid.transform:GetChild(i).gameObject)
    end
    for i=1,#data do
        local item  
        item=GameObject.Instantiate(mitem.gameObject)  
        item.gameObject:SetActive(true)
        item.transform.parent=grid.transform
        item.transform.localScale={x=1,y=1,z=1}
        item.name=i
        this.UpdateRecord(item.gameObject,i) 
    end 
    grid.enabled=true
    grid:Reposition()
end

function this.DeleteItem(index)
    local item=child(grid.transform,tostring(index))
    table.remove(wraprecord,index) 
    maxCount=table.getCount(wraprecord)
    this.Initdate(wraprecord)  
end

function this.UpdateRecord(go,realindex) 
    local rindext=realindex   
    
    if wraprecord[rindext]==nil then
        go.gameObject:SetActive(false)
        return
    end
    local redpoint=child(go.transform,"sp_red")  
    redpoint.gameObject:SetActive(wraprecord[rindext].status==0) 
    componentGet(go.gameObject,"UIToggle").enabled = true
    if go~=nil then
        local lab_name=child(go.transform,"lab_name")   
        local lab_noname=child(go.transform,"lab_NOname")
        componentGet(lab_name.gameObject,"UILabel").text=wraprecord[rindext].title 
        componentGet(lab_noname.gameObject,"UILabel").text=wraprecord[rindext].title 
        go.name=rindext  
        addClickCallbackSelf(go.gameObject,this.toggleclick,this) 
    end
    if rindext~=announcement_ui.currentindex then
        componentGet(go.gameObject,"UIToggle").value=false  
        child(go.transform,"Checkmark").gameObject:SetActive(false)
    else
        componentGet(go.gameObject,"UIToggle").value=true   
        child(go.transform,"Checkmark").gameObject:SetActive(true) 
        redpoint.gameObject:SetActive(false) 
        componentGet(announcement_ui.lab_content.gameObject,"UILabel").text=wraprecord[rindext].content
        http_request_interface.readEmail(wraprecord[rindext].eid,function(str)Trace(str) end)  
    end  
    
    if wraprecord[rindext]==nil then
        go.gameObject:SetActive(false)
        return
    end
end
 

function this.OnUpdateToEnd()
    http_request_interface.getEmails(page+1,function (str) 
        local s=string.gsub(str,"\\/","/")  
        local t=ParseJsonStr(s) 
        Trace(str)
        if t.ret==0 then 
            local count=table.getCount(wraprecord)
            for i=1,table.getCount(t.data) do
                wraprecord[i+count]=t.data[i]
            end
            maxCount=table.getCount(wraprecord) 
            if table.getCount(t.data)> 0 then
               page=page+1 
               this.Initdate(wraprecord)  
            end
       end
    end)  
end

function this.toggleclick(obj1,obj2) 
    announcement_ui.currentindex=tonumber(obj2.name) 
    child(obj2.transform,"Checkmark").gameObject:SetActive(true)
    componentGet(announcement_ui.lab_content.gameObject,"UILabel").text=wraprecord[tonumber(obj2.name)].content
    wraprecord[tonumber(obj2.name)].status = 1
    local redpoint=child(obj2.transform,"sp_red") 
    redpoint.gameObject:SetActive(false) 
    this.checkRead()
    http_request_interface.readEmail(wraprecord[tonumber(obj2.name)].eid,function(str)Trace(str) end)   
end 

function this.checkRead()
    local isshow=false 
    for i=0,grid.transform.childCount-1,1 do 
        local redpoint=child(grid.transform:GetChild(i),"sp_red")
        if  grid.transform:GetChild(i).gameObject.activeSelf then  
            if redpoint.gameObject.activeSelf  then  
               isshow=true  
            end
        end 
    end  
    local email= child(hall_ui.transform, "Panel_TopRight/sv_bottomright/Grid_dowm/btn_mail")
    child(email.transform,"sp_redpoint").gameObject:SetActive(isshow)
end

function this.CheckShowNoMail(count)
    local show = count == 0
    announcement_ui.btn_delete.gameObject:SetActive(not show)
    announcement_ui.nomailBgGo:SetActive(show)
    if show then
        local item =GameObject.Instantiate(mitem)
        item.transform.parent=grid.transform
        item.localScale={x=1,y=1,z=1}
        this.ShowFirstItemWithoutClick(grid.transform:GetChild(0))
    end
end

function this.ShowFirstItemWithoutClick(tr)
    local redpoint = child(tr,"sp_red")
    redpoint.gameObject:SetActive(false)
    tr.gameObject:SetActive(true)
    tr.localPosition = Vector3.zero
    subComponentGet(tr, "lab_name", typeof(UILabel)).text = ""
    subComponentGet(tr, "lab_NOname", typeof(UILabel)).text = ""
    componentGet(tr.gameObject,"UIToggle").value=false  
    child(tr, "Checkmark").gameObject:SetActive(false)
    componentGet(tr.gameObject,"UIToggle").enabled = false
    UIEventListener.Get(tr.gameObject).onClick = nil
end

function this.GetmaxCount()
   return maxCount
end

function this.GetRecord()
    return wraprecord
end
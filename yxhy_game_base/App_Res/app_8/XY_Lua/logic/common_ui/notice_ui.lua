--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion 
notice_ui = ui_base.New()
local this = notice_ui  
local startlabel=518/2
local endlabel=-518/2
local endpoint=-518/2
local nduration=5
local spead=1.5
local OnFinishScroll=nil
local label=nil
this.messagetable={}
function this.Show(str)
	if this.gameObject==nil then  
		this.gameObject=newNormalUI("app_8/ui/common/notice_ui") 
        this.Init() 
        this.corRunmessage(str,nduration) 
	else  
        table.insert(this.messagetable,str) 
	end 
end
 
function this.Init() 
   label=child(this.transform,"notice_pos/sv_zoumadeng/Label")
   local panel=componentGet(child(this.transform,"notice_pos/sv_zoumadeng"),"UIPanel")
   startlabel=panel.baseClipRegion.z/2
   endlabel=-panel.baseClipRegion.z/2 
end
function this.Hide()
    if not IsNil(this.gameObject) then
        GameObject.Destroy(this.gameObject)
        this.gameObject=nil
        this.Clear()
    end  
end

function this.Clear()
    OnFinishScroll=nil 
    nduration=5
    coroutine.stop(this.cor)
    this.cor=nil 
    this.messagetable={}
end

function this.corRunmessage(str,duration,onfinish)
   if label~=nil then  
       componentGet(label.gameObject,"UILabel").text=str 
       endlabel=-componentGet(label.gameObject,"UILabel").width+endpoint 
       label.transform.localPosition={x=startlabel,y=0,z=0}
       OnFinishScroll=onfinish
       if this.cor==nil then
         this.cor=coroutine.create(movelabel)
       end
       coroutine.resume(this.cor,duration) 
   end
end

function movelabel(duration) 
    while true do   
        label.transform.localPosition={x=label.transform.localPosition.x-spead,y=0,z=0} 
        coroutine.wait(0.01)   
        if tonumber(label.transform.localPosition.x)<endlabel then    
            if table.getCount(this.messagetable)>0 then 
                local s=this.messagetable[1] 
                table.remove(this.messagetable,1) 
                this.corRunmessage(s) 
                if OnFinishScroll~=nil then
                   OnFinishScroll()
                end 
            else 
                this.Hide() 
                coroutine.yield() 
            end 
        end
    end
end

 
--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

 
require"logic/hall_sys/announcement_ui/mail_wrap"
--endregion
announcement_ui =ui_base.New()
local this = announcement_ui 
this.currentindex=1  

this.nomailBgGo = nil
this.btn_delete = nil
this.lab_content=nil

function this.Show()
	if this.gameObject==nil then
		require ("logic/hall_sys/announcement_ui/announcement_ui")
		this.gameObject=newNormalUI("app_8/ui/announcement_ui/announcement_ui")
	else
		this.gameObject:SetActive(true)
	end
    this.addlistener()
end
function this.Start() 
    this:RegistUSRelation()
end

function this.OnDestroy()
    this:UnRegistUSRelation()
end


function this.addlistener()
    this.lab_content=child(this.transform,"panel_announcement/Panel_Right/sp_background/lab_details") 
    local btn_close=child(this.transform,"panel_announcement/btn_close")
    if btn_close~=nil then
        addClickCallbackSelf(btn_close.gameObject,this.Hide,this)
    end  
    this.btn_delete=child(this.transform,"panel_announcement/Panel_Right/btn_delete")
    if this.btn_delete~=nil then
        addClickCallbackSelf(this.btn_delete.gameObject,this.delete,this)
    end 
    this.nomailBgGo = child(this.transform, "panel_announcement/Panel_Right/nomailBg").gameObject
    this.nomailBgGo:SetActive(false)
end

function  this.Hide()

    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    if not IsNil(this.gameObject) then 
		GameObject.Destroy(this.gameObject)
        this.gameObject=nil
        this.emailrecord=nil
	end
end 
 

function this.IninData(data) 
    mail_wrap.InitData(data) 
end
function this.delete(obj1,obj2)  
    if this.currentindex==nil or mail_wrap.GetRecord()[this.currentindex]==nil then
        return
    end     
    http_request_interface.delEmail(mail_wrap.GetRecord()[this.currentindex].eid,function(str) 
        componentGet(this.lab_content.gameObject,"UILabel").text=""
        local index=this.currentindex  
        this.currentindex  =nil  
        mail_wrap.DeleteItem(index)
        if mail_wrap.GetmaxCount()==0 then 
             mail_wrap.checkRead() 
             mail_wrap.CheckShowNoMail(mail_wrap.GetmaxCount())
        end
    end)
    
end
 


 




 



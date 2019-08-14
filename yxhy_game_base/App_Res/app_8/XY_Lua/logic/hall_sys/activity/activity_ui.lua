--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
activity_ui = ui_base.New()
local this = activity_ui

function this.Show()  
    if this.gameObject==nil then
		require ("logic/hall_sys/activity/activity_ui")
		this.gameObject=newNormalUI("Prefabs/UI/Hall/activity_ui")
	else
		this.gameObject:SetActive(true)
	end   
     
    this.RegisterEvent()
end
function this.Start() 
    this:RegistUSRelation()
end

function this.OnDestroy()
    this:UnRegistUSRelation()
end

function this.RegisterEvent()
    local btn_close=child(this.transform,"panel_activity/btn_close")
    if btn_close~=nil then
        addClickCallbackSelf(btn_close.gameObject,this.Hide,this)
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
   -- SingleWeb.Instance:Hide()
    require"logic/common/global_define"
    local url=global_define.GetUrlData()
    local webPage=SingleWeb.Instance:GetDicObj(url);
    webPage:Hide()
end
 
--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--endregion
setting_ui =ui_base.New()
local this = setting_ui

local tableClothNameList = 
{
  "暗香疏影" , "高山流水", "幽静竹林"
}

function this.Show()
	if IsNil(this.gameObject) then
		require ("logic/hall_sys/user_ui")
		this.gameObject=newNormalUI("app_8/ui/setting_ui/setting_ui")
	else
		this.gameObject:SetActive(true)
	end 
    hall_data.Init()
end

function this.Start()
    this.UpdataInfo()
    this:RegistUSRelation()

----------------换皮十三水-------------------
	this.openlist.gameObject:SetActive(false)
	this.question.gameObject:SetActive(false)
---------------------------------------------

end

function this.OnDestroy()
    this:UnRegistUSRelation()
    PlayerPrefs.Save()
end

function this.UpdataInfo()
    this.lab_name=child(this.transform,"setting_panel/panel_middle/tex_photo/lab_name") 
    componentGet(this.lab_name.gameObject,"UILabel").text=data_center.GetLoginUserInfo().nickname

    this.tex_photo=child(this.transform,"setting_panel/panel_middle/tex_photo")
    hall_data.getuserimage(componentGet(this.tex_photo,"UITexture")) 

    this.toggle_music=child(this.transform,"setting_panel/panel_middle/toggle/toggle_music")
    if this.toggle_music~=nil then
        componentGet(this.toggle_music,"UIToggle").value=tonumber(hall_data.playerprefs.music)==1
        addClickCallbackSelf(this.toggle_music.gameObject,this.musicclick,this)
    end

    this.toggle_musiceffect=child(this.transform,"setting_panel/panel_middle/toggle/toggle_musiceffect")
    if this.toggle_musiceffect~=nil then
        addClickCallbackSelf(this.toggle_musiceffect.gameObject,this.musiceffectclick,this) 
        componentGet(this.toggle_musiceffect,"UIToggle").value=tonumber(hall_data.playerprefs.musiceffect)==1
    end

    this.toggle_shake=child(this.transform,"setting_panel/panel_middle/toggle/toggle_shake")
    if this.toggle_shake~=nil then
        addClickCallbackSelf(this.toggle_shake.gameObject,this.shakeclick,this)
        componentGet(this.toggle_shake,"UIToggle").value=tonumber(hall_data.playerprefs.shake)==1
    end

    this.toggle_check=child(this.transform,"setting_panel/panel_middle/toggle/toggle_check")
    if this.toggle_check~=nil then
        addClickCallbackSelf(this.toggle_check.gameObject,this.checkclick,this)
        componentGet(this.toggle_check,"UIToggle").value=tonumber(hall_data.playerprefs.check)==1
    end
    this.toggle_check=child(this.transform,"setting_panel/panel_middle/toggle/toggle_GPS")
    if this.toggle_check~=nil then
        addClickCallbackSelf(this.toggle_check.gameObject,this.gps,this)
        componentGet(this.toggle_check,"UIToggle").value=tonumber(hall_data.playerprefs.gps)==1
    end

    this.btn_change=child(this.transform,"setting_panel/panel_middle/toggle/btn_change")
    if game_scene.getCurSceneType() == scene_type.HENANMAHJONG or 
        game_scene.getCurSceneType() == scene_type.FUJIANSHISANGSHUI then
        local bgSP = subComponentGet(this.btn_change, "Background", "UISprite")
        if bgSP ~= nil then
            bgSP.spriteName = "zhanghaogenghuan01"
        end
    else
        if this.btn_change~=nil then
            local bgSP = subComponentGet(this.btn_change, "Background")
            if bgSP ~= nil then
                bgSP.spriteName = "zhanghaogenghuan01"
            end            
            addClickCallbackSelf(this.btn_change.gameObject, this.changeclick, this)
        end
    end

    this.btn_grid=child(this.transform,"setting_panel/panel_middle/toggle/list/Panel/Sprite/gird_table")

    local btn_close=child(this.transform,"setting_panel/btn_close")
    if btn_close~=nil then
        addClickCallbackSelf(btn_close.gameObject,this.Hide,this)
    end 
    local tex_photo=child(this.transform,"setting_panel/panel_middle/tex_photo")
    if tex_photo~=nil then
        local tx=componentGet(tex_photo,"UITexture")
        hall_data.getuserimage(tx)
    end
    local lab_id=child(tex_photo.transform,"lab_id")
    componentGet(lab_id.gameObject,"UILabel").text="ID:"..data_center.GetLoginUserInfo().uid
    local gri_table=child(this.transform,"setting_panel/panel_middle/toggle/list/sv_zhuobu/gird_table")
    for i=1,gri_table.transform.childCount do
        local btn_z=gri_table.transform:GetChild(i-1)
        if btn_z~=nil then
            addClickCallbackSelf(btn_z.gameObject,this.changedesk,this)
        end
    end

    local btn_mzsm=child(this.transform,"setting_panel/panel_middle/toggle/btn_mzsm")
    if btn_mzsm~=nil then
        addClickCallbackSelf(btn_mzsm.gameObject,this.OpenMZSM,this)
    end
    local btn_fwtk=child(this.transform,"setting_panel/panel_middle/toggle/btn_fwtk")
    if btn_fwtk~=nil then
        addClickCallbackSelf(btn_fwtk.gameObject,this.OpenFWTK,this)
    end
    local btn_yszc=child(this.transform,"setting_panel/panel_middle/toggle/btn_yszc")
    if btn_yszc~=nil then
        addClickCallbackSelf(btn_yszc.gameObject,this.OpenYSZC,this)
    end

    local lblVersion = subComponentGet(this.transform, "setting_panel/panel_middle/lab_version", "UILabel")
    if lblVersion ~= nil then
        lblVersion.text = "版本号："..data_center.GetVerCommInfo().versionNum
    end

    this.tableClothLabel = subComponentGet(this.transform, "setting_panel/panel_middle/toggle/btn_openlist/Label2", typeof(UILabel))
	this.openlist = child(this.transform,"setting_panel/panel_middle/toggle/btn_openlist")
	this.question = child(this.transform,"setting_panel/panel_middle/toggle/btn_question")
    this.Init() 
end


function this.UpdateTableClothLabel()
    local index = tonumber(hall_data.playerprefs.desk)
    if tableClothNameList[index] == nil then
        return
    end
    this.tableClothLabel.text = tableClothNameList[index]
end

function this.Init()
    this.musicclick(this.gameObject,this.toggle_music)
    this.musiceffectclick(this.gameObject,this.toggle_musiceffect)
    this.shakeclick(this.gameObject,this.toggle_shake) 
    this.openhtml()
    this:UpdateTableClothLabel()
end

function this.OpenMZSM() 
    webview_ui.url=global_define.GetMzsmUrl()   
    webview_ui:Show()
    webview_ui.UpdateTitle("mzsm")   
end

function this.OpenFWTK() 
    webview_ui.url=global_define.GetFwtkUrl()   
    webview_ui:Show()
    webview_ui.UpdateTitle("fwtk") 
end

function this.OpenYSZC() 
    webview_ui.url=global_define.GetYszcUrl()   
    webview_ui:Show()
    webview_ui.UpdateTitle("yszc")  
end


function this.openhtml()
      webview.InitwithSize(global_define.GetMzsmUrl(),180,30,180,180) 
      webview.InitwithSize(global_define.GetFwtkUrl(),180,30,180,180) 
      webview.InitwithSize(global_define.GetYszcUrl(),180,30,180,180)  
end

function this.disableuserbtn()
    this.btn_change=child(this.transform,"setting_panel/panel_middle/toggle/btn_change")
    componentGet(this.btn_change.gameObject,"UIButton").isEnabled=false
end

function this.changedesk(obj1,obj2) 
    local s=string.split(obj2.name,"_")
    hall_data.SetPlayerPrefs("desk",s[2])
    Notifier.dispatchCmd(cmdName.MSG_CHANGE_DESK) 
    PlayerPrefs.Save()
    this.UpdateTableClothLabel()
end

function this.gps(obj1,obj2)
    local value=componentGet(obj2.gameObject,"UIToggle").value
    if value then  
        hall_data.SetPlayerPrefs("gps", "1")
    else 

        hall_data.SetPlayerPrefs("gps", "0")
    end 
    PlayerPrefs.Save()
end

function this.musicclick(obj,obj2)
    local value=componentGet(obj2.gameObject,"UIToggle").value
    if value then  
        ui_sound_mgr.controlValue(0.5) 
        hall_data.SetPlayerPrefs("music", "1")
    else 
        ui_sound_mgr.controlValue(0)
        hall_data.SetPlayerPrefs("music", "0")
    end
    PlayerPrefs.Save() 
end

function this.musiceffectclick(obj,obj2)
    local value=componentGet(obj2.gameObject,"UIToggle").value
    if value then 
        ui_sound_mgr.ControlCommonAudioValue(0.5) 
        hall_data.SetPlayerPrefs("musiceffect", "1")
    else
        ui_sound_mgr.ControlCommonAudioValue(0) 
        hall_data.SetPlayerPrefs("musiceffect", "0")
    end 
    PlayerPrefs.Save()
end

function this.shakeclick(obj,obj2)
    local value=componentGet(obj2.gameObject,"UIToggle").value
    if value then  
       -- YX_APIManage.shake()
       hall_data.SetPlayerPrefs("shake", "1")
   else 

    hall_data.SetPlayerPrefs("shake", "0")
    end 
    PlayerPrefs.Save()
    Trace(tostring(value).."ss")
end

function this.checkclick(obj,obj2)
    local value=componentGet(obj2.gameObject,"UIToggle").value
    if value then  
        hall_data.SetPlayerPrefs("check", "1")
    else 
        hall_data.SetPlayerPrefs("check", "0")
    end 
    PlayerPrefs.Save()
end

function this.changeclick()
    message_box.ShowGoldBox(GetDictString(6029),
        {function()message_box:Close()  end,
        function ()  
            message_box:Close()
            game_scene.gotoLogin()  
            game_scene.GoToLoginHandle()
        end}, {"quxiao", "queding"}, {"button_03","button_02"}) 
end



function  this.Hide()
    if not IsNil(this.gameObject) then 
      destroy(this.gameObject)
      this.gameObject=nil
  end
end 
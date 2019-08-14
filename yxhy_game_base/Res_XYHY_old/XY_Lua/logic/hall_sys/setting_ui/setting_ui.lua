--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--endregion
local base = require("logic.framework.ui.uibase.ui_window")
local setting_ui = class("setting_ui", base) 

function setting_ui:ctor()
	base.ctor(self)
end

function setting_ui:OnInit()
	self:InitView()
end

function setting_ui:OnOpen()
	self:UpdateView()
end

function setting_ui:OnRefreshDepth()

    local uiEffect = child(self.gameObject.transform, "setting_panel/Panel_Top/Title/Effect_youxifenxiang")
    if uiEffect and self.sortingOrder then
        local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
        Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
    end
end

function setting_ui:InitView()
	local Panel_Middle = child(self.gameObject.transform,"setting_panel/Panel_Middle")
	self.right_hall = child(Panel_Middle,"Right_hall")
	self.right_game = child(Panel_Middle,"Right_game")
	
    self.toggle_music = child(Panel_Middle,"Left/toggle/toggle_music")
    if self.toggle_music ~= nil then
        componentGet(self.toggle_music,"UIToggle").value = tonumber(hall_data.playerprefs.music) == 1
        addClickCallbackSelf(self.toggle_music.gameObject,self.MusicClick,self)
    end

    self.toggle_musiceffect = child(Panel_Middle,"Left/toggle/toggle_musiceffect")
    if self.toggle_musiceffect ~= nil then
        addClickCallbackSelf(self.toggle_musiceffect.gameObject,self.MusicEffectClick,self) 
        componentGet(self.toggle_musiceffect,"UIToggle").value = tonumber(hall_data.playerprefs.musiceffect) == 1
    end

    self.toggle_shake = child(Panel_Middle,"Left/toggle/toggle_shake")
    if self.toggle_shake ~= nil then
        addClickCallbackSelf(self.toggle_shake.gameObject,self.ShakeClick,self)
        componentGet(self.toggle_shake,"UIToggle").value = tonumber(hall_data.playerprefs.shake) == 1
    end

    self.toggle_check = child(Panel_Middle,"Left/toggle/toggle_check")	--防作弊暂不用
    if self.toggle_check ~= nil then
        --addClickCallbackSelf(self.toggle_check.gameObject,self.CheckClick,self)
        --componentGet(self.toggle_check,"UIToggle").value = tonumber(hall_data.playerprefs.check) == 1
    end
	
    self.toggle_GPS = child(Panel_Middle,"Left/toggle/toggle_GPS")	--GPS暂不用
    if self.toggle_GPS ~= nil then
        --addClickCallbackSelf(self.toggle_GPS.gameObject,self.GpsClick,self)
        --componentGet(self.toggle_GPS,"UIToggle").value = tonumber(hall_data.playerprefs.gps) == 1
    end

    self.btn_close = child(self.gameObject.transform,"setting_panel/Panel_Top/btn_close")
    if self.btn_close ~= nil then
        addClickCallbackSelf(self.btn_close.gameObject,self.CloseWin,self)
    end 
	
	local Panel_Bottom = child(self.gameObject.transform,"setting_panel/Panel_Bottom")

    self.btn_mzsm = child(Panel_Bottom,"btn_mzsm")
    if self.btn_mzsm ~= nil then
        addClickCallbackSelf(self.btn_mzsm.gameObject,self.OpenMZSM,self)
    end
    self.btn_fwtk = child(Panel_Bottom,"btn_fwtk")
    if self.btn_fwtk ~= nil then
        addClickCallbackSelf(self.btn_fwtk.gameObject,self.OpenFWTK,self)
    end
    self.btn_yszc = child(Panel_Bottom,"btn_yszc")
    if self.btn_yszc ~= nil then
        addClickCallbackSelf(self.btn_yszc.gameObject,self.OpenYSZC,self)
    end

    --苹果审核隐藏界面
    if G_isAppleVerifyInvite then
        local btn_update=child(self.transform, "setting_panel/Panel_Middle/Right_hall/btn_update")
        if btn_update then
            btn_update.gameObject:SetActive(false)
        end
    end
end

function setting_ui:UpdateView()
	self:MusicClick(self.toggle_music)
    self:MusicEffectClick(self.toggle_musiceffect)
    self:ShakeClick(self.toggle_shake) 
	if game_scene.getCurSceneType() ~= scene_type.HALL then		--仅大厅跟游戏内两个场景显示设置
		self.right_hall.gameObject:SetActive(false)
		self.right_game.gameObject:SetActive(true)
		require"logic/hall_sys/setting_ui/game_setting":create(self.right_game)	
	else
		self.right_hall.gameObject:SetActive(true)
		self.right_game.gameObject:SetActive(false)
		require"logic/hall_sys/setting_ui/hall_setting":create(self.right_hall)
	end
end

function setting_ui:OpenMZSM() 
    ui_sound_mgr.PlayButtonClick()
	UI_Manager:Instance():ShowUiForms("textView_ui",UiCloseType.UiCloseType_CloseNothing,function() 
		Trace("Close textView_ui__3")
	end,3)
end

function setting_ui:OpenFWTK() 
    ui_sound_mgr.PlayButtonClick()
	UI_Manager:Instance():ShowUiForms("textView_ui",UiCloseType.UiCloseType_CloseNothing,function() 
		Trace("Close textView_ui__1")
	end,1)
end

function setting_ui:OpenYSZC() 
    ui_sound_mgr.PlayButtonClick()
	UI_Manager:Instance():ShowUiForms("textView_ui",UiCloseType.UiCloseType_CloseNothing,function() 
		Trace("Close textView_ui__2")
	end,2)
end


function setting_ui:GpsClick(obj2)
    local value = componentGet(obj2.gameObject,"UIToggle").value
    if value then  
        hall_data.SetPlayerPrefs("gps", "1")
    else 
        hall_data.SetPlayerPrefs("gps", "0")
    end 
    PlayerPrefs.Save()
end

function setting_ui:MusicClick(obj2)
    local value = componentGet(obj2.gameObject,"UIToggle").value
    if value then  
        ui_sound_mgr.controlValue(0.5) 
        hall_data.SetPlayerPrefs("music", "1")
    else 
        ui_sound_mgr.controlValue(0)
        hall_data.SetPlayerPrefs("music", "0")
    end
    PlayerPrefs.Save() 
end

function setting_ui:MusicEffectClick(obj2)
    local value = componentGet(obj2.gameObject,"UIToggle").value
    if value then 
        ui_sound_mgr.ControlCommonAudioValue(0.5) 
        hall_data.SetPlayerPrefs("musiceffect", "1")
    else
        ui_sound_mgr.ControlCommonAudioValue(0) 
        hall_data.SetPlayerPrefs("musiceffect", "0")
    end 
    PlayerPrefs.Save()
end

function setting_ui:ShakeClick(obj2)
    local value = componentGet(obj2.gameObject,"UIToggle").value
    if value then  
        hall_data.SetPlayerPrefs("shake", "1")
	else 
		hall_data.SetPlayerPrefs("shake", "0")
    end 
    PlayerPrefs.Save()
end

function setting_ui:CheckClick(obj2)
    local value = componentGet(obj2.gameObject,"UIToggle").value
    if value then  
        hall_data.SetPlayerPrefs("check", "1")
    else 
        hall_data.SetPlayerPrefs("check", "0")
    end 
    PlayerPrefs.Save()
end

function  setting_ui:CloseWin()	
    ui_sound_mgr.PlayCloseClick()
	UI_Manager:Instance():CloseUiForms("setting_ui")
end 

function setting_ui:OnClose()
	PlayerPrefs.Save()
end

return setting_ui
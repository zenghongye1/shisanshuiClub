
local base = require("logic.framework.ui.uibase.ui_window")
local share_ui = class("share_ui",base)

local icon = {
	["WeChat"] = "icon_06",
	["WeChatFC"] = "icon_08",
	["QQ"] = "icon_26",
	["qZone"] = "icon_30",
}

function share_ui:ctor()
	base.ctor(self)
	self.loginType = 0
    self.destroyType = UIDestroyType.Immediately
end

function share_ui:OnInit(data)
	self:InitView()
end

function share_ui:OnOpen() 
	self.loginType = data_center.GetPlatform()
    self:UpdateView()
end

-- function share_ui:PlayOpenAmination()
-- 	--打开动画重写
-- end

function share_ui:OnRefreshDepth()

  local uiEffect = child(self.gameObject.transform, "share_panel/Panel_Top/Title/Effect_youxifenxiang")
  if uiEffect and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
  end
end

function share_ui:InitView()
    local btn_close = child(self.gameObject.transform,"share_panel/Panel_Top/btn_close")
    if btn_close ~= nil  then
        addClickCallbackSelf(btn_close.gameObject,self.CloseWin,self)
    end
	
    self.btn_shareFriend = child(self.gameObject.transform,"share_panel/Panel_Middle/btn_Fshare")
    if self.btn_shareFriend ~= nil  then
        addClickCallbackSelf(self.btn_shareFriend.gameObject,self.sharefriend,self)
    end 

    self.btn_shareFriendQ = child(self.gameObject.transform,"share_panel/Panel_Middle/btn_Cshare")
    if self.btn_shareFriendQ ~= nil  then
        addClickCallbackSelf(self.btn_shareFriendQ.gameObject,self.sharefriendQ,self)
    end 
	
	self.btnFShareSp = componentGet(child(self.btn_shareFriend,"icon"),"UISprite")
	self.btnQShareSp = componentGet(child(self.btn_shareFriendQ,"icon"),"UISprite")
end

function share_ui:UpdateView()	
	if self.btnFShareSp ~= nil and self.btnQShareSp ~= nil then
		if self.loginType == LoginType.WXLOGIN then			----微信登陆
			self.btnFShareSp.spriteName = icon["WeChat"]
			self.btnQShareSp.spriteName = icon["WeChatFC"]
			--self.btnFShareSp:MakePixelPerfect()
			--self.btnQShareSp:MakePixelPerfect()
			componentGet(child(self.btn_shareFriend,"text"),"UILabel").text = "分享给微信好友"
			componentGet(child(self.btn_shareFriendQ,"text"),"UILabel").text = "分享到朋友圈"
		elseif self.loginType == LoginType.QQLOGIN then		----QQ登陆
			self.btnFShareSp.spriteName = icon["QQ"]						
			self.btnQShareSp.spriteName = icon["qZone"]
			--self.btnFShareSp:MakePixelPerfect()
			--self.btnQShareSp:MakePixelPerfect()
			componentGet(child(self.btn_shareFriend,"text"),"UILabel").text = "分享给QQ好友"
			componentGet(child(self.btn_shareFriendQ,"text"),"UILabel").text = "分享到空间"
		else
			--其他登陆方式
		end	
	end
end

function share_ui:sharefriendQ()
    ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_button_click")
    local shareType = 1--0微信/QQ好友，1朋友圈/空间，2微信收藏
    local contentType = 5 --1文本，2图片，3声音，4视频，5网页
    local title = global_define.appConfig.hallShareQTitle
    local filePath = ""
    local url = string.format(global_define.GetShareUrl(),data_center.GetLoginUserInfo().uid)
    local description = global_define.appConfig.hallShareFriendQContent
    Trace("sharefriendQ----" .. url..tostring(title))
	
	shareHelper.doShare(self.loginType,shareType,contentType,title,filePath,url,description)
end

function share_ui:sharefriend()
    ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_button_click")
    local shareType = 0--0微信好友，1朋友圈，2微信收藏
    local contentType = 5 --1文本，2图片，3声音，4视频，5网页
    local title = global_define.appConfig.hallShareTitle
    local filePath = ""
    local url = string.format(global_define.GetShareUrl(),data_center.GetLoginUserInfo().uid)
    local description = global_define.appConfig.hallShareFriendContent
    Trace("sharefriend----" .. url..tostring(description))
	
	shareHelper.doShare(self.loginType,shareType,contentType,title,filePath,url,description)
end

function share_ui:CloseWin()
    ui_sound_mgr.PlayCloseClick()
    UI_Manager:Instance():CloseUiForms("share_ui")
end

return share_ui
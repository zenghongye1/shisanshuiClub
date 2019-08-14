--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
require "logic/hall_sys/openroom/room_data"
share_ui = ui_base.New()
local this = share_ui


function this.Show(data)
	if this.gameObject==nil then
		require ("logic/hall_sys/share/share_ui")
		this.gameObject = newNormalUI("app_8/ui/share_ui/share_ui")
	else
		this.gameObject:SetActive(true) 
	end 
    this.addlistener()
end
function this.Hide()
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    if this.gameObject==nil then
		return
	else
		GameObject.Destroy(this.gameObject)
        this.gameObject=nil
	end
end
function this.Start() 
    this:RegistUSRelation()
end

function this.OnDestroy()
    this:UnRegistUSRelation()
end
function this.addlistener()
    local btn_close=child(this.transform,"share_panel/btn_close")
    if btn_close~=nil  then
        addClickCallbackSelf(btn_close.gameObject,this.Hide,this)
    end

    local btn_sharefriend=child(this.transform,"share_panel/Panel_Middle/btn_WXFshare")
    if btn_sharefriend~=nil  then
        addClickCallbackSelf(btn_sharefriend.gameObject,this.sharefriend,this)
    end 

    local btn_sharefriendQ=child(this.transform,"share_panel/Panel_Middle/btn_WXCshare")
    if btn_sharefriendQ~=nil  then
        addClickCallbackSelf(btn_sharefriendQ.gameObject,this.sharefriendQ,this)
    end 
end

function this.sharefriendQ()
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    Trace("this.sharefriendQ")
    local shareType = 1--0微信好友，1朋友圈，2微信收藏
    local contentType = 5 --1文本，2图片，3声音，4视频，5网页
    local title = global_define.hallShareQTitle
    local filePath = ""
    local url = string.format(global_define.GetShareUrl(),data_center.GetLoginUserInfo().uid)
    --local url = global_define.preWebUrl .. subUrl
    Trace("sharefriend----" .. url)

    local description = global_define.hallShareFriendQContent
    YX_APIManage.Instance:WeiXinShare(shareType,contentType,title,filePath,url,description)
end

function this.sharefriend()
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    Trace("this.sharefriend")
    local shareType = 0--0微信好友，1朋友圈，2微信收藏
    local contentType = 5 --1文本，2图片，3声音，4视频，5网页
    local title = global_define.hallShareTitle
    local filePath = ""
    local url = string.format(global_define.GetShareUrl(),data_center.GetLoginUserInfo().uid)
    --local url = global_define.preWebUrl .. subUrl
    Trace("sharefriend----" .. url)
    local description = global_define.hallShareFriendContent

    YX_APIManage.Instance:WeiXinShare(shareType,contentType,title,filePath,url,description)
end
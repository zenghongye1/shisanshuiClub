--[[--
 * @Description: 大厅数据层
 * @Author:      shine
 * @FileName:    hall_data.lua
 * @DateTime:    2017-05-19 14:33:40
 ]]

require "logic/common/HeadImageHelper"
hall_data = {}
local this = hall_data
local UIManager = UI_Manager:Instance() 
--大厅存储的数据 
local chooseRoomClick = false
-- 是否绑定运营商
local hasBindAgent = false
--是否第一次登录
this.ShowApply = false
this.playerprefs={
    music=1,
    musiceffect=1,
    desk=1,
    shake=1,
    check=1,
    gps=1,
}
this.jcGameUrl = ""

--[[--
 * @Description: 数据初始化  
 ]]
function this.Init()  
   if tonumber(this.GetPlayerPrefs("FristLogin")) ~= 1 then
       for k ,v in pairs(this.playerprefs)do
           this.SetPlayerPrefs(k,v)   
       end
       this.SetPlayerPrefs("FristLogin", "1") 
       PlayerPrefs.Save()
   end  
   
   for k ,v in pairs(this.playerprefs)do
     this.playerprefs[k] = this.GetPlayerPrefs(k)  
   end   
    
   if tonumber(this.playerprefs.musiceffect) == 1 then
      ui_sound_mgr.ControlCommonAudioValue(0.5) 
   else
      ui_sound_mgr.ControlCommonAudioValue(0) 
   end 
   
   if tonumber(this.playerprefs.music) == 1 then
     ui_sound_mgr.controlValue(0.5)  
   else
     ui_sound_mgr.controlValue(0)
   end 
   this.register()  
end

function this.register() 
    Notifier.regist(cmdName.MSG_ROOMCARD_REFRESH, this.UpdateInfo)
    Notifier.regist(cmdName.MSG_SHAKE, this.PhoneShake)
    Notifier.regist(cmdName.MSG_HASACTIVITY, this.HasActivity)
    Notifier.regist(cmdName.MSG_APP_NOTIFY, this.onMsgAppNotify)
	Notifier.regist(cmdName.MSG_FeedBackMsg, this.onMsgFeedBack)
	Notifier.regist(cmdName.MSG_EmailMsg, this.onMsgEmail)
end

function this.onMsgEmail(data)
	hall_ui:ShowEmailRedPoint(true)
end

function this.onMsgFeedBack(data)
	hall_ui:ShowFeedBackRedPoint(true)
	local feedback_ui = UI_Manager:Instance():GetUiFormsInShowList("feedback_ui")
	if feedback_ui ~= nil then
		this.feedback_data = require ("logic/hall_sys/feedback_ui/feedback_data"):create(feedback_ui)
		this.feedback_data:RefreshPushMsg(data)
	end
end

function this.onMsgAppNotify()
  invite_sys.LoadMWParam()
  this.LoadJPushParam()
end 

--JPush
function this.LoadJPushParam()
  local strFile = "tempPush.txt"
  local s = YX_APIManage.Instance:read(strFile)
  if s == nil then
    return
  end
  YX_APIManage.Instance:deleteFile(strFile)

  local dataTbl = nil 
  local msg = string.gsub(s, "\\/", "/")
  if not pcall( function() dataTbl = ParseJsonStr(msg) end) then
    Trace("LoadJPushParam---error:"..msg)
    return
  end
  local useinfo = data_center.GetLoginUserInfo()
  if useinfo.uid ~= dataTbl.uid then
    logError("当前uid与会长uid不匹配~~~~~~~~")
    return
  end
  if dataTbl.type and dataTbl.cid and dataTbl.type == "open_apply_list" then
      UI_Manager:Instance():ShowUiForms("ClubApplyUI",UiCloseType.UiCloseType_CloseNothing,nil,dataTbl.cid)
  end

end

function this.checkIdCard() 
	if hall_ui == nil then
		return
	end
	http_request_interface.checkIdCard(nil,function(str)
		local s = string.gsub(str,"\\/","/")  
		local t = ParseJsonStr(s)
		hall_ui:SetAuthShow(tonumber(t.ret)~=0)
	end) 
end

function this.Unregister()
    Notifier.remove(cmdName.MSG_ROOMCARD_REFRESH, this.UpdateInfo)
    Notifier.remove(cmdName.MSG_SHAKE,this.PhoneShake)
    Notifier.remove(cmdName.MSG_HASACTIVITY,this.HasActivity)
    Notifier.remove(cmdName.MSG_APP_NOTIFY,this.onMsgAppNotify)
	Notifier.remove(cmdName.MSG_FeedBackMsg, this.onMsgFeedBack)
	Notifier.remove(cmdName.MSG_EmailMsg, this.onMsgEmail)
end

function this.HasActivity(data)
    -- local redpoint=child(hall_ui.transform,"Panel_TopRight/Grid_TopRight/btn_activity/sp_red")
    -- if tonumber(data)==1 then
    --     redpoint.gameObject:SetActive(true)
    -- else
    --     redpoint.gameObject:SetActive(false)
    -- end
end

function this.UpdateInfo(accountData)
	if type(accountData) ~= "table" then
		return
	end
    data_center.GetLoginUserInfo().card = accountData.card
    if hall_ui then 
        hall_ui:UpdateInfo(accountData)
    end
    Trace("Updatacoin-----------------------------------") 
end

function this.PhoneShake()
  if tonumber(this.playerprefs.shake) == 1 then
    YX_APIManage.Instance:shake()
  end
end

local times=0
this.animationtable={}
this.texList = {}

function this.staranimation()
  times=times+1
  --Trace("times"..times)
  if times==10 then
      for i=1,table.getCount(this.animationtable) do
          local an=componentGet(this.animationtable[i].gameObject,"SkeletonAnimation") 
          an.AnimationName=this.animationtable[i].gameObject.name
          an.playComPleteCallBack=function()
              an.AnimationName=""   
          end
      end
      times=0
  end
end
 
function this.getuserimage(tx, itype, iurl,uid)
	if not tx then
		return
	end
  
    itype=itype or data_center.GetLoginUserInfo().imagetype
    iurl=iurl or data_center.GetLoginUserInfo().imageurl
    local imagetype=itype
    local imageurl=iurl
    if tonumber(imagetype)~=2 then
        if IsNil(this.baseImage) then
            local baseImagePrefab = newNormalObjSync(data_center.GetAppConfDataTble().appPath.."/uitextures/art/common_head", typeof(UnityEngine.Texture2D))
            this.baseImage = newobject(baseImagePrefab)
            GameObject.DontDestroyOnLoad(this.baseImage)
        end
        --imageurl=global_define.defineimg
        tx.mainTexture = this.baseImage
        return
    end
    DownloadCachesMgr.Instance:LoadImage(imageurl,function( code,texture )
		if code == 0 then
			tx.mainTexture = texture
			if (uid ~= nil) then
				this.texList[tostring(uid)] = texture
			end
		else
			if IsNil(this.baseImage) then
				local baseImagePrefab = newNormalObjSync(data_center.GetAppConfDataTble().appPath.."/uitextures/art/common_head", typeof(UnityEngine.Texture2D))
				this.baseImage = newobject(baseImagePrefab)
				GameObject.DontDestroyOnLoad(this.baseImage)
			end
			tx.mainTexture = this.baseImage
		end
    end)
end

function this.SetPlayerPrefs(key, v)
    PlayerPrefs.SetString(key, v)
    if this.playerprefs[key]~=nil then
      this.playerprefs[key] = v
    end
end

function this.GetPlayerPrefs(key)
    return PlayerPrefs.GetString(key)
end

function this.SetChooseRoomClick(isClick)
    chooseRoomClick = isClick
end

function this.CheckIsChooseRoomClick()
    return chooseRoomClick
end

function this.BindAgent()
  hasBindAgent = true
end

-- 暂时不缓存绑定信息
-- @TODO 切账号时清理数据
function this.CheckHasBindAgent()
  return false
  -- return hasBindAgent
end

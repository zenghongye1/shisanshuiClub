--[[--
 * @Description: 大厅数据层
 * @Author:      shine
 * @FileName:    hall_data.lua
 * @DateTime:    2017-05-19 14:33:40
 ]]

hall_data = {}
local this = hall_data

--大厅存储的数据 
local chooseRoomClick = false
-- 是否绑定运营商
local hasBindAgent = false
this.playerprefs={
    music=1,
    musiceffect=1,
    desk=1,
    shake=1,
    check=1,
    gps=1,
}


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
     this.playerprefs[k]=this.GetPlayerPrefs(k)  
   end   
    
   if tonumber(this.playerprefs.musiceffect)==1 then
      ui_sound_mgr.ControlCommonAudioValue(0.5) 
   else
      ui_sound_mgr.ControlCommonAudioValue(0) 
   end 
   
   if tonumber(this.playerprefs.music)==1 then
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
end
function this.onMsgAppNotify()
   this.checkInviteroom()
end 


function this.checkIdCard() 
    local uitable=hall_ui.Getuitable()
   http_request_interface.checkIdCard(nil, function (str)
     local s=string.gsub(str,"\\/","/")  
     local t=ParseJsonStr(s)  
     if tonumber(t.ret)==0 then 
       if uitable.btn_renzheng~=nil then
          uitable.btn_renzheng.gameObject:SetActive(false)
       end
     else
       if uitable.btn_renzheng~=nil then
          uitable.btn_renzheng.gameObject:SetActive(true)
       end
     end
   end) 
end





function this.Unregister()
    Notifier.remove(cmdName.MSG_ROOMCARD_REFRESH, this.UpdateInfo)
    Notifier.remove(cmdName.MSG_SHAKE,this.PhoneShake)
    Notifier.remove(cmdName.MSG_HASACTIVITY,this.HasActivity)
    Notifier.remove(cmdName.MSG_APP_NOTIFY,this.onMsgAppNotify)
end

function this.HasActivity(data)
    local redpoint=child(hall_ui.transform,"Panel_TopRight/Grid_TopRight/btn_activity/sp_red")
    if tonumber(data)==1 then
        redpoint.gameObject:SetActive(true)
    else
        redpoint.gameObject:SetActive(false)
    end
end

---检测邀请
function this.checkInviteroom() 
   local s= YX_APIManage.Instance:read("temp.txt")
   if s~=nil then
      Trace(s)
      Trace("hall_ui temp.txt str-----" .. s)
      local t=ParseJsonStr(s)
      if t.roomId then
        Trace("hall_ui temp.txt t.roomId-----" .. t.roomId)
        waiting_ui.Show() 
        join_room_ctrl.JoinRoomByRno(tonumber(t.roomId))
      end 
       YX_APIManage.Instance:deleteFile("temp.txt")
   end
end

function this.UpdateInfo(roomcard)
    data_center.GetLoginUserInfo().card=roomcard 
    if not IsNil(hall_ui.gameObject) then 
        hall_ui.InitInfo()
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
 
function this.getuserimage(tx, itype, iurl)
    itype=itype or data_center.GetLoginUserInfo().imagetype
    iurl=iurl or data_center.GetLoginUserInfo().imageurl
    local imagetype=itype
    local imageurl=iurl
    if tonumber(imagetype)~=2 then
        --imageurl=global_define.defineimg
        tx.mainTexture = newNormalObjSync("app_8/uitextures/art/common_head", typeof(UnityEngine.Texture2D))
        return
    end
    DownloadCachesMgr.Instance:LoadImage(imageurl,function( code,texture )
      if code == 0 then
        tx.mainTexture = texture 
      else
        tx.mainTexture = newNormalObjSync("app_8/uitextures/art/common_head", typeof(UnityEngine.Texture2D))
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

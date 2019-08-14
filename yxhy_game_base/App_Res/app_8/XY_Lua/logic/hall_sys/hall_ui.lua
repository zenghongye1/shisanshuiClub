 --[[--
 * @Description: 大厅ui组件
 * @Author:      shine
 * @FileName:    hall_ui.lua
 * @DateTime:    2017-05-19 14:33:25
 ]]
 
require "logic/hall_sys/hall_data"
require "logic/hall_sys/hall_ui_ctrl"  
require "logic/network/http_request_interface"
require "logic/hall_sys/user_ui"  
require "logic/hall_sys/shop/shop_ui"  
require "logic/hall_sys/certification_ui"
require "logic/network/majong_request_protocol" 
require "logic/hall_sys/openroom/openroom_main_ui"
require "logic/hall_sys/setting_ui/setting_ui"
require "logic/hall_sys/record_ui/record_ui"
require "logic/hall_sys/announcement_ui/announcement_ui"
require "logic/hall_sys/join_room/join_room_ui"
require "logic/hall_sys/record_ui/recorddetails_ui"
require "logic/hall_sys/share/share_ui"
require "logic/hall_sys/service_ui"
require "logic/hall_sys/help_ui" 
require "logic/common/join_room_ctrl"
require "logic/hall_sys/record_ui/openrecord_ui"
require "logic/hall_sys/invite_code_input/invite_code_input_ui"
require "logic/common_ui/webview_ui"


hall_ui = ui_base.New()
local this = hall_ui 
local transform
 
local arrowTimer = nil

local uitable = {}

function this.Awake() 
   this.registerevent() 
   hall_data.checkIdCard()
   hall_data.checkInviteroom()  
   hall_data.Init() 
   this.InitInfo()  
   if tostring(Application.platform)  == "Android" or tostring(Application.platform) == "IPhonePlayer" then
      hall_ui.LoadWebPage()
   end  
   --用于苹果审核
   if LuaHelper.isAppleVerify ~= nil and LuaHelper.isAppleVerify then
     this.AppleVerifyHandler()
   end
end

function this.AppleVerifyHandler()
  uitable.btn_shopicon.gameObject:SetActive(false)  
  local sp_fk = child(this.btn_photo.transform, "sp_fkBackground/Sprite")
  if sp_fk ~= nil then
    sp_fk.gameObject:SetActive(false)
  end

  local sp_bg = child(this.btn_photo.transform, "sp_fkBackground")
  if sp_bg ~= nil then
    sp_bg.gameObject:SetActive(false)
  end
  uitable.btn_share.gameObject:SetActive(false) 
  uitable.btn_activity.gameObject:SetActive(false)  
  uitable.btn_shop.gameObject:SetActive(false)   

  local btnBottom = child(this.transform, "Panel_BottomRight/btn_bottom")
  if btnBottom ~= nil then
    btnBottom.gameObject:SetActive(false)
  end
end
 
  
function  this.LoadWebPage() 
  local url=global_define.GetUrlData()
  if(url == nil) then
    Trace("url wei nil")
    return
  else
    Trace("url bu wei nil")
  end  
  webview.InitwithSize(url,180,30,180,180)    
  webview.AddReceiveFunctionByurl(url,function(webView, message)
       if message.path=="move" then    
          webview_ui.OnBtnCloseClick()
          openroom_main_ui.Show()
       end
       if message.path=="yaoqing" then    
          webview_ui.OnBtnCloseClick()
          share_ui.Show()
       end
   end) 
end
 
--[[--
 * @Description: 初始化设置UI  
 ]] 

--[[--
 * @Description: 逻辑入口  
 ]]
 function this.Start()   
	--this:RegistUSRelation() 
    
end 
function  this.OnEnable() 
   ui_sound_mgr.PlayBgSound("hall_bgm")     
end
--[[--
 * @Description: 销毁  
 ]]
 function this.OnDestroy()
	--this:UnRegistUSRelation()
   hall_ui_ctrl.UInit() 
   hall_data.Unregister()
   if arrowTimer ~= nil then
     arrowTimer:Stop()
     arrowTimer = nil
   end
end

--注册事件
function this.registerevent()  
   this.RegisterUI()       
   Notifier.regist(cmdName.MSG_APP_NOTIFY,this.onMsgAppNotify)
end

function this.onMsgAppNotify( )
   this.checkInviteroom()
end

 
function this.RegisterUI()   
-------------------左上------------------------
    local panel_topleft=child(this.transform,"Panel_TopLeft")
    uitable.btn_photo =AddListener(panel_topleft,"btn_photo",this.Onbtn_goldClick) 
    uitable.btn_shop=AddListener(uitable.btn_photo,"sp_fkBackground/btn_shop",this.shop) 

-------------------右上------------------------

    local panel_topright=child(this.transform, "Panel_TopRight")
    uitable.btn_renzheng= AddListener(panel_topright,"sv_bottomright/Grid_dowm/btn_renzheng",this.certification) --认证 
    uitable.btn_mail=AddListener(panel_topright,"sv_bottomright/Grid_dowm/btn_mail",this.announcement) --邮件  
    uitable.btn_share=AddListener(panel_topright,"Grid_TopRight/btn_share",this.share) --分享  
    uitable.btn_help=AddListener(panel_topright, "sv_bottomright/Grid_dowm/btn_help",this.help) --玩法   
    uitable.btn_setting=AddListener(panel_topright, "sv_bottomright/Grid_dowm/btn_setting",this.setting) --设置 
    uitable.btn_shopicon=AddListener(panel_topright, "Grid_TopRight/btn_shop",this.shop) --商店    
    uitable.btn_customerservice=AddListener(panel_topright, "sv_bottomright/Grid_dowm/btn_customerservice",this.service) --客服      
    uitable.btn_activity=AddListener(panel_topright, "Grid_TopRight/btn_activity",this.activity) --客服      
    
-------------------中间------------------------
    uitable.btn_join= AddListener(this, "Panel_Middle/btn_join",this.joinroom) --房间1      
    uitable.btn_open= AddListener(this, "Panel_Middle/btn_open",this.OpenRoomClick) --房间2     
   
    local animation1=child(uitable.btn_join.transform,"tex_bg") 
    if animation1~=nil then 
       componentGet(animation1.gameObject,"SkeletonAnimation"):ChangeQueue(3002)
    end

    local animation2=child(uitable.btn_open.transform,"tex_bg") 
    if animation2~=nil then 
       componentGet(animation2.gameObject,"SkeletonAnimation"):ChangeQueue(3002)
    end

    local animation4=child(uitable.btn_join.transform,"hudie_2") 
    if animation4~=nil then 
       local a=componentGet(animation4.gameObject,"SkeletonAnimation")
       a:ChangeQueue(3001)
       a.playComPleteCallBack=function()
           a.AnimationName=""  
       end
    end

    local animation3=child(uitable.btn_join.transform,"hudie_1") 
    if animation3~=nil then 
       local a=componentGet(animation3.gameObject,"SkeletonAnimation")
       a:ChangeQueue(3003)
       a.playComPleteCallBack=function()
          a.AnimationName=""  
       end
    end

    hall_data.animationtable ={animation3,animation4} 
    arrowTimer = Timer
    arrowTimer = Timer.New(hall_data.staranimation, 1, -1)
    arrowTimer:Start() 

-------------------左中------------------------
    local panel_left=child(this.transform, "Panel_Left")
    uitable.toggle_record= AddListener(panel_left, "sp_left/toggle_record",this.record) --历史记录   
    uitable.toggle_openrecord= AddListener(panel_left, "sp_left/toggle_openrecord",this.openrecord) --开放记录  
    uitable.toggle_switch=AddListener(panel_left, "sp_left/toggle_switch",this.OnFreshrecordClick) --记录开关   

    uitable.WrapContent_record =subComponentGet(panel_left.transform, "sp_left/sv_record/grid_record","UIWrapContent")
    if uitable.WrapContent_record ~= nil then
       uitable.WrapContent_record.onInitializeItem = record_ui.OnUpdateItem_record
    end 

    uitable.WrapContent_openrecord =subComponentGet(panel_left.transform, "sp_left/sv_openrecord/grid_openrecord","UIWrapContent")
    if uitable.WrapContent_openrecord ~= nil then
       uitable.WrapContent_openrecord.onInitializeItem = record_ui.OnUpdateItem_openrecord
    end  
end 

  


--------------------------------------按钮相关逻辑----------------------------------------- 

function this.Onbtn_goldClick()
   Trace("Onbtn_goldClick")  
   PlayerPrefs.DeleteAll()
end

function this.share()
   share_ui.Show()
   ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
end

function this.activity(obj1,obj2) 
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    if tostring(Application.platform)  == "Android" or tostring(Application.platform) == "IPhonePlayer" then 
          local url=global_define.GetUrlData()
          webview_ui.url=url
          webview_ui:Show()
          webview_ui.UpdateTitle("hdgg-fonts")   
    end
end

function this.shop()    
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    waiting_ui.Show()
    if not hall_data.CheckHasBindAgent() then
        http_request_interface.CheckIsBindAgent(
        function(ret, status) 
           if ret == 0 then
              if status == 0 then
                  invite_code_input_ui.Show() 
              else
                  hall_data.BindAgent()
                  --this.ShowShop()
				  service_ui.Show()
              end 
              waiting_ui.Hide()
           end
        end)
    else
       this.ShowShop()
       waiting_ui.Hide()
    end 
end

function this.ShowShop()
  waiting_ui.Show()
  http_request_interface.getProductCfg(0,
  function(str)
      Trace(str)
      waiting_ui.Hide() 
      local s=string.gsub(str,"\\/","/")  
      local t=ParseJsonStr(s) 
      if t.ret==0 then
          shop_ui.productlist=t.productlist
          shop_ui.Show() 
      else
          fast_tip.Show("获取商城列表失败")
      end       
  end)
end

function this.service()
   ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
   service_ui.Show()
end

function this.help() 
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    help_ui.Show() 
end

function this.OpenRoomClick() 
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click") 
    if openroom_main_ui ~= nil then  
       openroom_main_ui.Show()
    else
       Trace('-------------shisangshui_room_ui_ui = nil-------')
    end 
end

function this.setting()
  ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
  setting_ui.Show() 
end

function this.announcement(obj1,obj2)
  ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click") 
  local sp_red=child(obj2.transform,"sp_redpoint")
  waiting_ui.Show()
  http_request_interface.getEmails(0,function (str) 
        local s=string.gsub(str,"\\/","/")  
        local t=ParseJsonStr(s) 
        if t.ret==0 then
            sp_red.gameObject:SetActive(false)
             announcement_ui.Show()
             announcement_ui.IninData(t.data)
        end
        waiting_ui.Hide()
    end)
end

function this.joinroom()
   ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
   join_room_ui.Show()
end

function this.certification()
   ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
   certification_ui.Show()
end

--------------------------------------更新用户信息-----------------------------------------
function this.InitInfo()
   local useinfo=data_center.GetLoginUserInfo()
   local allinfo=data_center.GetUserInfoTbl()
   local redpoint=child(uitable.btn_mail,"sp_redpoint")  
   if tonumber(allinfo["hasEmail"])==0 then
       redpoint.gameObject:SetActive(false)
   else
       redpoint.gameObject:SetActive(true)
   end 
    
   local aredpoint=child(uitable.btn_activity.transform,"sp_red")
   if tonumber(allinfo.hasact)==1 then
       aredpoint.gameObject:SetActive(true)
   else
       aredpoint.gameObject:SetActive(false)
   end
   local lab_name=child(this.transform,"Panel_TopLeft/btn_photo/sp_nameBackground/lab_name")
   if lab_name~=nil and useinfo.nickname~=nil then
       componentGet(lab_name.gameObject,"UILabel").text=useinfo.nickname
   end
   local lab_id=child(this.transform,"Panel_TopLeft/btn_photo/sp_nameBackground/lab_id")
   if lab_id~=nil and useinfo.uid~=nil then
      componentGet(lab_id.gameObject,"UILabel").text="ID:"..useinfo.uid
   end
   local lab_card=child(this.transform,"Panel_TopLeft/btn_photo/sp_fkBackground/lab_id")
   if lab_card~=nil and useinfo.card~=nil then
      componentGet(lab_card.gameObject,"UILabel").text=useinfo.card
   end
   local tx_photo=child(this.transform,"Panel_TopLeft/btn_photo/sp_photo/tex_photo")
   if lab_name~=nil then 
      hall_data.getuserimage(componentGet(tx_photo, "UITexture"))
   end
   local xlb=allinfo["xlb"]
   if xlb~=nil and xlb.data~=nil and  xlb.data[1]~=nil then
      notice_ui.Show(xlb.data[1].msg,5) 
   end  
end

--------------------------------------滑动战绩事件----------------------------------------- 
function this.OnFreshrecordClick(obj1,obj2) 
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    if componentGet(obj2.gameObject,"UIToggle").value==false then 
       this.RefreshRecord()
       this.RefreshOpenRecord()
   else 
       record_ui.page=0
       open_ui.page=0
   end  
end

function this.RefreshRecord()
    local sp_nocord=child(this.transform,"Panel_Left/sp_left/sp_norecord")
    if componentGet(uitable.toggle_record,"UIToggle").value==true then
       http_request_interface.getRoomSimpleByUid(nil, 2, 0, function (str)
       local s=string.gsub(str,"\\/","/")  
       local t=ParseJsonStr(s)  
       if componentGet(uitable.toggle_record.gameObject,"UIToggle").value==true then 
           record_ui.InitData(t.data) 
           record_ui.page=1
           if table.getCount(t.data)==0 then
             sp_nocord.gameObject:SetActive(true)
          else
             sp_nocord.gameObject:SetActive(false)
          end 
       end
       end) 
    end
end
function this.RefreshOpenRecord()
    local sp_nocord=child(this.transform,"Panel_Left/sp_left/sp_norecord")
    if componentGet(uitable.toggle_openrecord,"UIToggle").value==true then
        http_request_interface.getRoomSimpleList(nil,99,0,function (str)
          local s=string.gsub(str,"\\/","/")  
          local t=ParseJsonStr(s)   
          if componentGet(uitable.toggle_openrecord.gameObject,"UIToggle").value==true then 
             open_ui.InitData(t.data)
             open_ui.page=1
             if table.getCount(t.data)==0 then
                 sp_nocord.gameObject:SetActive(true)
             else
                 sp_nocord.gameObject:SetActive(false)
             end 
         end
      end) 
    end
end
function this.record()
   ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")  
   this.RefreshRecord()
end


function this.openrecord()
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")  
    this.RefreshOpenRecord()
end

function this.Getuitable()
    return uitable 
end
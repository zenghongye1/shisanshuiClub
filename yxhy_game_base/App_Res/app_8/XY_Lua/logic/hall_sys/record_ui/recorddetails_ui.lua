--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion
recorddetails_ui = ui_base.New()
local this = recorddetails_ui
local datatable={}

local datatabletime = nil

function this.Awake(  )
  --用于苹果审核
  if LuaHelper.isAppleVerify ~= nil and LuaHelper.isAppleVerify then
    this.AppleVerifyHandler()
  end
end

function this.AppleVerifyHandler(  )
    local sharef=child(this.transform,"recorddetails_panel/Panel_Middle/btn_sharefriend")
    if sharef~=nil then
        sharef.gameObject:SetActive(false)
    end
    local shareq=child(this.transform,"recorddetails_panel/Panel_Middle/btn_sharefriendQ")
    if shareq~=nil then
       shareq.gameObject:SetActive(false)
    end
end

function this.Show(data) 
	if this.gameObject==nil then
		require ("logic/hall_sys/record_ui/recorddetails_ui")
		this.gameObject = newNormalUI("app_8/ui/openrecord_ui/recorddetails_ui")
	else
		this.gameObject:SetActive(true) 
	end
    this.addlistener()
    if data~=nil then
       datatable=data.data 
       this.InitPlayData()
       this.InitPointData()
       Trace("----------------init")
    else
        datatable=nil
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
end

function this.Start() 
    this:RegistUSRelation()
end

function this.OnDestroy()
    this:UnRegistUSRelation()
end

function this.addlistener()
    this.grid_reward = child(this.transform, "recorddetails_panel/Panel_Middle/sv_all/grid_reward")  
    this.grid_rank = child(this.transform, "recorddetails_panel/Panel_Middle/sv_all/grid_rank")  
    local btn_close=child(this.transform, "recorddetails_panel/btn_close")
    if btn_close~=nil then
        addClickCallbackSelf(btn_close.gameObject,this.Hide,this)
    end 
    local toggle_rank=child(this.transform,"recorddetails_panel/Panel_Middle/toggle_rank")  
    if toggle_rank~=nil then
        addClickCallbackSelf(toggle_rank.gameObject,this.InitPointData,this)
    end
    datatabletime=child(this.transform,"recorddetails_panel/Panel_Middle/sp_data/lab_data")

    local sharef=child(this.transform,"recorddetails_panel/Panel_Middle/btn_sharefriend")
    if sharef~=nil then
       addClickCallbackSelf(sharef.gameObject,this.sharef,this)
    end
    local shareq=child(this.transform,"recorddetails_panel/Panel_Middle/btn_sharefriendQ")
    if shareq~=nil then
       addClickCallbackSelf(shareq.gameObject,this.shareq,this)
    end
end

function this.shareq(obj1,obj2)
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    Trace("share") 
    YX_APIManage.Instance:GetCenterPicture("screenshot.png")
    YX_APIManage.Instance.onfinishtx=function(tx) 
        local shareType = 1--0微信好友，1朋友圈，2微信收藏
        local contentType = 2 --1文本，2图片，3声音，4视频，5网页
        local title = "我在测试" 
        local filePath =YX_APIManage.Instance:onGetStoragePath().."screenshot.png"
        local url = "http://connect.qq.com/"
        local description = "test"
        YX_APIManage.Instance:WeiXinShare(shareType,contentType,title,filePath,url,description)
    end
    

end

function this.sharef(obj1,obj2)
    ui_sound_mgr.PlaySoundClip("app_8/sound/common/audio_button_click")
    Trace("share")
     
    YX_APIManage.Instance:GetCenterPicture("screenshot.png")
    YX_APIManage.Instance.onfinishtx=function(tx) 
        local shareType = 0--0微信好友，1朋友圈，2微信收藏
        local contentType = 2 --1文本，2图片，3声音，4视频，5网页
        local title = "我在测试"  
        local filePath = YX_APIManage.Instance:onGetStoragePath().."screenshot.png"
        local url = "http://connect.qq.com/"
        local description = "test"
        YX_APIManage.Instance:WeiXinShare(shareType,contentType,title,filePath,url,description)
    end
   
end
 
function this.InitPlayData()   
   if datatable==nil then
       return
   end
   if datatable.ctime~=nil then
       componentGet(datatabletime,"UILabel").text=os.date("%Y/%m/%d %H:%M",datatable.ctime)
       datatabletime.gameObject:SetActive(true)
   end
   if datatable.rno~=nil then
      componentGet(child(this.transform,"recorddetails_panel/Panel_Middle/lab_rno").gameObject,"UILabel").text="房间号:"..datatable.rno
   end
   if datatable.clog.scorelog==nil or table.getCount(datatable.clog.scorelog)==0 then
      return
   end
   for i=1,table.getCount(datatable.clog.scorelog) do 
      local item=child(this.transform, "recorddetails_panel/Panel_Middle/sv_all/item_"..i)
      if item==nil then
          local old_item=child(this.transform, "recorddetails_panel/Panel_Middle/sv_all/item_reward")
          item=NGUITools.AddChild(this.grid_reward.gameObject,old_item.gameObject)
          item.transform.localScale={x=1,y=1,z=1}
          item.name="item_"..i
          componentGet(this.grid_reward.gameObject,"UIGrid"):Reposition()   
      end   
      local btn_detail=child(item.transform,"btn_detail")
      if btn_detail~=nil then
         addClickCallbackSelf(btn_detail.gameObject,this.OpenCardDetail,this)
      end
      local lab_number=child(item.transform,"sp_number/lab_number") 
      componentGet(lab_number.gameObject,"UILabel").text=i
      local k=1  
      for j,v in pairs(datatable.clog.chairs) do 
          local tex_photo=child(item.transform, "sv_user/grid_player/tex_photo_"..k)
          if tex_photo==nil then
              local old_tex_photo=child(item.transform, "sv_user/grid_player/tex_photo_"..(k-1))
              tex_photo=NGUITools.AddChild(child(item.transform,"sv_user/grid_player").gameObject,old_tex_photo.gameObject)
              tex_photo.transform.localScale={x=1,y=1,z=1}
              tex_photo.name="tex_photo_"..k 
              componentGet(child(item.transform,"sv_user/grid_player"),"UIGrid"):Reposition()
          end
          
          local imagetype=datatable.clog.imgs[j].type 
          local imageurl=datatable.clog.imgs[j].url
          hall_data.getuserimage(componentGet(tex_photo.gameObject,"UITexture"),imagetype,imageurl)
          local lab_name=child(tex_photo.transform,"lab_name")
          componentGet(lab_name.gameObject,"UILabel").text=v
          local lab_earn=child(tex_photo.transform,"lab_reward")
          if tonumber(datatable.clog.scorelog[i][j])>0 then
              componentGet(lab_earn.gameObject,"UILabel").text="+"..datatable.clog.scorelog[i][j]
          else
              componentGet(lab_earn.gameObject,"UILabel").text=datatable.clog.scorelog[i][j] 
          end
          k=k+1
      end 
   end
end

function this.InitPointData() 
  --  componentGet( this.grid_reward.transform.parent.gameObject,"UIScrollView"):ResetPosition()
   if datatable==nil then
       return
   end
   if datatable.accountc.rewards==nil or table.getCount(datatable.accountc.rewards)==0 then
      return
   end
    local i=1    
  if datatable.aRankId==nil then
     return
  end
    for j=1,#datatable.aRankId do   
      local key=datatable.aRankId 
      local item=child(this.transform, "recorddetails_panel/Panel_Middle/sv_all/grid_rank/item_"..i)
      if item==nil then
          local old_item=child(this.transform, "recorddetails_panel/Panel_Middle/sv_all/item_rank")
          item=NGUITools.AddChild(this.grid_rank.gameObject,old_item.gameObject)
          item.transform.localScale={x=1,y=1,z=1}
          item.name="item_"..i
          componentGet(this.grid_rank.gameObject,"UIGrid"):Reposition()  
      end   
      local lab_number=child(item.transform,"sp_number/lab_number")
      componentGet(lab_number.gameObject,"UILabel").text =i
      
      local lab_name=child(item.transform,"lab_name")
      componentGet(lab_name.gameObject,"UILabel").text=datatable.accountc.rewards[key[j]].nickname
       
      local lab_rounds=child(item.transform,"lab_rounds")
      componentGet(lab_rounds.gameObject,"UILabel").text="对局数:"..datatable.accountc.curr_ju
      if tonumber(datatable.uid)==tonumber(datatable.accountc.rewards[key[j]].uid) then
          child(item.transform,"fangzhu").gameObject:SetActive(true)
      else 
          child(item.transform,"fangzhu").gameObject:SetActive(false)
      end
      local lab_win=child(item.transform,"lab_win")
      componentGet(lab_win.gameObject,"UILabel").text="胜局:"..datatable.accountc.rewards[key[j]].hu_num 
      local sp=child(item.transform,"number_grid/Sprite") 
      lab_gnumber=componentGet(child(item.transform,"lab_gnumber").gameObject,"UILabel")
      lab_bnumber=componentGet(child(item.transform,"lab_bnumber").gameObject,"UILabel")
      if  tonumber(datatable.accountc.rewards[key[j]].all_score) >=0  then
            lab_gnumber.gameObject:SetActive(true)
            lab_bnumber.gameObject:SetActive(false)  
            lab_gnumber.text="+"..datatable.accountc.rewards[key[j]].all_score
        else 
            lab_bnumber.gameObject:SetActive(true)
            lab_gnumber.gameObject:SetActive(false)
            lab_bnumber.text=datatable.accountc.rewards[key[j]].all_score
        end 
      local tex_photo=child(item.transform,"tex_photo") 
      local imagetype=datatable.accountc.rewards[key[j]].img.type 
      local imageurl=datatable.accountc.rewards[key[j]].img.url
      hall_data.getuserimage(componentGet(tex_photo.gameObject,"UITexture"),imagetype,imageurl)
      i=i+1
   end
end

function this.OpenCardDetail(obj1,obj2)
    Trace(obj2.transform.parent.name)
    local rounds=string.split(obj2.transform.parent.name,"_")
    Trace(rounds[2])
    require "logic/hall_sys/record_ui/carddetails_ui"
    carddetails_ui.Show(datatable,tonumber(rounds[2]))
end

 
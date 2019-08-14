--region *.lua
--Date
--此文件由[BabeLua]插件自动生成  



--endregion
local poolBaseClass = require "logic/common/poolBaseClass"
-- local openroom_poplist = require"logic/hall_sys/openroom/openroom_poplist"
local openroom_clubTab = require"logic/hall_sys/openroom/openroom_clubTab"
local openroom_gameItemBtn = require"logic/hall_sys/openroom/openroom_gameItemBtn"
local openroom_content_view = require "logic/hall_sys/openroom/openroom_content_view"
local openroom_window = require "logic/hall_sys/openroom/openroom_window"

local clubModel = model_manager:GetModel("ClubModel")
local openroom_model = model_manager:GetModel("openroom_model")
local GameModel = model_manager:GetModel("GameModel")
local base = require("logic.framework.ui.uibase.ui_window")
local BaseClass = class("help_ui",base)

-- help_ui = ui_base.New()
-- local this = help_ui  

local currentPosy=0  
local grid=nil
local label_panel=nil
local opengidList = model_manager:GetModel("GameModel"):GetOpenGidList()
local toggleInfo = {}
-- local GameKindTbl = {
--   [1] = {18,20,25,26,40,41,42,43,44,45}, --麻将
--   [2] = {11,27,2011}, --纸牌
-- }
function BaseClass:ctor()
  base.ctor(self)
  self.curGameGid = 0
  self.curTypeIndex = 0
  self.opengidList = opengidList
  self.gameBtnObjList = {}
end

  


function BaseClass:OnInit()

  self.rulestype = nil
  base.OnInit(self)
  self:FindChild()
  self:InitPool()
  --用于苹果审核
 --[[ if LuaHelper.isAppleVerify ~= nil and LuaHelper.isAppleVerify then
    self:AppleVerifyHandler()
  end--]]

  --注册按钮事件
  local btn_close = child(self.gameObject.transform,"panel_help/Panel_Top/btn_close")
  if btn_close ~= nil then
      addClickCallbackSelf(btn_close.gameObject,self.CloseWin,self)
  end
end

function BaseClass:OnOpen(gid)
  if game_scene.getCurSceneType() ~= scene_type.HALL and gid ~= nil then   --牌局内只显示当前游戏玩法
    self:ShowSingle(gid)
  else
    self:ResetGameItemBtn()
  end
end

function BaseClass:OnClose()
  self.curTypeIndex = 0
  self.curGameGid = 0
end

function BaseClass:FindChild()
  self.gameList_scrollView = subComponentGet(self.transform,"panel_help/Panel_Left/gameBtn_list","UIScrollView")
  self.gameListGrid_tr = child(self.transform,"panel_help/Panel_Left/gameBtn_list/grid")
  self.gameItemBtn_tr = child(self.transform,"panel_help/Panel_Left/gameItemBtn")--一级按钮
  self.gameItemSecBtn_tr = child(self.transform,"panel_help/Panel_Left/gameItemSecBtn")--二级按钮
  self.poolRoot_tr = child(self.transform,"panel_help/Panel_Left/gameItemSecPool")
  self.label_panel = child(self.transform,"panel_help/Panel_Right")
  self.gameItemSecBtnList = {}

  self.singleItem = openroom_gameItemBtn:create(self.gameItemSecBtn_tr.gameObject)
 
end

function BaseClass:InitPool()
  local createFunc = function () 
    local prefab = newobject(self.gameItemSecBtn_tr.gameObject)
    return prefab 
  end

  local recycleFunc = function (obj)
    obj.transform:SetParent(self.poolRoot_tr,false)
  end

  self.gameItemSecBtnPool = poolBaseClass:create(createFunc,nil,recycleFunc)

end

function BaseClass:ShowSingle(gid)
  self.singleItem:SetActive(true)
  self.gameListGrid_tr.gameObject:SetActive(false)

  self.singleItem:SetText(GameUtil.GetGameName(gid))
  self.curGameGid = gid
  self:CreateContentGo(gid)
  self:Read(self.curGameGid)
end


function BaseClass:ResetGameItemBtn()
  self.singleItem:SetActive(false)
  self.gameListGrid_tr.gameObject:SetActive(true)

  local gametype = GameModel:GetTypeList()
  local showList = {}
  for i,cfg in pairs(gametype) do
    local gLst = self:SelectClubGid(cfg.gids)
    if table.getn(gLst) > 0 then
      table.insert(showList,{gids = gLst,name = cfg.name,order = cfg.order,id = i})
    end
  end
  for i=#showList,1,-1 do
    for j=1,i-1 do
      if showList[j].order > showList[j+1].order then
        local temp = showList[j+1]
        showList[j+1] = showList[j]
        showList[j] = temp
      end
    end
  end
  self.showList = showList
  for i=table.getn(self.showList) + 1,#self.gameBtnObjList do
    local item = self.gameBtnObjList[i]
    if not IsNil(item.gameObject) then
      item:SetActive(false)
    end
  end
  for i,cfg in ipairs(self.showList) do
    local item
    if i<=#self.gameBtnObjList then
      item = self.gameBtnObjList[i]
    else
      local obj = newobject(self.gameItemBtn_tr.gameObject)
      obj.transform:SetParent(self.gameListGrid_tr,false)
      item = openroom_gameItemBtn:create(obj)
      table.insert(self.gameBtnObjList,item)
    end
    item.gids = cfg.gids
    item:SetCallback(function (obj) self:OnGameItemBtnClick(obj) end )
    item:SetName(i)
    item:SetText(cfg.name)
    item:SetActive(true)
    item.self_toggle.value = false
  end
  componentGet(self.gameListGrid_tr,"UITable"):Reposition()
  self.gameList_scrollView:ResetPosition()

  local firstItem = self.gameBtnObjList[1]
  if firstItem and firstItem.isActive then 
    firstItem:OnBtnClick()
  else
    self:RecycleGameItemSecBtn()
  end
end

function BaseClass:SelectClubGid(gidList)
  local gidList = gidList or {}
  if self.opengidList then
    local selectList = {}
    for _,gid in ipairs(gidList) do
      for _,clubGid in ipairs(self.opengidList) do
        if clubGid == gid then
          table.insert(selectList,gid)
        end
      end
    end
    return selectList
  end
  return gidList
end

function BaseClass:OnGameItemBtnClick(obj)

  local index = tonumber(obj.name)
  local isOpen = true
  if self.curTypeIndex == index then
    isOpen = false
  end
  if obj then
    local t = componentGet(obj.transform,"UIToggle")
    if t then
      t.value = isOpen
    end
  end
  if isOpen then
    self.curTypeIndex = index
  else

    self.curTypeIndex = 0 
  end
  self:OnOpenGameItemBtn(obj,self.showList[index].gids,isOpen)
  componentGet(self.gameListGrid_tr,"UITable"):Reposition()
  self.gameList_scrollView:ResetPosition()
end

function BaseClass:OnOpenGameItemBtn(obj,gids,isOpen)
  self:RecycleGameItemSecBtn()

  if isOpen then
    local typeIndex = obj.transform:GetSiblingIndex()
    for i=#gids,1,-1 do
      local item = self:GetGameItemSecBtn(typeIndex + 1)
      item:SetCallback(function (obj) self:OnGameItemSecBtnClick(obj) end )
      item:SetName(gids[i])
      item:SetText(GameModel:GetGameName(gids[i]))
    end
  end
  
  local firstItem = self.gameItemSecBtnList[1]
  if firstItem then 
    firstItem:OnBtnClick()
  end
end


function BaseClass:OnGameItemSecBtnClick(obj)
  local Panel_Right = label_panel or child(self.transform,"panel_help/Panel_Right")
  local gid = tonumber(obj.name)
  if self.curGameGid == gid then
    return
  end
  if Panel_Right then
      for i = (Panel_Right.transform.childCount -1),0,-1 do
          GameObject.DestroyImmediate(Panel_Right.transform:GetChild(i).gameObject)
      end
  end
  
  if obj then
    local t = componentGet(obj.transform,"UIToggle")
    if t then      
      t.value = true
    end
  end
  for i,v in ipairs(self.gameItemSecBtnList) do
    if gid == v.gid then
      v:SetValue(true)
    else
      v:SetValue(false)
    end
  end
  self:CreateContentGo(gid)
        
  self.curGameGid = gid
  self:Read(self.curGameGid)
end

function BaseClass:CreateContentGo(gid)
    local back_item=child(self.transform,"panel_help/Panel_Left/back")
    local back=GameObject.Instantiate(back_item.gameObject)
    back.name=gid
    back:SetActive(true)
    back.transform.parent=self.label_panel.transform
    back.transform.localPosition={x=0,y=0,z=0}
    back.transform.localScale={x=1,y=1,z=1}
end


function BaseClass:RecycleGameItemSecBtn()
  for i,v in ipairs(self.gameItemSecBtnList) do
    self.gameItemSecBtnPool:Recycle(v.gameObject)
  end
  self.gameItemSecBtnList = {}

end

function BaseClass:SetGameBtnPos(index,count)
  if count > 6 then
    if index> count/2 then
      self.gameList_scrollView:SetDragAmount(0, index/count, false)
    else
      self.gameList_scrollView:SetDragAmount(0, (index-1)/count, false)
    end
  end
end



function BaseClass:GetGameItemSecBtn(index)
  local obj = self.gameItemSecBtnPool:Get()
  local tr = obj.transform
  tr:SetParent(self.gameListGrid_tr,false)
  tr:SetSiblingIndex(index)
  item = openroom_gameItemBtn:create(obj)
  item:SetActive(true)
  table.insert(self.gameItemSecBtnList,1,item)
  return item
end


function BaseClass:PlayOpenAmination()
end

function BaseClass:OnRefreshDepth()

  local Effect_shaangcheng = child(self.gameObject.transform, "panel_help/Panel_Top/topBg/Title/Effect_youxifenxiang")
  if Effect_shaangcheng and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(Effect_shaangcheng.gameObject, topLayerIndex)
  end
end

function BaseClass:CloseWin()
  ui_sound_mgr.PlayCloseClick()
  UI_Manager:Instance():CloseUiForms("help_ui")
end


function BaseClass:GetTxtPath(gid)
  local name = GameUtil.GetRuleName(gid)
  return data_center.GetAppConfDataTble().appPath.."/config/txt/rules/" .. name
end

function BaseClass:Show(rulestype, _isTimer)

  --临时处理再次打开界面错乱问题
  if not self.updateTimer then
      self.updateTimer = FrameTimer.New(function()
          self:Show(rulestype, true)
          self.updateTimer = nil
        end,1,1)
      self.updateTimer:Start()
  end
  if not _isTimer then
    return
  end
  self:Read(rulestype)
end


function BaseClass:AppleVerifyHandler()
    --[[self.toggle_sss=child(self.transform,"panel_help/Panel_Left/sv_playrole/toggle_grid/"..tostring(ENUM_GAME_TYPE.TYPE_SHISHANSHUI))
   if self.toggle_sss~=nil then
       self.toggle_sss.gameObject:SetActive(false)
   end--]]
end

function BaseClass:addlistener()
   local btn_close=child(self.transform,"panel_help/Panel_Top/btn_close")
   if btn_close~=nil then
      addClickCallbackSelf(btn_close.gameObject,self.Hide,self)
   end 
end

function BaseClass:Read(obj2)
    local gid  
    if type(obj2)=="number" then
        gid=obj2 
    else 
       gid =tonumber(obj2.name) 
    end
    self:ToggleClick(gid)
    local label=child(self.transform,"panel_help/Panel_Right/"..tostring(gid))
    if label~=nil then
        self:readTxt(self:GetTxtPath(gid),tostring(gid))  
    end
end

function BaseClass:Hide()
  if not IsNil(self.gameObject) then 
    self.gameObject:SetActive(false)
    destroy(self.gameObject)
    self.gameObject = nil
	end    
    self:Clear()
end  


function BaseClass:ToggleClick(gid)
    for i=0,self.label_panel.transform.childCount-1 do
        local l=self.label_panel.transform:GetChild(i)
        if tonumber(l.name)==tonumber(gid) then
        local label=child(self.transform,"panel_help/Panel_Right/"..tostring(gid))
          if label~=nil then
              self:readTxt(self:GetTxtPath(gid),tostring(gid))  
          end
        else 
            l.gameObject:SetActive(false)
        end

    end
end 

function BaseClass:Clear()
    currentPosy=0  
end

function BaseClass:readTxt(rulestype,backname)  
    componentGet(self.label_panel.gameObject,"UIScrollView"):ResetPosition()
    if child(self.label_panel.transform, backname).childCount>2 then 
        return
    end 
    currentPosy=0   
    if rulestype==nil then
        return
    end  
    local path=rulestype or "rules/shisanshui"   
    local txt=newNormalObjSync(path, typeof(UnityEngine.TextAsset)) 
    if txt==nil then
        logError(path..".txt 不存在")
        return
    end
    local i=1 --子目录数量
    local m=1 --主目录数量   
    local t=string.split(tostring(txt),"##") 
    for k=1,table.getCount(t),1  do 
      local str=t[k]--DelS(t[k]) 
      local tt= string.split(str,"-")     
      if table.getCount(tt)>1 then    
         if string.find(tt[1], "main", 1)~=nil  then
            m=self:addmainlab(m,tt[2],backname)  
         end
         if string.find(tt[1], "child", 1)~=nil then
             if table.getCount(tt)>2 then  
              for i=3, table.getCount(tt) do
                  tt[2]=tt[2].."-"..tt[i]
              end 
             end
            i=self:addchildlab(i,tt[2],backname)  
         end
      elseif t[k]~=nil then   
         self:upchildlab(i, str, backname)
      end 
    end
end

local function DelS(s)
    assert(type(s)=="string")
    return s:match("^%s*(.-)%s*$")
end
 
function BaseClass:addmainlab(m,str,backname)    
   local lab_message01=child(self.label_panel.transform, backname.."/lab_main"..tostring(m)) 
   if lab_message01~=nil then
       componentGet(lab_message01.transform,"UILabel").text=str
   else
       local lab_message=child(self.label_panel.transform, backname.."/lab_main"..tostring(m-1))
       lab_message01=GameObject.Instantiate(lab_message.gameObject)
       lab_message01.transform.parent=lab_message.transform.parent  
       lab_message01.name="lab_main"..tostring(m)
       lab_message01.transform.localScale={x=1,y=1,z=1}  
       lab_message01.transform.localPosition={x=0,y=currentPosy,z=0} 
       componentGet(lab_message01,"UILabel").text=str
   end   
   currentPosy=lab_message01.transform.localPosition.y-componentGet(lab_message01.gameObject,"UILabel").height
   m=m+1   
   return m
end

function BaseClass:addchildlab(i, str, backname)  
    local lab_message01=child(self.label_panel.transform, backname.."/lab_child"..tostring(i))
    if lab_message01~=nil then
       componentGet(lab_message01.transform,"UILabel").text=str
    else 
       local lab_message=child(self.label_panel.transform, backname.."/lab_child"..tostring(i-1))
       lab_message01=GameObject.Instantiate(lab_message.gameObject)
       lab_message01.transform.parent=lab_message.transform.parent 
       lab_message01.name="lab_child"..tostring(i)
       lab_message01.transform.localScale={x=1,y=1,z=1}  
       lab_message01.transform.localPosition={x=0,y=currentPosy,z=0}
       componentGet(lab_message01,"UILabel").text=str  
    end    
    currentPosy=lab_message01.transform.localPosition.y-componentGet(lab_message01.gameObject,"UILabel").height 
    i=i+1
   return i
end

function BaseClass:upchildlab(i, str, backname)
   local lab_message01=child(self.label_panel.transform, backname.."/lab_child"..tostring(i-1))
   if lab_message01 then
     componentGet(lab_message01.transform,"UILabel").text=componentGet(lab_message01.transform,"UILabel").text.."\n"..str
     currentPosy=lab_message01.transform.localPosition.y-componentGet(lab_message01.gameObject,"UILabel").height
   end
   return i
end

return BaseClass

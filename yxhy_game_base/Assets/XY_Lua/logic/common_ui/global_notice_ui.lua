local base = require("logic.framework.ui.uibase.ui_window")
local global_notice_ui = class("global_notice_ui", base)
local UI_Manager = UI_Manager:Instance()
local LuaHelper = LuaHelper

function global_notice_ui:ctor()
  base.ctor(self)
  self.startlabel=518/2
  self.endlabel=-518/2
  self.endpoint=-518/2
  self.nduration=5
  self.spead=2
  self.OnFinishScroll=nil
  self.label=nil

  self.messagetable = {}
end

function global_notice_ui:OnInit()
  base.OnInit(self)
  self.m_UiLayer = UILayerEnum.UILayerEnum_Top
  self:FindChild() 
end

function global_notice_ui:OnOpen(str,nduration)
  base.OnOpen(self,str)
  if #self.messagetable == 0 then
    self:corRunmessage(str,nduration) 
  else
    table.insert(self.messagetable,str)
  end
end

function global_notice_ui:close()
  ui_sound_mgr.PlayCloseClick()
  UI_Manager:CloseUiForms("global_notice_ui")
  self:Clear()
end

function global_notice_ui:PlayOpenAmination()
end
 
function global_notice_ui:FindChild() 
   self.label=child(self.transform,"notice_pos/sv_zoumadeng/Label")
   local panel=componentGet(child(self.transform,"notice_pos/sv_zoumadeng"),"UIPanel")
   self.startlabel=panel.baseClipRegion.z/2
   self.endlabel=-panel.baseClipRegion.z/2 
end


function global_notice_ui:Clear()
    self.OnFinishScroll=nil 
    self.nduration=5
    coroutine.stop(self.cor)
    self.cor=nil 
    self.messagetable={}
    curTime = 0
end

function global_notice_ui:corRunmessage(str,duration,onfinish)
   if self.label~=nil then  
       componentGet(self.label.gameObject,"UILabel").text=str 
       self.endlabel=-componentGet(self.label.gameObject,"UILabel").width+self.endpoint 
       self.label.transform.localPosition={x=self.startlabel,y=0,z=0}
       self.OnFinishScroll=onfinish
       if self.cor==nil then
         self.cor=coroutine.create(function (duration)
           self:movelabel(duration) 
         end)
       end
       coroutine.resume(self.cor,duration) 
   end
end

local curTime = 0
local totalTime = 0.01
local movement

function global_notice_ui:movelabel(duration) 
    while true do   
        -- curTime = curTime + Time.deltaTime
        -- if curTime > totalTime then
        local sp = 66 * Time.deltaTime
        if sp > self.spead then
          sp = self.spead
        end
          -- movement = self.spead * curTime/totalTime
          -- if curTime > 0.034 then
          --   movement = self.spead * 0.034/totalTime
          -- end
          -- curTime = 0
          self.label.transform.localPosition={x=self.label.transform.localPosition.x-sp,y=0,z=0} 
          -- coroutine.wait(0.01)
          if tonumber(self.label.transform.localPosition.x)<self.endlabel then    
              if table.getCount(self.messagetable)>0 then 
                  local s=self.messagetable[1] 
                  table.remove(self.messagetable,1) 
                  self:corRunmessage(s) 
                  if self.OnFinishScroll~=nil then
                     self.OnFinishScroll()
                  end 
              else 
                  self:close() 
                  coroutine.yield() 
              end 
          end
        -- end
        coroutine.step()
    end
end

return global_notice_ui

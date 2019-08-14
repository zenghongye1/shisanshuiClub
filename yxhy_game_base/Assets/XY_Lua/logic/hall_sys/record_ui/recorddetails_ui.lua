--region *.lua
--Date
--此文件由[BabeLua]插件自动生成



--endregion

local base = require("logic.framework.ui.uibase.ui_window")
local recorddetails_ui = class("recorddetails_ui",base)


local datatable={}

local datatabletime = nil
local loginType = 0

-- function recorddetails_ui:ctor()
--   base.ctor(self)
-- end

function recorddetails_ui:OnInit()
  --用于苹果审核
  --[[if LuaHelper.isAppleVerify ~= nil and LuaHelper.isAppleVerify then
    self:AppleVerifyHandler()
  end--]]

  local btn_close = child(self.gameObject.transform,"recorddetails_panel/Panel_Top/btn_close")
  if btn_close ~= nil then
      addClickCallbackSelf(btn_close.gameObject,recorddetails_ui.CloseWin,self)
  end
  self:InitTab()
end

function recorddetails_ui:OnOpen(data)
  if data ~= nil then
    datatable = data --保留详情数据
    if self.tab then
      if data.isRule then
        self.tab:SwitchToByName("recorddetailTap3")
      else
        self.tab:SwitchToByName("recorddetailTap1")
      end

      if self.tab.currentTab.luaFileObj.UpdateView then
        self.tab.currentTab.luaFileObj:UpdateView(datatable)
      end
    end
  end
end

function recorddetails_ui:PlayOpenAmination()

end
function recorddetails_ui:OnRefreshDepth()
  local uiEffect = child(self.gameObject.transform, "recorddetails_panel/Panel_Top/Title/Effect_youxifenxiang")
  if uiEffect and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
  end
end

function recorddetails_ui:CloseWin()
  ui_sound_mgr.PlayCloseClick()
  UI_Manager:Instance():CloseUiForms("recorddetails_ui")
end

function recorddetails_ui:InitTab()
  local tabRoot = child(self.gameObject.transform,"recorddetails_panel/Panel_Middle/TabRoot")
  self.tab = require("logic.framework.ui.ui_tab"):create("TabTitle","TabWindows","recorddetailTap1","button_06","", "UILabel_Select", "UILabel")
  self.tab.gameObject = tabRoot.gameObject
  self.tab:Open(self.tab.gameObject)
  self.tab.onSwitchCallBack = function(winName)
    -- Trace("页面切换完成："..winName)
    local tabWindow = self.tab:GetTabWindowFormCacheByName(winName)
    if tabWindow and tabWindow.luaFileObj.UpdateView then
      tabWindow.luaFileObj:UpdateView(datatable)
    end
  end
end


function recorddetails_ui:AppleVerifyHandler(  )
    
end

function recorddetails_ui:addlistener()

    local sharef=child(self.transform,"recorddetails_panel/Panel_Middle/btn_sharefriend")
    if sharef~=nil then
       addClickCallbackSelf(sharef.gameObject,recorddetails_ui.sharef,self)
    end
    local shareq=child(self.transform,"recorddetails_panel/Panel_Middle/btn_sharefriendQ")
    if shareq~=nil then
       addClickCallbackSelf(shareq.gameObject,recorddetails_ui.shareq,self)
    end
end

function recorddetails_ui:shareq(obj1,obj2)
    
end

function recorddetails_ui:sharef(obj1,obj2)
   
end

return recorddetails_ui

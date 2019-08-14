require "logic/recharge/recharge_sys"

local base = require("logic.framework.ui.uibase.ui_window")
local shop_ui = class("shop_ui",base)
local shop_ui_item = require "logic/hall_sys/shop/shop_ui_item"

function shop_ui:ctor()
  base.ctor(self)
  self.destroyType = UIDestroyType.Immediately
  self.initItemCount = 9
  self.itemList = {}

end

function shop_ui:OnInit()
  base.OnInit(self)
  self:InitProductItems()

  --代理公告
  local model = model_manager:GetModel("LoginModel")
  if string.len(model.mall_broadcast or "") >0 then
    self:setNotifyText(model.mall_broadcast)
  end
end

function shop_ui:OnOpen(...)
  base.OnOpen(self,...)

  FrameTimer.New(
    function() 
      local shop_model = model_manager:GetModel("shop_model")
      if shop_model:GetProductList() then
        self:RefreshItem()
      else
        shop_model:ReqProductList(function()
          self:RefreshItem()
        end)
      end
    end,1,1
  ):Start()
end

function shop_ui:InitProductItems()
  self.btn_close=child(self.transform,"backBtn")
  if self.btn_close~=nil then
      addClickCallbackSelf(self.btn_close.gameObject,self.close,self)
  end 
  self.grid = subComponentGet(self.transform,"Scroll View/Grid",typeof(UIGrid))
  self.productItem_tr = child(self.transform,"item")

    local time = FrameTimer.New(
    function() 
        for i=1,self.initItemCount do
          local item = self:CreateItem(i)
          table.insert(self.itemList,item)
        end
    end,1,1):Start()
end

function shop_ui:CreateItem(i)
    local go = newobject(self.productItem_tr.gameObject)
    local item = shop_ui_item:create(go)
    item.transform:SetParent(self.grid.transform,false)
    go.name = "item"..i
    return item
end

function shop_ui:close()
  ui_sound_mgr.PlayCloseClick()
  UI_Manager:Instance():CloseUiForms("shop_ui")
end

function shop_ui:PlayOpenAmination()
end

function shop_ui:OnRefreshDepth()

  local Effect_shaangcheng = child(self.gameObject.transform, "bg/topBg/Title/Effect_youxifenxiang")
  if Effect_shaangcheng and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(Effect_shaangcheng.gameObject, topLayerIndex)
  end

  for i,v in ipairs(self.itemList) do
    local effectName = "Effect_zhuanshi"
  --   if i%3 ==1 then
  --     effectName = "Effect_fangkax3"
  --   elseif i%3 ==2 then
  --     effectName = "Effect_fangkax6"
  --   else
  --     effectName = "Effect_fangkax18"
  --   end

    local uiEffect = child(v.transform, effectName)
    if uiEffect and self.sortingOrder then
      uiEffect.gameObject:SetActive(true)
      local topLayerIndex = self.sortingOrder +self.m_subPanelCount +10
      Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
    end
  end
end

function  shop_ui:RefreshItem()
    local productTbl = model_manager:GetModel("shop_model"):GetProductTbl()

    for i,v in ipairs(productTbl) do
        local item
        if i <= #self.itemList then
            item = self.itemList[i]
        else
            item = self:CreateItem(i)
            table.insert(self.itemList,item)
        end
        item:SetActive(true)
        local btn = item.btn_tr
        local proIndex = i
        item.gameObject.proIndex = proIndex --记录商品编号
        local proId = productTbl[proIndex or 0]
        if proId then
            item:SetRMB(tostring(proId[3] or 0))
            item:SetNumber(proId[2] or 0)
            -- item:SetPic(math.floor((proIndex+2)/3),(proIndex%3 == 0 and 3) or proIndex%3)
            item:SetPicNew(proIndex)
        end

        addClickCallbackSelf(item.gameObject,self.OnBuyBtnClick,self)
    end
    self.grid:Reposition()
end 

function shop_ui:OnBuyBtnClick(obj1)
    local productTbl = model_manager:GetModel("shop_model"):GetProductTbl()

    ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_button_click")

    local proId = productTbl[tonumber(obj1.proIndex) or 0]
    if proId then
        if data_center.GetCurPlatform()  == "Android" or data_center.GetCurPlatform()  == "WindowsEditor"  then
          recharge_sys.requestIAppPayOrder(rechargeConfig.Douyou8, proId[4], "1", proId[3])
        elseif data_center.GetCurPlatform() == "IPhonePlayer" or data_center.GetCurPlatform() =="OSXEditor" then
          recharge_sys.requestIAppPayOrder(rechargeConfig.AppleStore, proId[4], "1", proId[1])        
        end
    else
        logError("dybuy proId nil: "..obj2.proIndex)
    end
end

function shop_ui:setNotifyText(_txt)
    local notifyTxt = subComponentGet(self.transform, "bg/notifyBg/Label", "UILabel")
    if notifyTxt then
        notifyTxt.text = _txt 
    end
end
    
return shop_ui
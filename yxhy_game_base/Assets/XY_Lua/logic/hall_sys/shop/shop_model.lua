
local shop_model = class("shop_model")

function shop_model:ctor()
	self.productlist = nil
	self.productTbl = nil
	self.iosProductString = nil
end

function shop_model:ReqProductList(callback)
	-- waiting_ui.Show()
  UI_Manager:Instance():ShowUiForms("waiting_ui")
    http_request_interface.getProductCfg(0,
    function(str)
        -- waiting_ui.Hide() 
        UI_Manager:Instance():CloseUiForms("waiting_ui")
        local s=string.gsub(str,"\\/","/")  
        local t=ParseJsonStr(s) 
        if t.ret==0 then
            self:UpdateProductList(t.productlist)
            if callback then
            	callback()
            end
        else
            UI_Manager:Instance():FastTip("获取商城列表失败")
        end
    end)
end

function shop_model:UpdateProductList(productlist)
	self.productlist = productlist
	self:SetProductTbl()
	if data_center.GetCurPlatform() == "IPhonePlayer" or data_center.GetCurPlatform() =="OSXEditor" then
		self:SetIOSProductString()
	end
end

function shop_model:GetProductList()
	return self.productlist
end

function shop_model:SetProductTbl()
	local tempProductTbl = {}
	for k,v in pairs(self.productlist) do
	    local proID = v["spid"]
	    if proID and string.len(proID) >0 then
	        table.insert(tempProductTbl, {proID, v["total"], v["price"], v["pid"]})
	    elseif data_center.GetCurPlatform()  == "Android" or data_center.GetCurPlatform()  == "WindowsEditor" then
	        table.insert(tempProductTbl, {"proID", v["total"], v["price"], v["pid"]})
	    end
	end
	if #tempProductTbl >0 then
	    table.sort(tempProductTbl, function(a1, a2)
	        return tonumber(a1[3]) <tonumber(a2[3])
	    end)
	    self.productTbl = tempProductTbl
	end
end

function shop_model:GetProductTbl()
	return self.productTbl
end

function shop_model:SetIOSProductString()
      --传给apple校验
      self.iosProductString = nil
      for i,v in ipairs(self.productTbl) do
          if self.iosProductString then
              self.iosProductString = self.iosProductString..","..v[1]
          else
              self.iosProductString = v[1]
          end
      end

      YX_APIManage.Instance:initApplePay(self.iosProductString, function(msg)
          -- waiting_ui.Hide()
          UI_Manager:Instance():CloseUiForms("waiting_ui")
          if string.len(msg) <1 then
              Trace("initApplePay failed!")
              return
          end
          Trace("initApplePay:"..msg)
      end)
end

return shop_model
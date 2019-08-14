--region *.lua
--Date
--此文件由[BabeLua]插件自动生成


--endregion 
ui_wrap=ui_base.New()
ui_wrap.__index=ui_wrap

 




--[[

自定义，itemheight
后面用
]]

function  ui_wrap.New()
	local result = {
    OnUpdateItemInfo=nil,
    OnUpdateToEnd=nil,
    itemheight=0,
    page=1 , 
    wraprecord=nil,
	}
	setmetatable(result,ui_wrap)
	return result
end

--[[
初始化赋值UI 
itemheight  选项高度

]]

function ui_wrap:InitUI(itemheight)
    self.itemheight=itemheight
    self.wrap=subComponentGet(self.transform,"scrollview/ui_wrapcontent","UIWrapContent")  
    self.wrap.itemSize=itemheight
    self.scrollview=subComponentGet(self.transform,"scrollview","UIPanel") 
    self.wrap.transform.localPosition={x=0,y=self.scrollview.baseClipRegion.w/2-itemheight/2,z=0}
    if self.wrap~=nil then 
        self.wrap.onInitializeItem=function (go,index,rindex)self:OnUpdateItem(go,index,rindex)   end
    else 
        logError("no wrap")
    end
end

--[[
初始化数据
刷新列表
]]

function ui_wrap:Initdate(data)  
	self.wraprecord =data        
    Trace(data) 
    if data~=nil then  
	    self.maxCount = table.getCount(data)    
	    self:InitWrap(self.maxCount)  
    end  
end

function ui_wrap:InitWrap(count)     
    self.wrap.minIndex = -count+1
	self.wrap.maxIndex = 0     
    self.wrap.enabled =false    
    for i=0 ,self.wrap.transform.childCount-1 do  
        self.wrap.transform:GetChild(i).gameObject:SetActive(false)  
        self.wrap.transform:GetChild(i).name=i+1 
    end  
	if count >=0 and count <=self.wrap.transform.childCount then 
		for i=0, count-1 do
		   local go= self:InitItem(i)  
           self:OnUpdateItem(go,nil,-i) 
		end 
	elseif count>self.wrap.transform.childCount then
		for a=0,self.wrap.transform.childCount-1 do 
			local go= self:InitItem(a) 
            self:OnUpdateItem(go,nil,-a)  
            self.wrap.enabled =true 
		end 
	end  
     
    self:ResetPosition()
end

function ui_wrap:ResetPosition() 
    componentGet(self.scrollview,"UIScrollView"):ResetPosition()
    self.scrollview.clipOffset={x=0,y=0}
    self.scrollview.transform.localPosition={x=0,y=0,z=0}
end

function ui_wrap:InitItem(i) 
    local item  
    item=child(self.wrap.transform,tostring(i+1)) 
    item.gameObject:SetActive(true)
    item.transform.localPosition = Vector3.New(0,-i*(self.itemheight),0)     
    return item
end

--[[
    rindexc从-1开始往下递减
]]
function ui_wrap:OnUpdateItem(go,index,rindex)  
   local realindex=1-rindex 
   self.OnUpdateItemInfo(go,realindex)

   if self:CheckUpdateIsEnd(realindex) and self.OnUpdateToEnd~=nil then
       self.OnUpdateToEnd()
   end
end

function ui_wrap:CheckUpdateIsEnd(index)
    if index==self.maxCount and self.maxCount>self.wrap.transform.childCount then
        return true
    end
    return false
end 

function ui_wrap:ScrollToTarget(index)
    local delte=index*self.itemheight
    self.scrollview.clipOffset={x=0,y=-delte}
    self.scrollview.transform.localPosition={x=0,y=delte,z=0} 
    self.scrollview:RebuildAllDrawCalls()
end

function ui_wrap:RefreshView()
    for i=0,self.wrap.transform.childCount do
        local child=self.wrap.transform:GetChild(i)
        self.OnUpdateItemInfo(child,child.name)
    end
end

function ui_wrap:DeleteItem(index)
    table.remove(self.wraprecord,index)
    self:RefreshView()
end
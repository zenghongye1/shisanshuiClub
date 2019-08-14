local base = require "logic/framework/ui/uibase/ui_view_base"
local ui_wrap = class("ui_wrap",base)

function ui_wrap:InitView()
    self.OnUpdateItemInfo=nil
    self.OnUpdateToEnd=nil
    self.itemheight=0
    self.page=1 
    self.wraprecord=nil
end

--[[
使用时确保Scrollview的offset 坐标为（0，0）
center 为（0，0）

预设位置---/UI/COMMON/UI_WRAP
]] 



--[[
初始化赋值UI 
itemheight  选项高度

]]

function ui_wrap:InitUI(itemheight)
    self.itemheight=itemheight
    self.wrap=subComponentGet(self.transform,"scrollview/ui_wrapcontent","UIWrapContent")  
    self.wrap.itemSize=itemheight
    self.scrollview=subComponentGet(self.transform,"scrollview","UIPanel") 
    self.scroll = subComponentGet(self.transform, "scrollview", "UIScrollView")
    --self.wrap.transform.localPosition={x=0,y=self.scrollview.baseClipRegion.w/2-itemheight/2,z=0}
    if self.wrap~=nil then 
        self.wrap.onInitializeItem=function (go,index,rindex) self:OnUpdateItem(go,index,rindex)   end
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
    if data~=nil then  
	    self.maxCount = table.getCount(data)    
	    self:InitWrap(self.maxCount)  
    end  
end

function ui_wrap:InitWrap(count)     
    self.wrap.minIndex = -count+1
    self.maxCount = count
	self.wrap.maxIndex = 0     
    self.wrap.enabled =false    
    for i=0 ,self.wrap.transform.childCount-1 do  
        self.wrap.transform:GetChild(i).gameObject:SetActive(false)  
        self.wrap.transform:GetChild(i).name=i+1 
    end  
	if count >=0 and count <=self.wrap.transform.childCount then 
		for i=0, count-1 do
		   local go= self:InitItem(i)  
           self:OnUpdateItem(go,i,-i) 
		end 
	elseif count>self.wrap.transform.childCount then
		for a=0,self.wrap.transform.childCount-1 do 
			local go= self:InitItem(a) 
            self:OnUpdateItem(go,a,-a)  
            self.wrap.enabled =true 
		end 
	end  
     
    self:ResetPosition()
    for i=count,self.wrap.transform.childCount-1 do
        self.wrap.transform:GetChild(i).gameObject:SetActive(false)  
    end
end

function ui_wrap:ResetPosition() 
    
    self.scrollview.clipOffset={x=0,y=0}
    self.scrollview.transform.localPosition={x=0,y=0,z=0}
    componentGet(self.scrollview,"UIScrollView"):ResetPosition()
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
    if self.maxCount == nil then
        return
    end
    local realindex=1-rindex 
    if realindex <= self.maxCount and realindex > 0 then
        index = index + 1
        self.OnUpdateItemInfo(go,realindex,index)
    end

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
    local count = self.wrap.transform.childCount
    -- 不满一页不设置
    if count > self.maxCount then
        return
    end

    if index > (self.maxCount - count + 1) then
        index = self.maxCount - count + 1
    end

    local delte=index*self.itemheight
    self.scroll:MoveRelative(Vector3(0, delte, 0))
    -- self.scroll:RestrictWithinBounds(true)
    -- self.scrollview.clipOffset={x=0,y=-delte}
    -- self.scrollview.transform.localPosition={x=0,y=delte,z=0} 
    -- -- self.scrollview:RebuildAllDrawCalls()
    -- self.scroll:UpdatePosition()
end

function ui_wrap:RefreshView()
    if self.maxCount >=0 and self.maxCount <=self.wrap.transform.childCount then 
        for i=0, self.maxCount-1 do
           local go= self:InitItem(i)  
           self:OnUpdateItem(go,i,-i) 
        end 
        return
    end
    for i=0,self.wrap.transform.childCount - 1 do
        local child=self.wrap.transform:GetChild(i)
        self.OnUpdateItemInfo(child,i + 1, tonumber(child.name))
    end
end

function ui_wrap:DeleteItem(index)
    table.remove(self.wraprecord,index)
    self:RefreshView()
end

return ui_wrap
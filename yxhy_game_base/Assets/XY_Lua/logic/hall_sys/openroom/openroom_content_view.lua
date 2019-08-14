--[[--
 * @Description: 开房玩法内容面板组件
 * @Author:      ShushingWong
 * @FileName:    openroom_content_view.lua
 * @DateTime:    2017-12-12 14:56:18
 ]]
local poolBaseClass = require "logic/common/poolBaseClass"
local openroom_item_view = require "logic/hall_sys/openroom/openroom_item_view"

local base = require "logic/framework/ui/uibase/ui_view_base"
local openroom_content_view = class("openroom_content_view",base)

local itemPrefabPath = data_center.GetAppConfDataTble().appPath.."/ui/openroom_ui/contentItem"
local single_toggle_path = data_center.GetAppConfDataTble().appPath.."/ui/openroom_ui/single_toggle"
local multi_toggle_path = data_center.GetAppConfDataTble().appPath.."/ui/openroom_ui/multi_toggle"
local poplist_button_path = data_center.GetAppConfDataTble().appPath.."/ui/openroom_ui/poplist_button"

local openroom_model = model_manager:GetModel("openroom_model")

local switchToggleTbl = {}

function openroom_content_view:InitView()
	self.paneltable = {} -- 总数据

	self.content_scrollView = subComponentGet(self.transform,"","UIScrollView")
	--self.bg_Sprite = subComponentGet(self.transform,"Background","UISprite")
	self.content_table = subComponentGet(self.transform,"contentTable","UITable")
	self.line_go = child(self.transform,"contentTable/line").gameObject

	self.contentItemList = {} -- 子项列表
	self.lineSpriteList = {}

	self.toggleResItemMap = {} -- 预设缓存
	self.poolRoot = nil
	self:InitPool()

end

function openroom_content_view:Show(paneltable,value)
	--logError(GetTblData(paneltable))
	if paneltable == self.paneltable then
		self:ResetRoomCard("")
		self:SetCostToggleAble(value)
		return
	end
	self:RecyleToggle()
	self.paneltable = paneltable or {}
	self:DelCache()
	self:CreateItems()
	self:AddConnect()
	self:SetData()
	self:ReflashPanel()
	self:SetCostToggleAble(value)
	--self:ResetBackground()
	self.content_table:Reposition()
	self.content_scrollView:ResetPosition()
	self:SetSpecialItemPos()
end

--[[--
 * @Description: 创建item  
 ]]
function openroom_content_view:CreateItems()
	for i=#self.paneltable + 1,#self.contentItemList do
		local item = self.contentItemList[i]
		if not IsNil(item.gameObject) then
			item:SetActive(false)
		end
		if i-1<=#self.lineSpriteList and i-1 > 0 then
			self.lineSpriteList[i-1].gameObject:SetActive(false)
		end
	end
	
	for i,data in ipairs(self.paneltable) do
		if i > 1 then
			if i-1>#self.lineSpriteList then
				local lineObj = newobject(self.line_go)
				lineObj.transform:SetParent(self.content_table.transform,false)
				table.insert(self.lineSpriteList,lineObj)
			end
			self.lineSpriteList[i-1]:SetActive(true)
		end
		local item
		if i<=#self.contentItemList then
			item = self.contentItemList[i]
		else
			if self.itemPrefab == nil then
				self.itemPrefab = newNormalObjSync(itemPrefabPath, typeof(GameObject))
			end
			local obj = newobject(self.itemPrefab)
			obj.transform:SetParent(self.content_table.transform,false)
			item = openroom_item_view:create(obj)
			table.insert(self.contentItemList,item)
		end
		item:SetActive(true)
		item:CreateToggles(data,self)
	end
	self.itemPrefab = nil
end

--[[--
 * @Description: 添加按键点击回调  
 ]]
function openroom_content_view:AddConnect()
	for i,data in ipairs(self.paneltable) do
		local item = self.contentItemList[i]
		item:AddConnect()
	end
end

--[[--
 * @Description: 初始化设置  
 ]]
function openroom_content_view:SetData()
	for i,data in ipairs(self.paneltable) do
		local item = self.contentItemList[i]
		item:SetData()
	end
end

function openroom_content_view:ReflashPanel()
for i=1,#self.paneltable do 
    local panel = self.paneltable[i]
    local selectIndex = panel.selectIndex
    local connect = panel.connect
    for j=1,#panel.ToggleTable do
      local toggle=panel.ToggleTable[j]
      local toggle_type = toggle.type
      local connecttype = toggle.connecttype

      -- 单选
      if toggle_type == 1 or toggle_type == 0 then
        local toggle_UIToggle = self.contentItemList[i].toggleList[j]

        local toggle_value = false
        for k=1,#selectIndex do
          if selectIndex[k] == j and toggle_UIToggle:IsEnabled() then
            toggle_value = true
            break
          end
        end

        toggle_UIToggle:SetValue(toggle_value)

        -- 对选中项恢复关联
        if connect == 1 and connecttype then
          for m=1,#connecttype do
            if connecttype[m]==1 then 
              if toggle_value then 
                --self:Disable(toggle,m)
              end
            end
            if connecttype[m]==2 then 
              if toggle_value then
                --self:ChangLabel(toggle,m) 
              end
            end 
            if connecttype[m]==3 then
              if toggle_value then
                --self:ToggleChange(toggle,m) 
              end
            end  
          end 
        end

      elseif toggle_type == 2 then

      end
    end
  end
end

function openroom_content_view:ResetBackground()
	local total = 22
	for i,itemData in ipairs(self.paneltable) do
		local baseHeight = 60
		local count = #itemData.ToggleTable
		local line = math.ceil(count/itemData.maxperLine)
		local toggleType = itemData.ToggleTable[1].type
		if toggleType == 2 then
			baseHeight = 70
		end
		total = total + baseHeight*line + 4
	end

	--self.bg_Sprite.height = total
end

---开房特殊处理
function openroom_content_view:SetSpecialItemPos()
	if self.main_ui.curGameGid == ENUM_GAME_TYPE.TYPE_NIUNIU and #self.paneltable > 0 then
		self.lineSpriteList[#self.paneltable-1]:SetActive(false)
		local y_pos = self.contentItemList[#self.paneltable-3].transform.localPosition.y
		local specialItem_tr = self.contentItemList[#self.paneltable].transform
		LuaHelper.SetTransformLocalY(specialItem_tr, y_pos)
		LuaHelper.SetTransformLocalX(specialItem_tr, 435)
	end

	if self.main_ui.curGameGid == ENUM_GAME_TYPE.TYPE_SANGONG and #self.paneltable > 0 then
		self.lineSpriteList[#self.paneltable-1]:SetActive(false)
		local y_pos = self.contentItemList[#self.paneltable-2].transform.localPosition.y
		local specialItem_tr = self.contentItemList[#self.paneltable].transform
		LuaHelper.SetTransformLocalY(specialItem_tr, y_pos)
		LuaHelper.SetTransformLocalX(specialItem_tr, 435)
	end
	--[[local maxLineItem = 8
	if self.main_ui.curGameGid == ENUM_GAME_TYPE.TYPE_SHISHANSHUI or self.main_ui.curGameGid == ENUM_GAME_TYPE.TYPE_DuoGui_SSS 
	  or self.main_ui.curGameGid == ENUM_GAME_TYPE.TYPE_PINGTAN_SSS and #self.paneltable > maxLineItem then
		self.lineSpriteList[#self.paneltable-1]:SetActive(false)
		local y_pos = self.contentItemList[#self.paneltable-2].transform.localPosition.y
		local specialItem_tr = self.contentItemList[#self.paneltable].transform
		LuaHelper.SetTransformLocalY(specialItem_tr, y_pos)
		LuaHelper.SetTransformLocalX(specialItem_tr, 465)
	end--]]
end

function openroom_content_view:ResetRoomCard(id)
	if self.pnum_cache == nil or id == "pnum" then
		self.pnum_cache = self:GetItemValue("pnum")
	end
	if self.round_cache == nil or id == "rounds" then
		self.round_cache = self:GetItemValue("rounds")
	end
	if self.costType_cache == nil or id == "costtype" then
		self.costType_cache = self:GetItemValue("costtype")
	end
	local gid = self.main_ui.curGameGid
	local isClub = self.main_ui:IsClub()
	if gid and self.pnum_cache and self.round_cache and self.costType_cache and isClub~=nil then
		local cost 
		if self.main_ui.isCustomRoomCard then
			cost = openroom_model:GetCustomRoomCardValue(gid,self.pnum_cache,self.round_cache,self.costType_cache)
		end
		if cost == nil then
			cost = openroom_model:GetRoomCardValue(gid,self.pnum_cache,self.round_cache,self.costType_cache,isClub)
		end
		if cost then
			if self.costType_cache == 1 then
				cost = cost.."/人"
			end
			--logWarning("x"..cost)
			self.main_ui:SetRoomCard("x"..cost)
		end
	else
		--logError(gid,self.pnum_cache,self.round_cache,self.costType_cache,isClub)
	end
	
end

function openroom_content_view:SetCostToggleAble(value)
	if value ~= nil then
		for _,panel in ipairs(self.paneltable) do
			if panel.id == "costtype" then
				if value then
					self:SetEnableToggle({{["costtype"] = {3}}})
					self:SetDisableToggle({{["costtype"] = {1,2,0}}})
					if panel.selectIndex[1] ~= 4 then
						self:SetSelectToggle({{["costtype"] = {3}}})
					end
				else
					self:SetEnableToggle({{["costtype"] = {1,2,0}}})
					self:SetDisableToggle({{["costtype"] = {3}}})
					if panel.selectIndex[1] == 4 then
						self:SetSelectToggle({{["costtype"] = {0}}})
					end
				end
				local _,t = self:GetSelect()
				self.main_ui:SavePanelTable(t,true)
			end
		end
	end
end

function openroom_content_view:DelCache()
	self.pnum_cache = nil
	self.round_cache = nil
	self.costType_cache = nil
	switchToggleTbl = {}
end

--[[--
 * @Description: 回收toggle  
 ]]
function openroom_content_view:RecyleToggle()
	for i=#self.paneltable,1,-1 do
		local item = self.contentItemList[i]
		for j=1,#item.toggleList do
			local toggle = item.toggleList[j]
			local type = toggle.toggleData.type
			if type == 0 then
		      self.multi_toggle_pool:Recycle(toggle.gameObject)
		    elseif type == 1 then
		    	self.single_toggle_pool:Recycle(toggle.gameObject)
		    elseif type == 2 then
		      self.poplist_button_pool:Recycle(toggle.gameObject)
		    end
		end
		item.toggleList = {}
		item.data = nil
	end
end

--[[--
 * @Description: 取toggle  
 ]]
function openroom_content_view:GetToggle(type)
	if type == 0 then
      return self.multi_toggle_pool:Get()
    elseif type == 1 then
    	return self.single_toggle_pool:Get()
    elseif type == 2 then
      return self.poplist_button_pool:Get()
    end
end




function openroom_content_view:SetEnableToggle(enableData, selID)
-- ["enable"]={
-- 	[1]={
-- 		["nMaxMult"]={
-- 			[1]=1;[2]=2;[3]=3;[4]=4;[5]=5;
-- 		};
-- 	};
-- }			
	for _,v in ipairs(enableData) do				
		local flag = true
		for id,list in pairs(v) do	
			if type(list) == "table" then
				self:SelectItem(id):SetEnableToggle(id, list)
			elseif type(list) == "number" then
				if switchToggleTbl[id] ~= nil then								
					for j, w in ipairs(switchToggleTbl[id]) do
						if w.srcid ~= selID and w.value ~= list then
							flag = false
						elseif w.srcid == selID then
							w.value = list
						end									
					end
				end
				if flag then
					self:SelectItem(id):SetEnableToggle(id, list)	
				end	
			end			
		end	
	end
end

function openroom_content_view:SetSelectToggle(selectData)
-- ["select"]={
-- 	[1]={
-- 		["pnum"]={
-- 			[1]=4;
-- 		};
-- 	};[2]={
-- 		["nColorAdd"]={
-- 			[1]=1;
-- 		};
-- 	};[3]={
-- 		["nBuyCode"]={
-- 			[1]=0;
-- 		};
-- 	};[4]={
-- 		["nMaxMult"]={
-- 			[1]=5;
-- 		};
-- 	};
-- }
	for _,v in ipairs(selectData) do
		for id,list in pairs(v) do
			self:SelectItem(id):SetSelectToggle(id,list)
		end
	end
end

function openroom_content_view:SetDisableToggle(disableData, selID)
-- ["disable"]={
-- 	[1]={
-- 		["pnum"]={
-- 			[1]=2;[2]=3;[3]=6;
-- 		};
-- 	};[2]={
-- 		["nColorAdd"]={
-- 			[1]=0;
-- 		};
-- 	};[3]={
-- 		["nBuyCode"]={
-- 			[1]=1;
-- 		};
-- 	};
-- }
	for _,v in ipairs(disableData) do
		for id,list in pairs(v) do
			if type(list) == "table" then
				self:SelectItem(id):SetDisableToggle(id,list)
			elseif type(list) == "number" then
				local tmpItem = {}
				tmpItem.id = id
				tmpItem.srcid = selID				
				tmpItem.value = -list
				if switchToggleTbl[id] == nil then
					switchToggleTbl[id] = {}
				end
				local index = self:GetSwitchToggleBySrcID(id, selID)
				if index then
					switchToggleTbl[id][index] = tmpItem			
				else
					table.insert(switchToggleTbl[id], tmpItem)			
				end
				self:SelectItem(id):SetDisableToggle(id,list)				
			end			
		end
	end
end

function openroom_content_view:GetSwitchToggleBySrcID(id, srcid)
	local ret = nil
	if switchToggleTbl[id] ~= nil then
		for i,v in ipairs(switchToggleTbl[id]) do
			if v.srcid == srcid then
				ret = i
				break
			end
		end
	end
	return ret
end

function openroom_content_view:ChangLabelToggle(rtable)
	for id,list in pairs(rtable) do
		self:SelectItem(id):ChangLabelToggle(list)
	end
end

function openroom_content_view:SetToggleChange(isconnect,connect,index)

-- 			["rounds"]={
-- 				[1]={
-- 					[1]=16;[2]=8;[3]=4;
-- 				};[2]={
-- 					[1]=0;
-- 				};
-- 			};


-- 			["rounds"]={
-- 				[1]={
-- 					[1]=0;
-- 				};[2]={
-- 					[1]=16;[2]=8;[3]=4;
-- 				};
-- 			};
	for id,list in pairs(isconnect) do
		self:SelectItem(id):isconnectToggleChange(list[index])
	end

	for id,list in pairs(connect) do
		self:SelectItem(id):connectToggleChange(list[index])
	end

end


function openroom_content_view:SelectItem(id)
	for i,data in ipairs(self.paneltable) do
    	local item = self.contentItemList[i]
    	if type(item.data.id) ~= "table" then
			if id == item.data.id then
				return item
			end
		else
			for i,v in ipairs(item.data.id) do
				if id == v then
					return item
				end
			end
		end
	end
	logError("查找关联失败",id)
end

--[[--
 * @Description: 查找多选toggle  
 ]]
function openroom_content_view:SearchToggleValue(id)
	for i,data in ipairs(self.paneltable) do
    	local item = self.contentItemList[i]
		if type(item.data.id) == "table" then
			for i,v in ipairs(item.data.id) do
				if id == v then
					return item.toggleList[i].curValue
				end
			end
		end
	end
	logError("查找toggle失败",id)
end

--[[--
 * @Description: 查找单选toggle  
 ]]
function openroom_content_view:SearchSingleToggleValue(id,exData)
	for i,data in ipairs(self.paneltable) do
    	local item = self.contentItemList[i]
    	if type(item.data.id) ~= "table" then
			if id == item.data.id then
				for i,v in ipairs(item.toggleList) do
					if v.toggleData.exData == exData then
						return v.self_toggle.value
					end
				end
			end
		end
	end
	logError("查找toggle失败",id)
end

function openroom_content_view:GetItemValue(id)
	for i,data in ipairs(self.paneltable) do
    	local item = self.contentItemList[i]
    	if type(item.data.id) ~= "table" then
			if id == item.data.id then
				return item:GetValue()
			end
		end
	end
end

--[[--
 * @Description: 返回当前界面选择的paneltable数据  
 ]]
function openroom_content_view:GetSelect()
    local paramTable={}

    for i,data in ipairs(self.paneltable) do
    	local item = self.contentItemList[i]
    	self.paneltable[i].selectIndex={}
    	for j,toggle in ipairs(item.toggleList) do
    		local toggleData = toggle.toggleData
    		if toggleData.type==0 or toggleData.type==1 then
    			if toggle.self_button.isEnabled and toggle:GetValue() then
    				if toggleData.type==0  then 
                       paramTable[toggleData.selectIndex]=1  
                    end
                    if toggleData.type==1 then 
                       paramTable[toggleData.selectIndex]=toggleData.exData 
                    end
                    table.insert(self.paneltable[i].selectIndex,j)
                else
                	if toggleData.type==0  then  
                       paramTable[toggleData.selectIndex]=0
                    end
                end
            end
            if toggleData.type== 2 then
            	for k=1,#toggleData.text do
            		if toggle:GetValue() == k then
						paramTable[toggleData.selectIndex]=toggleData.exData[k]
						
                      	table.insert(self.paneltable[i].selectIndex,k) 
                    end
            	end
            end
    	end
    end
 --   logError("test data",GetTblData(paramTable))
    return paramTable,self.paneltable
end

function openroom_content_view:InitPool()
	self.single_toggle_pool = poolBaseClass:create(
		function ()
			return newobject(self:GetItemByType(1))
		end,nil,
		function (obj)
			self:PutToPoolRoot(obj)
		end)

	self.multi_toggle_pool = poolBaseClass:create(
		function ()
			return newobject(self:GetItemByType(0))
		end,nil,
		function (obj)
			self:PutToPoolRoot(obj)
		end)

	self.poplist_button_pool = poolBaseClass:create(
		function ()
			return newobject(self:GetItemByType(2))
		end,nil,
		function (obj)
			self:PutToPoolRoot(obj)
		end)
end

function openroom_content_view:GetItemByType(type)
	local resItem = self.toggleResItemMap[type]
	  if IsNil(resItem) then
	    local path
	    if type == 0 then
	      path = multi_toggle_path
	    elseif type == 1 then
	    	path = single_toggle_path
	    elseif type == 2 then
	      path = poplist_button_path
	    end
	     resItem = newNormalObjSync(path, typeof(GameObject))
	    if resItem ~= nil then
	      self.toggleResItemMap[type] = resItem
	    end
	  end
	  return resItem
end

function openroom_content_view:PutToPoolRoot(obj)
	if self.poolRoot == nil then
		local o = GameObject.New("objPoolRoot")
		o:SetActive(false)
		self.poolRoot = o.transform
		self.poolRoot:SetParent(self.transform)
	end
	obj.transform:SetParent(self.poolRoot,false)
end

return openroom_content_view
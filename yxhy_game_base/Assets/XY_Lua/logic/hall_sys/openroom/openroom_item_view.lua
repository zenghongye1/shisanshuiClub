--[[--
 * @Description: 单项玩法组件
 * @Author:      ShushingWong
 * @FileName:    openroom_item_view.lua
 * @DateTime:    2017-12-12 14:57:23
 ]]
local single_toggle = require "logic/hall_sys/openroom/comp/single_toggle"
local multi_toggle = require "logic/hall_sys/openroom/comp/multi_toggle"
local poplist_button = require "logic/hall_sys/openroom/comp/poplist_button"



local base = require "logic/framework/ui/uibase/ui_view_base"
local openroom_item_view = class("openroom_item_view",base)

function openroom_item_view:InitView()
	self.name_label = self:GetComponent("lab_name","UILabel")
	self.grid = self:GetComponent("toggle_grid","UIGrid")

	self.data = nil -- 数据
	self.toggleList = {} -- 按钮列表
	self.content = nil
end

function openroom_item_view:CreateToggles(data,content)
	self.content = content
	self.data = data

	self.name_label.text=data.title
	self.grid.cellWidth=data.itemWidth
    --self.grid.cellHeight=data.itemHeight
    self.grid.maxPerLine=data.maxperLine
	local tipsList = data["tipsList"] or {}
    for i=1,#data.ToggleTable do
        local toggle=data.ToggleTable[i]
		toggle["tipsEnable"] = tipsList[tostring(i)]
        
        local toggleobj=self:CreateToggle(toggle)
        table.insert(self.toggleList,toggleobj)
        toggleobj.gameObject.name = i
    end
    self.grid:Reposition() 
end


function openroom_item_view:AddConnect()
    local isChangeRoomCardToggle = self.data.id == "pnum" or self.data.id == "rounds" or self.data.id == "costtype"
    local hasConnect = self.data.connect ~= nil 
    for i=1,#self.data.ToggleTable do
        local toggle=self.data.ToggleTable[i]
        
        local toggleobj=self.toggleList[i]

        if (hasConnect and toggle.connecttype and toggle.connect) or isChangeRoomCardToggle then

            local func = function (value)
                if value then
                    if isChangeRoomCardToggle then
                        self.content:ResetRoomCard(self.data.id)
                    end
                end

            	for j=1,#(toggle.connecttype or {}) do
                    local connentType = toggle.connecttype[j]
            		local connentData = toggle.connect[j]
            		if connentData then

                        if connentType == 1 then
        			        local enableData = connentData["enable"]
        					local disableData = connentData["disable"]
                            local selectdata
            				if value then
            					if enableData then
            						self.content:SetEnableToggle(enableData, toggle.selectIndex)
            					end
            					if disableData then
            						self.content:SetDisableToggle(disableData, toggle.selectIndex)
            					end
                                if toggle.isconnect and toggle.isconnect[j] then
                                    selectdata = toggle.isconnect[j]["select"]
                                end
            					if selectdata then
            						self.content:SetSelectToggle(selectdata)
            					end
            				else
                                if toggle.type == 0 then
                					if disableData then
                						self.content:SetEnableToggle(disableData, toggle.selectIndex)
                					end
                					if enableData then
                						self.content:SetDisableToggle(enableData, toggle.selectIndex)
                					end
                                    if toggle.connect and toggle.connect[j] then
                                        selectdata = toggle.connect[j]["select"]
                                    end
                                    if selectdata then
                                        self.content:SetSelectToggle(selectdata)
                                    end
                                end
            				end
                        end

                        if connentType == 2 then
                            local rtable = connentData[1]
                            if value then
                                if rtable then
                                    self.content:ChangLabelToggle(rtable)
                                end
                            end
                        end

                        if connentType == 3 then
                            local vtable=connentData[1] 
                            local ctable=toggle.isconnect[j][1]
                            if value then
                                if ctable or vtable then
                                    self.content:SetToggleChange(ctable,vtable,i)
                                end
                            end
                        end
            		end
            	end
            end

            toggleobj:SetChangeCallBack(func)
        end
    end
end

function openroom_item_view:SetData()
    for i=1,#self.data.selectIndex do    
       local t=self.toggleList[self.data.selectIndex[i]] 
       if t==nil then
          t=self.toggleList[1]
	       if t.toggleData.type==1 then
	       		t:SetValue(true)
	       end    
	       if t.toggleData.type==2 then 
	       		t:SetValue(self.data.selectIndex[i])
	       end
       else
	       if t.toggleData.type==1 or t.toggleData.type==0 then
	       		t:SetValue(true)
	       end    
	       if t.toggleData.type==2 then 
	       		t:SetValue(self.data.selectIndex[i])
	       end
	   end
    end
end

function openroom_item_view:CreateToggle(toggleData)
	local obj,toggle,prefab
	local toggleType = toggleData.type

	obj = self.content:GetToggle(toggleType)
	obj:SetActive(true)
	if toggleType == 0 then
		toggle = multi_toggle:create(obj)
	elseif toggleType == 1 then
		toggle = single_toggle:create(obj)
	elseif toggleType == 2 then
		toggle = poplist_button:create(obj)
		toggle:SetEventFunc(function (toggleData,curValue,callback)
			self.content.toggleWindow:ShowWindow(toggleData,curValue,callback)
		end)
	end
	obj.transform:SetParent(self.grid.transform,false)
	toggle:SetToggleData(toggleData)
	toggle:Show()
	return toggle
end

function openroom_item_view:SetEnableToggle(id,list)
    if type(list) == "table" then
    	for _,exData in ipairs(list) do
    		for _,toggle in ipairs(self.toggleList) do
    			if exData == toggle.toggleData.exData then
    				toggle:SetAble(true)
    			end
    		end
    	end
    elseif type(list) == "number" then
        for _,toggle in ipairs(self.toggleList) do
            if id == toggle.toggleData.selectIndex and list == 1 then
                toggle:SetAble(true)
            end
        end
    end
end

function openroom_item_view:SetSelectToggle(id,list)
    if type(list) == "table" then
    	for _,exData in ipairs(list) do
    		for _,toggle in ipairs(self.toggleList) do
    			if exData == toggle.toggleData.exData then
    				if toggle:IsEnabled() then
    					toggle:SetValue(true)
    				end
    			end
    		end
    	end
    elseif type(list) == "number" then
        for _,toggle in ipairs(self.toggleList) do
            if id == toggle.toggleData.selectIndex and list == 1 then
                if toggle:IsEnabled() then
                    toggle:SetValue(true)
                end
            end
        end
    end
end

function openroom_item_view:SetDisableToggle(id,list)
    if type(list) == "table" then
    	for _,exData in ipairs(list) do
    		for _,toggle in ipairs(self.toggleList) do
    			if exData == toggle.toggleData.exData then
    				toggle:SetAble(false)
    			end
    		end
    	end
    elseif type(list) == "number" then
        for _,toggle in ipairs(self.toggleList) do
            if id == toggle.toggleData.selectIndex and list == 1 then
                toggle:SetAble(false)
            end
        end
    end
end

function openroom_item_view:ChangLabelToggle(list)
    for i,exData in ipairs(list) do
        local toggle = self.toggleList[i]
        if toggle then
            toggle:SetText(exData)
        end
    end
end

--[[--
 * @Description: 参考经典例子XianYouMJ.json  
 ]]
function openroom_item_view:isconnectToggleChange(list)
    for i,exData in ipairs(list) do
        for _,toggle in ipairs(self.toggleList) do
            if exData == toggle.toggleData.exData then
                toggle:SetAble(true)
                if i == 1 and self.data.type == 1 then
                    toggle:SetValue(true)
                end
            end
        end
    end
end

--[[--
 * @Description: 参考经典例子XianYouMJ.json  
 ]]
function openroom_item_view:connectToggleChange(list)
    for _,exData in ipairs(list) do
        for _,toggle in ipairs(self.toggleList) do
            if exData == toggle.toggleData.exData then
                toggle:SetValue(false)
                toggle:SetAble(false)
                --logError(toggle.toggleData.selectIndex,toggle.toggleData.exData)
            end
        end
    end
end

function openroom_item_view:GetValue()
    if self.data.type == 1 then
        for _,toggle in ipairs(self.toggleList) do
            if toggle:GetValue() == true then
                return toggle.toggleData.exData
            end
        end
    end
end

return openroom_item_view
--[[
	input_grid的子对象命名规范：
	0~9 ： 数字0~9
	10：清空
	11：删除(pressCallback == nil时)
	严格子对象索引顺序 1~10,0,11
--]]

local CommonInputi = class("CommonInputi")

function CommonInputi:ctor(input_grid,number_grid,pressCallback,enterCallback)
--[[
	pressCallback: grid_11的回调
	enterCallback：房号6位的回调
--]]	
	self.input_grid = input_grid
	self.number_grid = number_grid
	self.pressCallback = pressCallback
	self.enterCallback = enterCallback
	self.numList = {}
	self.Count = 0
end

function CommonInputi:InitView()
	self:RefreshNumShow("clear")
	for k = 0,self.input_grid.transform.childCount-1 do
        local btn_input = self.input_grid.transform:GetChild(k)
        addClickCallbackSelf(btn_input.gameObject,self.InputClick,self)
    end
end

function CommonInputi:InputClick(obj)
	ui_sound_mgr.PlaySoundClip(data_center.GetAppConfDataTble().appPath.."/sound/common/audio_button_click")
	local index = tonumber(obj.name)
	if (index >= 0 and index <= 9)then
		if self.Count < 6 then
			self.Count = self.Count + 1
			self:AddNumToList(index)
		else
			self.Count = 6
			return
		end
		
	elseif index == 10 then
		self.Count = 0
		self.numList = {}
		self:RefreshNumShow("clear")
	
	elseif index == 11 then
		if self.pressCallback ~= nil then
			self.pressCallback()
		else			
			if self.Count < 1 then
				self.Count = 0
				return
			else
				self.Count = self.Count - 1
				self:DeleteNumFromList()				
			end
		end
	end
end

function CommonInputi:AddNumToList(num)
	table.insert(self.numList,num)
	self:RefreshNumShow("add")
end

function CommonInputi:DeleteNumFromList()
	table.remove(self.numList)
	self:RefreshNumShow("delete") 
end

function CommonInputi:RefreshNumShow(command)
	local count = #self.numList
	if command == "add" then
		local sp_current = self.number_grid.transform:GetChild(count-1)
		local lbl_number = child(sp_current.transform,"Label")
		lbl_number.gameObject:SetActive(true)
		componentGet(lbl_number,"UILabel").text = self.numList[count]
		if count == 6 and self.enterCallback ~= nil then
			self.enterCallback()
		end
		
	elseif command == "delete" then
		local sp_current = self.number_grid.transform:GetChild(count)
		local lbl_number = child(sp_current.transform,"Label")
		lbl_number.gameObject:SetActive(false)
		componentGet(lbl_number,"UILabel").text = ""
		
	elseif command == "clear" then
		for i = 1,6 do
			local sp_current = self.number_grid.transform:GetChild(i-1)
			local lbl_number = child(sp_current.transform,"Label")
			--if self.numList[i] ~= nil then
				--lbl_number.gameObject:SetActive(true)
				--componentGet(lbl_number,"UILabel").text = self.numList[i]
			--else
				lbl_number.gameObject:SetActive(false)
				componentGet(lbl_number,"UILabel").text = ""			
			--end
		end
	end
end

function CommonInputi:GetNumList()
	return self.numList
end

function CommonInputi:ClearNumList()
	self.numList = {}
	self.Count = 0
	self:RefreshNumShow("clear")
end

return CommonInputi
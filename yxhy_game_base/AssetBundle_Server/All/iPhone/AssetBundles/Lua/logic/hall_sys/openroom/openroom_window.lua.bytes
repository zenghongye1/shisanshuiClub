local single_toggle = require "logic/hall_sys/openroom/comp/single_toggle"
local base = require "logic/framework/ui/uibase/ui_view_base"
local openroom_window = class("openroom_window",base)

function openroom_window:InitView()
	self.toggleWindow_sprite = subComponentGet(self.transform,"","UISprite")
	self.toggleWindow_grid = subComponentGet(self.transform,"bg/Grid","UIGrid")
	self.toggleWindowBtn_go = child(self.transform,"sureBtn").gameObject

	self.toggleList = {}
	self.buttonCallback = nil
	addClickCallbackSelf(self.toggleWindowBtn_go,function ()
		for i,v in ipairs(self.toggleList) do
			if v:GetValue() == true then
				self.buttonCallback(i)
				self:HideWindow()
				break
			end
		end
	end,self)

	self.bg_tr = child(self.transform,"bg")
	self.line_go = child(self.transform,"bg/Sprite").gameObject
	self.lineSpriteList = {}
end

function openroom_window:ShowWindow(toggleData,curValue,callback)
	self:SetActive(true)
	local lineCount = #toggleData.text/toggleData.maxPerLine
	self.toggleWindow_sprite.height = math.floor(436/3*lineCount)
	for i=lineCount,#self.lineSpriteList do
		self.lineSpriteList[i].gameObject:SetActive(false)
	end
	
	for i=1,lineCount - 1 do
		if i>#self.lineSpriteList then
			local lineObj = newobject(self.line_go)
			lineObj.name = i
			lineObj.transform:SetParent(self.bg_tr,false)
			table.insert(self.lineSpriteList,lineObj)
		end
		self.lineSpriteList[i]:SetActive(true)
		local y_pos = 2 + (lineCount - 2)*50 - (i - 1)*100
		self.lineSpriteList[i].transform.localPosition = Vector3(0,y_pos,0)
	end
	for i=1,#toggleData.text do
		local toggleObj = self.content:GetToggle(1)
		toggleObj:SetActive(true)
		local toggle = single_toggle:create(toggleObj)
		toggleObj.transform:SetParent(self.toggleWindow_grid.transform,false)
		toggle:SetToggleData({text = toggleData.text[i],Group = toggleData.Group})
		toggle:Show()
		table.insert(self.toggleList,toggle)
	end

	if curValue then
		self.toggleList[curValue]:SetValue(true)
	end
	self.buttonCallback = callback
	self.toggleWindow_grid.maxPerLine = toggleData.maxPerLine
	self.toggleWindow_grid:Reposition() 

end

function openroom_window:HideWindow()
	for _,v in ipairs(self.toggleList) do
		self.content.single_toggle_pool:Recycle(v.gameObject)
	end
	self.toggleList = {}
	self:SetActive(false)
end


return openroom_window
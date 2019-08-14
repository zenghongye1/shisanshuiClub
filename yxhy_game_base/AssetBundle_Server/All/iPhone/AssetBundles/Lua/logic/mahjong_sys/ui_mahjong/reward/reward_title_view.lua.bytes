local base = require "logic/framework/ui/uibase/ui_view_base"
local reward_title_view = class("reward_title_view", base)

function reward_title_view:InitView()
	base.InitView(self)
	--self.titleWinBgGo = self:GetGameObject("titleWinBg")
	self.titleWinBg_sp = self:GetComponent("titleWinBg",typeof(UISprite))
	--self.titleLoseBgGo = self:GetGameObject("titleLoseBg")
	self.titleLoseBg_sp = self:GetComponent("titleLoseBg",typeof(UISprite))
	--self.titleIcon = self:GetComponent("titleIcon", typeof(UISprite))

	self.titleGridObj = self:GetGameObject("titleGrid")
	self.titleGrid = self:GetComponent("titleGrid",typeof(UITable))
	self.titleIcon = self:GetComponent("titleGrid/titleIcon",typeof(UISprite))
end

-- res 1 胡 2 失败 3  荒庄  ...
function reward_title_view:SetResult(data)
	local iconName = config_mgr.getConfig("cfg_artconfig",data.titleIndex).spriteName
	if self.titleIcon ~= nil and iconName ~= nil then
		self.titleIcon.spriteName = iconName
	else
		logError("错误的data.titleIndex："..data.titleIndex)
	end
	self.titleIcon:MakePixelPerfect()

	self.titleWinBg_sp.gameObject:SetActive(data.isWinBG)
	if data.isWinBG then 
		if data.number > 0 then
			self.titleWinBg_sp.spriteName = "jiesuan_08"
		else
			self.titleWinBg_sp.spriteName = "jiesuan_09"
		end
	end
	self.titleLoseBg_sp.gameObject:SetActive(not data.isWinBG)
	if not data.isWinBG then
		if data.isHuang then
			self.titleLoseBg_sp.spriteName = "jiesuan_07"
		else
			self.titleLoseBg_sp.spriteName = "jiesuan_06"
		end
	end

	self:RecoverTitle()
	if data.number and data.number > 0 then
		self:GetNumList(data.number)
	end
	self.titleGrid:Reposition()
end

function reward_title_view:GetNumList(num)
	local tbl = {}
	while num >0 do
		local n = num%10
		table.insert(tbl,n)
		num = math.floor(num/10)
	end

	local count = self.titleGrid.transform.childCount
	local tblCount = #tbl
	for i=2,count do
		local tran = self.titleGridObj.transform:GetChild(i-1)
		if tblCount == 0 then
			tran.gameObject:SetActive(false)
		else
			if i<=tblCount+2 then
				tran.gameObject:SetActive(true)
				local tIndex = i -2 ;
				if tIndex > 0 then
					local tNumSprite = componentGet(tran,"UISprite")
					tNumSprite.spriteName = "xjs_1"..tostring(tbl[tblCount-tIndex+1])
					tNumSprite:MakePixelPerfect()
				end
			else
				tran.gameObject:SetActive(false)
			end					
		end
	end
end

function reward_title_view:RecoverTitle()	
	local count = self.titleGrid.transform.childCount
	for i=2,count do
		local tran = self.titleGridObj.transform:GetChild(i-1)
		tran.gameObject:SetActive(false)		
	end
end

return reward_title_view
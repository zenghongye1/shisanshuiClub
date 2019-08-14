local base = require "logic/framework/ui/uibase/ui_view_base"
local Item = class("Item", base)

function Item:InitView()
	self.titleLabel = self:GetComponent("title", typeof(UILabel))
	self.desLabel = self:GetComponent("des", typeof(UILabel))
	self.iconGo = self:GetGameObject("icon")
	addClickCallbackSelf(self.gameObject, self.OnClick, self)
end

function Item:OnClick()
	if self.callback ~= nil then
		self.callback(self.target, self)
	end
end

function Item:SetInfo(index, word1, word2)
	self.index = index
	self.desLabel.text = LanguageMgr.GetWord(word1)
	self.titleLabel.text = LanguageMgr.GetWord(word2)
end

function Item:SetCallback(callback, target)
	self.callback = callback
	self.target = target
end

function Item:SetSelect(value)
	if value == 1 then
		self.iconGo:SetActive(true)
	else
		self.iconGo:SetActive(false)
	end
end


local ClubManageView = class("ClubManageView", base)
local cfg = 
{	
		-- 内容，提示，  字段
	[1] = {10211, 10201, 10221, "public"},
	[2] = {10212, 10202, 10222, "allcosthost"},
	[3] = {10213, 10203, 10223, "mcactuser"},
	[4] = {10214, 10204, 10224, "mcosthost"},
}

function ClubManageView:SetInfo(clubInfo)
	if clubInfo == nil then
		return
	end
	self.clubInfo = clubInfo
	self:RefreshView()
end
function ClubManageView:SetAgent(_isAgent)
	self._isAgent = _isAgent
end

function ClubManageView:RefreshView()
	if self.clubInfo ~= model_manager:GetModel("ClubModel").currentClubInfo then
		self.clubInfo =  model_manager:GetModel("ClubModel").currentClubInfo 
	end
	if self.clubInfo == nil then
		return
	end
	for i = 1, 4 do
		if self.clubInfo.cfg == nil then
			self.itemList[i]:SetSelect(false)
		else
			self.itemList[i]:SetSelect(self.clubInfo.cfg[cfg[i][4]])
		end

		--代理商隐藏“展示俱乐部”
		local item = self.itemList[i]
		if item then
			self.moveUpTbl = self.moveUpTbl or {}
			if i==1 then
				item.gameObject:SetActive(not self._isAgent)
				self.firstItemPos = item.transform.localPosition
			elseif self.firstItemPos then
				local itemPos = item.transform.localPosition
				self.itemMoveY = self.itemMoveY or (self.firstItemPos.y -itemPos.y)

				local managerLabel = self:GetGameObject("scroll/managerLabel")
				if managerLabel then
					local curValue = managerLabel.transform.localPosition
					if self._isAgent then
						--上移
						if not self.moveUpTbl[10] then
							self.moveUpTbl[10] = true
							managerLabel.transform.localPosition = Vector3(curValue.x, curValue.y +self.itemMoveY, curValue.z)
						end
					elseif self.moveUpTbl[10] then
						--恢复
						self.moveUpTbl[10] = false
						managerLabel.transform.localPosition = Vector3(curValue.x, curValue.y -self.itemMoveY, curValue.z)
					end
				end

				if self._isAgent then
					--上移
					if not self.moveUpTbl[i] then
						self.moveUpTbl[i] = true
						item.transform.localPosition = Vector3(itemPos.x, itemPos.y +self.itemMoveY, itemPos.z)
					end
				elseif self.moveUpTbl[i] then
					--恢复
					self.moveUpTbl[i] = false
					item.transform.localPosition = Vector3(itemPos.x, itemPos.y -self.itemMoveY, itemPos.z)
				end
			end
		end
	end
end


function ClubManageView:InitView()
	self.model = model_manager:GetModel("ClubModel")
	self.itemList = {}
	for i = 1, 4 do
		local go = self:GetGameObject("scroll/item" .. i)
		local item = Item:create(go)
		item:SetInfo(i, cfg[i][1], cfg[i][2])
		item:SetSelect(false)
		item:SetCallback(self.OnItemClick, self)
		self.itemList[i] = item
	end
end

function ClubManageView:OnItemClick(item)
	local cfgS = self.clubInfo.cfg
	local key = cfg[item.index][4]
	local value = 0

	local oldValueTab = {}
	oldValueTab[1] = self.clubInfo.cid
	if cfgS ~= nil  then
		oldValueTab[2] = cfgS.public or 0
		oldValueTab[3] = cfgS.allcosthost or 0
		oldValueTab[4] = cfgS.mcactuser or 0
		oldValueTab[5] = cfgS.mcosthost or 0
		value = cfgS[key] or 0
	else
		oldValueTab[2] = 0
		oldValueTab[3] = 0
		oldValueTab[4] = 0
		oldValueTab[5] = 0
	end

	if value == 1 then
		oldValueTab[item.index + 1] = 0
		self.model:ReqSetClubConfig(unpack(oldValueTab))
	else
		oldValueTab[item.index + 1] = 1
		MessageBox.ShowYesNoBox(LanguageMgr.GetWord(cfg[item.index][3], self.clubInfo.cname), 
			function()
				self.model:ReqSetClubConfig(unpack(oldValueTab))
			end)
	end
end




function ClubManageView:OnOpen()
end

function ClubManageView:OnClose()
end

function ClubManageView:RegistEvent()
	Notifier.regist(GameEvent.OnClubInfoUpdate, self.RefreshView, self)
end

function ClubManageView:RemoveEvent()
	Notifier.remove(GameEvent.OnClubInfoUpdate, self.RefreshView, self)
end

return ClubManageView
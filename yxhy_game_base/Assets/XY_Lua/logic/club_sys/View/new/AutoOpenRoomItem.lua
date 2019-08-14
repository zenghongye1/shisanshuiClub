local base = require "logic/framework/ui/uibase/ui_view_base"
local AutoOpenRoomItem = class("AutoOpenRoomItem", base)

function AutoOpenRoomItem:InitView()
	self.model = model_manager:GetModel("ClubModel")
	self.nameLabel = self:GetComponent("name", typeof(UILabel))
	self.costtypeLabel = self:GetComponent("costType", typeof(UILabel))
	self.rulesLabel = self:GetComponent("openRules", typeof(UILabel))
	self.timesLabel = self:GetComponent("openRoomtimes", typeof(UILabel))
	self.icon = self:GetComponent("gameIcon", typeof(UISprite))
	self.deleteBtn = self:GetGameObject("deleteBtn")
	addClickCallbackSelf(self.deleteBtn,self.OnDelBtnClick,self)
	self.auto_id = nil
end

function AutoOpenRoomItem:SetCallback(callback, target)
	self.callback = callback
	self.target = target
end

function AutoOpenRoomItem:SetInfo(info)
	self.info = info
	--刷数据
	self:UpdateView()
end

function AutoOpenRoomItem:OnDelBtnClick()
	ui_sound_mgr.PlayButtonClick()
	self.model:DelAutoCreateRoom(self.auto_id)
	self.gameObject:SetActive(false)
	if self.callback ~= nil then
		self.callback(self.target,self)
	end
end

function AutoOpenRoomItem:UpdateView()
	local name = GameUtil.GetGameName(self.info.gid)
	self.nameLabel.text = name--游戏名字
	self.auto_id = self.info.auto_id
	self.timesLabel.text = self.info.create_num or ""--开房次数
	self.icon.spriteName = GameUtil.GetGameIcon(self.info.gid)--游戏头像
	if self.info.cfg == nil then
		return
	end
	local rules,costType = self:GetRules(self.info)
	self.rulesLabel.text = rules or ""
	self.costtypeLabel.text = costType or ""--消费方式
end

-- function AutoOpenRoomItem:OnClick()
-- 	if self.callback ~= nil then
-- 		self.callback(self.target, self)
-- 	end
-- end

function AutoOpenRoomItem:GetRules(info)
	local content,contentTbl = ShareStrUtil.GetRoomShareStr(info.gid,info,true)		
	if content then
		local contentStr = nil
		local costType = string.gsub(contentTbl[1],"、","")
		table.remove(contentTbl,1)
		contentStr = table.concat(contentTbl)
		return contentStr,costType
	end
end



return AutoOpenRoomItem
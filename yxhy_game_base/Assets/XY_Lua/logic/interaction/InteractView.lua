local view_base = require("logic/framework/ui/uibase/ui_view_base")
local ExItem = class('item', view_base)
function ExItem:InitView()
	self.iconSp = self:GetComponent("", typeof(UISprite))
	self.freeIconGo = self:GetGameObject("free_icon")
	self.iconGo = self:GetGameObject("icon")
	self.costLabel = self:GetComponent("icon/cost", typeof(UILabel))
	addClickCallbackSelf(self.gameObject, function ()
		if self.callback ~= nil then
			self.callback(self.target,self)
		end
	end)
end

function ExItem:SetInfo(cfg, index)
	self.cfg = cfg
	self.index = index
	self.iconSp.spriteName = cfg.icon
end

function ExItem:SetCallback(callback, target)
	self.callback = callback
	self.target = target
end

function ExItem:SetPriceInfo(price)
	if price == nil or price.is_fee == 1 or price.diamond == 0 then
		self.price = 0
		self.freeIconGo:SetActive(true)
		self.iconGo:SetActive(false)
	else
		self.freeIconGo:SetActive(false)
		self.iconGo:SetActive(true)
		-- 刷新文本
		self.price = price.diamond
		self.costLabel.text = "x" .. self.price
	end
end


local base = require("logic/framework/ui/uibase/ui_load_view_base")
local InteractView = class("InteractView", base)

function InteractView:InitPrefabPath()
	self.prefabPath = data_center.GetAppPath().. "/ui/common/interact_view"
end

function InteractView:InitView()

	self.model = model_manager:GetModel("ChatModel")

	self.bgSp = self:GetComponent("bg/bg", typeof(UISprite))
	self.checkList = {self.bgSp}
	self.itemGo = self:GetGameObject("btn/item")
	self.itemGo:SetActive(false)
	self.grid = self:GetComponent("btn/ScrollView/interfaceGrid", typeof(UIGrid))
	self.itemList = {}

	addClickCallbackSelf(self.gameObject, self.Hide, self)

	local cfgs = config_mgr.getConfigs("cfg_interact")

	for i = 1, #cfgs do
		if cfgs[i].isEnable == 1 then
			local go = newobject(self.itemGo)
			go.transform:SetParent(self.grid.transform)
			local item = ExItem:create(go)
			self.itemList[i] = item
			self.itemList[i]:SetInfo(cfgs[i], i)
			item:SetActive(true)
			item:SetCallback(self.OnItemClick,self)
		end
	end

	self.grid:Reposition()

	self.model:ReqGetPaidFace()
end

function InteractView:Refresh(logicSeat)
	self.logicSeat = logicSeat
end


function InteractView:OnHide()
	Notifier.remove(GameEvent.OnExpressionPriceUpdate, self.OnPriceUpdate, self)
end

function InteractView:OnShow()
	Notifier.regist(GameEvent.OnExpressionPriceUpdate, self.OnPriceUpdate, self)
	self:OnPriceUpdate()
end

function InteractView:OnPriceUpdate()
	for i = 1, #self.itemList do
		self.itemList[i]:SetPriceInfo(self.model:GetExpressionPrice(self.itemList[i].cfg.faceId))
	end
end


function InteractView:OnItemClick(item)
	if not self:CheckMoney(item.price) then
		return
	end

	self:SendCost(item)
end


function InteractView:SendCost(item)
	self.model:ReqSendPaidFace(item.cfg.faceId, roomdata_center.rid, function() 
		self:SendChat(item.index)
	end)
end

function InteractView:SendChat(index)
	if GameUtil.CheckGameIdIsMahjong(roomdata_center.gid) then
		mahjong_play_sys.ChatReq(4,tostring(index),"p"..self.logicSeat)
	else
		pokerPlaySysHelper.GetCurPlaySys().ChatReq(4,tostring(index),"p"..self.logicSeat)
	end
end

function InteractView:CheckMoney(money)
	--钻石是否充足
	self.money = data_center.GetLoginUserInfo().card
	if self.money < money then
		local content = "您的账户\"钻石\"不足，无法继续\n发送互动表情，是否充值钻石?"
		local yesBtn = MessageBox.GetBtnInfo("是", "button_03", function()
				-- Trace("充值钻石..")
				UI_Manager:Instance():ShowUiForms("shop_ui")
			end)
		local noBtn = MessageBox.GetBtnInfo("否","button_05", function() end)
		MessageBox.Show(content, {yesBtn, noBtn}, nil)
		return false
	end
	return true
end



return InteractView
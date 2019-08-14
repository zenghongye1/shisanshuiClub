local bigSettlement_ui_item = require "logic/mahjong_sys/ui_mahjong/window/bigSettlement_ui_item"

local base = require("logic.framework.ui.uibase.ui_window")
local bigSettlement_ui = class("bigSettlement_ui", base)

function bigSettlement_ui:ctor()
	base.ctor(self)
	self.loginType = data_center.GetPlatform()
	self.playerItemList = {}
end

function bigSettlement_ui:OnInit()
  	base.OnInit(self)
	self:InitView()
end

function bigSettlement_ui:OnOpen(...)
  	base.OnOpen(self,...)
	if roomdata_center.totalRewardData == nil then
		roomdata_center.needShowTotalReward = true
	else
		self:ReflushUI(roomdata_center.totalRewardData)
	end
end

function bigSettlement_ui:OnClose()
end

function bigSettlement_ui:PlayOpenAmination()
end

function bigSettlement_ui:InitView()
	self.btn_close=child(self.transform,"backBtn")
    addClickCallbackSelf(self.btn_close.gameObject,self.OnBtnEndClick,self)

	local btnEnd = child(self.transform, "panel/btn/btn_end")
	addClickCallbackSelf(btnEnd.gameObject, self.OnBtnEndClick, self)

	local btnShare = child(self.transform, "panel/btn/btn_share")
	addClickCallbackSelf(btnShare.gameObject, self.OnBtnShareClick, self)

	self.name_label = subComponentGet(self.transform, "panel/Anchor_TopRight/name","UILabel")

	self.roomNum_label = subComponentGet(self.transform, "panel/Anchor_TopRight/roomNum","UILabel")

	self.gameTime_label = subComponentGet(self.transform, "panel/Anchor_TopRight/time","UILabel")

	self.playerItem_tr = child(self.transform, "panel/player")
	self.playerItem_tr.gameObject:SetActive(false)
	self.grid_tr=child(self.transform,"panel/Scroll View/center")

	--苹果审核隐藏界面
	if G_isAppleVerifyInvite then
		if btnShare then
			btnShare.gameObject:SetActive(false)
		end
		if btnEnd then
			LuaHelper.SetTransformLocalX(btnEnd.gameObject.transform, 0)
		end
	end
end

function bigSettlement_ui:OnBtnEndClick()
	UI_Manager:Instance():CloseUiForms("bigSettlement_ui")
	SocketManager:closeSocket("game")
	game_scene.DestroyCurSence()
	game_scene.gotoHall()  
end

function bigSettlement_ui:OnBtnShareClick()
	report_sys.EventUpload(38,player_data.GetGameId())
	screenshotHelper.GetShot(self.loginType,0,2,"分享战绩","http://connect.qq.com/","分享战绩")
end

function bigSettlement_ui:ReflushUI(result)
	local clubName = ""
	if roomdata_center.gt_cfg and roomdata_center.gt_cfg.cid then
		local clubInfo = model_manager:GetModel("ClubModel").clubMap[roomdata_center.gt_cfg.cid]
		if clubInfo and clubInfo["ctype"] ~= 1 then
			clubName = clubInfo.cname
		end
	end
	self.name_label.text = clubName
	self.roomNum_label.text = (result.gameName or "").." "..(result.roomNum or "")
	self.gameTime_label.text = result.endTime or ""

	if IsNil(self.transform) then
		return
	end
	self:UpdateGridPos(#result.players)
	local usersDataList = room_usersdata_center.GetUsersDataList()
	for k, playerData in ipairs(result.players) do
		if playerData~= nil then
			local item = self.playerItemList[k]
			if item == nil then
				go = newobject(self.playerItem_tr.gameObject)
				go.transform:SetParent(self.grid_tr,false)
				go.name = "player"..k
				item = bigSettlement_ui_item:create(go)
				table.insert(self.playerItemList,item)
			end
			item:SetActive(true)
			item.transform.localPosition = Vector3(310*(k-1),0,0)
		end
	end
	for i=#result.players+1,#self.playerItemList do
		self.playerItemList[i]:SetActive(false)
	end
	for k, playerData in ipairs(result.players) do
		self.playerItemList[k]:Show(playerData)
	end
    --componentGet(self.grid_tr,"UIGrid"):Reposition()   
end

function bigSettlement_ui:UpdateGridPos(count)
	if count == 2 then
		self.grid_tr.localPosition = Vector3(-159,0,0)
	elseif count == 3 then
		self.grid_tr.localPosition = Vector3(-313,0,0)
	else
		self.grid_tr.localPosition = Vector3(-463.7,0,0)
	end
end

function bigSettlement_ui:OnRefreshDepth()
  local uiEffect = child(self.gameObject.transform, "tittle/Effect_youxifenxiang")
  if uiEffect and self.sortingOrder then
    local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
    Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
  end
end

return bigSettlement_ui
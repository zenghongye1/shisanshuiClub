--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--endregion
local ui_wrap = require "logic/framework/ui/uibase/ui_wrap"
local base = require("logic.framework.ui.uibase.ui_window")
local mail_ui = class("mail_ui",base)
local mail_item = require "logic/hall_sys/mail_ui/mail_item"

local isOpen = false
local attachmentText = {
	[1] = "钻石",
	[2] = "金币",
	[3] = "钻石",
}
local attachmentSpName = {
	[1] = "",
	[2] = "",
	[3] = "",
}

function mail_ui:ctor()
	base.ctor(self)
	self.itemList = {}
	self.currentIndex = 1
	self.destroyType = UIDestroyType.ChangeScene
end

function mail_ui:OnInit()
    self:InitView()
end

function mail_ui:OnOpen()
	isOpen = true
end

function mail_ui:PlayOpenAnimationFinishCallBack()	--打开动画播放后
	UI_Manager:Instance():ShowUiForms("waiting_ui")
	mail_data.ReqMailData(function()
		UI_Manager:Instance():CloseUiForms("waiting_ui")
		if isOpen then
			self:UpdateView()
		end
	end)
end

function mail_ui:OnRefreshDepth()
	local uiEffect = child(self.gameObject.transform, "panel_mail/Panel_Top/Title/Effect_youxifenxiang")
	if uiEffect and self.sortingOrder then
		local topLayerIndex = self.sortingOrder +self.m_subPanelCount +1
		Utils.SetEffectSortLayer(uiEffect.gameObject, topLayerIndex)
	end
end

function mail_ui:InitView()
    local btn_close = child(self.gameObject.transform,"panel_mail/Panel_Top/btn_close")
    if btn_close ~= nil then
        addClickCallbackSelf(btn_close.gameObject,self.CloseWin,self)
    end  
    self.nomailBgGo = self:GetGameObject("panel_mail/Panel_Right/nomailBg")
    self.nomailBgGo:SetActive(true)
	self.mailDetailGo = self:GetGameObject("panel_mail/Panel_Right/sp_background")
	self.mailDetailGo:SetActive(false)

	for i=1,7 do 
		local go = self:GetGameObject("panel_mail/Panel_Left/container/scrollview/ui_wrapcontent/"..tostring(i))
		local item = mail_item:create(go)
		item:SetCallback(self.OnItemClick,self)
		self.itemList[i] = item
	end
	
	self.wrap = ui_wrap:create(self:GetGameObject("panel_mail/Panel_Left/container"))
	self.wrap:InitUI(90)
	self.wrap.OnUpdateItemInfo = function(go,rIndex,index)  self:OnItemUpdate(go,index,rIndex)  end
	self.wrap:InitWrap(0)
	
	self.scrollview_text = self:GetComponent("panel_mail/Panel_Right/sp_background","UIScrollView")
	self.lbl_title = self:GetComponent("panel_mail/Panel_Right/sp_background/title","UILabel")
	self.lbl_content = self:GetComponent("panel_mail/Panel_Right/sp_background/lbl_details","UILabel")
	self.lbl_time = self:GetComponent("panel_mail/Panel_Right/sp_background/sender/lbl_time","UILabel")
	self.lbl_name = self:GetComponent("panel_mail/Panel_Right/sp_background/sender/lbl_name","UILabel")
	
	self.lbl_leftTime = self:GetComponent("panel_mail/Panel_Right/lbl_leftTime","UILabel")
	self.lbl_leftTime.gameObject:SetActive(false)
	
	self.btnGetGo = self:GetGameObject("panel_mail/Panel_Right/btn_get")	
	if self.btnGetGo then
		addClickCallbackSelf(self.btnGetGo.gameObject,self.GetReward,self)
		self.btnGetGo:SetActive(false)
	end
	self.btnDeleteGo = self:GetGameObject("panel_mail/Panel_Right/btn_delete")
	if self.btnDeleteGo then
		addClickCallbackSelf(self.btnDeleteGo.gameObject,self.DeleteMail,self)
		self.btnDeleteGo:SetActive(false)
	end
	self.rewardGo = self:GetGameObject("panel_mail/Panel_Right/sp_background/reward")
end

function mail_ui:OnItemUpdate(go,index,rIndex)
	local mailData = mail_data.GetMailData()
	go.name = tostring(rIndex)
	self.itemList[index]:SetInfo(mailData[rIndex])
	self:SetItemStatus()
end

function mail_ui:UpdateView()
	local count = mail_data.GetMailDataCount()
	self:CheckShowNoMail(count)
	self.wrap:InitWrap(count)
	if count > 0 then
		self:OnItemClick(self.itemList[1])	--默认打开第一封
	end
end

function mail_ui:OnItemClick(itemObj)
	ui_sound_mgr.PlayButtonClick()
	local rIndex = tonumber(itemObj.gameObject.name)
	self.currentIndex = rIndex
	self:SetItemStatus()
	self:UpdateMailDetail(itemObj,rIndex)
end

---处理toggle点击状态变化
function mail_ui:SetItemStatus()
	for i=1,7 do	
		if tonumber(self.itemList[i].gameObject.name) == tonumber(self.currentIndex) then
			componentGet(self.itemList[i].gameObject,"UIToggle").value = true
		else
			componentGet(self.itemList[i].gameObject,"UIToggle").value = false
		end	
	end
end

function mail_ui:UpdateMailDetail(itemObj,rIndex)
	local mailData = mail_data.GetMailData()
	if not mailData[rIndex] then
		itemObj:SetActive(false)
		return
	end
	
	self.lbl_content.text = mailData[rIndex]["content"]
	self.lbl_title.text = mailData[rIndex]["title"]
	self.lbl_time.text = os.date("%Y/%m/%d %H:%M",mailData[rIndex]["ptime"])
	self.lbl_name.text = mailData[rIndex]["nickname"]
	--self.lbl_leftTime.text = "剩余"..os.date("%d天%H小时",mailData[rIndex]["expiretime"]- os.time()).."过期"
	self.lbl_leftTime.text = "剩余"..self:GetLeftDayHourStr(mailData[rIndex]["expiretime"]).."过期"
	
	self:CheckWithAttachment(rIndex)
	
	self.scrollview_text:ResetPosition()	
	mail_data.ReqReadMail(rIndex,function()		--设置已读
		itemObj:SetRedPointShow(false)		
		self:IsHallRedPointHide()
	end)
end

function mail_ui:CheckShowNoMail(count)
	local show = (count == 0)
	self.nomailBgGo:SetActive(show)
	self.lbl_leftTime.gameObject:SetActive(not show)
	self.mailDetailGo:SetActive(not show)
	self.btnGetGo:SetActive(not show)
	self.btnDeleteGo:SetActive(not show)
end

function mail_ui:CheckWithAttachment(rIndex)
	local mailData = mail_data.GetMailData()
	if mailData[rIndex]["attachment"] and not isEmpty(mailData[rIndex]["attachment"]) then
		if mailData[rIndex]["isget"] == 0 then		--未领取
			self.btnGetGo:SetActive(true)
			self.rewardGo:SetActive(true)
			self.btnDeleteGo:SetActive(false)
			
			local attachment = mailData[rIndex]["attachment"]
			for i=1,3 do 							--暂只支持三种附件
				local item = child(self.rewardGo.transform,"item"..tostring(i))
				if attachment[i] then	
					item.gameObject:SetActive(true)
					componentGet(child(item,"thing"),"UISprite").spriteName = attachmentSpName[attachment[i]["type"]]
					componentGet(child(item,"getLbl"),"UILabel").text = attachmentText[attachment[i]["type"]].."*"..attachment[i]["val"]
				else
					item.gameObject:SetActive(false)
				end
			end
		else
			self.btnGetGo:SetActive(false)
			self.rewardGo:SetActive(false)
			self.btnDeleteGo:SetActive(false)
		end
	else
		self.btnGetGo:SetActive(false)
		self.rewardGo:SetActive(false)
		self.btnDeleteGo:SetActive(false)	--删除屏蔽使用
	end
end

function mail_ui:GetLeftDayHourStr(time)
	local lefTime = (time or os.time())- os.time()
	local day = math.floor(lefTime/86400)
	local hour = math.fmod(math.floor(lefTime/3600), 24) 
	return day.."天"..hour.."小时"
end

---领取附件
function mail_ui:GetReward()
	ui_sound_mgr.PlayButtonClick()
	mail_data.ReqGetReward(tonumber(self.currentIndex),function()
		self.btnGetGo:SetActive(false)
		self.rewardGo:SetActive(false)
	end)
end

---删除一封邮件
function mail_ui:DeleteMail()
	ui_sound_mgr.PlayButtonClick()
	mail_data.ReqDeleteMail(tonumber(self.currentIndex),function()
		self:UpdateView()
	end)
end

function  mail_ui:CloseWin()
    ui_sound_mgr.PlayCloseClick()
	UI_Manager:Instance():CloseUiForms("mail_ui")
end 

---全部已读则隐藏大厅红点
function mail_ui:IsHallRedPointHide()
	hall_ui:ShowEmailRedPoint(not mail_data.CheckAllRead())
end

function mail_ui:OnClose()
	isOpen = false
end
 
return mail_ui
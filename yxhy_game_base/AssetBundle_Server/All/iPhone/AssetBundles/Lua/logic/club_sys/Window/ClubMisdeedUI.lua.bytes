local base = require("logic.framework.ui.uibase.ui_window")
local ClubMisdeedUI = class("ClubMisdeedUI", base)
local ui_wrap = require "logic/framework/ui/uibase/ui_wrap"
local UIManager = UI_Manager:Instance()

function ClubMisdeedUI:OnInit()
	self.model = model_manager:GetModel("ClubModel")
	self:InitView()
end

function ClubMisdeedUI:OnOpen(cid,uid)
	self.cid = cid
	self.uid = uid
	self.model:ReqGetUserMisdeed(cid,uid,function(msgTab)
		self.container:SetActive(true)
		self.msgList = msgTab["data"]
		self.wrap:Initdate(self.msgList)
	end)
end

function ClubMisdeedUI:OnClose()
	self.msgList = {}
	self.container:SetActive(false)
end

function ClubMisdeedUI:PlayOpenAmination()
	--重写
end

function ClubMisdeedUI:InitView()
	local collider = self:GetGameObject("collider")
	addClickCallbackSelf(collider,self.CloseWin,self)
	self.container = self:GetGameObject("bg/container")
	self.wrap = ui_wrap:create(self.container)
	self.wrap:InitUI(44)
	self.wrap.OnUpdateItemInfo = function(go,rindex,index) self:OnItemUpdate(go,index,rindex)  end
	self.wrap:InitWrap(0)
end

function ClubMisdeedUI:OnItemUpdate(go,index,rindex)
	if self.msgList[rindex] ~= nil then
		local info = self.msgList[rindex]
		componentGet(go,"UILabel").text = rindex.."."..info["reason"].."，"..info["cname"].."，"..os.date("%Y/%m/%d",info["ptime"])
	end
end

function ClubMisdeedUI:CloseWin()
	UIManager:CloseUiForms("ClubMisdeedUI")
end

return ClubMisdeedUI
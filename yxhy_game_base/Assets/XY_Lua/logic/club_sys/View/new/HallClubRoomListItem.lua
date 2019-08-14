local base = require "logic/club_sys/View/ClubEnterRoomItem"
local HallClubRoomListItem = class("HallClubRoomListItem",base)

local costTypeConfig = {
	[1] = "房主支付",
	[2] = "AA支付",
	[3] = "大赢家支付",
	[4] = "会长支付",
}
local offClubStr = "大厅 [AEC0D9FF]（仅自己可见）"
local nameExtStr = "[D82B2B]（仅自己可见）[-]"

function HallClubRoomListItem:InitView()
	base.InitView(self)
	self.payModeLabel = self:GetComponent("payMode", typeof(UILabel))
	self.clubNameLabel = self:GetComponent("clubName", typeof(UILabel))
	self.offClubNameLabel = self:GetComponent("offClubName", typeof(UILabel))
	--self.isShowLabel = self:GetComponent("isShow", typeof(UILabel))
end

function HallClubRoomListItem:SetInfo(info)
	base.SetInfo(self,info)

	if info.cfg == nil then
		return
	end
	if info["cfg"]["costtype"] == nil then
		return
	end

	if info["cfg"]["costtype"] == nil then
		info["cfg"].costtype = 0
	end

	self.payModeLabel.text = costTypeConfig[info["cfg"]["costtype"]+1] or ""
	local clubMap = model_manager:GetModel("ClubModel").clubMap
	if clubMap[info["cid"]] then
		if clubMap[info["cid"]].ctype == 1 then
			componentGet(self.clubNameLabel.transform.parent,"UISprite").spriteName = "club_31"
			self.clubNameLabel.gameObject:SetActive(false)
			self.offClubNameLabel.gameObject:SetActive(true)
			self.offClubNameLabel.text = offClubStr
		else
			componentGet(self.clubNameLabel.transform.parent,"UISprite").spriteName = "club_21"
			self.clubNameLabel.gameObject:SetActive(true)
			self.offClubNameLabel.gameObject:SetActive(false)
			self.clubNameLabel.text = clubMap[info["cid"]].cname
		end
		if (info["cfg"]["ishide"] == 1 or info.cfg.ishide == true) and clubMap[info["cid"]].ctype ~= 1 then
			self.ruleLabel.text = "[2D2862]"..info["homenickname"].."[-]"..nameExtStr
		else
			self.ruleLabel.text = "[2D2862]"..info["homenickname"].."[-]"
		end
		--self.isShowLabel.gameObject:SetActive((info["cfg"]["ishide"] == 1 or info.cfg.ishide == true) and clubMap[info["cid"]].ctype ~= 1)
	end
end

function HallClubRoomListItem:ShowClubNameLbl(state)
	self.clubNameLabel.gameObject:SetActive(state)
	self.offClubNameLabel.gameObject:SetActive(state)
end

return HallClubRoomListItem
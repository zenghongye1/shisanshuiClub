local base = require "logic/framework/ui/uibase/ui_view_base"
local ClubInfoItem = class("ClubInfoItem", base)
local UIManager = UI_Manager:Instance() 

function ClubInfoItem:InitView()
	self.nameLabel = self:GetComponent("name", typeof(UILabel))
	self.locationLabel = self:GetComponent("location", typeof(UILabel))
	self.numLabel = self:GetComponent("num", typeof(UILabel))
	self.gameLabel = self:GetComponent("game", typeof(UILabel))
	self.enterIconGo = self:GetGameObject("enterIcon")
	self.idLabel = self:GetComponent("id", typeof(UILabel))

	self.headTex = self:GetComponent("headIcon", typeof(UISprite))

	addClickCallbackSelf(self.gameObject, self.OnClick, self)
end

function ClubInfoItem:OnClick()
	if not model_manager:GetModel("ClubModel"):IsClubMember(self.clubInfo.cid) then
--		UIManager:ShowUiForms("ClubInfoUI", nil, nil, self.clubInfo)
	else
		model_manager:GetModel("ClubModel"):SetCurrentClubInfo(self.clubInfo, true)
		UIManager:GetUiFormsInShowList("hall_ui"):ShowClub()
		-- UIManager:CloseUiForms("ClubSelectUI")
	end
end

function ClubInfoItem:SetInfo(clubInfo, show)
	self.isHall = not show
	self.clubInfo = clubInfo
	self.nameLabel.text = clubInfo.cname
	if clubInfo.clubusernum == nil then
		clubInfo.clubusernum = 1
	end
	if clubInfo.maxusernum == nil then
		clubInfo.maxusernum = 99999
	end
	if show then
		if clubInfo.ctype == 1 then
			self.numLabel.text = clubInfo.clubusernum 
		else
			self.numLabel.text = clubInfo.clubusernum .. "/" ..clubInfo.maxusernum
		end
		self.locationLabel.text = "地区：" .. ClubUtil.GetLocationNameById(clubInfo.position)
		self.enterIconGo:SetActive(model_manager:GetModel("ClubModel"):IsClubMember(clubInfo.cid))
		self.idLabel.text = "ID:" .. clubInfo.shid
	else
		self.numLabel.text = clubInfo.clubusernum .. "/" .. clubInfo.maxusernum
		self.locationLabel.text = ClubUtil.GetLocationNameById(clubInfo.position)
	end
	
	--self.gameLabel.text = ClubUtil.FormatGameStr(ClubUtil.GetGameContent(clubInfo.gids, "/"), 10)
	self.gameLabel.text = ClubUtil.GetGameContent(clubInfo.gids, "/")
	
	self.headTex.spriteName = ClubUtil.GetClubIconName(clubInfo.icon)
end


return ClubInfoItem
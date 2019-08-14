local base = require "logic/framework/ui/uibase/ui_view_base"
local poker_result_item = class("poker_result_item", base)

function poker_result_item:InitView()
	self.texHead = self:GetComponent("picFrame","UITexture")
	self.nameLbl = self:GetComponent("namelbl","UILabel")
	self.idLbl = self:GetComponent("IDlbl","UILabel")
	self.roomMasterObj = self:GetGameObject("fangzhu")
	self.bigWinObj = self:GetGameObject("bigWin")
	
	self.specialShowObj = self:GetGameObject("specialShow")
	self.specialNameSp = self:GetComponent("specialShow/specialCard","UISprite")
	
	self.posScoreLbl = self:GetComponent("score/scorelbl","UILabel")
	self.negScoreLbl = self:GetComponent("score/negscorelbl","UILabel")
	
	self.pokerShowObj = self:GetGameObject("pokerShow")
end

function poker_result_item:SetItemInfo(chairID)
	local userData = room_usersdata_center.GetTempUserByLogicSeat(tonumber(player_seat_mgr.GetLogicSeatByStr(chairID)))
	self.nameLbl.text = userData["name"]
	HeadImageHelper.SetImage(self.texHead,2,userData["headurl"])
end

---显示最大牌型详情
function poker_result_item:ShowCardData(cardData,nSpecialType)
	local cardShow = require("logic/cardShow/poker_cardShow"):create(self.pokerShowObj.transform,cardData,nSpecialType)
	cardShow.isChip = roomdata_center.gamesetting["nBuyCode"] >= 1
	cardShow.scale = Vector3(0.38,0.40,0.40)
	cardShow.gridCellWidth = 50
	cardShow:SetShisanshuiCardShow()
end

---设置特殊牌型显示
function poker_result_item:SetSpecialShow(nSpecialType)
	if nSpecialType and nSpecialType ~= 0 then
		self.specialNameSp.spriteName = nSpecialType	
		self.specialNameSp.gameObject:SetActive(true)
		self.specialShowObj.gameObject:SetActive(true)
	else
		self.specialNameSp.gameObject:SetActive(false)
		self.specialShowObj.gameObject:SetActive(false)
	end
end

---设置分数显示
function poker_result_item:SetScoreShow(allScore)
	local totalScores = allScore or 0
	if totalScores <= 0 then
		self.negScoreLbl.gameObject:SetActive(true)
		self.posScoreLbl.gameObject:SetActive(false)
		self.negScoreLbl.text = tostring(totalScores)
	else
		self.negScoreLbl.gameObject:SetActive(false)
		self.posScoreLbl.gameObject:SetActive(true)
		self.posScoreLbl.text = "+"..tostring(totalScores)
	end
end

---设置房主标志
function poker_result_item:SetRoomer(uid)
	self.roomMasterObj.gameObject:SetActive(tonumber(uid) == tonumber(self.fangzhuId))
end

function poker_result_item:SetBigWin(state)
	self.bigWinObj.gameObject:SetActive(state)
end


return poker_result_item
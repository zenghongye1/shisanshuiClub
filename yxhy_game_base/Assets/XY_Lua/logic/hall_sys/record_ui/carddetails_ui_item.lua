local mahjongHelper = require "logic/mahjong_sys/utils/mahjongHelper"

local base = require "logic/framework/ui/uibase/ui_view_base"
local carddetails_ui_item = class("carddetails_ui_item",base)

function carddetails_ui_item:InitView()
	self.mainUI = nil
	self.opercardList = {}
	self.handcard=nil
	
	self.lab_name_lb = subComponentGet(self.transform,"headView/name","UILabel")
	self.head_tex = subComponentGet(self.transform,"headView/headIcon","UITexture")

	self.lab_score=child(self.transform,"infoView/scoreLabel")
	self.lab_score1=child(self.transform,"infoView/scoreLabel1")

	self.tran_zhuang = child(self.transform,"headView/zhuangIcon")
	self.winIconGo = self:GetGameObject("headView/huIcon")
	self.dianPaoGo = self:GetGameObject("infoView/dianpao")
	
	self.tran_itemList = child(self.transform,"infoView/itemList")
	self.contentLabel = subComponentGet(self.transform,"infoView/contentLabel","UILabel")
	
	self.tran_pokerShow = child(self.transform,"infoView/pokerShow")	
	self.tran_specialShow = child(self.transform,"infoView/specialShow")
		
	self.tran_lbl_nnType = child(self.transform,"infoView/lbl_nnType")
	self.tran_Sprite2 = child(self.transform,"infoView/bg/Sprite2")
	self.tran_Sprite1 = child(self.transform,"infoView/bg/Sprite1")
	
end

function carddetails_ui_item:SetHeadInfo(rewards)
			self.lab_name_lb.text=rewards.nickname
			local imagetype=rewards.img.type 
			local imageurl=rewards.img.url 
			HeadImageHelper.SetImage(self.head_tex,imagetype,imageurl)
end

function carddetails_ui_item:SetScore(score)
			local nScore = tonumber(score) or 0
			if nScore >=0 then
				self.lab_score.gameObject:SetActive(true)
				self.lab_score1.gameObject:SetActive(false)
			else
				self.lab_score.gameObject:SetActive(false)
				self.lab_score1.gameObject:SetActive(true)
			end
			
			if nScore >=0 then
				componentGet(self.lab_score.gameObject,"UILabel").text= "+"..nScore
			else
				componentGet(self.lab_score1.gameObject,"UILabel").text=tostring(nScore)
			end
end

function carddetails_ui_item:ShowMJ(info,scoreItem,specialCardValues,replaceSpecialCardValue,isPao,specialCardType)
	--self:ResetItemView()
	local isWin = table.getCount(info.win_card)>0
	--local root_tr = child(self.transform,"infoView/itemList")
	self.tran_itemList.gameObject:SetActive(true)
	local handCards = mahjongHelper:GetMJHandCard(info.cards,info.win_card[1],specialCardValues,replaceSpecialCardValue)
	local valueList = mahjongHelper:GetOperValueList(info.combineTile,specialCardValues,replaceSpecialCardValue)

	if self.winIconGo ~= nil then
		self.winIconGo:SetActive(info.win_card[1]~=nil)
	end

	local distance = 151
	for i=1,#self.opercardList do
		self.mainUI:RecycleOperCard(self.opercardList[i])
	end
	self.opercardList = {}
	for i=1,#valueList do
		local operItem = self.mainUI:GetOperCard()
		operItem:SetActive(true)
		operItem.transform.parent = self.tran_itemList
		operItem.transform.localPosition = Vector3((i-1)*distance,0,0)
		operItem.transform.localScale = Vector3.one
		operItem:SetInfo(valueList[i],specialCardValues,specialCardType)
		table.insert(self.opercardList,operItem)
	end
	if self.handcard==nil or IsNil(self.handcard.gameObject) then
		self.handcard = self.mainUI:GetHandCard()
		self.handcard:SetActive(true)
	end
	self.handcard.transform.parent = self.tran_itemList
	self.handcard.transform.localPosition = Vector3((#valueList)*distance,0,0)
	self.handcard.transform.localScale = Vector3.one
	self.handcard:SetInfo(handCards,isWin,specialCardValues,specialCardType)

	if scoreItem then
		 self.contentLabel.gameObject:SetActive(true)
		self:SetContent(scoreItem)
	else
		self.contentLabel.gameObject:SetActive(false)
	end
	if self.dianPaoGo then
		self.dianPaoGo:SetActive(isPao == true)
	end
end

function carddetails_ui_item:SetContent(scoreItem)
	local content = ""
	for i=1,#scoreItem do
		if scoreItem[i].des then
			content = content..scoreItem[i].des
		end
		if scoreItem[i].num then
			content = content..scoreItem[i].num
		end
		if i~= #scoreItem then
			content = content.."  "
		end
	end
	self.contentLabel.text = content
end

function carddetails_ui_item:ShowSSS(t)
	--logError(GetTblData(t))
	self.tran_pokerShow.gameObject:SetActive(true)
	self.tran_pokerShow.localPosition = Vector3(-195,-168,0)
	if t["nSpecialType"] > 0 then
		self.tran_specialShow.gameObject:SetActive(true)
		componentGet(child(self.tran_specialShow,"specialCard"),"UISprite").spriteName = t["nSpecialType"]
	end
	
	local poker_cardShow = require("logic/cardShow/poker_cardShow"):create(self.tran_pokerShow,t["stCards"],t.nSpecialType)
	poker_cardShow.updateDepth = 12
	poker_cardShow.gridCellWidth = 55
	poker_cardShow:SetShisanshuiCardShow()
end

function carddetails_ui_item:ShowNiuNiu(t,gid)
	--logError(GetTblData(t))
	self.tran_Sprite2.gameObject:SetActive(true)
	self.tran_Sprite1.gameObject:SetActive(true)
	self.tran_lbl_nnType.gameObject:SetActive(true)
	if gid == ENUM_GAME_TYPE.TYPE_NIUNIU then
		require("logic/niuniu_sys/other/niuniu_rule_define")
		componentGet(self.tran_lbl_nnType.gameObject,"UILabel").text = niuniu_rule_define.PT_BULL_Text[t["nCardType"]].."  X"..t["nBeishu"]
	elseif gid == ENUM_GAME_TYPE.TYPE_SANGONG then
		require("logic/poker_sys/sangong_sys/other/sangong_rule_define")
		componentGet(self.tran_lbl_nnType.gameObject,"UILabel").text = (sangong_rule_define.PT_SANGONG_Text[t["nCardType"]] or "").."  X"..(t["nBeishu"] or "")
	elseif gid == ENUM_GAME_TYPE.TYPE_YINGSANZHANG then
		require "logic/poker_sys/yingsanzhang_sys/other/yingsanzhang_rule_define"
		componentGet(self.tran_lbl_nnType.gameObject,"UILabel").text = yingsanzhang_rule_define.PT_YINGSANZHANG_CardText[t["nCardType"]] or ""
	end

	self.tran_pokerShow.gameObject:SetActive(true)
	self.tran_pokerShow.localPosition = Vector3(-80,-168,0)
	local poker_cardShow = require("logic/cardShow/poker_cardShow"):create(self.tran_pokerShow,t["stCards"],t.nCardType)
	poker_cardShow.updateDepth = 12
	poker_cardShow.gridCellWidth = 55
	poker_cardShow:SetNiuNiuCardShow()
end

function carddetails_ui_item:ShowYingSanZhang(t,gid)
	--logError(GetTblData(t))
	self.tran_Sprite2.gameObject:SetActive(true)
	self.tran_Sprite1.gameObject:SetActive(true)
	self.tran_lbl_nnType.gameObject:SetActive(true)
	require "logic/poker_sys/yingsanzhang_sys/other/yingsanzhang_rule_define"
	local logicNum = tonumber(string.sub(t["_chair"],2,2))
	componentGet(self.tran_lbl_nnType.gameObject,"UILabel").text = yingsanzhang_rule_define.PT_YINGSANZHANG_CardText[t["stAllUserDatas"][logicNum]["nCardType"]] or ""

	self.tran_pokerShow.gameObject:SetActive(true)
	self.tran_pokerShow.localPosition = Vector3(-80,-168,0)
	local poker_cardShow = require("logic/cardShow/poker_cardShow"):create(self.tran_pokerShow,t["stAllUserDatas"][logicNum]["stCards"],t.nCardType)
	poker_cardShow.updateDepth = 12
	poker_cardShow.gridCellWidth = 55
	poker_cardShow:SetNiuNiuCardShow()
end

function carddetails_ui_item:ResetItemView()
	self.tran_Sprite2.gameObject:SetActive(false)
	self.tran_Sprite1.gameObject:SetActive(false)
	self.tran_lbl_nnType.gameObject:SetActive(false)
	self.tran_specialShow.gameObject:SetActive(false)
	self.tran_pokerShow.gameObject:SetActive(false)
	self.tran_itemList.gameObject:SetActive(false)
	self.tran_zhuang.gameObject:SetActive(false)
	self.contentLabel.gameObject:SetActive(false)
	self.winIconGo.gameObject:SetActive(false)
	self.dianPaoGo.gameObject:SetActive(false)
end

return carddetails_ui_item
local base = require "logic/mahjong_sys/ui_mahjong/reward/ui_view_base"
local reward_info_view = class("reward_info_view", base)

function reward_info_view:InitView()
	self.scoreLabel = self:GetComponent("scoreLabel", typeof(UILabel))
	-- 荒庄要使用黄色字， scoreLabel存黄色字体 @todo  动态load字体
	self.scoreLabel1 = self:GetComponent("scoreLabel1", typeof(UILabel))

	self.contentLabel = self:GetComponent("contentLabel", typeof(UILabel))
	self.bgTr = self:GetGameObject("bg").transform
	self.itemList_Tr = self:GetGameObject("itemList").transform
	self.selectIconGo = self:GetGameObject("selectIcon")
	self.opercardList = {}
	self.handcard = nil
	self.selectIconGo:SetActive(false)
end

function reward_info_view:SetInfo(info,isWin, viewSeat)
	local scoreLabel = self:GetScoreLabel(info.point)
	scoreLabel.text = self:GetPoint(info.point)
	self:SetContent(info)
	self:SetMahjongList(info,isWin)
	self.selectIconGo:SetActive(viewSeat == 1)
end

function reward_info_view:GetScoreLabel(point)
	-- 第一个item没有label1
	if self.scoreLabel1 == nil then
		return self.scoreLabel
	end
	self.scoreLabel.gameObject:SetActive(point ~= 0)
	self.scoreLabel1.gameObject:SetActive(point == 0)
	if point == 0 then
		return self.scoreLabel1 
	else
		return self.scoreLabel
	end
end

function reward_info_view:GetPoint(point)
	local point = tonumber(point)
	if point == 0 then
		return point
	elseif point > 0 then
		return "+" .. point 
	else
		return tostring(point)
	end
end

function reward_info_view:SetContent(info)
	local content = ""
	for i=1,#info.scoreItem do
		content = content..info.scoreItem[i].des..info.scoreItem[i].num.."  "
	end
	self.contentLabel.text = content
end

function reward_info_view:SetMahjongList(info,isWin)
	local distance = 151
	for i=1,#self.opercardList do
		mahjong_small_reward_ui.RecycleOperCard(self.opercardList[i])
	end
	self.opercardList = {}
	for i=1,#info.combineTile do
		local operItem = mahjong_small_reward_ui.GetOperCard()
		operItem:SetActive(true)
		operItem.transform.parent = self.itemList_Tr
		operItem.transform.localPosition = Vector3((i-1)*distance,0,0)
		operItem.transform.localScale = Vector3.one
		operItem:SetInfo(info.combineTile[i],roomdata_center.specialCard) -- 金的值，待优化
		table.insert(self.opercardList,operItem)
	end
	if self.handcard==nil or IsNil(self.handcard.gameObject) then
		self.handcard = mahjong_small_reward_ui.GetHandCard()
		self.handcard:SetActive(true)
	end
	self.handcard.transform.parent = self.itemList_Tr
	self.handcard.transform.localPosition = Vector3((#info.combineTile)*distance,0,0)
	self.handcard.transform.localScale = Vector3.one
	self.handcard:SetInfo(info.cards,isWin,roomdata_center.specialCard) -- 金的值，待优化
end

function reward_info_view:GetSelfIconPosition()
	return self.bgTr.position
end

return reward_info_view
local base = require "logic/framework/ui/uibase/ui_view_base"
local reward_info_view = class("reward_info_view", base)
local reward_mahjongCard_view = require "logic/mahjong_sys/ui_mahjong/reward/reward_mahjongCard_view"
local mahjong_flowercard_view = require "logic/mahjong_sys/ui_mahjong/reward/mahjong_flowercard_view"
local mjItem_view = require "logic/mahjong_sys/ui_mahjong/reward/reward_mjItem_view"

function reward_info_view:InitView()
	self.scoreLabel = self:GetComponent("scoreLabel", typeof(UILabel))
	-- 荒庄要使用黄色字， scoreLabel存黄色字体 @todo  动态load字体
	self.scoreLabel1 = self:GetComponent("scoreLabel1", typeof(UILabel))

	self.panLabel = self:GetComponent("pan",typeof(UILabel))
	self.panLabel.gameObject:SetActive(false)
	self.contentLabel = self:GetComponent("contentLabel", typeof(UILabel))
	self.bgTr = self:GetGameObject("bg").transform
	self.itemList_Go = self:GetGameObject("itemList")
	self.mahjongCard = reward_mahjongCard_view:create(self.itemList_Go)
	--self.selectIconGo = self:GetGameObject("selectIcon")
	--self.selectIconGo:SetActive(false)
	self.dianPaoGo = self:GetGameObject("dianpao")
	-- type 2
	self.flowerItemListGo = self:GetGameObject("flowerItemList")
	if self.flowerItemListGo then
		self.flowercard = mahjong_flowercard_view:create(self.flowerItemListGo)
	end
	-- type 3
	self.specialFlowerGo = self:GetGameObject("specialFlower")
	if self.specialFlowerGo then
		local go = self:GetGameObject("specialFlower/item")
		self.specialFlowerItem = mjItem_view:create(go)
		self.specialFlowerLabel = self:GetComponent("specialFlower/num", typeof(UILabel))
		self.specialFlowerGo:SetActive(false)
	end
end

function reward_info_view:SetInfo(info,isWin, viewSeat,specialCardValues,specialCardType,ui)
	local scoreLabel = self:GetScoreLabel(info.totalScore)
	scoreLabel.text = self:GetPoint(info.totalScore)
	self:SetContent(info)
	self.mahjongCard:SetMahjongList(info,isWin,specialCardValues,specialCardType,ui)
	--self.selectIconGo:SetActive(viewSeat == 1)
	self:SetDianPao(info.nJiePao)
	if info.flowers then
		self:SetFlowers(info.flowers)
	end
	if info.specialFlower then
		self:SetSpecialFlower(info.specialFlower)
	elseif self.specialFlowerGo then
		self.specialFlowerGo:SetActive(false)
	end 
end

function reward_info_view:SetSpecialFlower(specialFlower)
	self.specialFlowerItem:SetValue(specialFlower[1])
	self.specialFlowerLabel.text = "X"..specialFlower[2]
	self.specialFlowerGo:SetActive(true)
end

function reward_info_view:SetFlowers(flowers)
	self.flowercard:SetActive(true)
	self.flowercard:SetInfo(flowers)
end

function reward_info_view:SetDianPao(nJiePao)
	if self.dianPaoGo and nJiePao and nJiePao == 1 then
		self.dianPaoGo:SetActive(true)
	else
		self.dianPaoGo:SetActive(false)
	end
end

function reward_info_view:SetPan(num)
	if self.panLabel~=nil then
		self.panLabel.text = tostring(num)
		self.panLabel.gameObject:SetActive(true)
	end
end

function reward_info_view:GetScoreLabel(point)
	-- 第一个item没有label1
	if self.scoreLabel1 == nil then
		return self.scoreLabel
	end
	local isWin = false
	if point and point > 0 then
		isWin = true
	end
	self.scoreLabel.gameObject:SetActive(isWin)
	self.scoreLabel1.gameObject:SetActive(not isWin)
	if isWin then
		return self.scoreLabel 
	else
		return self.scoreLabel1
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
		if info.scoreItem[i].des then
			content = content..info.scoreItem[i].des
		end
		if info.scoreItem[i].num then
			content = content..info.scoreItem[i].num
		end
		if i~= #info.scoreItem then
			content = content.."  "
		end
	end
	self.contentLabel.text = content
end



function reward_info_view:GetSelfIconPosition()
	return self.bgTr.position
end

function reward_info_view:Clear()
	if self.flowercard then
		self.flowercard:Clear()
	end
end

return reward_info_view
local base = require "logic/framework/ui/uibase/ui_view_base"
local bigSettlement_ui_item = class("bigSettlement_ui_item", base)

function bigSettlement_ui_item:InitView()
	self.tHead_tex = self:GetComponent("Sprite/head","UITexture")
	self.name_label = self:GetComponent("name","UILabel")
	self.id_label = self:GetComponent("id","UILabel")
	self.scrollView_tr = child(self.transform,"scoreScrollView")
	self.grid_tr = child(self.transform,"scoreScrollView/grid")
	self.scoreBG_sprite = self:GetComponent("scoreBG","UISprite")
	self.scoreItem = self:GetGameObject("scoreScrollView/grid/item1")
	self.scoreItem:SetActive(false)
	self.score_add_label = self:GetComponent("score/add","UILabel")
	self.score_sub_label = self:GetComponent("score/sub","UILabel")
	self.bigWin_go = self:GetGameObject("bigWin")
	if self.bigWin_go then
		self.bigWin_go:SetActive(false)
	end
	self.bigLoser_go = self:GetGameObject("bigLoser")
	if self.bigLoser_go then
		self.bigLoser_go:SetActive(false)
	end
	self.fangzhu_go =self:GetGameObject("fangzhu")
	if self.fangzhu_go then
		self.fangzhu_go:SetActive(false)
	end
	self.line_go = self:GetGameObject("line")
	self.line_go:SetActive(false)

	self.lineSpriteList = {}
	self.infoList = {}
end

function bigSettlement_ui_item:Show(playerData)
	local userData = playerData.userData
	local headurl = userData.headurl
	local imagetype = userData.imagetype
	local name = userData.name
	local uid = userData.uid
	local isWin = playerData.isWin
	local isRich = playerData.isRich
	local isRoomOwner = playerData.isRoomOwner
	local all_score = playerData.all_score
	local tList = playerData.tList

	HeadImageHelper.SetImage(self.tHead_tex,imagetype,headurl)

	self.name_label.text = name
	self.id_label.text = "ID:"..tostring(uid)

	if all_score > 0 then
   		self.score_add_label.gameObject:SetActive(true)
   		self.score_sub_label.gameObject:SetActive(false)
   		self.score_add_label.text = "+"..tostring(all_score)
   	else
   		self.score_add_label.gameObject:SetActive(false)
   		self.score_sub_label.gameObject:SetActive(true)
   		self.score_sub_label.text = tostring(all_score)
   	end

   	--self:SetInfoBgSize((#tList == 0 and 1) or #tList)
   	self:SetPlayGameInfo(tList)
   	if self.bigWin_go and isWin then
   		self.bigWin_go:SetActive(true)
   	else
   		self.bigWin_go:SetActive(false)
   	end
   	if self.bigLoser_go and isRich then
   		self.bigLoser_go:SetActive(true)
   	else
   		self.bigLoser_go:SetActive(false)
   	end
   	if self.fangzhu_go and isRoomOwner then
   		self.fangzhu_go:SetActive(true)
   	else
   		self.fangzhu_go:SetActive(false)
   	end
end

function bigSettlement_ui_item:SetPlayGameInfo(tList)
	for i,v in ipairs(tList) do
		local good
		if #self.infoList < i then
			if i == 1 then
				good = self.scoreItem.gameObject
			else
			    good = newobject(self.scoreItem.gameObject)
			    good.transform:SetParent(self.grid_tr)
	            good.name="item"..tostring(i)
	            good.transform.localScale={x=1,y=1,z=1}   
			end
		   	table.insert(self.infoList,good)
		else
			good = self.infoList[i]
		end
		good.gameObject:SetActive(true)
	   	local infoNameLabel = subComponentGet(good.transform,"name","UILabel")
	   	infoNameLabel.text = v.name
	   	local infoNumLabel = subComponentGet(good.transform,"num","UILabel")
	   	infoNumLabel.text = v.num
	   	if i > 0 then
			if i>#self.lineSpriteList then
				local lineObj = newobject(self.line_go)
				lineObj.transform:SetParent(self.scrollView_tr,false)
				lineObj.transform.localPosition = Vector3(0,144-(i*51),0) 
				table.insert(self.lineSpriteList,lineObj)
			end
			self.lineSpriteList[i]:SetActive(true)
		end
	end

	for i=#tList + 1,#self.infoList do
		self.infoList[i]:SetActive(false)
		if i<=#self.lineSpriteList and i > 0 then
			self.lineSpriteList[i]:SetActive(false)
		end
	end
	componentGet(self.grid_tr,"UIGrid"):Reposition() 
end

function bigSettlement_ui_item:SetInfoBgSize(length)
	self.scoreBG_sprite.height = 49*length
end

return bigSettlement_ui_item
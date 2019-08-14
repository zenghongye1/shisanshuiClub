require "logic/shisangshui_sys/resMgr_component"

local player_component = class("player_component")

function player_component:ctor(obj)
	self.playerObj = obj 
	self.viewSeat = -1		
	self.CardList = {}			
	self.compareResult = {} 
	self.compareScores = {}
	--self.base_init = self.Initialize
	self.Group1 = nil
	self.Group2 = nil
	self.Group3 = nil
	self.resMgrComponet = nil
	self.CardOrgineTrans = {}
	self.usersdata = nil
	self.cardCount = 13
	self.pokerPool = nil
end

function player_component:InitCard()
	local cards = self.playerObj.transform:GetComponentsInChildren(typeof(UnityEngine.BoxCollider))
	if cards ~= nil then
		for j = 0, cards.Length -1 do
			local cardObj = cards[j]
			table.insert(self.CardList,cardObj)
		
			local cardPosition = cardObj.transform.localPosition
			local cardRotation = cardObj.transform.localRotation
			local cardScale = cardObj.transform.localScale
			local cardTrans = {}
			cardTrans.cardPosition = cardPosition
			cardTrans.cardRotation = cardRotation
			cardTrans.cardScale = cardScale
			table.insert(self.CardOrgineTrans,cardTrans)
		end
	end
end
	
--翻牌
function player_component:PlayerGroupCard(group)
	local groupTrans =	self.playerObj.transform:FindChild(group)
	
	local cardsBoxColider = groupTrans.transform:GetComponentsInChildren(typeof(UnityEngine.BoxCollider))
	for j = 0, cardsBoxColider.Length -1 do	
		local cardObj = cardsBoxColider[j]
		self:SetMaPaiMaterial(cardsBoxColider[j].transform)
		local y = cardObj.transform.localRotation.eulerAngles.y
		cardObj.transform:DOLocalRotate(Vector3(0, y, 0), 0.05, DG.Tweening.RotateMode.Fast)
	
	end
end
	
function player_component:SetMaPaiMaterial(tran)
	if roomdata_center.gamesetting["nBuyCode"] > 0 and tran.name == tostring(card_define.GetCodeCard()).."(Clone)" then	

		local rotationZ = tran.localRotation.eulerAngles.z
		local dipai = child(tran,"dipai")
		local meshRender = componentGet(dipai,"MeshRenderer")
		local originMatInfo = {}
		originMatInfo.meshRender = meshRender
		originMatInfo.sharedMaterial = meshRender.sharedMaterial
		codeMaterial = originMatInfo
		if meshRender ~= nil then
			local highLightMatTbl = self.resMgrComponet.GetHighLightMat()
			LuaHelper.AddMatToMeshRenderer(meshRender, highLightMatTbl.mat1, highLightMatTbl.mat2)					 
		end
	end
	
end

--获取第一墩牌
function player_component:showFirstCardByType()
	local dataTable = {}
	local cardTable = {}
	local cardType = self.compareResult["nFirstType"]
	if tonumber(cardType) > 0 then
		local stCards = self.compareResult["stCards"]
		if stCards == nil or #stCards < 1 then return end
		for i = 1 ,#stCards do
			if i > 10 and i < 14 then
				table.insert(cardTable,stCards[i])
			end
		end
		dataTable.cardTable = cardTable
		dataTable.type = cardType
		dataTable.chairid = self.viewSeat
		dataTable.index = 1
		local position = self.playerObj.transform:FindChild("2d_card_point").transform.position
		dataTable.nguiPosition = Utils.WorldPosToScreenPos(position)
		return dataTable
	end
end

--获取第二墩牌
function player_component:showSecondCardByType()
	local dataTable = {}
	local cardTable = {}
	local cardType = self.compareResult["nSecondType"]
	if tonumber(cardType) > 0 then
		local stCards = self.compareResult["stCards"]
		if stCards == nil or #stCards < 1 then return end
		for i = 1 ,#stCards do
			if i > 5 and i < 11 then
				table.insert(cardTable,stCards[i])
			end
		end
		dataTable.cardTable = cardTable
		dataTable.type = cardType
		dataTable.chairid = self.viewSeat
		dataTable.index = 2
		local position = self.playerObj.transform:FindChild("2d_card_point").transform.position
		dataTable.nguiPosition = Utils.WorldPosToScreenPos(position)
		return dataTable
	end
end

--获取第三墩牌
function player_component:showThreeCardByType()
	local dataTable = {}
	local cardTable = {}
	local cardType = self.compareResult["nThirdType"]
	if tonumber(cardType) > 0 then
		local stCards = self.compareResult["stCards"]
		if stCards == nil or #stCards < 1 then return end
		for i = 1 ,#stCards do
			if i > 0 and i < 6 then
				table.insert(cardTable,stCards[i])
			end
		end
		dataTable.cardTable = cardTable
		dataTable.type = cardType
		dataTable.chairid = self.viewSeat
		dataTable.index = 3
		local position = self.playerObj.transform:FindChild("2d_card_point").transform.position
		dataTable.nguiPosition = Utils.WorldPosToScreenPos(position)
		return dataTable
	end
end

--设置材质
function player_component:SetCardMesh(cards)	
	if self.compareResult == nil then
		logError("player_component -> SetCard Mesh Error")
	end
	local stCards = cards
	if cards == nil then
		stCards = self.compareResult["stCards"]
		if stCards == nil or #stCards < 1 then return end
	end
	local newCardList = {}
	local cacheCards = self.pokerPool:GetCard(self.viewSeat,stCards)
	for i,card in ipairs(cacheCards) do
		card.transform.position = self.CardList[i].transform.position
		card.transform.localScale = self.CardList[i].transform.localScale
		card.transform.localRotation = self.CardList[i].transform.localRotation
		card.transform.parent = self.CardList[i].transform.parent
		card.gameObject:SetActive(true)
		table.insert(newCardList,card)
		local rotationZ = card.transform.localEulerAngles.z
		if rotationZ  > -1 and rotationZ < 1 then
			self:SetMaPaiMaterial(card.transform)
		end
	end
	self.pokerPool:Recycle(self.CardList)
	self.CardList = {}
	self.CardList = newCardList
	
end
	
--理牌
function player_component:shuffle(isPlaySound,callback)
	local xoffset = -13 /4
	local yoffset = 0
	for k,cardObj in pairs(self.CardList) do
		cardObj.transform.parent.parent = self.playerObj.transform
		cardObj.transform.parent.localPosition = Vector3(xoffset,yoffset,0)
		cardObj.transform.parent.localEulerAngles = Vector3(0,0,0)
		cardObj.transform.localPosition = Vector3(0,0,0)
		cardObj.transform.localEulerAngles = Vector3(0,180,180)
		cardObj.gameObject:SetActive(false)
		xoffset = xoffset + 0.5
		yoffset = yoffset + 0.01
		self:ReSetMaPaiMaterial(cardObj.transform)
	end
	
	coroutine.start(function()
		for k,vv in pairs(self.CardList) do
			if isPlaySound then
				ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/fapai_zhankai")  ----发牌音效
			end
			vv.gameObject:SetActive(true)
			coroutine.wait(0.005)
		end

		if callback ~= nil then 
			callback()
		end	
	end)
end
	
function player_component:ShowAllCard(rotateZ)
	self:CardRest(self.CardOrgineTrans)
	rotateZ = tonumber(rotateZ)
	local group3 = self.playerObj.transform:FindChild("Group3")
	self:ShowCardShanXing(group3,1,rotateZ)
	local group2 = self.playerObj.transform:FindChild("Group2")
	self:ShowCardShanXing(group2,6,rotateZ)
	local group1 = self.playerObj.transform:FindChild("Group1")
	self:ShowCardShanXing(group1,11,rotateZ)
end

---重置马牌材质
function player_component:ReSetMaPaiMaterial(tran)
	if roomdata_center.gamesetting["nBuyCode"] > 0 then	
		local dipai = child(tran,"dipai")	
		local meshRender = componentGet(dipai.transform, "MeshRenderer")
		
		local originMatInfo = {}
		originMatInfo.meshRender = meshRender
		originMatInfo.sharedMaterial = meshRender.sharedMaterial
		codeMaterial = originMatInfo		
		if meshRender ~= nil then
			local OriginalMat = self.resMgrComponet.GetOriginalMat()
			LuaHelper.AddMatToMeshRenderer(meshRender,OriginalMat.mat1,nil)					 
		end
	end 
end
	
--理牌动画
function player_component:ShowCardShanXing(parentObj,index,rotateZ)
	local count  = index + 4
	if index == 11 then
		 count  = index + 2
	end
	
	for i = index ,count do
		local obj = self.CardList[i]
		parentObj.transform.localPosition = Vector3(0,0,0)
		obj.transform.parent.localPosition = Vector3(0,0,0)
		
		obj.transform.parent.parent = parentObj.transform
		local x = obj.transform.localRotation.eulerAngles.x
		local y = obj.transform.localRotation.eulerAngles.y
		local z = obj.transform.localRotation.eulerAngles.z
		obj.transform.localEulerAngles = Vector3(x,y,rotateZ)
		if rotateZ == 0 and self.viewSeat == 1 then	
			self:SetMaPaiMaterial(obj.transform) 	--判断马牌
		end
		if rotateZ == 180 and self.viewSeat == 1 then
			self:ReSetMaPaiMaterial(obj.transform)
		end
	end 
end

--玩家重置
function player_component:PlayerReset()
	self.playerObj:SetActive(false)
	self.compareResult = {}
end

--牌重置
function player_component:CardRest(transform)
	for i = 1,#self.CardList do
		local trans = transform[i]
		local card = self.CardList[i]
		card.transform.localPosition = trans.cardPosition
		card.transform.localRotation = trans.cardRotation
		card.transform.localScale = trans.cardScale
	end
end
	
--找到牌桌上的马牌
function player_component:GetCodeCardTran(group)
	local codeList = {}
	if roomdata_center.gamesetting["nBuyCode"] > 0 then 		---马牌模式
		local groupTrans =	self.playerObj.transform:FindChild(group)
		local cardsBoxColider = groupTrans.transform:GetComponentsInChildren(typeof(UnityEngine.BoxCollider))
		for j = 0, cardsBoxColider.Length -1 do	
			local cardObj = cardsBoxColider[j]
			if cardObj.name == tostring(card_define.GetCodeCard()).."(Clone)"  then
				table.insert(codeList,cardsBoxColider[j].transform)
			end
		end
	end
	return codeList
end
	
--只用于获取自己三墩各自中心的屏幕坐标
function player_component:GetCardGroupScreenPos()
	---找到中间牌的pos
	local group3 = self.playerObj.transform:FindChild("Group3"):FindChild("Card3"):GetComponentInChildren(typeof(UnityEngine.BoxCollider))
	local group2 = self.playerObj.transform:FindChild("Group2"):FindChild("Card3"):GetComponentInChildren(typeof(UnityEngine.BoxCollider))
	local group1 = self.playerObj.transform:FindChild("Group1"):FindChild("Card2"):GetComponentInChildren(typeof(UnityEngine.BoxCollider))
	local screenPos3 =  Utils.WorldPosToScreenPos(group3.gameObject.transform.position)
	local screenPos2 =  Utils.WorldPosToScreenPos(group2.gameObject.transform.position)
	local screenPos1 =  Utils.WorldPosToScreenPos(group1.gameObject.transform.position)
	local playerGroupPos = {}
	table.insert(playerGroupPos,screenPos1)
	table.insert(playerGroupPos,screenPos2)
	table.insert(playerGroupPos,screenPos3)
	return playerGroupPos
end
	
--choose_ok设置自己牌
function player_component:SetSelfCardMesh(cards)
	local stCards = cards
	if cards == nil then
		local chooseCards = card_data_manage.chooseCardsTbl
		stCards = chooseCards
		if stCards == nil or #stCards < 1 then 
			logError("choose_ok设置自己牌为空")
			return 
		end
	end
	
	local newCardList = {}
	local cacheCards = self.pokerPool:GetCard(self.viewSeat,stCards)
	for i,card in ipairs(cacheCards) do
		card.transform.position = self.CardList[i].transform.position
		card.transform.localScale = self.CardList[i].transform.localScale
		card.transform.localRotation = self.CardList[i].transform.localRotation
		card.transform.parent = self.CardList[i].transform.parent
		card.gameObject:SetActive(true)
		table.insert(newCardList,card)
	end
	for i,v in ipairs(self.CardList) do 
		if v ~= nil then
			v.gameObject.transform.parent = nil
			v.gameObject:SetActive(false)
		end
	end
	self.CardList = {}
	self.CardList = newCardList	
end
	
return player_component



local yingsanzhang_player_component = class("yingsanzhang_player_component")

function yingsanzhang_player_component:ctor(obj)
	self.gameObject = obj
	self.viewSeat = -1
	self.cardList = {}
	self.cardListPosition = {}
	self.cardListlocalScale = {}
	self.cardListlocalRotation = {}
	self.cardCount = 3
	self.isPlayAnimationed = true
	self.isPlaySpecialCardAnimitoned = true
	self.groupTrans = nil
	self.isPlaceCard = false
	self.interval = 1
	self.showCardSpeed = 0.3
	self.pokerPool = nil
	self:InitCard()
	self.isPokerGray = false
end

function yingsanzhang_player_component:InitCard()
	self.groupTrans = self.gameObject.transform:FindChild("Group")
	for i = 1 ,self.cardCount do
		local card = self.groupTrans.transform:FindChild("Card"..tostring(i).."/2")
		if card == nil then
			logError("找不到手牌对象："..tostring(i)..tostring(self.viewSeat))
			break
		end
		table.insert(self.cardList,card)
		table.insert(self.cardListPosition,card.transform.position)
		table.insert(self.cardListlocalRotation,card.transform.localRotation)
		table.insert(self.cardListlocalScale,card.transform.localScale)
	end
	self.nornalMat = newNormalObjSync(data_center.GetResPokerCommPath().."/materials/dipai", typeof(UnityEngine.Material))
    self.grayMat = newNormalObjSync(data_center.GetResPokerCommPath().."/materials/poker_disable",typeof(UnityEngine.Material))
end

function yingsanzhang_player_component:SetShufflePosition(tableCenterTrans)
	for k,cardObj in pairs(self.cardList) do
		cardObj.transform.position = tableCenterTrans.position
		local a1 = cardObj.transform.localPosition.y + self.viewSeat *(0.01)
		local y_value = a1 + (k-1)*0.05 --等差数列公式
--		logError("ViewSeate:"..tostring(self.viewSeat).." index:"..tostring(k).." y_value:"..tostring(y_value))
		local localPosition = cardObj.transform.localPosition
		cardObj.transform.localPosition = Vector3(localPosition.x,localPosition.y - y_value,localPosition.z)
		cardObj.gameObject:SetActive(true)
		if self.viewSeat == 1 then
			cardObj.transform.localScale = Vector3(0,0,0)
		else
			cardObj.transform.localScale = Vector3(0.4,0.4,0.4)
		end
	end
end

--理牌
function yingsanzhang_player_component:shuffle(tableCenterTrans,index)
	coroutine.start(function() 
		local cardObj = self.cardList[index]
		cardObj.transform:DOMove(self.cardListPosition[index],0.2,false)
		if self.viewSeat == 1 then
			cardObj.transform:DOScale(Vector3(1.68,1,1.68),0.2)
		else
			cardObj.transform:DOScale(Vector3(1.3,1,1.3),0.2)
		end
	end)
end

function yingsanzhang_player_component:SetCardMesh(stCards)
	if stCards == nil or #stCards < 1 then return end
	local newCardList = {}
	if table.nums(stCards) == self.cardCount -1 then
		table.insert(stCards,2)
	end
	local cards = self.pokerPool:GetCard(self.viewSeat,stCards)
	for i,card in ipairs(cards) do
		card.transform.position = self.cardList[i].transform.position
		card.transform.localScale = self.cardList[i].transform.localScale
		card.transform.localRotation = self.cardList[i].transform.localRotation
		card.transform.parent = self.cardList[i].transform.parent
		local meshRenderer = subComponentGet(card.transform,"dipai",typeof(UnityEngine.MeshRenderer))
		meshRenderer.sharedMaterial = self.isPokerGray and self.grayMat or self.nornalMat
		card.gameObject:SetActive(true)
		table.insert(newCardList,card)
	end
	self.pokerPool:Recycle(self.cardList)
	self.cardList = {}
	self.cardList = newCardList
end

function yingsanzhang_player_component:ShowCard(callback)
	for i ,v in ipairs(self.cardList) do
		v.gameObject:SetActive(true)
		coroutine.start(function() 
			local y = v.transform.localRotation.eulerAngles.y
			v.transform:DOLocalRotate(Vector3(0, y, -0.5), self.showCardSpeed, DG.Tweening.RotateMode.Fast)
			coroutine.wait(self.showCardSpeed-0.1)
		end)
	end
	if callback then
		callback()
	end
end

function yingsanzhang_player_component:DisableDisplayCard()
	self.gameObject:SetActive(true)
	for i ,v in ipairs(self.cardList) do
		v.gameObject:SetActive(true)
		local y = v.transform.localRotation.eulerAngles.y
		v.transform:DOLocalRotate(Vector3(0, y, -180), 0.01, DG.Tweening.RotateMode.Fast)	
	end
end

--扑克置灰
function yingsanzhang_player_component:SetPokerGray(state,force)
	if self.isPokerGray == state and not force then
        return
    end
    self.isPokerGray = state
	for i ,v in ipairs(self.cardList) do
		local meshRenderer = subComponentGet(v.transform,"dipai",typeof(UnityEngine.MeshRenderer))
		meshRenderer.sharedMaterial = self.isPokerGray and self.grayMat or self.nornalMat
	end
end

function yingsanzhang_player_component:GetLastCardPosition()
	Trace("elf.groupTrans.transform:"..self.groupTrans.name.."  parent:"..self.groupTrans.parent.name)
	local card = self.groupTrans.transform:FindChild("Card3"):GetComponentInChildren(typeof(UnityEngine.BoxCollider))
	return card.gameObject
end

function yingsanzhang_player_component:PlayerReset()
	for i ,v in ipairs(self.cardList) do
		v.transform.position = self.cardListPosition[i]
		local y = v.transform.localRotation.eulerAngles.y
		v.transform:DOLocalRotate(Vector3(0, 180, -180), 0.01, DG.Tweening.RotateMode.Fast)
	end
	self.isPlayAnimationed = true
	self.isPlaySpecialCardAnimitoned = true
	self:SetPokerGray(false,true)
	self.gameObject:SetActive(false)
end

function yingsanzhang_player_component:SyncReset()
	for i ,v in ipairs(self.cardList) do
		v.transform.position = self.cardListPosition[i]
		v.transform.localScale = self.cardListlocalScale[i]
	end
end

return yingsanzhang_player_component
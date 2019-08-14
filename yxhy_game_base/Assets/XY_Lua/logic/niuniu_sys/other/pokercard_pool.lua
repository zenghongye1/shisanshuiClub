local pokercard_pool = class("pokercard_pool")

function pokercard_pool:ctor()
	self.normalCardPool = {}
	self.smallCardPool = {}
	self.normalPath = "/normal_card/"
	self.smallPath = "/small_card/"
	
end

function pokercard_pool:GetCard(viewSeat,stCards)
	
	if stCards == nil or #stCards < 1 then return end
	local returnObjs = {}
	for i = 1,#stCards do
		local card = stCards[i]
		local pool = nil
		local newCard = nil
		if viewSeat == 1 then
			pool = self.normalCardPool
		else
			pool = self.smallCardPool
		end
		for j,v in ipairs(pool) do
			local cardName = tostring(card).."(Clone)"
			
			if cardName == v.name and v.gameObject.transform.parent == nil and v.transform.position.x == 0 then
			--	logError("命中缓存"..v.name)
				v.transform.position = Vector3(1,1,1)
				newCard = v
				break
			end
		end
		--如果缓存中没有，那么生成一个新的
		if newCard == nil then
			local path = ""
			if viewSeat == 1 then
				path = self.normalPath
			else
				path = self.smallPath
			end
		--	logError("生成对象:"..tostring(path).." viewSeat:"..tostring(viewSeat))
			local prefab = newNormalObjSync(data_center.GetResPokerCommPath()..path..tostring(card), typeof(GameObject))
			newCard = newobject(prefab)
			newCard.transform.position  = Vector3(1,1,1)
			table.insert(pool,newCard)
		end
		
		table.insert(returnObjs,newCard)
	end
	return returnObjs
end

function pokercard_pool:Recycle(cards)
	if cards == nil then return end
	for i,v in ipairs(cards) do 
		if v ~= nil then
			v.gameObject.transform.parent = nil
			v.transform.position = Vector3(0,0,0)
			v.gameObject:SetActive(false)
		end
	end
end

return pokercard_pool
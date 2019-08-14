local table_poker = class("table_poker")

function table_poker:ctor()
	self.player_counts = 0	--玩家数量
	self.gameObjct = nil
	self.meshFilter = nil
	self.meshRender = nil
	
	self.pokerAnimation = nil
	self.tableCenter = nil
	self.gun = nil
	self.cardTranPool = {}
	self.resPath = ""
	self:createObj()
	self:init()
	
end

function table_poker:createObj()
	local resTableObj = newNormalObjSync(self.resPath,typeof(GameObject))
	if self.gameObjct == nil then
		self.gameObjct = newobject(resTableObj)
	end
	self.meshFilter = self.gameObjct:GetComponentInChildren(typeof(UnityEngine.MeshFilter))
	self.meshRender = self.gameObjct:GetComponentInChildren(typeof(UnityEngine.MeshRenderer))
	return self.gameObjct
end

function table_poker:init()
	self.tableCenter = GameObject.Find("tableCenter")
	self.gun = GameObject.Find("qiang")
	self.pokerAnimation = child(self.tableCenter.transform, "Poker_Animaiton").gameObject
end

--[[--
 * @Description: 洗牌
 ]]
function table_poker:WashCard(callback)
	coroutine.start(function()
		ui_sound_mgr.PlaySoundClip("audio/xipai")   --洗牌音效
		if not IsNil(self.pokerAnimation) then
			self.tableCenter:SetActive(true)
			self.pokerAnimation:SetActive(true)		
			coroutine.wait(1.2)
			self.pokerAnimation:SetActive(false)
			self.tableCenter:SetActive(false)
		end
		if callback ~= nil then
			callback()
			callback = nil
		end
	end)		
end

--[[
 * @Description: 初始化桌子中心的扑克牌  
 ]]
function table_poker:InitCardPool(callback)
	if self.cardTranPool == nil or #self.cardTranPool < 1 then
		for i = 1, #this.PlayerList * 13 do 
			local cardPrefab = chess_item_factory:Instance():GetChessItem("Poker")
		--	local cardTran =  newobject(cardPrefab).transform
			local cardTran = cardPrefab.gameObject.transform
			cardTran.parent = self.tableCenter.transform
			cardTran.localPosition = Vector3(0, i/20, 0)
			cardTran.localEulerAngles = Vector3(0, 0, 180)
			table.insert(self.cardTranPool, cardTran)
		end
	end
	this.DealAnimation(callback)
end

--[[
 * @Description: 发牌动作  
 ]]
function  table_poker:DealAnimation(callback)
	local count = 1
	this.ResetDeal()
	coroutine.start(function ()								
		this.ShowDeal()
		ui_sound_mgr.PlaySoundClip("audio/fapai")  ----发牌音效
		for i =1, #this.cardTranPool / #this.PlayerList do
			for j ,Player in ipairs(this.PlayerList) do				
				--需要边移动边旋转
				local tmpTran = Player.playerObj.transform
				this.cardTranPool[count]:DOMove(tmpTran.position, 0.3, false)
				local toRotate = this.cardTranPool[count].localRotation + Vector3(0, i*50, 0)
				this.cardTranPool[count]:DOBlendableLocalRotateBy(toRotate, i*0.05, DG.Tweening.RotateMode.Fast)
				count = count + 1
			end
			coroutine.wait(0.01)
		end
		coroutine.wait(0.5)
		this.ResetDeal()
		if callback ~= nil then 
			callback()
			callback = nil			
		end
		for i, player in pairs(this.PlayerList) do
			local data = {}
			data.viewSeat = player.viewSeat
			data.state = true
			data.position = Utils.WorldPosToScreenPos(player.playerObj.transform.position)
			Notifier.dispatchCmd(cmd_shisanshui.ReadCard, data)
		end
	end)
end

--[[
 * @Description: 重置发牌动作
 ]]

function table_poker:ResetDeal()
	self.tableCenter:SetActive(true)
	for i = 1, #self.cardTranPool do
		self.cardTranPool[i].transform.parent = self.tableCenter.transform
		self.cardTranPool[i].transform.localPosition = Vector3(0,i/20,0)
		self.cardTranPool[i].transform.localEulerAngles = Vector3(0,0,180)
		self.cardTranPool[i].gameObject:SetActive(false)
	end
end

return table_poker
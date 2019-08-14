require "logic/niuniu_sys/ui/cuopai_ui"
require "logic/niuniu_sys/other/poker_table_coordinate"
local sangong_table_component = class("sangong_table_component")
function sangong_table_component:ctor()
	self.gvbl = player_seat_mgr.GetViewSeatByLogicSeat
	self.gvbln = player_seat_mgr.GetViewSeatByLogicSeatNum
	self.gmls = player_seat_mgr.GetMyLogicSeat
	self.mostPlayerList = {}
	self.playerList = {}
	self.tableCenter = nil
	self.cardTranPool = {}

	self.cardCount = 3
	self.cardLastCardValue = 0
	self.cuoPaiCard = {}
	self.Camera = Camera.main
	self.isOpenCard = true
	self.isFinshCuoPai = false
	self.data_manage = require("logic.poker_sys.sangong_sys.cmd_manage.sangong_data_manage"):GetInstance()
	self.offsetX = 10
	self.offsetY = 50
	self.cuoPaiAnchor = nil
	self.sangong_ui = UI_Manager:Instance():GetUiFormsInShowList("sangong_ui")
	self.pokerPool = require("logic.niuniu_sys.other.pokercard_pool"):create()
	
end

function sangong_table_component:InitPlayerTransForm()
	--local nPlayerNum = self.data_manage.roomInfo.nPlayerNum
	--self.currentTable = poker_table_coordinate.poker_table[nPlayerNum]
	self.tableCenter = GameObject.Find("tableCenter")
	if self.tableCenter == nil then
		logError("tableCenter is nil")
	end
	if table.getCount(self.playerList) > 0 then
		logError("===InitPlayerTransFormError"..tostring(table.getCount(self.playerList)))
		return
	end
	self:CreatePlayerList()
	self:InitCuoPaiAnchor()
	self:HeGuan()
	self:SetRoomNum()
	self:ChangeDeskCloth()
end

function sangong_table_component:CreatePlayerList()
	if isEmpty(self.mostPlayerList)then
		for i = 1,6 do
			local playerGameObject = GameObject.Find("poker_players/Player_"..tostring(i))
			playerGameObject:SetActive(false)
			local player = require("logic.poker_sys.sangong_sys.scene.sangong_player_component"):create(playerGameObject)
			player.pokerPool = self.pokerPool
			player.position_index = i
			table.insert(self.mostPlayerList,player)
		end
	end
end

function sangong_table_component:SetCurPlayerList(vs)
	local peopleNum = roomdata_center.maxplayernum
	
	self.currentTable = poker_table_coordinate.poker_table[peopleNum]
	
	for viewSeat,index in pairs(self.currentTable) do
	   	if vs == viewSeat then
			self.playerList[viewSeat] = self.mostPlayerList[index]
			self.playerList[viewSeat]["viewSeat"] = viewSeat
	   	end
	end
end

function sangong_table_component:RemoveCurPlayerList(vs)
	for viewSeat,v in pairs(self.playerList) do
		if self.playerList[viewSeat] and vs == viewSeat then
			self.playerList[viewSeat] = nil
		end
	end
end

function sangong_table_component:SetRoomNum()
	local trans = GameObject.Find("roominfos/roomNum").transform
	self.roomNumComp = require("logic/mahjong_sys/components/base/comp_mjRoomNum"):create(trans)
	self.roomNumComp:SetRoomNum(self.data_manage:GetRoomInfo().rno,data_center.GetResMJCommPath())
	local iconName = niuniu_rule_define.SUB_BULL_BANKERICONNAME[self.data_manage.roomInfo.GameSetting.takeTurnsMode]
	local tips = GameObject.Find("roominfos/roomInfo/tip1").transform
	self.roomNumComp:SetSpImgByTransform(tips,iconName,data_center.GetResPokerCommPath(),305,84)
end
--[[--
 * @Description: 洗牌
 ]]
function sangong_table_component:WashCard(callback)
	coroutine.start(function()
		ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/xipai")   --洗牌音效
		self.tableCenter:SetActive(true)
		self.heguan_manage:PlayHeGuanAnimationByClipName("xipai")
		coroutine.wait(1.5)
		self.tableCenter:SetActive(false)
		if callback ~= nil then
			callback()
			callback = nil
		end
	end)		
end

--[[--
 * @Description: 初始化牌形  
 ]]
function sangong_table_component:DealCard(callback)		
	self.tableCenter:SetActive(false)

	coroutine.start(function()
	if self.playerList ~= nil then	
		for i, player in pairs(self.playerList) do
			player:SetShufflePosition(self.tableCenter.transform)
			player.gameObject:SetActive(true)
		end
		self.heguan_manage:PlayHeGuanAnimationByClipName("daiji1")
		coroutine.wait(0.1)
		for i =1,self.cardCount  do
			for j, player in pairs(self.playerList) do
			--	player.gameObject:SetActive(true)
				player:shuffle(self.tableCenter.transform,i)
			end
			coroutine.wait(0.05)
			ui_sound_mgr.PlaySoundClip(data_center.GetResRootPath().."/sound/audio/fapai_feichu")  ----发牌音效
		end
	end
	coroutine.wait(0.2)
	self.heguan_manage:PlayHeGuanAnimationByClipName("daiji2")
		if callback ~= nil then
			callback()	
			callback = nil
			self.tableCenter:SetActive(false)
		end	
	end)			
end

--根据发牌数据，四明一暗的翻牌效果
function sangong_table_component:OnAskOpenCard()
	self.isOpenCard = false
	for i,v in pairs(self.playerList) do
		v.isPlayAnimationed = false
		v.isPlaySpecialCardAnimitoned = false
		if v.viewSeat == 1 then
			local stCards = self.data_manage.DealData._para.stCards
			v:SetCardMesh(stCards)
			v:ShowCard(false)
			--发送最后一张牌的位置给UI，可以显示提示手势
			local lastCard = v:GetLastCardPosition()
			local position = Utils.WorldPosToScreenPos(lastCard.transform.position)
			Notifier.dispatchCmd(cmd_niuniu.GETLASTCARDPOSITION, position)
		end
	end
end

function sangong_table_component:OnOpenCard(callback)
	local openCardsDatas = self.data_manage.OnOpenCardData
	local viewSeat = player_seat_mgr.GetViewSeatByLogicSeat(openCardsDatas._src)
	local stCards = openCardsDatas._para.stCards
	local bankerData = self.data_manage.BankerData
	if bankerData == nil then
		logError("庄家的数据不能为空！！！！！")
		if callback ~= nil then
			callback()
		end
		return
	end
	local bankerViewSeat = self.gvbln(bankerData._para.banker)
	coroutine.start(function()
	for i,v in pairs(self.playerList) do
		
		if bankerViewSeat == v.viewSeat  and v.viewSeat == viewSeat then
			--如果是庄家，并且不是坐位号这里显示已经完成摆牌的图标
			if v.viewSeat ~= 1 then
				local tbl = {}
				tbl.viewSeat = v.viewSeat
				local position = Utils.WorldPosToScreenPos(v.gameObject.transform.position)
				tbl.position = Vector3(position.x+35,position.y+25,position.z)
				Notifier.dispatchCmd(cmd_niuniu.SetFinishState,tbl)
			else
				--如果是自己的坐位，得显示特殊牌型图标
				local data = {}
				if openCardsDatas._para.nCardType >= 11 then
					self:DisplayCardTypeBy(v,openCardsDatas._para.nCardType,openCardsDatas._para.nBeishu,cmd_shisanshui.SpecialCardType)
					v.isPlayAnimationed = true
				else	
					self:DisplayCardTypeBy(v,openCardsDatas._para.nCardType,openCardsDatas._para.nBeishu,cmd_shisanshui.ReadCard)
					local time = niuniu_rule_define.PT_BULL_AnimationLength[openCardsDatas._para.nCardType]
					coroutine.wait(tonumber(time))
					v.isPlayAnimationed = true
				end
			end
		else	
			if v.viewSeat == viewSeat then
				v:SetCardMesh(stCards)
				v:ShowCard(true)	
				if openCardsDatas._para.nCardType >= 11 then
					--提前开出特殊牌型，只显示图标，不播全屏动画，
					self:DisplayCardTypeBy(v,openCardsDatas._para.nCardType,openCardsDatas._para.nBeishu,cmd_shisanshui.SpecialCardType)
					v.isPlayAnimationed = true
				else
					self:DisplayCardTypeBy(v,openCardsDatas._para.nCardType,openCardsDatas._para.nBeishu,cmd_shisanshui.ReadCard)
					local time = niuniu_rule_define.PT_BULL_AnimationLength[openCardsDatas._para.nCardType]
					coroutine.wait(tonumber(time))
					v.isPlayAnimationed = true
				end
			end
			end
		end
		if callback ~= nil then
			callback()
		end
	end)
end

--断线重连显示牌型
function sangong_table_component:Sync_OpenCard()
	Trace("断线重连搓牌阶段")
	local SyncOpenCardsDatas = self.data_manage.OnSyncTableData._para.stPlayerOpen
	
	for i,v in ipairs(SyncOpenCardsDatas) do
		local viewSeat = self.gvbln(v.chairid)
		local stCards = v.stCards
		for j,k in pairs(self.playerList) do
			if k.viewSeat == viewSeat then
				k:DisableDisplayCard()
				if stCards ~= nil and #stCards > 0 then
					k:SetCardMesh(stCards)
					k:SyncReset()
				end
			end	
		end
		--如果是自己的坐位号，填充自己的发牌数据
		if viewSeat == 1 and #v.stCards > 0 then
			if self.data_manage.DealData == nil then
				self.data_manage.DealData = {}
				self.data_manage.DealData._para = {}
			end
			self.data_manage.DealData._para.stCards = v.stCards
			self.data_manage.DealData._para.nBeishu = v.nBeishu
			self.data_manage.DealData._para.nCardType = v.nCardType
		end
	end
end

--判断是不是开牌
function sangong_table_component:Sync_CheckCardStatus(status)
	local bankerId = self.data_manage.OnSyncTableData._para.banker
	local bankerViewSeat = self.gvbln(bankerId)
	for i,v in ipairs(status) do
		local viewSeat = self.gvbln(i)
		for j,player in pairs(self.playerList) do
		local SyncOpenCardsDatas = self.data_manage.OnSyncTableData._para.stPlayerOpen
			local data = {}
			for i,v in ipairs(SyncOpenCardsDatas) do
				local viewSeat = self.gvbln(v.chairid)
				if viewSeat == player.viewSeat then
					data.viewSeat = player.viewSeat
					data.nCardType = v.nCardType
					data.nBeishu = v.nBeishu
					local position = Utils.WorldPosToScreenPos(player.gameObject.transform.position)
					data.position = Vector3(position.x + self.offsetX,position.y - self.offsetY,position.z)
					data.stCards = v.stCards
				end
			end
			if viewSeat == player.viewSeat then
				--我是庄家，那么不亮牌出来，只有自己能看
				if viewSeat == 1 and bankerViewSeat == 1 then
					if v == -1 then
						player:ShowCard(false)
					elseif v == 1 then
						player:ShowCard(true)
						Notifier.dispatchCmd(cmd_shisanshui.SpecialCardType, data)
					end
				end
				if viewSeat ==1 and viewSeat ~= bankerViewSeat then
					if v == -1 then
						player:ShowCard(false)
					elseif v == 1 then
						player:ShowCard(true)
						Notifier.dispatchCmd(cmd_shisanshui.SpecialCardType, data)
					end
				end
				if viewSeat == bankerViewSeat and viewSeat ~= 1  then
					player:DisableDisplayCard()	
					--这里得显示一个完成按钮
					-- do something
					if v == 1 then
						local tbl = {}
						tbl.viewSeat = player.viewSeat
						local position = Utils.WorldPosToScreenPos(player.gameObject.transform.position)
						tbl.position = Vector3(position.x+35,position.y+25,position.z)
						Notifier.dispatchCmd(cmd_niuniu.SetFinishState,tbl)
					end
				end
				if viewSeat ~= bankerViewSeat then
					if v == -1 then
						player:DisableDisplayCard()
					elseif v == 1 then
						player:ShowCard(true)
						Notifier.dispatchCmd(cmd_shisanshui.SpecialCardType, data)
					end
				end
			end
		end
	end
end

--比牌结果
function sangong_table_component:OnCompareResult(callback)
	self.heguan_manage:PlayHeGuanAnimationByClipName("daiji3")
	self:SetCuoPaiAnchor(false)
--	cuopai_ui.Hide() --关闭搓牌界面
	UI_Manager:Instance():CloseUiForms("cuopai_ui")
	local compareResultData = self.data_manage.CompareResultData
	local stAllCompareData = compareResultData._para.stAllCompareData
	if stAllCompareData ~= nil and #stAllCompareData > 0 then
		local AllCompareData = {}
		local bankerData = self.data_manage.BankerData
		local bankerCompareData = {}
		for i,v in ipairs(stAllCompareData) do 
			if v.chairid == bankerData._para.banker then
				bankerCompareData = v
			else
				table.insert(AllCompareData,v)
			end
		end
		table.insert(AllCompareData,bankerCompareData)
		coroutine.start(function()
		for i,v in ipairs(AllCompareData) do
			local viewSeat = player_seat_mgr.GetViewSeatByLogicSeatNum(v.chairid)
			local stCards = v.stCards
			local nBeishu = v.nBeishu
			for j,k in pairs(self.playerList) do
				if viewSeat == k.viewSeat then
					k:SetCardMesh(stCards)
					k:ShowCard(true)
					if  k.isPlayAnimationed ==false then		
						self:DisplayCardTypeBy(k,v.nCardType,v.nBeishu,cmd_shisanshui.ReadCard)
						local time = niuniu_rule_define.PT_BULL_AnimationLength[v.nCardType]
						coroutine.wait(tonumber(time))
						k.isPlayAnimationed = true
					end
				end
			end
		end
		if 	compareResultData._para.nAllWinOrLooses == 1 then
			coroutine.wait(1)
			self.sangong_ui:PlayTongShaAnimation()
			coroutine.wait(2)
		end
		if callback ~= nil then
			callback()
		end
		end)
	end	
end

function sangong_table_component:DisplayCardTypeBy(player,nCardType,nBeishu,cmd)
	local data = {}
	data.viewSeat = player.viewSeat
	data.nCardType = nCardType
	data.nBeishu = nBeishu
	local position =Utils.WorldPosToScreenPos(player.gameObject.transform.position)
	data.position = Vector3(position.x + self.offsetX,position.y - self.offsetY,position.z)
	Notifier.dispatchCmd(cmd, data)
end

function sangong_table_component:MouseBinDown(position)
	if self.Camera == nil then
		self.Camera = Camera.main
	end
	local ray = self.Camera:ScreenPointToRay(position)
	if ray == nil then return end
	local isCast,rayhit = Physics.Raycast(ray,nil)
	if isCast then
		 local tempObj = rayhit.collider.gameObject
		
		 local tempObj = rayhit.collider.gameObject
		local IsOpenCuoPaiUI = false
		local cuopai_ui =  UI_Manager:Instance():GetUiFormsInShowList("cuopai_ui")
		if cuopai_ui ~= nil then
			IsOpenCuoPaiUI = cuopai_ui.IsOpenCuoPaiUI
		end
		if tempObj.transform.parent.name == "Card3" and tempObj.transform.parent.parent.parent.name == "Player_1" and IsOpenCuoPaiUI == false then
			if self.isOpenCard == false then
				coroutine.start(function()
				local y = tempObj.transform.localRotation.eulerAngles.y
				tempObj.transform:DOLocalRotate(Vector3(0, y, -1), 0.3, DG.Tweening.RotateMode.Fast)	
				Notifier.dispatchCmd(cmd_shisanshui.Card_RECOMMEND,nil)
				coroutine.wait(1.2)
				local stRecommendCards = self.data_manage.DealData._para.stRecommendCards
				if stRecommendCards ~= nil then
					self.data_manage.DealData._para.stCards = stRecommendCards
					self.playerList[1]:SetCardMesh(self.data_manage.DealData._para.stCards)
					self.playerList[1]:ShowCard(true)
				end
				self.isOpenCard = true
				end)
			end
		end
	end
	
	
	self.heguan_manage:MouseBinDown(position)
end

--翻开最后一张牌
function sangong_table_component:OpenLastCard()
	for i,v in pairs(self.playerList) do
		if v.viewSeat == 1 then
			coroutine.start(function()
			local lastCard = v:GetLastCardPosition()
			local y = lastCard.transform.localRotation.eulerAngles.y
			lastCard.transform:DOLocalRotate(Vector3(0, y, 0), 0.6, DG.Tweening.RotateMode.Fast)
			
			Notifier.dispatchCmd(cmd_shisanshui.Card_RECOMMEND,nil)
			self.isOpenCard = true
			coroutine.wait(1.2)
			
			local stRecommendCards = self.data_manage.DealData._para.stRecommendCards
			if stRecommendCards ~= nil then
				self.data_manage.DealData._para.stCards = stRecommendCards
				self.playerList[1]:SetCardMesh(self.data_manage.DealData._para.stCards)
				self.playerList[1]:ShowCard(true)
			end
			end)
		end
	end
end

--设置搓牌的值
function sangong_table_component:GetLastCardValue()
	if self.cuoPaiAnimObj ~= nil then
		if #self.cuoPaiCard < 1 then
			local meshFilters = self.cuoPaiAnimObj:GetComponentsInChildren(typeof(UnityEngine.SkinnedMeshRenderer))
			for i = 0, meshFilters.Length - 1,1 do
				table.insert(self.cuoPaiCard,meshFilters[i])		
			end
		end
	end
	local cardData = self.data_manage.DealData._para.stCards
	local lastCard = nil
	if #cardData >= self.cardCount then
		local value = cardData[self.cardCount]
		local index = poker3D_dictionary.Get3DPokerMeshIndex[value]
		Trace("niuniu cuo pai index"..tostring(index))
		lastCard = self:SetCuoPaiCardMesh(index + 1)
	end
	return lastCard
end

function sangong_table_component:SetCuoPaiCardMesh(index)
	--	local mesh = this.niuniuCard[index]
	local meshObj = nil
	for i,v in ipairs(self.cuoPaiCard) do
		if i == index then
			v.gameObject:SetActive(true)
			meshObj = v.gameObject
		else
			v.gameObject:SetActive(false)
		end
	end
	if meshObj == nil then
		Trace("GetNiuNiuCuoPaiCardMesh !!!!!!!!!!!!!!!!!!!!!!!!!! error !!!!!!!!! index"..index)
	end
	return meshObj
end	

function sangong_table_component:InitCuoPaiAnchor()	
	if self.poker_cuopai_manage == nil then
		self.poker_cuopai_manage = require("logic/poker_sys/other/poker_cuopai_manage"):create()
	end
	
end

function sangong_table_component:SetCuoPaiAnchor(isShow)	
	local lastCard = nil
	if isShow == true then
		local cardData = self.data_manage.DealData._para.stCards
	
		if #cardData >= self.cardCount then
			 lastCard = cardData[self.cardCount]
		end
	end
--	logError("lastCard"..tostring(lastCard))
	self.poker_cuopai_manage:SetCuoPaiAnchor(isShow,lastCard)
	
end

function sangong_table_component:OnDragAction(gesture)
	local cardData = self.data_manage.DealData._para.stCards
	local lastCard = nil
	if #cardData >= self.cardCount then
		 lastCard = cardData[self.cardCount]
	end
	self.poker_cuopai_manage:OnDragAction(gesture,lastCard,function()
		self:OpenLastCard() --翻开最后一张牌
	end)
end

function sangong_table_component:HeGuan()
	if self.heguan_manage == nil then
		self.heguan_manage = require("logic/poker_sys/other/heguan_manage"):create()
	end
end

function sangong_table_component:ChangeDeskCloth()
	if self.poker_chaneg_desk == nil then
		local poker_table = GameObject.Find("poker_table/poker_table01")
		if poker_table ~= nil then
			self.poker_chaneg_desk = require("logic.poker_sys.other.poker_change_desk"):create(poker_table,self.roomNumComp)
		else
			logError("找不到poker_table")
		end
	end
	self.poker_chaneg_desk:ChangeDeskCloth()
end

--重置发牌动作
function sangong_table_component:ResetDeal()
	self.tableCenter:SetActive(true)
	for i = 1, #self.cardTranPool do
		self.cardTranPool[i].transform.parent = self.tableCenter.transform
		self.cardTranPool[i].transform.localPosition = Vector3(0,i/20,0)
		self.cardTranPool[i].transform.localEulerAngles = Vector3(0,0,180)
		self.cardTranPool[i].gameObject:SetActive(false)
	end
end

function sangong_table_component:ReSetAll()
	self.isOpenCard = true
--	self.poker_cuopai_manage.isFinshCuoPai = false
	self.poker_cuopai_manage:Reset()
	self:ResetPlayerList()
end

function sangong_table_component:ReSetPlayerByViewSeat(viewSeat)
	self.playerList[viewSeat]:PlayerReset()
end

--重置发牌动作
function sangong_table_component:ResetPlayerList()
	for i ,player in pairs(self.playerList) do
		player:PlayerReset()
	end
end
return sangong_table_component